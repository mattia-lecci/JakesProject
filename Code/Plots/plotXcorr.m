function plots = plotXcorr(XCORR,legend,fd,T)

% arg check
p = inputParser;
inputCheck();

% init
t = XCORR.lags*T*fd;
besselLim = [-.6,1.2];
zeroLim = [-.5,.5];
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
    t,{real(XCORR.X)},legend,'Re[R_{X}]','Normalized time (f_d\tau)','',...
    besselLim);
plots.ImX = plotAll( @(x) 0.*x,...
    t,{imag(XCORR.X)},legend,'Im[R_{X}]','Normalized time (f_d\tau)','',...
    zeroLim);
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
    plots(i+1) = plot(t,others{i});
end

% aesthetic
title(tit)
xlabel(xlab)
ylabel(ylab)
xlim(Xlim)
ylim(Ylim)

legend(['Ideal',leg])

end