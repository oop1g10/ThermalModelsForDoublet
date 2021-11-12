
x = 0.1;
y = 0;
t = 120*24*60*60; % (s)
lm = 2.5;   %thermal conductivity of aquifer [W m-1 K-1]
Cw = 4.2E6; %Vol. capacity of water [J m-3 K-1]
Cm = 2.8E6; %Vol. heat capacity of aquifer [J m-3 K-1]
m = 10; % aquifer thickness (m)
q = 1.15741e-5; %m/s (1 m/day)
%5.787E-7; %Specific flux (Darcy flux) [m s-1] equal to 0.05 m/day 
ax = 1;
ay = 0.1;
Q = 0.0003; % water discharge rate (m3/s) = 0.3 litres/second, medium value according to Popphillat et al 2020
T_inj = 295.15; % 22 deg C   % 30 + 273.15; % K
T_0 = 285.15; % 12 deg C  % 0 + 273.15; % K

T = T_LAHM(x,y,t, lm,Cw,Cm,m, q,ax,ay, Q,T_inj,T_0);
T_delta = T - T_0 % in deg celsius