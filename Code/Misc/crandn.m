function X = crandn(n,varargin)
p = inputParser;
inputCheck();

%% Input Extraction
m = p.Results.m;
meanval = p.Results.meanval;
variance = p.Results.variance;

%% RV generation
if variance==0 % avoid computation
    X = meanval*ones(n,m);
else
    std = sqrt(variance/2);
    X = meanval + std*randn(n,m) + 1j*std*randn(n,m);
end

%% Argument checking
    function inputCheck()
        p.addRequired('n');
        p.addOptional('meanval',0);
        p.addOptional('variance',1);
        p.addOptional('m',1);
        
        p.parse(n,varargin{:});
    end
end