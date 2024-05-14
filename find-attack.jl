using JuMP, MathOptInterface

function FindSwap(
        num_candidates_per_contest::Vector{Int},
        num_votes_per_contest::Vector{Int},
        test_deck::Vector{Vector{Int}},
        model::Model
    )::Tuple{Int, Vector{Int}}

    # Turn off output for solver
    set_silent(model)

    # Process election for auxiliary data
    num_candidates = sum(num_candidates_per_contest)
    num_contests = length(num_candidates_per_contest)
    num_ballots = length(test_deck)
 
    # Check that election is well-formed
    @assert length(num_candidates_per_contest) == length(num_votes_per_contest)
    @assert all(n->n≥1, num_candidates_per_contest)
    @assert all(r->r≥1, num_votes_per_contest)

    # Check that test deck is well-formed
    @assert num_ballots > 0

    # Create mapping between candidates and contests
    candidate_to_contest = Vector{Int}()
    contest_to_candidates = Vector{Vector{Int}}()
    for c=1:num_contests
        push!(contest_to_candidates, Vector{Int}())
        for _=1:num_candidates_per_contest[c]
            push!(candidate_to_contest, c)
            push!(contest_to_candidates[c], length(candidate_to_contest))
        end
    end

    well_formed(ballot) = (
        all(candidate->(1 ≤ candidate ≤ num_candidates), ballot) &&     # Each candidate is valid, and
        (length(Set(ballot)) == length(ballot)) &&                      # Each candidate appears only once, and
        all(contest->(length([i for i in contest_to_candidates[contest] if i in ballot]) ≤ num_votes_per_contest[contest]), 1:num_contests)                                             # Each contest does not contain an overvote
    )
    @assert all(well_formed, test_deck)

    # Process test_deck for auxiliary data
    num_test_deck_per_candidate = zeros(Int, num_candidates)
    for ballot in test_deck
        for candidate in ballot
            num_test_deck_per_candidate[candidate] += 1
        end
    end

    # Define auxiliary function for whether candidates have the same number of votes
    in_group(i, j) = (num_test_deck_per_candidate[i] == num_test_deck_per_candidate[j])
    
    ####################################
    #
    #  MIP Formulation (see https://arxiv.org/pdf/2308.02306.pdf § 4.2.2) 
    #
    ####################################
    
    # Define matrix x such that x[i,j] == 1 if and only if candidate i recieves a vote when target j is marked
    @variable(model, x[i=1:num_candidates, j=1:num_candidates], binary = true)
    
    # No solution will include a swap involving candidates with different numbers of votes
    for i=1:num_candidates-1
        for j=i+1:num_candidates
            if !in_group(i,j)
                fix(x[i,j],0)
                fix(x[j,i],0)
            end
        end
    end

    # Ensure that the mapping between target and candidate is bijective
    @constraint(model, [i=1:num_candidates], sum(x[i,j] for j=1:num_candidates) == 1)
    @constraint(model, [j=1:num_candidates], sum(x[i,j] for i=1:num_candidates) == 1)

    # Ensure that model does not cause an unexpected overvote
    @constraint(model, [c=1:num_contests, b=1:length(test_deck)],
                sum(sum(x[i,j] for i in contest_to_candidates[c]) for j in test_deck[b])
                ≤ num_votes_per_contest[c])
    
    # Require that at least one candidate receives votes from some other target
    @constraint(model, sum(x[i,i] for i=1:num_candidates) ≤ num_candidates-2)
    
    # Attempt to find the swap that involves the fewest number of candidates possible
    @objective(model, Max, sum(x[i,i] for i=1:num_candidates))

    # Solve the MIP
    optimize!(model)

    # If the MIP has no solutions, no swap exists
    if termination_status(model) != MathOptInterface.OPTIMAL
        return 0, [i for i=1:num_candidates]
    end
    
    # Otherwise, return the permutation of candidates
    count = 0
    permutation = Vector{Int}()
    # For each candidate...
    for i=1:num_candidates
        # ...append the target that maps to the candidate
        for j=1:num_candidates
            if value(x[i,j]) ≥ 0.5
                if i != j
                    count += 1
                end
                push!(permutation,j) 
                break
            end
        end
    end

    return count, permutation
end

