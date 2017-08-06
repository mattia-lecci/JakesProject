clear variables
close all
clc

addpath('Channels','Misc','Plots','SavedData','Stats')

%% Parameters
% main parameters
loadMat = false;
saveMat = false;
calcStats = false;
calcTime = true;

% createChannel parameters
fd = 10;
T = .01;
duration = 10;
nSin = 8;
durationType = 'Tcoh';
Nchannels = 1e3;
interpMethod = 'spline';
simList = {'Clarke','Jakes','PopBeaulieu','LiHuang',...
            'ZhengXiao2002','ZhengXiao2003','XiaoZhengBeaulieu',...
            'Komninakis'};
legend = simList;

% computeAllStats parameters
pdfInd = [];
binMethod = 'auto';
maxlag = [];
thresholds = logspace(-3,1,25)';

% computeSimulationTime parameters
% simList,... same as createChannel
precision = .1;
NsamplesList = round( logspace(3,6,20)' );


%% Stats

if calcStats
    for i = 1:length(simList)
        if loadMat
            load('SavedData/stats'); %#ok<UNRCH>
        else
            [ch,t] = createChannel(fd,T,duration,simList{i},nSin,...
                'DurationType','Tcoh','NChannels',Nchannels,'InterpMethod',interpMethod);
            
            % check validity of possibly empty parameters
            if isempty(pdfInd)
                pdfInd = size(ch,1);
            end
            if isempty(maxlag)
                maxlag = size(ch,1)-1;
            end
            
            stats(i) = computeAllStats(ch,t,'pdfInd',pdfInd,...
                'binMethod',binMethod,'maxlag',maxlag,'thresholds',thresholds); %#ok<SAGROW>
            
            
            if saveMat
                save('SavedData/stats'); %#ok<UNRCH>
            end
        end
    end
end

% free some memory
clear 'ch' 't'

if calcTime
    if loadMat %#ok<UNRCH>
        load('SavedData/simTime'); 
    else
        [samples,time] = computeSimulationTime(simList,precision,NsamplesList,...
            'fd',fd,'T',T,'nSin',nSin,'interpMethod',interpMethod); 
        
        
        if saveMat
            save('SavedData/simTime'); 
        end
    end
end

%% Plots

pdfPlots = plotPdf([stats.pdf],legend);
xcorrPlots = plotXcorr([stats.xcorr],legend,fd,T);
LCRPlots = plotLCR([stats.LCR],legend,fd);
AFDPlots = plotAFD([stats.AFD],legend,fd);
%SimTimePlots = plotSimulationTime(samples,time,legend);