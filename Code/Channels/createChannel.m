function [ch,t] = createChannel(fd,T,duration,varargin)
% arg check
p = inputParser;
inputCheck();

%% Extracting inputs
simulator = p.Results.simulator;
nSin = p.Results.nSin;
DurationType = p.Results.DurationType;
NChannels = p.Results.NChannels;

%% Creating channel
[sampleDuration,timeDuration] = getDuration(T,duration,DurationType);
t = (0:T:timeDuration)'; % time vector (column)

switch simulator
    case 'Jakes'
        ch = JakesSimulator(fd,t,nSin,NChannels);
    case 'PopBeaulieu'
        ch = PopBeaulieuSimulator(fd,t,nSin,NChannels);
    otherwise
        ch = 0;
end

%% Argument checker
    function inputCheck()

        simulatorsList = {'Jakes','PopBeaulieu'};

        p.addRequired('fd',...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addRequired('T',...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addRequired('duration',...
            @(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
        p.addOptional('simulator','Jakes',...
            @(x)any(validatestring(x,simulatorsList)))
        p.addOptional('nSin',10,...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive','integer'}));
        p.addParameter('DurationType','time',...
            @(x)any(validatestring(x,{'time','samples'})));
        p.addParameter('NChannels',1,...
            @(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'}));

        p.parse(fd,T,duration,varargin{:})
    end
end

%% Useful functions
function [sampleDuration,timeDuration] = getDuration(T,duration,durationType)

switch durationType
    case 'time'
        timeDuration = duration;
        sampleDuration = floor(duration/T)+1;
    case 'samples'
        sampleDuration = duration;
        timeDuration = T*duration;
end

end