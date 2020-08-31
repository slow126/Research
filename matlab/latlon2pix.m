function [x, y] = latlon2pix(alon,alat,head)
%
%  function [x, y] = latlon2pix1(lon,lat,head)
%
%	Convert a lat,lon coordinate (lon,lat) to an image pixel location
%	(x,y) (in floating point, matlab convention).
%	To compute integer pixel indices (ix,iy): check to insure
%	1 <= x < nsx+1 and 1 <= x < nsx+1 then ix=floor(x) iy=floor(y)
%
% INPUTS:
%   lon,lat - longitude, latitude
%   head - header array from load sir
%
% OUTPUTS:
%   x,y - pixel location (matlab coordinates y_matlab=nxy-y_sir+1)
%

nsx=head(1);
nsy=head(2);
iopt=head(17);
xdeg=head(3);
ydeg=head(4);
ascale=head(6);
bscale=head(7);
a0=head(8);
b0=head(9);

if iopt == -1		    % image only (can't transform!)
 x=ascale*(alon-a0)+1.0;
 y=bscale*(alat-b0)+1.0;
elseif iopt == 0	            % rectalinear lat/long
 thelon=alon;
 thelat=alat;
 x=ascale*(thelon-a0)+1.0;
 y=bscale*(thelat-b0)+1.0;
elseif (iopt == 1) | (iopt == 2) % lambert
 [thelon thelat]=lambert1(alat,alon,ydeg,xdeg,iopt);
 x=(thelon-a0)*ascale+1.0;
 y=(thelat-b0)*bscale+1.0;
elseif iopt == 5             % polar stereographic
 [thelon thelat]=polster(alon,alat,xdeg,ydeg);
 x=(thelon-a0)/ascale+1.0;
 y=(thelat-b0)/bscale+1.0;
elseif (iopt == 8) | (iopt == 9) | (iopt == 10)  % EASE2
 [thelon thelat]=ease2grid(iopt,alon,alat,ascale,bscale);
 x=thelon+1.0-a0;
 y=thelat+1.0-b0;
elseif (iopt == 11) | (iopt == 12) | (iopt == 13)  % EASE1
 [thelon thelat]=easegrid(iopt,alat,alon,ascale);
 x=thelon+1.0-a0;
 y=thelat+1.0-b0;
else 
  disp(['*** unknown SIR transformation']);
end;

y=nsy-y+1;    % convert from matlab coordinates to SIR coordinates










