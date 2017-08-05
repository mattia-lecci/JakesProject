function plots = plotAFD(AFD,legend,fd,varargin)
%PLOTAFD Plots the Average Fade Duration given as output from computeAFD
%
% plots = PLOTAFD(AFD,legend,fd) Plots all of the precalculated AFD from the
%   function computeAFD, plotting first a thick black line representing the
%   ideal case, and then all of the others containined in the array of struct
%   AFD. The input legend should contain a cell array of strings containing
%   the legend with the same order (and number of elements) of AFD. Finally,
%   fd is the maximum doppler frequency used to create the channels (it must
%   be the same for all of them).
% plots = PLOTAFD(AFD,legend,fd,RMS) If the channel had a different RMS
%   from 1, you can specify it as the fourth input.
%
% OUTPUT: plots is a vector with length(AFD)+1 number of elements. The
%   first element is a FunctionLine object handle (Ideal case), and the
%   others in order contain Line object handles in order for each of the
%   elements in AFD.
%
% See also: COMPUTEAFD

% arg check
p = inputParser;
inputCheck();

% name inputs
RMS = p.Results.RMS;

%% Plot
plots = plotafd(AFD,legend,fd,RMS);

%% Argument checker
    function inputCheck()
        
        p.addRequired('AFD',@(x)checkAfdStruct(x));
        p.addRequired('legend',@(x)iscellstr(x));
        p.addRequired('fd',...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        p.addOptional('RMS',1,...
            @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
        
        p.parse(AFD,legend,fd,varargin{:});
        
        % further check
        validateattributes(legend,{'cell'},{'numel',length(AFD)});

    end
end

%% Utility functions

function b = checkAfdStruct(AFD)

% field lists
fields = {'values','thresh','stdev'};

% check fields
fieldsOk = isfield(AFD,fields);
vecOk = isvector(AFD);

b = all([fieldsOk,vecOk]);

end

% ------------------------------------------------------------------------
function plots = plotafd(AFD,leg,fd,RMS)

% init
Xlim = 20*log10( [min(AFD.thresh) max(AFD.thresh)] );

% ideal
lam = @(x) 10.^(x/20);
ideal = @(x) ( exp(lam(x).^2)-1 )./( sqrt(2*pi)*fd*lam(x) );
plots(1) = fplot(ideal,Xlim,'k','LineWidth',1.5);
hold on; grid on;

% computed LCR
for i = 1:length(AFD)
    lambda = 20*log10(AFD(i).thresh/RMS);
    plots(i+1) = plot(lambda,AFD(i).values); %#ok<AGROW>
end
hold off

% aesthetic
title('Average Fade Duration')
xlabel('\lambda_{dB}')
ylabel('AFD(\lambda)')

legend(['Ideal',leg]);

% use log in y coordinate
ax = gca;
ax.YScale = 'log';
end