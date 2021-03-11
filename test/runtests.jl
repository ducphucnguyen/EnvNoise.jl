using EnvNoise
using Test, BenchmarkTools, Base.Threads

#@time @threads for i=100:200
#    filename = "R:\\CMPH-Windfarm Field Study\\Hallett\\set1\\Recording-3.$i.pti"
#    ptiread(filename)
#end

#signal = rand(8192*600)

#Aweighting = weightingFilter("A-weighting", 8192)
#@btime yA = filt(Aweighting,signal)


filename = "R:\\CMPH-Windfarm Field Study\\Hallett\\set1\\Recording-3.1.pti"
signal, Fs, Date, Time = ptiread(filename)

welch_pgram(signal[:,1], 81920, 0;
    onesided=eltype(s)<:Real,
    nfft=nextfastfft(n),
    fs=Fs,
    window=hanning)

@testset "EnvNoise.jl" begin
    # Write your tests here.
end
