module FTIRFiles

using CSV
using DataFrames
using Dates
using StringEncodings

export read_spectrum,
       Spectrum

"""
    read_spectrum(file, names = ["X", "Y"])
"""
function read_spectrum(file, names = ["X", "Y"])
    #TODO: Get meta-data from the spectrum file.
    datarows = 0

    metadata = CSV.File(file, limit=18)
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
        df = DataFrame(CSV.File(file, skipto=20, limit=datarows))
    else
        df = DataFrame(CSV.File(file, skipto=20, footerskip=17)) 
    end

    rename!(df, names)
    return df
end

struct Spectrum
    title::String
    datatype::String
    origin::String
    owner::String
    date::Date
    time::Time
    locale::Int64
    deltax::Float64
    xunits::String
    yunits::String

    # the inner constructor should not be used directly
    function Spectrum(path)
        f = open(path, enc"SHIFT-JIS", "r")
        lines = readlines(f)
        for line in lines
            l = split(line, ",")
            if length(l)
                if l[1] == "TITLE"
                    title = l[2]
                elseif l[1] == "DATATYPE"
                    datatype = l[2]
                elseif l[1] == "ORIGIN"
                    origin = l[2]
                elseif l[1] == "OWNER"
                    owner = l[2]
                elseif l[1] == "DATE"
                    date = Date(l[2], "yy/mm/dd") + Dates.Year(2000)
                elseif l[1] == "TIME"
                    time = Time(l[2], "HH:MM:SS")
                elseif l[1] == "LOCALE"
                    locale = parse(Int, l[2])
                elseif l[1] == "DELTAX"
                    deltax = parse(Float64, l[2])
                elseif l[1] == "XUNITS"
                    xunits = l[2]
                elseif l[1] == "YUNITS"
                    yunits = l[2]
                end
            end
        end
        close(f)
    end
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
