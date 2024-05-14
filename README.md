# deck-checker
Given an election (i.e., a ballot style) definition and a test deck, produces a swap (i.e., a non-identity bijective mapping) between swaps and candidates that is not detected by the test deck (if such a swap exists). 

## Dependencies 
Required software:
- [Julia programming language](https://julialang.org/)
  Required Julia packages:
- [JuMP](https://jump.dev/JuMP.jl/stable/)
- [MathOptInterface](https://jump.dev/MathOptInterface.jl/stable/)
- [HiGHS.jl](https://github.com/jump-dev/HiGHS.jl)

## Licenses
`deck-checker.jl` is licensed under the [MIT License](LICENSE.md).

## Getting started
Run the file `example.jl` using Julia to see a documented example of how to run the code. 
