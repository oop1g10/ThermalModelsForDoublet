% Clean ALL is used here to clear persistent variables, in case input data is changed
% Persistent variables in function are used as cache.
clear all

%% Decide which plots to generate
plotT_q = true; %+ T change vs time at different GW flows
plotTxy_stream_tb = false; % Plot streamlines, hydraulic potential, isotherms and times to thermal breakthrough
    plotTxy_stream_tb_Txy = true; % plot isotherms
    plotTxy_stream_tb_tb = true; % plot time to breakthrough
    plotTxy_stream_tb_stream = true; % plot streamlines
        plotTxy_stream_tb_stream_withLabels = false; % if to plot hydraulic pressure labels
    plotTxy_stream_tb_param = false; % Plot for set parameters
plotTxy_q = false; % ADJUSTED %%%%% + How groundwater velocity influences plume development in x&y direction (plan view)
% for 3D  only
plotTz_q_x = false; %+ Temperature at different x versus depth (z dimention) for different GW flows

plotT_t_axy = false; %* How dispersivity influences plume development with time in x direction
    plotT_model_axy = false; % same but for one time and for two models
    
plottb_a_Q_q = false; % time to break through vs distance between wells for various flow in inj well and gw flows

plotTxz_q = false; % TODO %%%%%%%%%%%%%%%  PROFILE
%+ How groundwater velocity influences isotherm development in x&z direction (profile view)

plotTb_axy_q = false; %+ Temperature at borehole wall after 30 years vs dispersivities at different GW flows

plotXt_q_fe = false; % TODO Plume extent longitudinal (X) after set time (t) vs groundwater flow (q) for different heat input (fe)

% Model calibration plots %%%%%%%%%%%%%%%%%%%%%%%%
plotT_t_well = false; %+ T change vs time at different wells of field site for modelled and measured results


%% Save the plots
plotSave = false;
% plotExportPath = 'C:\Users\Asus\OneDrive\INRS\COMSOLfigs\doublet_2d_fieldtest\';
plotExportPath = 'C:\Users\Asus\OneDrive\INRS\COMSOLfigs\doublet_2d_Becancour\';
plotExportPathCalib = 'C:\Users\Asus\OneDrive\INRS\COMSOLfigs\doublet_2d_fieldtestCalib\';

[comsolDataFile, comsolDataFileConvergence, modelMethods, modelMethodsConvergence, variant,...
    solution, methodMesh, ~, ~ ] = comsolDataFileInUse_Info( );
fprintf('methodMesh: %s\n', methodMesh);

% Set standard model parameters
[paramsStd, ~, deltaH] = standardParams(variant);
% Get list of different parameter ranges for plots
[ t_list, q_list, ~, x_range, y_range, z_range, Mt, y, z, ~, timeTbh, timeForT_max,...
    T_plume_list, ~, x_Tlist, ~, Q_list, a_list, coord_list_ObsWells, measuredWellDepth_range ] = ...
    standardRangesToCompare( variant );

% warning('return variant from string to variable, it was changed to retieve z value')
% % take list and q lift from test 1 for plan view figure
% [ ~, q_list, ~, x_range, y_range, z_range, Mt, y, z, ~, timeTbh, timeForT_max,...
%     T_plume_list, ~, x_Tlist, ~, Q_list, a_list, coord_list_ObsWells, measuredWellDepth_range ] = ...
%     standardRangesToCompare( 'FieldExp1' );
% % take z range from test 2
% [ t_list, ~, ~, x_range, y_range, z_range, Mt, y, z, ~, timeTbh, timeForT_max,...
%     T_plume_list, ~, x_Tlist, ~, Q_list, a_list, coord_list_ObsWells, measuredWellDepth_range ] = ...
%     standardRangesToCompare( 'FieldExp2' );

q_max = max(q_list); %Specific flux (Darcy flux) [m s-1] % maximm required Darcy velocity
modelMethodsPlot = [modelMethods(1), modelMethods(2)]; % 1 = Schulz/Homo; 2 = Comsol 2D
modelMethodPlot = modelMethods{1}; % Method of model calculation
% NOTE selected plot support comparison of two models some only one model method
% Model methods for which comparison plot should be generated
% First method is full line for analytical model, 
% Second method (numerical model) oo circles line
plotTitle = modelMethodPlot; % plotTitle

%% Load previously saved workspace variables with comsol data in comsolResultsTab
load(comsolDataFile)
% If needed ONLY: Add missing columns to loaded result   
comsolResultsTab = addToTabAbsentParams( comsolResultsTab, variant );

%% Power calculation
% %% Calculate which power is needed for 1 K change for the set Q
% % fe = m^3/second * kg/m^3 * J/kg/K  = J / sec / K = W / K 
% fe_1K = paramsStd.Q * paramsStd.rhoW * paramsStd.cW; 
% fprintf('%.1f W per K\n', fe_1K)
% % 5600 W for 1 K
% % 5.6 kW for 1 K
% % for 10 K the needed kW is
% deltaT = paramsStd.Ti - paramsStd.T0; % K 
% fe = fe_1K * deltaT; % necessary fe to heat water at set Q for 10 K
% % 56 kW!!!!
% fprintf('%.1f W per deltaT %.1f K \n', fe, deltaT)

