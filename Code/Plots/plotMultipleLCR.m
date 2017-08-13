function figure = plotMultipleLCR(LCR,Legend,fd,varargin)
%PLOTMULTIPLELCR Plots the Level Crossing Rate given as output from computeLCR
%
% figure = PLOTMULTIPLELCR(LCR,legend,fd) Plots all of the precalculated LCR from the
%   function computeLCR, plotting first a thick black line representing the
%   ideal case(s), and then all of the others containined in the array of struct
%   LCR. the first column is plotted first and considered to be the base fot
%   the following ones. The input legend should contain a cell array of strings 
%   containing the legend with the same number of rows of LCR. Finally,
%   fd is the maximum doppler frequency used to create the channels. It has
%   to be a vector of the same length as the number of columns of LCR. The 
%   outuput figure contains a reference to the plotted figure.
% figure = PLOTMULTIPLELCR(LCR,legend,fd,RMS) If the channel had a different RMS
%   from 1, you can specify it as the fourth input.
%
% See also: COMPUTELCR

% arg check
p = inputParser;
inputCheck();

% name inputs
RMS = p.Results.RMS;

% init
Legend = {Legend{:}}; % row

%% Plot
[figure,colors,plots] = plotFirst(LCR(:,1),fd(1),RMS);

if length(fd)>1
    plotOthers(figure,colors,LCR(:,2:end),fd(2:end),RMS);
end

legend(plots,['Ideal',Legend],'Location','south');

%% Argument checker
    function inputCheck()
        
        p.addRequired('LCR',@(x)checkLcrStruct(x));
        p.addRequired('legend',@(x)iscellstr(x));
        p.addRequired('fd',@(x)checkfd(x,LCR));
        p.addOptional('RMS',1,...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        
        p.parse(LCR,Legend,fd,varargin{:});
        
        % further check
        validateattributes(Legend,{'cell'},{'numel',size(LCR,1)});
        
    end
end

%% Utility functions

function b = checkLcrStruct(LCR)

% field lists
fields = {'values','thresh','stdev'};

% check fields
fieldsOk = isfield(LCR,fields);

b = all(fieldsOk);

end
%------------------------------------------------------------------
function b = checkfd(fd,LCR)

validateattributes(fd,{'numeric'},{'nonempty','vector'});
b = isscalar(fd) || (length(fd)==size(LCR,2));

end

% ------------------------------------------------------------------------
function [fig,col,plots] = plotFirst(LCR,fd,RMS)

% init
Xlim = getXlim(LCR);
col = zeros(length(LCR),3);

% ideal
ideal = getIdeal(fd);

fig = figure;
plots = fplot(ideal,Xlim,'k','LineWidth',1.5);
hold on; grid on;

% computed LCR
for i = 1:length(LCR)
    lambda = 20*log10(LCR(i).thresh/RMS);
    plots(1+i) = plot(lambda,LCR(i).values);
    col(i,:) = plots(1+i).Color;
end
hold off

% aesthetic
title('Level Crossing Rate','Interpreter','latex','FontSize',18)
xlabel('$\lambda_{dB}$','Interpreter','latex')
ylabel('LCR($\lambda$)','Interpreter','latex')

% use log in y coordinate
ax = gca;
ax.YScale = 'log';
end

function plotOthers(fig,colors,LCR,fd,RMS)

% init
Xlim = getXlim(LCR(:));

% ideal
ideal = getIdeal(fd);

figure(fig)
hold on;
fplot(ideal,Xlim,'k','LineWidth',1.5);

% plots
for j = 1:size(LCR,2)
    for i = 1:size(LCR,1)
        lambda = 20*log10(LCR(i,j).thresh/RMS);
        plot(lambda,LCR(i,j).values,'Color',colors(i,:));
    end
end

hold off

end

% ----------------------------------------------------------------
function Xlim = getXlim(LCR)

minX = +inf;
maxX = -inf;

for i = 1:length(LCR)
    m = min( LCR(i).thresh );
    M = max( LCR(i).thresh );
    
    minX = min(minX,m);
    maxX = max(maxX,M);
end

Xlim = 20*log10( [minX maxX] );

end
% --------------------------------------------------------------
function id = getIdeal(fd)

uniquefd = unique(fd,'stable');
lam = @(x) 10.^(x/20);

for i = 1:length(uniquefd)
    id{i} = @(x) sqrt(2*pi)*uniquefd(i)*lam(x).*exp(-lam(x).^2); %#ok<AGROW>
end

end