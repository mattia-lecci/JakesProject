function pdf = computePdf(ch,ind)
%COMPUTEPDF Computes pdf of the given channel using as realizations the
%columns of ch (which should be independent channels)
% pdf = COMPUTEPDF(ch,ind) Computes pdf for channel ch on samples indexes
% given by ind (either scalar or vector). Returns a structure of the same
% length of ind with fields:
% - fit: containing a RayleighDistribution object fitted, from which you
% can extract mean, variance, std, parameter (b) confidence interval, plot
% pdf, cdf,...
% - normBinCount: vector of histogram bin count normalized as pdf
% - edges: vector of histogram edges
%
%
% normBinCount and edges can be visualized with the following command:
% histogram('BinEdges',pdf.edges,'BinCounts',pdf.normBinCount)

% arg check
p = inputParser;
inputCheck();

%% fit pdf
N = length(ind);
for i = N:-1:1 % to avoid preallocation
    pdf(i).fit = fitdist( abs(ch(ind(i),:)).', 'Rayleigh' );
    [pdf(i).normBinCount,pdf(i).edges] = histcounts( abs(ch(ind(i),:)),...
        'Normalization','pdf');
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