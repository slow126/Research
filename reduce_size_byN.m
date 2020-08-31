function out = reduce_size_byN(in,N)
%
% reduces the input array by a factor of N, linearly averaging the pixels
% 
% out = reduce_size_byN(in,N)
%

[m n]=size(in);
m2=floor(m/N);
n2=floor(n/N);
out=zeros([m2 n2]);
[Y X]=meshgrid(1:m2,1:n2);
ind=sub2ind([m2 n2],Y,X);

sub=[1-N:0];
for x=1:N
  for y=1:N
    ind2=sub2ind([m n],N*Y+sub(y),N*X+sub(x));
    out(ind)=out(ind)+in(ind2);
  end
end
out=out/N^2;
