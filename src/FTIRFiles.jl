module FTIRFiles

using CSV
using DataFrames
using Dates
using StringEncodings

export read_spectrum,
       Spectrum

struct Spectrum
    title::String
    datatype::String
    origin::String
    owner::String
    date::Date
    time::Time
    spectrometer::String
    locale::Int64
    resolution::String
    deltax::Float64
    xunits::String
    yunits::String
    firstx::Float64
    lastx::Float64
    npoints::Int64
    firsty::Float64
    maxy::Float64
    miny::Float64
    x::Vector{Float64}
    y::Vector{Float64}
end

function Spectrum(path::String)
    f = open(path, enc"SHIFT-JIS", "r")
    lines = readlines(f)
    metadata = Dict()
    for line in lines
        splitline = split(line, ",")
        if length(splitline) == 2
            # We only want metadata, but the spectrum is also a comma-separated xy pair
            try
                parse(Float64, splitline[1])
            catch
                if splitline[1] == "DATE"
                    metadata[splitline[1]] = Date(splitline[2], "yy/mm/dd") + Year(2000)
                elseif splitline[1] == "TIME"
                    metadata[splitline[1]] = Time(splitline[2], "HH:MM:SS")
                else
                    metadata[splitline[1]] = splitline[2]
                end
            end
        end
    end

    npoints = parse(Int64, metadata["NPOINTS"])
    xdata = zeros(npoints)
    ydata = zeros(npoints)
    start = findfirst(line -> line == "XYDATA", lines)

    for (i, line) in enumerate(lines[start + 1:start + npoints])
        xdata[i] = parse(Float64, split(line, ",")[1])
        ydata[i] = parse(Float64, split(line, ",")[2])
    end

    return Spectrum(metadata["TITLE"],
                    metadata["DATA TYPE"],
                    metadata["ORIGIN"],
                    metadata["OWNER"],
                    metadata["DATE"],
                    metadata["TIME"],
                    metadata["SPECTROMETER/DATA SYSTEM"],
                    parse(Int64, metadata["LOCALE"]),
                    metadata["RESOLUTION"],
                    parse(Float64, metadata["DELTAX"]),
                    metadata["XUNITS"],
                    metadata["YUNITS"],
                    parse(Float64, metadata["FIRSTX"]),
                    parse(Float64, metadata["LASTX"]),
                    parse(Int64, metadata["NPOINTS"]),
                    parse(Float64, metadata["FIRSTY"]),
                    parse(Float64, metadata["MAXY"]),
                    parse(Float64, metadata["MINY"]),
                    xdata,
                    ydata
    )
end


# function read_angleresolved(directory, format=".csv")

#     angle_data = []

#     for (root, dirs, files) in walkdir(directory)
#         for spectrum_file in files
#             if endswith(spectrum_file, format)
#                 str_start = findfirst("deg", spectrum_file)[end] + 1
#                 str_end = findlast(format, spectrum_file)[1] - 1

#                 if tryparse(Int, spectrum_file[str_start:str_end]) === nothing
#                     angle = parse(Int, spectrum_file[1:str_start-4])
#                 else
#                     angle = parse(Int, spectrum_file[str_start:str_end])
#                 end
#                 dataframe = read_spectrum(joinpath(root, spectrum_file))
#                 push!(angle_data, [angle, dataframe])
#             end
            
#         end
#     end
#     return sort(angle_data)
# end

end # module
