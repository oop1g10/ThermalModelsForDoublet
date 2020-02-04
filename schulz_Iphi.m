function Iphi = schulz_Iphi( N, x_0_mesh, y_0_mesh, v_u, K, alpha_deg, M, Q, a, delta_phi )
%SCHULZ_IPHI from Schulz paper 1987 eq, (26 and next one) page 18
% for definitions see function T_Schulz
    Iphi = NaN(size(x_0_mesh,1), size(x_0_mesh,2));
    for i = 1 : size(x_0_mesh,1)
        for j = 1 : size(x_0_mesh,2)
            % Calculate points xy on the streamline
            [ x_list, y_list ] = schulz_xy_streamline( N, x_0_mesh(i,j), y_0_mesh(i,j), ...
                                                    v_u, K, alpha_deg, M, Q, a, delta_phi );
            % Check if streamline ends in injection well with coordinates (-a, 0) 
            distanceFromInjectionWell = sqrt( (x_list(end) -(-a))^2 + (y_list(end) - 0)^2 );
            if distanceFromInjectionWell < a*0.005 % if streamline end point is closer than 0.5% of well distance
                % calculate groundwater velocity vector components at the given point
                [ v_x, v_y ] = schulz_velocity( x_list, y_list, v_u, alpha_deg, M, Q, a );
                % calculate goundwaer velocity vector length at the point
                v_squared = v_x.^2 + v_y.^2;
                % Time needed for water to arrive to injection well
                Iphi(i, j) = K * sum(delta_phi ./ v_squared);
            else % When streamline does not end in injection well, then Iphi is Inf (and the calculated T = T0).
                Iphi(i, j) = Inf;
            end
        end
    end
end

