function CheckXDF(streams, option)
% checks a streams list built following LSL guidelines
% 
% Provides :
%   - summary in the console 
%   - figures to display each column in eache stream 

%   Author(s):
%       D. Mottet, 2019-12-15, Version 1
%
%   Copyright 2019 - Univ Montpellier

%   References:
%   https://github.com/sccn/xdf


if nargin < 2 
    option = 'noFigures'; 
end



% get time relations between streams (for the plots)
tBeg = inf;         
tEnd = 0; 
for s = 1 : size(streams, 2)
    % it is possible that some streams are not well synchronized... 
    if isfield(streams{1, s}.info, 'first_timestamp')
        first_timestamp = str2num(streams{1, s}.info.first_timestamp);
        last_timestamp = str2num(streams{1, s}.info.last_timestamp);
        tBeg = min(tBeg, first_timestamp );
        tEnd  = max(tEnd, last_timestamp );
    end
end

fprintf('--------------------------------------------------------------\n')
fprintf('Streams start -> end:\n')
for s = 1 : size(streams, 2)
    if isfield(streams{1, s}.info, 'first_timestamp')
        first_timestamp = str2num(streams{1, s}.info.first_timestamp);
        last_timestamp = str2num(streams{1, s}.info.last_timestamp);
        
        type = streams{1, s}.info.type;
        fprintf('%2d: %13s %7.2f -> %7.2f s\n', s, type ...
            , first_timestamp - tBeg ...
            , last_timestamp - tBeg...
            );
    else
        fprintf('streams{1, %d}.info.first_timestamp not present\n', s)
    end
end

% display summary 
fprintf('--------------------------------------------------------------\n')
fprintf('Streams found:\n')
for s = 1 : size(streams, 2)
    name = streams{1, s}.info.name; 
    type = streams{1, s}.info.type;
    chan = streams{1, s}.info.channel_count;
    rate = streams{1, s}.info.nominal_srate;
    fprintf('%2d: %13s %3s x %4s Hz, %s\n', s, type, chan, rate, name )
end
fprintf('--------------------------------------------------------------\n')


% check all streams, by type of stream 
% see : https://github.com/sccn/xdf/wiki/Specifications 
for s = 1 : size(streams, 2)
    DataType = streams{1, s}.info.type; 
    
    % global error check : empty data sometimes happens... strange... 
    if isempty(streams{1, s}.time_series)
        fprintf('******** Stream %d is empty (no data)\n', s); 
        continue;
    end
    
    if 1
        tBeg = str2num(streams{1, s}.info.first_timestamp);
        tEnd = str2num(streams{1, s}.info.last_timestamp);
    end 
    switch DataType
        case {'MoCap' '!MoCap'}
            fprintf('MoCap found : stream %2d\n', s);
            CheckMocapStream(streams{1, s}, tBeg, tEnd, option);
        case 'EEG'
            fprintf('EEG found : stream %2d\n', s);
            CheckEEGStream(streams{1, s}, tBeg, tEnd);
        case 'Accelerometer'
            fprintf('Accelerometer found : stream %2d\n', s);
            CheckAccelerometerStream(streams{1, s}, tBeg, tEnd);
        case 'NIRS'
            fprintf('NIRS found : stream %2d\n', s);
            CheckNirsStream(streams{1, s}, tBeg, tEnd);
        case 'Markers' 
        case 'Event'    % Oxysoft Event ressembles a Marker
            fprintf('Markers found : stream %2d\n', s);
            CheckMarkersStream(streams{1, s}, tBeg, tEnd); 
 
        otherwise
            warning('Cannot process stream %2d\n', s);
    end
end


end

