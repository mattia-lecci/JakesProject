function [time,samples] = computeSimulationTime(simulators,varargin)
%COMPUTESIMULATIONTIME Computes how much simulations take to produce their
%output as a function of the number of samples to produce
%
% [samples,time] = COMPUTESIMULATIONTIME(simulators) Computes the
%   simulation time for the given list of simulators (either a cell array
%   with the names of the simulators to be tested or a single char array, 
%   as in createChannel). Returns a vector with the number of samples
%   tested and the time it took for every simulator (simulators on
%   different columns).
% [samples,time] = COMPUTESIMULATIONTIME(simulators,precision) The
%   simulation is stopped whenever the 95% confidence interval falls below
%   the given precision, with at leat 10 runs, and then averaged. Here you
%   can specify a precision of you choice. Default: 0.05.
% [samples,time] = COMPUTESIMULATIONTIME(simulators,precision,NsamplesList)
%   You can specifify the list of required number of samples to test.
%   Default: round( logspace(3,7,20) )'
% [samples,time] = computeSimulationTime(...,Name,Value) Additional
%   Name-Value pairs can be spacified.
%
% Name-Value pairs:
% - fd: doppler spread to be used in createChannel. Default: 10 [Hz]
% - T: sampling period. Default: 0.01 [s]
% - NSin: number of sinusoids to be used. Default: 10
% - InterpMethod: interpolation method to be used for Komninakis simulator.
%       Default: 'spline'. See createChannel for more infomation.
% - PrecisionType: {'%' (default), 'ms}
%
% See also: CREATECHANNEL

% arg check
p = inputParser;
inputCheck();

% name inputs
precision = p.Results.precision;
samples = p.Results.NsamplesList;
fd = p.Results.fd;
T = p.Results.T;
nSin = p.Results.NSin;
interpMethod = p.Results.InterpMethod;
precisionType = p.Results.PrecisionType;

% init (force simulators to be cell array)
if ischar(simulators)
    simulators = {simulators};
end

time = zeros( length(samples),length(simulators) );
checkChannelsAdded();

%% computations
for j = 1:length(simulators)
    for i = 1:length(samples)
        time(i,j) = computeTimePerSample( simulators{j},precision,...
            samples(i),precisionType,fd,T,nSin,interpMethod );
    end
end
    

%% Agrument checker
    function inputCheck()
        
        interpMethodsList = {'filter','spline','pchip','linear'};
        precisionTypeList = {'%','ms'};
        
        p.addRequired('simulators', @(x)checkValidSimList(x));
        p.addOptional('precision',.05,...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        p.addOptional('NsamplesList', round( logspace(3,7,20) )',...
            @(x)validateattributes(x,{'numeric'},{'positive','integer',...
            'nonempty','vector'}));
        
        % channel parameters
        p.addParameter('fd',10,...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addParameter('T',.01,...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addParameter('NSin',10,...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive','integer'}));
        p.addParameter('InterpMethod','spline',...
            @(x)any(validatestring(x,interpMethodsList)));
        p.addParameter('PrecisionType','%',...
            @(x)any(validatestring(x,precisionTypeList)));
        
        
        p.parse(simulators,varargin{:});
        
    end
end

%% Utility functions
function b = checkValidSimList(list)

% init
valid = {'Jakes','PopBeaulieu','LiHuang', 'ZhengXiao2002','ZhengXiao2003',...
    'XiaoZhengBeaulieu','Clarke','Komninakis'};
b = true;

% check if char array or cell
validateattributes(list,{'char','cell'},{'nonempty'});

if ~iscell(list)
    b = any(validatestring(list,valid));
else
    for i = 1:length(list)
        b = b & any(validatestring(list{i},valid));
    end
end

end
%----------------------------------------------------------------------
function checkChannelsAdded()

pathCell = regexp(path, pathsep, 'split');
if ispc  % Windows is not case-sensitive
  onPath = any(contains(pathCell,'JakesProject\Code\Channels'));
else
  onPath = any(contains(pathCell,'JakesProject/Code/Channels'));
end

if ~onPath
    error('"JakesProject/Code/Channels" has to be added to the path')
end

end
% ---------------------------------------------------------------------
function time = computeTimePerSample( sim,precision,sample,...
    precisionType,fd,T,nSin,interpMethod )

% init
timeList = zeros(1000,1);
i = 0;
isCIok = false;

% first one is slower
createChannel(fd,T,sample,sim,nSin,'DurationType','samples',...
        'interpMethod',interpMethod);

% compute
while ~isCIok
    % check current list dimension
    i = i+1;
    
    if i>length(timeList) % double dimension
        timeList = [timeList; zeros(size(timeList))]; %#ok<AGROW>
    end
    
    % compute channel and measure time
    tic
    createChannel(fd,T,sample,sim,nSin,'DurationType','samples',...
        'interpMethod',interpMethod);
    timeList(i) = toc;
    
    % check Confidence Interval
    if mod(i,10)==0
        [isCIok,timeList(1:i),i] = checkCI( timeList(1:i),precision,precisionType );
    end
    if i>1e3 % to avoid long waits
        isCIok = true;
    end
end

time = mean( timeList(1:i) );


%% debug
if true
    fprintf('Sim=%s, interpMethod=%s, fdT=%.4f; prec=%.2f, Nsamp=%9d, i=%3d, time=%6.3f\n',...
        sim,interpMethod,fd*T,precision,sample,i,time);
end

end

% ----------------------------------------------------------------------
function [isCIok,newv,newi] = checkCI(v,prec,precisionType)

% init
done = false;
newv = v;

% eliminate outliers
while ~done
    avg = mean(v);
    stdev = std(v);
    
    keep = newv < (avg+1.96*stdev);
    newv = newv( keep );
    
    done = all(keep);
end

% new
newi = length(newv);
newv = [newv; zeros(length(v)-newi,1)];

% 95% CI below desired precision
% done==true => avg and stdev are still valid
switch precisionType
    case '%'
        isCIok = (1.96*stdev/avg) < prec;
    case 'ms'
        isCIok = (1.96*stdev) < prec*1e-3;
end

end