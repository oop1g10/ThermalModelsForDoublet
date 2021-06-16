function [ legend ] = legendTexts_forPlotOneParamChg(  y1Legend, y2Legend, y1Time, infoRow, y1Unit, y2Unit, baseModeltoCompare, y)
%return legend texts for plot
% y = for which y (y1 or y2) to do the legend text

    % change units for time
    y1Time = secondsToDays(y1Time); % time from seconds to days

    
    if contains(y, 'timeSS')
        legend  = sprintf('%s: %.1f - %.1f %s (%s: %.1f %s)', ...
                y2Legend, ...
                secondsToDays(infoRow.y2 + infoRow.y2_Diff_Min), ...
                secondsToDays(infoRow.y2 + infoRow.y2_Diff_Max), ...
                y2Unit, baseModeltoCompare, ...
                secondsToDays(infoRow.y2), y2Unit);
    else
%                if contains(y, 'T_b') || contains(y, 'xPlume') 
        legend = sprintf('%s %.0f days: %.1f - %.1f %s (%s: %.1f %s)', ...
                y1Legend, y1Time,  ...
                infoRow.y1 + infoRow.y1_Diff_Min, ...
                infoRow.y1 + infoRow.y1_Diff_Max, ...
                y1Unit, baseModeltoCompare, ...
                infoRow.y1, y1Unit);
    end

end
