clear
clear T_eval_model % clear persistent variables in function (used as cache)

%% Decide which plots to generate
plotT_q = true; %+ T change vs time at different GW flows
plotTxy_stream_tb = false; % Plot streamlines, hydraulic potential, isotherms and times to thermal breakthrough
    plotTxy_stream_tb_Txy = true; % plot isotherms
    plotTxy_stream_tb_tb = true; % plot time to breakthrough
    plotTxy_stream_tb_stream = true; % plot streamlines
plotTxy_q = false; %+ How groundwater velocity influences plume development in x&y direction (plan view)

plotT_q_pipes = false; %   ****  Temperature change versus time at different GW flows with INFO on T inside pipes
    plotT_q_pipes_fracture = false; % if true = plot model with standard fracture paramters, if false = plot Homo model (i.e. without fracture)
plotHistogramTpipeDiffTb = false; % plot histogram of average deltaT in pipes - delta T on VBHE wall for all runs. (with or without fracture)
plotTz_q_x = false; %+ Temperature at different x versus depth (z dimention) for different GW flows
plotT_t_axy = false; %* How dispersivity influences plume development with time in x direction
    plotT_model_axy = false; % same but for one time and for two models
plotTxz_q = false; %+ How groundwater velocity influences isotherm development in x&z direction (profile view)
plotTb_axy_q = false; %+ Temperature at borehole wall after 30 years vs dispersivities at different GW flows
plotXt_axy_q = false; %+ Plume extent longitudinal (X) after 30 years (t) vs dispersivities, longitudinal and transverse (axy) at different GW flows (q)
plotXt_q_fe = false; % Plume extent longitudinal (X) after 30 years (t) vs groundwater flow (q) for different heat input (fe)

% Save the plots
plotSave = false;
plotExportPath = 'C:\Users\Asus\OneDrive\INRS\COMSOL\figures\';

[comsolDataFile, comsolDataFileConvergence, modelMethods, modelMethodsConvergence, variant,...
    solution, methodMesh, ~, ~ ] = comsolDataFileInUse_Info( );
fprintf('methodMesh: %s\n', methodMesh);

% Set standard model parameters
[paramsStd, ~, deltaH] = standardParams('homo');
% Get list of different q (gw velocity)
% Take coordinates for plots
[ t_list, q_list, ~, x_range, y_range, z_range, Mt, y, z, ~, timeTbh, timeForT_max, ~, ~, x_Tlist ] = ...
    standardRangesToCompare( );
q_max = max(q_list); %Specific flux (Darcy flux) [m s-1] % maximm required Darcy velocity

modelMethodsPlot = [modelMethods(1), modelMethods(2)];
modelMethodPlot = modelMethods{1}; % Method of model calculation
% NOTE selected plot support comparison of two models some only one model method
% Model methods for which comparison plot should be generated
% First method is full line for analytical model, 
% Second method (numerical model) oo circles line
plotTitle = modelMethodPlot; % plotTitle

%% Load previously saved workspace variables with comsol data in comsolResultsTab
load(comsolDataFile)

% If needed ONLY: Add missing columns to loaded result   
% comsolResultsTab = addToTabAbsentParams( comsolResultsTab );

