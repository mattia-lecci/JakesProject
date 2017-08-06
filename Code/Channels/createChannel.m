function [ch,t] = createChannel(fd,T,duration,varargin)
%CREATECHANNEL Create a simulated wirelss Rayleigh fading channel
%
% [ch,t] = CREATECHANNEL(fd,T,duration) Creates a channel with maximum
%   doppler frequency fd, sampling period T [s] and duration in seconds using
%   the default Jakes' simulator with 10 rays
% [ch,t] = CREATECHANNEL(fd,T,duration,simulator) With the optional
%   argument simulator you can choose the type of simulator from: 'Jakes'
%   (default), 'PopBeaulieu', 'LiHuang', 'ZhengXiao2002', 'ZhengXiao2003',
%   'XiaoZhengBeaulieu', 'Clarke', 'Komninakis'
% [ch,t] = CREATECHANNEL(fd,T,duration,simulator,nSin) With the optional
%   argument nSin you can control the number of sinusoids of the simulator
%   (for all simulators excluding 'Komninakis')
% [ch,t] = CREATECHANNEL(...,Name,Value) Add Value-Name pairs as additional
%   options
%
% Value-Name pairs:
% - 'DurationType': {'time' (default), 'samples','Tcoh'}. Tcoh is the
%   coherence time defined as Tcoh=1/fd
% - 'NChannels': positive scalar integer
% - 'interpMethod': valid only for 'Komninakis' simulator. {'filter', 
%       'spline' (default), 'pchip', 'linear'}
%
% See also: POPBEAULIEUSIMULATOR, JAKESSIMULATOR, ZHENGXIAO2003SIMULATOR,
%   KOMNINAKISSIMULATOR, CLARKESIMULATOR, XIAOZHENGBEAULIEUSIMULATOR,
%   LIHUANGSIMULATOR, ZHENGXIAO2002SIMULATOR

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
t = getTimeVector(T,fd,duration,DurationType); % column

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
        interpMethodsList = {'filter','spline','pchip','linear'};
        
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
            @(x)any(validatestring(x,{'time','samples','Tcoh'})));
        p.addParameter('NChannels',1,...
            @(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'}));
        p.addParameter('interpMethod','spline',...
            @(x)any(validatestring(x,interpMethodsList)));
        
        p.parse(fd,T,duration,varargin{:})
        
        
        % futher check
        if strcmp( p.Results.DurationType, 'samples' ) % check for integer samples
            validateattributes(p.Results.duration,...
                {'numeric'},{'integer'},'createChannel','duration',3);
        end
    end
end

%% Useful functions
function t = getTimeVector(T,fd,duration,durationType)

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
    case 'Tcoh'
        Tcoh = 1/fd;
        t = (0:T:duration*Tcoh)';
end

end