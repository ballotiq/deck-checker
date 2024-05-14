include("find-attack.jl")

using Test
using JuMP
using HiGHS

function RunTest(num_candidates_per_contest, num_votes_per_contest, test_deck, n_expected, p_expected=false)

    # Create a JuMP model instance
    model = Model(()->HiGHS.Optimizer())
    set_silent(model)

    # Run the FindSwap function
    n, p = FindSwap(num_candidates_per_contest, num_votes_per_contest, test_deck,model)

    # Return result of findswap function
    return n == n_expected && (p_expected == false || p == p_expected)
end


###########################################################
# Check error messages
###########################################################

# Check for vote for non-existant candidate in ballot in test deck
@test_throws AssertionError RunTest([1], [1], [[0]], 0, [0]) 

# Check for candidate receiving multiple votes in ballot in test deck
@test_throws AssertionError RunTest([1], [1], [[1,1]], 0, [0]) 

# Check for overvoted contest in ballot in test deck
@test_throws AssertionError RunTest([2], [1], [[1,2]], 0, [0]) 


###########################################################
# Election with single 2c1 contest
# (i.e., single contest with two candidates in which a 
#   voter may select up to one candidate)
###########################################################

@test RunTest([2], [1], [[1], [2]], 2, [2,1])
@test RunTest([2], [1], [Int[]], 2, [2,1])
@test RunTest([2], [1], [[1], [2], [2]], 0, [1,2])


###########################################################
# Election with single 2c2 contest
###########################################################

@test RunTest([2], [2], [[1,2]], 2, [2,1])
@test RunTest([2], [2], [[1], [2], [1,2]], 2, [2,1])
@test RunTest([2], [2], [[1,2], [2]], 0, [1,2])


###########################################################
# Election with two 1c1 contests
###########################################################

@test RunTest([1,1], [1,1], [[1,2]], 2, [2,1])
@test RunTest([1,1], [1,1], [[1], [2]], 2, [2,1])
@test RunTest([1,1], [1,1], [[1], [2], [1,2], Int[]], 2, [2,1])
@test RunTest([1,1], [1,1], [[1], [2], [2]], 0, [1,2])
@test RunTest([1,1], [1,1], [[1,2], [1]], 0, [1,2])


###########################################################
# Election with single 2c1 contest and single 1c1 contest
###########################################################

@test RunTest([1,2], [1,1], [[1,2], [3], [3]], 2, [2,1,3])
@test RunTest([1,2], [1,1], [[1,3], [2], [3]], 0, [1,2,3])
@test RunTest([1,2], [1,2], [[1,3], [2], [3]], 2, [2,1,3])


###########################################################
# Election with three 2c1 contests
###########################################################
@test RunTest([2,2,2], [1,1,1], [[1,6], [2,3], [4,5], [2,4,6],[4,6],[6]], 3, [5,2,1,4,3,6])
