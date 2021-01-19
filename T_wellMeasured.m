function [T_t, wellName] = ...
            T_wellMeasured(x, y, depth_range, t_list, variant)
% Return measured temperatures for specified depth and well
% x and y must be coordinates of well

    % Load measured data that was imported and saved as mat file
    % Extract name of data file with measured temperatures and Variant
    [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, wellTempDataFileImportCompare ] = ...
                comsolDataFileInUse_Info( );
    % Load table with results wellTempTabTest1
    persistent wellTempTabTest1
    if isempty(wellTempTabTest1)
        load(wellTempDataFileImportCompare, 'wellTempTabTest1');
    end
    
    % Determine well based on x y coordinate
    % Well coordinates
    wellCoords = table;
    wellCoords.wellName = {'aquifro2'; 'aquifro3'; 'aquifro4'; 'aquifro6'; 'aquifro5'; 'aquifro7'};
    wellCoords.x = [-2.62; -0.27; 2.59; -2.59; 6.90; 2.60];
    wellCoords.y = [-5.24; 4.37; 0.00; 0.00; -3.01; 1.57];
    % Find x y among well cordinates
    wellName = {};
    for i = 1 : numel(wellCoords.x)
        if x == wellCoords.x(i) && y == wellCoords.y(i)
           wellName = wellCoords.wellName(i);
        end
    end
    
    % Filter temperatures by well name and depth
    relevantRows = strcmp(wellTempTabTest1.wellName, wellName) & ...
        wellTempTabTest1.wellDepth >= depth_range(1) & ...
        wellTempTabTest1.wellDepth <= depth_range(2);
    wellTempTabFiltered = wellTempTabTest1(relevantRows, :);
    % Make sure the times are rounded for comparison to work
    wellTempTabFiltered.tRound = timeRoundToMeasured(wellTempTabFiltered.t);
    
    % Find temperatures for requested times
    T_t = NaN(1, numel(t_list));
    t_listRound = timeRoundToMeasured(t_list);
    % Slow method to find Temperature in result table which correspond to
    % requested times
%     for i = 1 : numel(t_listRound)
%         lines = wellTempTabFiltered.tRound == t_listRound(i);
%         T_t(i) = wellTempTabFiltered.tempC(lines);
%     end    
    % Faster method to do the same but using intersect function
    [~,ia,ib] = intersect(wellTempTabFiltered.tRound, t_listRound);
    T_t(ib) = wellTempTabFiltered.tempC(ia);
end

