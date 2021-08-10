function [outputArg1,outputArg2] = functionForGavsteh(inputArg1,inputArg2)
%FUNCTIONFORGAVSTEH Summary of this function goes here
%   Detailed explanation goes here
% Parameters:
% ca
% cf
% c1
% c2
% lambdaC
% lambda1
% lambda2
% Tin
% Tm0
% n
% Q
% r0
% b
% b1
% b2
% beta
% Omega is function with in put 'p'

% additional inputs to shorten the formula
% subscript 1
s1 = ((-r + r0)*sqrt(Omega(p)) ) / sqrt(lambdaC);
% subscript 2
s2 = (cf * Q) / (2 * b * pi  * lambdaC);
% variable 1
v1 = cf * Q * beta + 2 * b * pi * r * lamdbaC;
% variable 2
v2 = cf * Q * beta + 2 * b * pi * r0 * lamdbaC;

v3 = sqrt(Omega(p)) / (b*pi*lambdaC^(3/2));
v4 = cf^2 * Q^2 *beta*lambdaC;
v5 = 2*b*pi + cf*Q/lambdaC - cf * Q * beta * sqrt(Omega(p))/lambdaC^3/2;
v6 = cf*Q+2*b*pi*lambdaC;
v7 = cf *Q / (2*b*pi*lambdaC);
v8 = 6*b*pi + cf*Q/lambdaC - cf*Q*beta*sqrt(Omega(p))/lambdaC^(3/2);

% term 1
t1 = cf*e^s1 * Q*Tin*lambdaC * v1^s2 * v2^(1-s2);
Hypergeom_r0 = kummerU(v5/(4*b*pi), (1+s2), (v1 * v3));
t2 = 

end

