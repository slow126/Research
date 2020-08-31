function y = rmean(x,w,t,b);

% function y = rmean(x,w,t,b)
%
% this function computes a running mean average of x
% the centered window width is 2*w+1
% values of x less than t are not included in the running mean and
% but are set to a floor value of b

n=length(x);
y=x;
for k=1:n
 k1=k-w;
 if k1 < 1, k1=1;, end;
 k2=k+w;
 if k2 > n, k2=n;, end;
 s=x(k1:k2);
 tt=s(find(s>t));
 if length(tt) > 1
  y(k) = sum(tt) /length(tt);
 else
  y(k) = b;
 end
end