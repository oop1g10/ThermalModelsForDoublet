function [ keyModelInfoRelDiff ] = relativeDiff_forTable( keyModelInfoTab, numberOfColumnsToSkip )
% Calculate key info relative differences
% keyModelInfoTab - is expected to have 2 rows with columns for key model
% info (as Temperature at bh wall after 30 years),
% NOTE: first column of the table is for chars: model names, first is
% target name (e.g. MFLS) second row is for model name (e.g. Comsol)

    % table row for results
    % copy skipped columns with original values, for example parameters
    % Second row is set to take parameters from model with fracture, because first row is for Homo model with cleared fracture parameters
    keyModelInfoRelDiff = keyModelInfoTab(2, 1:numberOfColumnsToSkip);
    columnNames = keyModelInfoTab.Properties.VariableNames;
    % First column will have names of compared models (target and model)
    keyModelInfoRelDiff.(columnNames{numberOfColumnsToSkip+1}) = ...
        {sprintf('%s_vs_%s',cell2mat(keyModelInfoTab{2,numberOfColumnsToSkip+1}), cell2mat(keyModelInfoTab{1,numberOfColumnsToSkip+1}))};
    % Calculate relative difference for all columns starting from the second one
    for i = numberOfColumnsToSkip+2:numel(columnNames)
        % Add to column names Diff at the end 
        columnName = sprintf('%s_Diff', columnNames{i});
        % Take column name from contents of columnName variable
        keyModelInfoRelDiff.(columnName) = keyModelInfoTab{2,i} - keyModelInfoTab{1,i};
        
        % Add to column names RelDiff at the end 
        columnName = sprintf('%s_RelDiff', columnNames{i});
        % Take column name from contents of columnName variable
        keyModelInfoRelDiff.(columnName) = relativeDiff( keyModelInfoTab{1,i}, keyModelInfoTab{2,i} );
    end
    % Add new columns for both models with cell containing all original key info values
    keyModelInfoRelDiff.keyModelInfo_target = {keyModelInfoTab(1,:)};
    keyModelInfoRelDiff.keyModelInfo_model = {keyModelInfoTab(2,:)};
    % Old variant with column name based on modelMethod name
    %for i = 1:2
    %    keyModelInfoRelDiff.(['keyModelInfo_', keyModelInfoTab.modelMethod{i}]) = {keyModelInfoTab(i,:)};
    %end
    
end

