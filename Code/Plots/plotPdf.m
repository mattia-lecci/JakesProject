function plots = plotPdf(PDF,legend)
%PLOTPDF Plots probability distribution functions given as output from
%computePdf
%
% plots = PLOTPDF(PDF,legend) Plots all of the precalculated PDFs from the
%   function computePdf, plotting first a thick black line representing the
%   ideal case, and then all of the others containined in the array of struct
%   PDF. The input legend should contain a cell array of strings containing
%   the legend with the same order (and number of elements) of PDF.
%
% Plots the fitted Rayleigh distributions of the magnitude and the line
% version of the histogram of both the magnitude and phase.
%
% OUTPUT: plots is a structure with fields:
% - plots.magFitPlot
% - plots.magHistPlot
% - plots.phaseHistPlot
% Each of them contain an array with length(PDF)+1 elements, in which the
% first one contains a FunctionLine object handle (Ideal case), and the
% others in order contain Line (FunctionLine for magFitPlot) object handles
% in order for each of the elements in PDF.
%
% See also: COMPUTEPDF

% arg check
p = inputParser;
inputCheck();

%% Plots
[plots.magFitPlot,plots.magHistPlot] =...
    plotMagnitude([PDF.magnitude],legend);
plots.phaseHistPlot = plotPhase([PDF.phase],legend);

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
if isvector(PDF)
    
    fieldsOk = isfield(PDF(1),fields);
    if all(fieldsOk)

        magSubOk = isfield(PDF(1).magnitude,magSubfields);
        phaseSubOk = isfield(PDF(1).phase,phaseSubfields);


        b = all( [magSubOk,phaseSubOk] );

    else
        b = false;
    end
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
    plots(i) = plot(centers{i},binval{i}); %#ok<AGROW>
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