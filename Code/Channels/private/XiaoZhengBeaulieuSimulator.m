function ch = XiaoZhengBeaulieuSimulator(fd,t,nSin,nChannels)
% arg check
if mod(nSin,4)~=0
    error('Number of sinusoid must be of the form nSin=4*M for integer M');
end

%% create channels
N = nSin/4;

[omega,phi] = getVariables(fd,N,nChannels);

% init
ch = zeros( size(t,1),nChannels );

% computations
for k = 1:nChannels
    ch(:,k) = computeChannel(k);
end

%% computing function
    function ch = computeChannel(k)
        
        ch = sqrt(1/N)*(...
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