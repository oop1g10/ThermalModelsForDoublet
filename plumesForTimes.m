function [xPlume_times, yPlume_times, zPlume_times] = plumesForTimes( modelMethod, t_list, T_plume_list, params, comsolResultsTab, xPlumeSS )
    %% Find plume extent for timeforT (30 years) for given isotherm T_plume_list (for example 0.5 or 2 deg C)
    % Temperatures on the right hand side (downstream) of borehole (2D xy surface) 
    % for specific time timeforT (30 years) and for timeForT_max (300 years)
    
    % Take node coordinates from comsol results to determine possible x and y range
    % in plots. Taken from first results rows as all result should have same
    % geometry.
    [ xRangeLimits, yRangeLimits, ~ ] = comsol_xyzRanges( comsolResultsTab );

    y = 0; % Centered
    z = params.H/2; % Middle of borheole
    Mt = 200; % step s to find isotherm length at specific time
    % Due to straight triangular mesh cells around circular domain boundary, 
    % some points on the circle do not belong to any mesh cell (element), meshSizeBuffer ensures requested 
    % points belong to existing mesh elements.
    meshSizeBuffer = 2; %m
    % Get x coordinate of Injection well
    [xInjection, ~, ~, ~] = getWellCoords(params.a);
    % Set area to search the plume on one side from the injection well TODO intermediate step!!!!!!!!!!
    xRangeLimitsForXPlumeSearch = [xInjection, xRangeLimits(2)-meshSizeBuffer];
    yRangeLimitsForXPlumeSearch = [yRangeLimits(1) + meshSizeBuffer, ...
                                   yRangeLimits(2) - meshSizeBuffer ];
    % largest plume for profile may not be at excactly z = 50 (H/2), so search the whole VBHE length.
    zRangeLimitsForXPlumeSearch = [0, params.H]; 

    xPlume_times = nan(numel(t_list), numel(T_plume_list));
    yPlume_times = nan(numel(t_list), numel(T_plume_list));
    zPlume_times = nan(numel(t_list), numel(T_plume_list));
    % start looping from about 1 day because steady state for plumes never happens before that
    itStart = find(secondsToDays(t_list) > 1, 1); % find first index of times when time > 1 day
    for it = itStart:numel(t_list) 
        % prepare T values to find plume extent for plan view (x y)
        [~, ~, T_mesh_plan, Xmesh_plan, Ymesh_plan, ~ ] = ...
            T_eval_model(modelMethod, xRangeLimitsForXPlumeSearch, yRangeLimitsForXPlumeSearch, z, ...
                         Mt, params, t_list(it), comsolResultsTab, 'T');
        % prepare T values to find plume extent for profile view (x z)
        if isModel3D(modelMethod)
            [~, ~, T_mesh_profile, Xmesh_profile, ~, Zmesh_profile ] = ...
                T_eval_model(modelMethod, xRangeLimitsForXPlumeSearch, y, zRangeLimitsForXPlumeSearch, ...
                             Mt, params, t_list(it), comsolResultsTab, 'T');
        end
        % Find interpolated length along x axis for given isotherms in T_plume_list
        for ip = 1:numel(T_plume_list)
            [xPlume_plan, xValueRow] = interpolateXforY(T_mesh_plan, T_plume_list(ip), ...
                                                        Xmesh_plan, '+down');
            if ~isnan(xValueRow)
                yPlume_plan = Ymesh_plan(xValueRow, 1); % Take y coordinate for the mesh row on which max plume extent was found 
            else
                yPlume_plan = NaN;
            end
            if isModel3D(modelMethod)
                [xPlume_profile, xValueRow] = interpolateXforY(T_mesh_profile, T_plume_list(ip), ...
                                                               Xmesh_profile, '+down');
                if ~isnan(xValueRow)
                    zPlume_profile = Zmesh_profile(xValueRow, 1); % Take y coordinate for the mesh row on which max plume extent was found 
                else
                    zPlume_profile = NaN;
                end
            else
                xPlume_profile = NaN; % profile values are not available for 2D model
            end
            % if profile plume extent is available and is larger than plan isotherm extent, than take profile
            if xPlume_profile > xPlume_plan % this can be true only for 3D model
                xPlume_times(it, ip) = xPlume_profile;
                yPlume_times(it, ip) = y;
                zPlume_times(it, ip) = zPlume_profile;
            else
                xPlume_times(it, ip) = xPlume_plan;
                yPlume_times(it, ip) = yPlume_plan;
                zPlume_times(it, ip) = z;
            end
        end
        % check that plume extents for the first time are lower or equal to the steady state if it is given
        if it == itStart && ~isempty(xPlumeSS)
            % if starting plume has already reached steady state at initial time (10 days) then the search shoudl have started sooner   
            if any(xPlume_times(it) >= xPlumeSS)
                error(' Plume extent has already reached steady state at initial time (10 days), the search should have started sooner!')
            end
        end
        % if determined Xplume is already as large as steady state plume extent, xPlplumeSS, then stop searching X plumes for larger times 
        if all(xPlume_times(it) >= xPlumeSS) && ~isempty(xPlumeSS)
            break % exit the loop for time list
        end
    end

end

