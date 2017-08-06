function plots = plotLCR(LCR,legend,fd,varargin)
%PLOTLCR Plots the Level Crossing Rate given as output from computeLCR
%
% plots = PLOTLCR(LCR,legend,fd) Plots all of the precalculated LCR from the
%   function computeLCR, plotting first a thick black line representing the
%   ideal case, and then all of the others containined in the array of struct
%   LCR. The input legend should contain a cell array of strings containing
%   the legend with the same order (and number of elements) of LCR. Finally,
%   fd is the maximum doppler frequency used to create the channels (it must
%   be the same for all of them).
% plots = PLOTLCR(LCR,legend,fd,RMS) If the channel had a different RMS
%   from 1, you can specify it as the fourth input.
%
% OUTPUT: plots is a vector with length(LCR)+1 number of elements. The
%   first element is a FunctionLine object handle (Ideal case), and the
%   others in order contain Line object handles in order for each of the
%   elements in LCR.
%
% See also: COMPUTELCR

% arg check
p = inputParser;
inputCheck();

% name inputs
RMS = p.Results.RMS;

%% Plot
plots = plotlcr(LCR,legend,fd,RMS);

%% Argument checker
    function inputCheck()
        
        p.addRequired('LCR',@(x)checkLcrStruct(x));
        p.addRequired('legend',@(x)iscellstr(x));
        p.addRequired('fd',...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        p.addOptional('RMS',1,...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        
        p.parse(LCR,legend,fd,varargin{:});
        
        % further check
        validateattributes(legend,{'cell'},{'numel',length(LCR)});

    end
end

%% Utility functions

function b = checkLcrStruct(LCR)

% field lists
fields = {'values','thresh','stdev'};

% check fields
fieldsOk = isfield(LCR,fields);
vecOk = isvector(LCR);

b = all([fieldsOk,vecOk]);

end

% ------------------------------------------------------------------------
function plots = plotlcr(LCR,leg,fd,RMS)

% init
Xlim = 20*log10( [min(LCR(1).thresh) max(LCR(1).thresh)] );

% ideal
lam = @(x) 10.^(x/20);
ideal = @(x) sqrt(2*pi)*fd*lam(x).*exp(-lam(x).^2);

figure
plots(1) = fplot(ideal,Xlim,'k','LineWidth',1.5);
hold on; grid on;

% computed LCR
for i = 1:length(LCR)
    lambda = 20*log10(LCR(i).thresh/RMS);
    plots(i+1) = plot(lambda,LCR(i).values); %#ok<AGROW>
end
hold off

% aesthetic
title('Level Crossing Rate')
xlabel('\lambda_{dB}')
ylabel('LCR(\lambda)')

legend(['Ideal',leg]);

% use log in y coordinate
ax = gca;
ax.YScale = 'log';
end