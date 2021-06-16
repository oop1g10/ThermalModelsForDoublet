function [T_points_t, points_Coords, T_mesh, Xmesh, Ymesh, Zmesh, ...
          elementsCountComsol, comsolResultsRow, t_b_mesh, v_x_mesh, v_y_mesh, H_mesh] = ...
    T_eval_model(modelMethod, x_range, y_range, z_range, Mt, params, t_list, comsolResultsTab, evalTask, variant)
% Model inputs
% modelMethod - method of model "comsol" or MILS or MFLS
% x_range - has to be range as from to (e.g. [2 3], if only signle x point needed to be computed range should be
%           given as a single value, e.g. 2, provided that y and z are also single values. 
% y_range, z_range - can be given as signle value or a range (from to), either y or z should be fixed point 
%                    e.g. [2 2], i.e. both cannot be given as a list e.g. [2 3]
% Mt - number of steps to divide the range into
%       If Mt is [] EMPTY than it means that no space discretisation is needed and the x-list is taken directly from x_range (to evaluate T at separate point)
% params - structure with parameters
% t_list - list of times (seconds)
% comsolResultsTab - table with all Comsol results (Temperatures and times and positions and element triangulation)
% varOut -  'T' to return Temperatures,
%           't_b' to return time to break through
%           'v' to return velocities
%           'H' to return hydraulic potentials
%   for Example: 'T, t_b'

% Calculate Temperature mesh for selected fixed parameters
% modelMethod - model to calculate, can be numerical Comsol model (named as 'nMFLSfr', 'nMFLS', 'nMILSfr', 'nMILS') 
%                                                                   or analytical solution named as 'MFLS', 'MILS' 

    [ ~, ~, deltaH, ~, ~, ~, N_Schulz_streamline] = standardParams( variant );
    
    % If only single point should be evaluated, convert it to a "range" 
    % as the function used expects a "range" even for single points
    if numel(x_range) == 1 && numel(y_range) == 1 && numel(z_range) == 1
        x_range = [x_range, x_range] ;
        y_range = [y_range, y_range] ;        
    end
    
    % Space discretization for both wells accounting for log and lin spacing areas in model domain
    [ points_Coords, Xmesh, Ymesh, Zmesh, x_list, y_list, z_list ] = ...
           spaceDiscretisation(x_range, y_range, z_range, Mt, ...
                               params.ro, params.a, comsolResultsTab, variant);
    % Preallocate results if not requested
    T_points_t = nan(size(points_Coords,1), numel(t_list));
    T_mesh = nan(numel(y_list) * numel(z_list), numel(x_list)); 
    t_b_mesh = nan(numel(y_list) * numel(z_list), numel(x_list)); 
    v_x_mesh = nan(numel(y_list) * numel(z_list), numel(x_list)); 
    v_y_mesh = nan(numel(y_list) * numel(z_list), numel(x_list)); 
    H_mesh = nan(numel(y_list) * numel(z_list), numel(x_list));    
    elementsCountComsol = NaN; % element count cannot be determined
    
    %% Temperature evaluation for models
    %% For COMSOL
    if isModelNumerical( modelMethod ) % First argument says logic if model method is numerical.
        % If results with "deactivated" fracture are requested (nMILS or nMFLS)
        params = paramsHomoAdjust( params, modelMethod, variant );        
        % Parameters from comsol result
        if numel(z_range) == 1 && z_range == params.H/2 ... % if z coordinate is fixed and equals to standard z (mid borehole depth)
                && ~(numel(y_range) == 1 && y_range == 0) % if y = 0 do not use plan view, use profile view instead because it also covers  Pipe Temperatures
            fixedCoord = [NaN, NaN, points_Coords(1,3)]; % plan data will be used
        elseif numel(y_range) == 1 % if y coordinate is fixed
            fixedCoord = [NaN, points_Coords(1,2), NaN]; % profile data will be used
        else
            error('Please provide only SINGLE value for either y range or z range (or for both)!')
        end
        
        % prepare matrices for results        
        % Get comsol results rows
        comsolResultsRow = comsolResultsRowForParams( comsolResultsTab, params, fixedCoord, variant );
        % If result found
        if size(comsolResultsRow,1) == 1
            % Element count in mesh
            elementsCountComsol = comsolElementsCount(modelMethod, comsolResultsRow);

            % If requested Temperature return it
            if contains(evalTask, 'T')
                % Get temperatures for points of interest and selected times for current q
                [T_points_t, ~] = comsolInterpolatePointValues( comsolResultsRow, points_Coords, ...
                                                            'T_nodeTime', 'timeList', t_list);                                                         
                % Make matrix from list, rows for y or z coordinate, columns for x coordinate
                % Reshape can be done only for 1 time
                if numel(t_list) == 1
                    % Either y_list or z_list will contain only one element
                    T_mesh = reshape(T_points_t, numel(y_list) * numel(z_list), numel(x_list));
                else
                    T_mesh = [];
                end 
            end
            
            % If requested time to breakthough return it
            if contains(evalTask, 't_b')
                % Get time to breakthrough for points of interest for current q
                % 1% is used to change the initial aquifer temperature to detect T breaktrhough time
                % T breakthough (T diff) should be about 1 deg K (if max T diff is high, e.g. 27 deg K) because if
                % it is lower and t dispersivity is high, then thermal
                % breakthough reaches observation wells in the first second
                % of calculation.
%                 T_breakthrough = (params.Ti - params.T0) * 0.01;
                T_breakthrough = 1; % T difference in deg Kelvin
                % Temperatures at selected locations for all available times
                t_list_all = comsolResultsTab.timeList{1};
                T_points_tb_t = T_eval_model(modelMethod, x_range, y_range, z_range, ...
                                             Mt, params, t_list_all, comsolResultsTab, 'T', variant);                
                % Find interpolated time for breakthrough temperature at selected points
                time_points_tb = nan(size(T_points_tb_t, 1), 1); % preallocate for fast calc
                for ip = 1 : size(T_points_tb_t, 1) % for each row i.e. point                   
                    time_points_tb(ip) = ...
                        interpolateXforY(T_points_tb_t(ip, :), T_breakthrough, t_list_all, '+up'); 
                    % If all temperatures are higher than the breakthrough
                    % temperature means the breakthrough happened before
                    % the first time. --> Use the first time as a result
                    if min(T_points_tb_t(ip, :)) > T_breakthrough
                        time_points_tb(ip) = t_list_all(1);
                    end
                end
                % Reshape = Make matrix from list, rows for y or z coordinate, columns for x coordinate
                % Either y_list or z_list will contain only one element
                t_b_mesh = reshape(time_points_tb, numel(y_list) * numel(z_list), numel(x_list));
            end    
            
            % If requested velocity in x and y diretion return it           
            if contains(evalTask, 'v')
                % Get velocities in x and y direction for points of interest and selected times for current q
                [v_x_points_t, ~] = comsolInterpolatePointValues( comsolResultsRow, points_Coords, ...
                                                            'v_x_nodeTime', 'timeList', t_list);  
                [v_y_points_t, ~] = comsolInterpolatePointValues( comsolResultsRow, points_Coords, ...
                                                            'v_y_nodeTime', 'timeList', t_list);  
                % Make matrix from list, rows for y or z coordinate, columns for x coordinate
                % Reshape can be done only for 1 time
                if numel(t_list) == 1
                    % Either y_list or z_list will contain only one element
                    v_x_mesh = reshape(v_x_points_t, numel(y_list) * numel(z_list), numel(x_list));
                    v_y_mesh = reshape(v_y_points_t, numel(y_list) * numel(z_list), numel(x_list));
                else
                    v_x_mesh = [];
                    v_y_mesh = [];
                end 
            end
            
            % If requested hydraulic potential, return it
            if contains(evalTask, 'H')
                % Get hydraulic potential for points of interest and selected times for current q
                [H_points_t, ~] = comsolInterpolatePointValues( comsolResultsRow, points_Coords, ...
                                                            'Hp_nodeTime', 'timeList', t_list);                                                       
                % Make matrix from list, rows for y or z coordinate, columns for x coordinate
                % Reshape can be done only for 1 time
                if numel(t_list) == 1
                    % Either y_list or z_list will contain only one element
                    H_mesh = reshape(H_points_t, numel(y_list) * numel(z_list), numel(x_list));
                else
                    H_mesh = [];
                end 
            end            
            
        else % results not found
            % leave NaNs as result
        end    
    
    %% For analytical solution
    elseif strcmp(modelMethod, 'Schulz')
        % Element count in mesh and comsolResultsRow are not relevant for analytical models
        elementsCountComsol = NaN; 
        comsolResultsRow = [];
        
        % For mesh convergence analysis the calculation is called repeatedly for the same parameters.
        % It is waste of time to calculate the same results again, so for larger calculations
        % of 10000 Temperatures or more the results are cached (remembered) here for next call
        % and if it is the same they are immediately returned.
        % Caching is variable persistent between function calls
        persistent params_Cache T_points_t_Cache T_mesh_Cache t_b_mesh_Cache 
        persistent H_mesh_Cache v_x_mesh_Cache v_y_mesh_Cache 
        persistent t_list_Cache x_range_Cache y_range_Cache z_range_Cache Mt_Cache
        % Ignore parameters which make no sense for analytical models
        params.maxMeshSize = 0;
        % Check if enough Temperatures (>10000) so caching will be allowed
        cacheAllowed = (size(points_Coords, 1) * numel(t_list)) >= 100; % 2000;
        % If cache allowed and current parameters the same as previously cached
        if cacheAllowed && ~isempty(params_Cache) && ...
               all(table2array(struct2table(params)) == table2array(struct2table(params_Cache))) && ...
               all(all(t_list == t_list_Cache)) && ...
               all(x_range == x_range_Cache) && ...
               all(y_range == y_range_Cache) && ...
               all(z_range == z_range_Cache) && ...
               Mt == Mt_Cache
           % Return previously cached results
           T_points_t = T_points_t_Cache;
           T_mesh = T_mesh_Cache;
           t_b_mesh = t_b_mesh_Cache;
           H_mesh = H_mesh_Cache;
           v_x_mesh = v_x_mesh_Cache;
           v_y_mesh = v_y_mesh_Cache;
           
        else %no caching, calculate
            T_points_t = nan(size(points_Coords, 1), numel(t_list));
            % Calculate temperatures for each time
            
            % Calculate parameters for 2D Schulz model

            % deltaH is m/m hydraulic gradient Not input of this model
            % K is hydraulic conductivity (m/s) it is not taken from Schulz paper,
            % it does not influence the model results as Darcy groundwater flow is given
            K = params.q / deltaH;  
            modelBoundary = calc_modelBoundary( Xmesh, Ymesh, params.a );
            
            for it = 1 : numel(t_list)
                % Note that either Ymesh or Zmesh is required to be single number.
                if strcmp(modelMethod, 'ansol_3D_doublet')
                    % NO 3D model is yet implemented !!!!!!!!!!!!!!!                   
%                     T_mesh = T_MFLS_anisotropic(Xmesh,Ymesh,Zmesh, params.H, params.lm, params.q, ...
%                                                 params.Cw, params.Cm, t_list(it), params.fe, aXYZ);
                elseif strcmp(modelMethod, 'Schulz')                    
                    if true % numel(z_range) == 1 % PLAN view   if z coordinate is fixed     
                        % If requested Temperature or time to breakthrough then return it
                        if contains(evalTask, 'T') || contains(evalTask, 't_b') 
                            [T_mesh_tmp, t_b_mesh_tmp] = T_Schulz( Xmesh, Ymesh, t_list(it), params.q, K, params.n, ...
                                params.cW * params.rhoW, params.cS * params.rhoS, params.lS, ...
                                    params.T0, params.Ti, params.alpha_deg, params.M, params.Q, params.a,...
                                    modelBoundary, N_Schulz_streamline, params.ro); 
                            % return requested result only
                            if contains(evalTask, 'T')
                                T_mesh = T_mesh_tmp;
                            end
                            if contains(evalTask, 't_b')
                                t_b_mesh = t_b_mesh_tmp;
                            end
                            
                        end
                        % If requested hydraulic potential then return it
                        if contains(evalTask, 'H')
                            % Hydraulic conductivity
                            K = params.q / deltaH;               
                            % calculate hydraulic potential phi in steady state
                            H_mesh = schulz_phi_psi( Xmesh, Ymesh, params.q, K, params.alpha_deg, ...
                                                          params.M, params.Q, params.a );
                        end
                        % If requested groundwater velocities then return them
                        if contains(evalTask, 'v')                         
                            % calculate groundwater velocities in x and y direction (in 2D to plot streamlines)
                            [ v_x_mesh, v_y_mesh ] = schulz_velocity( Xmesh, Ymesh, params.q, params.alpha_deg, ...
                                                            params.M, params.Q, params.a );                                          
                        end
                                                    
                    else % for PROFILE view NOTDONE
                        % y_list is one value (0), x_list is first line, as doesn't depend on depth (z)
                        [T_mesh, t_b_mesh] = T_Schulz( x_list, y_list, t_list(it), params.q, K, params.n, ...
                            params.cW * params.rhoW, params.cS * params.rhoS, params.lS, ...
                                params.T0, params.Ti, params.alpha_deg, params.M, params.Q, params.a,...
                                modelBoundary, N_Schulz_streamline, params.ro);                        
                            
                        % Repeat the calculated row for profile with depth (z) as it does not change with depth
                        T_mesh = repmat(T_mesh, numel(z_list), 1);
                    end
                    %warning('T_MILSd used! Switch back to T_MFLS_anisotropic');
                end
                % Reshape matrix to single column so rows with temperature match
                % with point rows in points_Coords
                T_points_t(:,it) = T_mesh(:);
            end
            % Return T_mesh only for single time, 
            %if time list is given, return Empty T_mesh (as no need for it)
            if numel(t_list) > 1
                T_mesh = [];
                t_b_mesh = [];
                v_x_mesh = [];
                v_y_mesh = [];
                H_mesh = [];
            end
            % If cache allowed remember current parameters and the result in cache
            if cacheAllowed
                params_Cache = params;
                T_points_t_Cache = T_points_t;
                T_mesh_Cache = T_mesh;
                t_b_mesh_Cache = t_b_mesh;
                H_mesh_Cache = H_mesh; 
                v_x_mesh_Cache = v_x_mesh;
                v_y_mesh_Cache = v_y_mesh;
                t_list_Cache = t_list;
                x_range_Cache = x_range;
                y_range_Cache = y_range;
                z_range_Cache = z_range;
                Mt_Cache = Mt;
            end
        end        
    else
        error('Model method name is not supported.')
    end
    % round result of temeprature in same way as numerical result.
    % this is because result of analytical slightly not precise (on about 6 decimal points)
    decimalPlaces = 5;
    T_points_t = round(T_points_t, decimalPlaces);
    if ~isempty(T_mesh)
        T_mesh = round(T_mesh, decimalPlaces);
    end
end
