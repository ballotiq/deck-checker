# deck-checker
This repository provides code to determine, given an election (i.e., a ballot style) and a test deck, whether there exists a swap (i.e., a non-identity bijective mapping) between targets and candidates that is not detected by the test deck. 

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
