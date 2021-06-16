function paramsCalib = paramsFromCalib(calibVariant, variant)
%Return the set of best fit parameters according to the variant of calibration used.

    % Get best calibrated parameters for specified variant 
    if strcmp(variant, 'FieldExp1')
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
        elseif strcmp(calibVariant, 'Numerical2: 424') % BEST FIT FOR TEST 2 to be used here for plots (Q par removed)
            bestFitParams = 'q[3.32926e-06] aXYZ[1.75351e-05 1.75351e-05 1.75351e-05] ro[0.0762] H[8.84383] M[8.84383] adeg[271.215] T0[283.64] Ti[302.452] a[3.14067] rhoW[999.75] cW[4192] rhoS[2600] cS[787.993] lS[1.8614] n[0.254193] mesh[0.1]';
        else
            error('such calibvariant does not exist')
        end
    elseif strcmp(variant, 'FieldExp1m')
        if strcmp(calibVariant, 'Numerical: q,aX,alpha,cS,lS,n,H RunCount:0488 WIDER ranges cS,H init 431')
            bestFitParams = 'q[1.50618e-05] aXYZ[0.1954 0.1954 0.1954] ro[0.0762] H[1.45979] M[1.45979] adeg[209.392] T0[283.32] Ti[310.55] a[4.97] Q[0.00041] rhoW[999.75] cW[4192] rhoS[2600] cS[929.114] lS[1.66504] n[0.322536] mesh[0.1]';
        % first best fit for exp1m
        elseif strcmp(calibVariant, 'Numerical: 0458')           
            bestFitParams = 'q[2.73023e-06] aXYZ[0 0 0] ro[0.0762] H[4.42107] M[4.42107] adeg[251.504] T0[283.32] Ti[310.55] a[4.97] Qb[0.000225325] rhoW[999.75] cW[4192] rhoS[2600] cS[692.321] lS[1.68264] n[0.1388] mesh[0.1]';        
  
            % WARMING these initial parameters are taken from test all
        % Modif best fit, ls different,  Ti different
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 482 modif') % RMSEadj: 1.243685 BEST finished calibration for all tests with zero dispersivity
            bestFitParams = 'q[2.39473e-06] aXYZ[0 0 0] ro[0.0762] H[4.5549] M[4.5549] adeg[233.01] T0[283.32] Ti[310.55] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[671.654] lS[1.5] n[0.20024] mesh[0.1]';
 
 
        else
            error('such calibvariant does not exist')
        end
    elseif strcmp(variant, 'FieldExp2')
        if strcmp(calibVariant, 'Numerical2: RunCount: 261 adjusted') % RMSEadj: 1.162524 BEST
            % Best fit params after initial calibration with ZERO dispersivity, for All tests dataset. with dispersivity and no data for monitoring 1
            % and with ls 1.5
            bestFitParams = 'q[1.00259e-06] aXYZ[0 0 0] ro[0.0762] H[8.20562] M[8.20562] adeg[235.278] T0[283.32] Ti[310.55] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[648.094] lS[1.5] n[0.235899] mesh[0.1]';
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 411') % RMSEadj:  0.777966 BEST Finished  411, time 1.40 minutes
            bestFitParams = 'q[1.00012e-06] aXYZ[0 0 0] ro[0.0762] H[7.33363] M[7.33363] adeg[218.165] T0[283.32] Ti[310.55] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[804.683] lS[2.49968] n[0.228189] mesh[0.1]';
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 423') % RMSEadj: 1.408902 BEST 
            bestFitParams = 'q[1.01982e-06] aXYZ[0 0 0] ro[0.0762] H[8.99804] M[8.99804] adeg[216.871] T0[283.32] Ti[303.341] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[600.512] lS[2.49835] n[0.200041] mesh[0.1]';
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 359') % RMSEadj: 1.411372 BEST 
            bestFitParams = 'q[1.06255e-06] aXYZ[4.46229e-07 4.46229e-07 4.46229e-07] ro[0.0762] H[8.99361] M[8.99361] adeg[210.103] T0[283.32] Ti[302.9] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[611.083] lS[1.70884] n[0.201153] mesh[0.1]';
        % WARMING these initial parameters are taken from test all
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 482') % RMSEadj: 1.243685 BEST finished calibration for all tests with zero dispersivity
            bestFitParams = 'q[2.39473e-06] aXYZ[0 0 0] ro[0.0762] H[4.5549] M[4.5549] adeg[233.01] T0[283.32] Ti[305.15] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[671.654] lS[3.98691] n[0.20024] mesh[0.1]';
 
        
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 482_ls15_Ti29') % RMSEadj: 3.24369 BEST finished calibration for all tests with zero dispersivity
            bestFitParams = 'q[2.39473e-06] aXYZ[0 0 0] ro[0.0762] H[4.5549] M[4.5549] adeg[233.01] T0[283.64] Ti[302.35] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[671.654] lS[1.5] n[0.20024] mesh[0.1]';
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 482_ls39_Ti29') % RMSEadj: 1.243685 BEST finished calibration for all tests with zero dispersivity
            bestFitParams = 'q[2.39473e-06] aXYZ[0 0 0] ro[0.0762] H[4.5549] M[4.5549] adeg[233.01] T0[283.64] Ti[302.35] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[671.654] lS[3.98691] n[0.20024] mesh[0.1]';
        
        % latest best fit for test 2 (new axrange wider) with COMSOL
        elseif strcmp(calibVariant, 'Numerical2: 424') 
            bestFitParams = 'q[3.32926e-06] aXYZ[1.75351e-05 1.75351e-05 1.75351e-05] ro[0.0762] H[8.84383] M[8.84383] adeg[241.957] T0[283.64] Ti[302.452] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[787.993] lS[1.8614] n[0.254193] mesh[0.1]';
            
        % switch(calibVariant) % can also use

            % calibration when LARGE range for ls thermal conductivity was set
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 539') % RMSEadj: 1.331887 BEST 
            bestFitParams = 'q[1.03334e-06] aXYZ[3.98012e-06 3.98012e-06 3.98012e-06] ro[0.0762] H[8.42753] M[8.42753] adeg[230.303] T0[283.32] Ti[305.047] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[716.163] lS[4.52951] n[0.174094] mesh[0.1]';
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 371') % RMSEadj: 1.331887 BEST 
            bestFitParams = 'q[1.33583e-06] aXYZ[0 0 0] ro[0.0762] H[7.70212] M[7.70212] adeg[205.299] T0[283.64] Ti[302.394] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[685.796] lS[1.09814] n[0.321278] mesh[0.1]';
        
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 572') % RMSEadj: 1.331887 BEST 
            bestFitParams = 'q[1.79335e-06] aXYZ[8.43294e-05 8.43294e-05 8.43294e-05] ro[0.0762] H[7.72487] M[7.72487] adeg[205.09] T0[283.64] Ti[303.01] a[4.97] rhoW[999.75] cW[4192] rhoS[2600] cS[783.264] lS[1.11176] n[0.209682] mesh[0.1]';
        else
            error('such calibvariant does not exist')
        end 
    elseif strcmp(variant, 'FieldExp2Rotated') %%%%%%%%ROTATED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        % latest best fit for test 2 (new axrange wider) with COMSOL
        if strcmp(calibVariant, 'Numerical2: 424') 
            bestFitParams = 'q[3.32926e-06] aXYZ[1.75351e-05 1.75351e-05 1.75351e-05] ro[0.0762] H[8.84383] M[8.84383] adeg[271.215] T0[283.64] Ti[302.452] a[3.14067] rhoW[999.75] cW[4192] rhoS[2600] cS[787.993] lS[1.8614] n[0.254193] mesh[0.1] Q[0.000407]';
       % latest best fit for test 2 with Analytical solution Schulz
        elseif strcmp(calibVariant, 'Analytical: from Init424')  %  RunCount: 2428,
            bestFitParams = 'q[1.36638e-05] aXYZ[0 0 0] ro[0.0762] H[5.14374] M[5.14374] adeg[240.136] T0[283.64] Ti[302.498] a[3.14067] rhoW[999.75] cW[4192] rhoS[2600] cS[1055.89] lS[2.48064] n[0.269173] mesh[0.1] Q[0.000407]';
        else
            error('such calibvariant does not exist')
        end 
    elseif strcmp(variant, 'FieldExpAll')
        if strcmp(calibVariant, 'Numerical2: RunCount:558 WIDER ranges init 431. zerodisp') % RMSEadj 3.01
            % Best fit params but with dispersivity zero
            bestFitParams = 'q[1.03207e-05] aXYZ[0 0 0] ro[0.0762] H[2.86124] M[2.86124] adeg[210.207] T0[283.32] Ti[310.55] a[4.97] Qb[0.0002] rhoW[999.75] cW[4192] rhoS[2600] cS[603.676] lS[3.591] n[0.222411] mesh[0.1]';
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 261') % RMSEadj: 1.162524 BEST
            % Best fit params after initial calibration with dispersivity, for All tests dataset. with dispersivity and no data for monitoring 1
            bestFitParams = 'q[1.00259e-06] aXYZ[0.174622 0.174622 0.174622] ro[0.0762] H[8.20562] M[8.20562] adeg[235.278] T0[283.32] Ti[310.55] a[4.97] Qb[0.000244125] rhoW[999.75] cW[4192] rhoS[2600] cS[648.094] lS[3.3537] n[0.235899] mesh[0.1]';
        elseif strcmp(calibVariant, 'Numerical2: RunCount: 482') % RMSEadj: 1.243685 BEST finished calibration for all tests with zero dispersivity
            bestFitParams = 'q[2.39473e-06] aXYZ[0 0 0] ro[0.0762] H[4.5549] M[4.5549] adeg[233.01] T0[283.32] Ti[310.55] a[4.97] Qb[0.000408806] rhoW[999.75] cW[4192] rhoS[2600] cS[671.654] lS[3.98691] n[0.20024] mesh[0.1]';
        else
            error('such calibvariant does not exist')   
        end
    end
    paramsCalib = comsolFilename_Info( ['plan sol1 0001 ', bestFitParams, '.txt'], variant );
end

