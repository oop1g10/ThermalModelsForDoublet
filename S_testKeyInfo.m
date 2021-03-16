% Clean ALL is used here to clear persistent variables, in case input data is changed
% Persistent variables in function are used as cache.
clear all 
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
% params = paramsStd;
% params = paramsFromCalib('Numerical: q,aX,alpha,cS,lS,n,H RunCount:0488 WIDER ranges cS,H init 431', variant);
params = paramsFromCalib('Numerical2: RunCount: 411', variant);
keyModelInfoRow = keyModelInfo( timeTbh, timeForT_max, T_plume_list, x_Tlist, ...
                                  modelMethodPlot, params, comsolResultsTab, variant);
                              
