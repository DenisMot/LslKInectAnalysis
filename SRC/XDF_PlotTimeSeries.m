function XDF_PlotTimeSeries(stream, tBeg, tEnd)
% to plot any type of numeric data stream from XDF file...
% XDF_PlotTimeSeries(stream) plots the data in stream
% XDF_PlotTimeSeries(stream, tBeg, tEnd) adds a line from tBeg to tEnd,
% --> thisnis useful to visualise time coherence between streams with :
%       tBeg = time of start of stream starting the first
%       tEnd = time of end of stream ending the last
%
%   Author(s):
%       D. Mottet, 2020-01-04, Version 1
%
%   Copyright 2019 - Univ Montpellier

%   References:
%   Works with
% 1: Accelerometer   3 x 100 Hz, LSLOutletStreamName-Accelerometer
% 2:        Kinect 102 x  30 Hz, Kinect-LSL-Data
% 3:       Quality   8 x   1 Hz, LSLOutletStreamName-Quality
% 5:          NIRS  16 x  10 Hz, Oxysoft
% 6:       Markers   1 x   0 Hz, LSLOutletStreamName-Markers
% 7:          Data   3 x 100 Hz, LSL-Mouse-DataInfo
% 8:           EEG   8 x 500 Hz, LSLOutletStreamName-EEG


if nargin < 2 tBeg = stream.time_stamps(1); end
if nargin < 3 tEnd = stream.time_stamps(end); end

if strcmp(stream.info.channel_format, 'string')
    warning('cannot plot strings... nothing done.');
    return
end

%t = stream.time_stamps - stream.time_stamps(1);
t = stream.time_stamps - tBeg;
x = stream.time_series;

% if segments, make "holes" (for nicer plot...)
if isfield(stream, 'segments')
    for s = 1:length(stream.segments)
        t(stream.segments(s).index_range(2)) = nan;
    end
end


nbChan = size(x, 1);

if 0
    h = figure(); clf; hold on;
    h.Name = sprintf('%s, %s', stream.info.name, stream.info.type);
    
    plot(t, x)
    
    lab = XDF_GetChannelsDescriptions(stream.info);
    xlabel('time (s)')
    
    for c = 1:nbChan
        theLegend {c} = strcat(stream.info.desc.channel{c}.name, ', ', stream.info.desc.channel{c}.unit);
    end
    
    
    legend(theLegend)
else
    
    % plot the channels with nSubplots per figure
    nSubplots = 4;
    nChannels = size(x, 1);
    nSubplots = min (nSubplots, nChannels); % 4 channels per figure (maximum)
    for c = 1:nChannels
        % chose figure/subplot
        iSubplot = mod(c-1, nSubplots) + 1;  % matlab indexes at 1 (not zero)
        if iSubplot == 1                     % first subplot = new figure
            h = figure(); clf; hold on;
            h.Name = sprintf('%s, %s', stream.info.name, stream.info.type);
        end
        
        
        % plot the channel
        subplot(nSubplots, 1, iSubplot)
        
        chan = x(c, :);
        plot(t, chan) ;
        lab = XDF_GetChannelsDescriptions(stream.info);
        xlabel('time (s)')
        title ( lab(c) )
        
        % add a zero line, also for time coherence between plots
        %     hold on;
        %     plot([0,  tEnd - tBeg ] , [ 0, 0 ] , '.-k');
        xlim([0,  tEnd - tBeg ])
    end
end
end
