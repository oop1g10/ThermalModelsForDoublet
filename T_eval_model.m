function [T_points_t, points_Coords, T_mesh, Xmesh, Ymesh, Zmesh, ...
          elementsCountComsol, comsolResultsRow, t_b_mesh] = ...
    T_eval_model(modelMethod, x_range, y_range, z_range, Mt, params, t_list, comsolResultsTab)
% Model inputs
% modelMethod - method of model "comsol" or MILS or MFLS
% x_range - has to be range as from to (e.g. [2 3], if only signle x point needed to be computed range should be given as repeated value, e.g. [2 2] 
% y_range, z_range - can be given as signle value or a range (from to), either y or z should be fixed point e.g. [2 2], 
%       i.e. both cannot be given as a list e.g. [2 3]
% Mt - number of steps to divide the range into
% params - structure with parameters
% t_list - list of times (seconds)
% comsolResultsTab - table with all COmsol results (Temperatures and times and positions and element triangulation)

% Calculate Temperature mesh for selected fixed parameters
% modelMethod - model to calculate, can be numerical Comsol model (named as 'nMFLSfr', 'nMFLS', 'nMILSfr', 'nMILS') 
%                                                                   or analytical solution named as 'MFLS', 'MILS' 

    [ ~, ~, deltaH, ~, ~, N_Schulz_streamline] = standardParams( 'homo' );
    
    % Space discretization for both wells accounting for log and lin spacing areas in model domain
    [ points_Coords, Xmesh, Ymesh, Zmesh, x_list, y_list, z_list ] = ...
           spaceDiscretisation(x_range, y_range, z_range, Mt, ...
                               params.maxMeshSize, params.ro, params.a, comsolResultsTab);

    %% Temperature evaluation for models
    %% For COMSOL
    if isModelNumerical( modelMethod ) % First argument says logic if model method is numerical.
        % If results with "deactivated" fracture are requested (nMILS or nMFLS)
        params = paramsHomoAdjust( params, modelMethod );        
        % Parameters from comsol result
        if numel(z_range) == 1 && z_range == params.H/2 ... % if z coordinate is fixed and equals to standard z (mid borehole depth)
                && ~(numel(y_range) == 1 && y_range == 0) % if y = 0 do not use plan view, use profile view instead because it also covers  Pipe Temperatures
            fixedCoord = [NaN, NaN, points_Coords(1,3)];% plan data will be used
        elseif numel(y_range) == 1 % if y coordinate is fixed
            fixedCoord = [NaN, points_Coords(1,2), NaN]; % profile data will be used
        else
            error('Please provide only single value for either y range or z range (or for both)!')
        end
        
        % prepare matrices for results        
        % Get comsol results rows
        comsolResultsRow = comsolResultsRowForParams( comsolResultsTab, params, fixedCoord, coordInsidePipe );
        % If result found
        if size(comsolResultsRow,1) == 1
            % Element count in mesh
            elementsCountComsol = comsolElementsCount(modelMethod, comsolResultsRow);

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
        else % results not found
            elementsCountComsol = NaN; % element count cannot be determined
            T_points_t = nan(size(points_Coords,1), numel(t_list));
            T_mesh = nan(numel(y_list) * numel(z_list), numel(x_list));
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
        persistent params_Cache T_points_t_Cache t_b_mesh_Cache T_mesh_Cache
        persistent t_list_Cache x_range_Cache y_range_Cache z_range_Cache Mt_Cache
        % Ignore parameters which make no sense for analytical models
        params.maxMeshSize = 0;
        % Check if enough Temperatures (>10000) so caching will be allowed
        cacheAllowed = (size(points_Coords, 1) * numel(t_list)) >= 10000;
        % If cache allowed and current parameters the same as previously cached
        if cacheAllowed && ~isempty(params_Cache) && ...
               all(table2array(struct2table(params)) == table2array(struct2table(params_Cache))) && ...
               all(t_list == t_list_Cache) && ...
               all(x_range == x_range_Cache) && ...
               all(y_range == y_range_Cache) && ...
               all(z_range == z_range_Cache) && ...
               Mt == Mt_Cache
           % Return previously cached results
           T_points_t = T_points_t_Cache;
           t_b_mesh = t_b_mesh_Cache;
           T_mesh = T_mesh_Cache;

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
                    if numel(z_range) == 1 % PLAN view   if z coordinate is fixed                    
                        [T_mesh, t_b_mesh] = T_Schulz( Xmesh, Ymesh, t_list(it), params.q, K, params.n, ...
                            params.cW * params.rhoW, params.cS * params.rhoS, params.lS, ...
                                params.T0, params.Ti, params.alpha_deg, params.M, params.Q, params.a,...
                                modelBoundary, N_Schulz_streamline, params.ro);                        

                    else % for PROFILE view 
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
                % Reshape matrix to single column so temperatures rows match
                % with point rows in points_Coords
                T_points_t(:,it) = T_mesh(:);
            end
            % Return T_mesh only for single time, 
            %if time list is given, return Empty T_mesh (as no need for it)
            if numel(t_list) > 1
                T_mesh = [];
            end
            % If cache allowed remember current parameters and the result in cache
            if cacheAllowed
                params_Cache = params;
                T_points_t_Cache = T_points_t;
                t_b_mesh_Cache = t_b_mesh;
                T_mesh_Cache = T_mesh;
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
    T_mesh = round(T_mesh, decimalPlaces);
end
