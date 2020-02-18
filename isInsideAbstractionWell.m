function [ insideAbsWell ] = isInsideAbstractionWell( x, y, a, rw )
    % is the xy point inside the abstraction well?
    % true or false
    % rw = 0.1; % radius of injection well (m)
    % x y coordinates of the point
    % a is half distance between injection and abstraction well
    % location of abstraction well is fixed to x = a, y = 0
    [~, ~, xAbs, yAbs] = getWellCoords(a);

   %  if x point is inside the wall of the well
   % if 1 (true) then point is inside the well
   % well radius is reduced by 1 % to account for possibility of rounding error
   insideAbsWell = ((x-xAbs).^2+(y-yAbs).^2) < (rw* 0.99)^2; 
end

