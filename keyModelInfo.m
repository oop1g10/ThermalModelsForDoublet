function keyModelInfoRow = keyModelInfo( timeForT, timeForT_max, T_plume_list, x_Tlist, ...
                                         modelMethod, params, comsolResultsTab, variant)
% Extract key information from model output
% Borehole wall temperature change (maximum downstream side on borehole)
% after 30 years and after 300 years
% Time to stabilize temperature at borehole wall
% Plume length donwstream (0.5 and 2K isotherms) after 30 years
% Time to stabilize plume length growth downstream

    y = 0; % Centered
    z = params.H/2; % Middle of borheole
    ro = params.ro;
    t_list = comsolResultsTab.timeList{1};
    
    %% Temperature at abstraction well at time timeForT
    Mt_single = 1; % single point need at abstraction well
    [xInjection, yInjection, xAbstraction, yAbstraction] = getWellCoords(params.a);
    [T_bh, ~, ~, ~, ~, ~, elementsCountComsol, comsolResultsRow ] = ...
        T_eval_model(modelMethod, xAbstraction, yAbstraction, z, ...
                     Mt_single, params, timeForT, comsolResultsTab, 'T', variant);
                 
    % Temperature at abstraction well at time timeTbh_max
    [T_bh_max, ~, ~, ~, ~, ~ ] = ...
        T_eval_model(modelMethod, xAbstraction, yAbstraction, z, ...
                     Mt_single, params, timeForT_max, comsolResultsTab, 'T', variant);
                 
    % Time to reach steady state temperature at borehole wall
    % 0.99 is used to lower the max temperature at borehole by 1 %
    [ ~, ~, ~, ~, ~, ~, ~, ~, ~, T_SS_low ] = standardRangesToCompare( variant );   
    T_bh_SS = T_bh_max * T_SS_low;
    % Temperatures at borehole wall for all available times
    [T_bh_t, ~, ~, ~, ~, ~ ] = ...
        T_eval_model(modelMethod, xAbstraction, yAbstraction, z, ...
                     Mt_single, params, t_list, comsolResultsTab, 'T', variant);
    % Find interpolated time for almost steady state temperature at bh wall
    timeSS_Tbh = interpolateXforY(T_bh_t, T_bh_SS, t_list, '+up');
    
    %% Temperature at other positions at time timeForT
    T_x = T_eval_model(modelMethod, x_Tlist, y, z, [], params, timeForT, comsolResultsTab, 'T', variant)';
    
    %% Find plume extent for timeforT (30 years) for given isotherm T_plume_list (for example 0.5 or 2 deg C)
    % Temperatures measured on the right hand side (downstream) of borehole (2D xy surface) 
    % isotherm length (plume extent) for specific time timeforT (30 years)
    [xPlume, yPlume, zPlume] = plumesForTimes( modelMethod, timeForT, T_plume_list, params, ...
                                                comsolResultsTab, [], variant );
    % Calculate plume length after timeForT  
    plumeLength = sqrt((xPlume - xInjection).^2 + (yPlume - yInjection).^2 + (zPlume - z).^2);
    
    % isotherm length (plume extent) and for timeForT_max (300 years)
    [xPlumeSS, yPlumeSS, zPlumeSS] = plumesForTimes( modelMethod, timeForT_max, T_plume_list,...
                                                    params, comsolResultsTab, [], variant );
    % Calculate plume length after timeForT_max  
    plumeLengthSS = sqrt((xPlumeSS - xInjection).^2 + (yPlumeSS - yInjection).^2 + (zPlumeSS - z).^2);
    
    %% Find time to reach steady state for given isotherm
    % lower isotherm extent by 1%   to find when it reached steady state
    % NEW SLOW SLOW METHOD, historical
