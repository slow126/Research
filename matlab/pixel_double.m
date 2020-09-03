function out = pixel_double(in)
%
% duplicates pixel values to increase size of image by 2
%
[m n]=size(in);
m2=2*m;
n2=2*n;
out=zeros([m2 n2]);
[Y X]=meshgrid(1:m,1:n);
ind=sub2ind([m n],Y,X);

sub=[-1 0];
for x=1:2
  for y=1:2
    ind2=sub2ind([m2 n2],2*Y+sub(y),2*X+sub(x));
    out(ind2)=in(ind);
  end
end
