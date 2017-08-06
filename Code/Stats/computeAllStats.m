function stats = computeAllStats(ch,t,varargin)
%COMPUTEALLSTATS Computes all statistics of the given channel in one shot
%
% stats = computeAllStats(ch,t) Computes all of the statistics of channel
%   ch based on time vector t and puts them in the structure stats, later
%   described
% stats = computeAllStats(ch,t,simulator) If ch is the output of a Jakes
%   simulator, specify simulator as 'Jakes'. Otherwise insert 'Other'.
% stats = computeAllStats(...,Name,Value) Name-Value pairs can be added to
%   better control the details of the statistics
%
% OUTPUT: stats is a structure containing the following field:
% - stats.pdf: output of computePdf. Look at the function for more details
% - stats.xcorr: output of computeXcorr
% - stats.LCR: output of computeLCR
% - stats.AFD: output of computeAFD
%
% Name-Value pairs:
% - 'pdfInd': second required input ('ind') of computePdf. Default: last
%   sample (i.e. size(ch,1) )
% - 'binMethod': third optional input of computePdf. Default: 'auto'
% - 'maxlag': second optional input of computeXcorr. Default: size(ch,1)-1,
%   i.e. maximum allowed lag
% - 'thresholds': third optional input of both computeLCR and computeAFD.
%   Default: 25 equally log-spaced values between the min and max magnitude
%   of ch
%
% See also: COMPUTEPDF, COMPUTEXCORR, COMPUTELCR, COMPUTEAFD

% check arg
p = inputParser;
inputCheck();

% name inputs
simulator = p.Results.simulator;
pdfInd = p.Results.pdfInd;
binMethod = p.Results.binMethod;
maxlag = p.Results.maxlag;
thresh = p.Results.thresholds;

% init
T = t(2)-t(1);
duration = t(end)-t(1);

% calls to functions
switch simulator
    case 'Other'
        stats.pdf = computePdf( ch,pdfInd,binMethod ); % compute pdf on last sample
        stats.xcorr = computeXcorr( ch,maxlag ); % compute all type of auto and cross correlation
        stats.LCR = computeLCR( ch,duration,thresh ); % compute LCR
        stats.AFD = computeAFD( ch,T,thresh ); % compute AFD
    case 'Jakes'
        stats.pdf = computePdf( ch(:,1).',pdfInd,binMethod ); % compute pdf on last sample
        stats.xcorr = computeXcorr( ch,maxlag,'Jakes' ); % compute all type of auto and cross correlation
        stats.LCR = computeLCR( ch,duration,thresh ); % compute LCR
        stats.AFD = computeAFD( ch,T,thresh ); % compute AFD
    otherwise
        error('Simulator %s not recognized',simulator);
end

%% Argument checker
    function inputCheck()
        
        p.addRequired('ch',...
            @(x)validateattributes(x,{'numeric'},{'nonempty','2d'}));
        p.addRequired('t',...
            @(x)validateattributes(x,{'numeric'},{'vector','real',...
            'numel',size(ch,1)}));
        p.addOptional('simulator','Other',...
            @(x)any(validatestring(x,{'Jakes','Other'})));
        
        % optional parameters. attributes will be checked by the specific
        % functions
        
        % computePdf
        p.addParameter('pdfInd',size(ch,1));
        p.addParameter('binMethod','auto');
        % computeXcorr
        p.addParameter('maxlag',size(ch,1)-1);
        % computeLCR/computeAFD
        p.addParameter('thresholds',getDefaultThresh(ch));
        
        p.parse(ch,t,varargin{:});
    end

end

%% Utility functions
function thresh = getDefaultThresh(ch)

m = min(abs(ch(:)));
M = max(abs(ch(:)));
thresh = logspace( log10(m),log10(M),26 );
thresh(1) = []; % nothing goes below the min

end