# deck-checker
This repository provides code for checking whether there exists a swap (i.e., a non-identity bijective mapping) between targets and candidates that would not be detected by a given test deck for a given election (i.e., ballot style). The code in this repository exclusively utilizes open source software and is freely available for use under an [MIT License](LICENSE.md). 

## Dependencies 
Required software:
- [Julia programming language](https://julialang.org/)
  
Required Julia packages:
- [JuMP](https://jump.dev/JuMP.jl/stable/)
- [MathOptInterface](https://jump.dev/MathOptInterface.jl/stable/)
- [HiGHS.jl](https://github.com/jump-dev/HiGHS.jl)


## Getting started
Run the file `example.jl` using Julia to see a documented example of how to run the code. 
