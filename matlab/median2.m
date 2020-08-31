function out=median2(in,nsize,thres)
%
% 2d median filtering
%   out=median2(in,nsize,thres)
%
%  nsize should be odd
%  values less than thres are not considered in the median filtering

nsize2=floor(nsize/2);

out=zeros(size(in))+thres;

[m n]=size(in);
[r c]=find(in>thres);
for k=1:length(r)
  r1=max([r(k)-nsize2 1]);
  r2=min([r(k)+nsize2 m]);
  c1=max([c(k)-nsize2 1]);
  c2=min([c(k)+nsize2 n]);
  [x y]=meshgrid(r1:r2,c1:c2);
  vals=in(sub2ind(size(in),x,y));
  out(r(k),c(k))=median(vals(find(vals>thres)));
end
