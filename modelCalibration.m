function [paramsCalib, comsolResultsRowCalib] = ...
    modelCalibration(modelMethod, paramRanges, paramsStd, comsolResultsTab, variant)
% Fit the best parameters for calibration period

%% Fit model parameters
[paramValues, objVal, exitVal, info] = ...
    fminsearchbnd(@modelObjFunRmse, ...
        paramRanges.mean_best , ... % initial values to start calibration
        paramRanges.min, ...
        paramRanges.max, ...
        optimset('MaxIter', 10000, 'MaxFunEvals', 20000, 'TolX', 1e-6, 'TolFun', 1e-6), ...
        ... % these additional parameters will be used for calling modelObjFunRmse
        modelMethod, paramRanges, paramsStd, comsolResultsTab, variant); 
% Print optimizations message
fprintf('%s', info.message);

%Best-fit (calibrated) parameters :)
paramsCalib = getCalibParams( paramValues, paramRanges.name, paramsStd); %without ; to show result

%% Import line with results for best-fit params
    comsolResultsRowCalib = [];
end

