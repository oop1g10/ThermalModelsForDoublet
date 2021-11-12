% Analyse one a time sensitivity analysis fro model parameters 

% Clean ALL is used here to clear persistent variables, in case input data is changed
% Persistent variables in function are used as cache.
clear all

%%
setFigSize( 1, 1 ); %size for single column figure
defaultLineWidth = get(groot,'defaultLineLineWidth');

%% Plots selections
% plots
plot_Tb_tSS_q = false; % plot % difference of temp at bh wall (delta K) and time to SS for diff gw flows
plot_xPlume = true; % Plume extent longitudinal (X) after required years (t) for required isotherms, T diff for various parameters  
plot_RMSEadj = false; %RMSEadj

% For the plots above CHOOSE WHICH PARAMETERS to plot
% One at a time sensitivity analysis
paramsFor_q = false;
paramsFor_aXYZ = false;
paramsFor_alpha_deg = false;
paramsFor_cS = false;
paramsFor_lS = false;
paramsFor_Ti = false;
paramsFor_n = false;
paramsFor_H = false;
paramsFor_Q = true;
paramsFor_a = false; 

%% Plot settings
plot_tSS_OnSamePlot = false; % if true per each plot there will be 4 lines: 2 for Tb or Xplume AND 2 lines for tSS times to stabilize them (relative diff) 
% if plot_tSS_OnSamePlot false, then 2 plots will be generated one for Tb(or xPlume) and another for time to stabilise them

%% Saving
resultsTableSave = false; % save comsol results table with qInfo and parameter values
plotSave = false;
plotExportPath = 'C:\Users\Asus\OneDrive\INRS\COMSOLfigs\doublet_2d_Becancour\';

%% Load previously saved workspace variables with comsol calculations in comsolResultsTab
[comsolDataFile, ~, modelMethods, ~, variant, solution, methodMesh, ~, ~ ] = ...
            comsolDataFileInUse_Info( );
% For one at a time sensitivity analysis the model methods are both
% numerical, first is with standard best fit parameters, the second is with
% param set from one at a time params set
% modelMethods = {'nDoublet2Dstd', 'nDoublet2D'};
modelMethods = {'SchulzStd', 'Schulz'};

fprintf('methodMesh: %s\n', methodMesh);

load(comsolDataFile)
        
modelMethod = modelMethods{2}; % plot for one method to be used
% Add missing columns to loaded result   
comsolResultsTab = addToTabAbsentParams( comsolResultsTab, variant );

modelTitle = [modelMethod '_' solution '_' methodMesh]; %text for plot titles and names to save the figures
plotTitle = modelTitle; plotTitle(plotTitle == '_') = '-'; %replace _ with - in plot title not to print as subscript

% Save results table in csv file
% if resultsTableSave
%     resultsTabSave( comsolResultsTab, plotExportPath )
% end

%% Calculation of comparative statistics for plots 
% Standard model parameters
paramsStd = standardParams(variant);

% Ranges for models comparison
[ t_list, ~, ~, x_range, y_range, ~, Mt, ~, z, ~, timeTbh, timeTbh_max, T_plume_list, ~, x_Tlist ] ...
                    = standardRangesToCompare( variant );     
% T_plume_list = [2];
% warning ('Plume list limited to 2K only ! ')

q_colorOrder = [2]; % standard colour

% Prepare unique combinations of parameters to analyse 
paramsCombinationsTab = ...
        standardParamsCombinations( variant, paramsFor_q, paramsFor_aXYZ, paramsFor_alpha_deg, paramsFor_cS, ... 
                                            paramsFor_lS, paramsFor_Ti, paramsFor_n, paramsFor_H, ...
                                            paramsFor_Q, paramsFor_a );                     
