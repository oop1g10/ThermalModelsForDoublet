function plottb_a_Q_q_fun( a_list, tb_a_Q_q, legendTexts, colorOrder, lineStyle )
% Plot MILSd with physical units PROFILE VIEW
% how dispersivity influences plume development with time in x direction
    % tranfer seconds to days
    tb_a_Q_q_days = secondsToDays(tb_a_Q_q); % days
    defaultLineWidth = get(groot,'defaultLineLineWidth');
    % Check if negative temperatures are in result, not to forget about them, if yes print a warning!
    if min(min(tb_a_Q_q_days)) < 0
        warning('Attention: Negative temperatures are present in the output results!')        
    end
    setFigSize( 1.5, 3 ); %size for single column figure
    figure;
    colors = setColorOrder( colorOrder ); %use same color for same time
   % hold on;
    for i = 1:size(tb_a_Q_q_days, 1)
        % a list * 2 because a is half distance between wells
        plot(a_list * 2, tb_a_Q_q_days(i, :), 'Color', colors(i,:), 'lineStyle', lineStyle{i}, 'LineWidth', ...
             1.001 * defaultLineWidth + 0.5 ); %Circle points were too thin (probably bug), using 1.001 fixes it
        hold on
    end
    axisObj = gca;
    % Start minimum y axis from zero
    axisObj.YLim(2) = 30; % days
    % Manually fix max Y limit to match between comsol and analytical soltuion
    % axisObj.XLim(1) = -5;
    xlabel('Distance between wells (m)');
    ylabel('Time to breakthough (days)');
    legend(legendTexts, 'Location', 'southoutside')
    %title('Moving line source')
    grid on
    %saveFig(sprintf('fig8 MILS vs MFLS all correct headings/T_t_axy %s ay/ax=%.1f, az/ax=%.1f, z=%.1d m', model, ay_ratioTo_ax, az_ratioTo_ax, z))
end

