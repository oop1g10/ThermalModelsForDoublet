function [ t_list, q_list, aXYZ_list, x_range, y_range, z_range, Mt, y, z, ...
           T_SS_low, timeTbh, timeTbh_max, ...
           T_plume_list, T_plume_listMC, x_Tlist, x_TlistMC, Q_list, a_list, coord_list_ObsWells]...
           = standardRangesToCompare( variant )
% Ranges used to compare analytical and numerical models

    % Set standard model parameters
    paramsStd = standardParams(variant);
    [xInjection, yInjection, xAbstraction, ~] = getWellCoords(paramsStd.a);

    % Input Time discretization
    % Time step of 0.25 is used for comparison, smaller time step of 0.125
    % is used in COMSOL for better fitted models however slow.. and for
    % comparison 0.25 time step is good enough.
    if  strcmp(variant, 'Homo')
        % build time list full from comsol
        t_max = 300 * 365; % maximum simulation time [days]
        timeStep = 0.25; % 0.25
        t_list_days = 10.^[-3 : timeStep : 5] / 1e5 * t_max; % days
        t_list_all = daysToSeconds(round(t_list_days, 5, 'significant')); % seconds
        t_list = t_list_all(t_list_all > 259 & t_list_all < daysToSeconds(40) );
        % Times and isotherms for comparative statistics (key info comparison)
        timeTbh = daysToSeconds(15); % time to calculate temperature at specified location (or well), [seconds]
        timeTbh_max = daysToSeconds(t_max); % time to calc max temperature at specified location, [seconds]
        % Difference of temperature, deg C, to find plume (isotherm) extent
        % warning('T_plume_list = only 1 value')
        T_plume_list = [1 3 5 7];
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
    q_max = 1 / daysToSeconds(1); % Specific flux (Darcy flux) [m s-1] which equals to 1 m/day
    q_range = [q_max / 1000, q_max];
    q_list = logspace(log10(q_range(1)), log10(q_range(2)),4); %Specific flux (Darcy flux) [m s-1]
    q_list = [0, q_list]; % add zero groundwater velocity as first in list
    
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
    Q_list = [paramsStd.Q / 5 * 2 , paramsStd.Q / 5 * 3, paramsStd.Q / 5 * 4, paramsStd.Q, ...
                paramsStd.Q / 5 * 6 ];
    a_list = [1:1:6]; % HALF distance between wells 
    % xy coordinates for observation wells
    coord_list_ObsWells = [xInjection - paramsStd.a, yInjection ; ... % left
                           xInjection, yInjection + paramsStd.a ; ... % up
                           xInjection + paramsStd.a, yInjection ; ...  % right
                           xInjection, yInjection - paramsStd.a ] ; % down
end

