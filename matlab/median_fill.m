function out=median_fill(in,nsize,thres)
%
% 2d median fill
%   out=median_fill(in,nsize,thres)    nsize should be odd
%  
%  pixel values less than thres are filled with median of pixel values
%  greater than thres

nsize2=floor(nsize/2);

out=in;

[m n]=size(in);
[r c]=find(in<thres);
for k=1:length(r)
  r1=max([r(k)-nsize2 1]);
  r2=min([r(k)+nsize2 m]);
  c1=max([c(k)-nsize2 1]);
  c2=min([c(k)+nsize2 n]);
  [x y]=meshgrid(r1:r2,c1:c2);
  vals=in(sub2ind(size(in),x,y));
  ind=find(vals>thres);
  if length(ind)>0
    out(r(k),c(k))=median(vals(ind));
  end
end
