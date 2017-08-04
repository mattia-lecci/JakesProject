function LCR = computeLCR(ch,duration,varargin)
%COMPUTELCR Computes the Level Crossing Rate of the given channel. A
%channel is considered to be a column. Multiple independent channels are
%supported in order to give a better estimate.
%
% LCR = COMPUTELCR(ch,duration) Computes the LCR of the
% channel ch of the given duration. Threshold are decided as 25 equally
% log-spaced values between the min and max magnitude of ch. Returns the
% structure LCR, later described.
% LCR = COMPUTELCR(ch,duration,thresholds) You can
% optionally pass a vector of real positive numbers containing the desired
% thresholds.
%
% OUTPUT: Structure LCR with fields:
% - LCR.values: the computed Level Crossing Rates
% - LCR.thresh: thresholds on which values are computed
% - LCR.stdev: standard deviation of the estimated values (more independent
%       channels are needed for this)
%
% See also: COMPUTEALLSTATS

% arg check
p = inputParser;
inputCheck();

ch = abs(ch); % we only care about fading envelope

% name inputs
thresh = p.Results.thresholds;

% decide thresholds
if isempty(thresh)
    m = min(ch(:));
    M = max(ch(:));
    thresh = logspace( log10(m),log10(M),26 );
    thresh(1) = []; % nothing goes below the min
end

%% computations
LCR = zeros( length(thresh),1 );
stdev = LCR;

for i = 1:length(thresh)
    below = ch < thresh(i);
    above = ch >= thresh(i);
    upcross = below(1:end-1,:) & above(2:end,:);
    
    % number of upcross per realization
    numcross = sum(upcross);
    LCR(i) = mean( numcross );
    stdev(i) = std( numcross );
end

% normalize to time
LCR.values = LCR/duration;
LCR.stdev = stdev/duration;
LCR.thresh = thresh;

%% Argument checker
    function inputCheck()
        
        p.addRequired('ch',...
            @(x)validateattributes(x,{'numeric'},{'nonempty','2d'}));
        p.addRequired('duration',...
            @(x)validateattributes(x,{'numeric'},{'real','positive','scalar'}));
        p.addOptional('thresholds',[],...
            @(x)validateattributes(x,{'numeric'},{'real','positive','vector'}));
        
        p.parse(ch,duration,varargin{:});
        
    end

end