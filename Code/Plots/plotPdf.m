function [magFitPlot,magHistPlot,phaseHistPlot] = plotPdf(PDF,legend)

% arg check
p = inputParser;
inputCheck();

%% Plots
[magFitPlot,magHistPlot] = plotMagnitude([PDF.magnitude],legend);
phaseHistPlot = plotPhase([PDF.phase],legend);

%% Argument checker
    function inputCheck()
        
        p.addRequired('PDF',@(x)checkPdfStruct(x));
        p.addRequired('legend',@(x)iscellstr(x));
        
        p.parse(PDF,legend);
        
        % further check
        validateattributes(legend,{'cell'},{'numel',length(PDF)});

    end
end


%% Utility functions

function b = checkPdfStruct(PDF)

% field lists
fields = {'magnitude','phase'};
magSubfields = {'fit','normBinCount','edges'};
phaseSubfields = {'normBinCount','edges'};

% check fields
fieldsOk = isfield(PDF,fields);
if all(fieldsOk)
    
    magSubOk = isfield(PDF.magnitude,magSubfields);
    phaseSubOk = isfield(PDF.phase,phaseSubfields);
    isVec = isvector(PDF);
    
    b = all( [magSubOk,phaseSubOk,isVec] );
    
else
    b = false;
end

end

% ----------------------------------------------------------------------

function [magFitPlot,magHistPlot] = plotMagnitude(mag,leg)

%% Plot fit
% init
Xlim = [0 3];

% ideal pdf
ideal = makedist('Rayleigh','b',1/sqrt(2));

figure
magFitPlot(1) = fplot(@ideal.pdf,Xlim,'k','LineWidth',1.5);
hold on; grid on

% plot given pdfs
for i = 1:length(mag)
    fittedDistrib = mag(i).fit;
    magFitPlot(i+1) = fplot(@fittedDistrib.pdf,Xlim); %#ok<AGROW>
end

hold off

% plot aesthetic
title('Fitted Magnitude PDFs')
xlabel('a')
ylabel('f(a)')

legend( [{'Ideal'}, leg] );

%% Plot hitogram
% ideal pdf
figure
magHistPlot(1) = fplot(@ideal.pdf,Xlim,'k','LineWidth',1.5);
hold on; grid on

% plot given histograms
magHistPlot(2:length(mag)+1) = plotHistogram({mag.normBinCount},{mag.edges});
hold off

% plot aesthetic
title('Histogram Magnitude PDFs')
xlabel('a')
ylabel('f(a)')
xlim(Xlim)

legend(['Ideal',leg])

end

% -----------------------------------------------------------------------
function phasePlot = plotPhase(ph,leg)

% ideal
figure
phasePlot(1) = plot([-pi,pi],[1 1]/(2*pi),'k','LineWidth',1.5);
hold on; grid on

% plot given histograms
phasePlot(2:length(ph)+1) = plotHistogram({ph.normBinCount},{ph.edges});
hold off

% plot aesthetic
title('Histogram Phase PDFs')
xlabel('\theta')
ylabel('f(\theta)')
xlim([-pi,pi])
ylim([0, .25])

legend(['Ideal',leg])
end

% ----------------------------------------------------------------------
function plots = plotHistogram(binval,edges)

% init
centers = getBinCenters(edges);

for i = 1:length(binval)
    plots(i) = plot(centers{i},binval{i});
end

end
% ---------------------------------------------------------------------
function centers = getBinCenters(edges)

% init
centers = cell(1,length(edges));

for i = 1:length(edges)
    centers{i} = getCenters(i);
end

    function c = getCenters(i)
        d = diff( edges{i} );
        c = edges{i}(1:end-1) + d/2;
    end
end