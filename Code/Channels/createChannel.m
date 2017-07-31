function ch = createChannel(fd,T,duration,varargin)
% arg check
p = inputParser;
inputCheck();

% creating channel
ch = 0;
%% Argument checker
    function inputCheck()

        simulatorsList = {'Jakes'};

        p.addRequired('fd',@(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addRequired('T',@(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addRequired('duration',@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
        p.addOptional('simulator','Jakes',@(x)any(validatestring(x,simulatorsList)))
        p.addParameter('DurationType','time_s',@(x)any(validatestring(x,{'time_s','samples'})));

        p.parse(fd,T,duration,varargin{:})
    end
end