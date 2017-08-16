clear variables
close all
clc

addpath('Channels','Misc','Plots','SavedData','Stats')

%% Parameters
% main parameters
loadSimTime =   true;
saveSimTime =   false;

% createChannel parameters
T = 1e-3;
fd = 0.01/T;
% duration = 1e5; <<< controlled by NsamplesList
nSin = 8;
durationType = 'samples';
Nchannels = [1 10 100];
interpMethod = 'pchip';
simList = {'Clarke','PopBeaulieu','ZhengXiao2002',...
    'LiHuang','ZhengXiao2003','XiaoZhengBeaulieu',...
    'Komninakis'};
legend = getLegend(simList,Nchannels);

% computeSimulationTime parameters
precision = .1;
NsamplesList = round( logspace(3,log10(2e6),18)' );
precisionType = '%';

%% computation
time = zeros( length(NsamplesList),length(simList),length(Nchannels) );

if loadSimTime
    load('SavedData/multiSimTime');
else
    for j = 1:length(Nchannels)
        for i = 1:length(simList)
            
            time(:,i,j) = computeSimulationTime(simList{i},precision,NsamplesList,...
                'fd',fd,'T',T,'nSin',nSin,'interpMethod',interpMethod,...
                'PrecisionType',precisionType,'Nchannels',Nchannels(j));
            
        end
    end
    
    if saveSimTime
        save('SavedData/multiSimTime','time');
    end
    
end

%% plot

figSimTime = plotSimulationTime(NsamplesList,time,legend);
adjustColors(figSimTime); % Jakes is not plotted => different colors

%% Utility functions
function legend = getLegend(simList,Nch)

% copy simList
legend = simList;

% add first Nch
legend{1} = [legend{1}, ', $N_{ch}=',num2str(Nch(1)),'$'];

% add other Nch
for i = 2:length(Nch)
    legend{end+1} = [simList{1}, ', $N_{ch}=',num2str(Nch(i)),'$'];
end

end
% -------------------------------------------------------------------
function adjustColors(fig)

% init
load('SavedData/multSimTime_colors');
figure(fig)
ch = get(gca,'Children');

for i = 1:length(ch)
    ind = mod(i-1,7)+1;
    ch(end-i+1).Color = colors(ind,:);
end

end