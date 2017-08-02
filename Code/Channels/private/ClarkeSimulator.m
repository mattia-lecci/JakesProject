function ch = ClarkeSimulator(fd,t,nSin,nChannels)
% Reference B1, Eq. (1)

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
        
        ch = sqrt(1/nSin)*sum(...
            exp( 1j*( omega(k,:).*t + phi(k,:) ))...
                                ,2);

    end

end

%% Utility functions

function [omega,phi] = getVariables(fd,N,nChannels)

% useful variables
alpha = 2*pi*rand(nChannels,N);

% varialbes
omega = 2*pi*fd*cos(alpha);
phi = 2*pi*rand(nChannels,N);

end