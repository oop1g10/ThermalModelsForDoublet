function modelIsNumerical = isModelNumerical( modelMethod )
% 'Schulz', 'nDoublet2D'
	modelIsNumerical = strcmp(modelMethod, 'nDoublet2D') ...
                    || strcmp(modelMethod, 'nDoublet2Dstd');
end

