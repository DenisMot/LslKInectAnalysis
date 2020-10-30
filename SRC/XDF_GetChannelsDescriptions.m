function chLabels = XDF_GetChannelsDescriptions(info)
% chLabels = XDF_GetChannelLabels(info)
%   returns the label of each channel from info of the LSL stream
%   chLabels : a string matrix
%       each line is "type (unit): label" (of the channel)

% %   Author(s):
%       D. Mottet, 2019-12-15, Version 1
%
%   Copyright 2019 - Univ Montpellier

%   References:
%   https://github.com/sccn/xdf/wiki/MoCap-Meta-Data
%   https://github.com/sccn/xdf/wiki/EEG-Meta-Data



nbChannels = str2num(info.channel_count);
for i = 1 : nbChannels
    label = GetChannelInfo(i, info);
    chLabels{i} = sprintf('Ch %3d, %s', i, label);
end

end % function


function label = GetChannelInfo(i, info)
% label = string summary of information about chan i : type (unit): label

if isfield(info.desc, 'channels')       % generic LSL way
    chInfo = info.desc.channels.channel{i};
    % we expect at least 3 fields (by recommendation)
    % but we are prudent 
    label = SecureGetLabel (chInfo);
    
elseif isfield(info.desc, 'channel')        % NeuroElectrics... mistake(s)
    chInfo = info.desc.channel{1, i} ;
    label = SecureGetLabel (chInfo)
else
    label = 'No description';
end

label = sprintf('%s\n', label); 
end % function

function labelStr = SecureGetLabel (chInfo) 
    label = 'label?'; unit = 'unit?' ; type = 'type?'; marker = '';
    if isfield(chInfo, 'type')
        type = chInfo.type;
    end
    if isfield(chInfo, 'unit')
        unit = chInfo.unit;
    end
    if isfield(chInfo, 'label')
        label = chInfo.label;
    end
    if isfield(chInfo, 'marker')
        marker = chInfo.marker;
    end

    labelStr = sprintf('%s (%s): %s %s', type, unit, label, marker);
end

