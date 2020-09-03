function [thelon, thelat]=easgrid(iopt,alat,alon,ascale)
%
% function [thelon thelat]=easgrid(iopt,lat,lon,ascale)
%
%	computes the forward "ease" grid transform
%
%	given a lat,lon (alat,alon) and the scale (ascale) the image
%	transformation coordinates (thelon,thelat) are comuted
%	using the "ease grid" (version 1.0) transformation given in fortran
%	source code supplied by nsidc.
%
%	the radius of the earth used in this projection is imbedded into
%	ascale while the pixel dimension in km is imbedded in bscale
%	the base values are: radius earth= 6371.228 km
%			     pixel dimen =25.067525 km
%	then, bscale = 2*(base_pixel_dimen)
%	      ascale = 4*(base_radius_earth)
%
%	these values are set in the loadsir routine
%
%	iopt is ease type: iopt=11=north, iopt=12=south, iopt=13=cylindrical
%
pi2=1.57079633d0;
dtr=pi2/90.0d0;

if iopt == 11		% ease grid north
  thelon= ascale*sin(alon*dtr)*sin(dtr*(45.0-0.5*alat));
  thelat=-ascale*cos(alon*dtr)*sin(dtr*(45.0-0.5*alat));
elseif iopt == 12	% ease grid south
  thelon=ascale*sin(alon*dtr)*cosd(dtr*(45.0-0.5*alat));
  thelat=ascale*cos(alon*dtr)*cosd(dtr*(45.0-0.5*alat));
elseif iopt == 13 	% ease cylindrical
  thelon=ascale*pi2*alon*cos(30.0*dtr)/90.0;
  thelat=ascale*sin(alat*dtr)*cos(30.0*dtr);
end;
