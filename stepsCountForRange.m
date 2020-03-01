function stepsCount = stepsCountForRange( startStepSize, growthRate, skipRadius, logRangeEnd, rangeFull )
% this function returns the number of points needed for rangeFull
% given the number of required steps, for both logarythmic and linear parts.

% Outputs:
% stepsCount - number of steps for requested full range
% Inputs:
% startStepSize - initial step to start the log stepping
% growthRate - the factor by which to increase the step size for logarythmic part
% skipRadius - the radius of borehole which to skip in the mesh generation.
% logRangeEnd - point at which logarythmic stepping ends and linear stepping begins
% rangeFull - points at the borders of model domain on x axis
    stepsCount_Negative = 0;
    stepsCount_Positive = 0;
    % if requested range is actually only a single point than return 1 step
    if ~isempty(rangeFull) && rangeFull(1) == rangeFull(2)
      stepsCount = 1; 
      return
    end
    % divide range in two parts: on left side of borehole wall and right side of it
    if any(rangeFull <= -skipRadius)
        rangeFull_partNegative = rangeFull(rangeFull <= -skipRadius);
        % prepare negative part of range to be only in positive numbers
        rangeFull_partNegative = sort(abs(rangeFull_partNegative));
        % add zero in case only 1 negative value is present in the requested range
        if numel(rangeFull_partNegative) == 1
            rangeFull_partNegative = [skipRadius, rangeFull_partNegative]; %  Absolute values on left hand side
        end

        [stepsCountLog_Negative, stepsCountLin_Negative ] = ...
                stepsCountForLogLin(startStepSize, growthRate, skipRadius, logRangeEnd, rangeFull_partNegative);
        stepsCount_Negative = stepsCountLog_Negative + stepsCountLin_Negative; 
    end
    if any(rangeFull >= skipRadius)
        rangeFull_partPositive = rangeFull(rangeFull >= skipRadius);
        % add zero in case only 1 positive value is present in the requested range
        if numel(rangeFull_partPositive) == 1
            rangeFull_partPositive = [skipRadius, rangeFull_partPositive];
        end
        
        [stepsCountLog_Positive, stepsCountLin_Positive ] = ...
                stepsCountForLogLin(startStepSize, growthRate, skipRadius, logRangeEnd, rangeFull_partPositive);
        stepsCount_Positive = stepsCountLog_Positive + stepsCountLin_Positive; 
    end
    stepsCount = stepsCount_Negative + stepsCount_Positive;
end

