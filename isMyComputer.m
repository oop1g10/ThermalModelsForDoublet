function isMyComp = isMyComputer()
% Return true if running on my computer

    % Detect by existance of working folder
    if exist('D:\COMSOL_INRS','dir')
        isMyComp = true;
    else
        isMyComp = false;
    end

end

