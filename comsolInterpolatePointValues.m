function [ pointValues_IndepVar, independentVarIndices ] = ...
    comsolInterpolatePointValues( comsolResultsRow, pointXYZ, nodeValuesVarName, independetVarName, independentVarValuesSelected)
%delaunayTriangulate returns the weighted average of point(s) property (e.g.
%temperature) calculated from the weighted average of properties of the
%nodes around this point(s) i.e. which belong to the element in which this
%point of interest is located

% Inputs
% nodeXYZ -  x y z coordinated of all nodes which form all the elements of the
%               numerical model (matrix with rows to separate the points, colums = x y z
%               coordinates)
% pointXYZ -  x y z coordinates of the point/points of interest, the property of
%             which should be calculated (e.g. temperature) (matrix with rows to separate the 
%             points, colums = x y z coordinates)
% nodeValues - dependent property of nodes e.g. temperature at certain time
%              (time is independent variable),
%              rows = for nodes, columns of this matrix - for independent variable (if>1)
% independentVarValues - independent variable as list (one row), columns correspond to nodeValues columns
%                        for example time steps
% independentVarValuesSelected - specific independent variable values as list to use in
%                                analysis (e.g. times: 3 and 30 years in units as in independentVarValues)

% Outputs
% pointValues_IndepVar - values at points of interest (e.g. temperature)
%                        as a matrix with rows to separate the points 
%                        and columns for independentVarValuesSelected (if needed) e.g. time
    
    % Get results data from table cells
    delaunayTriang = comsolResultsRow.delaunayTriang{1};
    dimensions = comsolResultsRow.dimensions{1};
    fixedCoord = comsolResultsRow.fixedCoord{1};
    nodeValues = comsolResultsRow.(nodeValuesVarName){1};
    independentVarValues = comsolResultsRow.(independetVarName){1};

    % Select dimensions to use from current result table row
    usedDimensions = dimensionFromName_Logic( dimensions );
    
    % Keep only coordinates for used dimensions
    pointCoords = pointXYZ(:,usedDimensions);
    % Check that imported unused (fixed) coordinate value (in result table) matches with 
    % fixed coordinate value of the point of interest
    if sum(usedDimensions) < 3 % if unsused dimension exists 
        % Unused dimension must be the same as the fixed one in data
        % extract, or it can be NaN in case the data extract is in 2D
        % (covers all values).
        assert(fixedCoord(~usedDimensions) ==  pointXYZ(1,~usedDimensions) ...
               | isnan(fixedCoord(~usedDimensions)), 'Fixed dimension does not match');
    end
        
    % Find triangle element containing point
    % Barycentric coordinates used to weight node temperatures in element
    [nodeConnectivityIndex, baryCoord] = pointLocation(delaunayTriang, pointCoords);
    % Indices of nodes (4 columns) for elements (rows) which contain the
    % points of interest, one row for each point of interest
      
    nodeIndicesOfElement = delaunayTriang.ConnectivityList(nodeConnectivityIndex,:);

    % Prepare list of indices for selected independent variable values (for example time)
    independentVarSelectedLogic = false(1, numel(independentVarValues));
    for i = 1:numel(independentVarValuesSelected) 
        % Put TRUE to column only when this independent variable is selected for analysis
        independentVarSelectedLogic = independentVarSelectedLogic | ...
                                      (independentVarValues == independentVarValuesSelected(i));
    end
    % List indices of selected independent variables
    independentVarIndices = find(independentVarSelectedLogic);

    % Calculate weighted temperature at point of interest using Barycentric coordinates
    pointValues_IndepVar = zeros(size(pointCoords,1), numel(independentVarIndices));
    for i = 1:numel(independentVarIndices)
        %Take temparatures for one time
        values_elementNodes = zeros(size(nodeIndicesOfElement,1), size(nodeIndicesOfElement,2));
        for j = 1:size(nodeIndicesOfElement,2)
            values_elementNodes(:,j) = nodeValues(nodeIndicesOfElement(:,j), independentVarIndices(i)); %for jth element
        end
        %Interpolation on a triangular unstructured grid
        %https://en.wikipedia.org/wiki/Barycentric_coordinate_system#Interpolation_on_a_triangular_unstructured_grid
        weightsElementNodes = baryCoord;
        %Weighted average of node temperatures for each point
        pointValues_IndepVar(:,i) = sum(weightsElementNodes .* values_elementNodes, 2);
    end
    % Round result to get rid of negative values close to zero
    significantDigits = 4;
    pointValues_IndepVar = round(pointValues_IndepVar, significantDigits, 'significant');
    % Replace small values (close to zero) by zero
    pointValues_IndepVar(abs(pointValues_IndepVar) <= 10^(-significantDigits)) = 0;
end
