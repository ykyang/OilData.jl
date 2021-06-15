# Simply put
# Run from terminal
#   julia --project=@. test/runtests.jl
#
# Run from REPL
#   julia> include("test/runtests.jl")
# When run from REPL, may need to exit out to force re-compile of the module.
# 
#
# Document
# http://abelsiqueira.github.io/blog/test-driven-development-in-julia/
#
# Run test from command line
#   cd OilData/
#   julia --project=@. test/runtests.jl
# This way it will not print out bunch of package information.
# pwd() = OilData/
#
# Run test from Julia in OilData/
#   cd OilData/
#   julia --project=@.
#   import Pkg
#   Pkg.test("OilData")
# This will print out bunch of package information.
# This can be done anywere where OilData package is loaded.
# pwd() is OilData/test/
#
# Run the test from Package mode
# pkg> test OilData
# pwd() is OilData/test/
#
# Add package to test/.
#   cd OilData/
#   julia --project=test
#
# FactCheck package not found

using Test
using Dates
using Logging

# see https://discourse.julialang.org/t/writing-tests-in-vs-code-workflow-autocomplete-and-tooltips/57488
# see https://github.com/julia-vscode/julia-vscode/issues/800
if isdefined(@__MODULE__, :LanguageServer)
    # invoked by VS Code
    include("../src/OilData.jl")
    using .OilData
else
    # invoked during test
    using OilData
end

logger = ConsoleLogger(stdout, Logging.Info)
global_logger(logger)

@test true == true
@test false == false

function data_dir()
    
    #@info "pwd(): $(pwd())"
    # if basename(path) == "OilData"
    #     path = joinpath(path, "test")
    # end

    path = joinpath(pwd(), "data")
    if isdir(path)
        return path # ".../.../../OilData/test/data"
    end

    path = joinpath(pwd(), "test", "data")
    if isdir(path)
        return path # ".../.../../OilData/test/data"
    end

    path = joinpath(pwd(), "..", "data")
    if isdir(path)
        return path # ".../.../../OilData/test/data"
    end

    path = joinpath(pwd(), "..", "..", "data")
    if isdir(path)
        return path # ".../.../../OilData/test/data"
    end

    path = joinpath(pwd(), "..", "..", "..", "data")
    if isdir(path)
        return path # ".../.../../OilData/test/data"
    end

    return nothing
end

#include("driver.jl")
include("test_parser.jl")
