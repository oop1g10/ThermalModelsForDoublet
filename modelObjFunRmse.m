function objVal = modelObjFunRmse( paramValues, modelMethod, paramRanges, paramsStd, comsolResultsTab, variant)
%Compute model and RMSE
    % Set parameters to compute model
    params = getCalibParams(paramValues, paramRanges.name, paramsStd);
    % Display evaluated parameters and the count of model runs
    % (calculations)
    persistent runCount
    if isempty(runCount)
        runCount = 1;
    else
        runCount = runCount + 1;
    end     
    fprintf('RunCount: %d, Model parameters: %s\n', runCount, comsolParams2String( params ));

    % For current set of parameters run numerical Comsol model and return
    % the results in comsolResultsTab
    if isModelNumerical( modelMethod )
        comsolResultsTab = comsolRun(params, runCount, false);
    end
    
    % Not used for model and measurements comparison, so any values are ok
    timeTbh = comsolResultsTab.timeList{1}(1); 
    timeForT_max = comsolResultsTab.timeList{1}(2);
    T_plume_list = 1; 
    x_Tlist = 1;
    % Compute model and calculate comparison info (RMSE)
    keyModelInfoRow = keyModelInfo( timeTbh, timeForT_max, T_plume_list, x_Tlist, ...
                                      modelMethod, params, comsolResultsTab, variant);
    % Return value of objective function during process of calibration
    objVal = keyModelInfoRow.RMSEadj;
    % Remember the best obj function value
    persistent objValBest
    if isempty(objValBest)
        objValBest = objVal;
    elseif objVal < objValBest
        objValBest = objVal;        
    end
    if objValBest == objVal
        fprintf('RMSEadj: %f BEST\n', objVal);
    else
        fprintf('RMSEadj: %f\n', objVal);
    end
end


