function [ params, mu_w, deltaH, g_const, growthRateOptim, N_Schulz_streamline] = standardParams( variant )
%Return standard default parameters for models
% params = copy of parameters with added few (specific for Comsol) for
% statistics comparison and sensitivity analysis (monte carlo sampling)
% variant - "homo" to receive standard parameters for homogenous aquifer "without" fracture
%         - "frSingle" to receive standard parameters for aquifer with single fracture (which has effect). 
%          - 'frSingle_TightMat' to receive parameters for aquifer with tight matrix and single fracture (which has effect)

    %% Based on model dimension 2D or 3D mesh geometry options are different: take them from function
    [~,~,~,~,~,~,~, ~, maxMeshSize ] = comsolDataFileInUse_Info( );

    %% Heat exchanger properties
    % Input Space discretization
    % Input flow and heat transport parameters
%     QL = 50;   %Heat flow rate per unit length of borehole [W/m]
%     fe = QL * H;   %Heat flux [W]
%     
%   params.fe = fe; % "Heat input (W) per whole cylinder source"
    params.ro = 0.1; % borehole well radius [m]
    params.H = 100; %borehole length [m]
    
    params.alpha_deg = 90; % [deg] % angle of gw flow, if = 0 it is parallel to x axis, if 90 = parallel to y axis
    params.T0 = 40; % [deg C] degC2kelvin(40); %   =313.15 K	% undisturbed temperature in aquifer 
    params.Ti = 25; % [deg C] degC2kelvin(25); % injection temperature
    params.a = 200; % [m] half of distance between two wells
    params.Q = 0.03; %  [m^3/second] water injection and production rate
    
    %% Aquifer properties      
    % aXYZ  %longitudinal (x) and transverse (y,z) thermal dispersivities [m] 
    aXYZ = [0 0 0];
    params.aX = aXYZ(1); % "Dispersivity in X direction (m)"
    params.aY = aXYZ(2); % "Dispersivity in Y direction (m)"
    params.aZ = aXYZ(3); % "Dispersivity in Z direction (m)"
    
    params.rhoW = 1000; % kg/m^3 density of solid
    params.cW = 4200; % J/kg/K specific heat capacity of solid
    params.rhoS = 2600; % kg/m^3 density of solid
    params.cS = 1000; % J/kg/K specific heat capacity of solid
    params.lS = 2.8; % [W/m/K ] thermal conductivity of solid in aquifer matrix [W m-1 K-1]
    params.q = 1E-6;% "Darcy gw velocity (m/s)"
    params.n = 0.1; % porosity of material in aquifer
    params.M = 30; % [m] thickness of aquifer, even the model is in 2D it is accounted for and influences model results
    %% Mesh and time step properties
    % increased from original 0.01 because comsol returned error in meshing due to too small heat source in model with fracture.
    params.maxMeshSize = maxMeshSize; %0.01; % "max el size (m) at source cylinder" standard used what is optimal in comsol (e.g. 0.01 m)   
    
    %% General constants and fixed parameters needed to calculate Reynolds numbers for qInfo (local q for aquifer and fracture)
    mu_w = 0.001324801; %[Pa*s] or [kg/s/m], dynamic viscosity of water at 10 deg C
    deltaH = 0.001; % [m/m] Hydraulic head gradient, = 1 mm/m
    g_const =  9.8067; % m/s^2 acceleration due to Earth gravity
    growthRateOptim = 1.1; % mesh growth rate  
    
    %% Specific for Schulz model ansol
    N_Schulz_streamline = 600; % number of points x and y to calculate on the streamline 

end

