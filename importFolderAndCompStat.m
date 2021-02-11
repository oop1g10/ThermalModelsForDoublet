function keyInfoResultsCompStatTab = importFolderAndCompStat( comsolImportPath, modelMethods, variant, iFileList )
% Import comsol results from txt files and calculate comparative statistics
    % Get standard times, plume temperatures and coordinates for comparison
    [ t_list, ~, ~, ~, ~, ~, ~, ~, z, ~, timeTbh, timeTbh_max,...
        ~, T_plume_listMC, ~, x_TlistMC, ~, ~, ~, ~ ] = ...
        standardRangesToCompare( variant );

    keyInfoResultsCompStatTab = table;
    % List names of txt files with results
    fileList = dir([comsolImportPath '*.txt']);
    iFileListAll = 1 : numel(fileList);
    iFileListUse = intersect(iFileListAll, iFileList);
    for iFile = iFileListUse
        filename = fileList(iFile).name;
        fprintf('Importing: %s\n', filename)
        tic
        % Import Comsol results from txt files 
        comsolResultsTabRow = comsolResultsRowImportFile( comsolImportPath, filename );
        % Get parameters from comsol filename
        params = comsolFilename_Info( filename, variant );

        % Calculate key info for MonteCarlo analysis        
%         keyModelInfoRow = keyModelInfo( timeTbh, timeTbh_max, T_plume_list, x_Tlist, ...
%                                  modelMethod, params, comsolResultsTab, variant);
        % Small ranges for RMSE calculation, they are not used for MC but required as function input
        x_range = [-1, 1];
        y_range = [-1, 1];
        Mt = 10;
        comparativeStatsRow = comparativeStats( modelMethods, x_range, y_range, z, Mt, ...
                          timeTbh, timeTbh_max, T_plume_listMC, x_TlistMC, params, t_list, comsolResultsTabRow, variant); 
                  
        %% Save simulation parameters and statistics to file
        
        % Prepare relevant results, statistics and key info into single row
        % Results, delete not relevant columns
        comsolResultsTabToSave = comsolResultsTabRow; % Duplicate table to enable debugging and operations with full table
        comsolResultsTabToSave.nodeXYZ = []; 
        comsolResultsTabToSave.T_nodeTime = []; 
        comsolResultsTabToSave.timeList = []; 
        comsolResultsTabToSave.delaunayTriang = []; 
        comsolResultsTabToSave.v_x_nodeTime = [];
        comsolResultsTabToSave.v_y_nodeTime = [];
        comsolResultsTabToSave.Hp_nodeTime = [];
        % Delete columns from Results Row which are repeated in KeyInfo
        for fieldName = comsolResultsTabToSave.Properties.VariableNames
            % If key Info also contains this field, delete it from the Results table
            if any(strcmp(comparativeStatsRow.keyModelInfo_model{1}.Properties.VariableNames, fieldName))
                comsolResultsTabToSave.(fieldName{1}) = [];
            end
        end
        % Statistics, delete not relevant columns
        comparativeStatsRowToSave = comparativeStatsRow; % Duplicate table to enable debugging and operations with full table
        comparativeStatsRowToSave.keyModelInfo_target = []; 
        comparativeStatsRowToSave.keyModelInfo_model = []; 
        comparativeStatsRowToSave.rmse_2D = []; 
        comparativeStatsRowToSave.mae_2D = []; 
        % Delete columns from comparativeStatsRow which are repeated in KeyInfo
        for fieldName = comparativeStatsRowToSave.Properties.VariableNames
            % If key Info also contains this field, delete it from the Results table
            if any(strcmp(comparativeStatsRow.keyModelInfo_model{1}.Properties.VariableNames, fieldName))
                comparativeStatsRowToSave.(fieldName{1}) = [];
            end
        end
        % Key info to save all columns are relevant
        keyModelInfo_targetToSave = comparativeStatsRow.keyModelInfo_target{1}; %As currently: Target = Homo model (no fracture)
        keyModelInfo_modelToSave = comparativeStatsRow.keyModelInfo_model{1}; %As currently: Model = Hetero model (with fracture)

        % Combine all three result parts into one table: KeyInfo + ResultRow + ComparativeStats = SuperFile:)
        % Two times identical numerical model. Comsol results is one row only is used for both lines of models. 
        % Analytical and numerical model comparison. Comsol results is one
        % row only will be used for analytical to keep the table columns structure.
        % Two different numerical models. Comsol results is two rows.
        if size(comsolResultsTabToSave,1) == 1
            iTarget = 1;
            iModel = 1;
        else 
            iTarget = 1;
            iModel = 2;
        end
        keyInfoResultsCompStatTab(end+1,:) = [keyModelInfo_targetToSave, comsolResultsTabToSave(iTarget,:), comparativeStatsRowToSave];
        keyInfoResultsCompStatTab(end+1,:) = [keyModelInfo_modelToSave, comsolResultsTabToSave(iModel,:), comparativeStatsRowToSave];
        
        % Stop calculation time duration measurement
        calcDurationSeconds = toc();
        fprintf('Finished time %7.2f minutes\n', calcDurationSeconds / 60); % print in log file
    end
end

