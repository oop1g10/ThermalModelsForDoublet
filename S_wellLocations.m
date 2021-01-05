d12 = 46.87;
d23 = 43.87;
a132 = 72.08; % degrees

a235 = 30.5;
a342 = 34.20;
d25 = 53.34;

a213sinus = (d23 * sin(deg2rad(a132))) / d12;
a213 = rad2deg(asin(a213sinus)); % degrees

a123 = 180 - a132 - a213; 

% law of sines to find side distance d13

d13 = (sin(deg2rad(a123)) * d12) / sin(deg2rad(a132));

% coords for point 3
a32f = 90 - a123;
a23f = 180 - 90 - a32f;
d2f = cos(deg2rad(a32f)) * d23
d3f = sin(deg2rad(a32f)) * d23
d2f^2 + d3f^2 
sqrt(1.9246e+03)
% wells locations
wellsLocations = [0,0; 0,46.87; 31.006, 31.035];
hydraulicHead = [506.6, 503, 504];
scatter(wellsLocations(:,1), wellsLocations(:,2))

% hydraulic heads

%% wells locaiton in Second field
Sd12 = 48.143;
Sd23 = 51.974;
Sd31 = 91.085;
Sa123 = 130.79;

Sd34 = 37.201;
Sd24 = 71.531;
Sa234 = 105.50;

Sa132Cos = (Sd31^2 + Sd23^2 - Sd12^2) / (2* Sd31 * Sd23);

Sa132 = acos(Sa132Cos); % degrees
Sa132 = rad2deg(Sa132);

Sa134 = Sa234 - Sa132;

% side of trinagle 134
Sd14_squared = Sd34^2 + Sd31^2 - 2 * Sd34 * Sd31 * cos(Sa134); 
Sd14 = sqrt(Sd14_squared);

% Sa413
Sa314_sinus = (sin(deg2rad(Sa134)) * Sd34) / Sd14;
Sa314 = asin(Sa314_sinus);
Sa314 = rad2deg(Sa314);

Sa143 = 180 - Sa314 - Sa134;
% a angle, d distance
aABD = 90 - Sa143;
aBAD = 180 - 90 - aABD;

dBD = ( Sd34 / sin(deg2rad(90)) )  * sin(deg2rad(aBAD));

dAD = ( Sd34 / sin(deg2rad(90)) )  * sin(deg2rad(aABD));
