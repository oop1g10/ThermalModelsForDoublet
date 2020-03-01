function plotTxy_stream_tb_fun( Txy_q, legendTexts_q, time, T_isotherm, ...
                                phi_xy, v_x, v_y, t_b, ...
                                Xmesh, Ymesh, titleStr, iColor)
% PLOTS plot isotherms and hydraulic potential phi and groundwater streamlines in plan view

% Input parameters:
% Txy_q - temperature series, 3 dimensions matrix (x, y, q)
% legendTexts_q - cell texts for each q (gw flow)
% time - time at which temperatures were calculated
% T_isotherm - temperatures for isotherm on plot display (Kelvin)
% Xmesh, Ymesh - combination of x and y lists for countour plot, meshgrid(x_list, y_list);

    %setFigSize( 0.67, 1.2 ); %size for poster
    setFigSize( 2, 2 );
    defaultLineWidth = get(groot,'defaultLineLineWidth');
    
    figure;
    colors = setColorOrder( [1 2 3 4 5 6 7] ); %use first colors from default list
    hold on;
    % if temperature data is present in inputs then plot it
    if ~isempty(Txy_q)
        T_line = [T_isotherm(1), T_isotherm]; % to draw on plot single line for plume extent        
        contour(Xmesh, Ymesh, Txy_q, T_line, ... %lineSpec{i}); % draw contour plot
                'LineStyle', '-', 'LineColor', colors(iColor,:), 'LineWidth', defaultLineWidth * 2, ...
                'ShowText','on'); % label the line with temperature delta bewteen natural and disturbed groun
    end
    
    % if Hydraulic potential data is present in inputs then plot it
    if ~isempty(phi_xy)
        % Hydraulic potential (phi)
        contour( Xmesh, Ymesh, phi_xy, 30 ) % 'ShowText','on'
    end
    % if groundwater velocity data is present in inputs then plot it
    if ~isempty(v_x)   
        % plot streamlines
        streamslice(Xmesh, Ymesh, v_x, v_y)
    end
    
    % plot break through time (s)
    if ~isempty(t_b)
        yearList = [0.5, 1, 2, 5, 10, 25];
        contour( Xmesh, Ymesh, secondsToYears(t_b), yearList, ...
                                        'ShowText','on', ...
                                        'LineWidth', defaultLineWidth * 2, 'LineColor', 'blue' )
    end    
    
    
    axis equal xy; % resize x and y to have the same scaled lengths
    xlabel('X distance (m)');
    ylabel('Y distance (m)');
    legend(legendTexts_q, 'Location', 'SouthEast')
    %legend(legendTexts_q, 'Location', 'SouthOutside') %for poster
    title(sprintf('GW velocity effect on [%.1f %.1f] K isotherm, %.0f years', ...
        T_isotherm(1:2), secondsToYears(time)));
    
    axisObj = gca;
    %axisObj.XLim(2) = 150; %Change upper X axis limit only 
    %axisObj.YLim(2) = 60; %Change upper Y axis limit only
    
    % Text on plot about time
    if secondsToYears(time) >= 1 % write legend text time as years, if time>=year
        text(axisObj.XLim(2) / 2, ...
             axisObj.YLim(2) * 0.85, ...
             sprintf('time = %.0f years\n%s', secondsToYears(time), titleStr) );
    else
        text(axisObj.XLim(2)/2, ...
             axisObj.YLim(2)* 0.85, ... 
             sprintf('time = %d days\n%s', secondsToDays(time), titleStr) );
    end

    grid on;

end

