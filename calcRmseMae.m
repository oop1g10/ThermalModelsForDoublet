function [rmse, mae] = calcRmseMae(target, model, dim)
% Function to calculate from a data vector or matrix and corresponding
% model data.
% rmse - root mean square error 
% mae - mean absolute error
% dim - to calculate rmse/mae across dimension dim (1 rows or 2 columns)
% Note: data and estimates have to be of same size

%     % Delete records with NaNs in both datasets first
%     valuesListWithoutNaNs = ~isnan(target) & ~isnan(model); 
%     targetWithoutNaN = target(valuesListWithoutNaNs);
%     modelWithoutNaN = model(valuesListWithoutNaNs);
    
    diff = target - model;
    mae = mean(abs(diff), dim);
    rmse = sqrt( sum(diff .^ 2, dim) / size(target, dim) );
end