function paramsString = comsolParams2String( params )
% Convert parameters to text

    % Set fixed first params for q and axyz as special case (axyz = 3 numbers)
    paramsString = sprintf('q[%g] aXYZ[%g %g %g]', ...
        params.q, params.aX, params.aY, params.aZ );
    % Add other parameters values to string (to be used for file name) from params structure 
    paramsNames = fieldnames(params); % take params names as cell array from params structure
    for i = 1: numel(paramsNames)
        % Skip q and axyz params as they are already preset to param string
        paramsNamesToSkip = {'q', 'aX', 'aY', 'aZ' };
        if ~any(strcmp(paramsNames{i}, paramsNamesToSkip)) % for all parameters, except those in list paramsNamesToSkip
            paramValue = params.(paramsNames{i}); % take one param value 
            % Convert param names to shorter versions because txt file names are limited to 256 characters
            comsolParamNamesInFile = comsolParamNamesInFileShort( );
            paramNameShort = comsolParamNamesInFile(strcmp(paramsNames{i},comsolParamNamesInFile(:,1)), 2);
            % if No such parameter name exists 
            if size(paramNameShort,1) ~= 1
                % use long parameter name
                paramNameShort = paramsNames(i);
            end
            % Format parameter name with its value in cell with one string
            paramStringValue = {sprintf('%s[%g]', paramNameShort{1}, paramValue)};
            % Join one string (parameter with its value) to string with q and aXYZ value and all present other values
            paramsString = strjoin([paramsString, paramStringValue]); % Note strjoin takes both cells and strings as input!
            % default delimiter is space ' ' in strjoin
        end
    end

end

