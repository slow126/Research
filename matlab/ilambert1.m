function [alon, lat]=ilambert1(x,y,orglat,orglon,iopt)
%
% function [lon, lat]=ilambert1(x,y,orglat,orglon,iopt)
%
%	computes the inverse transformation from lat/lon to x/y for the
%	lambert azimuthal equal-area projection
%
%	inputs:
%	 lat	(r): latitude +90 to -90 deg with north positive
%	 lon	(r): longitude 0 to +360 deg with east positive
%			or -180 to +180 with east more positive
%	 orglat	(r): origin parallel +90 to -90 deg with north positive
%	 orglon	(r): central meridian (longitude) 0 to +360 deg
%			or -180 to +180 with east more positive
%	 iopt	(i): earth radius option
%	             for iopt=1 a fixed, nominal earth radius is used.
%	             for iopt=2 the local radius of the earth is used 
%	outputs:
%	 x,y	(r): rectangular coordinates in km
%

%
%	see "map projections used by the u.s. geological survey"
%	geological survey bulletin 1532, pgs 157-173
%
%	for this routine, a spherical earth is assumed for the projection.
%	the error will be small for small-scale maps.  
%	for local radius the 1972 wgs ellipsoid model (bulletin pg 15).

%       vectorized DGL 4/4/98

dtr=3.141592654d0/180.0;
radearth=6378.135d0;	% equitorial earth radius
f=298.26d0;		% 1/f
orglon1=mod(orglon+720.0,360.0);

%
%	compute local radius of the earth at center of image
%

eradearth=6378.0d0;	%  use fixed nominal value
if iopt == 2            %  use local radius
  era=(1.-1./f);
  eradearth=radearth*era/sqrt(era*era*cos(orglat*dtr)^2+sin(orglat*dtr)^2);
end;
x1=x/eradearth;
y1=y/eradearth;
rho=x1.*x1+y1.*y1;
if rho > 0
  rho=sqrt(rho);
  c=2*asin(rho*0.5);
  lat=asin(cos(c).*sin(orglat*dtr)+y1.*sin(c).*cos(orglat*dtr)./rho)/dtr;
else 
  lat=orglat;
end;

lon=0;
if abs(orglat) ~= 90.0 
  if rho == 0
    lon=orglon1;
  else
    t1=x1.*sin(c);
    t2=rho.*cos(orglat*dtr).*cos(c)-y1.*sin(orglat*dtr).*sin(c);
    lon=orglon1+atan2(t1,t2)/dtr;
  end;
elseif orglat == 90.0 
  lon=orglon1+atan2(x1,-y1)/dtr;
else
  lon=orglon1+atan2(x1,y1)/dtr;
end;

lon=mod(lon+720.0,360.0);
if lon > 180 
  lon=lon-360;
end;
alon=lon;


