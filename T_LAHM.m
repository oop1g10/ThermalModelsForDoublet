function T = T_LAHM(x,y,t, lm,Cw,Cm,m, q,ax,ay, Q,T_inj,T_0)
% Analytical solution for 2D : Linear Advective Heat transport Model (LAHM)
% ASSUMED
% Zero thermal dispersion and Zero hydraulic influence of a well                                    
% Formula taken from Stauufer 2014 textbook, formula 3.138 page 158
% Stauffer, F., Bayer, P., Blum, P., Giraldo, N.M. and Kinzelbach, W., 2013. Thermal use of shallow groundwater. CRC Press.
% authors of analytical solution (Keim and Lang 2008) in stauffer 2014 textbook

% coded by Oleksandra Pedchenko on 27 January 2020
%                                                                         
%--Nomenclature-----------------------------------------------------------%
% T_0 - initial temperature (deg C)
% T_inj - Injection temerpature (deg C)
% t - simulation time (seconds)
% Q = water discharge rate (m3/s)
% Cw - Vol. capacity of water [J m-3 K-1]
% Cm - volumetric heat capacity of the porous medium [J/m3/K] 
% m - aquifer thickness (m)

% q: Specific flux (Darcy flux) [m s-1]
% ax - longitudinal thermal dispersivity (in textbook Stauffer ?_L) (m)
% ay - transverse thermal dispersivity (in textbook Stauffer ?_T) (m)
% vT - heat transport velocity which equals to q * Cw/Cm, units [m/s], where q is Specific groundwater flux [m s-1] (i.e. Darcy flux m3/m2/s)
% x, y, z - Cartesian coordinates (m)
% r - defined separately in formula to be used in analytical solution , r = sqrt( x^2 +  y^2 * Dx / Dy );
%     Dx = Dt + ax * vT; % Thermal dispersion coefficient in vertical direction
%     Dy = Dt + ay * vT; % abd in transverse direction
%     Dt = lm/Cm;     % thermal diffusivity [m2/s]
% lm: bulk thermal conductivity [W/m/K]


% preliminary definitions with formulas:
    vT = q * Cw/Cm; % Heat transport velocity [m/s]    
    Dt = lm/Cm;     % thermal diffusivity [m2/s]
    Dx = Dt + ax * vT; % Thermal dispersion coefficient in vertical direction
    Dy = Dt + ay * vT; % abd in transverse direction

    % Allow list of x, y, or t values, but not x,y and t list together
    % For number in x list >1, y can be one value or the same number for y list is required
    % ie. x,y pairs
    iters = max([ numel(x), numel(y), numel(t) ]); % select number of cycles based on maximal numel of list
    T = zeros(1, iters);
    % For larger computations use paralel loop to speed up calculation
    if iters > 1000000 % iters 10, do nto use parfor to enable debuging
        parfor i = 1:iters %parallel loop
            %Calculate temperature change
            T(i) = calcT_LAHM(i,x,y,t, Cm,Cw,m, ax,ay,vT,Dx,Dy,  Q,T_inj,T_0);                                  
        end
    else
        for i = 1:iters %normal loop
            %Calculate temperature change
            T(i) = calcT_LAHM(i,x,y,t, Cm,Cw,m, ax,ay,vT,Dx,Dy,  Q,T_inj,T_0); 
        end
    end
    % convert T list into matrix with rows for x coordinate and columns for
    % y coordinate for x and y pairs only
    if size(x,2)>1 && size(y,1)>1
        T = reshape(T, size(y,1), size(x,2));
    end
end
%Calculate temperature change - main calculation put to function
%so it can be called in parallel or normal loop
function T = calcT_LAHM(i,x,y,t, Cm,Cw,m, ax,ay,vT,Dx,Dy,  Q,T_inj,T_0)
    if numel(x) > 1 %If more values for x
        xval = x(i); %use i-th value
    else
        xval = x;
    end
    if numel(y) > 1
        yval = y(i);
    else
        yval = y;
    end
    if numel(t) > 1
        tval = t(i);
    else
        tval = t;
    end

     %--Analytical solution------------------------------------------------%
    % Temperature change at certian time and distance from well whcih can be aplied for open loop system with fast groudnwater flow.

    p1 = Q * Cw * (T_inj - T_0);
    p2 = 4 * m * Cm * sqrt(pi * ay) * vT;
    
    r = sqrt( x^2 +  y^2 * Dx / Dy );
    p3 = exp((x - r)/(2 * ax));
    
    p4 = 1/sqrt(r);
    
    p5 = erfc( (r - vT * t) / (2 * sqrt(vT * ax * t) ) );
    
    T = T_0 + (p1 / p2) * p3 * p4 * p5;
    
    if any(isnan(T)) || any(T == Inf) || any(T == -Inf)
        warning('T_LAHM temperature not found')
    end

end


