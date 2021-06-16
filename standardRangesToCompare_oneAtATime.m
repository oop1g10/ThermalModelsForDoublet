function [q_list, aXYZ_list, alpha_deg_list, cS_list, lS_list, Ti_list, n_list, H_list ] = ...
      standardRangesToCompare_oneAtATime(variant)

    % Groundwater velocity
    q_range = [1E-6, 1E-2];  % m/s
    q_list = logspace(log10(q_range(1)), log10(q_range(2)),10); %Specific flux (Darcy flux) [m s-1]
    q_list = [0, q_list]; % add zero groundwater velocity as first in list

    % List of aXYZ (aquifer dispersivities in 3D)
    ax_list = [0 : 0.2 : 2]; % longitudinal dispersivity [m]
    aXYZ_list = aXYZ_toTest( ax_list );
    
    % Groundwater direction (degrees)
    alpha_deg_list = [160 : 10:  280];
    if strcmp(variant, 'FieldExp2Rotated')
        rotateTest2Struct = rotateTest2Info();
        alpha_deg_list = alpha_deg_list +  round(rotateTest2Struct.rotationAngleDeg, -1);
    end
    % Thermal capacity
    cS_list = [600 : 50 : 1100];
    % Thermal conductivity
    lS_list = [1 : 0.125 : 2.5];
    % Temperature of injection
    Ti_list = [degC2kelvin(29) : 0.25 : degC2kelvin(31)];
    % Aquifer porosity
    n_list = [0.1 : 0.025 : 0.4];
    % Aquifer thickness
    H_list = [1 : 1 : 12];
    
end