% Calculate for each combination of parameters
comparativeStatsTab = table;
% Calculate only when relevant plots are required 
if plot_Tb_tSS_q || plot_xPlume
    hWait = waitbar(0,'Calculating fracture parameters influence, please wait...'); %show progress bar for longer computations
    for i = 1:size(paramsCombinationsTab,1)
        waitbar(i/size(paramsCombinationsTab,1), hWait); %show progress
        params = table2struct(paramsCombinationsTab(i,:));
        % Calculate comparison key info (e.g. temperature at borehole wall) for PLAN view
        comparativeStatsRow = ...
            comparativeStats( modelMethods, x_range, y_range, z, Mt, ...
                              timeTbh, timeTbh_max, T_plume_list, x_Tlist,...
                              params, t_list, comsolResultsTab, variant);
        comparativeStatsTab(i,:) = comparativeStatsRow;
    end
    close(hWait); %close progress window
    %comparativeStatsTab

    % Plot relative difference (%) of temperature at pumping well (Tbh) 
    % and time to Steady State for Tbh

    % Prepare table for parameters for plot
    paramsPlotTab = paramsPlotTabPrep( variant, ...
        paramsFor_q, paramsFor_aXYZ, paramsFor_alpha_deg, paramsFor_cS, paramsFor_lS, ...
        paramsFor_Ti, paramsFor_n, paramsFor_H, paramsFor_Q, paramsFor_a);

    % Create plots for each changed parameter (x label) 
    for i = 1:size(paramsPlotTab, 1)
        if plot_Tb_tSS_q
            plotNamePrefix = 'Tb_tSS_q'; % plot name to save the plot with relevant name            
            plotOneParamChg_choicesFun(plotNamePrefix, q_colorOrder, paramsPlotTab.paramName{i}, paramsPlotTab.paramValue_list{i},...
                                    paramsPlotTab.xUnitCoef(i), paramsPlotTab.xUnitShift(i), ...
                                 paramsStd, comparativeStatsTab, 'T_bh', 1, '\DeltaT_b', 'K', timeTbh, ...% column T_bh has only one value so 1 is used
                                 'timeSS_Tbh', 1, 'TimeSS_b', 'day', ... % time units is in days
                                 paramsPlotTab.xLabel{i}, paramsPlotTab.useSemiLogX(i), ...                             
                                 plotSave, plotExportPath, variant, plot_tSS_OnSamePlot)                             
        end
              
        %% Extract data for plot 
        %% Plume extent longitudinal (X) after 50 years (t) for 1 K and 2 K isotherms T diff for various parameters
        if plot_xPlume
            plotNamePrefix = 'xPlume'; % plot name to save the plot with relevant name
            plotOneParamChg_choicesFun(plotNamePrefix, q_colorOrder, paramsPlotTab.paramName{i}, paramsPlotTab.paramValue_list{i},...
                                    paramsPlotTab.xUnitCoef(i), paramsPlotTab.xUnitShift(i), ...
                                 paramsStd, comparativeStatsTab, 'xPlume', 1, 'Plume extent in x coordinate', 'm', timeTbh, ...
                                 ... % [], 1, '', '', ... % second y is not used
                                 'xPlume', 2, 'Plume extent in x coordinate', 'm', ...
                                 paramsPlotTab.xLabel{i}, paramsPlotTab.useSemiLogX(i), ...                             
                                 plotSave, plotExportPath, variant, plot_tSS_OnSamePlot)                                         
        end
             
        if plot_RMSEadj %RMSEadj
            plotNamePrefix = 'RMSEadj'; % plot name to save the plot with relevant name            
            plotOneParamChg_choicesFun(plotNamePrefix, q_colorOrder, paramsPlotTab.paramName{i}, paramsPlotTab.paramValue_list{i},...
                                    paramsPlotTab.xUnitCoef(i), paramsPlotTab.xUnitShift(i), ...
                                 paramsStd, comparativeStatsTab, 'RMSEadj', 1, 'RMSE adjusted', '-', timeTbh, ...
                                 [], 1, '', '', ... % time units is in days
                                 paramsPlotTab.xLabel{i}, paramsPlotTab.useSemiLogX(i), ...                             
                                 plotSave, plotExportPath, variant, true)                             
        end
    end
end
