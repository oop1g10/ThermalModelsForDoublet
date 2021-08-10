% Colin Brosseau (2021). Inverse Laplace transform by Gaver-Stehfest algorithm (https://www.mathworks.com/matlabcentral/fileexchange/36517-inverse-laplace-transform-by-gaver-stehfest-algorithm), MATLAB Central File Exchange. Retrieved July 1, 2021.

% https://www.mathworks.com/matlabcentral/fileexchange/36517-inverse-laplace-transform-by-gaver-stehfest-algorithm

function ilt = gavsteh_2(L,funname,varargin)
%  ilt = gavsteh_param(L,funname,varargin);
%
%Calculates the value of funname(t) given its Inverse Laplace Transform funname(s)
%
%Input
%    L   	number of coefficient ---> depends on computer word length used
%                   	(examples: L=8, 10, 12, 14, 16, so on..)
%    funname    the name of the function to be transformed.
%    varargin	the following parameters will be directly passed to funname
%			t = varargin{end} is the time at with we want to calculate the inverse Laplace Transform
%
%Output
%    ilt       	The value of the inverse transform at time t
%
%  Wahyu Srigutomo
%  Physics Department, Bandung Institute of Tech., Indonesia, 2006
%  Numerical Inverse Laplace Transform using Gaver-Stehfest method
%  Initial function that can be found at
%  http://www.mathworks.com/matlabcentral/fileexchange/9987
% 
%  Colin-N. Brosseau
%  Departement de Physique, Universite de Montreal, Canada, 2008
%  Modification to use an arbritary function and their parameters
%
%References:
% 1. Villinger, H., 1985, Solving cylindrical geothermal problems using
%   Gaver-Stehfest inverse Laplace transform, Geophysics, vol. 50 no. 10 p.
%   1581-1587
% 2. Stehfest, H., 1970, Algorithm 368: Numerical inversion of Laplace transform,
%    Communication of the ACM, vol. 13 no. 1 p. 47-49
%

    t = varargin{end};
    t = t(:);
    nn2 = L/2;
    for n = 1:L
        z = 0.0;
        for k = floor( ( n + 1 ) / 2 ):min(n,nn2)
            z = z + ((k^nn2)*factorial(2*k))/ ...
                (factorial(nn2-k)*factorial(k)*factorial(k-1)* ...
                factorial(n-k)*factorial(2*k - n));
        end
        v(n)=(-1)^(n+nn2)*z;
    end
    somme = zeros(size(t));
    ln2_on_t = log(2.0) ./ t;
    for n = 1:L
        p = n * ln2_on_t;
        somme = somme + v(n) * feval(funname,varargin{1:end-1},p);
    end
    ilt = somme .* ln2_on_t;
end