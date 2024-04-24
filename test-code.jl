
function RunTest(num_candidates, num_votes, ballots, n_expected, p_expected=false)

    n, p = FindSwap(num_candidates, num_votes, ballots, Model(()->Gurobi.Optimizer(gurobi_env)))
    return n == n_expected && (p_expected == false || p == p_expected)

end

# Single 2-candidate contest
@assert RunTest([2], [2], [[1,2]], 2, [2,1])
@assert RunTest([2], [1], [[1], [2]], 2, [2,1])
@assert RunTest([2], [2], [[1], [2], [1,2]], 2, [2,1])
@assert RunTest([2], [1], [], 2, [2,1])
@assert RunTest([2], [1], [[1], [2], [2]], 0, [1,2])
@assert RunTest([2], [2], [[1,2], [2]], 0, [1,2])

# Two 1c1 contests
@assert RunTest([1,1], [1,1], [[1,2]], 2, [2,1])
@assert RunTest([1,1], [1,1], [[1], [2]], 2, [2,1])
@assert RunTest([1,1], [1,1], [[1], [2], [1,2], []], 2, [2,1])
@assert RunTest([1,1], [1,1], [[1], [2], [2]], 0, [1,2])
@assert RunTest([1,1], [1,1], [[1,2], [1]], 0, [1,2])


@assert RunTest([1,2], [1,1], [[1,2], [3], [3]], 2, [2,1,3])
@assert RunTest([1,2], [1,1], [[1,3], [2], [3]], 0, [1,2,3])
@assert RunTest([1,2], [1,2], [[1,3], [2], [3]], 2, [2,1,3])
