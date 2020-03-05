function [ isType, charsForType ] = comsolFilename_Type( comsolFilename, type )
% Returns true if filename is of given type.
% types possible: 'profile', 'plan', 'qInfo'
    charsForType = length(type);
    isType = strncmp(comsolFilename, [type ' '], charsForType+1); %after type should be space in file name
    % if not identified file name it can be a variant with short name: pr for profile, pl for plan, qI for qInfo
    if ~isType
        typeShort = type(1:2);
        charsForType = length(typeShort);
        isType = strncmp(comsolFilename, [typeShort ' '], charsForType+1); %after type should be space in file name
    end
end

