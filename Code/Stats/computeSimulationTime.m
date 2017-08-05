function [samples,time] = computeSimulationTime(simulators,varargin)

% arg check
p = inputParser;
inputCheck();

% name inputs
precision = p.Results.precision;
samples = p.Results.NsamplesList;
fd = p.Results.fd;
T = p.Results.T;
nSin = p.Results.nSin;
interpMethod = p.Results.interpMethod;

% init (force simulators to be cell array)
if ischar(simulators)
    simulators = {simulators};
end

time = zeros( length(samples),length(simulators) );

%% computations
for j = 1:length(simulators)
    for i = 1:length(samples)
        time(i,j) = computeTimePerSample( simulators{j},precision,...
            samples(i),fd,T,nSin,interpMethod );
    end
end
    

%% Agrument checker
    function inputCheck()
        
        p.addRequired('simulators', @(x)checkValidSimList(x));
        p.addOptional('precision',.5,...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        p.addOptional('NsamplesList', round( logspace(3,7,20) )',...
            @(x)validateattributes(x,{'numeric'},{'positive','integer',...
            'nonempty','vector'}));
        
        % channel parameters
        p.addParameter('fd',10,...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addParameter('T',.01,...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive'}));
        p.addParameter('nSin',10,...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive','integer'}));
        p.addParameter('interpMethod','spline',...
            @(x)any(validatestring(x,sampMethodsList)));
        
        
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

% ---------------------------------------------------------------------
function time = computeTimePerSample( sim,precision,sample,fd,T,nSin,interpMethod )

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
    if i>3
        [isCIok,timeList(1:i),i] = checkCI( timeList(1:i),precision );
    end
end

time = mean( timeList(1:i) );

if true
    fprintf('Sim=%s, prec=%.2f, Nsamp=%9d, i=%d\n',sim,precision,sample,i);
end

end

% ----------------------------------------------------------------------
function [isCIok,newv,newi] = checkCI(v,prec)

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
isCIok = (1.96*stdev/avg) < prec;

end