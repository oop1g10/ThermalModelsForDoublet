function paramsCalib = paramsFromCalib(calibVariant, variant)
%Return the set of best fit parameters according to the variant of calibration used.

    % Get best calibrated parameters for specified variant 
    if strcmp(calibVariant, 'Analytical: q,aX,alpha,cS,lS,n')
        % Trial params set with lower inj temeprature
        bestFitParams = 'q[2.8128e-05] aXYZ[1.97503 1.97503 1.97503] ro[0.0762] H[6] M[6] adeg[278.74] T0[283.15] Ti[310.55] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[800.026] lS[1.90001] n[0.599998] mesh[0.1]';
    elseif strcmp(calibVariant, 'Numerical: q,aX,alpha,cS,lS,n,H RunCount:384')
        bestFitParams = 'q[2.24335e-05] aXYZ[0.00425659 0.00425659 0.00425659] ro[0.0762] H[6.18782] M[6.18782] adeg[302.687] T0[283.15] Ti[310.55] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[993.007] lS[2.87887] n[0.399983] mesh[0.1]';
    elseif strcmp(calibVariant, 'Numerical: q,aX,alpha,cS,lS,n,H RunCount:447 diff T0,lS,n init as ansol')
        bestFitParams = 'q[1.08293e-05] aXYZ[0.710769 0.710769 0.710769] ro[0.0762] H[3.00286] M[3.00286] adeg[216.44] T0[283.32] Ti[310.55] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[823.19] lS[2.78244] n[0.380194] mesh[0.1]';
    elseif strcmp(calibVariant, 'Numerical: q,aX,alpha,cS,lS,n,H RunCount:431 diff T0,lS,n init as prev numsim 447') % RMSE adj 3.02
        bestFitParams = 'q[1.063e-05] aXYZ[0.635331 0.635331 0.635331] ro[0.0762] H[3] M[3] adeg[215.359] T0[283.32] Ti[310.55] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[803.766] lS[3.18097] n[0.31096] mesh[0.1]';
    elseif strcmp(calibVariant, 'Numerical: q,aX,alpha,cS,lS,n,H RunCount:558 diff T0,lS,n WIDER ranges init 431') % RMSEadj 3.01
        bestFitParams = 'q[1.03207e-05] aXYZ[0.381537 0.381537 0.381537] ro[0.0762] H[2.86124] M[2.86124] adeg[210.207] T0[283.32] Ti[310.55] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[603.676] lS[3.591] n[0.222411] mesh[0.1]';
    elseif strcmp(calibVariant, 'Numerical: q,aX,alpha,cS,lS,n,H RunCount:0488 WIDER ranges cS,H init 431') % yes same init values used here % RMSEadj 3.1
        bestFitParams = 'q[1.50618e-05] aXYZ[0.1954 0.1954 0.1954] ro[0.0762] H[1.45979] M[1.45979] adeg[209.392] T0[283.32] Ti[310.55] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[929.114] lS[1.66504] n[0.322536] mesh[0.1]';
    end
    paramsCalib = comsolFilename_Info( ['plan sol1 0001 ', bestFitParams, '.txt'], variant );
end