%% Extract data for plot T change at different GW flows
% Point where temperature will be analyzed
if plotT_q
    plotNamePrefix = 'T_q'; % plot name to save the plot with relevant name    
    x_list = x_Tlist; % [m] X coordinates, distance from heat source, to plot  
    warning('test x list')
    % x_list = -999.9396 + [1, 10, 50, 100, 1000];
    warning('x_list changed')
    x_list = -899.94;
    Mt_T_q = 1; % calculation only in one point
    calibVariant = 'Becancour_litpars';
    paramsStd = paramsFromCalib(calibVariant, variant);
    warning("paramsStd are changed for plotT_q check other plots are not affected");
    % bestFitParams = 'q[2.8128e-05] aXYZ[1.97503 1.97503 1.97503] ro[0.0762] H[6] M[6] adeg[278.74] T0[283.15] Ti[310.55] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[800.026] lS[1.90001] n[0.599998] mesh[0.1]';
    % trial params set with lower inj temeprature
    % bestFitParams = 'q[2.8128e-05] aXYZ[1.97503 1.97503 1.97503] ro[0.0762] H[6] M[6] adeg[278.74] T0[283.15] Ti[287.6] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[800.026] lS[1.90001] n[0.599998] mesh[0.1]';
    % paramsBestFit = comsolFilename_Info( ['plan sol1 0001 ', bestFitParams, '.txt'], variant );

    % One plot for each point location along x axis from list
    for ix = 1:numel(x_list)
        point_MidDepth = [x_list(ix), y, z];
        T_q = nan(length(q_list) * numel(modelMethodsPlot), length(t_list));
        legendTexts_q = cell(1, length(q_list) * numel(modelMethodsPlot)); % text for legends on plot
        i = 0;
        for iq = 1:numel(q_list)
            % Parameters from comsol result
           % warning('best fit pars are used')
            params = paramsStd;   
            params.q = q_list(iq);
            % params = paramsBestFit;             
            
            % For each model method
            for im = 1:numel(modelMethodsPlot)
                i = i + 1;
                % Calculate temperature series for current q
                T_q(i,:) = ...
                   T_eval_model(modelMethodsPlot{im}, [point_MidDepth(1), point_MidDepth(1)], ...
                                                point_MidDepth(2), point_MidDepth(3), ...
                                                Mt_T_q, params, t_list, comsolResultsTab, 'T', variant);

                legendTexts_q{i} = sprintf('%s: v_D = %.3f m/day', ...
                    modelMethodsPlot{im}, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
            end
        end
        % Plot Time to reach steady state at different GW flows
        % to allow for one or two model methods use same colours for gw flows
        q_colorOrder = [1 2 3 4 5];
        % Duplicate colour number to be the same for each model. 
        q_colorOrder = sort(repmat(q_colorOrder, 1,numel(modelMethodsPlot)));        
        plotName = sprintf('%s_x%.2fm_z%dm_a[%.1f %.1f %.1f]_%s', ...
                plotNamePrefix, point_MidDepth(1), point_MidDepth(3), ...
                params.aX, params.aY, params.aZ, cell2mat(modelMethodsPlot));
        plotTitleT_q = plotName;
        plotTitleT_q(plotTitleT_q == '_') = '-'; %replace _ with - in plot title not to print as subscript
            
        plotT_q_fun( t_list, T_q, point_MidDepth(1), [], ...
            legendTexts_q, q_colorOrder, plotTitleT_q, [], {'none','o'})   
        % Save figure
        if plotSave
            saveFig([plotExportPath plotName])
        end    
    end
end

%% Plot streamlines, hydraulic potential,  isotherms and times to thermal breakthrough
if plotTxy_stream_tb
    plotNamePrefix = 'Txy_stream_tb'; % plot name to save the plot with relevant name
    % times for results    1.9481 years col 94 and 5.3348 yrs column 101 in time list from comsol
    % t_list_plotTxy_q = 168238080; % [6.143644800000002e+07, 168238080]; % time in seconds        
    t_list_plotTxy_q = timeTbh; %t_list(25); % = 1 day % [t_list(44), timeTbh]; %  around 14 days as calc in numerical model %t_list(16) ; % t_list(15); % = 9.5 days %    10 / secondsToDays(1); % seconds from days
    % preassign 4 D matrices for T to save the results
    q_listSpec = paramsStd.q;
    Txy_stream_tb = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_listSpec));
    % same for tb ( which is based on I phi)
    t_b_mesh = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_listSpec));
    % same for phi (hydraulic potential)
    phi_xy_mesh = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_listSpec));
    % same for groundwater velocities, parts of the vector [ v_x, v_y ],
    % both v_x and v_y are calculated in all mesh points.
    v_x = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_listSpec));
    v_y = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_listSpec));
    % If only one parameter should be plotted
    if plotTxy_stream_tb_param
        % best fit calibrated params
        paramsUse = paramsFromCalib('Numerical: q,aX,alpha,cS,lS,n,H RunCount:0488 WIDER ranges cS,H init 431', variant);
       % paramsUse = paramsStd; % Params before calibration
        q_listSpec = paramsUse.q;
    else
        paramsUse = paramsStd;
    end
    
    hWait = waitbar(0, '', 'Name','Calculating results ...');
    i = 0;
    for it = 1:numel(t_list_plotTxy_q)
        % prepare matrices for results
        for iq = 1:numel(q_listSpec)
            % Show progress info bar
            i = i + 1;
            waitInfo = sprintf('v_D = %.3f m/day',   q_listSpec(iq) * daysToSeconds(1) );
            waitbar(i / (numel(t_list_plotTxy_q) * numel(q_listSpec)), hWait, waitInfo); %show progress

            params = paramsUse;
            params.q = q_listSpec(iq);
            zUse = params.H/2;
            
            %% Temperature, time to breakthrough, streamlines and hydraulic potential for plot
            % create string with variable names requested for plot
            evalTask = '';
            if plotTxy_stream_tb_Txy
                evalTask = [evalTask, 'T, '];
            end
            if plotTxy_stream_tb_tb
                evalTask = [evalTask, 't_b, '];
            end
            % calc streamlines and hydraulic potential for plot
            if plotTxy_stream_tb_stream
            % calculate hydraulic potential phi
            % calculate groundwater velocities in x and y direction (in 2D to plot streamlines)
                evalTask = [evalTask, 'v, H'];
            end
            
            % Calculate required variable for current q
            [~, ~, Txy_stream_tb(:,:,it, iq ), Xmesh, Ymesh, ~, ~, ~, t_b_mesh(:,:,it, iq ), ...
                v_x(:,:,it, iq ), v_y(:,:,it, iq ), phi_xy_mesh(:,:,it, iq )] = ...          
               T_eval_model(modelMethodPlot, x_range, y_range, zUse, ...
                            Mt, params, t_list_plotTxy_q(it), comsolResultsTab, evalTask, variant);
        end
    end
    close(hWait); % close progress window

    %% Plot PLAN VIEW streamlines, hydraulic potential,  isotherms and times to thermal breakthrough
