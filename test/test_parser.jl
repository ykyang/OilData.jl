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

function test_read_rsm()
    path = joinpath(data_dir(), "test_read_rsm.RSM")

    nt = nothing
    open(path, "r") do io
        nt = read_rsm(io)
    end

    return nt
end

@testset "add_day" begin
    test_add_day()
end

@testset "find_prt_start_date" begin
    test_find_prt_start_date()
    test_read_rsm()
end

nothing
