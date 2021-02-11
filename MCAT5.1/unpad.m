function y=unpad(x,e,d)
% function y=unpad(x,e,d);
% Removes all elements equal to e from the d end of vector x.
% where d is 'b' (beginning of the vector) or 'e' (end).
y=x;
L=length(y);
[n,m]=size(y);
if all(y==e*ones(n,m)), y=[];return;end
if strcmp(d,'b')
  k=1;
  while y(1)==e
    y=y(2:L-k+1);
    k=k+1;
  end
elseif strcmp(d,'e')
  k=L;
  while y(k)==e
    k=k-1;
    y=y(1:k);
  end
end
