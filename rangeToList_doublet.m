function list = rangeToList_doublet( range, Mt, startStepSize, growthRate, skipRadius, logRangeEnd, a )
% List of values (for example coordinates x, OR list of coordinated y ) separated by skipRadius
% (for example borehole radius)
% to avoid calculation of T (temperature, for example) inside borehole which has infinite temperature
%in the center
% range - minimum (given as first value) and maximum (given as second value) of value range to create list from
% Mt - number of steps from max to min to create list from
% skipRadius - radius AROUND ZERO!!!!, which creates a distance to skip inside the created list of values
% skipRadius should be always given as finction input but the required
% range to make list may not inlude this radius, and therefore it will be
% ignored.
% logRangeEnd - Threshhold from where log method ends and linear method starts for list generation 
% (due to optimal Comsol meshing), for example 50 m
% a - % (m) half of distance between two wells

    [xInjection, ~, xAbstraction, ~] = getWellCoords(a);
    
    % generate list of points around injection well,
    % starting from end of model closest to injection well and up to zero.
    % if requested range lies on the right hand side from zero coordinate
    if range(1) > 0 % equal sign is deleted so that point zero is left on the side of injection well 
        rangeInj = [];
    else
        % generate list of points for the side from start range to zero (injection well half)
        % and if the range(2) is smaller than zero --> limit the range accordingly
        if range(2) < 0
            rangeEndInj = range(2);
        else
            rangeEndInj = 0;
        end
        % shifted injection range so that injection well is located at zero coordinate
        rangeInj = [range(1) - xInjection, rangeEndInj - xInjection];
    end
    % same for abstraction well
    % if requested range lies on the left hand side from zero coordinate
    if range(2) <= 0 % zero point is excluded from the side of abstraction
        rangeAbs = [];
    else
        % generate list of points for the side from zero to end fo the range (abstraction well half)
        % if the range(1) is larger than zero --> limit the range accordingly
        if range(1) > 0 
            rangeStartAbs = range(1);
        else
            rangeStartAbs = 0;
        end
        % shifted abstraction range so that abstraction well is located at zero coordinate
        rangeAbs = [rangeStartAbs - xAbstraction, range(2) - xAbstraction];
    end
    
    % Split total number Mt by weighted number of steps for each side (injection and abstraction well)
    % rangeInj is given around injection well, well is on zero, 
    % so e.g. considering both inj and abstraction wells ranges = doublet model is from -400 to 400m
    % Calculate number of points for side with negative coordinate points
    stepsCount_Inj = stepsCountForRange( startStepSize, growthRate, skipRadius, logRangeEnd, rangeInj );
    % Calculate number of points for side from zero to abstraction well (positive numbers)
    stepsCount_Abs = stepsCountForRange( startStepSize, growthRate, skipRadius, logRangeEnd, rangeAbs );
    % divide requested Mt by weighted parts
    MtInj =  round(Mt * stepsCount_Inj/(stepsCount_Inj + stepsCount_Abs));    
    MtAbs =  round(Mt * stepsCount_Abs/(stepsCount_Inj + stepsCount_Abs));
    % If ranges for both sides (Abstraction and Injectin wells) are not empty
    if all([stepsCount_Inj, stepsCount_Abs])
        % Make sure that the sum of rounded required steps for both sides equal to Mt + 1
        % as later 1 will be subtracted from Mt to accound for double zero coordinate (each side has one zero)
        MtInj = (Mt + 1) - MtAbs;
    end    
    
    % Based on weighted parts for Mt for Abstration and Injection generate list of coordinates for each part
    listInjection = xInjection + rangeToList( rangeInj, MtInj, startStepSize, growthRate, skipRadius, logRangeEnd );
    listAbstraction = xAbstraction + rangeToList(rangeAbs, MtAbs, startStepSize, growthRate, skipRadius, logRangeEnd );
    
    % return unique x coordinates list
    list = unique([listInjection, listAbstraction]);
end
