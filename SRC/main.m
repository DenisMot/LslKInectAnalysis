% GOAL : Compare the data from LSL-Kinect 
%       -- XDF file : LSL.xdf
%       -- CSV file : MoCap.csv

%   Author(s):
%       D. Mottet, 2019-12-15, Version 1

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
streams = load_xdf(fullFileNameXDF, 'HandleJitterRemoval', true);

disp(strcat( 'loading: ', fullFileNameCSV, '...'));
M = importKinectCSV(fullFileNameCSV); 

% does the same. but 3 times slower... strange... 
% M = csvread(fullFileNameCSV,3,0); % CAUTION 0 based index!!

%CheckXDF(streams, 'noFigures'); 
CheckLSLKinectSampling(streams); 

searchedName = 'EuroMov-Mocap-Kinect'; 
iStreamMocap = findStreamByName(streams, searchedName); 

% do not forget that XDF stores data on LINES (not columns)
TimeXDF = streams{1, iStreamMocap}.time_stamps'; 
TimeXDFdata = streams{1, iStreamMocap}.time_series(1,:)'; 
% CSV is column oriented (classical). 
TimeCSV = M(:,1); 

% units of time should be the same ! 
timeUnit = 'ms'
switch timeUnit
    case 's'
        TimeXDF     = TimeXDF;
        TimeCSV     = TimeCSV     ./ 1000; % to get seconds
        TimeXDFdata = TimeXDFdata ./ 1000; % to get seconds
    case 'ms'
        TimeXDF     = TimeXDF .* 1000 ;
        TimeCSV     = TimeCSV;
        TimeXDFdata = TimeXDFdata;
end


figure(200); clf;
subplot(2,1,1) 
plot(TimeCSV - TimeXDFdata) 
title('TimeCSV - TimeXDFdata (should be equal)')
subplot(2,1,2) 
delay = (TimeCSV-TimeCSV(1)) - (TimeXDF-TimeXDF(1)); 
plot(delay, '*') 
title('TimeCSV - TimeXDF (jitter in network tranmission)')
ylabel(sprintf('delay (%s)', timeUnit) )
xlabel('sample number')

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
plot(0)
legend('diff(TimeXDF)', 'diff(TimeCSV)')

xlabel('sample number')
ylabel(sprintf('sampling period (%s)', timeUnit) )
title('Comparison of XDF and CSV sampling period')

figure (3); clf; 

histogram(diff(TimeCSV))
xlabel(sprintf('sampling period (%s)', timeUnit) )
ylabel('count')
title('distribution of diff(TimeCSV)') 