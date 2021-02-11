function paramsTab_MCAT = paramsPrep_MCAT( paramsNameList_MC, keyInfoResultsCompStatTab )
% extract parameters (variables) from  table with all results to use in MCAT

    paramsTab_MCAT = table;
    for paramNameCell = paramsNameList_MC'
        paramName = paramNameCell{1};
        % If parameter should be logged
        if contains(paramName, 'LOG10_')
            paramsTab_MCAT.(paramName) = log10( keyInfoResultsCompStatTab.(paramName(7:end)) );
        % If several parameters are linked, use only the key one
        elseif contains(paramName, 'LINKED_')
            paramsTab_MCAT.(paramName) = keyInfoResultsCompStatTab.(paramName(8:end));         
        % Normal parameter
        else
            paramsTab_MCAT.(paramName) = keyInfoResultsCompStatTab.(paramName);
        end
    end

end

