module ProjectIO

using CSV, DataFrames

function read_spectrum(datafile, col_names=["X", "Y"])
    #TODO: Get meta-data from the spectrum file.

    df = DataFrame(CSV.File(datafile, datarow=20, footerskip=36))
    metadata = CSV.File(datafile, limit=18)
    for row in metadata
        if row.TITLE == "XUNITS"
            if row.Column2 == "1/CM"
                col_names[1] = "Wavenumber"
            end
        end

        if row.TITLE == "YUNITS"
            col_names[2] = titlecase(row.Column2)
        end
    end
    rename!(df, col_names)
    return df
end

function read_angle_data_from_dir(directory, format=".csv")

    angle_data = []

    for spectrum_file in readdir(directory, join=true)
        if endswith(spectrum_file, format)
            str_start = findfirst("deg", spectrum_file)[end] + 1
            str_end = findlast(format, spectrum_file)[1] - 1
            angle = parse(Float64, spectrum_file[str_start:str_end])
            dataframe = read_spectrum(spectrum_file)
            push!(angle_data, [angle, [dataframe[:, 1], dataframe[:, 2]]])
        end
    end
    return sort(angle_data)
end

end # module
