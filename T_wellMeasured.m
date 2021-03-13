function [T_t, wellName] = ...
            T_wellMeasured(x, y, depth_range, t_list, variant)
% Return measured temperatures for specified depth and well
% x and y must be coordinates of well

    paramsStd = standardParams( variant );

    % Load measured data that was imported and saved as mat file
    % Extract name of data file with measured temperatures and Variant
    [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, wellTempDataFileImportCompare ] = ...
                comsolDataFileInUse_Info( );        
    % Load table with results wellTempTabTest
    persistent wellTempTabTest
    if isempty(wellTempTabTest)
        load(wellTempDataFileImportCompare, 'wellTempTabTest');
    end
    
    % Determine well based on x y coordinate
    % Well coordinates
    wellCoords = wellCoordinates(variant);
    % Find x y among well cordinates
    wellName = {};
    for i = 1 : numel(wellCoords.x)
        if x == wellCoords.x(i) && y == wellCoords.y(i)
           wellName = wellCoords.wellName(i);
        end
    end
    
    % Filter temperatures by well name and depth
    relevantRows = strcmp(wellTempTabTest.wellName, wellName) & ...
        wellTempTabTest.wellDepth >= depth_range(1) & ...
        wellTempTabTest.wellDepth <= depth_range(2);
    wellTempTabFiltered = wellTempTabTest(relevantRows, :);
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
    % Temperature difference from initial values
    T_t(ib) = wellTempTabFiltered.tempC(ia) - kelvin2DegC(paramsStd.T0);
end

