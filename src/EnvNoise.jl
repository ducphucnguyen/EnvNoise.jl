module EnvNoise

using DSP
# Write your package code here.
include("ptiread.jl")
include("weightingFilter.jl")

export filt, welch_pgram

end
