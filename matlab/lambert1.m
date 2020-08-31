function [x,y]=lambert1(lat,lon,orglat,orglon,iopt)
%
% function [x,y]=lambert1(lat,lon,orglat,orglon,iopt)
%
%	Computes the transformation from lat/lon to x/y for the
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
%	             for iopt=2 the local radius of the earth is used.
%	outputs:
%	 x,y	(r): rectangular coordinates in km

%	see "map projections used by the u.s. geological survey"
%	geological survey bulletin 1532, pgs 157-173
%	for this routine, a spherical earth is assumed for the projection
%	the 1972 wgs ellipsoid model (bulletin pg 15).
%	the error will be small for small-scale maps.  

%       vectorized DGL 4/4/98

radearth=6378.135d0;		% equitorial earth radius
f=298.26d0;			% 1/f wgs 72 model values
dtr=3.141592654d0/180.0d0;

lon1=mod(lon+720.0,360.0);
orglon1=mod(orglon+720.0,360.0);
%
%	compute local radius of the earth at center of image
%
eradearth=6378.0d0;		% use fixed nominal value
if iopt == 2		        % local radius
  era=(1.-1./f);
  eradearth=radearth*era/sqrt(era*era*cos(orglat*dtr).^2+sin(orglat*dtr).^2);
end;
%
denom=1.0+sin(orglat*dtr).*sin(lat*dtr)+ ...
    cos(orglat*dtr).*cos(lat*dtr).*cos(dtr*(lon1-orglon1));
if denom > 0.0 
  ak=sqrt(2.0./denom);
else
  disp(['*** division error in lambert1 routine ***']);
  ak=1.0;
end;
x=ak.*cos(lat*dtr).*sin(dtr*(lon1-orglon1));
y=ak.*(cos(dtr*orglat).*sin(dtr*lat)- ...
    sin(dtr*orglat).*cos(dtr*lat).*cos(dtr*(lon1-orglon1)));
x=x*eradearth;
y=y*eradearth;
