function plots = plotSimulationTime(samples,time,Legend)

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