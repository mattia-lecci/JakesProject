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
T = 1e-3;
fd = 0.01/T;
durPdf = 1; durZH03 = 100; durCorr = 10; durJakes = 1e7; durLA = 1e6; % different durations
nSin = 8;
DTpdf = 'samples'; DTCorr = 'Tcoh'; DTJakes = 'samples'; DTLA = 'samples'; % different duration types
NchPdf = 1e7; NchZH03 = 1e5; NchCorr = 1e5; NchLA = 1e1; % different #channels
interpMethod = 'pchip';
simList = {'Clarke','Jakes','PopBeaulieu','ZhengXiao2002',...
    'LiHuang','ZhengXiao2003','XiaoZhengBeaulieu',...
    'Komninakis'};
legend = simList;

% computeAllStats parameters
pdfInd = [];
binMethod = 'auto';
maxTcohLag = 10; % max lag for xcorr in Tcoh
thresholds = logspace(-2,.5,25)';

% computeSimulationTime parameters
% simList,... same as createChannel
precision = .1;
NsamplesList = round( logspace(3,7,25)' );
precisionType = '%';


%% Stats
maxlag = 1/(fd*T)*maxTcohLag;

if loadStats
    load('SavedData/stats');
else
    for i = 1:length(simList)
        % log
        fprintf('%2d/%2d: %s\n',i,length(simList),simList{i});
        
        if strcmp(simList{i},'Jakes')
            % pdf
            clear 'ch' 't'
            ch = createChannel(fd,T,durJakes,simList{i},nSin,...
                'DurationType',DTJakes,'NChannels',1,...
                'InterpMethod',interpMethod);
            
            stats(i).pdf = computePdf(ch.',1,binMethod,false);
            
            % xcorr
            clear 'ch' 't'
            [ch,t] = createChannel(fd,T,durJakes,simList{i},nSin,...
                'DurationType',DTJakes,'NChannels',1,...
                'InterpMethod',interpMethod);
            
            stats(i).xcorr = computeXcorr(ch,t,maxlag,'Jakes');
            
            % LCR/AFD
            clear 'ch' 't'
            [ch,t] = createChannel(fd,T,durJakes,simList{i},nSin,...
                'DurationType',DTJakes,'NChannels',1,...
                'InterpMethod',interpMethod);
            
            stats(i).LCR = computeLCR(ch,t(end)-t(1),thresholds);
            stats(i).AFD = computeAFD(ch,t(2)-t(1),thresholds);
        else
            if strcmp(simList{i},'ZhengXiao2003')
                % pdf
                clear 'ch' 't'
                ch = createChannel(fd,T,durZH03,simList{i},nSin,...
                    'DurationType',DTpdf,'NChannels',NchZH03,...
                    'InterpMethod',interpMethod);
                
                stats(i).pdf = computePdf(ch,durZH03,binMethod,false);
            else
                % pdf
                clear 'ch' 't'
                ch = createChannel(fd,T,durPdf,simList{i},nSin,...
                    'DurationType',DTpdf,'NChannels',NchPdf,...
                    'InterpMethod',interpMethod);
                
                stats(i).pdf = computePdf(ch,1,binMethod,false);
            end
            
            % xcorr
            clear 'ch' 't'
            [ch,t] = createChannel(fd,T,durCorr,simList{i},nSin,...
                'DurationType',DTCorr,'NChannels',NchCorr,...
                'InterpMethod',interpMethod);
            
            stats(i).xcorr = computeXcorr(ch,t,maxlag);
            
            % LCR/AFD
            clear 'ch' 't'
            [ch,t] = createChannel(fd,T,durLA,simList{i},nSin,...
                'DurationType',DTLA,'NChannels',NchLA,...
                'InterpMethod',interpMethod);
            
            stats(i).LCR = computeLCR(ch,t(end)-t(1),thresholds);
            stats(i).AFD = computeAFD(ch,t(2)-t(1),thresholds);
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
xcorrFig = plotXcorr([stats.xcorr],legend,fd);
LCRFig = plotLCR([stats.LCR],legend,fd);
AFDFig = plotAFD([stats.AFD],legend,fd);
SimTimeFig = plotSimulationTime(samples,time,legend);