%     xPlumeSS_lower = xPlumeSS * T_SS_low;
%     [xPlume_times, ~, ~] = plumesForTimes( modelMethod, t_list, T_plume_list, params, comsolResultsTab, xPlumeSS_lower, variant );
%     % replace NaNs for zeros as interpolateXforY can only work with real numbers, NaN means plume did not reach anything (given T did not occur yet)
%     xPlume_times(isnan(xPlume_times)) = 0;
%     % Find interpolated time for almost steady state temperature at x plume    
%     timeSS_xPlume = nan(1, numel(T_plume_list));
%     for i = 1:numel(T_plume_list)
%         % Temperatures at x where isotherm plume was calculated for all available times
%         if isnan(xPlumeSS(i)) % if plume extent was not found, for example it is outside the domain
%             timeSS_xPlume(i) = NaN;
%         else
%             timeSS_xPlume(i) = interpolateXforY(xPlume_times(:,i)', xPlumeSS_lower(i), t_list, 'up');
%         end
%     end
    
    % Find time to reach steady state for given isotherm
    T_plume_list_SS = T_plume_list * T_SS_low;
    timeSS_xPlumeOld = nan(1, numel(T_plume_list));
    for i = 1:numel(T_plume_list)
        % Temperatures at x where isotherm plume was calculated for all available times
        if isnan(xPlumeSS(i)) % if plume extent was not found, for example it is outside the domain
            timeSS_xPlumeOld(i) = NaN;
        else
            [T_xPlume_t, ~, ~, ~, ~, ~ ] = ...
                T_eval_model(modelMethod, xPlumeSS(i), yPlumeSS(i), zPlumeSS(i), ...
                             Mt_single, params, t_list, comsolResultsTab, 'T', variant);
            % Find interpolated time for almost steady state temperature at x plume
            timeSS_xPlumeOld(i) = interpolateXforY(T_xPlume_t, T_plume_list_SS(i), t_list, '+up');
%             if timeSS_xPlume(i) > 9e9
%                 error('300 years to reach SS time for isotherm! is wrong')
%             end
        end
    end   
    
    %% Preparation of key Info row
    % Adjust params depending on model method:
    % If Homo (Simple as analytical solution) model is used, need to use Homo params, 
    % this will allow to have unique result rows are final result, 
    % otherwise Homo and Hetero models will have same params for same simulation in Monte Carlo and it will 
    % be hard to find unique row from table
    params = paramsHomoAdjust( params, modelMethod ); 
    keyModelInfoRow = struct2table(params);
    
    keyModelInfoRow.modelMethod = {modelMethod}; % give it as cell to avoid dimension mismatch
    keyModelInfoRow.T_bh = T_bh;
    keyModelInfoRow.T_bh_max = T_bh_max;
    keyModelInfoRow.timeSS_Tbh = timeSS_Tbh;
    keyModelInfoRow.T_x = T_x;
    keyModelInfoRow.xPlume = xPlume;
    keyModelInfoRow.yPlume = yPlume;
    keyModelInfoRow.zPlume = zPlume;
    keyModelInfoRow.plumeLength = plumeLength;
    keyModelInfoRow.xPlumeSS = xPlumeSS;
    keyModelInfoRow.yPlumeSS = yPlumeSS;
    keyModelInfoRow.zPlumeSS = zPlumeSS;
    keyModelInfoRow.plumeLengthSS = plumeLengthSS;
    % Old method is used because new method much slower  
    keyModelInfoRow.timeSS_xPlume = timeSS_xPlumeOld; % new method --> timeSS_xPlume;
    keyModelInfoRow.elementsCountComsol = elementsCountComsol;
    
    %% Attach to results row q info columns
    % Currrently q Info not used not needed.because all gw velocitites are exported from Comsol
    if ~isempty(comsolResultsRow) && ... % for COMSOL 
       any(strcmp(comsolResultsRow.Properties.VariableNames, 'q_frMax')) % and columns with velocities exist (they may not for older exports)
%         keyModelInfoRow.q_frMax = comsolResultsRow.q_frMax;
%         keyModelInfoRow.volume_5K30y = comsolResultsRow.volume_5K30y;
%         keyModelInfoRow.area_5K30y = comsolResultsRow.area_5K30y;
    else % For only analytical models, fracture does not exist
%         keyModelInfoRow.q_frMax = NaN;
%         keyModelInfoRow.volume_5K30y = NaN;
%         keyModelInfoRow.area_5K30y = NaN;
    end
    
    %% Add comparison between measured and modelled temperatures
    % Comparison is done for times which are both measured and modelled
    t_listComparison = timesForComparison(variant);
    keyModelInfoRow.t_listComparison = {t_listComparison};
    
    % Get list of wells with coordinates to compare, columns with Temperatures and RMSE comparisons will be added
    well_T_comparison = wellCoordinates(variant);
    % For test 2 well 6 will be used only to validate the model result with time
    % to thermal breakthrough. RMSE is not calculated for well 6 because it
    % is influenced by heat injection from test 1.
    if strcmp(variant, 'FieldExp2') 
        well_T_comparison = well_T_comparison(~strcmp(well_T_comparison.wellName, 'aquifro6'), :);   
    end

    % Add columns with modelled and measured Temperature and RMSE for each well for comparison times
    well_T_comparison.T_model = cell(size(well_T_comparison, 1), 1);
    well_T_comparison.T_measured = cell(size(well_T_comparison, 1), 1);
    well_T_comparison.RMSE = nan(size(well_T_comparison, 1), 1);
    well_T_comparison.RMSEadj = nan(size(well_T_comparison, 1), 1); % adjusted RMSE
    % Depths from which to take measured temperatures
    [ ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ... 
        measuredWellDepth_range] = standardRangesToCompare( variant );
    % For each well
    for i = 1 : size(well_T_comparison, 1)
        % Add column with MODELLED T for each well for comparison times
        well_T_comparison.T_model{i} = ...
            T_eval_model(modelMethod, well_T_comparison.x(i), well_T_comparison.y(i), z, ...
                     Mt_single, params, t_listComparison, comsolResultsTab, 'T', variant);
        well_T_comparison.T_model{i}(well_T_comparison.T_model{i} < -1) = NaN;
        well_T_comparison.T_model{i}(well_T_comparison.T_model{i} < 0) = 0;
        
        % Add column with MEASURED T for each well for comparison times
        well_T_comparison.T_measured{i} = ...
            T_wellMeasured(well_T_comparison.x(i), well_T_comparison.y(i), measuredWellDepth_range, t_listComparison, variant);
        % Calculate RMSE for each well between model and measurement
        well_T_comparison.RMSE(i) = calcRmseMae(well_T_comparison.T_measured{i}, well_T_comparison.T_model{i}, 2);
        % Calculate adjusted RMSE (see excel) so difference for each well have similar importance in resulting objective value which is their sum
        T_MaxMinDiff = max(well_T_comparison.T_measured{i}) - min(well_T_comparison.T_measured{i});
        % If all measured temepratures are the same (e.g. initial) then T_MaxMinDiff is zero
        % Division by zero is not possible. Use a small value instead
        if T_MaxMinDiff < 0.1
            T_MaxMinDiff = 0.1;
        end
        well_T_comparison.RMSEadj(i) =  well_T_comparison.RMSE(i) / T_MaxMinDiff;
    end     
    % Give larger weight to RMSE adj for well 4 to achieve better
    % calibration for test 2 measurements
    if strcmp(variant, 'FieldExp2') 
        well_T_comparison.RMSEadj(strcmp(well_T_comparison.wellName, 'aquifro4')) = ...
            well_T_comparison.RMSEadj(strcmp(well_T_comparison.wellName, 'aquifro4')) * 5; 
    end
    
    % Add table with comparisons to keyInfo as a cell
    keyModelInfoRow.well_T_comparison = {well_T_comparison};

    % Add sum of adjusted RMSE to keyInfo (objective value to be used for parameters fitting)
    keyModelInfoRow.RMSEadj = sum(well_T_comparison.RMSEadj(~isnan(well_T_comparison.RMSEadj)));
    
    
    %% Calculation of breakthrough times
    % Get coordinates for breakthrough time calculation on wells
    wellCoords = wellCoordinates(variant);
    % For each coordinate calculate break through time
    for iWell = 1 : size(wellCoords, 1)
        % Calculate time to breakthrough
        [~, ~, ~, ~, ~, ~, ~, ~, t_b ] = ...
            T_eval_model(modelMethod, wellCoords.x(iWell), wellCoords.y(iWell), z, ...
                         Mt_single, params, timeForT, comsolResultsTab, 't_b', variant);
        % Assign time to breakthrough to results table
        t_b_columnName = ['t_b_',  wellCoords.wellName{iWell}];
        keyModelInfoRow.(t_b_columnName) = t_b;
    end

end

