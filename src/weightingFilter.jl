
export weightingFilter

using DSP


"""

        weightingFilter(Type,fs)


Compute an A-, C- and G- weighting filter for a time series signal sampled at fs Hz

# Arguments
- `type`: string, "A-weighting", "C-weighting", "G-weighting"
- `fs`: Hz, sampling frequency

# Example:
```julia-repl
julia> weightingFilter("A-weighting", 8192)
```
---
[1]. IEC/CD 1672: Electroacoustics-Sound Level Meters, Nov. 1996.
[2]. ISO 7196

"""
function weightingFilter(opt::AbstractString,fs::Real)

        if opt == "A-weighting"

                # Definition of analog A-weighting filter according to IEC/CD 1672
                #fs = 8192
                f1 = 20.598997
                f2 = 107.65265
                f3 = 737.86223
                f4 = 12194.217
                A1000 = 1.9997


                NUM = vec([(2π*f4)^2 * 10^(A1000/20) 0 0 0 0])
                DEN = conv([1, 4π*f4, (2π*f4)^2],
                        [1, 4π*f1, (2π*f1)^2])
                DEN = conv(conv(DEN, [1, 2π*f3]),
                                [1, 2π*f2])

                Hs = PolynomialRatio(NUM, DEN)
                Hz = DSP.Filters.bilinear(Hs,fs)
                return Hz

        elseif opt == "C-weighting"

                f1 = 20.598997
                f4 = 12194.217
                C1000 = 0.0619

                NUM = vec([ (2*π*f4)^2 * 10^(C1000/20) 0 0 ])
                DEN = vec(conv([1 +4*π*f4 (2*π*f4)^2], [1 +4*π*f1 (2*π*f1)^2]) )
                Hs = PolynomialRatio(NUM, DEN)
                Hz = DSP.Filters.bilinear(Hs,fs)
                return Hz

        elseif opt == "G-weighting"

                z = [0+0im, 0+0im, 0+0im, 0+0im]

                p = [2*π*(-0.707 + 0.707*1im), 2*π*(-0.707 - 0.707*1im),
                        2*π*(-19.27 + 5.16*1im), 2*π*(-19.27 - 5.16*1im),
                    2π*(-14.11 + 14.11*1im), 2*π*(-14.11 - 14.11*1im),
                     2π*(-5.16 + 19.27*1im), 2π*(-5.16 - 19.27*1im)]

                k = 9.825e8

                Hx = ZeroPoleGain(z, p, k)
                Hz = DSP.Filters.bilinear(Hx,fs)
                return  Hz

        end

end

# Example

#signal = rand(8192*600)

#Aweighting = weightingFilter("A-weighting", 8192)
#@btime yA = filt(Aweighting,signal)

#Cweighting = weightingFilter("C-weighting", 8192)
#@btime yC = filt(Cweighting,signal)


#Gweighting = weightingFilter("G-weighting", 8192)
#@btime yG = filt(Gweighting,signal)

#x = rand(100_000000)
#@time yA = f_Aweighting(x,8192)

#@btime yA = f_Aweighting(x,8192)



#z = vec([0 0 0 0])
#p = vec([-2*pi*f1 -2*pi*f1 -2*pi*f4 -2*pi*f4 -2*pi*f2 -2*pi*f3])
#k = (2*pi*f4)^2*(10^(A1000/20))


#f_object = ZeroPoleGain(Z, P, K)

#x = rand(100000)

#d_object = DSP.Filters.bilinear(f_object,24000)
#filt(d_object,x)
#freqz(d_object, f, fs)


#f = range(1000, stop=2000, length=10000)
#plot(f, 20*log10.(abs.(freqz(Hz,f,8192))))
