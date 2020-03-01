function list = rangeToList( range, Mt, startStepSize, growthRateOptim, skipRadius, logRangeEnd )
% List of values (for example coordinates x, y ) separated by skipRadius (for example borehole radius)
% to avoid calculation of T (temperature, for example) inside borehole which has infinite temperature
%in the center
% range - minimum (given as first value) and maximum (given as second value) of value range to create list from
% Mt - number of steps from max to min to create list from
% skipRadius - radius AROUND ZERO!!!!, which creates a distance to skip inside the created list of values
% skipRadius should be always given as finction input but the required
% range to make list may not inlude this radius, and therefore it will be
% ignored.
% logRangeEnd - Threshhold from where log method ends and linear method starts for list generation 
% (due to optimal Comsol meshing)  ,for example 50 m
        
    % if Mt is zero, return empty list
    if Mt == 0
        list = [];
        return
    end

    % If discretization step is 1, (for example to calculate temperature at
    % bh wall) return list containing single value
    if Mt == 1
        assert(numel(range) == 1 || range(1) == range(2), 'Single discretization step Mt is requested, so range(1) has to be equal to range(2)')
        list = range(1);
        return
    end
    
    % If range consists of single point, return it as a list ignoring
    % number of requested points
    if numel(range) == 1 || range(1) == range(2)
        list = range(1);
        return
    end
    
    % Determine range in front of the borehole and behind of the borehole
    rangeA(1) = min([range(1), -skipRadius]);
    rangeA(2) = min([-skipRadius, range(2)]) ;
    
    rangeB(1) = max([skipRadius, range(1)]);
    rangeB(2) = max([range(2), skipRadius]);
    
    % Use linear method for whole range if logRangeEnd == 0
    if logRangeEnd == 0
        lengthA = rangeA(2) - rangeA(1);
        lengthB = rangeB(2) - rangeB(1);

        % Split number of steps between two ranges (i.e. in front and behind borehole) 
        % proportionally to their relative lengths.
        stepRatioA = lengthA / ( lengthA + lengthB );
        MtA = round(stepRatioA * Mt); % rounds each element of () to the nearest integer
        MtB = Mt - MtA;
        assert( (MtA >= 2 || MtA == 0) && ...
                (MtB >= 2 || MtB == 0) && ...
                (MtA ~= 0 || MtB ~= 0), ...
               'Please make sure that Mt is large enough to have minimum 2 points around ZERO.')

        % Generate list of values
        list = [ linspace(rangeA(1), rangeA(2), MtA), ...  % [m]
                 linspace(rangeB(1), rangeB(2), MtB) ];
    
    % If part of the range is in logarythmic scale (i.e. <50m)
    else

        % Full range for list generation
        [ stepsCountLogOptimA, stepsCountLinOptimA, rangeLogA, rangeLinA, stepsCountRangeLogOptimA ] = ...
            stepsCountForLogLin(startStepSize, growthRateOptim, skipRadius, logRangeEnd, sort(-rangeA));
        [ stepsCountLogOptimB, stepsCountLinOptimB, rangeLogB, rangeLinB, stepsCountRangeLogOptimB ] = ...
            stepsCountForLogLin(startStepSize, growthRateOptim, skipRadius, logRangeEnd, rangeB);

        % Available steps count
        stepsCountOptimSum = stepsCountLogOptimA + stepsCountLinOptimA + ...
                                stepsCountLogOptimB + stepsCountLinOptimB;
        stepsCountLogA = round(stepsCountLogOptimA * Mt / stepsCountOptimSum);
        stepsCountLinA = round(stepsCountLinOptimA * Mt / stepsCountOptimSum);
        stepsCountLogB = round(stepsCountLogOptimB * Mt / stepsCountOptimSum);
        stepsCountLinB = round(stepsCountLinOptimB * Mt / stepsCountOptimSum);

        % Ensure that total number of steps is equal to Mt
        % Put variables to table so biggest can be found and adjusted
        varName = {'stepsCountLogA'; 'stepsCountLinA'; 'stepsCountLogB'; 'stepsCountLinB'};
        stepsCount = [stepsCountLogA; stepsCountLinA; stepsCountLogB; stepsCountLinB];
        stepsCountsTab = table(varName, stepsCount);
        % Sort in decending order to find biggest value
        stepsCountsTab = sortrows(stepsCountsTab, 'stepsCount', 'descend');
        % Add difference in total number of steps to largest value (i.e. 1st row)
        stepsCountDiff = Mt - sum(stepsCountsTab.stepsCount);
        eval([ stepsCountsTab.varName{1} ' = ' stepsCountsTab.varName{1} ' + stepsCountDiff;']);
        
        % In case range of A and B have common point (skipRadius = 0), this duplicate point will be removed
        % so add extra point to the largest part of list, to receive the requested number of steps
        if rangeA(2) == rangeB(1)
            eval([ stepsCountsTab.varName{1} ' = ' stepsCountsTab.varName{1} ' + 1;']);
        end
        
        % In case of absence of linear part of range, logarythmic steps count needs to be decreased by one
        % because range start value is added at the beginning. In case linear range is present, the range end 
        % value is removed at the end by 'unique' command, so nothing needs to be done here
        if stepsCountLinA == 0 ...%In case of absence of linear part of range
                  && stepsCountLogA > 0
            stepsCountLogA = stepsCountLogA - 1;
        end
        % Do the same for second half of the whole range (range may consist of 2 parts: before and after borehole)
        if stepsCountLinB == 0 ...%In case of absence of linear part of range
                  && stepsCountLogB > 0
            stepsCountLogB = stepsCountLogB - 1;
        end
        
        % Recalculate optimal number of steps to available
        stepsCountA = stepsCountRangeLogOptimA(2) * Mt / stepsCountOptimSum;
        stepsCountB = stepsCountRangeLogOptimB(2) * Mt / stepsCountOptimSum;
        % Determine growth rate to be used for available number of steps
        growthRateFunctionA = @(growthRate) ...
           (growthRate^stepsCountA - 1)/(growthRate - 1) - (rangeLogA(2)-skipRadius) / startStepSize;
        growthRateA = fzero(growthRateFunctionA, 1.1);
        growthRateFunctionB = @(growthRate) ...
           (growthRate^stepsCountB - 1)/(growthRate - 1) - (rangeLogB(2)-skipRadius) / startStepSize;
        growthRateB = fzero(growthRateFunctionB, 1.1);

        % Calculate list of step sizes (calculated growth rate  * any step size)
        stepsUnscaledLogA = growthRateA.^(0:stepsCountLogA-1);
        stepsUnscaledLogB = growthRateB.^(0:stepsCountLogB-1);
        % Determine initial step size, so the all steps together cover required log range (rescale stepsUnscalesLog)
        stepSizeInitialLogA = (rangeLogA(2)-rangeLogA(1)) / sum(stepsUnscaledLogA);
        stepSizeInitialLogB = (rangeLogB(2)-rangeLogB(1)) / sum(stepsUnscaledLogB);

        % Prepare list of points for logarythmic part of the range
        if isempty(stepsUnscaledLogA)
            listLogA = [];
        else
            listLogA = rangeLogA(1) + [0 cumsum(stepsUnscaledLogA * stepSizeInitialLogA)];
        end
        if isempty(stepsUnscaledLogB)
            listLogB = [];
        else
            listLogB = rangeLogB(1) + [0 cumsum(stepsUnscaledLogB * stepSizeInitialLogB)];
        end

        % Calculate list of points for linear part of the range
        listLinA = linspace(rangeLinA(1), rangeLinA(2), stepsCountLinA);
        listLinB = linspace(rangeLinB(1), rangeLinB(2), stepsCountLinB);

        % Join all sublists in one list of points
        list = unique(round([-listLinA -listLogA listLogB listLinB], 6, 'significant'));
        
        % Current issue: if too few steps (Mt) requested, function may not be susessful and NaN values 
        % are present in list. Issue error
        if any(isnan(list))
            error('Please increase your requested number of steps, Mt')
        end
    end
end

