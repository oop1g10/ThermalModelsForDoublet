function [ insideInjWell ] = isInsideInjectionWell( x, y, a, rw )
    % is the stream line xy point close to injection well?
    % true or false

    % rw = 0.1; % radius of injection well (m)
    % x y coordinates of the point
    % a is half distance between injection and abstraction well

    % if x point is inside the wall of the well = 1 (true)
    % get coordinates of injection well
    [xInj, yInj, ~, ~] = getWellCoords(a);
    
    % well radius is reduced by 1 % to account for possibility of rounding error
    insideInjWell = ((x-xInj).^2+(y-yInj).^2) < (rw* 0.99)^2;

end

