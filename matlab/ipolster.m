function [alon,alat]=ipolster(x,y,xlam,slat)
%
% function [lon,lat]=ipolster(x,y,xlam,slat)
%
%	computes the inverse polar sterographic transformation for (x,y)
%	given in km with references lon,lat=(xlam,slat).
%	output lon,lat=alon,alat

%
%	algorithm is the same as used for processing ers-1 sar images
%	as received from m. drinkwater (1994).  updated by d. long to
%	improve accuracy using iteration with forward transform.
%
%       vectorized DGL 4/4/98
e2=0.006693883d0;
re=6378.273d0;
pi2=1.570796327d0;
dtr=pi2/90.0d0;
%
%	first use approximate inverse calculation
%
e=sqrt(e2);
e22=e2*e2;
e23=e2*e2*e2;
x1=x;
y1=y;
rho=x1.*x1+y1.*y1;
rho(find(rho >0)) = sqrt(rho(find(rho >0)));
if (rho <0.05)
  alon=xlam;
  alat=sign(90.0,slat);
else
  sn=1.0d0;
  slat1=slat;
  if (slat < 0)
    sn=-1.0d0;
    slat1=-slat;
  end;
  cm=cos(slat1 * dtr)./sqrt(1.0d0-e2*sin(slat1 * dtr).^2);
  t=tan(dtr*(45.0d0-0.5*slat1))./((1.d0-e*sin(slat1*dtr))./(1.d0+e*sin(slat1*dtr))).^(e*0.5d0);
  t=rho.*t./(re.*cm);
  chi=pi2-2.0d0*atan(t);
  t=chi+(0.5d0*e2+5.0d0*e22/24.0d0+e23/12.0d0)*sin(2.0d0*chi)+ ...
      (7.0d0*e22/48.0d0+29.0d0*e23/240.0d0)*sin(4.0d0*chi)+ ...
      (7.0d0*e23/120.0d0)*sin(6.0d0*chi);
  alat=sn.*(t*90.0d0/pi2);
  alon=sn.*atan2(sn.*x1,-sn.*y1)/dtr+xlam;
  alon(find(alon < -180)) = alon(find(alon < -180))+360.0;
  alon(find(alon >  180)) = alon(find(alon >  180))-360.0;
end;
%
%	using the approximate result as a starting point, iterate to improve
%	the accuracy of the inverse solution
%
sn1=1.0;
if (slat < 0)
  sn1=-1.0;
end;
a=atan2(y,x) / dtr;
r=sqrt(x.*x+y.*y);

for icnt=1:20
 [xx, yy]=polster(alon,alat,xlam,slat);
 rr=sqrt(xx.*xx+yy.*yy);
 rerr=sn1.*(rr-r)/180.0d0;
 aa=atan2(yy,xx)/dtr;
 aerr=aa-a;
 aerr(find(abs(aerr)>180)) = 360.0-aerr(find(abs(aerr)>180));

%
%	check for convergence
%
 if (((max(max(abs(rerr))) < 0.001) & (max(max(abs(aerr))) < 0.001)) | (icnt > 9)) 
  if (max(max(abs(alon))) > 360.0)
    alon=mod(alon,360);
  end;
  return
 end;
%
%	constrain updates
%
 alon=alon+aerr;
 if (max(max(abs(alon))) > 360) 
   alon=mod(alon,360);
 end;
 if (alat*slat < 0)
   rerr=rerr.*(1.0d0-sin(dtr*abs(alat)));
   rerr(find(abs(rerr)>2))=sign(2.0,rerr(find(abs(rerr)>2)))/icnt;
   alat=alat+rerr;
   alat(find(abs(alat)>90))=sign(90,alat(find(abs(alat)>90)));
 end;
end;




