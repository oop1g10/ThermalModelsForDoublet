function  [x_value, x_valueRow] = interpolateXforY(y_matrix, y_value, x_matrix, y_trend)
% Returns interpolated x value, which corresponds to y_value
% y_value - y value to find, for example isotherm temperature of 2 degC
% y_matrix - function values, for example Temperatures, along x axis, given as a list 
% x_matrix - x values, for example time, or x coordinates of values in y_list    
% y_trend - string 'up' = if y values are increasing, find first occurence of requested value 
%                           (if heat source is constant, with time temperature goes up)
%                  'down' = if y values are decreasing, find last occurence of requested value
%                           if heat source is constant with X (distance) temperature goes down.
    
    % '+up' trend is used when T is searched for single location for a list of times
    %          i.e. when time (e.g. to reach Steady state) is interpolated for a given T (i.e.T at Steady state)
    %  '+down is used when T is searched for a list of locations at a single time 
    %        i.e. when the length of plume is interpolated for given T
    if strcmp(y_trend, '+up') || strcmp(y_trend, '+down')
        % Set trend to "up" or "down" respectively
        y_trend = y_trend(2:end); %skip initial '+' character
        % If y_value negative, values need to be flipped to make correct increasing/decreasing trend
        if y_value < 0
            y_value = -y_value;
            y_matrix = -y_matrix;
        end
    end
    
    % Check if the y_matrix values are all above or below the requested y_value
    if max(max(y_matrix)) < y_value  ||  min(min(y_matrix)) > y_value
        % this can occur if isotherm is not present or is longer than search boundaries
        %warning('Extracted temperatures are all lower / higher than requested isotherm temperature.')
        x_value = NaN; x_valueRow = NaN;
    else
        % If first occurence of requested value should be found (for example for plot Temp vs time at one point)
        if strcmp(y_trend, 'up')
            % Swap order of columns, so last column values become first. This will make increasing y value
            % series becomes decreasing, and the logic below holds.
            y_matrix = flip(y_matrix, 2);
            x_matrix = flip(x_matrix, 2);
        end
        
        % Pre-allocate NaNs to place where results are recorded
        x_value_list = nan(size(y_matrix,1),1);

        % Separate values which are higher and lower from T_plume
        positiveDiff = y_matrix >= y_value; 
        negativeDiff = y_matrix < y_value;

        % Find plume extent for each line in y matrix
        for i = 1:size(y_matrix,1)
            y_matrixRow = y_matrix(i,:);
            x_matrixRow = x_matrix(i,:);

            % If last y values is bigger than requested y_value, then no answer exists
            % this accounts for laterally distorted plume (asymmetric)
            if y_matrixRow(end) >= y_value
                % This is okay to happen, values will be missing (NaN) in plots, do not show warning
                % warning('Extracted temperatures are all higher than requested isotherm temperature.')
                x_value = NaN; x_valueRow = NaN;
                return;
            elseif isnan(y_matrixRow(end))
                warning('Interpolation not possible, as NaNs exist in result temperatures.')
                x_value = NaN; x_valueRow = NaN;
                return;
            end

            % Find index for last y value higher or equal to requested y_value
            indexPositive = find(positiveDiff(i,:),1,'last');
            % Check that positive values are found,if not = skipp the line as all values are lower
            if isempty(indexPositive)
                % Use -Inf for x value so when maximum is determined it is ignored (not chosen) while index for chosen value is correct
                x_value_list(i) = -Inf;
            else
                % Find index for the furthest y value which is lower than requested value and goes just after the indexPositive
                % Find indices for all y values which are lower than requested y_value
                indexNegativeList = find(negativeDiff(i,:));
                % Find index for the y value below requested y_value, which is just after indexPositive 
                indexNegativeListAfter = indexNegativeList(indexNegativeList > indexPositive);
                indexNegative = min(indexNegativeListAfter);

                % Interpolate x between found y values 
                x_value_list(i) = x_matrixRow(indexPositive) + ...
                   (y_value - y_matrixRow(indexPositive)) / (y_matrixRow(indexNegative) - y_matrixRow(indexPositive)) * ...
                   (x_matrixRow(indexNegative) - x_matrixRow(indexPositive));
            end
        end
        % Return the maximum x_value calculated from list
        [x_value, x_valueRow] = max(x_value_list);
    end
end

