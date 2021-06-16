function wellCoords = wellCoordinates(variant)
% Return well coordinates based on variant
% Coordinates will be different for test 1 and test 2
    if strcmp(variant, 'FieldExp1') || strcmp(variant, 'FieldExp1m')
        % Well coordinates
        wellCoords = table;
        wellCoords.wellName = {'aquifro2'; 'aquifro3'; 'aquifro4'; 'aquifro5'; 'aquifro6'};
        wellCoords.x = [-3.42; -4.09; -0.04; 4.97; -4.97];
        wellCoords.y = [-5.01; 4.86; 1.57; 0.00; 0.00];
    elseif strcmp(variant, 'FieldExpAll')
        % Well coordinates
        wellCoords = table;
        wellCoords.wellName = {'aquifro2'; 'aquifro3'; 'aquifro4'; 'aquifro5'; 'aquifro6'; 'aquifro7'};
        wellCoords.x = [-3.42; -4.09; -0.04; 4.97; -4.97; -0.51];
        wellCoords.y = [-5.01; 4.86; 1.57; 0.00; 0.00; 3.07];
    elseif strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated')
        % Well coordinates
        wellCoords = table;
        wellCoords.wellName = {'aquifro3'; 'aquifro4'; 'aquifro5'; 'aquifro6'; 'aquifro7'};
        wellCoords.x = [-4.09; -0.04; 4.97; -4.97; -0.51];
        wellCoords.y = [4.86; 1.57; 0.00; 0.00; 3.07];
        % Rotate coordinates for test 2 so that x axis is on the line of
        % injection pumping wells
        if strcmp(variant, 'FieldExp2Rotated')
            points_Coords = [wellCoords.x, wellCoords.y];
            rotateTest2Struct = rotateTest2Info();
            points_CoordsRotated = rotateCoordinates(points_Coords, rotateTest2Struct);
            wellCoords.x = points_CoordsRotated(:,1);
            wellCoords.y = points_CoordsRotated(:,2);
        end
    else
        % To avoid error return out of ceiling coordinates for all variants
        wellCoords = table;
%         wellCoords.wellName = {'aquifro'};
%         wellCoords.x = 0;
%         wellCoords.y = 0;   
    end
end