%     T_isotherm = T_plume_list ; % [11 15 19]; % [-14, - 10, -5, -1]; % temperature for limit of plume on plot display (Kelvin)
    T_isotherm = [-10, -25];
    % tb_list = [ 1, 2, 5, 10] / secondsToDays(1); % seconds
    tb_list = [ 25 * 365, 100 * 365, 200 * 365] / secondsToDays(1); % seconds

    for iq = 1:numel(q_listSpec)       
        for it = 1 : numel(t_list_plotTxy_q)
            % prepare legend
            legendTexts_q_plotTxy_stream_tb{1} = sprintf('v_D = %.3f m/day', q_listSpec(iq) * daysToSeconds(1)); % legend for list of gw velocity [m/day]
            
            % Create the plot streamlines, hydraulic potential,  isotherms and times to thermal breakthrough
            plotTxy_stream_tb_fun( Txy_stream_tb(:,:,it, iq), legendTexts_q_plotTxy_stream_tb, t_list_plotTxy_q(it), ...
                            T_isotherm, tb_list, phi_xy_mesh(:,:,it, iq), v_x(:,:,it, iq), v_y(:,:,it, iq), ... 
                            t_b_mesh(:,:,it, iq), ...
                            Xmesh, Ymesh, plotTitle, iq, coord_list_ObsWells, plotTxy_stream_tb_stream_withLabels) % last iq sets the colour of isotherms
                                                         % to correspond to the colour of groundwater velocity
            if plotSave        
                if secondsToYears(t_list_plotTxy_q(it)) >= 1
                    plotName = sprintf('%s_q%.3fmd-1_z%dm_a[%.1f %.1f %.1f]_t%.0fy_%s', ...
                        plotNamePrefix, q_listSpec(iq) * daysToSeconds(1), ...
                        z, params.aX, params.aY, params.aZ, ...
                        secondsToYears(t_list_plotTxy_q(it)), modelMethodPlot);
                else
                    plotName = sprintf('%s_q%.3fmd-1_z%dm_a[%.1f %.1f %.1f]_t%.0fdays_%s', ...
                        plotNamePrefix, q_listSpec(iq) * daysToSeconds(1), ...
                        z, params.aX, params.aY, params.aZ, ...
                        secondsToDays(t_list_plotTxy_q(it)), modelMethodPlot);
                end

                saveFig([plotExportPath plotName])
            end
        end
    end

end     

