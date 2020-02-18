function [ x_list, y_list ] = schulz_xy_streamline( N, x_0, y_0, v_u, K, alpha_deg, M, Q, a, ...
                                                                modelBoundary, rw )                                                   
% SCHULZ_XY_STREAMLINE 
% calculate the next point coordinates (x,y) on the stream line
    delta_phi = calc_delta_phi( N, v_u, K, modelBoundary, alpha_deg, M, Q, a, rw);
    x_m = x_0;
    y_m = y_0;    
    % prepare X and Y list to fill the results for streamline points
    x_list = NaN(N+1, 1);
    y_list = NaN(N+1, 1);
    % First point for return is x0, y0
    x_list(1) = x_0;    
    y_list(1) = y_0;
    % calculate location of all N points along streamline in the loop
    for i = 1 : N
        % calculate phi and psi for the initial point located at [x_0, y_0]
        [ phi_0, psi_0, signAtan1 ] = schulz_phi_psi( x_m, y_m, v_u, K, alpha_deg, M, Q, a );        
        % only a few Newton-Raphson iterations are needed
        for k = 1 : 2
            % calculate groundwater velocity vector components at the given point
            [ v_x, v_y ] = schulz_velocity( x_m, y_m, v_u, alpha_deg, M, Q, a );
            % calculate goundwaer velocity vector length at the point
            v_squared = v_x^2 + v_y^2;
            % calculate phi and psi for the given point
            [ phi_m, psi_m, signAtan2 ] = schulz_phi_psi( x_m, y_m, v_u, K, alpha_deg, M, Q, a );
            % formula does not work if atan in psi calculation changes the sign in the k loop. (e.g. + to -)
            % need to use only result when signs are equal in the loop (between x0y0 and xmym), 
            % which will be always true for the first iteration where x0, y0 = xm, ym.
            % therefore psi_0 = psi_m.
            % stop iterations otherwise
            if signAtan1 ~= signAtan2
                break
            end
            % Calculate next point on the stream line as in eq 26 from schulz paper 1987
            p1 = [-v_y, v_x; v_x, v_y];
            p2 = [psi_m - psi_0; phi_m - phi_0 - delta_phi];
            Point_xy1 = [x_m; y_m] + K/v_squared * p1 * p2;
            x_m = Point_xy1(1);
            y_m = Point_xy1(2);     
        end
        % save calculated point on stream line
        x_list(i + 1) = x_m;
        y_list(i + 1) = y_m;
        % finish calculation if out of model boundary
        if      x_m < modelBoundary(1,1) || ... % min x
                y_m < modelBoundary(1,2) || ... % min y
                x_m > modelBoundary(2,1) || ... % max x
                y_m > modelBoundary(2,2)        % max y
            % return only the calculated points of the streamline
            x_list = x_list(1 : i + 1);
            y_list = y_list(1 : i + 1);
            break
        end
        % finish calculation if calculated streamline xy point is close to injection well
        % because at injection well is infinite hydraulic gradient and the point of stream line will be calculated to use all given n
        % but will be dancing on one spot at injection well, as delta-phi will change = by climbing on the infinite hydr gradient
        insideInjWell = isInsideInjectionWell( x_m, y_m, a, rw );
        if insideInjWell
            % return only the calculated points of the streamline
            x_list = x_list(1 : i + 1);
            y_list = y_list(1 : i + 1);
            break
        end
        
    end
end

