function fig = plotSimulationTime(samples,time,Legend)
%PLOTSIMULATIONTIME Plots the simulations times as given by the function
%computeSimulationTime
%
% plots = PLOTSIMULATIONTIME(samples,time,Legend) Plots the simulation
%   times as given by the function computeSimulationTime. In order to try to keep
%   the same colours as the other plots, the first one (which is usually
%   the Ideal plot) is discarded. Legend should contain the names to put in
%   the legend in order (left to right) with the columns of the input time.
%   The output fig is a reference to the plotted figure.
%   NOTE: a multi Simulation plot is now supported. Simulators should lie
%   on the second dimension while the third dimension is for the other
%   parameter. Colors will be maintained among lines of the same simulator
%   while styles will vary following the third dimension. The third
%   dimension shouldn't exceed a length of 4.
%
% See also: COMPUTESIMULATIONTIME

% arg check
p = inputParser;
inputCheck();

% init
Legend = {Legend{:}}; % row
color = zeros( size(time,2),3 );
style = {'-','-.','--',':'};

%% Plots
fig = figure;
dummyLine = loglog(0,0); % to keep the same colours, the other stats have an Ideal plot
hold on; grid on

% plot first time: first Nch, all simulators
for i = 1:size(time,2)
    plots(i) = loglog(samples,time(:,i,1),'DisplayName',Legend{i},'LineStyle',style{1});
    color(i,:) = plots(i).Color;
end

% plot other Nch
for j = 2:size(time,3)
    for i = 1:size(time,2)
        if i==1
            legInd = size(time,2) + j-1;
            plots(legInd) = loglog(samples,time(:,i,j),'DisplayName',Legend{legInd},...
                'Color',color(i,:),'LineStyle',style{j});
        else
            loglog(samples,time(:,i,j),'Color',color(i,:),'LineStyle',style{j});
        end
    end
end

hold off

% aesthetic
title('Simulation time','Interpreter','latex','FontSize',18)
xlabel('\#samples','Interpreter','latex')
ylabel('time [s]','Interpreter','latex')
xlim([min(samples) max(samples)])

legend(plots,Legend,'Location','northwest')
delete(dummyLine);

%% Argument checker
    function inputCheck()
        
        p.addRequired('samples',...
            @(x)validateattributes(x,{'numeric'},{'positive','integer','vector'}));
        p.addRequired('time',...
            @(x)validateattributes(x,{'numeric'},{'positive','3d',...
            'size',[length(samples),NaN,NaN]}));
        p.addRequired('Legend',@(x)iscellstr(x));
        
        p.parse(samples,time,Legend);
        
        % further check
        Nleg = size(time,2) + size(time,3)-1; % one for each sim (2nd dim) + one for each extra Nch (3rd dim)
        validateattributes(Legend,{'cell'},{'numel',Nleg});
        if size(time,3)>4
            error('size(time,3)>4')
        end
        
    end

end