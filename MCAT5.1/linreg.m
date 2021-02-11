function [a,R2,P,Pse,yhat,e]=linreg(y,x)

% function [a,R2,P,Pse,yhat,e]=linreg(y,x)
%
% linear regression
%
% inputs
%
%  y - dependent variables (vector)
%  x - independent variables (matrix)
%
% outputs
%
%  a - parameters [inv(x'*x)*(x'*y)]
%  R2 - correlation coeficient
%  P - parameter covariance matrix [inv(x'x)*var(e)]
%  Pse - Percentage standard errors
%  yhat - model output
%  e - residuals
%
% Matthew Lees, Imperial College London, November 1999

[m,n] = size(x);
a=(x'*x)\(x'*y);
P=(x'*x)\eye(n);
yhat=x*a;
e=y-yhat;
P=P*cov(e);
Pse=(sqrt(diag(P))./abs(a))*100;
R2=1-cov(e)/cov(y);