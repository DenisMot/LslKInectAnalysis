function XDF_DispChannelInfo(info)
% visualisation of channels from an XDF file

% %   Author(s):
%       D. Mottet, 2020-01-06, Version 1
%
%   Copyright 2019 - Univ Montpellier

fprintf('Channels in stream "%s" of type "%s" :\n', info.name, info.type ); 
chLabels = XDF_GetChannelsDescriptions(info);
for i = 1:length(chLabels)
    fprintf('  %03d, %s', i, chLabels{i});
end

end