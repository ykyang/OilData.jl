# Deprecated
# use various test_*.jl files
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


od = OilData


logger = SimpleLogger(stdout, Logging.Info)
global_logger(logger)

@test true == true
@test false == false

@testset "add_day" begin
    d = Date(2021, 1, 1)
    t = Time(15, 32, 33)
    dt = DateTime(d,t)
    dt_1 = DateTime(Date(2021, 1, 2), Time(15,32,33))

    @test dt_1 == add_day(dt, 1.0)
    @test dt_1 == add_day(dt, 1)

    @test_throws MethodError add_day(1, 1.0) 
    @test_throws MethodError add_day(1.0, 1.0) 

    @info pwd()
end

@testset "find_prt_start_date" begin
   @test basename(data_dir()) == "data"
   path = joinpath(data_dir(), "Project-2.PRT")
   start_datetime = od.find_prt_start_date(path)
   #@info start_datetime
   expected = DateTime(Date(2019, 2, 1), Time(00,00,00))
   @test start_datetime == expected
end