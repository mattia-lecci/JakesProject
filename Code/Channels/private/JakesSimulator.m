function ch = JakesSimulator(fd,T,timeDuration,nChannels)
if nChannels>1
    warning(['Jakes Simulator does not support multiple independent channels. '...
        'The channels will be replicated using repmat']);
end

ch = zeros(1,nChannels);

end