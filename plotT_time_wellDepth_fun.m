function plotT_time_wellDepth_fun( time_depth, T_depth, legendTexts_depth, depth_colorOrder, titleStr, lineStyles, markerStyles, ...
                                        dateTimeStart_inj, dateTimeFinish_inj, xDateTimeStart, xDateTimeFinish)
% Plot T vs time at different depths in well

    defaultLineWidth = get(groot,'defaultLineLineWidth');

    if numel(legendTexts_depth) >= 3
        setFigSize( 3, 3 ); % (width, height) %size for single column figure %2.1
    else
        setFigSize( 3, 2 ); %size for single column figure
    end 
    figure;
    colors = setColorOrder( depth_colorOrder );

    for i = 1 : size(T_depth,1)
        % if marker size is not specified do not use it
        if isempty(markerStyles)
            markerStyle = 'none';
        else
            markerStyle = markerStyles{mod(i-1,numel(markerStyles))+1}; %repeat usage of markers if not enough specified
        end
        % if line style is not specified do not use it
        if isempty(lineStyles)
            lineStyle = 'none';
        else
            lineStyle = lineStyles{mod(i-1,numel(lineStyles))+1}; %repeat usage of line style if not enough specified
        end
           
        lineWidthfactor = 1;                                 
                                  
        plot(time_depth{i}, T_depth{i}, ...
            'Color', colors(i,:), 'LineStyle', lineStyle, 'Marker', markerStyle, 'LineWidth', ...
                1.001*defaultLineWidth*lineWidthfactor); %Circle points were too thin (probably bug), using 1.001 fixes it
        hold on
    end
    % Plot line for start and finish dates of heat injection
    if ~isempty(dateTimeStart_inj) && ~isempty(dateTimeFinish_inj)
        plot([dateTimeStart_inj, dateTimeStart_inj], [min(T_depth{i}), max(T_depth{i})], ...
            'Color', 'k', 'LineStyle', ':', 'Marker', 'none', 'LineWidth', ...
            1.001*defaultLineWidth*lineWidthfactor); %Circle points were too thin (probably bug), using 1.001 fixes it
        plot([dateTimeFinish_inj, dateTimeFinish_inj], [min(T_depth{i}), max(T_depth{i})], ...
            'Color', 'k', 'LineStyle', ':', 'Marker', 'none', 'LineWidth', ...
            1.001*defaultLineWidth*lineWidthfactor); %Circle points were too thin (probably bug), using 1.001 fixes it
    end
    
    if ~isempty(xDateTimeStart)&& ~isempty(xDateTimeFinish)
        % adjust x axis time period according to test chosen
        axisObj = gca;
        axisObj.XLim(1) = xDateTimeStart;
        axisObj.XLim(2) = xDateTimeFinish;
    end

    xlabel('Time');
    ylabel('Temperature (degC)');   
    
    legend(legendTexts_depth, 'Location', 'SouthOutside')
    title(titleStr)
    grid on
    
end

