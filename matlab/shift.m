function out = shift(x,n)
%
% out = shift(x,n)
%
% shifts a circulant buffer by n points: out=x(:+n)
%

m=length(x);
l=[1:m]+n;
ind=find(l<1);
if ~isempty(ind)
  l(ind)=l(ind)+m;
  ind=find(l<1);
  if ~isempty(ind)
    l(ind)=l(ind)+m;
  end
end
ind=find(l>m);
if ~isempty(ind)
  l(ind)=l(ind)-m;
  ind=find(l>m);
  if ~isempty(ind)
    l(ind)=l(ind)-m;
  end
end

out(l)=x;
