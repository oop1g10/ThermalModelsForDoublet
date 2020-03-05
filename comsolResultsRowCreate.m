function comsolResultsTabRow = comsolResultsRowCreate(comsolFilename, nodeXYZ, ...
                                    T_nodeTime, v_x_nodeTime, v_y_nodeTime, Hp_nodeTime, timeList)
                                             
% Prepare results for one file with unique parameter set

    % Round all data number to 8 decimal places, to remove tiny
    % insignificant numbers which have to be zero or 273.15 in results
    % Note that if only 6 decimals used some points appear to be duplicated and triangulation removes them
    numDecimals = 8; 
    nodeXYZ = round(nodeXYZ, numDecimals);
    T_nodeTime = round(T_nodeTime, numDecimals);
    v_x_nodeTime = round(v_x_nodeTime, numDecimals);
    v_y_nodeTime = round(v_y_nodeTime, numDecimals);
    Hp_nodeTime = round(Hp_nodeTime, numDecimals);

    %Coordinate in Z direction make from 0 top to positive downwards
    nodeXYZ(:,3) = -nodeXYZ(:,3); %in comsol down was negative, invert it
    
    % Identify used dimentions (dimension with all the same values is not used) 
    usedDimensions = ~[all(nodeXYZ(:,1) == nodeXYZ(1,1)) || isnan(nodeXYZ(1,1)) ...
                       all(nodeXYZ(:,2) == nodeXYZ(1,2)) || isnan(nodeXYZ(1,2)) ...
                       all(nodeXYZ(:,3) == nodeXYZ(1,3)) || isnan(nodeXYZ(1,3))];
    dimensionNames = 'xyz';
    usedDimensionNames = dimensionNames(usedDimensions);
    % Store fixed unsused dimension value
    fixedCoord = nodeXYZ(1,:); % take the fixed value from first row as they are all the same
    fixedCoord(usedDimensions) = NaN; %used dimensions will be NaN because they change    
 
    % Create a 2D (plane or profile view) or 3D delaunayTriangulation (elements) for nodes with known temperatures
    delaunayTriang = delaunayTriangulation(nodeXYZ(:,usedDimensions));
     
    % Prepare table for all comsol output data: range of gw velocities,
    % and dispersivities
    comsolResultsTabRow = table;
    comsolResultsTabRow.dimensions = {usedDimensionNames};
    comsolResultsTabRow.fixedCoord = {fixedCoord};
    comsolResultsTabRow.nodeXYZ = {nodeXYZ}; %nodes coordinates xyz
    comsolResultsTabRow.T_nodeTime = {T_nodeTime}; % temperature differences for nodes (rows) and times (columns)
    comsolResultsTabRow.v_x_nodeTime = {v_x_nodeTime}; % gw velocities in x direction for nodes (rows and times (columns)
    comsolResultsTabRow.v_y_nodeTime = {v_y_nodeTime}; % same for gw velocities in y direction
    comsolResultsTabRow.Hp_nodeTime = {Hp_nodeTime}; % same for hydraulic potential
    comsolResultsTabRow.timeList = {timeList}; % list of times used in Comsol simulation (columns) in 1 row
    comsolResultsTabRow.delaunayTriang = {delaunayTriang}; %triangulated elements
    % Get the info from comsol filename
    [ params ] = comsolFilename_Info( comsolFilename );
    paramNames = fieldnames(params);
    for i = 1:numel(paramNames)
        % create column in table with name as the parameter. variable{i} = extract
        % value from cell, {variable} = put variable into cell
        comsolResultsTabRow.(paramNames{i}) = {params.(paramNames{i})};
    end
end