%% Extract data for plot 
%% PLAN VIEW how groundwater velocity influences plume development in x&y direction
if plotTxy_q
    plotNamePrefix = 'Txy_q'; % plot name to save the plot with relevant name
    varplot = variant;
    % t_list_plotTxy_q = [daysToSeconds(5*365)]; % time in seconds
  %  t_list_plotTxy_q = [8.196595200000000e+05, 2592000]; % [seconds] equaling to 9.5, 30 days  
    % in 2 weeks
    t_list = comsolResultsTab.timeList{1,1}(67);
    t_list_plotTxy_q = t_list; % secondsToDays(t_list); %in seconds, equals to 2 weeks 
    
    for it = 1:numel(t_list_plotTxy_q)
        % prepare matrices for results
        [ ~, q_list, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~ ] = ...
                standardRangesToCompare( variant );
        Txy_q = nan(Mt, Mt, numel(q_list)); % temperature series
        % pre-allocate empty strings to legend text 
        % in case not all q are filled it will be working.
        legendTexts_q = repmat({''},1,numel(q_list)); % OLD version: legendTexts_q = cell(1, numel(q_list));        
        for i = 1:numel(q_list)
            % params = paramsStd;
            warning('return variant from string to variable')
            params = paramsFromCalib('Numerical2: 424', 'FieldExp2');
            params.q = q_list(i);
            params.aX = 0; 
            params.aY = 0; 
            params.aZ = 0; 
            params.alpha_deg = 271.215; % from Test 2 rotated
            params.a = 3.14067; % from Test 2 rotated
            params.Q = 0.000407; % injection flow rate
            % Calculate temperature series for current q
            [~, ~, Txy_q(:, :, i), Xmesh, Ymesh, ~ ] = ...          
               T_eval_model(modelMethodPlot, x_range, y_range, z, ...
                            Mt, params, t_list_plotTxy_q(it), comsolResultsTab, 'T', variant);

            legendTexts_q{i} = sprintf('v_D = %.3f m/day', q_list(i)*daysToSeconds(1)); % legend for list of gw velocity [m/day]
        end

        %% Plot MFLS with physical units PLAN VIEW
        T_isotherm = [1 10]; % [-1, -14]; % temperature for limit of plume on plot display (Kelvin)
        plotTxy_q_fun( Txy_q, legendTexts_q, t_list_plotTxy_q(it), T_isotherm, Xmesh, Ymesh, plotTitle )

        if plotSave        
            if secondsToYears(t_list_plotTxy_q(it)) >= 1
                plotName = sprintf('%s_z%dm_a[%.1f %.1f %.1f]_t%.0fy_%s', ...
                    plotNamePrefix, z, params.aX, params.aY, params.aZ, ...
                    secondsToYears(t_list_plotTxy_q(it)), [modelMethodPlot, varplot]);
            else
                plotName = sprintf('%s_z%dm_a[%.1f %.1f %.1f]_t%.0fdays_%s', ...
                    plotNamePrefix, z, params.aX, params.aY, params.aZ, ...
                    secondsToDays(t_list_plotTxy_q(it)), [modelMethodPlot, varplot]);
            end
            saveFig([plotExportPath plotName])
        end        
    end
end

