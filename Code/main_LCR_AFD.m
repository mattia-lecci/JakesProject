clear variables
close all
clc

addpath('Channels','Misc','Plots','SavedData','Stats')
% set 8 colors (as many as the simulators)
set(groot,'defaultAxesColorOrder','default');
set(groot,'defaultAxesColorOrder',...
    [get(groot,'defaultAxesColorOrder');
    .5 .5 .5]);

%% Parameters
% main parameters
loadStats = true;
saveStats = false;

% createChannel parameters
fdT = [0.05 0.01 0.002];
T = 1e-3;
fd = fdT/T;
duration = 1e6;
nSin = 8;
durationType = 'samples';
Nchannels = 10;
interpMethod = 'pchip';
simList = {'Clarke','Jakes','PopBeaulieu','ZhengXiao2002',...
    'LiHuang','ZhengXiao2003','XiaoZhengBeaulieu',...
    'Komninakis'};
legend = simList;

% LCR/AFD parameters
thresholds = logspace(-2,.5,25)';

%% computation

if loadStats
    load('SavedData/multiLCR_AFD')
else
    for j = 1:length(fdT)
        for i = 1:length(simList)
            clear 'ch' 't'
            
            if strcmp(simList{i},'Jakes')
                [ch,t] = createChannel(fd(j),T,duration*Nchannels,simList{i},nSin,...
                    'DurationType',durationType,'NChannels',1,...
                    'InterpMethod',interpMethod);
            else
                [ch,t] = createChannel(fd(j),T,duration,simList{i},nSin,...
                    'DurationType',durationType,'NChannels',Nchannels,...
                    'InterpMethod',interpMethod);
            end
            
            LCR(i,j) = computeLCR(ch,t(end)-t(1),thresholds);
            AFD(i,j) = computeAFD(ch,t(2)-t(1),thresholds);
        end
    end
    
    if saveStats
        save('SavedData/multiLCR_AFD','LCR','AFD')
    end
end
%% plots

figLCR = plotMultipleLCR(LCR,legend,fd); annotation('textarrow',[.54 .49],[.6 .9],'String','$\uparrow f_dT$','interpreter','latex')
figAFD = plotMultipleAFD(AFD,legend,fd); annotation('textarrow',[.6 .67],[.45 .23],'String','$\uparrow f_dT$','interpreter','latex')