function [ comsolResultsTab ] = addToTabAbsentParams( comsolResultsTab, variant )
%Check if comsolDataFile has variable Q (gw flow) for model. It is needed for analytical model
% if no such parameter is present, add this parameter      
        
    paramsStd = standardParams( variant );
    % If parameter Q is present in ParamsStd structure but is not in comsol
    % results table 
    % Add it
    if isfield(paramsStd, 'Q')
        % If column Q (gw flow) does not exist in table    
        if ~any(strcmp('Q', comsolResultsTab.Properties.VariableNames))
            % add column with default values for each line
            comsolResultsTab.Q = repmat({paramsStd.Q}, size(comsolResultsTab, 1), 1);
        end
    end
end