%% Extract data for plot: Temperature at different x versus depth (z dimention) for different GW flows
% Point where temperature will be analyzed
if plotTz_q_x
    plotNamePrefix = 'Tz_q_x'; % plot name to save the plot with relevant name
    % x_list means [m] X coordinates, distance along x axis, to plot (0.03 menas x axis location of pipes from center of grout [0, 0])
    % x_list = [0.03, ro];
    warning('comment line below')
    x_list = x_Tlist(end); % 0.03; %  [0.03, ro, 1, 10];
    y = 0; % [m] Y coordinate
    z_range = [0, paramsStd.H]; % z coordinates range [m]
    time = timeTbh;
    % One plot for each point location along x axis from list
    for ix = 1:numel(x_list)
        Tz_q_x = nan(length(q_list) * numel(modelMethodsPlot), Mt); 
        modelNames_Tz_q_x = cell(size(Tz_q_x,1), 1); % set size for matrix with model names
        legendTexts_q = cell(size(Tz_q_x,1), 1); % text for legends on plot
        i = 0; 
        for iq = 1:numel(q_list)
            % Parameters from comsol result
            params = paramsStd;
            params.q = q_list(iq);          
            % For each model method
            for im = 1:numel(modelMethodsPlot)
                % Calculate temperature series for x
                i = i + 1;
                [Tz_q_x(i,:),~,~,~,~, z_list] = T_eval_model(modelMethodsPlot{im}, ...
                                                [x_list(ix) x_list(ix)], y, z_range, ...
                                                Mt, params, time, comsolResultsTab, 'T', variant);
                legendTexts_q{i} = sprintf('%s: v_D = %.3f m/day', ...
                    modelMethodsPlot{im}, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
                modelNames_Tz_q_x(i) = modelMethodsPlot(im);
            end
        end
        % Plot Time to reach steady state at different GW flows
        if numel(modelMethodsPlot) == 1 % to allow for one or two model methods use same colours for gw flows
            q_colorOrder = [1 2 3 4 5];
        else
           q_colorOrder = [1 1 2 2 3 3 4 4 5 5]; % plot with grey model without pipes
        end
        
        plotName = sprintf('%s_x%.2fm_a[%.1f %.1f %.1f]_%s', ...
                plotNamePrefix, x_list(ix), ...
                params.aX, params.aY, params.aZ, cell2mat(modelMethodsPlot));
        plotTitleTz_q_x = plotName;
        plotTitleTz_q_x(plotTitleTz_q_x == '_') = '-'; %replace _ with - in plot title not to print as subscript
            
       % plotT_q_fun( z_list, Tz_q_x, x_list(ix), aXYZ, legendTexts_q, q_colorOrder, plotTitleTz_q_x, []) 
        show_legend = true;
        lineStyleSet = {'-', ':', '-', ':', '-', ':', '-', ':', '-', ':'};
        markerStyleSet = {'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none'};
        %  for saving ideally figure size is: setFigSize( 2.9, 2.1 );
        plotTz_q_x_fun( z_list, Tz_q_x, x_list(ix), [paramsStd.aX, paramsStd.aY, paramsStd.aZ], ...
                        legendTexts_q, q_colorOrder, modelNames_Tz_q_x, ...
                        plotTitleTz_q_x, show_legend, lineStyleSet, markerStyleSet)
        % Save figure
        if plotSave
            saveFig([plotExportPath plotName])
        end    
    end
end

%% Extract data for plot of T development with time in x direction
if plotT_t_axy
    if  plotT_model_axy
        plotNamePrefix = 'T_model_axy'; % plot name to save the plot with relevant name
    else
        plotNamePrefix = 'T_t_axy'; % plot name to save the plot with relevant name
    end

    % Times for (around 10 days, around 200 days) approximated  in
    % seconds from results table of COMSOL
    if plotT_model_axy  % plot for two models
       t_list_plotT_t_axy = timeTbh; % simulation time [seconds]
       model_choice = modelMethodsPlot;
    else
       t_list_plotT_t_axy = [timeTbh, timeForT_max]; % seconds
       model_choice =  {modelMethodPlot};
    end
    % List of aXYZ (aquifer dispersivities in 3D)
    ax_list = [0 2]; % longitudinal dispersivity [m]
    aXYZ_list = aXYZ_toTest( ax_list );

    for iq = 1:numel(q_list)
        q_choice = q_list(iq); % m/sec 
        T_t_axy = nan(numel(t_list_plotT_t_axy)*numel(ax_list)*numel(model_choice), Mt); % temperature series
        legendTexts = cell(1, numel(t_list_plotT_t_axy)*numel(ax_list)*numel(model_choice));
        i = 0; %index for T series
        for it = 1:numel(t_list_plotT_t_axy)
            for im = 1:numel(model_choice)
                for ia = 1:numel(ax_list)
                    % Parameters from comsol result
                    params = paramsStd;
                    params.q = q_choice;
                    params.aX = aXYZ_list(ia,1); params.aY = aXYZ_list(ia,2); params.aZ = aXYZ_list(ia,3);

                    i = i + 1; %next T series
                    % Get temperatures for points of interest and selected times for current q
                    [T_points_t, ~, ~, Xmesh] = T_eval_model(model_choice{im}, x_range, y, z, ...
                                       Mt, params, t_list_plotT_t_axy(it), comsolResultsTab, 'T', variant);
                    T_t_axy(i,:) = T_points_t(:, 1)'; %rows for each point transposed to columns
                    % write time units in legend either in days or in years, depending on requested time
                    if t_list_plotT_t_axy(it) >= daysToSeconds(30*365)
                        legendTexts{i} = sprintf('%s: t = %.0f years, a_{xyz} = (%.1f, %.1f, %.2f) m', ...
                            model_choice{im}, secondsToYears(t_list_plotT_t_axy(it)), aXYZ_list(ia,:));
                        
                    else
                        legendTexts{i} = sprintf('%s: t = %.0f days, a_{xyz} = (%.1f, %.1f, %.2f) m', ...
                            model_choice{im}, secondsToDays(t_list_plotT_t_axy(it)), aXYZ_list(ia,:));                      
                    end  
                end
            end
        end

        % Plot Comsol for plume development with time in x direction
        T_plumeLimit = 0.5; % K Horizontal line for temperature
        if plotT_model_axy % plot for two models
            colorOrder = [1 2 1 2]; % repeat color for gw flow for each line on plot
            %use full line without dispersion and dashed with dispersion, 'none' for circles marker
            lineStyle = {'-', '--', 'none', 'none'}; 
        else
            colorOrder = [1 1 2 2]; % colours for time, independent of gw flow
            lineStyle = {'-', '--', '-', '--'}; %use full line without dispersion and dashed with dispersion
        end
        plotT_t_axy_fun( Xmesh, T_t_axy, legendTexts, q_choice, T_plumeLimit, x_range, colorOrder, lineStyle );

        if plotSave
            plotName = sprintf('%s_z%dm_q%.3fmday_%s', plotNamePrefix, z, q_choice/secondsToDays(1), ...
                                cell2mat(model_choice));
            saveFig([plotExportPath plotName])
        end
    end
end

%% time to break through vs distance between wells for various flow in inj well and gw flows
if plottb_a_Q_q 
    plotNamePrefix = 'tb_a_Q_q'; 
    q_list_tb_a_Q_q = q_list(2:end); % [0.01, 0.02] / daysToSeconds(1);
    tb_a_Q_q = nan(numel(q_list_tb_a_Q_q)*numel(Q_list), numel(a_list)); % temperature series
    legendTexts = cell(1, numel(q_list_tb_a_Q_q) * numel(Q_list));
    i = 0; %index for T series
    for iq = 1:numel(q_list_tb_a_Q_q)
        for iQ = 1:numel(Q_list)
            i = i + 1; % next T series
            for ia = 1:numel(a_list)
                % Parameters from comsol result
                params = paramsStd;
                params.q =  q_list_tb_a_Q_q(iq);
                params.Q = Q_list(iQ); 
                params.a = a_list(ia);
                %params.alpha_deg = 0; % from abs to inj gw flow
                [~, ~, xAbstraction, yAbstraction] = getWellCoords(params.a);
                % Get time to breakthrough for abs well for current a, q and Q
                [~, ~, ~, ~, ~, ~, ~, ~, tb_a_Q_q(i,ia)] = ...
                    T_eval_model(modelMethodPlot, xAbstraction, yAbstraction, z, ...
                                   1, params, timeTbh, comsolResultsTab, 't_b', variant);
                % Legend
                legendTexts{i} = sprintf('%s: v_D = %.3f m/day, Q = %.3f l/s', ...
                     modelMethodPlot, params.q * daysToSeconds(1), params.Q * 1000 ); % darcy velocity in m/days from m/sec
            end        
        end
    end
    % Plot
    colorOrder = sort(repmat(2:numel(q_list_tb_a_Q_q)+1,  1, numel(Q_list))) ; % colours for time, independent of gw flow
    lineStylesAvailable = {'-', '--', ':', '-.', '-'};
    lineStyle = repmat(lineStylesAvailable(1:numel(Q_list)), 1, numel(q_list_tb_a_Q_q)); %

    plottb_a_Q_q_fun( a_list, tb_a_Q_q, legendTexts, colorOrder, lineStyle )

    if plotSave
        plotName = sprintf('%s_z%dm_%s_angle%.1fdeg', plotNamePrefix, z, ...
                            modelMethodPlot, params.alpha_deg);
        saveFig([plotExportPath plotName])
    end
end

%% Extract data for plot 
%% PROFILE VIEW how groundwater velocity influences isotherm development in x&z direction
if plotTxz_q
    plotNamePrefix = 'Txz_q'; % plot name to save the plot with relevant name
    t_list_plotTxz_q = [timeTbh, timeForT_max] ; % time in seconds

    for it = 1:numel(t_list_plotTxz_q)
        % prepare matrices for results
        Txz_q = nan(Mt, Mt, numel(q_list) * numel(modelMethodsPlot)); % temperature series
        legendTexts_q = cell(1, numel(q_list) * numel(modelMethodsPlot)); % allocate to legends empty cells 
        il = 0;

        for im = 1:numel(modelMethodsPlot)
            for i = 1 : numel(q_list)                
                params = paramsStd;   
                params.q = q_list(i);
                
                %% Calculate temperature series for current q
                il = il + 1;
                [T_points_t, points_XZ_grid, Txz_q(:, :, il), Xmesh, ~, Zmesh] = ...
                   T_eval_model(modelMethodsPlot(im), x_range, y, z_range, ...
                                Mt, params, t_list_plotTxz_q(it), comsolResultsTab, 'T', variant);
                legendTexts_q{il} = sprintf('v_D = %.3f m/day model: %s', q_list(i)*daysToSeconds(1),...
                                             modelMethodsPlot{im}); % legend for list of gw velocity [m/day]
            end
        end
            %% Plot PROFILE VIEW how groundwater velocity influences isotherm development in x&z direction
            T_isotherm = [2 0.5]; % temperature for isotherm on plot display (Kelvin)
            q_colorOrder = [1 2 3 4 1 2 3 4];
            if numel(q_list) == 2
               q_colorOrder = [2 3 2 3 ];
            end
            
            lineStyles = {'-', '-', '-', '-', '--', '--', '--', '--'};
            plotTxz_q_fun( Txz_q, legendTexts_q, H, t_list_plotTxz_q(it), T_isotherm, Xmesh, Zmesh, plotTitle, ...
                            q_colorOrder, lineStyles, params )

    end
        
        if plotSave        
            if secondsToYears(t_list_plotTxz_q(it)) >= 1        
                plotName = sprintf('%s_a[%.1f %.1f %.1f]_t%.0fy_%s', ...
                    plotNamePrefix, params.aX, params.aY, params.aZ, secondsToYears(t_list_plotTxz_q(it)), modelMethodPlot);
            else
                plotName = sprintf('%s_a[%.1f %.1f %.1f]_t%.0fdays_%s', ...
                    plotNamePrefix, params.aX, params.aY, params.aZ, secondsToDays(t_list_plotTxz_q(it)), modelMethodPlot);        
            end
            
            saveFig([plotExportPath plotName])
        end
 end




%% Extract data for plot 
%% Temperature at borehole wall after 30 years vs dispersivities at different GW flows
if plotTb_axy_q
    plotNamePrefix = 'Tb_axy_q'; % plot name to save the plot with relevant name
    point_BhWallMidDepth = [paramsStd.ro, 0, paramsStd.H/2];
    Mt_plotTb_axy_q = 1;
    t = timeTbh; % maximum simulation time input in [days], converted in seconds
    ax_list = [0 0.1 0.2 0.3 0.5 1 2 3 4]; % longitudinal dispersivity [m]
    %ax_list = [0 2]; % longitudinal dispersivity [m]
    aXYZ_list = aXYZ_toTest( ax_list );
    
    % temperature change at borehole wall, rows for gw flows, columns for dispersivities
    Tb_axy_q = nan(numel(q_list), numel(ax_list));
    legendTexts_q = cell(1, numel(q_list)); % text for legends on plot
    for iq = 1:numel(q_list)
        for ia = 1:numel(ax_list)
            % Extract temperature series for current q and dispersivity in x direction for range of dispersivities in x and y     
            %allocate T list row by row for different q
           
            % Parameters from comsol result           
            params = paramsStd;
            params.q = q_list(iq);
            params.aX = aXYZ_list(ia,1); 
            params.aY = aXYZ_list(ia,2); 
            params.aZ = aXYZ_list(ia,3);
            
            % Get comsol results rows
            % If result found
            % Get temperatures for points of interest and selected times for current q
            Tb_axy_q(iq,ia) = ...
               T_eval_model(modelMethodPlot, [point_BhWallMidDepth(1), point_BhWallMidDepth(1)], ...
                                            point_BhWallMidDepth(2), point_BhWallMidDepth(3), ...
                                            Mt_plotTb_axy_q, params, t, comsolResultsTab, 'T', variant);
        end

        % Legend texts
        legendTexts_q{iq} = sprintf('%s: v_D = %.3f m/day', ... 
                                    modelMethodPlot, q_list(iq) * daysToSeconds(1)); % darcy velocity in m/days from m/sec
    end

    %% Plot
    plotTb_axy_q_fun( ax_list, Tb_axy_q, legendTexts_q, plotTitle, t )
    
    if plotSave    
        plotName = sprintf('%s_x%.2fm_z%dm_t%dy_%s', ...
            plotNamePrefix, point_BhWallMidDepth(1), point_BhWallMidDepth(3), secondsToYears(t), modelMethodPlot);
        saveFig([plotExportPath plotName])
    end
end

%% Extract data for plot 
%% Plume extent longitudinal (X) after 30 years (t) vs groundwater flow (q) for different heat input (fe)
if plotXt_q_fe
    plotNamePrefix = 'Xt_q_fe'; % plot name to save the plot with relevant name
    
    % List for groundwater velocity (Darcy flux) [m s-1]
    q_range = [q_max/1000 q_max*2];
    q_list_big = logspace(log10(q_range(1)), log10(q_range(2)),20); %Specific flux (Darcy flux) [m s-1]
    q_list_big = [0, q_list_big]; % add zero groundwater velocity as first in list
    % List of heat inputs (W)
    fe_list = [1000 2500 5000]; % 10000] [W] % 10000 is too large for comsol comparison, it generates plume >400m which is larger than model mesh  % [W]
    
    T_plume = 0.5; % temperature for plume extent in x direction [K] 
    
    % X coordinates for temperature extraction
    x_range = [ro, min([500, xRange(2)]) ]; % minimum and maximum x coordinates [m]
    x_list = linspace(x_range(1), x_range(2), Mt); % [m]
    % Points at which temperature will be extracted from Comsol results
    points_alongXMidDepth = zeros(numel(x_list), 3);
    points_alongXMidDepth(:,1) = x_list'; %x
    points_alongXMidDepth(:,2) = 0; %y
    points_alongXMidDepth(:,3) = H/2; %z
        
    % plume extent longitudinal(X) after time (t), rows for heat input (fe), columns for gw flow
    Xt_q_fe = nan(numel(fe_list), numel(q_list_big));
    legendTexts_fe = cell(1, numel(fe_list)); % text for legends on plot
    
    for ife = 1:numel(fe_list)
        for iq = 1:numel(q_list_big)
            % Parameters from comsol result extraction
            params = paramsStd;
            params.q = q_list_big(iq); % Darcy gw velocity
            params.fe = fe_list(ife); % heat input
            % Get comsol results rows
            % If result found
            % Get temperatures for points of interest for current q and a (dispersivity in x y z )           
            % Get plume lengths for isotherm of T_plume temperature, current q (gw velocity) and current a (dispersivity)               
            keyModelInfoRow = keyModelInfo( timeTbh, timeForT_max, T_plume, x_Tlist, ...
                                            modelMethodPlot, params, comsolResultsTab, variant);
            Xt_q_fe(ife, iq) = keyModelInfoRow.xPlume;
        end
            
        % Fill in legend text for current heat input (W)
        legendTexts_fe{ife} = sprintf('%s: J = %.0f W', modelMethodPlot, fe_list(ife)); % heat input in W     
   end
       

    %% Plot
    plotXt_q_fe_fun( q_list_big, Xt_q_fe, T_plume, legendTexts_fe, plotTitle, timeTbh, [], [], [])

    if plotSave
        plotName = sprintf('%s_z%dm_a[%.1f %.1f %.1f]_t%dy_Tplume%.1fK_%s', ...
            plotNamePrefix, points_alongXMidDepth(1,3), params.aX, params.aY, params.aZ, secondsToYears(timeTbh), T_plume, modelMethodPlot);
        saveFig([plotExportPath plotName])
    end
