function plotT_t_axy_fun( x_list, T_t_axy, legendTexts, q, T_plumeLimit, x_range, colorOrder, lineStyle )
% Plot MILSd with physical units PROFILE VIEW
% how dispersivity influences plume development with time in x direction

    defaultLineWidth = get(groot,'defaultLineLineWidth');

    % Check if negative temperatures are in result, not to forget about them, if yes print a warning!
    if min(min(T_t_axy)) < 0
        warning('Attention: Negative temperatures are present in the output results!')        
    end

    setFigSize( 1.5, 1.5 ); %size for single column figure
    figure;

    colors = setColorOrder( colorOrder ); %use same color for same time

   % hold on;
    for i = 1:size(T_t_axy, 1)
        % If not line is plotted, use circles to show data points
        if strcmp(lineStyle{i}, 'none')
            lineSpec = 'o';
            T_t_axy_line = T_t_axy(i,3:3:end);
            x_list_line = x_list(3:3:end);
        else
            lineSpec = lineStyle{i};
            T_t_axy_line = T_t_axy(i,:);
            x_list_line = x_list;
        end
        plot(x_list_line, T_t_axy_line, 'Color', colors(i,:), 'lineStyle', lineSpec, 'LineWidth',  1.001*defaultLineWidth+0.5); %Circle points were too thin (probably bug), using 1.001 fixes it
        hold on
    end
    plot(x_range, [T_plumeLimit,T_plumeLimit], ':k'); % plot line for all x of 0.5 K temperature as plume extent marker
    plot(x_range, [1, 1], ':k'); % plot line for all x of 0.5 K temperature as plume extent marker

    axisObj = gca;
    % Start minimum y axis from zero
    axisObj.YLim(1) = 0;
    % Manually fix max Y limit to match between comsol and analytical soltuion
    axisObj.XLim(1) = -5;
    xlabel('X distance (m)');
    ylabel('Temperature change (K)');
    legend(legendTexts, 'Location', 'NorthEast')
    %title('Moving line source')
    grid on
        %axisObj = gca;
        %axisObj.XLim = [0 1000]; %Change X axis limits
        %axisObj.YLim = [0 2]; %Change Y axis limits
        
    text( axisObj.XLim(1) + (axisObj.XLim(2) - axisObj.XLim(1)) * 0.77, ...
          axisObj.YLim(1) + (axisObj.YLim(2) - axisObj.YLim(1)) * 0.15, ...
          sprintf('v_{D} = %.3f m/day', q/secondsToDays(1) ));
    

    %saveFig(sprintf('fig8 MILS vs MFLS all correct headings/T_t_axy %s ay/ax=%.1f, az/ax=%.1f, z=%.1d m', model, ay_ratioTo_ax, az_ratioTo_ax, z))
end

