function figure = plotAFD(AFD,legend,fd,varargin)
%PLOTAFD Plots the Average Fade Duration given as output from computeAFD
%
% figure = PLOTAFD(AFD,legend,fd) Plots all of the precalculated AFD from the
%   function computeAFD, plotting first a thick black line representing the
%   ideal case, and then all of the others containined in the array of struct
%   AFD. The input legend should contain a cell array of strings containing
%   the legend with the same order (and number of elements) of AFD. Finally,
%   fd is the maximum doppler frequency used to create the channels it can
%   be either a scalar of a vector of the same length as AFD). The outuput
%   figure contains a reference to the plotted figure.
% figure = PLOTAFD(AFD,legend,fd,RMS) If the channel had a different RMS
%   from 1, you can specify it as the fourth input.
%
% See also: COMPUTEAFD

% arg check
p = inputParser;
inputCheck();

% name inputs
RMS = p.Results.RMS;

% init
legend = {legend{:}}; % row

%% Plot
figure = plotafd(AFD,legend,fd,RMS);

%% Argument checker
    function inputCheck()
        
        p.addRequired('AFD',@(x)checkAfdStruct(x));
        p.addRequired('legend',@(x)iscellstr(x));
        p.addRequired('fd',@(x)checkfd(x,AFD));
        p.addOptional('RMS',1,...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        
        p.parse(AFD,legend,fd,varargin{:});
        
        % further check
        validateattributes(legend,{'cell'},{'numel',length(AFD)});

    end
end

%% Utility functions

function b = checkAfdStruct(AFD)

% field lists
fields = {'values','thresh','stdev'};

% check fields
fieldsOk = isfield(AFD,fields);
vecOk = isvector(AFD);

b = all([fieldsOk,vecOk]);

end
%------------------------------------------------------------------
function b = checkfd(fd,AFD)

validateattributes(fd,{'numeric'},{'nonempty','vector'});
b = isscalar(fd) || (length(fd)==length(AFD));

end
% ------------------------------------------------------------------------
function fig = plotafd(AFD,leg,fd,RMS)

% init
Xlim = 20*log10( [min(AFD(1).thresh) max(AFD(1).thresh)] );

% ideal
ideal = getIdeal(fd);

fig = figure;
plots = fplot(ideal,Xlim,'k','LineWidth',1.5);
hold on; grid on;

plots = plots(1); % keep only one

% computed LCR
for i = 1:length(AFD)
    lambda = 20*log10(AFD(i).thresh/RMS);
    plots(1+i) = plot(lambda,AFD(i).values);
end
hold off

% aesthetic
title('Average Fade Duration')
xlabel('\lambda_{dB}')
ylabel('AFD(\lambda)')

legend(plots,['Ideal',leg],'Location','northwest');

% use log in y coordinate
ax = gca;
ax.YScale = 'log';

end

% ----------------------------------------------------------------
function id = getIdeal(fd)

uniquefd = unique(fd,'stable');
lam = @(x) 10.^(x/20);

for i = 1:length(uniquefd)
    id{i} = @(x) ( exp(lam(x).^2)-1 )./( sqrt(2*pi)*uniquefd(i)*lam(x) ); %#ok<AGROW>
end

end