end

%% Calibration plots
% T change vs time at different wells of field site for modelled and measured results
if plotT_t_well
    plotNamePrefix = 'T_t_well'; % plot name to save the plot with relevant name
    wellCoords = wellCoordinates(variant);
    % Delete injection well 6, injection well should not be plotted
    % wellCoordsPlot = wellCoords(~strcmp(wellCoords.wellName, 'aquifro6'), :);
    wellCoordsPlot = wellCoords;
    t_listComparison = timesForComparison(variant);  
    % Get best calibrated parameters    
    % paramsCalib = paramsFromCalib('Analytical: q,aX,alpha,cS,lS,n', variant);
    % paramsCalib = paramsFromCalib('Numerical: q,aX,alpha,cS,lS,n,H RunCount:384', variant);
    % paramsCalib = paramsFromCalib('Numerical: q,aX,alpha,cS,lS,n,H RunCount:447 diff T0,lS,n init as ansol', variant);
    % paramsCalib = paramsFromCalib('Numerical: q,aX,alpha,cS,lS,n,H RunCount:431 diff T0,lS,n init as prev numsim 447', variant); 
%      paramsCalib = paramsFromCalib('Numerical: q,aX,alpha,cS,lS,n,H RunCount:558 diff T0,lS,n WIDER ranges init 431', variant); 
     % paramsCalib = paramsFromCalib('Numerical2: RunCount: 261 adjusted', variant); 
   %  paramsCalib = paramsFromCalib('Numerical2: RunCount: 411', variant);
   %  paramsCalib = paramsFromCalib('Numerical2: RunCount: 482', variant);
    % paramsCalib = paramsFromCalib('Numerical: q,aX,alpha,cS,lS,n,H RunCount:0488 WIDER ranges cS,H init 431', variant);   
    % paramsCalib = paramsStd;   
    if strcmp(variant, 'FieldExpAll')
        paramsCalib = paramsFromCalib( 'Numerical2: RunCount: 482', variant); % finished calib params     
