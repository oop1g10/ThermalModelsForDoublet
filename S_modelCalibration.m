clear
% Clean ALL is used here to clear persistent variables, in case input data is changed
% Persistent variables in function are used as cache.
clear all 

% Automated calibration was carried out in MATLAB using the Nelder-Mead simplex method 
% to find minimum of objective function (Nelder & Mead 1965).
% Nelder, J. A. and R. Mead. 1965. A Simplex Method for Function Minimization. The Computer Journal 7: 308-313.

% Take the model method to calibrate
[comsolDataFile, ~, modelMethods, ~, variant, ~, methodMesh, ~, ~ ] = comsolDataFileInUse_Info( );
fprintf('methodMesh: %s\n', methodMesh);

% Set standard model parameters
paramsStd = standardParams(variant);

% 1 = Schulz/Homo; 2 = Comsol 2D
modelMethod = modelMethods{2}; % Method of model for calibration
fprintf('Model method: %s\n', modelMethod);

% Load previously saved workspace variables with comsol data in comsolResultsTab
load(comsolDataFile)
disp('paramsStd equal to best fit for ansol')
% paramsCalib = paramsFromCalib('Analytical: q,aX,alpha,cS,lS,n', variant);
paramsCalib = paramsFromCalib('Numerical: q,aX,alpha,cS,lS,n,H RunCount:447 diff T0,lS,n init as ansol', variant);
paramsInit = paramsCalib;

% Prepare list of parameters for calibration with their ranges
paramRanges(1,:) = prepParamRange('LOG10_q', [], log10(1E-6), log10(1E-2), log10(paramsInit.q), NaN); % paramsStd.q
paramRanges(end+1,:) = prepParamRange('LINKED_aX', [], 0, 4, paramsInit.aX, NaN); % aX
paramRanges(end+1,:) = prepParamRange('alpha_deg', [], 0, 360, paramsInit.alpha_deg, NaN); %alpha_deg
paramRanges(end+1,:) = prepParamRange('cS', [], 800, 1100, paramsInit.cS, NaN); %cS
paramRanges(end+1,:) = prepParamRange('lS', [], 1, 3.2, paramsInit.lS, NaN); %lS
paramRanges(end+1,:) = prepParamRange('n', [], 0.3, 0.4, paramsInit.n, NaN); %n
paramRanges(end+1,:) = prepParamRange('LINKED_H', [], 3, 9, paramsInit.H, NaN);

% Show in command window calibrated parameters and their ranges
paramRanges

% Try artificial injection temperature for analytical model fitting
% warning('test only')
% paramsStd.Ti = paramsStd.T0 + 4.5;

%% Fit the best parameters for calibration period
[paramsCalib, comsolResultsRowCalib] = modelCalibration(modelMethod, paramRanges, paramsStd, comsolResultsTab, variant);

%% If numerical model is used the remove model from comsol server memory (close mph file) and disconnect from comsol server
if isModelNumerical( modelMethod )    
    import com.comsol.model.*  % pathway to comsol utilities for them to work
    import com.comsol.model.util.*
    ModelUtil.remove('model') % close mph in server
    ModelUtil.disconnect;    % close comsol server
end


