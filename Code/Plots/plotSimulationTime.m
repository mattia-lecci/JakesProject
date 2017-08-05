function plots = plotSimulationTime(samples,time,Legend)
%PLOTSIMULATIONTIME Plots the simulations times as given by the function
%computeSimulationTime
%
% plots = PLOTSIMULATIONTIME(samples,time,Legend) Plots the simulation
%   times as given by the function computeSimulationTime. To try to keep
%   the same colours as the other plots, the first one (which is usually
%   the Ideal plot) is discarded. Legend should contain the names to put in
%   the legend in order (left to right) with the columns of the input time.
%   The output plots is a vector of Line handles which contain, in order,
%   references to the plotted lines.
%
% See also: COMPUTESIMULATIONTIME

% arg check
p = inputParser;
inputCheck();

%% Plots
loglog(0,0); % to keep the same colours, the other stats have an Ideal plot
hold on; grid on

for i = 1:size(time,2)
    plots(i) = loglog(samples,time(:,i)); %#ok<AGROW>
end
hold off

% aesthetic
title('Simulation time')
xlabel('#samples')
ylabel('time [s]')
xlim([min(samples) max(samples)])

legend(plots,Legend) % do not display first entry

%% Argument checker
    function inputCheck()
        
        p.addRequired('samples',...
            @(x)validateattributes(x,{'numeric'},{'positive','integer','vector'}));
        p.addRequired('time',...
            @(x)validateattributes(x,{'numeric'},{'positive','2d',...
            'nrows',length(samples)}));
        p.addRequired('Legend',@(x)iscellstr(x));
        
        p.parse(samples,time,Legend);
        
        % further check
        validateattributes(Legend,{'cell'},{'numel',size(time,2)});
        
    end

end