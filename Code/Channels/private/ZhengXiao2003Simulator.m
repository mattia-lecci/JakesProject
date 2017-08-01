function ch = ZhengXiao2003Simulator(fd,t,nSin,nChannels)
% arg check
if mod(nSin,4)~=0
    error('Number of sinusoid must be of the form nSin=4*M for integer M');
end

%% create channels
M = nSin/4;

[omega,psi,phi] = getVariables(fd,M,nChannels);

% init
ch = zeros( size(t,1),nChannels );

% computations
for k = 1:nChannels
    ch(:,k) = computeChannel(k);
end

%% computing function
    function ch = computeChannel(k)
        
        ch = sqrt(2/M)*(...
            sum( cos( psi(k,:) ).*cos( omega(k,:).*t + phi(k) ) ,2) +...
         1j*sum( sin( psi(k,:) ).*cos( omega(k,:).*t + phi(k) ) ,2)...
                                );

    end

end

%% Utility functions

function [omega,psi,phi] = getVariables(fd,M,nChannels)

% init
n = 1:M;

% support variables
theta = 2*pi*rand(nChannels,1) - pi;
alpha = ( 2*pi*n-pi+theta )/(4*M);

% variables
omega = 2*pi*fd*cos(alpha);
psi = 2*pi*rand(nChannels,M) - pi;
phi = 2*pi*rand(nChannels,1) - pi;

end