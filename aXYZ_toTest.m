function aXYZ_list = aXYZ_toTest( ax_list )
% Make aXYZ list for testing based on the given list of aX dispersivities
% ax_list = [0 2]; % longitudinal dispersivity [m]

    %   Detailed explanation goes here
    % List of aXYZ (aquifer dispersivities in 3D)
    ay_ratioTo_ax = 0.1; %relate dispersivity in y direction as 10% of dispersivity in x
    az_ratioTo_ax = 0.1; %relate dispersivity in z direction as 10% of dispersivity in x
    ay_list = ax_list * ay_ratioTo_ax; %transversal dispersivity [m]
    az_list = ax_list * az_ratioTo_ax; %transversal dispersivity [m] in z direction
    aXYZ_list = [ax_list', ay_list', az_list'];

end

