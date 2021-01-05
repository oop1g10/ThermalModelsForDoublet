% Wells locations and potentiometric surface on the field estimauville
% ABC are wells for water level measurement 5 m deep
% wells 1 and 3 are observation wells

% Full Depth (fd) of the well from well top to bottom
fdA = 6.10;
fdB = 5.90;
fdC = 6.07;

%% Calculation of hydraulic head
wellname = {'A'; 'C'; '1'; '3'}; %'B'
wsDepth = struct();

% Depths from well top to water surface - depthToptoWaterLevel
dA = 4.265; % upstream
%dB = 2.765; % 
dC = 4.10; % near broadwalk
d1 = 4.115;
d3 = 4.06; 
depthToptoWaterLevel = [dA; dC; d1; d3]; 

% Distance from the laser to the top of the well (lA, lB, lC)
lA = 0.89; % m
%lB = 1.125; % m
lC = 1.08; % m
l1 = 1.035;
l3 = 1.11;
distanceLaserToWellTop = [lA; lC; l1; l3]; %lB

HydrHeadTab = table( depthToptoWaterLevel, distanceLaserToWellTop, 'RowNames', wellname );


% Calculate depth from laser to the water surface (depthLaserToWs)
depthLaserToWaterSurf = - HydrHeadTab.distanceLaserToWellTop - HydrHeadTab.depthToptoWaterLevel;
HydrHeadTab.depthLaserToWaterSurf = depthLaserToWaterSurf;

% hydraulic head calculation
AquiferDepth = 30;
dA_depthLaserToWaterSurf = abs(depthLaserToWaterSurf(1) - depthLaserToWaterSurf(2));
dC_depthLaserToWaterSurf = abs(depthLaserToWaterSurf(3) - depthLaserToWaterSurf(2));
d1_depthLaserToWaterSurf = abs(depthLaserToWaterSurf(4) - depthLaserToWaterSurf(2));
d3_depthLaserToWaterSurf = abs(depthLaserToWaterSurf(5) - depthLaserToWaterSurf(2));
Hh_A = AquiferDepth - dA_depthLaserToWaterSurf;
Hh_B = AquiferDepth;
Hh_C = AquiferDepth - dC_depthLaserToWaterSurf;
Hh_1 = AquiferDepth - d1_depthLaserToWaterSurf;
Hh_3 = AquiferDepth - d3_depthLaserToWaterSurf;

HydrHeadTab.Hh = [Hh_A; Hh_B; Hh_C; Hh_1; Hh_3];

%% well locations
% distances between wells
d3A = 12.621; % m
d31 = 9.901;
dA1 = 11.87;
dAB = 25.280;
d1B = 14.203;
dCB = 18.686;
dC1 = 16.823;
dCA = 26.541;
dC3 = 15.415;

Cxy = [0, 0];
Bxy = [1.125, 0];
% calc triangle CDA
% Axy = 
CA = 26.541; % m
% find angle DCA (aDCA);
aDCB = 90; % degrees
% a1CB = 
a1CB_cos = (dCB^2 + dC1^2 - d1B^2) / (2 * dCB * dC1);
a1CB_rad = acos(a1CB_cos); % radians
a1CB = rad2deg(a1CB_rad); % degrees
% a1C3
a1C3_cos = (dC1^2 + dC3^2 - d31^2) / (2 * dC1 * dC3);
a1C3_rad = acos(a1C3_cos); % radians
a1C3 = rad2deg(a1C3_rad); % degrees
% angle DC3
aDC3 = 90 - a1CB - a1C3;
% a3CA
a3CA_cos = (dC3^2 + dC3^2 - d31^2) / (2 * dC1 * dC3);
a1C3_rad = acos(a1C3_cos); % radians
a1C3 = rad2deg(a1C3_rad); % degrees



