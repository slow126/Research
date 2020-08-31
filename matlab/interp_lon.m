function out = interp_lon(x,lon,xq,varargin);

% INTERP_LON interpolates a set of longitude (in deg) values
%
% Usage: out = interp_lon(x,lon,xq)
%
% x and lon are vectors of length N.  function evalutes longitude 
% (in deg -180..180) at points xq using unwrap and interp1
%
% to specify interpolation method used in interp1, use
% out = interp_lon(x,lon,xq,METHOD)
%
% Written by D.G. Long, 11-27-17 

ulon=unwrap(lon*pi/180)*180/pi;
if nargin>3
  out=interp1(x,ulon,xq,varargin{1});
else
  out=interp1(x,ulon,xq);
end
out=mod(out,360);
out(out>180)=out(out>180)-360;
