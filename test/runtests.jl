################################################################################
#
# Document
# http://abelsiqueira.github.io/blog/test-driven-development-in-julia/
#
################################################################################
# The package directory needs to be "instantiate" in order to run from the 
# package directory.
#
# Run test from command line
#   $ cd OilData/
#   $ julia --project=@. test/runtests.jl
#
# Run test from REPL
#   $ cd OilData/
#   $ julia --project=@.
#   julia> include("test/runtests.jl")
#
# Run test from REPL using Pkg
#   $ cd OilData/
#   $ julia --project=@.
#   julia> import Pkg
#   julia> Pkg.test("OilData")
#
# Run test from Package mode
#   $ cd OilData/
#   $ julia --project=@.
#   julia> ]
#   (OilData) pkg> test OilData
#
################################################################################
# Add package to test/.
#   cd OilData/
#   julia --project=test
#   ]
#   add DataFrames
################################################################################
# Run from REPL, in development environment
#   $ cd OilDataDev/
#   $ julia --project=@.
#   julia> include("dev/OilData/test/runtests.jl")
#   julia> include("dev/OilData/test/test_parser.jl")
#   julia> include("dev/OilData/test/test_utility.jl")
# One can run in the development environment
#   julia> using Revise
# to speed up the development cycle.
################################################################################



# In a development parent project such as
#   OilDataDev/
# where OilData.jl is checkout in dev/
#   OilDataDev/dev/OilData/
#
#   cd OilDataDev/
#   julia --project=@.
#   using Revise
#   include("dev/OilData/test/runtests.jl")
# Test individual files
#   include("dev/OilData/test/test_parser.jl")
#   include("dev/OilData/test/test_utility.jl")



# Not working
# Is this the best way for development?
#   cd OilData/
#   julia --project=test
#   

using Test
using Dates

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

include("common.jl")

local_6cfddc95df03456583406d57fd5963ac = false

include("test_parser.jl")
include("test_utility.jl")
