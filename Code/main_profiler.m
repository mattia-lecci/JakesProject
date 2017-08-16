clear variables
close all
clc

addpath('Channels','Misc','Plots','SavedData','Stats')

%% Parameters
% createChannel parameters
fd = 10;
T = 0.01/fd;
duration = 2e6;
nSin = 8;
durationType = 'samples';
Nchannels = 100;
interpMethod = 'pchip';
simulator = 'Komninakis';

%% Channel
tic
[ch,t] = createChannel(fd,T,duration,simulator,nSin,...
                'DurationType',durationType,'NChannels',Nchannels,...
                'InterpMethod',interpMethod);
toc