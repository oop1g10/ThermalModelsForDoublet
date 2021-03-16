function plotT_q_fun( t_list, T_q, xCoord, aXYZ, legendTexts_q, q_colorOrder, titleStr, lineStyles, markerStyles )
% Time to reach steady state at different GW flows
% xCoord - x value for all temperature results to print it in the figure

    defaultLineWidth = get(groot,'defaultLineLineWidth');
    % Check if negative temperatures are in result, not to forget about them, if yes print a warning!
%     if min(min(T_q)) < 0
%         warning('Attention: Negative temperatures are present in the output results!')        
%     end

    if numel(legendTexts_q) >= 3
        setFigSize( 2, 2 ); %size for single column figure %2.1
    else
        setFigSize( 1, 1 ); %size for single column figure
    end
    figure;
    colors = setColorOrder( q_colorOrder );
    
    % By how many steps to skip the data during plotting, if = 1 means no
    % skipping
    skipCount = 1;
    
    for i = 1 : size(T_q,1)
        % if marker size is not specified do not use it
         if isempty(markerStyles)
            markerStyle = 'none';
        else
            markerStyle = markerStyles{mod(i-1,numel(markerStyles))+1}; %repeat usage of markers if not enough specified
         end

        % For same colour use different line style, first line '-', second circles 'o'
        if i > 2 && q_colorOrder(i) == q_colorOrder(i-2)
            if isempty(lineStyles) 
                lineStyle = 'none'; %'-';
            else
                lineStyle = lineStyles{mod(i-1,numel(lineStyles))+1}; %repeat usage of line styles if not enough specified               
            end
            
           % markerStyle = 'none'; %'*';
            lineWidthfactor = 1.5;
            % Sparse (every third point) for numerical model otherwise there are too many circles!
            %T_q_line = T_q(i,1:skipCount:end);
            %t_list_line = t_list(1:skipCount:end);
          %  T_q_line = T_q(i,:);
          %  t_list_line = t_list;
            
            if length(t_list) > 100 %in case of 3D model many times are calculated, so every 6rd value is ploted
                T_q_line = T_q(i,1:6:end);
                t_list_line = t_list(1:6:end);
            else %in case of 2D model fewer times are calculated, so every 3rd value is ploted
                T_q_line = T_q(i,1:skipCount:end);
                t_list_line = t_list(1:skipCount:end);
            end
                      
            
        elseif i > 1 && q_colorOrder(i) == q_colorOrder(i-1)
            if isempty(lineStyles)
                lineStyle = 'none'; %'--'
            else
                lineStyle = lineStyles{mod(i-1,numel(lineStyles))+1}; %repeat usage of line styles if not enough specified
            end
                        
            lineWidthfactor = 1.5;
            % Sparse (every third point) for numerical model otherwise there are too many circles!
            if length(t_list) > 100 %in case of 3D model many times are calculated, so every 6rd value is ploted
                T_q_line = T_q(i,1:6:end);
                t_list_line = t_list(1:6:end);
            else %in case of 2D model fewer times are calculated, so every 3rd value is ploted
                T_q_line = T_q(i,1:skipCount:end);
                t_list_line = t_list(1:skipCount:end);
            end
            
            
          %  T_q_line = T_q(i,:); % plot all points
           % t_list_line = t_list;
        else
            if isempty(lineStyles)
                lineStyle = '-';     %':';
            else
                lineStyle = lineStyles{mod(i-1,numel(lineStyles))+1}; %repeat usage of line styles if not enough specified
            end

            lineWidthfactor = 1.5;         %1;
            T_q_line = T_q(i,:);
            t_list_line = t_list;

        end
       % semilogx
        plot(secondsToDays(t_list_line), T_q_line, ...
            'Color', colors(i,:), 'LineStyle', lineStyle, 'Marker', markerStyle, 'LineWidth', ...
                1.001*defaultLineWidth*lineWidthfactor); %Circle points were too thin (probably bug), using 1.001 fixes it
        hold on
    end
    
    axisObj = gca;
    % Allow to change time range while keeping the same Xlim for both MILS and Comsol
    % use round of log. Set x axis minimum/maximum on whole exponent numbers as 10^-3 or 10^-4. 
    % X limits commented because semilog x is no longer used.
    % axisObj.XLim(1) = 10^floor( log10(min(secondsToDays(t_list))) ); 
    % axisObj.XLim(2) = 10^ceil( log10(max(secondsToDays(t_list))) );
    % Start minimum y axis from zero
    % axisObj.YLim(1) = 0;
    % axisObj.YLim(2) = 25;

    xlabel('Time (days)');
    ylabel('Temperature change (K)');   
    
    % %legend(legendTexts_q, 'Location', 'NorthWest')
   if numel(legendTexts_q) > 4 % if more than 4 lines plotted
       legend(legendTexts_q, 'Location', 'SouthOutside')
   else
       legend(legendTexts_q, 'Location', 'SouthOutside'); %'NorthWest')
   end
%  warning('legend off')
    title(titleStr)
    grid on
    %show dispersivity on the plot
    if ~isempty(aXYZ) %show only if provided values
        if numel(legendTexts_q) > 4 % if more than 4 lines plotted
            yTextLocationCoef = 0.85;
        else
            yTextLocationCoef = 0.40;
        end
        warning('textoff')
%         text(axisObj.XLim(1) + exp(log((axisObj.XLim(2) - axisObj.XLim(1))) * -0.6), ...
%              axisObj.YLim(1) + (axisObj.YLim(2) - axisObj.YLim(1)) * yTextLocationCoef, ...
%                 sprintf('a_{xyz} = (%.1f, %.1f, %.1f) m\nx = %.2f m', aXYZ, xCoord) );
%                 % % sprintf('a_{xyz} = (%.1f, %.1f, %.1f) m\nx = %.2f m\n%s', aXYZ, xCoord, titleStr) );
    end
end

