function out = reduce_size_by2(in)
%
% reduces the input array by a factor of two, averaging the pixels
%
[m n]=size(in);
m2=floor(m/2);
n2=floor(n/2);
out=zeros([m2 n2]);
[Y X]=meshgrid(1:m2,1:n2);
ind=sub2ind([m2 n2],Y,X);

sub=[-1 0];
for x=1:2
  for y=1:2
    ind2=sub2ind([m n],2*Y+sub(y),2*X+sub(x));
    out(ind)=out(ind)+in(ind2);
  end
end
out=out/4;