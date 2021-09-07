using Test
using ProjectIO
using DataFrames


data_dir = joinpath(dirname(dirname(pathof(ProjectIO))), "test/data")
spectrum_file = data_dir * "/liquid_crystal_in_etalon.csv"
angles_dir = data_dir * "/angle_resolved"

println(pwd())

@testset "read JASCO FTIR csv file" begin
    df = ProjectIO.read_spectrum(spectrum_file)
    @test df[:, 1][1] == 999.9101
    @test round(df[:, 1][end], sigdigits=8) == 6000.4248
    @test round(df[:, 2][1], sigdigits=3) ≈ 0.00673
    @test size(df) == (10373, 2)
    @test names(df)[1] == "Wavenumber"
    @test names(df)[2] == "Transmittance"
end


@testset "read angle-resolved data" begin
    datalist = ProjectIO.read_angle_data_from_dir(angles_dir)
    @test length(datalist) == 6
    @test [typeof(i[1]) == Int for i in datalist] == ones(length(datalist))
    @test typeof(datalist[1][2]) == DataFrame
    for d in datalist
        @test length(d) == 2
    end
end
