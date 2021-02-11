function fx = normdist(x,m,s)

% function fx = normdist(x,m,s)
% 
% calculates the p.d.f. for a normal distribution
% x is variate vector
% m is mean
% s is standard deviation
%
% Matthew Lees, Imperial College London, January 1997
%
% See Chatfield P. 88

fx=(1/(sqrt(2*pi)*s))*exp(-(x-m).^2./(2.*s^2));
