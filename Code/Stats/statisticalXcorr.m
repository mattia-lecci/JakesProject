function [corr,lags] = statisticalXcorr(X,varargin)

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