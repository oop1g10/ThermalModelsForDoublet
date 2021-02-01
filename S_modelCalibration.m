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
warning('paramsStd equal to best fit for ansol')
bestFitParams = 'q[2.8128e-05] aXYZ[1.97503 1.97503 1.97503] ro[0.0762] H[6] M[6] adeg[278.74] T0[283.15] Ti[310.55] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[800.026] lS[1.90001] n[0.599998] mesh[0.1]';

% Prepare list of parameters for calibration with their ranges
paramRanges(1,:) = prepParamRange('LOG10_q', [], log10(1E-6), log10(1E-2), log10(2.8128e-05), NaN); % paramsStd.q
paramRanges(end+1,:) = prepParamRange('LINKED_aX', [], 0, 4, 1.97503, NaN); % aX
paramRanges(end+1,:) = prepParamRange('alpha_deg', [], 0, 360, 278.74, NaN); %alpha_deg
paramRanges(end+1,:) = prepParamRange('cS', [], 800, 1100, 800.026, NaN); %cS
paramRanges(end+1,:) = prepParamRange('lS', [], 1, 3.2, 1.90001, NaN); %lS
paramRanges(end+1,:) = prepParamRange('n', [], 0.3, 0.4, 0.35, NaN); %n
paramRanges(end+1,:) = prepParamRange('LINKED_H', [], 3, 9, paramsStd.H, NaN);

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


