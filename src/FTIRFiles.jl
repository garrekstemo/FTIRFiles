module FTIRFiles

using CSV
using DataFrames

export read_spectrum

"""
    read_spectrum(file, names = ["X", "Y"])
"""
function read_spectrum(file, names = ["X", "Y"])
    #TODO: Get meta-data from the spectrum file.
    datarows = 0

    metadata = CSV.File(datafile, limit=18)
    for row in metadata
        if row.TITLE == "XUNITS"
            if row.Column2 == "1/CM"
                names[1] = "Wavenumber"
            end
        end

        if row.TITLE == "YUNITS"
            names[2] = titlecase(row.Column2)
        end

        if row.TITLE == "NPOINTS"
            datarows = parse(Int, row.Column2)
        end
    end

    if datarows > 0
        df = DataFrame(CSV.File(datafile, skipto=20, limit=datarows))
    else
        df = DataFrame(CSV.File(datafile, skipto=20, footerskip=17)) 
    end

    rename!(df, names)
    return df
end


function read_angleresolved(directory, format=".csv")

    angle_data = []

    for (root, dirs, files) in walkdir(directory)
        for spectrum_file in files
            if endswith(spectrum_file, format)
                str_start = findfirst("deg", spectrum_file)[end] + 1
                str_end = findlast(format, spectrum_file)[1] - 1

                if tryparse(Int, spectrum_file[str_start:str_end]) === nothing
                    angle = parse(Int, spectrum_file[1:str_start-4])
                else
                    angle = parse(Int, spectrum_file[str_start:str_end])
                end
                dataframe = read_spectrum(joinpath(root, spectrum_file))
                push!(angle_data, [angle, dataframe])
            end
            
        end
    end
    return sort(angle_data)
end

end # module
