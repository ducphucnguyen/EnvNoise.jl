using EnvNoise
using Test, BenchmarkTools, Base.Threads

#@time @threads for i=100:200
#    filename = "R:\\CMPH-Windfarm Field Study\\Hallett\\set1\\Recording-3.$i.pti"
#    ptiread(filename)
#end

signal = rand(8192*600)

Aweighting = weightingFilter("A-weighting", 8192)
@btime yA = filt(Aweighting,signal)

@testset "EnvNoise.jl" begin
    # Write your tests here.
end
