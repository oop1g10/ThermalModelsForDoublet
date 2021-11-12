clear
plotT = true;
plottb = true; % plot break through time

% v_u is taken from Schulz from scenario b or c
v_u = 1 * 10^-6; % m/sec % scenario B in Schulz
% v_u = 2.5*10^-6; % m/sec % scenario C in Schulz
i = 0.001; % m/m hydraulic gradient Not input of this model
K = v_u / i;  % not taken from Schulz, it does not influence the model results as v_u is given
alpha_deg = 90; %180; % degrees
M = 30;% m
%M = 35; % 30; % m
Q = 0.03; %0.03 ; %   % injected volume flow rate m^3/second
t = 5 * 365*24*60*60; % seconds
a = 400/2; % (m) half of distance between two wells
% Definitions inputs for Temperature calc
n = 0.1; % porosity (-)
%n = 0.27; % 0.1; % porosity (-)
% rw = m  radius of injection well. it is used in schult only to determine 
% if stream line is close to injection and the location to calculate Temperature at abstraction well.
rw = 0.1; % radius of injection well (m)
Cw = 4.2 * 10^6; % Volumetric heat capacity of water J/m^3/K
rho_s = 2600; % kg/m^3
%rho_s = 2670; %2600; % kg/m^3
c_s = 1000; % J/kg/K
%c_s = 850; %1000; % J/kg/K
Cs = rho_s * c_s; % Volumetric heat capacity of solid J/m^3/K
l_s = 2.8; % W/m/K % thermal conductivity of solid rock in aquifer
%l_s = 2.9; %2.8; % W/m/K % thermal conductivity of solid rock in aquifer
T0 = 40 + 273.15; % undisturbed temperature in aquifer (K)
Ti = 25 + 273.15; % injection temperature (K)
N = 600; % number of points x and y to calculate on the streamline 
% prepare mesh
x =  [-600:15:600]; %[1,2];[200, 201] ;
y =  [-600:15:600]; %[3,4];[0, 1]; %
% prepare model boundary limits to stop calculating streamline outside of model boundary
modelBoundary = calc_modelBoundary( x, y );
% x = [-210,-205, -100, -50];
% y = [2,1,-1,-2];
[Xmesh,Ymesh] = meshgrid(x,y);

%% TEST streamline function
x_0 =  [210];%[200, 210];  %[-400:5:400];
y_0 =  [50]; %[-600:5:600];
%% TEST TEST TEST!!! T for extraction well and 1 random point  :)
[T_tphi, t_b] = T_Schulz( [x_0, a], [y_0, 0], t, v_u, K, n, Cw, Cs, l_s, T0, Ti,...
                        alpha_deg, M, Q, a, modelBoundary, N, rw );    
kelvin2DegC(T_tphi)
secondsToYears(t_b)   
(T_tphi(2) - T0) / (Ti - T0); 

% calculate groundwater velocities in x and y direction (in 2D to plot streamlines
[ v_x_test, v_y_test ] = schulz_velocity( 0, 0, v_u, alpha_deg, M, Q, a );
v_test = sqrt(v_x_test.^2 + v_y_test.^2);

%% Temperature calc
if plotT
    [T_tphi, t_b] = T_Schulz( Xmesh, Ymesh, t, v_u, K, n, Cw, Cs, l_s, T0, Ti, ...
                        alpha_deg, M, Q, a, modelBoundary, N, rw );
end
%% calculate hydraulic potential phi
%secondsToDays(I_phi);
phi_xy_mesh = schulz_phi_psi( Xmesh,Ymesh,v_u, K, alpha_deg, M, Q, a );

%% calculate groundwater velocities in x and y direction (in 2D to plot streamlines
[ v_x, v_y ] = schulz_velocity( Xmesh, Ymesh, v_u, alpha_deg, M, Q, a );

%% PLOTS plot hydraulic potential phi and groundwater streamlines
figure
% plot phi
contour( Xmesh, Ymesh, phi_xy_mesh, 30 ) % 'ShowText','on'
ax = gca;
ax.DataAspectRatio = [1,1,1]; %make x and y coordinates square
hold on 
% plot streamlines
streamslice(Xmesh, Ymesh, v_x, v_y)

% Temperature isotherms plot (degC)
if plotT
    contour( Xmesh, Ymesh, kelvin2DegC(T_tphi), [26, 28, 33, 40], ...
                                    'ShowText','on', ...
                                    'LineWidth', 2, 'LineColor', 'black' )
end
if plottb % plot break through time (s)
    contour( Xmesh, Ymesh, secondsToYears(t_b), [0.5, 1, 2, 5, 10, 25], ...
                                    'ShowText','on', ...
                                    'LineWidth', 2, 'LineColor', 'blue' )
end
% Streamline from initial point
for i = 1 : numel(x_0)
    [ x_list, y_list ] = schulz_xy_streamline( N, x_0(i), y_0(i), v_u, K, alpha_deg, M, Q, a, modelBoundary, rw );
    plot(x_list, y_list, 'Color', 'red', 'LineWidth', 2)   
    hold on
end


