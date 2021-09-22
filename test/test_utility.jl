using Test
using DataFrames

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

function test_find_integers()
    values = [0, 0.5, 1.0, 1.2, 2, 2.5, 3, 3.8, 4]
    inds,ints = find_integers(values)
    @test inds == [1,3,5,7,9]
    @test ints == [0, 1, 2, 3, 4]
end

function test_find_indices()
    # indices are order by the values array,
    # not the filter
    values = [0, 0.5, 1.0, 1.2, 2, 2.5, 3, 3.8, 4]
    filter = [1, 3]
    inds = find_indices(filter, values)
    @test inds == [3,7]

    values = [0, 0.5, 1.0, 1.2, 2, 2.5, 3, 3.8, 4]
    filter = [3, 1]
    inds = find_indices(filter, values)
    @test inds == [3,7]

    # Reverse the order of values
    values = reverse([0, 0.5, 1.0, 1.2, 2, 2.5, 3, 3.8, 4])
    filter = [1, 4]
    inds = find_indices(filter, values)
    @test inds == [1,7]

    values = reverse([0, 0.5, 1.0, 1.2, 2, 2.5, 3, 3.8, 4])
    filter = [4, 1]
    inds = find_indices(filter, values)
    @test inds == [1,7]
end


function test_smooth_production()
    @show pwd()

    df = DataFrame( # Pair constructor
        "TIME" => [
            0,

            0.5,
            1.0, 
            
            1.2,
            2,

            2.5,
            3,
            
            3.8,
            4,
        ], 
        "WOPR" => [
            0,
            5,
            10, 
            12,
            20,
            25,
            30,
            38,
            40,
        ],
    )

    rdf = smooth_production(df, "TIME", ["WOPR"])
    @test rdf[!,"TIME"] == [0, 1, 2, 3, 4]
    @test rdf[!,"WOPR"] == [0.0, 7.5, 18.4, 27.5, 38.4]
end

@testset "utility" begin
    test_find_integers()
    test_find_indices()
    test_smooth_production()
end