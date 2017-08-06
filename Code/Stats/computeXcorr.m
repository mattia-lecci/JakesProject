function XCORR = computeXcorr(ch,varargin)
%COMPUTEXCORR Computes the statistical cross correlation of the given
%channel using statisticalXcorr.m.
%
% XCORR = COMPUTEXCORR(ch) Considers the columns of ch as realizations of a
%   channel and estimates its statistical correlations.
% XCORR = COMPUTEXCORR(ch,maxlag) You can decide to compute the
%   correlations up to a lower maximum lag.
% XCORR = COMPUTEXCORR(ch,maxlag,simulator) If the given channel is the
%   output of a Jakes simulator, specify the input simulator as 'Jakes'.
%   For any other type of simulator, specify 'Other'.
%
% OUTPUT: consider the channel to be a random variable X = Xc+j*Xs
% Using the notation R_YZ(n,m)=E[Y(n+m)Z*(n)]=E[Y(n)Z*(n-m)] to indicate
% statistical cross correlation between the stochastic processes Y and Z,
% and the notation R_Y(n,m)=E[Y(n+m)Y*(n)] to indicate the autocorrelation
% y, the output of the function COMPUTEXCORR is a structure containing the
% following fields:
%
% - XCORR.lags containing the lags at which all the following correlations
%   are computed
% - XCORR.XcXc containing R_XcXc
% - XCORR.XsXs containing R_XsXs
% - XCORR.XcXs containing R_XcXs
% - XCORR.XsXc containing R_XsXc
% - XCORR.X containing R_X (complex)
% - XCORR.X2 containing R_{|X|^2}
%
% See also: STATISTICALXCORR, COMPUTEALLSTATS

% arg check
p = inputParser;
inputCheck();

% name inputs
maxlag = p.Results.maxlag;
simulator = p.Results.simulator;

%% computations
switch simulator
    case 'Other'
        XCORR.XcXc = statisticalXcorr(real(ch),real(ch),maxlag);
        XCORR.XsXs = statisticalXcorr(imag(ch),imag(ch),maxlag);
        XCORR.XcXs = statisticalXcorr(real(ch),imag(ch),maxlag);
        XCORR.XsXc = statisticalXcorr(imag(ch),real(ch),maxlag);
        [XCORR.X,XCORR.lags] = statisticalXcorr(ch,ch,maxlag);
        XCORR.X2 = statisticalXcorr(abs(ch).^2,abs(ch).^2,maxlag);
    case 'Jakes' % only temporal correlation is possible
        [xc,lg] = xcorr(real(ch),real(ch),maxlag,'unbiased');
        XCORR.XcXc = xc(lg>=0);
        [xc,lg] = xcorr(imag(ch),imag(ch),maxlag,'unbiased');
        XCORR.XsXs = xc(lg>=0);
        [xc,lg] = xcorr(real(ch),imag(ch),maxlag,'unbiased');
        XCORR.XcXs = xc(lg>=0);
        [xc,lg] = xcorr(imag(ch),real(ch),maxlag,'unbiased');
        XCORR.XsXc = xc(lg>=0);
        [xc,lg] = xcorr(ch,ch,maxlag,'unbiased');
        XCORR.X = xc(lg>=0);
        XCORR.lags = lg(lg>=0);
        [xc,lg] = xcorr(abs(ch).^2,abs(ch).^2,maxlag,'unbiased');
        XCORR.X2 = xc(lg>=0);
    otherwise
        error('Simulator %d not recognized',simulator);
end

%% Argument checker
    function inputCheck()
        
        p.addRequired('ch',...
            @(x)validateattributes(x,{'numeric'},{'nonempty','2d'}));
        p.addOptional('maxlag',size(ch,1)-1,...
            @(x)validateattributes(x,{'numeric'},{'nonempty','nonnegative',...
            'scalar','integer','<',size(ch,1)}));
        p.addOptional('simulator','Other',...
            @(x)any(validatestring(x,{'Jakes','Other'})));
        
        p.parse(ch,varargin{:});
        
    end
end