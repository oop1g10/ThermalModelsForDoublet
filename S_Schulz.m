clear
PlotT = true;
% v_u is taken from Schulz from scenario b or c
v_u = 1*10^-6; % m/sec % scenario B in Schulz
% v_u = 2.5*10^-6; % m/sec % scenario C in Schulz
i = 0.001; % m/m hydraulic gradient Not input of this model
K = v_u / i;  % not taken from Schulz, it does not influence the model results as v_u is given
alpha_deg = 90; %180; % degrees
M = 30; % m
Q = 0.03; %0.03 ; %   % injected volume flow rate m^3/second
t = 3*365*24*60*60; % seconds
a = 400/2 ;% (m) half of distance between two wells
% Definitions inputs for Temperature calc
n = 0.3;
% rw = m  radius of injection well. it is used in schult only to determine 
% if stream line is close to injection and the location to calculate Temperature at abstraction well.
rw = 0.1; % radius of injection well (m)
Cw = 4.2 * 10^6; % Volumetric heat capacity of water J/m^3/K
ro_s = 2600; % kg/m^3
c_s = 1000; % J/kg/K
Cs = ro_s * c_s;
l_s = 2.8; % W/m/K % thermal conductivity of solid rock in aquifer
T0 = 40 + 273.15; % undisturbed temperature in aquifer (K)
Ti = 25 + 273.15; % injection temperature (K)
N = 600; % number of points x and y to calculate on the streamline 
% prepare mesh
x =  [-400:5:400]; %[1,2];
y =  [-600:5:600]; %[3,4];
% x = [-210,-205, -100, -50];
% y = [2,1,-1,-2];
[Xmesh,Ymesh] = meshgrid(x,y);

%% TEST streamline function
x_0 =  [210];%[200, 210];  %[-400:5:400];
y_0 =  [50]; %[-600:5:600];
N = 600;

%% Temperature calc
if PlotT
    T_tphi = T_Schulz( Xmesh, Ymesh, t, v_u, K, n, Cw, Cs, l_s, T0, Ti, alpha_deg, M, Q, a, N, rw );
end
%% calculate hydraulic potential phi
%secondsToDays(I_phi);
phi_xy_mesh = schulz_phi_psi( Xmesh,Ymesh,v_u, K, alpha_deg, M, Q, a );
%% calculate groundwater velocities in x and y direction (in 2D to plot streamlines
[ v_x, v_y ] = schulz_velocity( Xmesh, Ymesh, v_u, alpha_deg, M, Q, a );

%% PLOTS plot hydraulic potential phi and groundwater streamlines
figure
% plot phi
contour( Xmesh, Ymesh, phi_xy_mesh, 20 ) % 'ShowText','on'
hold on 
% plot streamlines
streamslice(Xmesh, Ymesh, v_x, v_y)

% Temperature isotherms plot (degC)
if PlotT
contour( Xmesh, Ymesh, Kelvin2DegC(T_tphi), [26, 28, 33, 40], ...
                                    'ShowText','on', ...
                                    'LineWidth', 2, 'LineColor', 'black' )
end
% Streamline from initial point
% prepare model boundary limits to stop calculating streamline outside of model boundary
[ modelBoundary, maxModelDistance ] = calc_modelBoundary( Xmesh, Ymesh );
for i = 1 : numel(x_0)
    [ x_list, y_list ] = schulz_xy_streamline( N, x_0(i), y_0(i), v_u, K, alpha_deg, M, Q, a, modelBoundary, rw );
    plot(x_list, y_list, 'Color', 'red', 'LineWidth', 2)   
    hold on
end


