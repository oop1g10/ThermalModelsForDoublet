% Compare analytical and numerical models with the same criteria and varying mesh size, for mesh convergence
% Oleksandra Pedchenko
%%
clear
clear T_eval_model % clear persistent variables in function (used as cache)
clc

setFigSize( 1, 1 ); %size for single column figure
defaultLineWidth = get(groot,'defaultLineLineWidth');
%% Decide model for mesh convergence
% Model decisions: Choose ONLY ONE TRUE
% decision on 3D or 2D is located in function comsolDataFileInUse_Info

% Plots selections
meshColumnName = 'maxMeshSize'; % select from 'elementsCountComsol' or 'maxMeshSize'
%meshColumnName = 'elementsCountComsol';

plot_Tb_mesh_q = true; % plot temperature at borehole wall vs number of elements in mesh
    plot_absoluteDiff_1 = true; % ALWAYS SHOULD BE TRUE % use absolute value (PREFFERED to avoid zigzaggy plot lines) for temeprature difference for plot_Tb_mesh_q and plot_TmaxDiff_mesh_q
    plot_relativeDiff = true;
plot_RMSE_mesh_q = false; % plot total RMSE vs number of elements in mesh
    plot_MAE_mesh_q = false; % plot total MAE (mean absolute error) vs number of elements in mesh
plot_TmaxDiff_mesh_q = false; % plot max T difference for all positions and for all times, between models vs number of elements in mesh
    plot_absoluteDiff_2 = true; % use absolute value (PREFFERED to avoid zigzaggy plot lines) for temeprature difference for plot_Tb_mesh_q and plot_TmaxDiff_mesh_q

plotSave = false;
plotExportPath = 'C:\Users\Asus\OneDrive\INRS\COMSOLfigs\doubletMeshConvergence_2d_H3000\'; % Folder to export plots

% Load results comsolResultsTab from Comsol calculations
[~, comsolDataFileConvergence, ~, modelMethodsConvergence, variant,~,~,~,~ ] = ...
            comsolDataFileInUse_Info( );
load(comsolDataFileConvergence)
% Add missing columns to loaded result   
% IT IS NOT NEEDED NOW!!!!!, just in case it is needed, do it here.
comsolResultsTab = addToTabAbsentParams( comsolResultsTab, variant );

modelMethods = modelMethodsConvergence;

%% Calculations for RMSE / MAE 
% Standard model parameters
paramsStd = standardParams(variant);
% Ranges for models mesh convergence comparison
[ t_list, q_list, ~, x_range, y_range, ~, Mt, ~, z, ~, timeTbh, timeTbh_max, T_plume_list, ~, x_Tlist ] = ...
    standardRangesToCompare( variant );
warning('results after 5 years are incorrect as only interpolated, run was until 5 years.')

if true %temporary lower steps for quicker execution for testing
    Mt = 60; % Step size for stats calculation, disable when testing is finished
    warning('Change steps Mt for stats calculation back to original after testing is finished!');
end

% Prepare table of parameter sets to sample from, to conduct model comparison
paramsList = paramsStd;
% Lists for parameters which are needed for sampling for model comparison
paramsList.q = q_list(4); %q_list; %it can also be takedn from results if only 1 q was used: comsolResultsTab.q{1};
fprintf('Used q = %.3f m/day\n', paramsList.q * daysToSeconds(1));

