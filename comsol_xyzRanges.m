function [ xRange, yRange, zRange, logRangeEnd ] = comsol_xyzRanges( comsolResultsTab )
% Take node coordinates from comsol results to determine possible x and y range
% in plots. Taken from first results rows as all result should have same
% geometry.

    % logRangeEnd - Threshhold from where log method ends and linear method starts for list generation 
    % (due to optimal Comsol meshing), for example 50 m, needed for 'rangeToList' function
    logRangeEnd = 50; %m

    % If comsolResultsTab is empty then return empty ranges  
    if isempty(comsolResultsTab)
        xRange = [];
        yRange = [];
        zRange = [];
        return
    end
    
    % Identify first row from results table where x coordinate is present, the
    % same for y and z coordinates
    rowIndex_xRange = find(any(char(comsolResultsTab.dimensions) == 'x', 2), 1);
    rowIndex_yRange = find(any(char(comsolResultsTab.dimensions) == 'y', 2), 1);
    rowIndex_zRange = find(any(char(comsolResultsTab.dimensions) == 'z', 2), 1);
    % Take list of node coordinates for range extraction for x y z
    % and extract ranges for x y z coordinates, assume infinite ranges if
    % given coordinate (x y or z) is not present in data exports
    xRange = [-Inf,Inf]; yRange = [-Inf,Inf]; zRange = [-Inf,Inf];
    if ~isempty(rowIndex_xRange)
        nodeXYZ_xRange = comsolResultsTab.nodeXYZ{rowIndex_xRange};
        xRange = [min(nodeXYZ_xRange(:,1)), max(nodeXYZ_xRange(:,1))];
    end
    if ~isempty(rowIndex_yRange)
        nodeXYZ_yRange = comsolResultsTab.nodeXYZ{rowIndex_yRange};
        yRange = [min(nodeXYZ_yRange(:,2)), max(nodeXYZ_yRange(:,2))];
    end
    if ~isempty(rowIndex_zRange)
        nodeXYZ_zRange = comsolResultsTab.nodeXYZ{rowIndex_zRange};
        zRange = [min(nodeXYZ_zRange(:,3)), max(nodeXYZ_zRange(:,3))];
    end
end
