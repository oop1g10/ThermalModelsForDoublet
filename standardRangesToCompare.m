function [ t_list, q_list, aXYZ_list, x_range, y_range, z_range, Mt, y, z, ...
           T_SS_low, timeTbh, timeTbh_max, ...
           T_plume_list, T_plume_listMC, x_Tlist, x_TlistMC, Q_list, a_list, ...
           coord_list_ObsWells, measuredWellDepth_range]...
           = standardRangesToCompare( variant )
% Ranges used to compare analytical and numerical models

    % Set standard model parameters
    paramsStd = standardParams(variant);
    [xInjection, yInjection, xAbstraction, ~] = getWellCoords(paramsStd.a);

    % Input Time discretization
    % Time step of 0.25 is used for comparison, smaller time step of 0.125
    % is used in COMSOL for better fitted models however slow.. and for
    % comparison 0.25 time step is good enough.
    
    %  FieldExp 1 = first field experiment; FieldExpAll = all experiments (4 steps: Test1, monitoring1, Test2, monitoring2).
    if  strcmp(variant, 'Homo') || strcmp(variant, 'FieldExp1')  || strcmp(variant, 'FieldExp1m') ...
            || strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated') || strcmp(variant, 'FieldExpAll') ...
            || strcmp(variant, 'Becancour')
        % build time list full from comsol
        if strcmp(variant, 'FieldExpAll')
            % For field experiment use full list of all calculated times in
            % comsol, in form as was input in Comsol
            t_list_days = [1/60/24 : 2/24 : 333930/60/60/24, 333930/60/60/24, ...
                333930/60/60/24 + 1/24/60 : 4/24 : 1466496/60/60/24, 1466496/60/60/24, ...
                1466496/60/60/24 + 1/24/60 : 2/24 : 1647510/60/60/24, 1647510/60/60/24, ...
                1647510/60/60/24 + 1/24/60 : 6/24 : 2511510/60/60/24, ...
                2511510/60/60/24 + 1 :  24/24 :  6392820/60/60/24, 6392820/60/60/24]; % days       
            t_list = daysToSeconds(round(t_list_days, 5, 'significant')); % seconds
            t_max = secondsToDays(max(t_list)); % maximum simulation time [days]
            % Times and isotherms for comparative statistics (key info comparison)
            % time to calculate temperature at specified location (or well), [seconds]
            timeTbh =  1255564.8; % 14.5 days in seconds in new time list for all field tests.
        elseif strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated')
            % For field experiment use for list of calculated times in
            % comsol for test 2, in form as was input in Comsol
            t_list_days = [1/60/24 : 1/24 : 181014/60/60/24, 181014/60/60/24, ...
                181014/60/60/24 + 1/24/60 : 4/24 : 699414/60/60/24, ...
                699414/60/60/24 + 1 :  24/24 :  4926324/60/60/24, 4926324/60/60/24]; % days       
            t_list = daysToSeconds(round(t_list_days, 5, 'significant')); % seconds
            t_max = secondsToDays(max(t_list)); % maximum simulation time [days]
            % Times and isotherms for comparative statistics (key info comparison)
            % time to calculate temperature at specified location (or well), [seconds]
            timeTbh =  daysToSeconds(2.0951); % 2.1 days in seconds, it is when heat injection finished for test 2.
        elseif strcmp(variant, 'FieldExp1m')
            t_list_days = [1/60/24 : 2/24 : 333930/60/60/24, 333930/60/60/24 ...
                333930/60/60/24 + 1/24/60 : 4/24 : 1466496/60/60/24, ...
                1466496/60/60/24 + 1 : 24/24 : 6392820/60/60/24, 6392820/60/60/24]; 
            % days       
            t_list = daysToSeconds(round(t_list_days, 5, 'significant')); % seconds
            t_max = secondsToDays(max(t_list)); % maximum simulation time [days]
            timeTbh =  daysToSeconds(3.0007); % 14.5 days in seconds in new time list for all field tests. 
        elseif strcmp(variant, 'Becancour')
            t_max = 200 * 365; % maximum simulation time [days]
            timeStep = 0.25/8; % 0.25
            t_list_days = 10.^[-3 : timeStep : 5] / 1e5 * t_max; % days
            t_list = daysToSeconds(round(t_list_days, 5, 'significant')); % seconds
            % Times and isotherms for comparative statistics (key info comparison)
            % timeTbh = daysToSeconds(15); % time to calculate temperature at specified location (or well), [seconds]
            timeTbh = daysToSeconds(365 * 50); % it is for test 1 = 14.5 days in seconds; % seconds, equals to 14.6 days
        else
            t_max = 300 * 365; % maximum simulation time [days]
            % For field experiment use full list of all calculated times in comsol
            if strcmp(variant, 'FieldExp1') || strcmp(variant, 'FieldExp1m')
                timeStep = 0.25/4;                
            else
                timeStep = 0.25; % 0.25
            end
            t_list_days = 10.^[-3 : timeStep : 5] / 1e5 * t_max; % days
            t_list_all = daysToSeconds(round(t_list_days, 5, 'significant')); % seconds
            % Use only times from cca 4 minutes to 40 days
            t_list = t_list_all(t_list_all > 259 & t_list_all < daysToSeconds(40) );
            % Times and isotherms for comparative statistics (key info comparison)
            % timeTbh = daysToSeconds(15); % time to calculate temperature at specified location (or well), [seconds]
            timeTbh = 1261612.8; % it is for test 1 = 14.5 days in seconds; % seconds, equals to 14.6 days
            
        end
        timeTbh_max = daysToSeconds(t_max); % time to calc max temperature at specified location, [seconds]
        % Difference of temperature, deg C, to find plume (isotherm) extent
        if strcmp(variant, 'Becancour')
            T_plume_list = [-1 -2];
        else
            % warning('T_plume_list = only 1 value')
            T_plume_list = [1 3 5 7];
        end
        % Difference of temperature, deg C, to find plume (isotherm) extent for Monte Carlo analysis
        T_plume_listMC = T_plume_list;
        % [m] X coordinates, distance from injection well for temperature evaluation, to plot
        x_Tlist_Inj = xInjection   + [paramsStd.ro, 1, 3, 5, 7]; 
        x_Tlist_Abs = xAbstraction - [paramsStd.ro, 1, 3, 5, 7];
        % warning('x_Tlist changed to only abstraction Well!')
        % x_Tlist = xAbstraction; 
        x_Tlist = unique([x_Tlist_Inj, x_Tlist_Abs]);
        % x_Tlist = 0; % Position betwen injection and abstraction wells
        % [m] X coordinates, distance from heat source  for temperature evaluation for Monte Carlo analysis
        x_TlistMC = x_Tlist;
    else strcmp(variant, 'paper_Schulz')
        t_max = 300 * 365; % maximum simulation time [days]
        timeStep = 0.25; % 0.25
        t_list_days = 10.^[-3 : timeStep : 5] / 1e5 * t_max; % days
        t_list = daysToSeconds(round(t_list_days, 5, 'significant')); % seconds
        % Times and isotherms for comparative statistics (key info comparison)
        timeTbh = daysToSeconds(3 * 365); % time to calculate temperature at specified location (or well), [seconds]
        timeTbh_max = daysToSeconds(300*365); % time to calc max temperature at specified location, [seconds]
        % Difference of temperature, deg C, to find plume (isotherm) extent
        T_plume_list = [-1 -2 -5 -10];
        % Difference of temperature, deg C, to find plume (isotherm) extent for Monte Carlo analysis
        T_plume_listMC = T_plume_list;
        % [m] X coordinates, distance from injection well for temperature evaluation, to plot
        x_Tlist_Inj = xInjection   + [paramsStd.ro, 1, 50, 100, 200]; 
        x_Tlist_Abs = xAbstraction - [paramsStd.ro, 1, 50, 100, 200];
        x_Tlist = unique([x_Tlist_Inj, x_Tlist_Abs]);
        % [m] X coordinates, distance from heat source  for temperature evaluation for Monte Carlo analysis
        x_TlistMC = x_Tlist;
    end
    % Calculate time series for different q (gw velocity)
    if strcmp(variant, 'FieldExp1') || strcmp(variant, 'FieldExp1m') ...
            || strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated') || strcmp(variant, 'FieldExpAll')
        q_max = paramsStd.q * 10; % Specific flux (Darcy flux) [m s-1] ] 
    else
        q_max = 1 / daysToSeconds(1); % Specific flux (Darcy flux) [m s-1] which equals to 1 m/day        
    end
    q_range = [q_max / 1000, q_max];
    q_list = logspace(log10(q_range(1)), log10(q_range(2)),4); %Specific flux (Darcy flux) [m s-1]
    q_list = [0, q_list]; % add zero groundwater velocity as first in list
    
    if strcmp(variant, 'Becancour') 
        q_list = [0]; % zero groundwater velocity
    end
    
    % List of aXYZ (aquifer dispersivities in 3D)
    ax_list = [0 2]; % longitudinal dispersivity [m]
    aXYZ_list = aXYZ_toTest( ax_list );
    
    % Fixed coordinates
    % vertical coordinate [m] % M is thicknes of aquifer which now equals to length of well
    z = paramsStd.M / 2; 
    % y direction (orthogonal to gw flow) [m], 
    % y = zero means that only flow in groundwater flow direction is modelled
    y = 0; 
    % Coordinate ranges for plots
    % number of discretization steps for space
    Mt = 101; % Mt must be odd number because during generation of mesh points odd number remains odd
    % while 1 will be added to even number. this happens to account for zero coordinate only once in the mesh list
    % assert Mt is odd number  % if number is odd than mod(Mt,2) = 1 
    % Mt is divided by given numer (2) and returns remainder after division
    assert(mod(Mt,2) == 1, 'Mt must be Odd number to not change during mesh generation');
    x_range = 3 * [xInjection, xAbstraction]; % minimum and maximum x coordinates [m] for plots
    y_range = x_range; % equal to x_range to have square field,  minimum and maximum y coordinates [m]
    z_range = [0, paramsStd.M]; % minimum and maximum z coordinates [m]
    
    % 0.99 is used to lower the max temperature at borehole by 1 % to
    % calculate the time to reach steady state at specific point
    T_SS_low = 0.99; 
    
    % Field test design parameters
    % Q_range = [paramsStd.Q / 3, paramsStd.Q * 10];
    % Q_list = logspace(log10(Q_range(1)), log10(Q_range(2)),5); 
    if strcmp(variant, 'FieldExpAll') || strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated') ...
                 || strcmp(variant, 'FieldExp1m')
        Q_list =  [];
    elseif strcmp(variant, 'FieldExp1')
        Q_list = [paramsStd.Q / 5 * 2 , paramsStd.Q / 5 * 3, paramsStd.Q / 5 * 4, paramsStd.Q, ...
                    paramsStd.Q / 5 * 6 ];
    elseif strcmp(variant, 'Becancour') 
        Q_list = [paramsStd.Q / 5 * 2 , paramsStd.Q / 5 * 3, paramsStd.Q / 5 * 4, paramsStd.Q, ...
            paramsStd.Q / 5 * 6 ];
    else
        Q_list =  [];
    end
    a_list = [1:1:6]; % HALF distance between wells 
    % xy coordinates for observation wells
    % For Field test variant set coordinates of real observation wells
    if strcmp(variant, 'FieldExp1') || strcmp(variant, 'FieldExp1m') ...
            || strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated') || strcmp(variant, 'FieldExpAll')
        % Well coordinates
        wellCoords = wellCoordinates(variant); 
        coord_list_ObsWells = [wellCoords.x, wellCoords.y];
    else     
        coord_list_ObsWells = [xInjection - paramsStd.a, yInjection ; ... % left
                               xInjection, yInjection + paramsStd.a ; ... % up
                               xInjection + paramsStd.a, yInjection ; ...  % right
                               xInjection, yInjection - paramsStd.a ] ; % down
    end
    
    % Depth range for measured well temperature
    measuredWellDepth_range = [27.5, 28.5];
    % measuredWellDepth_range = [28.5, 29.5];
end

