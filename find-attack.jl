using JuMP, MathOptInterface

function FindSwap(
        num_candidates_per_contest::Vector{Int},
        num_votes_per_contest::Vector{Int},
        ballots::Vector{Vector{Int}},
        solver_model
    )::Tuple{Bool, Vector{Int}}


    # Check that election is well-formed
    @assert length(num_candidates_per_contest) == length(num_votes_per_contest)
    @assert all(n->n≥1, num_candidates_per_contest)
    @assert all(r->r≥1, num_votes_per_contest)

    # Process election for auxiliary data
    num_candidates = sum(num_candidates_per_contest)
    num_contests = length(num_candidates_per_contest)
    
    candidate_to_contest = Vector{Int}()
    contest_to_candidates = Vector{Vector{Int}}()
    
    for c=1:num_contests
        push!(contest_to_candidates, Vector{Int}())
        for _=1:num_candidates_per_contest[c]
            push!(candidate_to_contest, c)
            push!(contest_to_candidates[c], length(candidate_to_contest))
        end
    end

    # Check that the ballots are well-formed
    well_formed(ballot) = (
        all(candidate->(1 ≤ candidate ≤ num_candidates), ballot) &&     # Each candidate is valid, and
        (length(Set(ballot)) == length(ballot)) &&                      # Each candidate appears only once, and
        true # TODO check overvote
    )
    @assert all(well_formed, ballots)

    # Process ballots for auxiliary data
    num_ballots_per_candidate = zeros(Int, num_candidates)
    for ballot in ballots
        for candidate in ballot
            num_ballots_per_candidate[candidate] += 1
        end
    end

    # Define auxiliary function for whether candidates have the same number of votes
    in_group(i, j) = (num_ballots_per_candidate[i] == num_ballots_per_candidate[j])
    
    ####################################
    #
    #  MIP Formulation (see https://arxiv.org/pdf/2308.02306.pdf § 4.2.2) 
    #
    ####################################
    
    # Define matrix x such that x[i,j] == 1 if and only if candidate i recieves a vote when target j is marked
    @variable(solver_model, x=[i=1:num_candidates, j=1:num_candidates], Bin)
    
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
    @constraint(solver_model, [i=1:num_candidates], sum(x[i,j] for j=1:num_candidates if in_group(i,j)) == 1)
    @constraint(solver_model, [j=1:num_candidates], sum(x[i,j] for i=1:num_candidates if in_group(i,j)) == 1)

    # Ensure that model does not cause an unexpected overvote
    @constraint(solver_model, [c=1:num_contests, b=1:length(ballots)],
                sum(sum(x[i,j] for j in contest_to_candidates[c] if in_group(i,j)) for i in ballots[b])
                ≤ num_votes_per_contest[c])
    
    # Require that at least one candidate receives votes from some other target
    @constraint(solver_model, sum(x[i,i] for i=1:num_candidates) ≤ num_candidates-2)
    
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
    # For each target...
    for i=1:num_candidates
        # ...append the index of the corresponding candidate
        for j=1:num_candidates
            if x[i,j] ≥ 0.5
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

