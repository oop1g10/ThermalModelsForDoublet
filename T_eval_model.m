function [T_points_t, points_Coords, T_mesh, Xmesh, Ymesh, Zmesh, elementsCountComsol, comsolResultsRow ] = ...
    T_eval_model(modelMethod, x_range, y_range, z_range, ...
                 Mt, params, t_list, comsolResultsTab)
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

    aXYZ = [params.aX, params.aY, params.aZ]; % prepare aXYZ to model run
    
    % Take node coordinates from comsol results to determine possible x and y range
    % in plots. Taken from first results rows as all result should have same
    % geometry.
    [ xRangeLimits, yRangeLimits, zRangeLimits, logRangeEnd ] = comsol_xyzRanges( comsolResultsTab );
    
    % Note +/- 1 meter at boundaries of domain are used below, because the interpolation at
    % boundary edge gives error (for Comsol model), maybe no elements for interpolation at
    % boundary, so 1 meter from edge is excluded from boundaries.
    if ~isempty(xRangeLimits)
        assert(x_range(1) >= xRangeLimits(1)+1, 'Required minimum x_range to plot is not present in given model data (is smaller than given for plot).')
        assert(x_range(2) <= xRangeLimits(2)-1, 'Required maximum x_range to plot is not present in given model data (is larger than given for plot).')
    end
    if ~isempty(yRangeLimits)
        assert(y_range(1) >= yRangeLimits(1)+1, 'Required minimum y_range to plot is not present in given model data (is smaller than given for plot).')
        if numel(y_range) == 2
            assert(y_range(2) <= yRangeLimits(2)-1, 'Required maximum y_range to plot is not present in given model data (is larger than given for plot).')
        else
            assert(y_range(1) <= yRangeLimits(2)-1, 'Required maximum y_range to plot is not present in given model data (is larger than given for plot).')
        end
    end
    if ~isempty(zRangeLimits)
        assert(z_range(1) >= zRangeLimits(1), 'Required minimum z_range to plot is not present in given model data (is smaller than given for plot).')
        if numel(z_range) == 2 
            assert(z_range(2) <= zRangeLimits(2), 'Required maximum z_range to plot is not present in given model data (is larger than given for plot).')        
        else
            assert(z_range(1) <= zRangeLimits(2), 'Required maximum z_range to plot is not present in given model data (is larger than given for plot).')        
        end
    end
    
    %% Space discretization
    % List of x coordinates separated by borehole width to avoid calculation of
    % T inside borehole which has infinite temperature in the center
    % If Mt is not provided, x,y,z ranges already contain the positions of all points to be evaluable, rahter than only ranges.
    if isempty(Mt)
        x_list = x_range;
    else
        x_list = rangeToList( x_range, Mt, params.ro, logRangeEnd );   
    end
    % if z coordinate is fixed
    if numel(z_range) == 1
        % If Mt is not provided, x,y,z ranges already contain the positions of all points to be evaluable, rahter than only ranges.
        if isempty(Mt)
            y_list = y_range;
        else
            % If x is single value inside borehole, y list must exclude borehole radius
            if min(abs(x_list)) < params.ro % actually function rangeToList already avoids inside borehole values if number of x points >1, but just to make sure.
                y_list = rangeToList( y_range, Mt, params.ro, logRangeEnd );
            else % If all x coordinates are outside of borehole radius
                y_list = rangeToList( y_range, Mt, 0, logRangeEnd );
            end
        end
        %prepare mesh for x and y to have distinct xy pairs for T calculation
        [Xmesh, Ymesh] = meshgrid(x_list, y_list);
        % Single value expected, not range for z
        Zmesh = z_range; 
        z_list = z_range;       
    % if y coordinate is fixed
    elseif numel(y_range) == 1 
        % If Mt is not provided, x,y,z ranges already contain the positions of all points to be evaluable, rahter than only ranges.
        if isempty(Mt)
            z_list = z_range;
        else
            z_list = linspace(z_range(1), z_range(2), Mt); % [m] No need to skip borehole in z direction so use simple linspace.
        end
        %prepare mesh for x and z to have distinct xz pairs for T calculation
        [Xmesh, Zmesh] = meshgrid(x_list, z_list);
        % Single value expected, not range for y
        Ymesh = y_range;
        y_list = y_range;
    else
        error('Either y or z must be given as range, not both!')
    end
    
    % Points where temperature will be analysed
    points_Coords = nan(numel(x_list)*numel(y_list)*numel(z_list), 3);
    points_Coords(:,1) = reshape(Xmesh, numel(Xmesh), 1);
    points_Coords(:,2) = reshape(Ymesh, numel(Ymesh), 1);
    points_Coords(:,3) = reshape(Zmesh, numel(Zmesh), 1);

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
        % Check if T results belong to inside pipe or only on/outside VBHE wall 
        coordInsidePipe = isCoordInsidePipe( points_Coords, params.ro );
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
    
    %% For MFLS or MILS
    elseif strcmp(modelMethod, 'MFLS') || strcmp(modelMethod, 'MILS')
        % Element count in mesh and comsolResultsRow are not relevant for analytical models
        elementsCountComsol = NaN; 
        comsolResultsRow = [];
        
        % For mesh convergence analysis the calculation is called repeatedly for the same parameters.
        % It is waste of time to calculate the same results again, so for larger calculations
        % of 10000 Temperatures or more the results are cached (remembered) here for next call
        % and if it is the same they are immediately returned.
        % Caching in variable persistent between function calls
        persistent params_Cache T_points_t_Cache T_mesh_Cache
        persistent t_list_Cache x_range_Cache y_range_Cache z_range_Cache Mt_Cache
        % Ignore parameters which make no sense for analytical models
        params.rSource = 0; %use 0 so it can be easily compared
        params.maxMeshSize = 0;
        params.pipe_TinLimitDiff = 0;
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
           T_mesh = T_mesh_Cache;

        else %no caching, calculate
            T_points_t = nan(size(points_Coords, 1), numel(t_list));
            % Calculate temperatures for each time
            for it = 1 : numel(t_list)
                % Note that either Ymesh or Zmesh is required to be single number.
                if strcmp(modelMethod, 'MFLS')
                    T_mesh = T_MFLS_anisotropic(Xmesh,Ymesh,Zmesh, params.H, params.lm, params.q, ...
                                                params.Cw, params.Cm, t_list(it), params.fe, aXYZ);
                elseif strcmp(modelMethod, 'MILS')
                    QL = params.fe / params.H;   %Heat flow rate per unit length of borehole [W/m]
                    if numel(z_range) == 1 % if z coordinate is fixed i.e. plan view
                        T_mesh = T_MILSd(Xmesh,Ymesh, params.lm, params.q, params.Cw, params.Cm, t_list(it),...
                                         QL, params.aX, params.aY);
                    else %for profile view 
                        %y_list is one value (0), x_list is first line, as doesn't depend on depth (z)
                        T_mesh = T_MILSd(x_list,y_list, params.lm, params.q, params.Cw, params.Cm, t_list(it),...
                                         QL, params.aX, params.aY);
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
%             % Calculate temperature series for current q
%             if strcmp(modelMethod, 'MFLS')
%                 T_q(i,:) = T_MFLS_anisotropic(x_list(ix),y,z,H,lm,q_list(i),Cw,Cm,t_list,fe,aXYZ); %allocate T list row by row for different q
%             elseif strcmp(modelMethod, 'MILS')
%                 T_q(i,:) = T_MILSd(x_list(ix),y,lm,q_list(i),Cw,Cm,t_list,QL,aXYZ(1),aXYZ(2));
%                 warning('T_MILSd used! Switch back to T_MFLS_anisotropic');
%             elseif strcmp(modelMethod, 'MFLSc')
%                 % T as mean around circle:
%                 T_q(i,:) = T_MFLSc(ro,z,H,lm,q_list(i),Cw,Cm,t_list,fe); %allocate T list row by row for different q
%                 warning('T_MFLSc used! Switch back to T_MFLS_anisotropic');
%             elseif strcmp(modelMethod, 'FCS')
%                 % CYLINDER
%                 T_q(i,:) = T_FCS(x_list(ix),y,ro,z,H,lm,Cm,t_list,QL);
%                 warning('T_FCS used! Switch back to T_MFLS_anisotropic');
%             end

    end
end
