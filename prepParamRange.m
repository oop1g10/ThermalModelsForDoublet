function paramRange = prepParamRange(paramName, distribution, min, max, mean_best, sigma)
% Prepare ranges and distributions for model parameters

    paramRange = table;
    paramRange.name = {paramName};
    paramRange.distribution = {distribution};
    paramRange.min = min;
    paramRange.max = max;
    paramRange.mean_best = mean_best;
    paramRange.sigma = sigma;
end