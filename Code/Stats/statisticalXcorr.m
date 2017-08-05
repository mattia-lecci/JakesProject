function [corr,lags] = statisticalXcorr(X,varargin)
%STATISTICALXCORR Computes the cross/auto correlation in the statistical
%meaning, i.e. R(n,m)=E[X(n)Y*(n-m)]=E[X(n+m)Y*(n)].
%Inputs are supposed to be WSS and n=1 (Matlab starts from 1). The second
%formula is used.
%Every column is considered to be a realization of a stochastic process and
%the expectation is estimated as a mean of the realizations.
%Lags are considered as number of samples.
%
% [corr,lags] = STATISTICALXCORR(X) Computes the statistical autocorrelation
%   of X. Only positive lags are computed and the maximum lag is the highest
%   available, i.e. the length of each realization minus 1. lag refers to the
%   number of samples, not time.
% [corr,lags] = STATISTICALXCORR(X,Y) Computes the statistical cross
%   correlation between X and Y. The dimension of Y must be the same as X
%   (meaning number of rows, columns and elements). Only positive lags are
%   computed
% [corr,lags] = STATISTICALXCORR(X,Y,maxlag) You can decide to compute only
%   the lags needed. maxlag must be smaller than the first dimension of X or
%   Y.
%
% See also: COMPUTEXCORR

% arg check
p = inputParser;
inputCheck();

% name inputs
Y = p.Results.Y;
maxlag = p.Results.maxlag;

%% init
ix = (1:maxlag+1)'; % n+m, m=0,...,maxlag
iy = ones(maxlag+1,1); % fixed n=1

%% computation
corr = mean( X(ix,:).*conj( Y(iy,:) ) ,2);
lags = ix-1;

%% Argument checker
    function inputCheck()
        
        p.addRequired('X',...
            @(x)validateattributes(x,{'numeric'},{'2d'}));
        p.addOptional('Y',X,...
            @(x)validateattributes(x,{'numeric'},{'2d',...
            'ncols',size(X,2),'nrows',size(X,1),'numel',numel(X)})); % same dimension as X
        p.addOptional('maxlag',size(X,1)-1,...
            @(x)validateattributes(x,{'numeric'},{'nonnegative','integer',...
            'scalar','<',size(X,1)}));
        
        p.parse(X,varargin{:});
        
    end
end