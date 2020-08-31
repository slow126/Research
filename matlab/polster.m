function [x1, y1]=polster(alon,alat,xlam,slat)
%
% function [x, y]=polster(lon,lat,xlam,slat)
%
%	computes the polar sterographic transformation for a lon,lat
%	input of (alon,alat) with reference origin  lon,lat=(xlam,slat).
%	output is (x,y) in km

%
%	algorithm is the same as used for processing ers-1 sar images
%	as received from m. drinkwater (1994) 
%
%       DGL 4/4/98: vectorized (lon,lat) 
%       DGL 7/14/98: fixed sign error in computing CM

e2=0.006693883d0;
re=6378.273d0;
dtr=3.141592654/180.0;
e=sqrt(e2);
if (slat < 0)
  sn=-1.0;
  rlat=-alat;
else
  sn=1.0;
  rlat=alat;
end;
t=((1.d0-e*sin(rlat*dtr))./(1.d0+e*sin(rlat*dtr))).^(e*0.5d0);
ty=tan(dtr*(45.0d0-0.5d0*rlat))./t;
if (slat < 0) 
  rlat=-slat;
else
  rlat=slat;
end;
t=((1.d0-e*sin(dtr*rlat))./(1.d0+e*sin(dtr*rlat))).^(e*0.5d0);
tx=tan(dtr*(45.0d0-0.5d0*rlat))./t;
cm=cos(dtr*rlat)./sqrt(1.d0-e2*sin(dtr*rlat).^2);
rho=re*cm.*ty./tx;
x1= (sn.*sin(dtr*(sn.*alon-xlam))).*rho;
y1=-(sn.*cos(dtr*(sn.*alon-xlam))).*rho;
