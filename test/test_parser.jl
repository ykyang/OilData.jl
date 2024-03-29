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

if !@isdefined local_6cfddc95df03456583406d57fd5963ac
    local_6cfddc95df03456583406d57fd5963ac = true
end
if local_6cfddc95df03456583406d57fd5963ac
    include("common.jl")
end


function test_add_day()
    dt_0 = DateTime(Date(2021, 1, 1), Time(15, 32, 33))
    dt_1 = DateTime(Date(2021, 1, 2), Time(15, 32, 33))

    @test dt_1 == add_day(dt_0, 1.0)
    @test dt_1 == add_day(dt_0, 1)

    @test_throws MethodError add_day(1, 1.0) 
    @test_throws MethodError add_day(1.0, 1.0) 

    # Test broadcast (Vector{DateTime}, Float64)
    dts_0 = [dt_0, dt_1]
    dts_1 = [
        DateTime(Date(2021, 1, 2), Time(15, 32, 33)), 
        DateTime(Date(2021, 1, 3), Time(15, 32, 33))
    ]
    @test add_day.(dts_0, 1) == dts_1

    # Test broadcast (Vector{DateTime}, Vector{Float64})
    dts_0 = [dt_0, dt_0]
    durations = [1, 2]
    dts_1 = [
        DateTime(Date(2021, 1, 2), Time(15, 32, 33)), 
        DateTime(Date(2021, 1, 3), Time(15, 32, 33))
    ]
    @test add_day.(dts_0, durations) == dts_1

    # Test broadcast (DateTime, Vector{Float64})
    dt_0 = DateTime(Date(2021, 1, 1), Time(15, 32, 33))
    durations = [1, 2]
    dts_1 = [
        DateTime(Date(2021, 1, 2), Time(15, 32, 33)), 
        DateTime(Date(2021, 1, 3), Time(15, 32, 33))
    ]
    @test add_day.(dt_0, durations) == dts_1
end

function test_find_prt_start_date()
    if isnothing(data_dir())
        return
    end
    
    path = joinpath(data_dir(), "test_start_date.PRT")
    start_datetime = find_prt_start_date(path)
     
    @test DateTime(2020, 1, 18) == start_datetime
end

function test_find_schedule_end_date()
    if isnothing(data_dir())
        return
    end
    path = joinpath(data_dir(), "test_schedule.ixf")
    end_datetime = find_schedule_end_date(path)
    @test DateTime(2021,2,4) == end_datetime
end

function run_read_rsm()
    path = joinpath(data_dir(), "test_read_rsm.RSM")
    return read_rsm(path)
end

function test_read_rsm()
    if isnothing(data_dir())
        return
    end
    
    nt = run_read_rsm()

    df_body = nt.body
    df_meta = nt.meta

    # Notice the body's column count == meta's row count
    @test size(df_body)              == (1250, 466)
    @test size(df_meta)              == (466, 5)
    @test df_meta[191:200, "column"] == ["WWCT", "WWCT_1", "WWCT_2", "WWCT_3", "WWCTH", "WWCTH_1", "WWCTH_2", "WWCTH_3", "WOPR", "WOPR_3"]
    @test df_meta[191:200, "3"]      == ["ADA-1761","ADA-1762","ADA-1763","ADA-1764","ADA-1761","ADA-1762","ADA-1763","ADA-1764","ADA-1761","ADA-1762"]
    @test df_body[1:10, "TIME"]      == [0.0, 1.0, 1.35154, 1.66463, 2.30742, 3.7002, 5.02709, 6.41903, 7.79777, 9.28154]

    #
    # This is how to get a column of data
    #
    # 1. Look up column name from meta table
    @test "WOPR_3" == find_column_name(df_meta, "WOPR", "ADA-1762", "")
    # 2. Get value from body table
    @test df_body[100:110, "WOPR_3"] == [1.27629, 1.201, 3.50271, 2.99395, 2.52574, 2.27444, 1.9766, 1.74319, 1.58073, 1.51217, 1.45468]

    # Test data type
    colname = find_column_name(df_meta, "WOPR", "ADA-1762", "")
    @test "WOPR_3" == colname
    @test df_body[!,"TIME"]   isa Vector{Float64}
    @test df_body[!, colname] isa Vector{Float64}
end

# Use this to find function name
# name = StackTraces.stacktrace()[1].func

@testset "parser/base" begin
    test_add_day()
    test_find_prt_start_date()
    test_find_schedule_end_date()
end

@testset "parser/read_rsm" begin
    test_read_rsm()
end

nothing