%     elseif strcmp(variant, 'FieldExp2')
%         paramsCalib = paramsFromCalib( 'Numerical2: RunCount: 423', variant); % latest best fit params test 2
    elseif strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated')
%        paramsCalib = paramsFromCalib( 'Numerical2: RunCount: 482_ls39_Ti29', variant); % finished calib params     
% INITIAL valias for analytical solution fitting        
        paramsCalib = paramsFromCalib( 'Numerical2: 424', variant); % finished calib params   best is Numerical2: 424  
% FINAL calibrated values after analytical solution fitting strcmp(calibVariant, 'Analytical: from Init424')
     %  paramsCalib = paramsFromCalib( 'Analytical: from Init424', variant); % finished calib params   best is Numerical2: 424  

%         paramsCalib = paramsFromCalib( 'Numerical2: RunCount: 539', variant); % latest best fit params test 2 with dispersivity       
    elseif strcmp(variant, 'FieldExp1') || strcmp(variant,'Becancour') 
        paramsCalib = paramsFromCalib( 'Numerical: q,aX,alpha,cS,lS,n,H RunCount:558 diff T0,lS,n WIDER ranges init 431', variant); % best fit params test 1       
    elseif strcmp(variant, 'FieldExp1m') % field test 1 and monitoring 1
        paramsCalib = paramsFromCalib( 'Numerical: 0458', variant); % best fit params test 1 with monitoring   Numerical: 0458     
    end
    
    Mt_T_t_well = 1; % calculation only in one point
    T_t_well = nan(size(wellCoordsPlot,1) * 2, length(t_listComparison));
    legendTexts_well_method = cell(size(T_t_well, 1), 1); % text for legends on plot
    i = 0;
    for iwell = 1 : size(wellCoordsPlot,1)
        point_MidDepth = [wellCoordsPlot.x(iwell), wellCoordsPlot.y(iwell), z];
        % For model
        i = i + 1;
        % Calculate temperature series for current well
        T_t_well(i,:) = ...
           T_eval_model(modelMethodPlot, [point_MidDepth(1), point_MidDepth(1)], ...
                                        point_MidDepth(2), point_MidDepth(3), ...
                                        Mt_T_t_well, paramsCalib, t_listComparison, comsolResultsTab, 'T', variant);
        legendTexts_well_method{i} = sprintf('%s: %s', ...
            wellCoordsPlot.wellName{iwell}, modelMethodPlot); 
        % For measurements
        i = i + 1;
        % Get measured temperature series for current well
        T_t_well(i,:) = ...
            T_wellMeasured(point_MidDepth(1), point_MidDepth(2), measuredWellDepth_range, t_listComparison, variant);       
        legendTexts_well_method{i} = sprintf('%s: %s', ...
            wellCoordsPlot.wellName{iwell}, 'Measured'); 
    end
    well_colorOrder = [1 2 3 4 5 6];
    % Duplicate colour number to be the same for each well
    well_colorOrder = sort(repmat(well_colorOrder, 1, 2));        
    plotName = sprintf('%s_%s', plotNamePrefix, modelMethodPlot);
    plotTitleT_t_well = plotName;
    plotTitleT_t_well(plotTitleT_t_well == '_') = '-'; %replace _ with - in plot title not to print as subscript    
    plotT_q_fun( t_listComparison, T_t_well, [], [], ...
        legendTexts_well_method, well_colorOrder, plotTitleT_t_well, {'-', ':'}, {'none','o'})   
    % Save figure
    if plotSave
        saveFig([plotExportPathCalib plotName])
    end    
end