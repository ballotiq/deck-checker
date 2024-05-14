# deck-checker
This repository provides code for checking whether there exists a swap (i.e., a non-identity bijective mapping) between targets and candidates that would not be detected by a given test deck for a given election (i.e., ballot style). The code in this repository exclusively utilizes open source software and is freely available for use under an [MIT License](LICENSE.md). 

## Dependencies 
Required software:
- [Julia programming language](https://julialang.org/)
  
Required Julia packages:
- [JuMP](https://jump.dev/JuMP.jl/stable/)
- [MathOptInterface](https://jump.dev/MathOptInterface.jl/stable/)
- [HiGHS.jl](https://github.com/jump-dev/HiGHS.jl)


## Installation
```julia
import Pkg
Pkg.add("JuMP")
Pkg.add("MathOptInterface")
Pkg.add("HiGHS")

```

## Quick Example
The following example is based on Figure 2 from the paper [Improving the Security of United States Elections with Robust Optimization](https://arxiv.org/pdf/2308.02306). 
```julia
using JuMP
using MathOptInterface
using HiGHS

include("find-attack.jl")

###############################################
# Set up the following election:
# 
#   Contest 1: Three candidates (1,2,3), voter may select at most one candidate
#   Contest 2: Two candidates (4,5), voter may select at most one candidate
###############################################

num_candidates_per_contest = Vector{Int}()
num_votes_per_contest = Vector{Int}()

# Contest 1
push!(num_candidates_per_contest, 3)
push!(num_votes_per_contest, 1)

# Contest 2
push!(num_candidates_per_contest, 2)
push!(num_votes_per_contest, 1)

###############################################
# Construct the following test deck:
#
#   Ballot 1: Vote for candidates 1,4
#   Ballot 2: Vote for candidates 2,5
#   Ballot 3: Vote for candidates 2,5
#   Ballot 4: Vote for candidate  3
#   Ballot 5: Vote for candidate  3
#   Ballot 6: Vote for candidate  3
###############################################

test_deck = Vector{Vector{Int}}()
push!(test_deck, [1,4])
push!(test_deck, [2,5])
push!(test_deck, [2,5])
push!(test_deck, [3])
push!(test_deck, [3])
push!(test_deck, [3])

###############################################
# Find a swap that is not detected by the
# above test deck
###############################################

n, p = FindSwap(num_candidates_per_contest, num_votes_per_contest, test_deck,Model(()->HiGHS.Optimizer()))

# Print the output
println("-----------------------------")
println("Test Deck 1")
for b=1:length(test_deck)
    println("\tBallot ",b,": ", test_deck[b])
end
println("Minimal swap: n = ",n)
for i=1:5
    println("\tCandidate ", i, " receives votes from target ", p[i])
end

###############################################
# If n is greater than 0, then there exists a
# swap that is not detected by the test deck
#
# In the above example, n should be equal to 2, which
# means that the swap found by the `FindSwap` function
# involves swapping two candidates.
#
# The swap found by the `FindSwap` function is
# encoded in the variable `p`. Specifically,
# for each i=1,...,N, we have the interpretation
# # that 
#
# p[i] = target that is interpretted as
#        as associated with candidate i
#
# Below is an example of test deck for the
# same election as above that does not have
# any undetected swaps.
###############################################

test_deck = Vector{Vector{Int}}()
push!(test_deck, [1,5])
push!(test_deck, [2,4])
push!(test_deck, [2])
push!(test_deck, [3,5])
push!(test_deck, [3])
push!(test_deck, [3])

n, p = FindSwap(num_candidates_per_contest, num_votes_per_contest, test_deck,Model(()->HiGHS.Optimizer()))

# Print the output
println("-----------------------------")
println("Test Deck 2")
for b=1:length(test_deck)
    println("\tBallot ",b,": ", test_deck[b])
end
println("Minimal swap: n = ",n,"... no swap found!")
```
Run the file `example.jl` using Julia to see a documented example of how to run the code. 
