function [q_list, aXYZ_list, alpha_deg_list, cS_list, lS_list, Ti_list, n_list, H_list, ...
                Q_list, a_list] = ...
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
    
    if strcmp(variant, 'Becancour')
    % List of aXYZ (aquifer dispersivities in 3D)
    ax_list = [0, 0.5, 1, 1.5, 2, 2.5]; % longitudinal dispersivity [m]
    aXYZ_list = aXYZ_toTest( ax_list ); 
    
    % Aquifer thickness
    H_list = sort([138, 200, 100, 50, 300, 400, 25]);
    
    % Thermal conductivity
    lS_list = sort([2.7, 2.6, 2.5, 3, 2.8, 2.4, 2.2, 2]);
    
    % Flow rate in injection well m3/sec
    Q_list = [0.005787037, 0.004, 0.007, 0.009, 0.011, 0.015, 0.020, 0.05, 0.07, 0.1];
    
    % Half distance between wells
    a_list = sort([1500, 1000, 800, 600, 400, 200]./2);
    else
         Q_list = [];
         a_list = [];        
    end
    
end

