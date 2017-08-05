function ch = ZhengXiao2002Simulator(fd,t,nSin,nChannels)
% Reference C2, Eq. (8)
%
% See also: CREATECHANNEL

%% create channels
[alpha,phi,phi1] = getVariables(nSin,nChannels);

% init
ch = zeros( size(t,1),nChannels );

% computations
for k = 1:nChannels
    ch(:,k) = computeChannel(k);
end

%% computing function
    function ch = computeChannel(k)
        
        ch = sqrt(1/nSin)*(...
            sum( cos( 2*pi*fd*cos( alpha(k,:) ).*t + phi(k,:) ) ,2) +...
         1j*sum( cos( 2*pi*fd*sin( alpha(k,:) ).*t + phi1(k,:) ) ,2)...
                                );

    end

end

%% Utility functions

function [alpha,phi,phi1] = getVariables(M,nChannels)

% init
n = 1:M;

% support variables
theta = 2*pi*rand(nChannels,1) - pi;

% variables
alpha = ( 2*pi*n-pi+theta )/(4*M);
phi = 2*pi*rand(nChannels,M) - pi;
phi1 = 2*pi*rand(nChannels,M) - pi;

end