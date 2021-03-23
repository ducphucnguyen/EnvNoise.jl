export pwelch,
    windowproperty,
    hanning,
    hamming,
    rect


using DSP


# When x is a vector, it is treated as a single channel.
# When x is a matrix, the PSD is computed independently for each column
# and stored in the corresponding column of pxx
# This function is comparable with pwelch Matlab function for calcualting
# PSD

"""
    pwelch(x, window, noverlap, nfft,fs)

Return the power spectral density (PSD) estimate, pxx, of the input signal, x,
found using Welch's method.

### Fields:
* `x`    - a vector (single channel) or array (multi-channels).
* `window` - a window function used to divided x into segments
* `noverlap`- number of samples overlaping between segments
* `nfft` - number of fft point that is >= length of segment
* `fs`- Hz, sampling frequency
### Available Constructors:
* `pxx, f = pwelch(signal,window,noverlap,nfft,fs)`
* `pxx, f = pwelch(signal,window,noverlap,nfft,fs,"power")`
"""
function pwelch(x::AbstractVector,window,noverlap,nfft,fs)

    n = length(window)  # length of segment
    ob = welch_pgram(x, n, noverlap;
        onesided=true,  # one sided spectrum
        nfft=nfft,      # number of fft points
        fs=fs,          # sampling frequency
        window=window)  # window function

    return ob.power, ob.freq
end


# Using when x is multiple channels
function pwelch(x::AbstractArray,window,noverlap,nfft,fs)

    nrow, ncol = size(x)
    pxx = Array{Float64}(undef, floor(Int,nfft/2)+1, ncol) # assume 1 sided
    f = Array{Float64}(undef, floor(Int,nfft/2)+1,1)

        for i=1:ncol
            n = length(window)  # length of segment
            ob = welch_pgram(x[:,i], n, noverlap;
                onesided=true,  # one sided spectrum
                nfft=nfft,      # number of fft points
                fs=fs,          # sampling frequency
                window=window)  # window function
            pxx[:,i] = ob.power
            f[:,1] = ob.freq
        end

    return pxx, f

end



# Equivalent noise bandwidth, amplitude and energy correction factor
"""
    enbw(window)

    returs the two-sided equivalent noise bandwidth, amplitude correction factor
    and energy correction factor.
"""
function windowproperty(window)

    # equivalent noise bandwith
    ENBW = length(window)*sum(window .^2) / sum(window)^2

    # amplitude correction factor
    ACF = 1/( sum(window)/ length(window) )

    # energy correction factor
    ECF = ACF/sqrt(ENBW)

    return ENBW, ACF, ECF
end

# example
# windowproperty(hamming(1000))


function pwelch(x::AbstractVector,window,noverlap,nfft,fs,type::AbstractString)

    n = length(window)  # length of segment
    ob = welch_pgram(x, n, noverlap;
        onesided=true,  # one sided spectrum
        nfft=nfft,      # number of fft points
        fs=fs,          # sampling frequency
        window=window)  # window function
    if type=="power"
        ENBW = windowproperty(window)[1] # equivalent bandwith
        res = ob.freq[2] # frequency resolution
        pxx = ob.power * (ENBW*res) # estimate Power spectrum
        return pxx, ob.freq
    else
        return ob.power, ob.freq
    end

end


function pwelch(x::AbstractArray,window,noverlap,nfft,fs,type::AbstractString)

    nrow, ncol = size(x)
    pxx = Array{Float64}(undef, floor(Int,nfft/2)+1, ncol) # assume 1 sided
    f = Array{Float64}(undef, floor(Int,nfft/2)+1,1)

        for i=1:ncol
            n = length(window)  # length of segment
            ob = welch_pgram(x[:,i], n, noverlap;
                onesided=true,  # one sided spectrum
                nfft=nfft,      # number of fft points
                fs=fs,          # sampling frequency
                window=window)  # window function

            if type == "power"
                ENBW = windowproperty(window)[1] # equivalent bandwith
                res = ob.freq[2] # frequency resolution
                pxx[:,i] = ob.power * (ENBW*res) # estimate Power spectrum
            else
                pxx[:,i] = ob.power
            end

            f[:,1] = ob.freq
        end

    return pxx, f

end

# example
#=
filename = "R:\\CMPH-Windfarm Field Study\\Hallett\\set1\\Recording-3.1.pti"
signal, Fs, Date, Time = ptiread(filename)

res = 0.1
nfft = floor(Int,Fs/res)
ovlap = Int(0.5*nfft)

 pxx, f =  pwelch(signal,hanning(nfft),ovlap,nfft,Fs)
 pxx, f =  pwelch(signal,hanning(nfft),ovlap,nfft,Fs,"power")
=#
