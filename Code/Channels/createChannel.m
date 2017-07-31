function ch = createChannel(fd,T,duration,varargin)
% arg check
p = inputParser;
inputCheck();

% creating channel
ch = 0;
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
            @(x)validateattributes(x,'numeric',{'scalar','integer','positive'}));

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