function paramsCalib = getCalibParams( paramValues, paramRanges, paramsStd )
%Return meanings of values in fitted vector
%paramsCalib - structure with parameters

    % Put used not calibrated standard params into the structure
    paramsCalib = paramsStd;
    % Set values of calibrated parameters 
    for i = 1 : size(paramRanges,1)
        paramName = paramRanges.name{i};
        paramValue = paramValues(i);
        % Logarythmic parameter is used (log10)
        if contains(paramName, 'LOG10')
            paramName = paramName(7:end);
            paramValue = 10^paramValue;
            paramsCalib.(paramName) = paramValue;
        % Dispersivity values are assigned separately for x y z directions.
        % they are all equal (linked)
        elseif strcmp(paramName, 'LINKED_aX')
            paramsCalib.aX = paramValue;
            paramsCalib.aY = paramValue;
            paramsCalib.aZ = paramValue; 
        % Well length and aquifer thickness values are the same
        elseif strcmp(paramName, 'LINKED_H')
            paramsCalib.H = paramValue;
            paramsCalib.M = paramValue;
        % Parameter name will not change
        else  
            paramsCalib.(paramName) = paramValue;
        end
    end
end

