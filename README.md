# SpectrumFiles.jl

SpectrumFiles.jl reads text files from a JASCO 4600 FT-IR 
(Fourier Transform Infrared Spectrometer). It does not read the .jws files.
Instead the user must export raw data to a .csv or other text file format.
SpectrumFiles.jl parses the file and stores metadata and xy data in a Julia type called `Spectrum`.

## Installation

To install SpectrumFiles.jl, use the Julia package manager:

```
julia> using Pkg
julia> Pkg.add(url="https://github.com/garrekstemo/SpectrumFiles.jl")
```

## Usage

``
Spectrum(filepath; encoding = enc"SHIFT-JIS")
``
