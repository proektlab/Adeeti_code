%8/2/2016
%Setup movie playback of all 20 natural noise movies back-to-back using
%GaplessMoviePlayBack demo,with TTLs being sent out for each frame. PTB
%reports no missed frames. Here I'll check the jitter of the TTLs.
%Inter-frame-interval should be 16.6 ms (60 Hz refresh).

%% init
clc
clear all
close all

%% load the data
dirData='\\CONTRERASNAS\contreras_shared\MOUSE DATA\1August2016_timing\';

%load Events
[EV_Timestamps, ~, EV_TTLs, ~] = LoadEVs(dirData); %EV_Timestamps is in unis of uSeconds (FS=1e6)

%% Check the jitter by looking at inter-TTL time of TTLs (should be consistently 16.66 ms)
%get the timestamp of TTLs
TTLhigh_ind=find(EV_TTLs==2);
TTLhigh_time=EV_Timestamps(TTLhigh_ind);

%The stimulus changed contrast on every frame, which was refreshed at 60
%cycles per second, and indicated by a TTL going high (for 5 ms), then
%coming back down. The first thing to check is the consistency of the TTL
%on-times, independent of the photodiode.

%check the inter-TTL time (shuld be consistent at 16.66 ms)
ISI_TTL=(1/1000).*diff(TTLhigh_time);

figure; 
plot(ISI_TTL,'r*');
xlabel('Presentation Number'); ylabel('Inter Frame Interval (ms)');
title('Inter Frame Interval for frame refresh rate of 60 Hz');
%Looks like except for the first frame, jitter is less than 0.3 ms!

mean_isi=mean(ISI_TTL(2:end)); 
std_isi=std(ISI_TTL(2:end));

display(['Mean inter-frame interval is: ', num2str(mean_isi,'%6.2f'), ' ms, and std is: ', num2str(std_isi,'%6.2f'),' ms.']);