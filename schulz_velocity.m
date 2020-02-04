function [ v_x, v_y ] = schulz_velocity( x, y, v_u, alpha_deg, M, Q, a )
% to determine the values of groundwater velocity in x and y directions in 2D model of schulz
% formula from Schulz paper 1987 eq, (15) page 16
% Definitions
% x, y = coordinates (m)
% v_u = undisturbed velocity of natural flow field (Darcy) m/s
% v_x = Darcy velocity at x coordinate
% v_y =  Darcy velocity in y coordinate
% M = thickness of the aquifer (m)
% a = half of the distance between two wells (m)
% 2a = the distance between 2 wells
% alpha_deg = azimuth of natural flow field (in degrees)
% Q = injected volume flow rate (m^3/second)

    alpha = deg2rad(alpha_deg);

    pv_1 = (x + a) ./ ((x + a).^2 + y.^2); % units are 1/m
    pv_2 = (x - a) ./ ((x - a).^2 + y.^2); % units are 1/m
    pv_3 = y ./ ( (x + a).^2 + y.^2 ); % units are 1/m
    pv_4 = y ./ ((x - a).^2 + y.^2); % units are 1/m

    v_x = v_u * cos(alpha) + Q / (2 * pi * M) * (pv_1 - pv_2); % units m/s
    v_y = v_u * sin(alpha) + Q / (2 * pi * M) * (pv_3 - pv_4); % units m/s

end

