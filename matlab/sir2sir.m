function out=sir2sir(template_head, sir_in, sir_head)
%
%  out=sir2sir(template_head, sir_in, sir_head)
%
% Given a sir input header as a template and a sir image and its header,
% this routine creates a new sir image with the size and projection of the
% template header but using the information in the second header by remapping
% pixels based on the projection.  Caution: routine is slow and requires
% lots of memory
%

m=template_head(2);
n=template_head(1);
[Y X]=meshgrid(1:m,1:n);
X=reshape(X',m*n,1);
Y=reshape(Y',m*n,1);
[lon lat]=pix2latlon(X,Y,template_head);
clear X
clear Y
[X Y]=latlon2pix(lon,lat,sir_head);
clear lon;
clear lat;
X=floor(X);
Y=floor(Y);
M=sir_head(2);
N=sir_head(1);
ind=find(X > 0 & X <= N & Y > 0 & Y <= M);
X=X(ind);
Y=Y(ind);
ind2=sub2ind([M N],Y,X);
clear X
clear Y
ind3=reshape(ind2',length(ind),1);
clear ind2
out=zeros([m n])-template_head(10);  % the no data value
out(ind)=sir_in(ind3);






