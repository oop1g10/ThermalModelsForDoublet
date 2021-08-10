% Wahyu Srigutomo (2021). Gaver-Stehfest algorithm for inverse Laplace transform (https://www.mathworks.com/matlabcentral/fileexchange/9987-gaver-stehfest-algorithm-for-inverse-laplace-transform), MATLAB Central File Exchange. Retrieved July 1, 2021.

% https://www.mathworks.com/matlabcentral/fileexchange/9987-gaver-stehfest-algorithm-for-inverse-laplace-transform

%
% testing the gaver-stehfest module
% L is the number of coefficients 
% (examples: L=8, 10, 12, 14, 16, so on..) ONLY EVEN number, and only SINGLE number

% Functions fun1 and fun2 are necessary for this to work

L = 18;

sum=0.0;
for l=1:20
    t(l)=l * 0.1;
    %calcv(l)=gavsteh('fun1',t(l),L);
    calcv(l)= gavsteh_2(L,'fun1',t(l));
    exactv(l)=t(l);
    sum=sum+(1- exactv/calcv)^2;
end
result1=[exactv' calcv' calcv'-exactv']
relerr=sqrt(sum)
%another example
sum=0.0;
for l=1:20
    t(l)=l * 0.1;
    %calcv(l)=gavsteh('fun2',t(l),L);
    calcv(l)=gavsteh_2(L,'fun2', 8, t(l));
    exactv(l)=sin(t(l));
    sum=sum+(1- exactv/calcv)^2;
end
result2=[exactv' calcv' calcv'-exactv']
relerr=sqrt(sum)






