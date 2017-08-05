function ch = XiaoZhengBeaulieuSimulator(fd,t,nSin,nChannels)
% Reference B1, Eq.s (6),(18)
%
% See also: CREATECHANNEL

%% create channels
[omega,phi] = getVariables(fd,nSin,nChannels);

% init
ch = zeros( size(t,1),nChannels );

% computations
for k = 1:nChannels
    ch(:,k) = computeChannel(k);
end

%% computing function
    function ch = computeChannel(k)
        
        ch = sqrt(1/nSin)*(...
            sum( cos( omega(k,:).*t + phi(k,:) ) ,2) +...
         1j*sum( sin( omega(k,:).*t + phi(k,:) ) ,2)...
                                );

    end

end

%% Utility functions

function [omega,phi] = getVariables(fd,N,nChannels)

% init
n = 1:N;

% support variables
theta = 2*pi*rand(nChannels,N) - pi;
alpha = ( 2*pi*n+theta )/N;

% variables
omega = 2*pi*fd*cos(alpha);
phi = 2*pi*rand(nChannels,N) - pi;

end