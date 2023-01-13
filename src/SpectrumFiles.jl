module SpectrumFiles

using CSV
using DataFrames
using Dates
using StringEncodings
import Base.length

export Spectrum,
       read_spectrum,
       read_angleresolved

"""
    Spectrum

A struct to hold the metadata and data of a spectrum.
It is mutable because the incidence angle must be defined by the user.
"""
mutable struct Spectrum
    title::String
    datatype::String
    origin::String
    owner::String
    date::Date
    time::Time
    spectrometer::String
    detector::String
    locale::Int64
    scans::Int64
    resolution::String
    zerofilling::String
    apodization::String
    gain::String
    aperture::String
    scanspeed::String
    filter::String
    deltax::Float64
    xunits::String
    yunits::String
    firstx::Float64
    lastx::Float64
    npoints::Int64
    firsty::Float64
    maxy::Float64
    miny::Float64
    angle::Int64  # angle of incidence
    x::Vector{Float64}
    y::Vector{Float64}
end

function Spectrum(path::String; encoding = enc"SHIFT-JIS")

    f = open(path, encoding, "r")
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

    metadata["SPECTROMETER/DATA SYSTEM"] = metadata["機種名"]
    metadata["serial number"] = metadata["シリアル番号"]
    metadata["detector"] = metadata["検出器"]
    metadata["scans"] = metadata["積算回数"]
    metadata["RESOLUTION"] = metadata["分解"]
    metadata["zero filling"] = metadata["ゼロフィリング"]
    metadata["apodization"] = metadata["アポダイゼーション"]
    metadata["gain"] = metadata["ゲイン"]
    metadata["aperture"] = metadata["アパーチャー"]
    metadata["scan speed"] = metadata["スキャンスピード"]
    metadata["filter"] = metadata["フィルタ"]
    
    # Parse xy data
    npoints = parse(Int64, metadata["NPOINTS"])
    xdata = zeros(npoints)
    ydata = zeros(npoints)
    start = findfirst(line -> line == "XYDATA", lines)

    for (i, line) in enumerate(lines[start + 1:start + npoints])
        xdata[i] = parse(Float64, split(line, ",")[1])
        ydata[i] = parse(Float64, split(line, ",")[2])
    end
    
    close(f)
    return Spectrum(metadata["TITLE"],
                    metadata["DATA TYPE"],
                    metadata["ORIGIN"],
                    metadata["OWNER"],
                    metadata["DATE"],
                    metadata["TIME"],
                    metadata["SPECTROMETER/DATA SYSTEM"],
                    metadata["detector"],
                    parse(Int64, metadata["LOCALE"]),
                    parse(Int64, metadata["scans"]),
                    metadata["RESOLUTION"],
                    metadata["zero filling"],
                    metadata["apodization"],
                    metadata["gain"],
                    metadata["aperture"],
                    metadata["scan speed"],
                    metadata["filter"],
                    parse(Float64, metadata["DELTAX"]),
                    metadata["XUNITS"],
                    metadata["YUNITS"],
                    parse(Float64, metadata["FIRSTX"]),
                    parse(Float64, metadata["LASTX"]),
                    parse(Int64, metadata["NPOINTS"]),
                    parse(Float64, metadata["FIRSTY"]),
                    parse(Float64, metadata["MAXY"]),
                    parse(Float64, metadata["MINY"]),
                    0,
                    xdata,
                    ydata
    )
end

"""
    length(s::Spectrum)

Returns the number of points in the xy data of the spectrum.
"""
function length(s::Spectrum)
    return s.npoints
end

"""
    read_angleresolved(directory, format=".csv")

Reads all spectra in a directory and returns a vector of `Spectrum` structs
sorted by angle.

Files must be named according to the format "degX.csv" or "degXX.csv" where X is the angle.
"""
function read_angleresolved(directory, format=".csv")

    angle_data = Spectrum[]

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
                spectrum = Spectrum(joinpath(root, spectrum_file))
                spectrum.angle = angle
                push!(angle_data, spectrum)
            end
        end
    end
    return sort(angle_data, by = x -> x.angle)
end

end # module
