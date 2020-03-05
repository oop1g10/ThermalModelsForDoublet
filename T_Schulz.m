function [T_diff, t_b] = T_Schulz( x, y, t, v_u, K, n, Cw, Cs, l_s, ...
                                T0, Ti, alpha_deg, M, Q, a, modelBoundary, N, rw)
%T_SCHULZ 
% formula from Schulz paper 1987 eq, (19) page 17
% Definitions
% Q - water injection and production rate in m^3/second
% t_b - break throgh time (s)
% T_diff - temperature difference from T0 in the aquifer depending on
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
% rho_s - solid density (kg/m^3)
% rw = m  radius of injection well it is used in schult only to determin eif stream line is close to injection
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

    % Since analytical solution of Schulz assumes non-zero groundwater velocity, even if groundwater flow is absent 
    % hydraulic conductivity cannot be zero, so water can flow from injection well.
    % any non zero number is good for K, since it does not effect the model result.
    if v_u == 0
        K = 1; % hydraulic conductivity which does not infleunce the results
    end

    U = @(value) (value >= 0) * 1; % to convert logical output to number need to * 1. 
    T_diff = NaN(size(x,1), size(x,2));
    t_b = NaN(size(x,1), size(x,2));
    
    % z_bar = 0 (no untis) to define if the temperature is calculated inside the confined aquifer
    z_bar = 0;
    % Ca is volumetric heat capacity of aquifer, Ca = ro_a * c_a; 
    Ca = n * Cw + (1 - n) * Cs; % (J/m^3/K)
 
    % to calculate locations xy of points around well
    pointsNumber = 24; % number of points around well to calculate the locaitons.
    [~, ~, xAbsWell, yAbsWell] = getWellCoords(a);% coordinated of abstraction well
    % when parfor (parallel computing to spead up process) is used 
    % = breakpoints are not working inside the loop
    for i = 1 : size(x,1)
        parfor j = 1 : size(x,2)
            % Check if x y point is inside the abstraction well. DONE
            % If yes consider every streamline going into abstration well 
            % to calculate Temperature and time of breakthrough             
            % If yes (xy is inside the well) than provide the list of x y points on the wall
            % of the well depending on its radius DONE
            
            % if xy inside well, 
            if isInsideAbstractionWell( x(i,j), y(i,j), a, rw )
                % do this and save tb and t for this point. if not other...
                [ xList_aroundWell, yList_aroundWell ] = ...
                    xyPointsOnWellWall( rw, xAbsWell, yAbsWell, pointsNumber );

                % To calculate break through time for xy inside the well
                % calculate IPhi for points around the wall
                % and select the smallest value - it is used to calculate the breakthough time.

                % To calculate the temperature at the abstraction well -
                % for each point around the well        
                % 1) calculate temperatures around the well (all points)
                % Temperature and breakthrough times for points around the well
                [T_diff_aroundWell, t_b_aroundWell] = T_Schulz( xList_aroundWell, yList_aroundWell, ...
                    t, v_u, K, n, Cw, Cs, l_s, ...
                                    T0, Ti, alpha_deg, M, Q, a, modelBoundary, N, rw);    
                % calculate thermal break through at the abstraction well
                % which is the minimum tb from all the points aorund the well
                t_b(i,j) = min(t_b_aroundWell); % break through time at abstraction well (s)
              
                % calculate velocities for all the points around the well
                [ v_x_aroundWell, v_y_aroundWell ] = schulz_velocity( xList_aroundWell, yList_aroundWell, ...
                                                                        v_u, alpha_deg, M, Q, a );
                
                % gw velocity magnitude inside well around well points
                v_aroundWell = sqrt(v_x_aroundWell.^2 + v_y_aroundWell.^2);
                % find component of velocities towards the well.. (but it will work anyway) TODO
                %to exclude T whcih flow from the well to exclude form averange calc
                % weighted ave of T around the well using velocities
                T_diff(i,j) = sum(T_diff_aroundWell .* v_aroundWell / sum(v_aroundWell));                
                % where for each point around the well a specific v_aroundWell (point) /sum(v_aroundWell) 
                % is a weighting factor for T at each point around the well          
                % weighted average of temperature at abstraction well                
                
                % SIMPLE analytical solution for T at abstraction well from shultz 1987 paper table 2, 
                % which is valid for non zero gw flows and y is alwyas = zero
                % gw direction parallel to wells location
                 
%% incorrect results from analytical formulas from table in schulz tab
%                         c = abs( a^2 + a * Q / ( pi * M * v_u * cos(deg2rad(alpha_deg)) ) )^1/2; 
%                         if alpha_deg == 0 && v_u > 0
% 
%                         % log is natural logarythm
%                         % different result than analytical solution for time to breakthrough, for points aorund well wall
%                         t_b_Ansol =   Ca / Cw * 2 * a / v_u * (1 - Q / (2 * pi * M * v_u * c) * log((c+a)/(c-a))); 
%                         compare_tb.t_b = t_b(i,j);
%                         compare_tb.t_b_Ansol = t_b_Ansol;
%                         compare_tb.relDiff = (compare_tb.t_b - compare_tb.t_b_Ansol) / compare_tb.t_b_Ansol;
%                     end
%                     if alpha_deg == 180 && v_u > 0 && v_u < (Q / (a * pi * M))
%                         % ABSolute for c see formula??? TODO
%                         % log is natural logarythm
%                         t_b_Ansol =   Ca / Cw * 2 * a / v_u * (-1 + Q / (pi * M * v_u * c) * atan(a/c)); 
%                         compare_tb.t_b = t_b(i,j);
%                         compare_tb.t_b_Ansol = t_b_Ansol;
%                         compare_tb.relDiff = (compare_tb.t_b - compare_tb.t_b_Ansol) / compare_tb.t_b_Ansol;
%                     end
                
            else % for points outside abstraction well
                I_phi = schulz_Iphi( N, x(i,j), y(i,j), v_u, K, alpha_deg, M, Q, a, modelBoundary, rw );
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
                % units are K (units of erfc() are none (-))
                % to make T difference '+ T0' was removed from the end of equation,
                % it was in original Schulz equation
                T_diff(i,j) = p1 .* erfc( p2 ./ (p3 * p4) ) * (Ti - T0); % '+ T0'
                

            end
        end
    end
end

