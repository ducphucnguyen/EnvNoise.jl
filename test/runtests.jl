using EnvNoise
using Test, BenchmarkTools, Base.Threads, DelimitedFiles
using JLD

#@time @threads for i=100:200
#    filename = "R:\\CMPH-Windfarm Field Study\\Hallett\\set1\\Recording-3.$i.pti"
#    ptiread(filename)
#end

#signal = rand(8192*600)

#Aweighting = weightingFilter("A-weighting", 8192)
#@btime yA = filt(Aweighting,signal)

dir = "R:\\CMPH-Windfarm Field Study\\Hallett\\set1\\"
allpti = filter(x->endswith(x, ".pti"), readdir(dir; join=true))

#filename = "R:\\CMPH-Windfarm Field Study\\Hallett\\set1\\Recording-3.1.pti"
@time for i=1:100
    filename = allpti[i]
    signal, Fs, Date, Time = ptiread(filename)

    res = 0.1
    nfft = floor(Int,Fs/res)
    ovlap = floor(Int, 0.5*nfft)
    pxx = pwelch(signal, hanning(nfft),ovlap,nfft,Fs)[1]
    pxx = Float32.(pxx) # using Float32 precision

    # save results
    set_i = filename[38:41]
    name_i = filename[43:end-4]
    savedir = "R:\\CMPH-Windfarm Field Study\\Duc Phuc Nguyen\\3. Spectrum quantification\\Hallett_spectrum"
    save("$savedir\\$set_i-$name_i.jld", "pxx", pxx, "date", Date,"time",Time) # save spectrum
    #save("$savedir\\info-$set_i-$name_i.jld", "date", Date,"time",Time) # save DateTime
end

#pxx2 = load("pxx2.jld")
#writedlm("pxx.txt", pxx)

#=
@time open("pxx.txt", "w") do file
    write(file, pxx)
end
=#



@testset "EnvNoise.jl" begin
    # Write your tests here.
end
