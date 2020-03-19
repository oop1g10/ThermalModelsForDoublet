function comparativeStatsSave( comparativeStatsTab, plotExportPath, modelMethods )
% Save comparative statistics table with unique parameter combinations into csv file

    % Exclude rows rmse_2D and mae_2D from comparative stats tab because they have 2D matrix in them, 
    % this is preparation to save this table as csv file
    comparativeStatsTab_tosave = comparativeStatsTab;
    comparativeStatsTab_tosave.rmse_2D = [];
    comparativeStatsTab_tosave.mae_2D = [];
    comparativeStatsTab_tosave.keyModelInfo_target = [];
    comparativeStatsTab_tosave.keyModelInfo_model = [];
    writetable(comparativeStatsTab_tosave, [plotExportPath 'compare_statsTab_' cell2mat(modelMethods) '.csv'],...
                'Delimiter', ',')

end

