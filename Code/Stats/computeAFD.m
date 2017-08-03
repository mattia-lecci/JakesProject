function [AFD,thresh,stdev] = computeAFD(ch,t,varargin)

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
T = t(2) - t(1);
AFD = AFD*T;
stdev = stdev*T;

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
        c(ci) = 1;
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