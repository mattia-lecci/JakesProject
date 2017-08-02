function [ch,t] = createChannel(fd,T,duration,varargin)
% arg check
p = inputParser;
inputCheck();

%% Extracting inputs
simulator = p.Results.simulator;
nSin = p.Results.nSin;
DurationType = p.Results.DurationType;
NChannels = p.Results.NChannels;
interpMethod = p.Results.interpMethod;

%% Creating channel
t = getTimeVector(T,duration,DurationType); % column

switch simulator
    case 'Jakes'
        ch = JakesSimulator(fd,t,nSin,NChannels);
    case 'PopBeaulieu'
        ch = PopBeaulieuSimulator(fd,t,nSin,NChannels);
    case 'LiHuang'
        ch = LiHuangSimulator(fd,t,nSin,NChannels);
    case 'ZhengXiao2002'
        ch = ZhengXiao2002Simulator(fd,t,nSin,NChannels);
    case 'ZhengXiao2003'
        ch = ZhengXiao2003Simulator(fd,t,nSin,NChannels);
    case 'XiaoZhengBeaulieu'
        ch = XiaoZhengBeaulieuSimulator(fd,t,nSin,NChannels);
    case 'Clarke'
        ch = ClarkeSimulator(fd,t,nSin,NChannels);
    case 'Komninakis'
        addpath('../Misc');
        ch = KomninakisSimulator(fd,t,NChannels,interpMethod);
    otherwise
        error('Simulator "%s" not recognized',simulator);
end

%% Argument checker
    function inputCheck()
        
        simulatorsList = {'Jakes','PopBeaulieu','LiHuang',...
            'ZhengXiao2002','ZhengXiao2003','XiaoZhengBeaulieu',...
            'Clarke','Komninakis'};
        sampMethodsList = {'filter','spline','pchip','linear'};
        
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
        p.addParameter('interpMethod','spline',...
            @(x)any(validatestring(x,sampMethodsList)));
        
        p.parse(fd,T,duration,varargin{:})
        
        
        % futher check
        if strcmp( p.Results.DurationType, 'samples' ) % check for integer samples
            validateattributes(p.Results.duration,{'numeric'},{'integer'},'createChannel','duration',3);
        end
    end
end

%% Useful functions
function t = getTimeVector(T,duration,durationType)

% limit case
if duration==0
    t = [];
    return
end
% otherwise
switch durationType
    case 'time'
        t = (0:T:duration)';
    case 'samples'
        timeDuration = T*(duration-1);
        t = (0:T:timeDuration)';
end

end