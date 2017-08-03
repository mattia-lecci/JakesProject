function [corr,lags] = statisticalXcorr(X,Y,maxlag)

% arg check
p = inputParser;
inputCheck();
% special case
if ( isempty(X) || isempty(Y) ) 
    corr = [];
    return
end

%% init
ix = ones(maxlag+1,1);
j = 1:size(X,2);
iy = (1:maxlag+1)';

%% computation
corr = mean( X(ix,j).*Y(iy,j) ,2);
lags = iy-1;

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
        
        p.parse(X,Y);
        
    end
end