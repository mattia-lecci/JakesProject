function ch = createChannel(fd,T,duration,varargin)
% arg check
p = inputParser;
inputCheck();

%% Extracting inputs
simulator = p.Results.simulator;
DurationType = p.Results.DurationType;
NChannels = p.Results.NChannels;

%% Creating channel
[sampleDuration,timeDuration] = getDuration(T,duration,DurationType);

switch simulator
    case 'Jakes'
        ch = JakesSimulator(fd,T,timeDuration,NChannels);
    otherwise
        ch = 0;
end

%% Argument checker
    function inputCheck()

        simulatorsList = {'Jakes'};

        p.addRequired('fd',...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addRequired('T',...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addRequired('duration',...
            @(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
        p.addOptional('simulator','Jakes',...
            @(x)any(validatestring(x,simulatorsList)))
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
        sampleDuration = floor(duration/T);
    case 'samples'
        sampleDuration = duration;
        timeDuration = T*duration;
end

end