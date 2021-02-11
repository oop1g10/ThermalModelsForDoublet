function y=var(x)
% function V=var(x)
[m,n] = size(x);
if (m == 1) + (n == 1)
    m = max(m,n);
    y = norm(x-sum(x)/m)^2;
else
    avg = sum(x)/m;
    y = zeros(size(avg));
    for i=1:n
        y(i) = norm(x(:,i)-avg(i))^2;
    end
end
if m == 1
    y = 0;
else 
    y = y/(m-1);
end
