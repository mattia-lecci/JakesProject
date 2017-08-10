clear variables
close all
clc

addpath('Channels','Misc','Plots','SavedData','Stats')

%% Parameters
% main parameters
loadStats =     true;
loadSimTime =   true;
saveStats =     false;
saveSimTime =   false;

% createChannel parameters
fd = 10;
T = .01;
duration = 10; durationJakes = 1e4;
nSin = 8;
durationType = 'Tcoh';
Nchannels = 1e3;
interpMethod = 'pchip';
simList = {'Clarke','Jakes','PopBeaulieu','ZhengXiao2002',...
            'LiHuang','ZhengXiao2003','XiaoZhengBeaulieu',...
            'Komninakis'};
legend = simList;

% computeAllStats parameters
pdfInd = [];
binMethod = 'auto';
maxlag = 100;
thresholds = logspace(-2,.5,25)';

% computeSimulationTime parameters
% simList,... same as createChannel
precision = .1;
NsamplesList = round( logspace(3,6,20)' );
precisionType = '%';


%% Stats

if loadStats
    load('SavedData/stats');
else
    for i = 1:length(simList)
        
        switch simList{i}
            case 'Jakes'
                [ch,t] = createChannel(fd,T,durationJakes,simList{i},nSin,...
                    'DurationType',durationType,'NChannels',1,...
                    'InterpMethod',interpMethod);
            otherwise
                [ch,t] = createChannel(fd,T,duration,simList{i},nSin,...
                    'DurationType',durationType,'NChannels',Nchannels,...
                    'InterpMethod',interpMethod);
        end
        
        % check validity of possibly empty parameters
        if isempty(pdfInd)
            pdfInd = size(ch,1);
        end
        if isempty(maxlag)
            maxlag = size(ch,1)-1;
        end
        
        switch simList{i}
            case 'Jakes'
                stats(i) = computeAllStats(ch,t,'Jakes','pdfInd',1,...
                    'binMethod',binMethod,'maxlag',maxlag,'thresholds',thresholds);
            otherwise
                stats(i) = computeAllStats(ch,t,'Other','pdfInd',pdfInd,...
                    'binMethod',binMethod,'maxlag',maxlag,'thresholds',thresholds);
        end
    end
    
    
    if saveStats
        save('SavedData/stats','stats');
    end
end


% free some memory
clear 'ch' 't'

if loadSimTime
    load('SavedData/simTime');
else
    [time,samples] = computeSimulationTime(simList,precision,NsamplesList,...
        'fd',fd,'T',T,'nSin',nSin,'interpMethod',interpMethod,...
        'PrecisionType',precisionType);
    
    
    if saveSimTime
        save('SavedData/simTime','samples','time');
    end
end

%% Plots

pdfFig = plotPdf([stats.pdf],legend);
xcorrFig = plotXcorr([stats.xcorr],legend,fd,T);
LCRFig = plotLCR([stats.LCR],legend,fd);
AFDFig = plotAFD([stats.AFD],legend,fd);
SimTimeFig = plotSimulationTime(samples,time,legend);