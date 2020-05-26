function plotTb_axy_q_fun( ax_list, Tb_axy_q, legendTexts_q, model, time )
%Plot Temperature change at borehole wall with different dispersivities and
%for different gw velocities

    setFigSize( 1, 1 );
    figure;
    plot(ax_list, Tb_axy_q);
    % Manually fix max Y limit to match between comsol and analytical soltuion
    axisObj = gca;
    axisObj.YLim(2) = 25;
    xlabel('Longitudinal dispersivity (m)');
    ylabel('Temperature change (K)');
    legend(legendTexts_q, 'Location', 'NorthEast')
    title(sprintf('%s (borehole wall \\DeltaT after %d years)', model, secondsToYears(time)));
    grid on

end

