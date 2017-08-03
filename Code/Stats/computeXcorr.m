function xcorr = computeXcorr(ch,varargin)
%COMPUTEXCORR Computes the statistical cross correlation of the given
%channel using statisticalXcorr.m.
%
% xcorr = COMPUTEXCORR(ch) Considers the columns of ch as realizations of a
% channel and estimates its statistical correlations.
% xcorr = COMPUTEXCORR(ch,maxlag) You can decide to compute the
% correlations up to a lower maximum lag.
%
% OUTPUT: consider the channel to be a random variable X = Xc+j*Xs
% Using the notation R_YZ(n,m)=E[Y(n+m)Z*(n)]=E[Y(n)Z*(n-m)] to indicate
% statistical cross correlation between the stochastic processes Y and Z,
% and the notation R_Y(n,m)=E[Y(n+m)Y*(n)] to indicate the autocorrelation
% y, the output of the function COMPUTEXCORR is a structure containing the
% following fields:
%
% - xcorr.lags containing the lags at which all the following correlations
%           are computed
% - xcorr.XcXc containing R_XcXc
% - xcorr.XsXs containing R_XsXs
% - xcorr.XcXs containing R_XcXs
% - xcorr.XsXc containing R_XsXc
% - xcorr.X containing R_X (complex)
% - xcorr.X2 containing R_{|X|^2}
%
% See also: STATISTICALXCORR, COMPUTEALLSTATS

% arg check
p = inputParser;
inputCheck();

% name inputs
maxlag = p.Results.maxlag;

%% computations
xcorr.XcXc = statisticalXcorr(real(ch),real(ch),maxlag);
xcorr.XsXs = statisticalXcorr(imag(ch),imag(ch),maxlag);
xcorr.XcXs = statisticalXcorr(real(ch),imag(ch),maxlag);
xcorr.XsXc = statisticalXcorr(imag(ch),real(ch),maxlag);
[xcorr.X,xcorr.lags] = statisticalXcorr(ch,ch,maxlag);
xcorr.X2 = statisticalXcorr(abs(ch).^2,abs(ch).^2,maxlag);

%% Argument checker
    function inputCheck()
        
        p.addRequired('ch',...
            @(x)validateattributes(x,{'numeric'},{'nonempty','2d'}));
        p.addOptional('maxlag',size(ch,1)-1,...
            @(x)validateattributes(x,{'numeric'},{'nonempty','nonnegative',...
            'scalar','integer','<',size(ch,1)}));
        
        p.parse(ch,varargin{:});
        
    end
end