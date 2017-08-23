function figures = plotPdf(PDF,legend)
%PLOTPDF Plots probability distribution functions given as output from
%computePdf
%
% figures = PLOTPDF(PDF,legend) Plots all of the precalculated PDFs from the
%   function computePdf, plotting first a thick black line representing the
%   ideal case, and then all of the others containined in the array of struct
%   PDF. The input legend should contain a cell array of strings containing
%   the legend with the same order (and number of elements) of PDF.
%
% Plots the fitted Rayleigh distributions of the magnitude and the line
% version of the histogram of both the magnitude and phase.
%
% OUTPUT: figures is a structure with fields:
% - figures.magFitFigure
% - figures.magHistFigure
% - figures.phaseHistFigure
% Each of them contains a reference to the plot's figure.
%
% See also: COMPUTEPDF

% arg check
p = inputParser;
inputCheck();

% init
legend = {legend{:}}; % row

%% Plots
[figures.magFitFigure,figures.magHistFigure] =...
    plotMagnitude([PDF.magnitude],legend);
figures.phaseHistFigure = plotPhase([PDF.phase],legend);

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
magSubfieldsReduced = {'normBinCount','edges'};
phaseSubfields = {'normBinCount','edges'};

% check fields
if isvector(PDF)
    
    fieldsOk = isfield(PDF(1),fields);
    if all(fieldsOk)

        magSub1Ok = isfield(PDF(1).magnitude,magSubfields);
        magSub2Ok = isfield(PDF(1).magnitude,magSubfieldsReduced);
        phaseSubOk = isfield(PDF(1).phase,phaseSubfields);

        magSubOk = all(magSub1Ok) || all(magSub2Ok);
        
        b = all( [magSubOk,phaseSubOk] );

    else
        b = false;
    end
else
    b = false;
end

end

% ----------------------------------------------------------------------

function [magFitFig,magHistFig] = plotMagnitude(mag,leg)
% init
Xlim = [0 3];
ideal = makedist('Rayleigh','b',1/sqrt(2));

%% Plot fit
if isfield(mag,'fit')
    
    magFitFig = figure;
    fplot(@ideal.pdf,Xlim,'k','LineWidth',1.5);
    hold on; grid on
    
    % plot given pdfs
    for i = 1:length(mag)
        fittedDistrib = mag(i).fit;
        fplot(@fittedDistrib.pdf,Xlim);
    end
    
    hold off
    
    % plot aesthetic
    title('Fitted Magnitude PDFs','Interpreter','latex','FontSize',18)
    xlabel('a','Interpreter','latex')
    ylabel('f(a)','Interpreter','latex')
    
    legend( [{'Ideal'}, leg] );
else
    magFitFig = [];
end

%% Plot hitogram
% ideal pdf
magHistFig = figure;
fplot(@ideal.pdf,Xlim,'k','LineWidth',1.5);
hold on; grid on

% plot given histograms
plotHistogram({mag.normBinCount},{mag.edges});
hold off

% plot aesthetic
title('Histogram Magnitude PDFs','Interpreter','latex','FontSize',18)
xlabel('a','Interpreter','latex')
ylabel('f(a)','Interpreter','latex')
xlim(Xlim)

legend(['Ideal',leg])

end

% -----------------------------------------------------------------------
function phaseFig = plotPhase(ph,leg)

% ideal
phaseFig = figure;
fplot(@(x) 0*x+1/(2*pi),[-pi, pi],'k','LineWidth',1.5);
hold on; grid on

% plot given histograms
plotHistogram({ph.normBinCount},{ph.edges});
hold off

% plot aesthetic
title('Histogram Phase PDFs','Interpreter','latex','FontSize',18)
xlabel('$\theta$','Interpreter','latex')
ylabel('f($\theta$)','Interpreter','latex')
xlim([-pi,pi])
ylim([0, .25])

legend(['Ideal',leg])
end

% ----------------------------------------------------------------------
function  plotHistogram(binval,edges)

% init
centers = getBinCenters(edges);

for i = 1:length(binval)
    plot(centers{i},binval{i});
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