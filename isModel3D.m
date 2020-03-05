function [ model3D ] = isModel3D( modelMethod )
% return true if model is in 3D 

    if strcmp(modelMethod, 'MFLS')... % analytical
            || strcmp(modelMethod, 'nMFLS')... % numerical
            || strcmp(modelMethod, 'nMFLSp') ... % numerical with pipes and grout
            || strcmp(modelMethod, 'nMFLSfr')... % numerical with fracture
            || strcmp(modelMethod, 'nMFLSfrp')      % numerical with fracture and with pipes with grout
        model3D = true;
    else
        model3D = false;
    end
end

