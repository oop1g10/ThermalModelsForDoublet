function [ phi_xy, psi_xy, signAtan ] = schulz_phi_psi( x, y, v_u, K, alpha_deg, M, Q, a )
% to determine the values of phi and psi for x y coordinates in 2D model of schulz
% formula from Schulz paper 1987 eq, (13 and 14) page 16
% Definitions
% phi = (m) hydraulic potential
% x, y = coordinates (m)
% v_u = undisturbed velocity of natural flow field (Darcy) m/s
% v_x = Darcy velocity at x coordinate
% v_y =  Darcy velocity in y coordinate
% M = thickness of the aquifer (m)
% a = half of the distance between two wells (m)
% 2a = the distance between 2 wells
% K = value of hydraulic conductivity (a scalar) (m/second)
%           in textbook K is kf
% alpha_deg = azimuth of natural flow field (in degrees)
% Q = injected volume flow rate (m^3/second)
% Tr = aquifer transmissivity (m^2/second)
% psi = the stream function

    % Since analytical solution of Schulz assumes non-zero groundwater velocity, even if groundwater flow is absent 
    % hydraulic conductivity cannot be zero, so water can flow from injection well.
    % any non zero number is good for K, since it does not effect the model result.
    if v_u == 0
        K = 1.81E-06 * 100 ; % m/s % 1 ; % hydraulic conductivity which does not infleunce the results
    end

    Tr = K * M; % aquifer transmissivity m^2 / s
    alpha = deg2rad(alpha_deg); % radians
    % hydraulic potential at one x,y location
    p1 = - v_u / K * (x * cos(alpha) + y * sin(alpha)); % units m
    p2 = (x + a).^2 + y.^2; % units m^2
    p3 = (x - a).^2 + y.^2; % units m^2
    p4 = Q / (4 * pi * Tr) * log( p2 ./ p3 ); % units m

    phi_xy = p1 - p4; % units m

    % psi = the stream function at one xy location
    ps1 = - v_u / K * ( y * cos(alpha) - x * sin(alpha)); % units m
    ps2 = Q / (2 * pi * Tr); % units m
    ps3 = atan(2 * a * y ./(a^2 - x.^2 - y.^2)); % (-) no units
    % determine the sign of result
    signAtan = sign(ps3);  % return sign of atan function which corresponds to point distance [x,y] being larger/smaller than a (a = half of distance between wells)
    
    psi_xy = ps1 - ps2 .* ps3; % units m

    % the groundwater velocity in x direction

end

