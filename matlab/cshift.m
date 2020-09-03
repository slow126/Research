function out = cshift(in,n)
%
% out = cshift(in,n)
%
% shifts a circulant buffer by n points: out=in(:+n)
% handles positive or negative shifts, even if larger than buffer length

% written by DGL 11/08/08

[M N]=size(in);
flag=0;
% shift is in row-direction by default
if M<N & M==1  % re-orient to shift by columns
  in=in.';
  [M N]=size(in);
  flag=1;
end
l=[1:M]+fix(n);
while ~isempty(find(l<1))
  ind=find(l<1);
  l(ind)=l(ind)+M;
end
while ~isempty(find(l>M))
  ind=find(l>M);
  l(ind)=l(ind)-M;
end
out(l,:)=in;
if flag==1
  out=out.';
end
