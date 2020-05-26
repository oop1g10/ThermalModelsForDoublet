function comsolResultsTab = comsolResultsTabAdd(comsolResultsTab, comsolResultsTabRow, variant)
% Add new results to the results table

    % Check if Results table is empty
    if isempty(comsolResultsTab)
        % Add new data to the comsol results table
        comsolResultsTab(end+1,:) = comsolResultsTabRow;
    else % Some data already in the results table
        % If this particular gw velocity and dispersivity etc. are already in table -> replace it
        rowFound_dim = strcmp(comsolResultsTabRow.dimensions(1), comsolResultsTab.dimensions);
        
        % Check if value of all parameters already exist in the results table 
        % Use standard params to get list of all params
        [ params ] = standardParams(variant);    
        paramNames = fieldnames(params);
        rowFound_params = false(size(comsolResultsTab, 1), numel(paramNames));
        for i = 1:numel(paramNames)
            % Compare value of parameter in new row with all existing values for this parameter in result table
            rowFound_params(:,i) = comsolResultsTabRow.(paramNames{i}){1} == cell2mat(comsolResultsTab.(paramNames{i})) ...
                                    | isnan(comsolResultsTabRow.(paramNames{i}){1}); % NaN is assigned for default values
        end
        
        rowFound_allParams = all(rowFound_params,2); %all params for the table row must match

        % If the export for q and aXYZ is already in results table
        if any(rowFound_dim & rowFound_allParams)
            % Replace previous export
            comsolResultsTab(rowFound_dim & rowFound_allParams,:) = comsolResultsTabRow;
            warning('Result row already exists and is replaced!')
        else
            % Otherwise, add new data to the comsol results table
            comsolResultsTab(end+1,:) = comsolResultsTabRow;
        end
    end
    % Sort table by q
    comsolResultsTab = sortrows(comsolResultsTab, {'q'});

end

