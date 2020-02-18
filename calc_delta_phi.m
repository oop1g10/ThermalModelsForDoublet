function [ delta_phi ] = calc_delta_phi( N, v_u, K, modelBoundary, alpha_deg, M, Q, a, rw)
% calculate delta_phi
% delta_phi is change in hydraulic potential, which defines steps to calculate streamfunction

    % calculate phi in points where its change is expected to be the highest/lowest
    [Xmesh, Ymesh] = meshgrid(modelBoundary(:,1), modelBoundary(:,2));
    XYpoint_list = [Xmesh(:), Ymesh(:)]; % list of xy coordinate points for corners of the domain
    % add xy coordinates close to the injection and extraction wells which are the the wall of the wells
    XYpoint_list = [XYpoint_list; [rw*0.99 + -a, 0]; [-rw*0.99 + a, 0]]; % * 0.99 to be inside the wall well to have enough delta_phi    
    % calculate phi (hydraulic potential) at each point (at model cornes and at the injection & extraction well   
    phi_xy = schulz_phi_psi(XYpoint_list(:,1), XYpoint_list(:,2), v_u, K, alpha_deg, M, Q, a );
    phi_xy_maxdiff = max(phi_xy) - min(phi_xy);
    delta_phi = phi_xy_maxdiff / N;
    % old version is below
%     i = v_u / K ;
%     factor_phi = 2 * ( (Q / 0.03) / (v_u / 1.0000e-06) ); 
%     delta_phi = maxModelDistance * i / N * factor_phi;
    %times 2 is to make it bigger as the slope changes by the injection/extraction
end

