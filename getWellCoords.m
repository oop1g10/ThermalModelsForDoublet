function [xInjection, yInjection, xAbstraction, yAbstraction] = getWellCoords(a)
% get coordinates for injection and abstraction wells
% from parameter a = half distance between the wells for Schulz analytical solution

    % distance of Injection well with coordinates (x = -a, y = 0) 
    % location of Abstraction well is fixed to x = a, y = 0
    xInjection = - a;
    yInjection = 0; % y coordinate of the well
    xAbstraction = a;
    yAbstraction = yInjection;

end

