function usedDimensions = dimensionFromName_Logic( dimensionNames )
% Find which dimensions are used in dimensions name of the column

    usedDimensions = [any(dimensionNames == 'x'), ...
                          any(dimensionNames == 'y'), ...
                          any(dimensionNames == 'z')];

end

