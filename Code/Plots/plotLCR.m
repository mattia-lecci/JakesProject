function figure = plotLCR(LCR,legend,fd,varargin)
%PLOTLCR Plots the Level Crossing Rate given as output from computeLCR
%
% figure = PLOTLCR(LCR,legend,fd) Plots all of the precalculated LCR from the
%   function computeLCR, plotting first a thick black line representing the
%   ideal case, and then all of the others containined in the array of struct
%   LCR. The input legend should contain a cell array of strings containing
%   the legend with the same order (and number of elements) of LCR. Finally,
%   fd is the maximum doppler frequency used to create the channels (it can
%   be either a scalar of a vector of the same length as LCR). The outuput
%   figure contains a reference to the plotted figure.
% figure = PLOTLCR(LCR,legend,fd,RMS) If the channel had a different RMS
%   from 1, you can specify it as the fourth input.
%
% See also: COMPUTELCR

% arg check
p = inputParser;
inputCheck();

% name inputs
RMS = p.Results.RMS;

% init
legend = {legend{:}}; % row

%% Plot
figure = plotlcr(LCR,legend,fd,RMS);

%% Argument checker
    function inputCheck()
        
        p.addRequired('LCR',@(x)checkLcrStruct(x));
        p.addRequired('legend',@(x)iscellstr(x));
        p.addRequired('fd',@(x)checkfd(x,LCR));
        p.addOptional('RMS',1,...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        
        p.parse(LCR,legend,fd,varargin{:});
        
        % further check
        validateattributes(legend,{'cell'},{'numel',length(LCR)});

    end
end

%% Utility functions

function b = checkLcrStruct(LCR)

% field lists
fields = {'values','thresh','stdev'};

% check fields
fieldsOk = isfield(LCR,fields);
vecOk = isvector(LCR);

b = all([fieldsOk,vecOk]);

end
%------------------------------------------------------------------
function b = checkfd(fd,LCR)

validateattributes(fd,{'numeric'},{'nonempty','vector'});
b = isscalar(fd) || (length(fd)==length(LCR));

end

% ------------------------------------------------------------------------
function fig = plotlcr(LCR,leg,fd,RMS)

% init
Xlim = 20*log10( [min(LCR(1).thresh) max(LCR(1).thresh)] );

% ideal
ideal = getIdeal(fd);

fig = figure;
plots = fplot(ideal,Xlim,'k','LineWidth',1.5);
hold on; grid on;

plots = plots(1); % keep only one

% computed LCR
for i = 1:length(LCR)
    lambda = 20*log10(LCR(i).thresh/RMS);
    plots(1+i) = plot(lambda,LCR(i).values);
end
hold off

% aesthetic
title('Level Crossing Rate','Interpreter','latex','FontSize',18)
xlabel('$\lambda_{dB}$','Interpreter','latex')
ylabel('LCR($\lambda$)','Interpreter','latex')

legend(plots,['Ideal',leg],'Location','south');

% use log in y coordinate
ax = gca;
ax.YScale = 'log';
end

% ----------------------------------------------------------------
function id = getIdeal(fd)

uniquefd = unique(fd,'stable');
lam = @(x) 10.^(x/20);

for i = 1:length(uniquefd)
    id{i} = @(x) sqrt(2*pi)*uniquefd(i)*lam(x).*exp(-lam(x).^2); %#ok<AGROW>
end

end