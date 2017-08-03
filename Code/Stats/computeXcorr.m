function xcorr = computeXcorr(ch,varargin)

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
[xcorr.X,xcorr.lag] = statisticalXcorr(ch,ch,maxlag);
xcorr.X2 = statisticalXcorr(abs(ch).^2,abs(ch).^2,maxlag);

%% Argument checker
    function inputCheck()
        
        p.addRequired('ch',...
            @(x)validateattributes(x,{'numeric'},{'2d'}));
        p.addOptional('maxlag',size(ch,1)-1,...
            @(x)validateattributes(x,{'numeric'},{'nonempty','nonnegative',...
            'scalar','integer','<',size(ch,1)}));
        
        p.parse(ch,varargin{:});
        
    end
end