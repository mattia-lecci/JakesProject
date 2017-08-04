function AFD = computeAFD(ch,T,varargin)
%COMPUTEAFD Computes Average Fading Duration for the given channel, i.e.
%the average time the channel stays below a certain threshold. A
%channel is considered to be a column. Multiple independent channels are
%supported in order to give a better estimate.
%
% AFD = COMPUTEAFD(ch,T) Computes AFD on channel ch considering T as the 
% sampling period. Threshold are decided as 25 equally log-spaced values 
% between the min and max magnitude of ch. Returns the structure AFD, later 
% described.
% AFD = COMPUTEAFD(ch,T,thresholds) You can optionally pass a vector of 
% real positive numbers containing the desired thresholds.
%
% OUTPUT: Structure AFD with fields:
% - AFD.values: the computed Average Fade Duration
% - AFD.thresh: thresholds on which values are computed
% - AFD.stdev: standard deviation of the estimated values (more independent
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
AFD = zeros( length(thresh),1 );
stdev = AFD;

for i = 1:length(thresh)
    % cell array containing column vectors with list of consecutive ones
    % for each realization
    consec = countConsecutiveOnes( ch < thresh(i) );
    % perform mean for each vector => mean FD for each realization
    realizationMean = cellfun(@mean,consec);
    % mean of the means of the realizations (as number of samples)
    AFD(i) = mean(realizationMean);
    % stdev of the means of the realizations
    stdev(i) = std(realizationMean);
end

% normalize to time
AFD.values = AFD*T;
AFD.stdev = stdev*T;
AFD.thresh = thresh;

%% Argument checker
    function inputCheck()
        
        p.addRequired('ch',...
            @(x)validateattributes(x,{'numeric'},{'nonempty','2d'}));
        p.addRequired('T',...
            @(x)validateattributes(x,{'numeric'},{'real','positive','scalar'}));
        p.addOptional('thresholds',[],...
            @(x)validateattributes(x,{'numeric'},{'real','vector'}));
        
        p.parse(ch,T,varargin{:});
        
    end

end

%% Utility functions
function n = countConsecutiveOnes(A)

n = cell(1, size(A,2) );

% for each column
for i = 1:size(A,2)
    n{i} = count(A(:,i));
end

end

function c = count(v)
% init
maxind = length(v);
vi = 1;
ci = 1;
c = 0;

% cycle through the vector
while vi<=maxind
    if v(vi)==true %fade starts
        c(ci) = 1; %#ok<AGROW>
        vi = vi+1;
        while ( vi<=maxind && v(vi)==true ) % lazy evaluation
            c(ci) = c(ci)+1; % count
            vi = vi+1; % next sample
        end
        ci = ci+1;
    end
    vi = vi+1;
end

end