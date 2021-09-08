# ProjectIO.jl

ProjectIO.jl contains the data read/write functionality for 
vibrational polariton experiments using a JASCO 4600 FT-IR 
(Fourier Transform Infrared Spectrometer) for steady-state measurements
and infrared spectrometer for femtosecond pump-probe dynamics experiments.

This code will be made available upon publication in the interest
of promoting open and reproducible science. This code is not written with 
the intention of it being used outside of the associated research projects.


## Installation

To install ProjectIO.jl, use the Julia package manager:

```
julia> using Pkg
julia> Pkg.add(url="https://github.com/garrekstemo/ProjectsIO")
```

## Related Packages

- [TransferMatrix.jl](https://github.com/garrekstemo/TransferMatrix.jl):
an upcoming transfer matrix algorithm written in Julia, based on the 
[Pistachio](https://github.com/garrekstemo/pistachio) transfer matrix 
Python package, also specific to this research.

## Citation

If you use ProjectIO.jl or related projects, please cite the relevant paper
when it is published (coming).
