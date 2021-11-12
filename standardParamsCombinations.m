function paramsCombinationsTab = ...
        standardParamsCombinations( variant, paramsFor_q, paramsFor_aXYZ, paramsFor_alpha_deg, paramsFor_cS, ... 
                                            paramsFor_lS, paramsFor_Ti, paramsFor_n, paramsFor_H, ...
                                            paramsFor_Q, paramsFor_a   )
% Prepare unique combinations of parameters 
    % Standard parameters 
    paramsStd = standardParams(variant);
    
    % Standard parameters lists for analysis
    [q_list, aXYZ_list, alpha_deg_list, cS_list, lS_list, Ti_list, n_list, H_list, ...
                 Q_list, a_list] = ...
            standardRangesToCompare_oneAtATime(variant);
    
    % For each parameter (while other params fixed) prepare combinations
    paramsCombinationsTab = table;
    if paramsFor_q
        paramsList = paramsStd;
        paramsList.q = q_list;
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    end
    if paramsFor_aXYZ
        paramsList = paramsStd;
        paramsList.aX = aXYZ_list(:,1)';
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    end
    if paramsFor_alpha_deg
        paramsList = paramsStd;
        paramsList.alpha_deg = alpha_deg_list;
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    end
    if paramsFor_cS
        paramsList = paramsStd;
        paramsList.cS = cS_list;
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    end
    if paramsFor_lS
        paramsList = paramsStd;
        paramsList.lS = lS_list;
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    end
    if paramsFor_Ti
        paramsList = paramsStd;
        paramsList.Ti = Ti_list;
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    end
    if paramsFor_n
        paramsList = paramsStd;
        paramsList.n = n_list;
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    end
    if paramsFor_H
        paramsList = paramsStd;
        paramsList.H = H_list;
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    end
        
   if paramsFor_Q
        paramsList = paramsStd;
        paramsList.Q = Q_list;
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
   end
    
    if paramsFor_a
        paramsList = paramsStd;
        paramsList.a = a_list;
        % Prepare combinations of all parameters to run model through
        paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    end
   
    % Remove duplicated parameter combinations
    paramsCombinationsTab = unique(paramsCombinationsTab);

end

