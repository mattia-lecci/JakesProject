function ch = PopBeaulieuSimulator(fd,t,nSin,nChannels)
% Reference A1, Eq. (24)

% arg check
if mod(nSin-2,4)~=0
    error('Number of sinusoid must be of the form nSin=4M+2 for integer M');
end

%% create channels
M = (nSin-2)/4;
n = 1:M;

[B,Psi,omega]= getVariables(M,fd,nChannels);

% init
ch = zeros( size(t,1),nChannels );
cosine = cos( omega.*t); % avoid computing this for every channel
sine = sin( omega.*t); % avoid computing this for every channel

% computations
for k = 1:nChannels
    ch(:,k) = computeChannel(k);
end

%% computing function
    function ch = computeChannel(k)
        cos_m = cosine(:,end)*cos( Psi(k,end) ) -...
            sine(:,end)*sin( Psi(k,end) );
        cos_n = cosine(:,n).*cos( Psi(k,n) ) -...
            sine(:,n).*sin( Psi(k,n) );

        X2c = 2/sqrt(nSin)*( cos(B(end))*cos_m +...
                            sqrt(2)*sum( cos(B(n)).*cos_n ,2) );
        X2s = 2/sqrt(nSin)*( sin(B(end))*cos_m +...
                            sqrt(2)*sum( sin(B(n)).*cos_n ,2) );

        ch = X2c + 1j*X2s;
    end

end

%% Utility functions

function [B,Psi,omega]= getVariables(M,fd,nChannels)
N = 4*M+2;
n = 1:M;

% init
B = zeros(1,M+1);
omega = B;

% omega
omega(n) = 2*pi*fd*cos( 2*pi*n/N );
omega(end) = 2*pi*fd;

% Psi
Psi = 2*pi*rand(nChannels,M+1);

% B
B(n) = pi*n/M;
B(end) = pi/4;

end
