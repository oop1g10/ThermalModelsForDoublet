function [ points_Coords, Xmesh, Ymesh, Zmesh, x_list, y_list, z_list ] = ...
           spaceDiscretisation(x_range, y_range, z_range, Mt, startStepSize, ro, a, comsolResultsTab)
% Model inputs
% x_range - has to be range as from to (e.g. [2 3], if only signle x point needed to be computed range should be given as repeated value, e.g. [2 2] 
% y_range, z_range - can be given as signle value or a range (from to), either y or z should be fixed point e.g. [2 2], 
%       i.e. both cannot be given as a list e.g. [2 3]
% Mt - number of steps to divide the range into
% comsolResultsTab - table with all COmsol results (Temperatures and times and positions and element triangulation)
% startStepSize equals to maxMeshSize (the smallest size used in mesh) used for space discretisation

    % Log range splitting support
    % (hybrid log and linear ranges)
    [ ~, ~, ~, ~, growthRateOptim ] = standardParams( 'homo' );
    
    %% Take node coordinates from comsol results to determine possible x and y range
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
    % If Mt is not provided, x,y,z ranges already contain the positions of all points to be evaluated,
    % rather than only ranges.
    if isempty(Mt)
        x_list = x_range;
    else
        x_list = rangeToList_doublet( x_range, Mt, startStepSize, growthRateOptim, ro, logRangeEnd, a );   
    end
    % if z coordinate is fixed
    if numel(z_range) == 1
        % If Mt is not provided, x,y,z ranges already contain the positions of all points to be evaluable, rahter than only ranges.
        if isempty(Mt)
            y_list = y_range;
        else
            % If x is single value inside borehole, y list must exclude borehole radius
            if min(abs(x_list)) < ro % actually function rangeToList already avoids inside borehole values if number of x points >1, but just to make sure.
                y_list = rangeToList( y_range, Mt, startStepSize, growthRateOptim, ro, logRangeEnd );
            else % If all x coordinates are outside of borehole radius
                y_list = rangeToList( y_range, Mt, startStepSize, growthRateOptim, 0,  logRangeEnd );
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
end
