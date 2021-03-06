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
modelMethod = modelMethods{1}; % Method of model for calibration
fprintf('Model method: %s\n', modelMethod);

% Load previously saved workspace variables with comsol data in comsolResultsTab
load(comsolDataFile)
disp('paramsStd equal to best fit for ansol')
% paramsCalib = paramsFromCalib('Analytical: q,aX,alpha,cS,lS,n', variant);
% paramsCalib = paramsFromCalib('Numerical2: RunCount:558 WIDER ranges init 431. zerodisp', variant);
% paramsCalib = paramsFromCalib('Numerical2: RunCount: 482 modif', variant); 
paramsCalib = paramsFromCalib('Numerical2: 424', variant); % Numerical best fit test 2 set as initial values for ansol calib
paramsInit = paramsCalib;

% Prepare list of parameters for calibration with their ranges
paramRanges = table;
%% warning('groundwater flow faster initial value')
paramRanges(end+1,:) = prepParamRange('LOG10_q', [], log10(1E-6), log10(1E-2), log10(paramsInit.q), NaN); % paramsStd.q
% paramRanges(end+1,:) = prepParamRange('alpha_deg', [], 100, 300, paramsInit.alpha_deg, NaN); %alpha_deg 0 360
paramRanges(end+1,:) = prepParamRange('alpha_deg', [], 240, 300, paramsInit.alpha_deg, NaN); %alpha_deg 0 360
paramRanges(end+1,:) = prepParamRange('cS', [], 600, 1100, paramsInit.cS, NaN); %cS
if strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated')
    paramRanges(end+1,:) = prepParamRange('lS', [], 1, 2.5, 1.5, NaN); %lS based on field measurements
    paramRanges(end+1,:) = prepParamRange('Ti', [], degC2kelvin(29), degC2kelvin(31), degC2kelvin(29.2), NaN); %lS based on field measurements
    if ~strcmp(variant, 'FieldExp2Rotated')
        paramRanges(end+1,:) = prepParamRange('LINKED_aX', [], 0, 2, 1, NaN); % aX
    end
    paramRanges(end+1,:) = prepParamRange('n', [], 0.1, 0.4, paramsInit.n, NaN); %n
elseif strcmp(variant, 'FieldExp1m')
    paramRanges(end+1,:) = prepParamRange('lS', [], 1, 3, paramsInit.lS, NaN); %lS based on field measurements
    paramRanges(end+1,:) = prepParamRange('n', [], 0.1, 0.4, paramsInit.n, NaN); %n
else
    paramRanges(end+1,:) = prepParamRange('lS', [], 1, 4, paramsInit.lS, NaN); %lS
    paramRanges(end+1,:) = prepParamRange('n', [], 0.2, 0.4, paramsInit.n, NaN); %n
end
paramRanges(end+1,:) = prepParamRange('LINKED_H', [], 1, 9, paramsInit.H, NaN);
% During test 1 the water injection was reduced due to well clogging, and
% water overflew the well, by unknown amount. therefore after well clogging occured the water flow is fitted
if strcmp(variant, 'FieldExpAll') || strcmp(variant, 'FieldExp1m')
    paramRanges(end+1,:) = prepParamRange('Qb', [], 0.00041/10, 0.00041, 0.00041/2, NaN);       
end
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


