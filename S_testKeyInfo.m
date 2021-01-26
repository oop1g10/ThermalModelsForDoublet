clear
clear T_eval_model % clear persistent variables in function (used as cache)
% Take the name of file to load
[comsolDataFile, ~, modelMethods, ~, variant,...
    ~, methodMesh, ~, ~ ] = comsolDataFileInUse_Info( );
fprintf('methodMesh: %s\n', methodMesh);

% Set standard model parameters
[paramsStd, ~, ~] = standardParams(variant);
% Get list of different parameter ranges for plots
[ t_list, q_list, ~, x_range, y_range, z_range, Mt, y, z, ~, timeTbh, timeForT_max,...
    T_plume_list, ~, x_Tlist, ~, Q_list, a_list, coord_list_ObsWells ] = ...
    standardRangesToCompare( variant );

% 1 = Schulz/Homo; 2 = Comsol 2D
modelMethodPlot = modelMethods{2}; % Method of model calculation

% Load previously saved workspace variables with comsol data in comsolResultsTab
load(comsolDataFile)

%% Test calculation of key info for model and measurement comparison
params = paramsStd;
keyModelInfoRow = keyModelInfo( timeTbh, timeForT_max, T_plume_list, x_Tlist, ...
                                  modelMethodPlot, params, comsolResultsTab, variant);
                              
