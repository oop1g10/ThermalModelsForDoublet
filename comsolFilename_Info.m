function [ params ] = comsolFilename_Info( comsolFilename )
% Returns info from filename.
% Input - comsolFilename, for example:
% profile sol1 0001 q[1e-06] aXYZ[0 0 0] ro[0.1] H[100] adeg[90] T0[40] Ti[25] a[200] Q[30] rhoW[1000] cW[4200] rhoS[2600] cS[1000] lS[2.8] n[0.1] mesh[0.01].txt
% Please NOTE: the order of q axyz and fe parameters MUST be as shown in example!
% q - Darcy groundwater velocity, m/s
% aXYZ - aquifer dispersivities in 3 directions, m

    %If some parameter is NOT set in file name - return standard parameter value in params 
    % Get standard model parameters
    paramsStd = standardParams('homo');
    params = paramsStd;
    
    % Substitute values from file name instead of standard params values
    % Split file name to cells with param names and values
    fileInfo = textscan(comsolFilename, '%s%f%s%f%f%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s',...
                        'Delimiter', {'[',']'});
    % The first parameters in file name should always be q and aXYZ, take the values for them
    params.q = fileInfo{2};
    params.aX = fileInfo{4};
    params.aY = fileInfo{5};
    params.aZ = fileInfo{6};
    % All other parameters follow, in any order, in pairs of cells as name and value
    for i = 7:2:numel(fileInfo)
        % If in current cell is '.txt' it means that no more parameters in file name
        if strcmp(fileInfo{i}, '.txt')
            break
        end
        % Take name of parameter from cell, example 'fe=' or 'fe'
        paramName = fileInfo{i}{1};
        % To support old variant of file names, if "=" is present -> remove it
        if paramName(end) == '=' 
            paramName = paramName(1:end-1); % Remove last char from parameter name (i.e. 'fe=' -> 'fe')
        end
        % Take value of parameter from cell
        paramValue = fileInfo{i+1};
        
        % Convert param names from shorter to longer (standard) versions 
        % (short versions were used during calculation because txt file names are limited to 256 characters)
        comsolParamNamesInFile = comsolParamNamesInFileShort( );
        paramNameLong = comsolParamNamesInFile(strcmp(paramName,comsolParamNamesInFile(:,2)), 1);
        % For older versions of files, if short names are not used
        % if found corresponding long parameter name, then use it, otherwise keep orig Already long name
        if size(paramNameLong,1) == 1
            paramName = paramNameLong{1};
        end
        % Assign param value to param structure 
        params.(paramName) = paramValue;
    end
    
    % possible parameter checks
    %assert(~isempty(fe) && fe > 0, 'Heat input (fe) value in file name is zero or less than zero.')
    
end

