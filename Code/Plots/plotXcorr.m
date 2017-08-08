function figures = plotXcorr(XCORR,legend,fd,T)
%PLOTXCORR Plots cross correlation functions given as output from
%computeXcorr
%
% figures = PLOTXCORR(XCORR,legend,fd,T) Plots all of the precalculated 
%   cross correlations from the  function computeXcorr, plotting first a
%   thick black  line representing the ideal case, and then all of the others
%   containined in the array of struct XCORR. The input legend should contain
%   a cell array of strings containing the legend with the same order (and
%   number of elements) of XCORR. The inputs fd and T are used as
%   normalizations for the time lags.
%
% Plots all the correlations computed in computeXcorr, dividing XCORR.X in
% real and imaginary part.
%
% OUTPUT: figures is a structure with fields:
% - figures.XcXc
% - figures.XsXs
% - figures.XcXs
% - figures.XsXc
% - figures.ReX
% - figures.ImX
% - figures.X2 (referring to |X|^2)
% Each of them contain a reference to the corresponding plotted figure.
%
% See also: COMPUTEXCORR

% arg check
p = inputParser;
inputCheck();

% init
t = XCORR(1).lags*T*fd;
besselLim = [-.6,1.2];
zeroLim = [-1,1];
bessel2Lim = [.8,2.2];

%% Plots
figures.XcXc = plotAll( @(x) .5*besselj(0,2*pi*x),...
    t,{XCORR.XcXc},legend,'R_{X_cX_c}','Normalized time (f_d\tau)','',...
    besselLim/2);
figures.XsXs = plotAll( @(x) .5*besselj(0,2*pi*x),...
    t,{XCORR.XsXs},legend,'R_{X_sX_s}','Normalized time (f_d\tau)','',...
    besselLim/2);
figures.XcXs = plotAll( @(x) 0.*x,...
    t,{XCORR.XcXs},legend,'R_{X_cX_s}','Normalized time (f_d\tau)','',...
    zeroLim);
figures.XsXc = plotAll( @(x) 0.*x,...
    t,{XCORR.XsXc},legend,'R_{X_sX_c}','Normalized time (f_d\tau)','',...
    zeroLim);
figures.ReX = plotAll( @(x) besselj(0,2*pi*x),...
    t, cellfun(@real,{XCORR.X},'UniformOutput',false),legend,...
    'Re[R_{X}]','Normalized time (f_d\tau)','',besselLim);
figures.ImX = plotAll( @(x) 0.*x,...
    t, cellfun(@imag,{XCORR.X},'UniformOutput',false),legend,...
    'Im[R_{X}]','Normalized time (f_d\tau)','',zeroLim);
figures.X2 = plotAll( @(x) 1 + besselj(0,2*pi*x).^2,...
    t,{XCORR.X2},legend,'R_{|X|^2}','Normalized time (f_d\tau)','',bessel2Lim);

%% Argument checker
    function inputCheck()
        
        p.addRequired('XCORR',@(x)checkXcorrStruct(x));
        p.addRequired('legend',@(x)iscellstr(x));
        p.addRequired('fd',...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        p.addRequired('T',...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        
        p.parse(XCORR,legend,fd,T);
        
        % further check
        validateattributes(legend,{'cell'},{'numel',length(XCORR)});

    end
end

%% Utility functions

function b = checkXcorrStruct(XCORR)

% field lists
fields = {'lags','XcXc','XsXs','XcXs','XsXc','X','X2'};

% check fields
fieldsOk = isfield(XCORR,fields);
vecOk = isvector(XCORR);

b = all([fieldsOk,vecOk]);

end

% --------------------------------------------------------------------
function fig = plotAll(ideal,t,others,leg,tit,xlab,ylab,Ylim)

% init
Xlim = [min(t), max(t)];

% ideal
fig = figure;
fplot(ideal,Xlim,'k','LineWidth',1.5);
hold on; grid on;

% given data
for i = 1:length(others)
    plot(t,others{i});
end
hold off

% aesthetic
title(tit)
xlabel(xlab)
ylabel(ylab)
xlim(Xlim)
ylim(Ylim)

legend(['Ideal',leg])

end