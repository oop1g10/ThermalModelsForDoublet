function [ params, mu_w, deltaH, g_const, growthRateOptim, startStepSize, N_Schulz_streamline] = ...
        standardParams( variant )
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

 if strcmp(variant, 'Homo') % field test parameters
         %   params.fe = fe; % "Heat input (W) per whole cylinder source"
        params.ro = 0.025; % borehole well radius [m]
    %    params.H = 30 * 3; %borehole length [m]    
        params.H = 6; % 30 ; %borehole length [m]
        params.M = params.H; % [m] thickness of aquifer, even the model is in 2D it is accounted for and influences model results
        params.alpha_deg = 180; %90; % [deg] % angle of gw flow, if = 0 it is parallel to x axis, if 90 = parallel to y axis
        params.T0 = degC2kelvin(10); % [K]  %   = 313.15 K	% undisturbed temperature in aquifer 
        params.Ti = degC2kelvin(25); % [K]  % injection temperature
        params.a = 5; % [m] half of distance between two wells
      % params.Q = 0.0005; % 3 / 1000; % [m^3/second],  water injection and production rate
        params.Q = 0.75 / 1000; % [m^3/second] (converted from litres per sec) approx 8 gallons per minute
        
        %% Aquifer properties      
        % aXYZ  %longitudinal (x) and transverse (y,z) thermal dispersivities [m] 
        aXYZ = [0 0 0];
        params.aX = aXYZ(1); % "Dispersivity in X direction (m)"
        params.aY = aXYZ(2); % "Dispersivity in Y direction (m)"
        params.aZ = aXYZ(3); % "Dispersivity in Z direction (m)"

        params.rhoW = 1000; % kg/m^3 density of water
        params.cW = 4200; % J/kg/K specific heat capacity of water
        
        params.rhoS = 1378; % kg/m^3 density of solid sand
        params.cS = 800; % J/kg/K specific heat capacity of solid
        % 0.8 for dry sand kJ/kg/K 
        % from https://www.engineeringtoolbox.com/specific-heat-solids-d_154.html
        params.lS = 3.34; % [W/m/K ] thermal conductivity of solid in aquifer matrix [W m-1 K-1] SAND
        % from https://www.geothermal-energy.org/pdf/IGAstandard/WGC/2010/2952.pdf
        % todo saturated is used here!!!
        K = 2.2E-4; % m/s
        deltaH = 0.001; % [m/m] Hydraulic  gradient, = 1 mm/m
        params.q = 1.15741e-07; % 0.01 / daysToSeconds(1); % 0.01 m/day K * deltaH ;% "Darcy gw velocity (m/s)" 2.2000e-07 m/s
        params.n = 0.25; % porosity of material in aquifer
        % https://www.geotechdata.info/parameter/soil-porosity.html
 end


 if strcmp(variant, 'paper_Schulz')
        deltaH = 0.001; % [m/m] Hydraulic  gradient, = 1 mm/m
    %   params.fe = fe; % "Heat input (W) per whole cylinder source"
        params.ro = 0.1; % borehole well radius [m]
    %    params.H = 30 * 3; %borehole length [m]    
        params.H = 30 * 100; %borehole length [m]
        params.M = params.H; % [m] thickness of aquifer, even the model is in 2D it is accounted for and influences model results

        params.alpha_deg = 90; % [deg] % angle of gw flow, if = 0 it is parallel to x axis, if 90 = parallel to y axis
        params.T0 = degC2kelvin(40); %   =313.15 K	% undisturbed temperature in aquifer 
        params.Ti = degC2kelvin(25); % injection temperature
        params.a = 200; % [m] half of distance between two wells
    %   params.Q = 0.03 * 3; %  [m^3/second] water injection and production rate
        params.Q = 0.03 * 100;

        %% Aquifer properties      
        % aXYZ  %longitudinal (x) and transverse (y,z) thermal dispersivities [m] 
        aXYZ = [0 0 0];
        params.aX = aXYZ(1); % "Dispersivity in X direction (m)"
        params.aY = aXYZ(2); % "Dispersivity in Y direction (m)"
        params.aZ = aXYZ(3); % "Dispersivity in Z direction (m)"

        params.rhoW = 1000; % kg/m^3 density of water
        params.cW = 4200; % J/kg/K specific heat capacity of water
        params.rhoS = 2600; % kg/m^3 density of solid
        params.cS = 1000; % J/kg/K specific heat capacity of solid
        params.lS = 2.8; % [W/m/K ] thermal conductivity of solid in aquifer matrix [W m-1 K-1]
        params.q = 1E-6;% "Darcy gw velocity (m/s)"
        params.n = 0.1; % porosity of material in aquifer
 end
 
    %  FieldExp 1 = first field experiment, FieldExpAll = all experiments (4 steps: Test1, monitoring1, Test2, monitoring2).     
    if strcmp(variant, 'FieldExp1') || strcmp(variant, 'FieldExp1m') || strcmp(variant, 'FieldExpAll') 
        deltaH = 0.0028; %0.001; % [m/m] Hydraulic  gradient, = 1 mm/m
    %   params.fe = fe; % "Heat input (W) per whole cylinder source"
        params.ro = 0.0762; %0.07; % borehole well radius [m]
    %    params.H = 30 * 3; %borehole length [m]    
        params.H = 6; %borehole length [m]
        params.M = params.H; % [m] thickness of aquifer, even the model is in 2D it is accounted for and influences model results
        params.alpha_deg = 280; % [deg] % angle of gw flow, if = 0 it is parallel to x axis (flows from left to right) if 90 = parallel to y axis
        params.T0 = degC2kelvin(10.17); % according to well 3, undisturbed temperature in aquifer 
        params.Ti = degC2kelvin(37.4); % 30 [deg C] % injection temperature
        params.a = 4.97; % [m] half of distance between two wells        
        % params.Q was used for test 1 for the whole period. 
        % For model with all tests (test 1 and test 2 and both monitoring
        % periods) params.Qb is used only for second subperiod within test 1. with lower value.
        % All other periods have fixed Q written in comsol mph file.
        if strcmp(variant, 'FieldExpAll') || strcmp(variant, 'FieldExp1m')
            params.Qb = 0.00041 / 2; % (m^3/second)  
        elseif strcmp(variant, 'FieldExp1') 
            %  params.Q = 0.03 * 3; % [m^3/second] water injection and production rate
            params.Q = 0.00041; % (cca 25 litre/minute translated in m^3/second)
        else
            % Q is not used because it is set directly into the comsol model
        end

        %% Aquifer properties      
        % aXYZ  %longitudinal (x) and transverse (y,z) thermal dispersivities [m] 
        aXYZ = [0 0 0];
        params.aX = aXYZ(1); % "Dispersivity in X direction (m)"
        params.aY = aXYZ(2); % "Dispersivity in Y direction (m)"
        params.aZ = aXYZ(3); % "Dispersivity in Z direction (m)"

        params.rhoW = 999.75; % kg/m^3 density of water
        params.cW = 4192; % J/kg/K specific heat capacity of solid
        params.rhoS = 2600; % kg/m^3 density of solid
        params.cS = 1000; % J/kg/K specific heat capacity of solid
        params.lS = 2.8; % [W/m/K ] thermal conductivity of solid in aquifer matrix [W m-1 K-1]
        params.q = 1E-5;% "Darcy gw velocity (m/s)"
        % natural undisturbed sand porosity taken from https://www.tandfonline.com/doi/abs/10.1080/10641190490900844
        params.n = 0.42; % porosity of material in aquifer  

    % For Test 2 standard parameters are best fit for test 2.
    elseif strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated')
        params = paramsFromCalib('Numerical2: 424', variant);
