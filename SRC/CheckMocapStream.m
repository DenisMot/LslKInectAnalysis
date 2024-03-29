function CheckMocapStream(stream, tBeg, tEnd, option)
% checks a "MocCap" stream built following LSL guidelines

%   Author(s):
%       D. Mottet, 2019-12-15, Version 1
%
%   Copyright 2019 - Univ Montpellier

%   References:
%   https://github.com/sccn/xdf/wiki/MoCap-Meta-Data

if  ~ strcmp(stream.info.type, {'MoCap' '!MoCap'} ) 
    error('Not a MoCap stream'); 
end


XDF_DispChannelInfo(stream.info);

switch option
    case 'noFigures'
        ; % do nothing
    otherwise
        XDF_PlotTimeSeries(stream, tBeg, tEnd);
end

return

% This is to go along with more specific analyses 

if isfield(stream.info.desc, 'configuration') 
    switch stream.info.desc.configuration.task
        case 'CircularTarget'
            CheckCircularTarget(stream)
        case 'ReachingTarget'
            disp('to be imlemented');
        otherwise
            disp('unknown Mocap type of stream'); 
    end
end


if isfield(stream.info.desc, 'acquisition') 
    if isfield(stream.info.desc.acquisition, 'model')
        switch stream.info.desc.acquisition.model
            case 'Kinect 2.0'
                CheckKinectStream(stream, tBeg, tEnd)
            otherwise
                disp('unknown Mocap acquisition model');
        end
    else
        disp('no model in stream.info.desc.acquisition');
    end
else
    disp('no acquisition in stream.info.desc');
end 
end





