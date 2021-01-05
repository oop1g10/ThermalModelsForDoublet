function wellTempTabPart = wellNameDepthSelect(wellTempTab, wellName, wellDepth)
% Return row with temperature data for specified well name and depth

    % Select relevant rows based on well name and depth
    relevantRows = strcmp(wellTempTab.wellName, wellName) ...
        & wellTempTab.wellDepth == wellDepth;
    wellTempTabPart = wellTempTab(relevantRows, :);

end

