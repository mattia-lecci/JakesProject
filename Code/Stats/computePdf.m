function pdf = computePdf(ch,varargin)
%COMPUTEPDF Computes pdfs of the given channel using as realizations the
%columns of ch (which should be independent channels)
%
% pdf = COMPUTEPDF(ch) Computes pdf for channel ch on the last available
% sample. Returns a structure, later described.
% pdf = COMPUTEPDF(ch,ind) Computes pdf for channel ch on samples indexes
% given by ind (either scalar or vector). Returns a structure of the same
% length of ind.
% pdf = COMPUTEPDF(ch,ind,binMethod) Allows you to choose the binning
% method of histcounts from: 'auto' (default), 'scott', 'fd', 'integers',
% 'sturges', 'sqrt'
%
% NOTE: No uniform distribution fit is available in matlab, that's why
% phase.fit is not present
%
% Structure fields:
% - pdf.magnitude.fit: containing a RayleighDistribution object fitted,
% from which you can extract mean, variance, std, parameter (b) confidence
% interval, plot pdf, cdf,...
% - pdf.magnitude.normBinCount: vector of histogram bin count normalized as pdf
% - pdf.magnitude.edges: vector of histogram edges
% - pdf.phase.normBinCount: vector of histogram bin count normalized as pdf
% - pdf.phase.edges: vector of histogram edges
%
% normBinCount and edges can be visualized with the following command:
% histogram('BinEdges',edges,'BinCounts',normBinCount)
%
% See also: COMPUTEALLSTATS

% arg check
p = inputParser;
inputCheck();

% name inputs
binMethod = p.Results.binMethod;

%% fit pdf
N = length(ind);
for i = N:-1:1 % to avoid preallocation
    % magnitude
    pdf(i).magnitude.fit = fitdist( abs(ch(ind(i),:)).', 'Rayleigh' );
    [pdf(i).magnitude.normBinCount,pdf(i).magnitude.edges] =...
        histcounts( abs(ch(ind(i),:)), 'Normalization','pdf','BinMethod',binMethod);
    
    % phase
    [pdf(i).phase.normBinCount,pdf(i).phase.edges] =...
        histcounts( angle(ch(ind(i),:)), 'Normalization','pdf',...
        'BinLimits',[-pi,pi],'BinMethod',binMethod);
end

%% Argument checker
    function inputCheck()
        validBinMethods = {'auto','scott','fd','integers','sturges','sqrt'};
        
        p.addRequired('ch',...
            @(x)validateattributes(x,{'numeric'},{'2d','nonempty'}));
        p.addOptional('ind',size(ch,1),...
            @(x)validateattributes(x,{'numeric'},{'vector','positive','integer'}));
        p.addOptional('binMethod','auto',...
            @(x)any(validatestring(x,validBinMethods)));
        
        p.parse(ch,varargin{:});
        
    end
end