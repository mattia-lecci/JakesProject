clear variables
close all
clc

addpath('Channels','Misc','Plots','SavedData','Stats')

%% Parameters
% createChannel parameters
fd = 10;
T = 0.01/fd;
duration = 1e7;
nSin = 8;
durationType = 'samples';
Nchannels = 1;
interpMethod = 'pchip';
simulator = 'Clarke';

%% Channel
tic
[ch,t] = createChannel(fd,T,duration,simulator,nSin,...
                'DurationType',durationType,'NChannels',Nchannels,...
                'InterpMethod',interpMethod);
toc