%% Extract data for plot T change at different GW flows
% Point where temperature will be analyzed
if plotT_q
    plotNamePrefix = 'T_q'; % plot name to save the plot with relevant name
    x_list = x_Tlist; % [m] X coordinates, distance from heat source, to plot
    Mt_T_q = 1; % calculation only in one point
    % One plot for each point location along x axis from list
    for ix = 1:numel(x_list)
        point_MidDepth = [x_list(ix), y, z];
        T_q = nan(length(q_list) * numel(modelMethodsPlot), length(t_list));
        legendTexts_q = cell(1, length(q_list) * numel(modelMethodsPlot)); % text for legends on plot
        i = 0; 
        for iq = 1:numel(q_list)
            % Parameters from comsol result
            params = paramsStd;          
            params.q = q_list(iq);
            % For each model method
            for im = 1:numel(modelMethodsPlot)
                i = i + 1;
                % Calculate temperature series for current q
                T_q(i,:) = ...
                   T_eval_model(modelMethodsPlot{im}, [point_MidDepth(1), point_MidDepth(1)], ...
                                                point_MidDepth(2), point_MidDepth(3), ...
                                                Mt_T_q, params, t_list, comsolResultsTab);

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
    t_list_plotTxy_q = [daysToSeconds(2*365), daysToSeconds(5*365)]; % time in seconds
    % preassign 4 D matrices for T to save the results
    Txy_stream_tb = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_list));
    % same for tb ( which is based on I phi)
    t_b_mesh = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_list));
    % same for phi (hydraulic potential)
    phi_xy_mesh = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_list));
    % same for groundwater velocities, parts of the vector [ v_x, v_y ],
    % both v_x and v_y are calculated in all mesh points.
    v_x = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_list));
    v_y = nan(Mt, Mt, numel(t_list_plotTxy_q), numel(q_list));
    for it = 1:numel(t_list_plotTxy_q)
        % prepare matrices for results
        for iq = 1:numel(q_list)
            params = paramsStd;
            params.q = q_list(iq);
            
            %% calc Temperature to plot isotherms or plot time to breakthrough
            if plotTxy_stream_tb_Txy || plotTxy_stream_tb_tb  
                % Calculate temperature series for current q
                [~, ~, Txy_stream_tb(:,:,it, iq ), Xmesh, Ymesh, ~, ~, ~, t_b_mesh(:,:,it, iq ) ] = ...          
                   T_eval_model(modelMethodPlot, x_range, y_range, z, ...
                                Mt, params, t_list_plotTxy_q(it), comsolResultsTab);
            else
                % Space discretization for both wells accounting for log and lin spacing areas in model domain
                [ ~, Xmesh, Ymesh ] = ...
                       spaceDiscretisation(x_range, y_range, z, Mt, ...
                                           params.ro, params.a, comsolResultsTab);   
            end            
            % if NOT to plot tb
            if ~plotTxy_stream_tb_tb 
                t_b_mesh = [];
            end
            % if NOT to plot Txy
            if ~plotTxy_stream_tb_Txy 
                Txy_stream_tb = [];
            end
            
            %% calc streamlines and hydraulic potential for plot
            if plotTxy_stream_tb_stream 
                % Hydraulic conductivity
                K = params.q / deltaH;               
                % calculate hydraulic potential phi
                phi_xy_mesh(:,:,it, iq ) = schulz_phi_psi( Xmesh, Ymesh, params.q, K, params.alpha_deg, ...
                                              params.M, params.Q, params.a );
                % calculate groundwater velocities in x and y direction (in 2D to plot streamlines
                [ v_x(:,:,it, iq ), v_y(:,:,it, iq ) ] = schulz_velocity( Xmesh, Ymesh, params.q, params.alpha_deg, ...
                                                params.M, params.Q, params.a );                                          
            else
                phi_xy_mesh = [];
                v_x = [];
                v_y = [];
            end
        end
    end

    %% Plot PLAN VIEW streamlines, hydraulic potential,  isotherms and times to thermal breakthrough
    T_isotherm = [-15, - 10, -5, -1]; % temperature for limit of plume on plot display (Kelvin)
    for iq = 1:numel(q_list)
        for it = 1 : numel(t_list_plotTxy_q)
            % prepare legend
            legendTexts_q{1} = sprintf('v_D = %.3f m/day', q_list(iq) * daysToSeconds(1)); % legend for list of gw velocity [m/day]
            % Create the plot streamlines, hydraulic potential,  isotherms and times to thermal breakthrough
            plotTxy_stream_tb_fun( Txy_stream_tb(:,:,it, iq), legendTexts_q, t_list_plotTxy_q(it), T_isotherm, ...
                            phi_xy_mesh(:,:,it, iq), v_x(:,:,it, iq), v_y(:,:,it, iq), ... 
                            t_b_mesh(:,:,it, iq), ...
                            Xmesh, Ymesh, plotTitle, iq) % last iq sets the colour of isotherms
                                                         % to correspond to the colour of groundwater velocity
            if plotSave        
                if secondsToYears(t_list_plotTxy_q(it)) >= 1
                    plotName = sprintf('%s_z%dm_a[%.1f %.1f %.1f]_t%.0fy_%s', ...
                        plotNamePrefix, z, params.aX, params.aY, params.aZ, ...
                        secondsToYears(t_list_plotTxy_q(it)), modelMethodPlot);
                else
                    plotName = sprintf('%s_z%dm_a[%.1f %.1f %.1f]_t%.0fdays_%s', ...
                        plotNamePrefix, z, params.aX, params.aY, params.aZ, ...
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
    % t_list_plotTxy_q = [daysToSeconds(5*365)]; % time in seconds
    t_list_plotTxy_q = t_list(26); % [seconds] about 5 years
    for it = 1:numel(t_list_plotTxy_q)
        % prepare matrices for results
        Txy_q = nan(Mt, Mt, numel(q_list)); % temperature series
        % pre-allocate empty strings to legend text 
        % in case not all q are filled it will be working.
        legendTexts_q = repmat({''},1,numel(q_list)); % OLD version: legendTexts_q = cell(1, numel(q_list));        
        for i = 1:numel(q_list)
            params = paramsStd;
            params.q = q_list(i);
            % Calculate temperature series for current q
            [~, ~, Txy_q(:, :, i), Xmesh, Ymesh, ~ ] = ...          
               T_eval_model(modelMethodPlot, x_range, y_range, z, ...
                            Mt, params, t_list_plotTxy_q(it), comsolResultsTab);

            legendTexts_q{i} = sprintf('v_D = %.3f m/day', q_list(i)*daysToSeconds(1)); % legend for list of gw velocity [m/day]
        end

        %% Plot MFLS with physical units PLAN VIEW
        T_isotherm = [-5, -1]; % temperature for limit of plume on plot display (Kelvin)
        plotTxy_q_fun( Txy_q, legendTexts_q, t_list_plotTxy_q(it), T_isotherm, Xmesh, Ymesh, plotTitle )

        if plotSave        
            if secondsToYears(t_list_plotTxy_q(it)) >= 1
                plotName = sprintf('%s_z%dm_a[%.1f %.1f %.1f]_t%.0fy_%s', ...
                    plotNamePrefix, z, params.aX, params.aY, params.aZ, ...
                    secondsToYears(t_list_plotTxy_q(it)), modelMethodPlot);
            else
                plotName = sprintf('%s_z%dm_a[%.1f %.1f %.1f]_t%.0fdays_%s', ...
                    plotNamePrefix, z, params.aX, params.aY, params.aZ, ...
                    secondsToDays(t_list_plotTxy_q(it)), modelMethodPlot);
            end
            saveFig([plotExportPath plotName])
        end        
    end
end

%% Extract data for plot T change at different GW flows with INFO about temperature in PIPES
% Point where temperature will be analyzed
if plotT_q_pipes
    plotNamePrefix = 'T_q_pipes'; % plot name to save the plot with relevant name
    [ ~, q_list, ~, ~, ~, ~, ~, ~, ~, ~, timeTbh, ~, ~, ~, x_Tlist ] = standardRangesToCompare( H );
    
%     paramsStd.aX = 2.0;
%     paramsStd.aY = 0.2;
%     paramsStd.aZ = 0.2;
%     warning('axyz are changed from 0 to 2')
    
    % if case with fracture that infleunces Tbh is plotted
    if plotT_q_pipes_fracture
        modelMethodsPlot_T_q_pipes = {'nMFLSfr', 'nMFLSfrp'};
        params = paramsStd_fr;
    else
        modelMethodsPlot_T_q_pipes = {'nMFLS', 'nMFLSp'};
        params = paramsStd;
    end
 
    
    x_bh = 0.05;
    x_pipe = 0.03; % (0.03 menas x axis location of pipes from center of grout [0, 0])
    y = 0; % [m] Y coordinate
    z_bh = H/2; % z coordinates [m]
    z_pipe = 0; % z coordinates for T pipe in and out [m]
    Mt = 1; % calculation only in one point

    point_bh = [x_bh, y, z_bh];
    point_pipeIN = [-x_pipe, y, z_pipe]; % location  of T of water going inside U tube pipe
    point_pipeOUT = [x_pipe, y, z_pipe]; % location  of T of water going outside U tube pipe
    t_list = comsolResultsTab.timeList{1}; % all calculated times for plot
    T_q = []; %nan(length(q_list) * 4, length(t_list));
    result_pipe = NaN(2, numel(t_list));
    legendTexts_q = []; %cell(size(T_q,1), 1); % text for legends on plot
    i = 0; 
    lineStyles = {}; 
    markerStyles = {};
    
    % for each gw flow
    for iq = 1:numel(q_list)
        % Parameters from comsol result
        params.q = q_list(iq);
        % to delete below
       % params.aX = 2; 
       % params.aY = 0.2;
       %  params.aZ = 0.2;
      %  warning(' delete lines with ax ay az they must be zero values!!! ')

        % Model without pipe Tbh, Calculate temperature series for current q
        i = i+1;
        T_q(i,:) = T_eval_model(modelMethodsPlot_T_q_pipes{1}, [point_bh(1), point_bh(1)], point_bh(2), point_bh(3), ...
                                Mt, params, t_list, comsolResultsTab);
        legendTexts_q{i} = sprintf('%s: T_b, v_D = %.3f m/day', ...
            modelMethodsPlot_T_q_pipes{1}, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
        lineStyles = [lineStyles {'-'}];
        markerStyles = [markerStyles {'none'}];
        
        % Model with pipe Tbh, Calculate temperature series for current q
        i = i+1;
        T_q(i,:) = T_eval_model(modelMethodsPlot_T_q_pipes{2}, [point_bh(1), point_bh(1)], point_bh(2), point_bh(3), ...
                                Mt, params, t_list, comsolResultsTab);
        legendTexts_q{i} = sprintf('%s: T_b, v_D = %.3f m/day', ...
            modelMethodsPlot_T_q_pipes{2}, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
        lineStyles = [lineStyles {'none'}];
        markerStyles = [markerStyles {'o'}];
        
        % Model with pipe TpipeIN, Calculate temperature series for current q
        result_pipe(1,:) = T_eval_model(modelMethodsPlot_T_q_pipes{2}, [point_pipeIN(1), point_pipeIN(1)], point_pipeIN(2), point_pipeIN(3), ...
                                Mt, params, t_list, comsolResultsTab);

        % Model with pipe TpipeOUT, Calculate temperature series for current q
        result_pipe(2,:) = T_eval_model(modelMethodsPlot_T_q_pipes{2}, [point_pipeOUT(1), point_pipeOUT(1)], point_pipeOUT(2), point_pipeOUT(3), ...
                                Mt, params, t_list, comsolResultsTab);
%         legendTexts_q{i} = sprintf('%s: T_{pipeOUT}, v_D = %.3f m/day', ...
%             modelMethodsPlot_T_q_pipes{2}, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
%         lineStyles = [lineStyles {'-.'}];

        PipeInOUtAverage = mean(result_pipe, 1);
        i = i + 1;
        T_q(i,:) = PipeInOUtAverage;
        legendTexts_q{i} = sprintf('%s: T_{pipeAverage}, v_D = %.3f m/day', ...
        modelMethodsPlot_T_q_pipes{2}, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
        lineStyles = [lineStyles {'--'}];
        markerStyles = [markerStyles {'none'}];

    end
    
    % Plot T vs time at different GW flows
    % numer of lines for each groundwater flow
    linesPerGw = size(T_q,1) / length(q_list);
    q_colorOrder = [repmat(1,1,linesPerGw) repmat(2,1,linesPerGw) repmat(3,1,linesPerGw) repmat(4,1,linesPerGw) ];

    plotName = sprintf('%s_a[%.1f %.1f %.2f]_%s', ...
            plotNamePrefix, ...
            params.aX, params.aY, params.aZ, cell2mat(modelMethodsPlot_T_q_pipes));
    plotTitleT_q = plotName;
    plotTitleT_q(plotTitleT_q == '_') = '-'; %replace _ with - in plot title not to print as subscript

    plotT_q_fun( t_list, T_q, point_bh(1), aXYZ, legendTexts_q, q_colorOrder, plotTitleT_q, lineStyles, markerStyles)   
    % Save figure
    if plotSave
        saveFig([plotExportPath plotName])
    end    
end

%% Extract data for plot: Temperature at different x versus depth (z dimention) for different GW flows
% Point where temperature will be analyzed
if plotTz_q_x
    plotNamePrefix = 'Tz_q_x'; % plot name to save the plot with relevant name
    % x_list means [m] X coordinates, distance along x axis, to plot (0.03 menas x axis location of pipes from center of grout [0, 0])
   % x_list = [0.03, ro];
   warning('comment line below')
    x_list = ro; % 0.03; %  [0.03, ro, 1, 10];
    y = 0; % [m] Y coordinate
    z_range = [0, H-1]; % z coordinates range [m]
    Mt = 200; % calculation only in one point
    time = timeTbh;
    % One plot for each point location along x axis from list
    for ix = 1:numel(x_list)
        % * 3 (see below) because the T is plotted for 2 x axis locations (upstream and downstream) and their average
        Tz_q_x = nan(length(q_list) * numel(modelMethodsPlot) * 3, Mt); 
        modelNames_Tz_q_x = cell(size(Tz_q_x,1), 1); % set size for matrix with model names
        legendTexts_q = cell(size(Tz_q_x,1), 1); % text for legends on plot
        i = 0; 
        for iq = 1:numel(q_list)
            % Parameters from comsol result
            params = paramsStd;
            params.q = q_list(iq);          
            % For each model method
            for im = 1:numel(modelMethodsPlot)
                % Calculate temperature series for negative x (left side of borehole)
                i = i+1;
                [Tz_q_x(i,:),~,~,~,~,z_list]  = T_eval_model(modelMethodsPlot{im}, [-x_list(ix) -x_list(ix)], y, z_range, ...
                                                Mt, params, time, comsolResultsTab);
                legendTexts_q{i} = sprintf('%s: v_D = %.3f m/day, left', ...
                    modelMethodsPlot{im}, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
                modelNames_Tz_q_x(i) = modelMethodsPlot(im);
                % Calculate temperature series for positive x (right side of borehole)
                i = i+1;
                [Tz_q_x(i,:),~,~,~,~,z_list] = T_eval_model(modelMethodsPlot{im}, [x_list(ix) x_list(ix)], y, z_range, ...
                                                Mt, params, time, comsolResultsTab);
                legendTexts_q{i} = sprintf('%s: v_D = %.3f m/day, right', ...
                    modelMethodsPlot{im}, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
                modelNames_Tz_q_x(i) = modelMethodsPlot(im);
                % Calculate temperature series for average x (sum for T for both sides of borehole / 2)
                i = i+1;
                Tz_q_x(i,:) = (Tz_q_x(i-1,:) + Tz_q_x(i-2,:)) / 2;
                legendTexts_q{i} = sprintf('%s: v_D = %.3f m/day, mean', ...
                    modelMethodsPlot{im}, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
                modelNames_Tz_q_x(i) = modelMethodsPlot(im);
            end
        end
        % Plot Time to reach steady state at different GW flows
        if numel(modelMethodsPlot) == 1 % to allow for one or two model methods use same colours for gw flows
            q_colorOrder = [1 1 1 2 2 2 3 3 3 4 4 4];
        else
           q_colorOrder = [9 9 9  1 1 1    9 9 9    2 2 2  9 9 9    3 3 3  9 9 9   4 4 4 ]; % plot with grey model without pipes
        end
        
        plotName = sprintf('%s_x%.2fm_a[%.1f %.1f %.1f]_%s', ...
                plotNamePrefix, x_list(ix), ...
                params.aX, params.aY, params.aZ, cell2mat(modelMethodsPlot));
        plotTitleTz_q_x = plotName;
        plotTitleTz_q_x(plotTitleTz_q_x == '_') = '-'; %replace _ with - in plot title not to print as subscript
            
       % plotT_q_fun( z_list, Tz_q_x, x_list(ix), aXYZ, legendTexts_q, q_colorOrder, plotTitleTz_q_x, []) 
        show_legend = true;
        lineStyleSet = {'none', 'none','-', ':', '--', '-', 'none', 'none','-', ':', '--', '-',...
                        'none', 'none','-', ':', '--', '-', 'none', 'none','-', ':', '--', '-'};
        markerStyleSet = {'o','x', 'none', 'none','none', 'none', 'o','x', 'none', 'none','none', 'none',...
                          'o','x', 'none', 'none','none', 'none', 'o','x', 'none', 'none','none', 'none'};
        %  for saving ideally figure size is: setFigSize( 2.9, 2.1 );
        plotTz_q_x_fun( z_list, Tz_q_x, x_list(ix), aXYZ, legendTexts_q, q_colorOrder, modelNames_Tz_q_x, plotTitleTz_q_x, show_legend, lineStyleSet, markerStyleSet)
        % Save figure
        if plotSave
            saveFig([plotExportPath plotName])
        end    
    end
end

%% Extract data for plot of plume development with time in x direction
% plotT_t_axy: xzy = [-5:ro:30, 0, H/2], t = [10 200 days], axyz=[0 0 0], [2 0.2 0.2], q = [0.05] m/day
if plotT_t_axy
    if plotT_model_axy
        plotNamePrefix = 'T_model_axy'; % plot name to save the plot with relevant name
    else
        plotNamePrefix = 'T_t_axy'; % plot name to save the plot with relevant name
    end

    % X coordinates for temperature extraction
    Mt = 100; %number of discretization steps
   %%% x_range = [-5, min([30, xRange(2)]) ]; % minimum and maximum x coordinates [m]
    x_range = [-10, 70];
    % Points where temperature will be analyzed
     y = 0;
     z = H/2;

    % Times for (around 10 days, around 200 days) approximated  in
    % seconds from results table of COMSOL
    if plotT_model_axy  % plot for two models
         t_list = daysToSeconds(30*365); % simulation time [seconds]
       % t_list = [16823808]; % seconds
       model_choice = modelMethodsPlot;
    else
       t_list = [946080, 16823808]; % seconds
       model_choice =  {modelMethodPlot};
    end
    % List of aXYZ (aquifer dispersivities in 3D)
    ax_list = [0 2]; % longitudinal dispersivity [m]
    aXYZ_list = aXYZ_toTest( ax_list );

    for iq = 1:numel(q_list)
        q_choice = q_list(iq); % m/sec 
        T_t_axy = nan(numel(t_list)*numel(ax_list)*numel(model_choice), Mt); % temperature series
        legendTexts = cell(1, numel(t_list)*numel(ax_list)*numel(model_choice));
        i = 0; %index for T series
        for it = 1:numel(t_list)
            for im = 1:numel(model_choice)
                for ia = 1:numel(ax_list)
                    % Parameters from comsol result
                    params = paramsStd;
                    params.q = q_choice;
                    params.aX = aXYZ_list(ia,1); params.aY = aXYZ_list(ia,2); params.aZ = aXYZ_list(ia,3);

                    i = i + 1; %next T series
                    % Get comsol results rows
                        % Get temperatures for points of interest and selected times for current q
                        % Temparatures are extrated for all requested times, loop through the times
                    [T_points_t, ~, ~, Xmesh] = T_eval_model(model_choice{im}, x_range, y, z, ...
                                       Mt, params, t_list(it), comsolResultsTab);
                    T_t_axy(i,:) = T_points_t(:, 1)'; %rows for each point transposed to columns
                    % write time units in legend either in days or in years, depending on requested time
                    if t_list(it) >= daysToSeconds(30*365)
                        legendTexts{i} = sprintf('%s: t = %.0f years, a_{xyz} = (%.1f, %.1f, %.2f) m', ...
                            model_choice{im}, secondsToYears(t_list(it)), aXYZ_list(ia,:));
                        
                    else
                        legendTexts{i} = sprintf('%s: t = %.0f days, a_{xyz} = (%.1f, %.1f, %.2f) m', ...
                            model_choice{im}, secondsToDays(t_list(it)), aXYZ_list(ia,:));                      
                    end

  
                end
            end
       end


        % Plot Comsol for plume development with time in x direction
        T_plumeLimit = 0.5;
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
            plotName = sprintf('%s_z%dm_q%.3fmday_%s', plotNamePrefix, z, q_choice/secondsToDays(1),cell2mat(model_choice));
            saveFig([plotExportPath plotName])
        end
    end
end

%% Extract data for plot 
%% PROFILE VIEW how groundwater velocity influences isotherm development in x&z direction
if plotTxz_q
    plotNamePrefix = 'Txz_q'; % plot name to save the plot with relevant name
    % t_list = [ daysToSeconds(3*365), daysToSeconds(30*365), daysToSeconds(300*365)]; % time in seconds
    t_list = [ daysToSeconds(30*365)]; % time in seconds
    warning('t list changed to 30 years only')
   % warning('qlist limited to two values')
   % q_list = q_list(2:3);

     for it = 1:numel(t_list)
            Mt = 120; %number of discretization steps for space
            % Minimum and maximum x coordinates [m],
            % Range is reduced by 1 meter because function pointLocation in function comsolInterpolatePointValues 
            % cannot find element for points on space boundaries.
            x_range = [-50 150]; % minimum and maximum x coordinates [m]
            y = 0;
            z_range = [0, H*1.6]; % minimum and maximum z coordinates [m], Max coord increased to 110%
                     
            % prepare matrices for results
            Txz_q = nan(Mt, Mt, numel(q_list)*numel(modelMethodsPlot)); % temperature series
            legendTexts_q = cell(1, numel(q_list)*numel(modelMethodsPlot)); % allocate to legends empty cells 
            il = 0;

        for im = 1:numel(modelMethodsPlot)
            for i = 1:numel(q_list)
                %warning ('changed params to fr dip diff!!');
                %[ ~, ~, ~, ~, ~, ~, ~, ~, ~, paramsFR] = standardParams( 'frSinglePipe' );
                %params = paramsFR;
                
                
               %% warning ('paramsStd is changed for paramsStdfr !!!')
               % [ ~,~,~,~,~,~,~,~,~, paramsStd_fr] = standardParams(variant);
               % params = paramsStd_fr; % paramsStd;                   
                params = paramsStd;   
                params.q = q_list(i);
                
              %  warning ('fracture params changed for horiz fr!!!')
              %  params.frZ = 50; 
              %  params.frH = 50; 
              %  params.frDip = 0;
              %  params.frDist = -25;
                
                %% Calculate temperature series for current q
                 il = il+1;
                [T_points_t, points_XZ_grid, Txz_q(:, :, il), Xmesh, ~, Zmesh] = ...
                   T_eval_model(modelMethodsPlot(im), x_range, y, z_range, ...
                                Mt, params, t_list(it), comsolResultsTab);
                legendTexts_q{il} = sprintf('v_D = %.3f m/day model: %s', q_list(i)*daysToSeconds(1), modelMethodsPlot{im}); % legend for list of gw velocity [m/day]
            end
        end
            %% Plot PROFILE VIEW how groundwater velocity influences isotherm development in x&z direction
            T_isotherm = [2 0.5]; % temperature for isotherm on plot display (Kelvin)
            q_colorOrder = [1 2 3 4 1 2 3 4];
            if numel(q_list) == 2
               q_colorOrder = [2 3 2 3 ];
            end
            
            lineStyles = {'-', '-', '-', '-', '--', '--', '--', '--'};
            plotTxz_q_fun( Txz_q, legendTexts_q, H, t_list(it), T_isotherm, Xmesh, Zmesh, plotTitle, q_colorOrder, lineStyles, params )

    end
        
        if plotSave        
            if secondsToYears(t_list(it)) >= 1        
                plotName = sprintf('%s_a[%.1f %.1f %.1f]_t%.0fy_%s', ...
                    plotNamePrefix, params.aX, params.aY, params.aZ, secondsToYears(t_list(it)), modelMethodPlot);
            else
                plotName = sprintf('%s_a[%.1f %.1f %.1f]_t%.0fdays_%s', ...
                    plotNamePrefix, params.aX, params.aY, params.aZ, secondsToDays(t_list(it)), modelMethodPlot);        
            end
            
            saveFig([plotExportPath plotName])
        end
 end




%% Extract data for plot 
%% Temperature at borehole wall after 30 years vs dispersivities at different GW flows
if plotTb_axy_q
    plotNamePrefix = 'Tb_axy_q'; % plot name to save the plot with relevant name
    point_BhWallMidDepth = [ro, 0, H/2];
    Mt = 1;
    t = daysToSeconds(365*30); % maximum simulation time input in [days], converted in seconds
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
            params.aX = aXYZ_list(ia,1); params.aY = aXYZ_list(ia,2); params.aZ = aXYZ_list(ia,3);
            
            % Get comsol results rows
            % If result found
            % Get temperatures for points of interest and selected times for current q
            Tb_axy_q(iq,ia) = ...
               T_eval_model(modelMethodPlot, [point_BhWallMidDepth(1), point_BhWallMidDepth(1)], ...
                                            point_BhWallMidDepth(2), point_BhWallMidDepth(3), ...
                                            Mt, params, t, comsolResultsTab);
        end

        % Legend texts
        legendTexts_q{iq} = sprintf('%s: v_D = %.3f m/day', ... 
                                    modelMethodPlot, q_list(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
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
%% Plume extent longitudinal (X) after 30 years (t) vs dispersivities, longitudinal and transverse (axy) 
%% at different GW flows (q)
if plotXt_axy_q
    plotNamePrefix = 'Xt_axy_q'; % plot name to save the plot with relevant name
    
    % List for groundwater velocity (Darcy flux) [m s-1]        
    q_list5 = logspace(log10(q_list(2)), log10(q_max),5); % List of 5 numbers (not 3 numbers as usual)
    q_list5 = [0, q_list5]; % add zero groundwater velocity as first in list
    
    % List for thermal dispersivities in the aquifer [m]
    ax_list = [0 0.1 0.2 0.3 0.5 1 2 3 4]; % longitudinal dispersivity [m]
    aXYZ_list = aXYZ_toTest( ax_list );   
    
    T_plume = 0.5; % temperature for plume extent in x direction [K] 
    
    % X coordinates for temperature extraction
    Mt = 300; %number of discretization steps
    x_range = [ro, min([500, xRange(2)]) ]; % minimum and maximum x coordinates [m]
    x_list = linspace(x_range(1), x_range(2), Mt); % [m]
    % Points at which temperature will be extracted from Comsol results
    points_alongXMidDepth = zeros(numel(x_list), 3);
    points_alongXMidDepth(:,1) = x_list'; %x
    points_alongXMidDepth(:,2) = 0; %y
    points_alongXMidDepth(:,3) = H/2; %z
        
    % Plume extent longitudinal (X direction) after time (t), rows for gw flows, columns for dispersivities
    Xt_axy_q = nan(numel(q_list5), numel(ax_list));
    legendTexts_q = cell(1, numel(q_list5)); % text for legends on plot
    for iq = 1:numel(q_list5)
        for ia = 1:numel(ax_list)                       
            % Parameters from comsol result extraction
            params = paramsStd;
            params.q = q_list5(iq); % Darcy gw velocity
            params.aX = aXYZ_list(ia,1); params.aY = aXYZ_list(ia,2); params.aZ = aXYZ_list(ia,3);
            
            % Get comsol results rows
            % If result found
            % Get temperatures for points of interest for current q and a (dispersivity in x y z )           
            % Get plume lengths for isotherm of T_plume temperature, current q (gw velocity) and current a (dispersivity)    
            keyModelInfoRow = keyModelInfo( timeTbh, timeForT_max, T_plume, x_Tlist, ...
                                            modelMethodPlot, params, comsolResultsTab);
            Xt_axy_q(iq, ia) = keyModelInfoRow.xPlume;
                               
        end
       % Fill in legend text for current groundwater velocity
        legendTexts_q{iq} = sprintf('%s: v_D = %.3f m/day', modelMethodPlot, q_list5(iq)*daysToSeconds(1)); % darcy velocity in m/days from m/sec
    end

    %% Plot
    plotXt_axy_q_fun( ax_list, Xt_axy_q, T_plume, legendTexts_q, plotTitle, timeTbh)

    if plotSave    
        plotName = sprintf('%s_z%0.1dm_t%dy_Tplume%.1fK_%s', ...
            plotNamePrefix, points_alongXMidDepth(1,3), secondsToYears(timeTbh), T_plume, modelMethodPlot);
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
    Mt = 300; %number of discretization steps
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
                                            modelMethodPlot, params, comsolResultsTab);
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

%% Histogram of T differences between T in pipe and T on VBHE wall
if plotHistogramTpipeDiffTb
    plotNamePrefix = 'HistogramTpipeDiffTb'; % plot name to save the plot with relevant name
    modelMethodPlot_HistogramTpipeDiffTb = 'nMFLSfrp';
    % prepare list of all parameter names which need to be extracted from results table
    paramsStd_fr_Tab = struct2table(paramsStd_fr);
    param_names = paramsStd_fr_Tab.Properties.VariableNames';
    % extract from results table only columns with parameters
    param_combinations = comsolResultsTab(:, param_names);
    % convert cell values in table to double
    param_combinations_array = table2array(param_combinations); % make table into array of cells
    param_combinations_array = cell2mat(param_combinations_array); % convert cells to double
    param_combinations = array2table(param_combinations_array, 'VariableNames',param_names); % make array back to table (but without cells)
    % keep unique parameter combinations only
    param_combinations = unique(param_combinations);
    param_combinations = param_combinations(~(param_combinations.frDip == 0 & param_combinations.frZ == 50), :);
    param_combinations = param_combinations((param_combinations.rSource == 0 ),:);
    
    % additional params for key info
    T_plume = 0.5; % temperature for plume extent in x direction [K] 
    %TpipeDiffTb = nan(size(param_combinations,1),1);
    %T_pipeIN_all = nan(size(param_combinations,1),1);
    %T_pipeOUT_all = nan(size(param_combinations,1),1);
    T_bh_all = nan(size(param_combinations,1),1);
    T_pipe_average = nan(size(param_combinations,1),1);
    TpipeAverageDiffTb = nan(size(param_combinations,1),1);   
    
    for i = 1: size(param_combinations,1)
        % get parameter combination
        params = paramsFromSample_COMSOL(param_combinations(i,:), paramsStd_fr);
        % Get key info for params
        keyModelInfoRow = keyModelInfo( timeTbh, timeForT_max, T_plume, x_Tlist, ...
                                        modelMethodPlot_HistogramTpipeDiffTb, params, comsolResultsTab);
        T_pipe_average(i) = mean([keyModelInfoRow.T_pipeIN, keyModelInfoRow.T_pipeOUT]);                            
        %TpipeDiffTb(i) = keyModelInfoRow.T_pipeIN - keyModelInfoRow.T_bh; 
        %T_pipeIN_all(i) = keyModelInfoRow.T_pipeIN;
        T_bh_all(i) = keyModelInfoRow.T_bh;
        
        TpipeAverageDiffTb(i) = T_pipe_average(i) - T_bh_all(i); % difference between average T in pipe and T at VBHE wall
    end
    % plot as histogram
    bins = 30;
    plotHistogramMC_fun( TpipeAverageDiffTb, [], [0 45], 'Difference between T pipe average and Tbh (K)', bins ) 
    
%     % just to compare groundwater velocities influence on Temperature difference between TpipeIN and Tbh
%     q1 = abs(param_combinations.q - q_list(2)) < 1e-10;
%     q2 = abs(param_combinations.q - q_list(3)) < 1e-10;
%     TpipeDiffTb_q1 = TpipeDiffTb(q1); 
%     TpipeDiffTb_q2 = TpipeDiffTb(q2); 
%     plotHistogramMC_fun( TpipeDiffTb_q1, [], [0 25], 'q1 Temperature difference between TpipeIN and Tbh (K)', bins ) 
%     plotHistogramMC_fun( TpipeDiffTb_q2, [], [0 25], 'q2 Temperature difference between TpipeIN and Tbh (K)', bins ) 
  
    if plotSave
        plotName = sprintf('%s_t%dy_%s', ...
            plotNamePrefix, secondsToYears(timeTbh), modelMethodPlot);
        saveFig([plotExportPath plotName])
    end
end


%% Additional ideas
% Save only nodes and temperatures for y >= 0 as the cylinder is symetric.
% The T_nodeTime matrix half then save as sparce after rounding to 6
% decimal places. Make function to replace columns with half data in table
% with full ones for processing and add delaunayTriang only at this point.
% Make a function to find/return row for q and aXYZ and return it (can
% reference to table row be used?).
% Not implemented because sparce matrix could save only about 10% of space
% becasue of dense number of nodes near borehole and plans to build
% fractures in homogenous medium --> no symmetry along y axis in future.
