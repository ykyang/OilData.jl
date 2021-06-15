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

function test_add_day()
    d = Date(2021, 1, 1)
    t = Time(15, 32, 33)
    dt = DateTime(d,t)
    dt_1 = DateTime(Date(2021, 1, 2), Time(15,32,33))

    @test dt_1 == add_day(dt, 1.0)
    @test dt_1 == add_day(dt, 1)

    @test_throws MethodError add_day(1, 1.0) 
    @test_throws MethodError add_day(1.0, 1.0) 

    #@info pwd()
end

function test_find_prt_start_date()
    #@test basename(data_dir()) == "data"
    
    path = joinpath(data_dir(), "test_start_date.PRT")
    start_datetime = find_prt_start_date(path)
     
    @test DateTime(Date(2019, 2, 1), Time(00,00,00)) == start_datetime
end

function run_read_rsm()
    path = joinpath(data_dir(), "test_read_rsm.RSM")

    nt = nothing
    open(path, "r") do io
        nt = read_rsm(io)
    end

    return nt
end

function test_read_rsm()
    nt = run_read_rsm()

    df_body = nt.body
    df_meta = nt.meta

    #       No. of columns == No. of rows
    @test size(df_body)[2] == size(df_meta)[1]

    # "WOPR" + "ADA-1762" -> column name -> value
    df = filter(["1", "3", "4"] => (c1,c3,c4) -> c1 == "WOPR" && c3 == "ADA-1762" && isempty(c4), df_meta)
    @test "WOPR_3" == df[1,1]
    @test df_body[!, "WOPR_3"][100:110] == [1.27629, 1.201, 3.50271, 2.99395, 2.52574, 2.27444, 1.9766, 1.74319, 1.58073, 1.51217, 1.45468]
    @test df_body[!, "TIME"][1:10] == [0.0, 1.0, 1.35154, 1.66463, 2.30742, 3.7002, 5.02709, 6.41903, 7.79777, 9.28154]
end


@testset "add_day" begin
    test_add_day()
end

@testset "find_prt_start_date" begin
    test_find_prt_start_date()
    test_read_rsm()
end

nothing
