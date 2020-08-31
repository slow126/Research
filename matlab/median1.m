function out=median1(in,nsize,thres)
%
% 1d median filtering
%   out=median1(in,nsize,thres)
%
%  nsize should be odd
%  values less than thres are not considered in the median filtering

nsize2=floor(nsize/2);

out=zeros(size(in))+thres;
m=length(out);

ind=find(in>thres);
for k=1:length(ind)
  r1=max([ind(k)-nsize2 1]);
  r2=min([ind(k)+nsize2 m]);
  vals=in(r1:r2);
  out(ind(k))=median(vals(find(vals>thres)));
end
