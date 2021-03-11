


using DSP




s = rand(8192*600)


@time welch_pgram(s, 81920, 0;
    onesided=eltype(s)<:Real,
    nfft=nextfastfft(n),
    fs=8192,
    window=hanning) # equivalent to 'psd' in Matlab


function pwelch(x,window,noverlap,nfft,fs,type)

    welch_pgram(x, n, noverlap;
        onesided=eltype(s)<:Real,
        nfft=nextfastfft(n),
        fs=fs,
        window=window)
end
