function [ comparativeStatsTab, Xmesh, Ymesh ] = ...
    comparativeStats( modelMethods, x_range_forRmseMae, y_range_forRmseMae, z_range_forRmseMae, Mt, ...
                      timeTbh, timeTbh_max, T_plume_list, x_Tlist, ...
                      params, t_list, comsolResultsTab, variant)
% Calculate RMSE and MAE for matrix outputs (2d space) of two models, and
% also total stats for the whole model performances
% Note about model input:
% modelMethods - two models to compare, first model is target (e.g. MFLS)
% second model is "model" to compare with e.g. Comsol
% T_points_t_model1 is model input which is required to have values
% (Temperatures) for each point (as rows) and for each time as columns.
% x_range, y_range, z_range - ranges for RMSE calculation, either y range or z range should be single
% value for profile or plan view respectively
% Xmesh, Ymesh - these are meshes which correspond to rmse_2D and mae_2D,
%                after reshape(mae_2D, Mt, Mt)
% timeTbh - time to calculate temperature at borehole wall, years
% timeTbh_max - time to calc max temperature at borehole wall, years
% T_plume_list - Difference of temperature, deg C, to find plume (isotherm) extent 
% x_Tlist - % [m] X coordinates, distance from heat source for temperature evaluation


    assert(numel(modelMethods) == 2, 'Enter two models only!') 
        
    %% Calculate key model info for comparison
    % note that xRange is used as x_range to search for plume extent
    keyModelInfoTab = table;
    for im = 1:numel(modelMethods)
        keyModelInfoRow = keyModelInfo( timeTbh, timeTbh_max, T_plume_list, x_Tlist, ...
                                         modelMethods{im}, params, comsolResultsTab, variant);
        % Delete columns with cells which are not needed for comparative stats
        keyModelInfoRow.t_listComparison = [];
        keyModelInfoRow.well_T_comparison = [];
        
        % Elements count is present only for comsol model (numerical model), for ansol it is empty []
        if ~isempty(keyModelInfoRow.elementsCountComsol)
            elementsCountComsol = keyModelInfoRow.elementsCountComsol;
        end
        keyModelInfoTab(im,:) = keyModelInfoRow;       
    end
    
    %% Calculate key info relative differences
    keyModelInfoRelDiff = relativeDiff_forTable(keyModelInfoTab, numel(fieldnames(params)));
    keyModelInfoRelDiff.elementsCountComsol = elementsCountComsol;

    % First part of comparison is key info, now add also RMSE and MAE
    comparativeStatsTab = keyModelInfoRelDiff;
    
    %% Calculate RMSE, MAE and max T difference for each row across all columns (dim = 2) i.e. for each point with all times.
 
    % Calculate temperatures for models
    T_points_t_modelMethod = nan(Mt*Mt, numel(t_list), numel(modelMethods));
%     warning('RMSE not calculated!!!!!!!!!!!!')
        Xmesh = []; Ymesh = [];
%     for im = 1:numel(modelMethods)
%         [T_points_t_modelMethod(:,:,im), ~, ~, Xmesh, Ymesh, ~ ] = ...
%             T_eval_model(modelMethods{im}, x_range_forRmseMae, y_range_forRmseMae, z_range_forRmseMae, ...
%                          Mt, params, t_list, comsolResultsTab);
%     end
    
    % Collect calculated temperatures for both models
    T_points_t_target = T_points_t_modelMethod(:,:,1); % analytical
    T_points_t_model = T_points_t_modelMethod(:,:,2); % numerical COMSOL
    % Calculate RMSE, MAE on 2D surface
    [rmse_2D, mae_2D] = calcRmseMae(T_points_t_target, T_points_t_model, 2);
    comparativeStatsTab.rmse_2D = {rmse_2D};
    comparativeStatsTab.mae_2D = {mae_2D};
    % Calculate maximum RMSE and MAE from all points
    comparativeStatsTab.rmse_2Dmax = {max(rmse_2D)};
    comparativeStatsTab.mae_2Dmax = {max(mae_2D)};
    % Calculate total RMSE and MAE for all points and for all times.
    [comparativeStatsTab.rmseTotal, comparativeStatsTab.maeTotal] = ...
        calcRmseMae(T_points_t_target(:), T_points_t_model(:), 1);
    
    % Calculate max T difference for all points and for all times.
    T_Diff = T_points_t_model(:) - T_points_t_target(:);
    [~, T_max_Diff_Idx] =  max(abs(T_Diff)); % get position of absolute max difference
    comparativeStatsTab.T_max_Diff = T_Diff(T_max_Diff_Idx); % return the real (not absolute) value of T difference

end

