function ch = LiHuangSimulator(fd,t,nSin,nChannels)
% arg check
if mod(nSin,4)~=0
    error('Number of sinusoid must be of the form nSin=4*N0 for integer N0');
end

%% create channels
N0 = nSin/4;

[omega,phi,phi1] = getVariables(fd,N0,nChannels);

% init
ch = zeros( size(t,1),nChannels );

% computations
for k = 1:nChannels
    ch(:,k) = computeChannel(k);
end

%% computing function
    function ch = computeChannel(k)
        
        ch = sqrt(1/N0)*sum(...
            cos( omega(k,:).*t + phi(k,:) ) +...
         1j*sin( omega(k,:).*t + phi1(k,:) )...
                                ,2);
    end

end

%% Utility functions

function [omega,phi,phi1] = getVariables(fd,N0,M)

% init
N = 4*N0;
[n,k] = meshgrid(0:N0-1,0:M-1);
alpha00 = pi/(2*M*N); % li-huang's decision

% variables
alpha = 2*pi*n/N + 2*pi*k/(M*N) + alpha00;

omega = 2*pi*fd*cos(alpha);
phi = 2*pi*rand(M,N0);
phi1 = 2*pi*rand(M,N0);

end