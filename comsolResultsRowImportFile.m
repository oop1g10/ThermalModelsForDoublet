function [ comsolResultsTabRow, comsolFilename_qInfo ] = comsolResultsRowImportFile( comsolImportPath, filename )
% comsolResultsRowImportFile function imports file of given name from given folder and adds to it the qInfo and Reynolds numer info.

    comsolFilename = [comsolImportPath  filename];
    % Import file of given name
    [nodeXYZ, T_nodeTime, v_x_nodeTime, v_y_nodeTime, Hp_nodeTime, timeList] ...
        = comsolImportFile(comsolFilename);
 
    % Prepare results for one file with unique parameter set
    comsolResultsTabRow = comsolResultsRowCreate(comsolFilename, nodeXYZ, T_nodeTime, ...
                                                 v_x_nodeTime, v_y_nodeTime, Hp_nodeTime, timeList);

    % Search if qInfo file is present with the same parameters and import it as additional columns
    % qInfo file contains groundwater velocities at VBHE wall and at 10m distance form it, also inside fracture
    % Prepare qInfo file name
    [ isTypePlan, charsForTypePlan ] = comsolFilename_Type( filename, 'plan' );
    [ isTypeProfile, charsForTypeProfile ] = comsolFilename_Type( filename, 'profile' );
    if isTypePlan 
        filename_part = filename(charsForTypePlan+1 : end);
    elseif isTypeProfile  
        filename_part = filename(charsForTypeProfile+1 : end);    
    end
    % Add qInfo to file name
    comsolFilename_qInfo = [comsolImportPath 'qInfo' filename_part];
        
    % Check if file present
    if exist(comsolFilename_qInfo, 'file') == 2 % 2 means it exists
        % Import existing qInfo file, for separate derived values
        qInfoTab = comsolImportFile_qInfo(comsolFilename_qInfo);
        % Add qInfo columns to results row
        comsolResultsTabRow = [comsolResultsTabRow, qInfoTab];
    end

end

