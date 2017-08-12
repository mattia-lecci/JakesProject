clear variables
close all
clc

addpath('Channels','Misc','Plots','SavedData','Stats')

%% Parameters
% createChannel parameters
fd = 10;
T = 0.01/fd;
duration = 1;
nSin = 8;
durationType = 'Tcoh';
Nchannels = 1e4;
interpMethod = 'pchip';
simulator = 'ZhengXiao2003';

%% Channel
tic
[ch,t] = createChannel(fd,T,duration,simulator,nSin,...
                'DurationType',durationType,'NChannels',Nchannels,...
                'InterpMethod',interpMethod);
toc