%         warning('best fit analytical params are used')
%         params = paramsFromCalib('Analytical: from Init424', variant);
        deltaH = 0.0028; %0.001; % [m/m] Hydraulic  gradient, = 1 mm/m       
        % test 2 has different initial temeprature by 0.32 degrees higher.
        % params.T0 = degC2kelvin(10.17 + 0.32); % according to well 3, undisturbed temperature in aquifer
        % It is given in best fit params 'Numerical2: 424'
    end
    
    %% Mesh and time step properties
    % increased from original 0.01 because comsol returned error in meshing due to too small heat source in model with fracture.
    params.maxMeshSize = maxMeshSize; %0.01; % "max el size (m) at source cylinder" standard used what is optimal in comsol (e.g. 0.01 m)   
    
    %% General constants and fixed parameters needed to calculate Reynolds numbers for qInfo (local q for aquifer and fracture)
    mu_w = 0.001324801; %[Pa*s] or [kg/s/m], dynamic viscosity of water at 10 deg C
    g_const =  9.8067; % m/s^2 acceleration due to Earth gravity
    growthRateOptim = 1.2; % [-] orig: 1.1; % mesh growth rate  
    startStepSize = 0.5; % [m] initial step to calculate coordinate points for plotting
    
    %% Specific for Schulz model ansol
    N_Schulz_streamline = 600; % number of points x and y to calculate on the streamline 

end

