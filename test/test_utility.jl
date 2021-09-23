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

# Avoid include common.jl multiple times
if !@isdefined local_6cfddc95df03456583406d57fd5963ac
    local_6cfddc95df03456583406d57fd5963ac = true
end
if local_6cfddc95df03456583406d57fd5963ac
    include("common.jl")
end

function test_downsample()
    values = [1, 1.1, 2, 2.2, 2.5, 3, 4, 4.3, 5, 5.5, 6, 7, 8]
    @test downsample(values,2) == [1, 3, 5, 7, 8]
    @test downsample(values,3) == [1, 4, 7, 8]
end

function test_find_duplication()
    values = [1, 1.5, 2, 2, 2, 2, 3]
    dup_inds, dup_vals = find_duplication(values)
    @test dup_inds == [4,5,6]
    @test dup_vals == [2,2,2]
end

function test_find_integers()
    values = [0, 0.5, 1.0, 1.2, 2, 2.5, 3, 3.8, 4]
    inds,ints = find_integer_times(values)
    @test inds == [1,3,5,7,9]
    @test ints == [0, 1, 2, 3, 4]

    values = [0, 0.5, 2, 3, 3, 4]
    @test_throws ErrorException find_integer_times(values)
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

    # Duplicated values
    values = [0, 1, 0.5, 2, 3, 3, 3.8, 4]
    filter = [1, 3]
    @test_throws ErrorException find_indices(filter, values)
end

function test_find_last_duplication()
    @test 1 == find_last_duplication(1, [1, 1.5, 2, 2, 2, 2, 3]) # 1
    @test 6 == find_last_duplication(3, [1, 1.5, 2, 2, 2, 2, 3]) # 2
    @test 7 == find_last_duplication(7, [1, 1.5, 2, 2, 2, 2, 3]) # 3
end

function test_repair_times()
    times = [1, 1.5, 2, 2, 2, 2, 3]
    @test [1, 1.5, 2, 2.25, 2.50, 2.75, 3] == repair_times(times)
end

function test_smooth_production()
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

@testset "utility/smooth" begin
    test_downsample()
    test_find_duplication()
    test_find_integers()
    test_find_indices()
    test_find_last_duplication()
    test_repair_times()
    test_smooth_production()
end

nothing