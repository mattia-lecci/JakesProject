function ch = LiHuangSimulator(fd,t,nSin,nChannels)
% Reference C1, Eq. (15)
%
% See also: CREATECHANNEL

%% create channels
[omega,phic,phis] = getVariables(fd,nSin,nChannels);

% init
ch = zeros( size(t,1),nChannels );

% computations
for k = 1:nChannels
    ch(:,k) = computeChannel(k);
end

%% computing function
    function ch = computeChannel(k)
        
        ch = sqrt(1/nSin)*sum(...
            cos( omega(k,:).*t + phic(k,:) ) +...
         1j*sin( omega(k,:).*t + phis(k,:) )...
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