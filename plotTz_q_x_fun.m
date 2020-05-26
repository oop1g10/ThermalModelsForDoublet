function plotTz_q_x_fun( z_list, Tz_q_x, x_list, aXYZ, legendTexts_q, q_colorOrder, modelNames_Tz_q_x, ...
                         plotTitleTz_q_x, show_legend, lineStyleSet, markerStyleSet )
% Plot Temperature at different x versus depth (z dimention) for different GW flows
% x_list - x value for all temperature results to print it in the figure
% show_legend show or not to show the legend on plot


    defaultLineWidth = get(groot,'defaultLineLineWidth');
    % Check if negative temperatures are in result, not to forget about them, if yes print a warning!
    if min(min(Tz_q_x)) < 0
        warning('Attention: Negative temperatures are present in the output results!')        
    end 
    setFigSize( 3, 3 ); % x, y width, height
    figure;
    colors = setColorOrder( q_colorOrder );
    for i = 1 : size(Tz_q_x, 1)
        lineWidthfactor = 1.5;
        % For same colour use different line style, first line '-', second circles 'o'
        if mod(i,3) == 0 % every third line should be dots ( average of right and left T)
        % if  Tz_q_x(i,end) == 1 && i > 2 && q_colorOrder(i) == q_colorOrder(i-2) ||...
        %     Tz_q_x(i,end) == 2 && any((i - numel(unique(q_colorOrder))) == [2, 8, 14, 24])
            lineStyle = ':';
            markerStyle = 'none';
            T_q_line = Tz_q_x(i, :);
            z_list_line = z_list;
        elseif isModelNumerical( modelNames_Tz_q_x{i} )
            lineStyle = 'none'; %'--'
            markerStyle = 'o'; % 'none'
            % Sparse (every third point) for numerical model otherwise there are too many circles!
            %T_q_line = T_q(i,1:3:end);
            %t_list_line = t_list(1:3:end);
            % Sparse (every third point) for numerical model otherwise there are too many circles!            
            T_q_line = Tz_q_x(i,1:3:end);
            z_list_line = z_list(1:3:end);
        else 
            lineStyle = '-';
            markerStyle = 'none'; 
            T_q_line = Tz_q_x(i,:);
            z_list_line = z_list;
        end    
        ax = gca;
        ax.YDir = 'reverse';
        
        if isempty(lineStyleSet)
            lineStyleUse = lineStyle;
        else
            lineStyleUse = lineStyleSet{i};
        end
        if isempty(markerStyleSet)
            markerStyleUse = markerStyle;
        else
            markerStyleUse = markerStyleSet{i};
        end
                    
        plot(T_q_line, z_list_line, ...
                'Color', colors(i,:), 'LineStyle', lineStyleUse, 'Marker', markerStyleUse, 'LineWidth', ...
                    1.001*defaultLineWidth*lineWidthfactor); %Circle points were too thin (probably bug), using 1.001 fixes it
        hold on
    end
    
    xlabel('Temperature change (K)');
    ylabel('Depth (m)');
    
    % %legend(legendTexts_q, 'Location', 'NorthWest')
    if show_legend
 
           legend(legendTexts_q, 'Location', 'WestOutside')
    else
            warning('legend off')
    end
    title(plotTitleTz_q_x)
    grid on
    %show dispersivity on the plot
    if ~isempty(aXYZ) %show only if provided values
        if numel(legendTexts_q) > 4 % if more than 4 lines plotted
            yTextLocationCoef = 0.85;
        else
            yTextLocationCoef = 0.40;
        end
     %   warning('textoff')
        axisObj = gca;
        text(axisObj.XLim(1) + (axisObj.XLim(2) - axisObj.XLim(1)) * 0.02, ...
             axisObj.YLim(1) + (axisObj.YLim(2) - axisObj.YLim(1)) * yTextLocationCoef, ...
                sprintf('a_{xyz} = (%.1f, %.1f, %.1f) m\nx = %.2f m', aXYZ, x_list) );
                % % sprintf('a_{xyz} = (%.1f, %.1f, %.1f) m\nx = %.2f m\n%s', aXYZ, xCoord, titleStr) );
    end
    %saveFig('fig5 v2 MFLSa disp 2 02 10 circle at wall for depth 90m/T_q x=0,05m')

end

