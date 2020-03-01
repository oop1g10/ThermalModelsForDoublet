function colorOrder = setColorOrder( colorIndexList )
% Set colors for plot line based on default ones by changing and/or
% repeating them. Use setColorOrder after calling 'figure' command.
% colorIndexList - list of color indexes from default color list, which contains 7 colors
%                  for example setColorOrder([1 1 2 2 3 4 5 5])
%                  to repeat first color for two lines, then second color for two lines, etc.

    if false
        fprintf('Using Poster colors\n');
        colorOrder = setColorOrderPoster( colorIndexList );

    else
        % Initial colors
        colorOrderCurrent = get(gca,'ColorOrder');
        colorOrderCurrent(end+1,:) = [0,0,0]; % add black color at end
        colorOrderCurrent(end+1,:) = [.3,.3,.3]; % add grey color at end

        % Get changed list
        colorOrder = colorOrderCurrent(colorIndexList, :);
        % Change to new colors
        set(gca, 'ColorOrder', colorOrder, 'NextPlot', 'replacechildren');
        % Verify color order changed and return it
        colorOrder = get(gca,'ColorOrder');
    end
end

