% GOAL : Compare the data from LSL-Kinect 
%       -- XDF file : LSL.xdf
%       -- CSV file : MoCap.csv

clear all ; 
close all ; 
clc

% manually select a file 
% [fileName, pathName] = uigetfile('../DAT/*.xdf', 'Navigate to the XDF file to open:'); 


fullFileNameXDF = fullfile('../DAT/', 'LSL.xdf');
fullFileNameCSV = fullfile('../DAT/', 'MoCap.csv');

% inform the user (it migh take a few seconds to complete) 
disp(strcat( 'loading: ', fullFileNameXDF, '...'));

% load the file (this might take sometimes if big xdf and no mex file) 
% 'HandleJitterRemoval', true ==> **** not the RAW DATA *****
streams = load_xdf(fullFileNameXDF, 'HandleJitterRemoval', false);

disp(strcat( 'loading: ', fullFileNameCSV, '...'));
M = importKinectCSV(fullFileNameCSV); 

%CheckXDF(streams, 'noFigures'); 

searchedName = 'EuroMov-Mocap-Kinect'; 
iStreamMocap = findStreamByName(streams, searchedName); 

TimeXDF = streams{1, iStreamMocap}.time_stamps'; 
TimeXDFdata = streams{1, iStreamMocap}.time_series(1,:)'; 
TimeCSV = M(:,1); 

TimeCSV     = TimeCSV     ./ 1000; % to get seconds 
TimeXDFdata = TimeXDFdata ./ 1000; % to get seconds 

figure(200); clf;
subplot(2,1,1) 
plot(TimeCSV - TimeXDFdata) 
title('TimeCSV - TimeXDFdata (should be equal)')
subplot(2,1,2) 
delay = (TimeCSV-TimeCSV(1)) - (TimeXDF-TimeXDF(1)); 
delay = delay * 1000; % ms 
plot(delay) 
title('TimeCSV - TimeXDF (jitter in network tranmission)')
ylabel('delay (milisecond)')

% display the head of the datasets for visual comparison 
format longG
ToDisp = 10; 
disp('[TimeXDF(1:ToDisp), TimeCSV(1:ToDisp), TimeXDFdata(1:ToDisp)]') 
disp([TimeXDF(1:ToDisp), TimeCSV(1:ToDisp), TimeXDFdata(1:ToDisp)]) 
disp('diff([TimeXDF(1:ToDisp), TimeCSV(1:ToDisp), TimeXDFdata(1:ToDisp)])') 
disp(diff([TimeXDF(1:ToDisp), TimeCSV(1:ToDisp), TimeXDFdata(1:ToDisp)], 1))


% plot the comparison of XDF timestamps and CSV time
% NB : this is especially infomative about the effect of 
%       'HandleJitterRemoval', true
figure (1); clf; 
plot(diff(TimeXDF)) 
hold on 
plot(diff(TimeCSV), '*') 
legend('deltaTimeXDF', 'deltaTimeStampCSV')

xlabel('sample number')
ylabel('sampling period (sec)')
title('Comparison of XDF timestamps and CSV time')


