function [LCR,thresh] = computeLCR(ch,t,varargin)

% arg check
p = inputParser;
inputCheck();

ch = abs(ch); % we only care about fading envelope

% name inputs
thresh = p.Results.thresholds;

% decide therholds
if isempty(thresh)
    m = min(ch(:));
    M = max(ch(:));
    thresh = logspace( log10(m),log10(M),26 );
    thresh(1) = []; % nothing goes below the min
end

%% computations
LCR = zeros( length(thresh),1 );

for i = 1:length(thresh)
    below = ch < thresh(i);
    above = ch >= thresh(i);
    upcross = below(1:end-1,:) & above(2:end,:);
    LCR(i) = mean( sum(upcross) );
end

span = t(end) - t(1);
LCR = LCR/span;

%% Argument checker
    function inputCheck()
        
        p.addRequired('ch',...
            @(x)validateattributes(x,{'numeric'},{'2d'}));
        p.addRequired('t',...
            @(x)validateattributes(x,{'numeric'},{'real','vector',...
            'numel',size(ch,1)}));
        p.addOptional('thresholds',[],...
            @(x)validateattributes(x,{'numeric'},{'real','vector'}));
        
        p.parse(ch,t,varargin{:});
        
    end

end