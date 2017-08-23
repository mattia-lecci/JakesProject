function figures = plotXcorr(XCORR,legend,fd,varargin)
%PLOTXCORR Plots cross correlation functions given as output from
%computeXcorr
%
% figures = PLOTXCORR(XCORR,legend,fd) Plots all of the precalculated 
%   cross correlations from the  function computeXcorr, plotting first a
%   thick black  line representing the ideal case, and then all of the others
%   containined in the array of struct XCORR. The input legend should contain
%   a cell array of strings containing the legend with the same order (and
%   number of elements) of XCORR. The inputs fd and T are used as
%   normalizations for the time lags. fd may be a scalar or a vector with
%   the same length of XCORR in order to support multiple different doppler
%   frequencies at once.
% figures = PLOTXCORR(XCORR,legend,fd,figs) The optional argument figs
%   allows you to reinsert the output from a previous call to PLOTXCORR. In
%   this way, plots will be added to the already existing figures and
%   legends will be updated accordingly.
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

% name input
figs = p.Results.figs;

if isempty(figs)
    figs.XcXc = [];
    figs.XsXs = [];
    figs.XcXs = [];
    figs.XsXc = [];
    figs.ReX = [];
    figs.ImX = [];
    figs.X2 = [];
end

% init
t = {XCORR.timelags};
besselLim = [-.6,1.2];
zeroLim = [-1,1];
bessel2Lim = [.8,2.2];
legend = {legend{:}}; % row

%% Plots
figures.XcXc = plotAll( @(x) .5*besselj(0,2*pi*x),...
    t,fd,{XCORR.XcXc},legend,'$R_{X_cX_c}$','Normalized time $(f_d\tau)$','',...
    besselLim/2,figs.XcXc);
figures.XsXs = plotAll( @(x) .5*besselj(0,2*pi*x),...
    t,fd,{XCORR.XsXs},legend,'$R_{X_sX_s}$','Normalized time $(f_d\tau)$','',...
    besselLim/2,figs.XsXs);
figures.XcXs = plotAll( @(x) 0.*x,...
    t,fd,{XCORR.XcXs},legend,'$R_{X_cX_s}$','Normalized time $(f_d\tau)$','',...
    zeroLim,figs.XcXs);
figures.XsXc = plotAll( @(x) 0.*x,...
    t,fd,{XCORR.XsXc},legend,'$R_{X_sX_c}$','Normalized time $(f_d\tau)$','',...
    zeroLim,figs.XsXc);
figures.ReX = plotAll( @(x) besselj(0,2*pi*x),...
    t,fd, cellfun(@real,{XCORR.X},'UniformOutput',false),legend,...
    '$Re[R_{X}]$','Normalized time $(f_d\tau)$','',besselLim,figs.ReX);
figures.ImX = plotAll( @(x) 0.*x,...
    t,fd, cellfun(@imag,{XCORR.X},'UniformOutput',false),legend,...
    '$Im[R_{X}]$','Normalized time $(f_d\tau)$','',zeroLim,figs.ImX);
figures.X2 = plotAll( @(x) 1 + besselj(0,2*pi*x).^2,...
    t,fd,{XCORR.X2},legend,'$R_{|X|^2}$','Normalized time $(f_d\tau)$','',...
    bessel2Lim,figs.X2);

%% Argument checker
    function inputCheck()
        
        p.addRequired('XCORR',@(x)checkXcorrStruct(x));
        p.addRequired('legend',@(x)iscellstr(x));
        p.addRequired('fd',@(x)checkfd(x,XCORR));
        p.addOptional('figs',[],@(x)checkFigs(x));
        
        p.parse(XCORR,legend,fd,varargin{:});
        
        % further check
        validateattributes(legend,{'cell'},{'numel',length(XCORR)});

    end
end

%% Utility functions

function b = checkXcorrStruct(XCORR)

% field lists
fields = {'timelags','XcXc','XsXs','XcXs','XsXc','X','X2'};

% check fields
fieldsOk = isfield(XCORR,fields);
vecOk = isvector(XCORR);

b = all([fieldsOk,vecOk]);

end
%--------------------------------------------------------------------
function b = checkFigs(fig)

% field lists
fields = {'XcXc','XsXs','XcXs','XsXc','ReX','ImX','X2'};

% check fields
b = all(isfield(fig,fields));

end
%------------------------------------------------------------------
function b = checkfd(fd,xcorr)

validateattributes(fd,{'numeric'},{'nonempty','vector'});
b = isscalar(fd) || (length(fd)==length(xcorr));

end

% --------------------------------------------------------------------
function fig = plotAll(ideal,t,fd,others,leg,tit,xlab,ylab,Ylim,fig)

% check
if isscalar(fd)
    fd = repmat(fd,1,length(t));
end
if length(fd)~=length(t)
    error('fd has to be either scalar or of the same length of t')
end

% init
Xlim = getXlim(t,fd);
firstPlot = isempty(fig);

% ideal
if firstPlot
    fig = figure;
    fplot(ideal,Xlim,'k','LineWidth',1.5);
    grid on;
else
    figure(fig);
    oldLegendHandle = findobj(gcf, 'Type', 'Legend');
    oldLegend = oldLegendHandle.String;
end
hold on;

% given data
for i = 1:length(others)
    plot(t{i}*fd(i),others{i});
end
hold off

% aesthetic
title(tit,'Interpreter','latex','FontSize',18)
xlabel(xlab,'Interpreter','latex')
ylabel(ylab,'Interpreter','latex')
xlim(Xlim)
ylim(Ylim)

if firstPlot
    legend(['Ideal',leg])
else
    legend([oldLegend, leg])
end

end
% -----------------------------------------------------
function Xlim = getXlim(t,fd)

Min = +inf;
Max = -inf;

for i = 1:length(t)
    m = min(t{i}*fd(i));
    M = max(t{i}*fd(i));
    
    Min = min(Min,m);
    Max = max(Max,M);
end

Xlim = [Min Max];

end