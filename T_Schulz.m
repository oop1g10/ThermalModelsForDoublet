function T_tphi = T_Schulz( x, y, t, v_u, K, n, Cw, Cs, l_s, ...
                                T0, Ti, alpha_deg, M, Q, a, N, rw)
%T_SCHULZ 
% formula from Schulz paper 1987 eq, (19) page 17
% Definitions
% t_b - break throgh time (s)
% T_tphi - temperature in the aquifer depending on
% time, hydraulic potential at the defined point (location) and depth of aquifer 
% i.e. whether heat flux into cap rock is considered (z_bar)
% T0 = undisturbed temeprature  (K)
% Ti = injection temperature (K)
% x, y, z = coordinates (m)
% or also in the cap rocks. 0 means - inside aquifer.
% v = Darcy velocity (m/s)
% M = thickness of the aquifer (m)
% t - time (s)
% ro_a - density of aquifer material (water and solid) (kg/m^3)
% ro_s - solid density (kg/m^3)
% rw = m  radius of injection well. it is used in schult only to determin eif stream line is close to injection
% and the location to calculate Temperature at abstraction well.

% c_a ( specific heat capacity of saturated aquifer material (J/kg/K)
        % Note: (it is called cm in matlab code for phd project)
% Ca ( volumetric heat capacity of saturated aquifer material (J/m^3/K)

% Cw - volumetric heat capacity of water (J/m^3/K)

% c_s - specific heat capacity of solid (J/kg/K)
% Cs - volumetric heat capacity of solid (J/m^3/K)

% l_s - thermal conductivity of solid part of the aquifer, i.e. matrix (W/m/K)
% I_phi -  time for water to reach the abstraction well (s)
% n - porosity 
% U - unit step function
% N number of points x and y to calculate on the streamline 

    U = @(value) (value >= 0) * 1; % to convert logical output to number need to * 1. 
    T_tphi = NaN(size(x,1), size(x,2));
    t_b = NaN(size(x,1), size(x,2));
    % when parfor (parallel computing to spead up process) is used = breakpoints are not working inside the loop
    for i = 1 : size(x,1) 
        for j = 1 : size(x,2)
            % Check if x y point is inside the abstraction well .
            % If yes consider every streamline going into abstration well 
            % to calculate Temperature and time of breakthrough            
            % If yes (xy is inside the well) than provide the list of x y points on the wall
            % of the well depending on its radius
            
            % To calculate break through time for xy inside the well
            % calculate IPhi for points around the wall
            % and select the smallest value - it is used to calculate the breakthough time.

            % To calculate the temperature at the abstraction well - 
            % for each point around the well            
            % 1) calculate temperatures around the well (all points)
            % 2) calculate velocities around the well (all points)
            % then using all calc points around the well:
            % 3) calculate Temperature at abstraction well from weighted average of Temperatures using velocities.
            
            % Below is default calculation for all points except abstraction well
            I_phi = schulz_Iphi( N, x(i,j), y(i,j), v_u, K, alpha_deg, M, Q, a, modelBoundary, rw );
            % z_bar = 0 (no untis) to define if the temperature is calculated inside the confined aquifer
            z_bar = 0;
            % Ca is volumetric heat capacity of aquifer, Ca = ro_a * c_a;
            Ca = n * Cw + (1 - n) * Cs; % (J/m^3/K)
            t_b(i,j) = Ca / Cw * I_phi; % break through time (s)
            p1 = U( t - t_b(i,j) ); % U returns no units answer Units of p1 are (-)
            p2 = l_s / M / Cw * I_phi + M / 4 * z_bar; % units of p2 are meter
            p3 = sqrt(l_s / Cs); % units of p3 are W^0.5 * m / J^0.5
            p4 = sqrt(t - t_b(i,j)); % units of p4 are s^1/2
            % in case when p1 is zero the first term (before plus sign) for T_tphi is also zero
            % therefore value of the erfc expresion is irrelevant, but complex numbers in p4
            % (which came from sqrt of negative number) and Infinities in p2 would cause error,
            % so they are set to 1.
            p4(p1 == 0) = 1; 
            p2(p1 == 0) = 1; 
            T_tphi(i,j) = p1 .* erfc( p2 ./ (p3 * p4) ) * (Ti - T0) + T0; % units are K (units of erfc() are none (-))
        end
    end
end

