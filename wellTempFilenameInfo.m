function [loggerID, wellName, wellDepth] = wellTempFilenameInfo(filename)
%wellTempFilenameInfo transfer info from file name 
% [loggerID, wellName, wellDepth] = wellTempFilenameInfo('4C10307_aquifro3_26.80m.xlsx')


    % Split file name to cells with param names and values
    fileInfo = textscan(filename, '%s%s%f%s', 'Delimiter', {'_'});

    loggerID = fileInfo{1}{1}; % unpack cell two times as double cell in fileinfo
    wellName = fileInfo{2}{1};
    wellDepth = fileInfo{3};                   

end

