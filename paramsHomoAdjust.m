function [ paramsOut ] = paramsHomoAdjust( paramsIn, modelMethod, variant )
% Returns params adjusted in case other method is given (i.e. fracture present)

    paramsOut = paramsIn;
    
    % For model with standard parameters ignore all changes in parameters
    % (in one at a time sensitivity analysis for example) and return
    % standard parameters set
    if strcmp(modelMethod, 'nDoublet2Dstd') || strcmp(modelMethod, 'SchulzStd')
        paramsOut = standardParams( variant );       
    end
end

