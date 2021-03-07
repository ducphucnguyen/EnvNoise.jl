export ptiread



"""
    ptiread

Read signals from *.pti files measured using B&K system.
### Fields:
* `filename`    - file name of the *.pti file.
### Available Constructors:
* `Signal, Freq, Date, Time = ptiread('recording-1.1.pti')`
"""
function ptiread(filename::AbstractString)

    # extract header lines
    header = Array{Union{Nothing, String}}(nothing, 297)
    open(filename) do io
        for i=1:297
            header[i] = readline(io)
        end
    end

    # extract general info
    RECInfoSectionSize = parse(Int64, match(r"(?<=RECInfoSectionSize=)(\d+)", header[4]).match)
    RECInfoSectionPos = parse(Int64, match(r"(?<=RECInfoSectionPos=)(\d+)", header[5]).match)
    SampleFrequency = parse(Int64, match(r"(?<=SampleFrequency=)(\d+)", header[6]).match)
    NoChannels = parse(Int8, match(r"(?<=NoChannels=)(\d+)", header[7]).match)
    OffsetStopSample = parse(Int64, match(r"(?<=OffsetStopSample=)(\d+)", header[13]).match)
    Date = header[14][6:end]
    Time = header[15][6:end]

    # extract correction for each channels
    CorrectionFactor = Array{Float64,1}(undef, NoChannels)

    for channel=1:NoChannels
        k = 15 + (channel-1)*10 + 4

        cfactor = match(r"(?<=CorrectionFactor=)(-?\ *[0-9]+\.?[0-9]*(?:[Ee]\ *-?\ *[0-9]+)?)",
            header[k])
        CorrectionFactor[channel] = parse(Float64, cfactor.match)
    end


    # Read binary data
    data = open(filename) do io
        seek(io, RECInfoSectionPos + RECInfoSectionSize + 20)
        dsize = read(io,Int16)
        cols = Int(OffsetStopSample/(dsize-4)*NoChannels)
        data = Array{Int32}(undef, (dsize, cols))

        seek(io, RECInfoSectionPos + RECInfoSectionSize + 20)
        read!(io, data)
    end


    #reshape channels
    Signal = Array{Float64}(undef, (OffsetStopSample, NoChannels))
    factor = CorrectionFactor/(2^16)

    for i=1:NoChannels
        Signal[:,i] = reshape(data[5:end,i:NoChannels:end],:,1) * factor[i]
    end

    return Signal, SampleFrequency, Date, Time

end



#filename = "R:\\CMPH-Windfarm Field Study\\Hallett\\set1\\Recording-3.8.pti"
#@time ptiread(filename)
