function [ relDiff ] = relativeDiff( target, model )
%Relative difference between target and model

    relDiff = (model - target) ./ target;

end

