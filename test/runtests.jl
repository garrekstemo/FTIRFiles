using ProjectIO
using Test


data_dir = joinpath(dirname(dirname(pathof(ProjectIO))), "test/data")
test_spectrum = data_dir * "/liquid_crystal_in_etalon.csv"

@testset "read JASCO FTIR csv file" begin
    df = ProjectIO.read_spectrum(test_spectrum)
    @test df[:, 1][1] == 999.9101
    @test round(df[:, 1][end], sigdigits=8) == 6000.4248
    @test round(df[:, 2][1], sigdigits=3) ≈ 0.00673
    @test size(df) == (10373, 2)
    @test names(df)[1] == "Wavenumber"
    @test names(df)[2] == "Transmittance"
end
