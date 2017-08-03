function pdf = computePdf(ch,ind)
%COMPUTEPDF Computes pdfs of the given channel using as realizations the
%columns of ch (which should be independent channels)
% pdf = COMPUTEPDF(ch,ind) Computes pdf for channel ch on samples indexes
% given by ind (either scalar or vector). Returns a structure of the same
% length of ind with fields:
% - magnitude.fit: containing a RayleighDistribution object fitted, from
% which you can extract mean, variance, std, parameter (b) confidence
% interval, plot pdf, cdf,...
% - magnitude.normBinCount: vector of histogram bin count normalized as pdf
% - magnitude.edges: vector of histogram edges
% - phse.normBinCount: vector of histogram bin count normalized as pdf
% - phse.edges: vector of histogram edges
%
%
% normBinCount and edges can be visualized with the following command:
% histogram('BinEdges',edges,'BinCounts',normBinCount)

% arg check
p = inputParser;
inputCheck();

%% fit pdf
N = length(ind);
for i = N:-1:1 % to avoid preallocation
    % magnitude
    pdf(i).magnitude.fit = fitdist( abs(ch(ind(i),:)).', 'Rayleigh' );
    [pdf(i).magnitude.normBinCount,pdf(i).magnitude.edges] =...
        histcounts( abs(ch(ind(i),:)), 'Normalization','pdf','BinMethod','sqrt');
    
    % phase
    [pdf(i).phase.normBinCount,pdf(i).phase.edges] =...
        histcounts( angle(ch(ind(i),:)), 'Normalization','pdf',...
        'BinLimits',[-pi,pi],'BinMethod','sqrt');
end

%% Argument checker
    function inputCheck()
        
        p.addRequired('ch',...
            @(x)validateattributes(x,{'numeric'},{'nonempty'}));
        p.addRequired('ind',...
            @(x)validateattributes(x,{'numeric'},{'vector','positive','integer'}));
        
        p.parse(ch,ind);
        
    end
end