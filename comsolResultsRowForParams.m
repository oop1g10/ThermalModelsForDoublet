function comsolResultsRow = comsolResultsRowForParams( resultsTab, params, fixedCoord, variant )
% Identify which lines in results table match the requested parameters         
% fixedCoord is to identify which cut (plan/profile) is needed.

    % If resultsTab is empty please return empty table only
    if isempty(resultsTab)
        comsolResultsRow = resultsTab;
        return
    end

    % Identify rows in results table that match fixed coordinate (fixedCoord)
    % If fixedCoord is provided (relevant)
    if ~isempty(fixedCoord)
        fixedCoordParRep = repmat(fixedCoord, numel(resultsTab.fixedCoord), 1);
        fixedCoordTab = cell2mat(resultsTab.fixedCoord);
        % In params.fixedCoord there are NaN for variable coordinates and a fixed value for coordinate
        % that is fixed for all points of interest, for example [NaN, NaN, 50]. 
        % The same three values are in comsolResultsTab.fixedCoord because the coordinate was
        % fixed by a domain cut and export of data for the cut.
        % In case of 2D export of plan view model, the z-coordinate is actually
        % not used and the comsolResultsTab.fixedCoord has NaN for it too [NaN, NaN, NaN].
        % This means that the data are suitable for ANY z-value.
        rows_fixedCoord = fixedCoordParRep == fixedCoordTab | isnan(fixedCoordTab);
        rows_fixedCoord = all(rows_fixedCoord,2); %all coordinates for the table row must match
    else % if fixedCoord is empty (not relevant)
        rows_fixedCoord = true;
    end
    
    % Round method for params is the same as for params in txt result, so the row is found in all cases
    % Turn params into string with general rounding
    paramsString = comsolParams2String( params );
    % Convert params string back to params structure
    paramsRounded = comsolFilename_Info( [paramsString '.txt'] , variant); % txt has to be added in function input for it to work
    
    % Check if value of all parameters already exist in the results table 
    % Use params structure to get list of all param names
    paramNames = fieldnames(params);
    rowFound_params = false(size(resultsTab, 1), numel(paramNames));
    for i = 1:numel(paramNames)
        % Prepare list of values for current parameter from results table
        paramValuesFromResults = resultsTab.(paramNames{i});
        % Turn to double in case the values are inside cells
        if iscell(paramValuesFromResults)
            paramValuesFromResults = cell2mat(paramValuesFromResults);
        end
        % Compare value of parameter in new row with all existing values for this parameter in result table
        rowFound_params(:,i) = paramsRounded.(paramNames{i}) == paramValuesFromResults ... % if result tab contains rounded values
                                 | params.(paramNames{i}) == paramValuesFromResults ... % if result tab contains original values
                                 | isnan(params.(paramNames{i})); % NaN is assigned for default values
    end
    rowFound_allParams = all(rowFound_params,2); %all params for the table row must match
    
    % Select result lines matching all parameters
    comsolResultsRow = resultsTab(rows_fixedCoord & rowFound_allParams ,:);
   
    % Check if no result found
    if size(comsolResultsRow,1) == 0
        % Allow no result just show message and return
        warning('No result found for given parameters.')
        return
    end
    
    % Only one result line is expected
    assert(size(comsolResultsRow,1) == 1, 'Only one result line is expected')

end

