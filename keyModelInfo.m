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
    [~, ~, xAbstraction, yAbstraction] = getWellCoords(params.a);
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
        T_eval_model(modelMethod, ro, y, z, ...
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
    % isotherm length (plume extent) and for timeForT_max (300 years)
    [xPlumeSS, yPlumeSS, zPlumeSS] = plumesForTimes( modelMethod, timeForT_max, T_plume_list,...
                                                    params, comsolResultsTab, [], variant );
    
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
    keyModelInfoRow.xPlumeSS = xPlumeSS;
    keyModelInfoRow.yPlumeSS = yPlumeSS;
    keyModelInfoRow.zPlumeSS = zPlumeSS;
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
end

