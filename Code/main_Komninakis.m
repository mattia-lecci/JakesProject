clear variables
close all
clc

addpath('Channels','Misc','Plots','SavedData','Stats')

%% Parameters
% main parameters
loadStats =     true;
loadSimTime =   false;
saveStats =     false;
saveSimTime =   false;

% createChannel parameters
fdT = [0.05 0.01 0.002];
T = 1e-3;
fd = fdT/T;
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
thresholds = logspace(-2,.5,25)';

% computeSimulationTime parameters
% simList,... same as createChannel
precision = .1;
NsamplesList = round( logspace(3,7,25)' );
precisionType = '%';


%% Stats

if loadStats
    load('SavedData/stats_Komninakis');
else
    for ff = 1:length(fdT)
        for int = 1:length(interpMethod)
            
            [ch,t] = createChannel(fd(ff),T,duration,simulator,nSin,...
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
            ind = (ff-1)*length(interpMethod) + int;
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
    for ff = 1:length(fdT)
        for int = 1:length(interpMethod)
            
            ind = (ff-1)*length(interpMethod) + int;
            time(:,ind) = computeSimulationTime(simulator,precision,NsamplesList,...
                'fd',fd(ff),'T',T,'nSin',nSin,'interpMethod',interpMethod{int},...
                'PrecisionType',precisionType);
        end
    end
    
    
    if saveSimTime
        save('SavedData/simTime_Komninakis','NsamplesList','time');
    end
end

%% Plots
plotfd = repmat(fd,1,4);
plotfd = plotfd([1:3:12, 2:3:12, 3:3:12]);

pdfFig = plotPdf([stats.pdf],legend); changeFigureAesthetic(pdfFig,fdT,interpMethod);
xcorrFig = plotXcorr([stats.xcorr],legend,plotfd); changeFigureAesthetic(xcorrFig,fdT,interpMethod);
LCRFig = plotLCR([stats.LCR],legend,plotfd); changeFigureAesthetic(LCRFig,fdT,interpMethod);
AFDFig = plotAFD([stats.AFD],legend,plotfd); changeFigureAesthetic(AFDFig,fdT,interpMethod);
SimTimeFig = plotSimulationTime(NsamplesList,time,legend); changeFigureAesthetic(SimTimeFig,fdT,interpMethod);








%% Utility functions
function legend = getLegend(fdT,interpMethod)

% init
NfdT = length(fdT);
Nint = length(interpMethod);
n = 1:Nint;
legend = cell(NfdT*Nint,1);
% concatenate
str_int = strcat(interpMethod,', ');
for i = 1:NfdT
    legend(n) = strcat(str_int,num2str(fdT(i)));
    n = n + Nint;
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
changeFigureAesthetic(xcorrFig,fdT,interpMethod);

end
% ----------------------------------------------------------------
function changeFigureAesthetic(fig,fdT,interpMethod)

% for comodity
if isstruct(fig)
    cellFig = struct2cell(fig);
else
    cellFig{1} = fig;
end

% process every line of every figure
for i = 1:length(cellFig)
    lines = [cellFig{i}.Children.Children];
    for j = 1:length(lines)
        aesthetic( lines(j),fdT,interpMethod )
    end
end

end
%-----------------------------------------------------------------
function aesthetic(line,fdT,interpMethod)

% init
Color{1} = [217 83 25]/255; % r
Color{2} = [119 172 48]/255;% g
Color{3} = [32 132 197]/255;% b
Color{4} = [242 196 88]/255;% y

Style{1} = '-';
Style{2} = '--';
Style{3} = '-.';
Style{4} = ':';

% change aesthetic
for i = 1:length(fdT)
    if contains(line.DisplayName,num2str(fdT(i)))
        line.Color = Color{i};
    end
end

for i = 1:length(interpMethod)
    if contains(line.DisplayName,interpMethod{i})
        line.LineStyle = Style{i};
        
        if strcmp(Style{i},':')
            line.LineWidth = 1.5;
        end
    end
end

end