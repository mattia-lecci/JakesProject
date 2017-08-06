function plots = plotXcorr(XCORR,legend,fd,T)
%PLOTXCORR Plots cross correlation functions given as output from
%computeXcorr
%
% plots = PLOTXCORR(XCORR,legend,fd,T) Plots all of the precalculated 
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
% OUTPUT: plots is a structure with fields:
% - plots.XcXc
% - plots.XsXs
% - plots.XcXs
% - plots.XsXc
% - plots.ReX
% - plots.ImX
% - plots.X2
% Each of them contain an array with length(XCORR)+1 elements, in which the
% first one contains a FunctionLine object handle (Ideal case), and the
% others in order contain Line object handles in order for each of the
% elements in XCORR.
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
plots.XcXc = plotAll( @(x) .5*besselj(0,2*pi*x),...
    t,{XCORR.XcXc},legend,'R_{X_cX_c}','Normalized time (f_d\tau)','',...
    besselLim/2);
plots.XsXs = plotAll( @(x) .5*besselj(0,2*pi*x),...
    t,{XCORR.XsXs},legend,'R_{X_sX_s}','Normalized time (f_d\tau)','',...
    besselLim/2);
plots.XcXs = plotAll( @(x) 0.*x,...
    t,{XCORR.XcXs},legend,'R_{X_cX_s}','Normalized time (f_d\tau)','',...
    zeroLim);
plots.XsXc = plotAll( @(x) 0.*x,...
    t,{XCORR.XsXc},legend,'R_{X_sX_c}','Normalized time (f_d\tau)','',...
    zeroLim);
plots.ReX = plotAll( @(x) besselj(0,2*pi*x),...
    t, cellfun(@real,{XCORR.X},'UniformOutput',false),legend,...
    'Re[R_{X}]','Normalized time (f_d\tau)','',besselLim);
plots.ImX = plotAll( @(x) 0.*x,...
    t, cellfun(@imag,{XCORR.X},'UniformOutput',false),legend,...
    'Im[R_{X}]','Normalized time (f_d\tau)','',zeroLim);
plots.X2 = plotAll( @(x) 1 + besselj(0,2*pi*x).^2,...
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
function plots = plotAll(ideal,t,others,leg,tit,xlab,ylab,Ylim)

% init
Xlim = [min(t), max(t)];

% ideal
figure
plots(1) = fplot(ideal,Xlim,'k','LineWidth',1.5);
hold on; grid on;

% given data
for i = 1:length(others)
    plots(i+1) = plot(t,others{i}); %#ok<AGROW>
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