paramsList.aX = comsolResultsTab.aX{1}; % Only ax is provided, ay az will be calculated later from specified proportion
paramsList.maxMeshSize = unique(cell2mat(comsolResultsTab.maxMeshSize)'); % mesh sizes list for convergence plot

paramsCombinationsTab = paramsCombinationsPrep(paramsList);
% Sort the table with parameters so the results for analytical model can be cached in T_eval_model if parameters do not change
paramsCombinationsTab = sortrows(paramsCombinationsTab, {'q', 'aX'});

% Calculate for each combination of parameters
comparativeStatsTab = table;
hWait = waitbar(0,'Calculating comparison statistics for you, please wait...'); %show progress bar for longer computations
for i = 1:size(paramsCombinationsTab,1)
    waitbar(i/size(paramsCombinationsTab,1), hWait); %show progress
    params = table2struct(paramsCombinationsTab(i,:));
    % Calculate comparative statistics for PLAN view
    [ comparativeStatsRow, Xmesh, Ymesh ] = ...
        comparativeStats( modelMethods, x_range, y_range, z, Mt, ...
                          timeTbh, timeTbh_max, T_plume_list, x_Tlist, ...
                          params, t_list, comsolResultsTab, variant);
    comparativeStatsTab(i,:) = comparativeStatsRow;
end
close(hWait); %close progress window

%% Plot preparation
% Sort data based on selected x axis values, as ascending maxMeshSize does not in all cases mean ascending mesh element number 
comparativeStatsTab = sortrows(comparativeStatsTab, {meshColumnName});

% Save comparative statistics table with unique parameter combinations into csv file
comparativeStatsSave(comparativeStatsTab, plotExportPath, modelMethods)

% Predefine xlabel for all subsequent plots based on chosen mesh size definition (from result table)
if strcmp(meshColumnName, 'elementsCountComsol') 
    xlabelPlot = 'Number of elements';
    showLegend = true;
else
    xlabelPlot = 'Max mesh size on heat source (m)';
    showLegend = true;
end
% Find x coordinate for optimal mesh
maxMeshSizeOptimal = paramsStd.maxMeshSize;
index_OptiMesh = find(comparativeStatsTab.maxMeshSize == maxMeshSizeOptimal, 1);
x_meshSizeOptimal = comparativeStatsTab.(meshColumnName)(index_OptiMesh);

%% Plot temperature difference at borehole for different meshes
if plot_Tb_mesh_q
    plotNamePrefix = 'Tb_mesh_q'; % plot name to save the plot with relevant name
    %Get values for plot
    y_T_bh_Diff_q = nan(numel(paramsList.q), numel(paramsList.maxMeshSize));
    if plot_relativeDiff
        y_T_bh_RelDiffPercent_q = nan(numel(paramsList.q), numel(paramsList.maxMeshSize));
    end
    legendTexts_q = cell(length(paramsList.q),1); % text for legends on plot    
    if plot_relativeDiff
        legendTexts_q = cell(length(paramsList.q)*2,1); % text for legends on plot
    end
    for iq = 1 : numel(paramsList.q)
        rows_q = comparativeStatsTab.q == paramsList.q(iq);
        y_T_bh_Diff_q(iq,:) = comparativeStatsTab.T_bh_Diff(rows_q);
     if plot_relativeDiff     
        y_T_bh_RelDiffPercent_q(iq,:) = comparativeStatsTab.T_bh_RelDiff(rows_q) * 100;
     end
     
        legendTexts_q{iq} = sprintf('v_D = %.3f m/day, difference', paramsList.q(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
     if plot_relativeDiff     
        legendTexts_q{iq + numel(paramsList.q)} = sprintf('v_D = %.3f m/day, relative %% diff.', paramsList.q(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec 
     end
    end
    % If requested, use absolute values so plots are not noisy
    if plot_absoluteDiff_1
        y_T_bh_Diff_q = abs(y_T_bh_Diff_q);
       if plot_relativeDiff     
            y_T_bh_RelDiffPercent_q = abs(y_T_bh_RelDiffPercent_q);
        end
    end
    % Choose prefered x axis values (element number or Comsol meshing size parameter)
    x_meshSize = comparativeStatsTab.(meshColumnName)(rows_q)';
    
    % Plot
    setFigSize( 1, 2.2 ); %size for single column figure
    fig = figure;
    colors = setColorOrder( [1 2 3 4 1 2 3 4] );
    blackColor = [0 0 0];
    %set(fig, 'defaultAxesColorOrder',colors);
    hold on
    %use same colors for usual velocities as in other plots
    yyaxis left
    axisObj = gca;
    axisObj.YColor = blackColor;
    for iq = 1 : numel(paramsList.q)
        plot(x_meshSize, y_T_bh_Diff_q(iq,:), 'Color', colors(iq,:), 'LineStyle', '-')
    end

    xlabel(xlabelPlot);
    ylabel('T_{bh} difference between models after 30 years (K)');
   
    
    if plot_relativeDiff     
        yyaxis right
        axisObj = gca;
        axisObj.YColor = blackColor;
        for iq = 1 : numel(paramsList.q)
            plot(x_meshSize, y_T_bh_RelDiffPercent_q(iq,:), 'Color', colors(iq,:), 'LineStyle', '--')
        end
        ylabel('Temperature change relative % difference');
    end
    
    % Plot line for selected optimal mesh size
    hold on
    axisObj = gca;
    plot([x_meshSizeOptimal, x_meshSizeOptimal], [axisObj.YLim(1), axisObj.YLim(2)], ...
                'Color', 'k', 'LineStyle', ':' )
    legendTexts_q{end+1} = 'Optimal mesh size';
    
    title('Comsol vs Analytical model (analytical - numerical)')
    if showLegend
        legend(legendTexts_q, 'Location', 'southoutside') %'NorthEast')
    end
    grid on
    if plotSave
        plotName = sprintf('convergence_%s_%s_%s', ...
                           plotNamePrefix, meshColumnName, cell2mat(modelMethods));                
        
        saveFig([plotExportPath plotName])
    end

end

%% Plot total RMSE vs number of elements in mesh
if plot_RMSE_mesh_q
    plotNamePrefix = 'RMSE_mesh_q'; % plot name to save the plot with relevant name
    if plot_MAE_mesh_q
        plotNamePrefix = 'plot_MAE_mesh_q';
    end
    %Get values for plot
    y_RMSEorMAE_q = nan(numel(paramsList.q), numel(paramsList.maxMeshSize));
    legendTexts_q = cell(length(paramsList.q),1); % text for legends on plot
    for iq = 1 : numel(paramsList.q)
        rows_q = comparativeStatsTab.q == paramsList.q(iq);
        if plot_MAE_mesh_q % for MAE
            y_RMSEorMAE_q(iq,:) = comparativeStatsTab.maeTotal(rows_q);
        else  % for RMSE
            y_RMSEorMAE_q(iq,:) = comparativeStatsTab.rmseTotal(rows_q);
        end
        
        legendTexts_q{iq} = sprintf('v_D = %.3f m/day', paramsList.q(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
    end
    x_meshSize = comparativeStatsTab.(meshColumnName)(rows_q)';
    
    % Plot
    setFigSize( 1, 1.5 ); %size for single column figure
    figure
    plot(x_meshSize, y_RMSEorMAE_q)
    % Plot line for selected optimal mesh size
    hold on
    axisObj = gca;
    plot([x_meshSizeOptimal, x_meshSizeOptimal], [axisObj.YLim(1), axisObj.YLim(2)], ...
        'Color', 'k', 'LineStyle', ':' )
    legendTexts_q{end+1} = 'Optimal mesh size';
    
    xlabel(xlabelPlot);
    if plot_MAE_mesh_q %MAE
        ylabel('MAE - all times, all positions (K)');
    else %RMSE
        ylabel('RMSE - all times, all positions (K)');
    end
    title('Comsol vs Analytical model')
    if showLegend
        legend(legendTexts_q, 'Location', 'southoutside') %'NorthEast')
    end
    grid on
    if plotSave
        plotName = sprintf('convergence_%s_%s_%s', ...
                           plotNamePrefix, meshColumnName, cell2mat(modelMethods));                
        saveFig([plotExportPath plotName])
    end
end

%% Plot max T difference for all positions and for all times, between models vs number of elements in mesh
if plot_TmaxDiff_mesh_q
    plotNamePrefix = 'TmaxDiff_mesh_q'; % plot name to save the plot with relevant name
    %Get values for plot
    y_TmaxDiff_q = nan(numel(paramsList.q), numel(paramsList.maxMeshSize));
    legendTexts_q = cell(length(paramsList.q),1); % text for legends on plot
    for iq = 1 : numel(paramsList.q)
        rows_q = comparativeStatsTab.q == paramsList.q(iq);
        y_TmaxDiff_q(iq,:) = comparativeStatsTab.T_max_Diff(rows_q);
        legendTexts_q{iq} = sprintf('v_D = %.3f m/day', paramsList.q(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
    end
    % If requested, use absolute values so plots are not noisy
    if plot_absoluteDiff_2
        y_TmaxDiff_q = abs(y_TmaxDiff_q);
    end
    % Choose prefered x axis values (element number or Comsol meshing size parameter)
    x_meshSize = comparativeStatsTab.(meshColumnName)(rows_q)';
    
    % Plot
    setFigSize( 1, 1.5 ); %size for single column figure
    figure
    plot(x_meshSize, y_TmaxDiff_q)
    % Plot line for selected optimal mesh size
    hold on
    axisObj = gca;
    plot([x_meshSizeOptimal, x_meshSizeOptimal], [axisObj.YLim(1), axisObj.YLim(2)], ...
        'Color', 'k', 'LineStyle', ':' )
    legendTexts_q{end+1} = 'Optimal mesh size';

    xlabel(xlabelPlot);
    % Max difference in temperature between models is in period between initial time and max time
    % used (300 years), in all points
    ylabel('Max. difference in T between models (K)'); 
    title('Comsol vs Analytical model')
    if showLegend
        legend(legendTexts_q, 'Location', 'southoutside') %'NorthEast')
    end
    grid on
    if plotSave
        plotName = sprintf('convergence_%s_%s_%s', ...
                           plotNamePrefix, meshColumnName, cell2mat(modelMethods));                
        saveFig([plotExportPath plotName])
    end

end
