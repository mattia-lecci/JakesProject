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
fd = 20;
fdT = [0.05 0.01 0.002];
T = fdT/fd;
duration = 10;
nSin = 8;
durationType = 'Tcoh';
Nchannels = 1e3;
interpMethod = {'spline','pchip','linear','filter'};
simulator = 'Komninakis';
legend = getLegend(fdT,interpMethod);

% computeAllStats parameters
pdfInd = [];
binMethod = 'auto';
maxlag = [];
thresholds = logspace(-1.5,.5,25)';

% computeSimulationTime parameters
% simList,... same as createChannel
precision = .1;
NsamplesList = round( logspace(3,6,20)' );
precisionType = '%';


%% Stats

if loadStats
    load('SavedData/stats_Komninakis');
else
    for tt = 1:length(T)
        for int = 1:length(interpMethod)
            
            [ch,t] = createChannel(fd,T(tt),duration,simulator,nSin,...
                'DurationType',durationType,'NChannels',Nchannels,...
                'InterpMethod',interpMethod{int});
            
            % check validity of possibly empty parameters
            if isempty(pdfInd)
                pdfInd = size(ch,1);
            end
            if isempty(maxlag)
                maxlag = size(ch,1)-1;
            end
            
            % stats
            ind = (int-1)*length(T) + tt;
            stats(ind) = computeAllStats(ch,t,'Other','pdfInd',pdfInd,...
                'binMethod',binMethod,'maxlag',maxlag,'thresholds',thresholds);
        end
        maxlag = [];
    end
    
    
    if saveStats
        save('SavedData/stats_Komninakis','stats');
    end
end


%% free some memory
clear 'ch' 't'

%% Simulation time
time = zeros(length(NsamplesList),...
    length(T)*length(interpMethod));

if loadSimTime
    load('SavedData/simTime_Komninakis');
else
    for t = 1:length(T)
        for int = 1:length(interpMethod)
            
            ind = (int-1)*length(T) + t;
            time(ind,:) = computeSimulationTime(simulator,precision,NsamplesList,...
                'fd',fd,'T',T(t),'nSin',nSin,'interpMethod',interpMethod{int},...
                'PrecisionType',precisionType);
        end
    end
    
    
    if saveSimTime
        save('SavedData/simTime_Komninakis','samples','time');
    end
end

%% Plots

pdfFig = plotPdf([stats.pdf],legend);

xcorrFig = plotAllXcorr(fdT,interpMethod,stats,legend,fd,T);

LCRFig = plotLCR([stats.LCR],legend,fd); changeFigureAesthetic(LCRFig,fdT,interpMethod);
AFDFig = plotAFD([stats.AFD],legend,fd); changeFigureAesthetic(AFDFig,fdT,interpMethod);
SimTimeFig = plotSimulationTime(samples,time,legend); changeFigureAesthetic(SimTimeFig,fdT,interpMethod);

%% Utility functions
function legend = getLegend(fdT,interpMethod)

% init
NfdT = length(fdT);
Nint = length(interpMethod);

n = 1:NfdT;
legend = cell(NfdT*Nint,1);

% concatenate
str_fdT = strcat({'f_dT='},num2str(fdT'),', ');

for i = 1:Nint
    legend(n) = strcat(str_fdT,interpMethod{i});
    n = n + NfdT;
end

% row
legend = {legend{:}};

end
%---------------------------------------------------------------------
function xcorrFig = plotAllXcorr(fdT,interpMethod,stats,legend,fd,T)

% xcorr with different T
NfdT = length(fdT);
Nint = length(interpMethod);
n = 1:NfdT:Nint*NfdT;

% first plot
xcorrFig = plotXcorr([stats(n).xcorr],legend(n),fd,T(1));
n = n+1;

% successive plots
for i = 2:NfdT
    plotXcorr([stats(n).xcorr],legend(n),fd,T(i),xcorrFig);
    n = n+1;
end

% aesthetic
cellFig = struct2cell(xcorrFig); % for comodity
for i = 1:length(cellFig)
    
    changeFigureAesthetic(cellFig{i},fdT,interpMethod);

end

end
% ----------------------------------------------------------------
function changeFigureAesthetic(fig,fdT,interpMethod)

lines = [fig.Children.Children];
for i = 1:length(lines)
    aesthetic( lines(i),fdT,interpMethod )
end

end
%-----------------------------------------------------------------
function aesthetic(line,fdT,interpMethod)

% init
Color{1} = [1 0 0];
Color{2} = [0 1 0];
Color{3} = [0 0 1];

Style{1} = '-';
Style{2} = '--';
Style{3} = ':';
Style{4} = '-.';

% change aesthetic
for i = 1:length(fdT)
    if contains(line.DisplayName,num2str(fdT(i)))
        line.Color = Color{i};
    end
end

for i = 1:length(interpMethod)
    if contains(line.DisplayName,interpMethod{i})
        line.LineStyle = Style{i};
    end
end

end