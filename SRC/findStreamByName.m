function iStream = findStreamByName(streams, searchedName)

iStream = []; 
for s=1:length(streams)
    if strcmp(streams{1,s}.info.name, searchedName)
        iStream = s; 
    end
end 
end
