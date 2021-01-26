function wellCoords = wellCoordinates(variant)
% Return well coordinates based on variant
% Coordinates will be different for test 1 and test 2
    
    % Well coordinates
    wellCoords = table;
    wellCoords.wellName = {'aquifro2'; 'aquifro3'; 'aquifro4'; 'aquifro6'; 'aquifro5'; 'aquifro7'};
    wellCoords.x = [-3.42; -4.09; -0.04; -4.97; 4.97; -0.51];
    wellCoords.y = [-5.01; 4.86; 1.57; 0.00; 0.00; 3.07];
    
end
