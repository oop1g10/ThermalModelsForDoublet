function setFigSize( figWidthCols, figHeightRatio )
% Set figure size for saving with readable text for articles
% figWidthCols - 1 single or 2 double (full) width
% figHeightRatio - height of figure relative to usual 3/4 to width, can be adjusted to fit legend below

    % Set displayed figures size for saving and using in article
    figureWidthSingle = 420; % width for 7.75 cm wide figure (double column article) so text is readable (cca size 9)
    figureWidthSingleCm = 7.75; % article single column width in cm
    figureWidthFullCm = 17; % article double column (full) width in cm
    figureHeightSingle = 300; % height for usual single column figure (can be adjusted)
    sizeRatioToSingle = (1 + (figWidthCols - 1) * (figureWidthFullCm / figureWidthSingleCm - 1)); % for figWidthCols = 2 it is 2.19 to accomodate for space between columns
    set(groot, 'defaultFigurePosition', ...
        [100, 50, ... % left bottom
        figureWidthSingle * sizeRatioToSingle, ... % width
        figureHeightSingle * figHeightRatio]);  % height

    % Set lines thicker than default 0.5
    set(groot,'defaultLineLineWidth',1);
    
    % Change line styles so if all colors repeated dashed line will be used
    set(groot,'defaultAxesLineStyleOrder', '-|--|:')

end

