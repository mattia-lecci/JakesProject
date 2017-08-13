function figure = plotMultipleAFD(AFD,Legend,fd,varargin)
%PLOTMULTIPLEAFD Plots the Level Crossing Rate given as output from computeAFD
%
% figure = PLOTMULTIPLEAFD(AFD,legend,fd) Plots all of the precalculated AFD from the
%   function computeAFD, plotting first a thick black line representing the
%   ideal case(s), and then all of the others containined in the array of struct
%   LCR. the first column is plotted first and considered to be the base fot
%   the following ones. The input legend should contain a cell array of strings 
%   containing the legend with the same number of rows of AFD. Finally,
%   fd is the maximum doppler frequency used to create the channels. It has
%   to be a vector of the same length as the number of columns of AFD. The 
%   outuput figure contains a reference to the plotted figure.
% figure = PLOTMULTIPLEAFD(AFD,legend,fd,RMS) If the channel had a different RMS
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
[figure,colors,plots] = plotFirst(AFD(:,1),fd(1),RMS);

if length(fd)>1
    plotOthers(figure,colors,AFD(:,2:end),fd(2:end),RMS);
end

legend(plots,['Ideal',Legend],'Location','northwest');

%% Argument checker
    function inputCheck()
        
        p.addRequired('AFD',@(x)checkLcrStruct(x));
        p.addRequired('legend',@(x)iscellstr(x));
        p.addRequired('fd',@(x)checkfd(x,AFD));
        p.addOptional('RMS',1,...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        
        p.parse(AFD,Legend,fd,varargin{:});
        
        % further check
        validateattributes(Legend,{'cell'},{'numel',size(AFD,1)});
        
    end
end

%% Utility functions

function b = checkLcrStruct(AFD)

% field lists
fields = {'values','thresh','stdev'};

% check fields
fieldsOk = isfield(AFD,fields);

b = all(fieldsOk);

end
%------------------------------------------------------------------
function b = checkfd(fd,AFD)

validateattributes(fd,{'numeric'},{'nonempty','vector'});
b = isscalar(fd) || (length(fd)==size(AFD,2));

end

% ------------------------------------------------------------------------
function [fig,col,plots] = plotFirst(AFD,fd,RMS)

% init
Xlim = getXlim(AFD);
col = zeros(length(AFD),3);

% ideal
ideal = getIdeal(fd);

fig = figure;
plots = fplot(ideal,Xlim,'k','LineWidth',1.5);
hold on; grid on;

% computed LCR
for i = 1:length(AFD)
    lambda = 20*log10(AFD(i).thresh/RMS);
    plots(1+i) = plot(lambda,AFD(i).values);
    col(i,:) = plots(1+i).Color;
end
hold off

% aesthetic
title('Average Fade Duration','Interpreter','latex','FontSize',18)
xlabel('$\lambda_{dB}$','Interpreter','latex')
ylabel('AFD($\lambda$)','Interpreter','latex')

% use log in y coordinate
ax = gca;
ax.YScale = 'log';
end

function plotOthers(fig,colors,AFD,fd,RMS)

% init
Xlim = getXlim(AFD(:));

% ideal
ideal = getIdeal(fd);

figure(fig)
hold on;
fplot(ideal,Xlim,'k','LineWidth',1.5);

% plots
for j = 1:size(AFD,2)
    for i = 1:size(AFD,1)
        lambda = 20*log10(AFD(i,j).thresh/RMS);
        plot(lambda,AFD(i,j).values,'Color',colors(i,:));
    end
end

hold off

end

% ----------------------------------------------------------------
function Xlim = getXlim(AFD)

minX = +inf;
maxX = -inf;

for i = 1:length(AFD)
    m = min( AFD(i).thresh );
    M = max( AFD(i).thresh );
    
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
    id{i} = @(x) ( exp(lam(x).^2)-1 )./( sqrt(2*pi)*uniquefd(i)*lam(x) ); %#ok<AGROW>
end

end