function points_CoordsRotated = rotateCoordinates(points_Coords, rotateTest2Struct)
% Rotate coordinates so they are given relative to new x axis between well
% 5 and well 7 (x axis in test 2), rather than well 5 and well 6 (test 1)

% (x-rotationpointx) * cos(Radians(rotation angle)) - (y - rotation point
% y) * sinus(radians(rotation angle)) + rotation point x + shift expressed
% as (a2-a1)/2

% In case there is a z coordinate copy it to the result.
points_CoordsRotated = points_Coords;

% Rotate x coordinate
points_CoordsRotated(:,1) = ...
    (points_Coords(:,1) - rotateTest2Struct.rotationPointX) * cos(deg2rad(rotateTest2Struct.rotationAngleDeg)) ...
    - (points_Coords(:,2) - rotateTest2Struct.rotationPointY) * sin(deg2rad(rotateTest2Struct.rotationAngleDeg)) ...
    + rotateTest2Struct.rotationPointX + rotateTest2Struct.shiftXA2minusA1Halved;
% Round
points_CoordsRotated(:,1) = round(points_CoordsRotated(:,1), 5, 'significant');
% Replace small values (close to zero) by zero
points_CoordsRotated(abs(points_CoordsRotated(:,1)) <= 10^(-7),1) = 0;

% Rotate y coordinate
points_CoordsRotated(:,2) = ...
    (points_Coords(:,1) - rotateTest2Struct.rotationPointX) * sin(deg2rad(rotateTest2Struct.rotationAngleDeg)) ...
    + (points_Coords(:,2) - rotateTest2Struct.rotationPointY) * cos(deg2rad(rotateTest2Struct.rotationAngleDeg)) ...
    + rotateTest2Struct.rotationPointY + rotateTest2Struct.shiftYA2minusA1Halved;
% Round
points_CoordsRotated(:,2) = round(points_CoordsRotated(:,2), 5, 'significant');
% Replace small values (close to zero) by zero
points_CoordsRotated(abs(points_CoordsRotated(:,2)) <= 10^(-7), 2) = 0;

end


