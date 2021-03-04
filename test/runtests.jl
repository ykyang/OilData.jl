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
using OilData

@test true == true
@test false == false

function data_dir()
    path = pwd()

    if basename(path) == "OilData"
        path = joinpath(path, "test")
    end

    path = joinpath(path, "data")

    return path # ".../.../../OilData/test/data"
end

include("driver.jl")

