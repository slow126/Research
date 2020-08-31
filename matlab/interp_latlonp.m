function [lat_out, lon_out] = interp_latlonp(x,lat,lon,xq,varargin);

% INTERP_LATLONP interpolates a set of latitude and longitude (in deg) 
% coordinates given as a function of x at the xq values by projecting
% the lat/lon values onto a polar stereographic grid where the Earth
% is treated as a sphere and the reference latitude is the pole, 
% interpolating in the grid, using interp1 to interpolate points on
% the polar grid, and inverse projecting grid points back to lat/long
%
% Usage: [lat_out, lon_out] = interp_latlonp(x,lat,lon,xq);
%
% x, lat_in, and lon_in are vectors of the same length
%
% to specify interpolation method used in interp1, use
%
% Usage: [lat_out, lon_out] = interp_latlonp(x,lat,lon,xq,METHOD);
%
% Written by D.G. Long, 11-27-17 

mlat=mean(lat);
if mlat>0
  pol=-90;
else
  pol=90;
end

xv=(lat+pol).*cos(lon*pi/180);
yv=(lat+pol).*sin(lon*pi/180);
if nargin>4
  xx=interp1(x,xv,xq,varargin{1});
  yy=interp1(x,yv,xq,varargin{1});
else
  xx=interp1(x,xv,xq);
  yy=interp1(x,yv,xq);
end
lon_out=atan2(yy,xx)*180/pi;
carg=cos(lon_out*pi/180);
lat_out=zeros(size(lon_out));
lat_out(abs(carg)>=0.5)=xx(abs(carg)>=0.5)./carg(abs(carg)>=0.5)-pol;
lat_out(abs(carg)<0.5)=yy(abs(carg)<0.5)./sin(lon_out(abs(carg)<0.5)*pi/180)-pol;
