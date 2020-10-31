function CheckLSLKinectSampling(streams)
% check if the sampling frequency changed during the record and informs the
% user 

%    Author(s):
%       D. Mottet, 2020-10-31, Version 1


% lookfor the marker stream
iStreamMarkers = findStreamByName(streams, 'EuroMov-Markers-Kinect');

% error check (minimal) 
if isempty(iStreamMarkers) 
    disp('Cannot find a stream named ''EuroMov-Markers-Kinect'' ') ;
    return
end

markersMessage = streams{1, iStreamMarkers}.time_series';
markersTime    = streams{1, iStreamMarkers}.time_stamps';

% find messages about frame rate changes
found = strfind(markersMessage,'Message : The framerate has changed to ');
iFrameRateChanged = find(not(cellfun('isempty',found)));

% find date and value of new frame rate
[newFrameRateValue, newFrameRateTime] = findFrameRateChanges(...
    markersMessage...
    , markersTime...
    , iFrameRateChanged...
    );

% get record timestamps
iStreamMocap   = findStreamByName(streams, 'EuroMov-Mocap-Kinect');
firstTime = str2num(streams{1, iStreamMocap}.info.first_timestamp);
lastTime  = str2num(streams{1, iStreamMocap}.info.last_timestamp);

% compare time of changes in FR with record Beg-End
nFrameRateChange = length(iFrameRateChanged);
message = ''; nProblems = 0;
for i=1:nFrameRateChange
    newFrTime  = newFrameRateTime(i);
    newFrValue = newFrameRateValue(i);
    
    % if FR changes during the recoriding time... 
    if (newFrTime > firstTime & newFrTime < lastTime)
        % ...we have a problem...
        message = sprintf('%sFrame rate changed to %d Hz at %5.2f sec (%5.2f s after start)\n', message, newFrValue, newFrTime, newFrTime - firstTime);
        nProblems = nProblems + 1;
    end
end

% end user message 
if nProblems > 0
    advice  = 'You should NOT use read_xdf with HandleJitterRemoval = true!';
    message = sprintf('\n%s\n%s\n', message, advice);
    warning(message)
else
    disp('No frame rate changes')
end

end

function [newFrameRateValue, newFrameRateTime] = findFrameRateChanges(...
    markersMessage, markersTime, iFrameRateChanged)
% find all frame rate changes knowing the index of messages describing the
% changes (iFrameRateChanged) 

% initialise output
nFrameRateChange  = length(iFrameRateChanged);
newFrameRateValue = zeros(nFrameRateChange, 1) + nan;
newFrameRateTime  = zeros(nFrameRateChange, 1) + nan;

% loop on all frame rate changes
for i=1:nFrameRateChange
    iToCheck = iFrameRateChanged(i);
    FrameRateChanged  = markersMessage{iToCheck};
    words = strsplit(FrameRateChanged);
    
    newFrameRateValue(i) = str2num(words{end});
    newFrameRateTime(i)  = markersTime(iFrameRateChanged);
end

end
