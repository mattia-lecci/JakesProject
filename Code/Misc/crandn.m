function X = crandn(n,varargin)
%CRANDN Creates complex random variables
%
% X = CRANDN(n) creates nx1 vector with 0 mean and unit variance
% X = CRANDN(n,m) creates nxm vector with 0 mean and unit variance
% X = CRANDN(n,m,meanval) creates nxm vector with "meanval" mean
%   and unit variance
% X = CRANDN(n,m,meanval,variance) creates nxm vector with "meanval" mean
%   and "variance" variance

% arg check
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
        p.addOptional('m',1);
        p.addOptional('meanval',0);
        p.addOptional('variance',1);
        
        p.parse(n,varargin{:});
    end
end