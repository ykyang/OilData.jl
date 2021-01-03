using Test

using Dates
using OilData

@test true == true
@test false == false

@testset "add_day" begin
    d = Date(2021, 1, 1)
    t = Time(15, 32, 33)
    dt = DateTime(d,t)
    dt_1 = DateTime(Date(2021, 1, 2), Time(15,32,33))

    @test dt_1 == add_day(dt, 1.0)
    @test dt_1 == add_day(dt, 1)
end