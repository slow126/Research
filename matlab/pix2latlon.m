function [alon, alat]=pix2latlon(x,y1,head)
%
% function [lon, lat]=pix2latlon(x,y,head)
%
%	Given an image pixel location (x,y) (1..nsx,1..nsy)
%	computes the lat,lon coordinates (lon,lat).   The lat,lon returned 
%	corresponds to the lower-left corner of the pixel.  (Note
%       that is the upper-left in matlab image coordinates).  If lat,lon
%	of pixel center is desired use (x+0.5,y+0.5) where x,y are integer
%	valued pixels
%
%	Note:  while routine will attempt to convert any (x,y)
%	values, only (x,y) values with 1 <= x <= nsx+1 and 1 <= y <= nsy+1
%	are contained within image.
%
% INPUTS:
%   x,y - input pixel location (matlab coordinates y_matlab=nxy-y_sir+1)
%   head - header array from loadsir
%
% OUTPUTS:
%   lon,lat - longitude, latitude
%

% revised by dgl 15 Sep 2005 + corrected EASE computation
% revised by dgl  7 Mar 2014 + added EASE2

nsx=head(1);
nsy=head(2);
iopt=head(17);
xdeg=head(3);
ydeg=head(4);
ascale=head(6);
bscale=head(7);
a0=head(8);
b0=head(9);

y=nsy-y1+1;    % convert from matlab coordinates to SIR coordinates

if iopt == -1		         % image only (can't transform!)
 thelon=(x-1.0)/ascale+a0;
 thelat=(y-1.0)/bscale+b0;
 alon=thelon;
 alat=thelat;
elseif iopt == 0                 % rectalinear lat/long
 thelon=(x-1.0)/ascale+a0;
 thelat=(y-1.0)/bscale+b0;
 alon=thelon;
 alat=thelat;
elseif (iopt == 1) | (iopt == 2) % lambert
 thelon=(x-1.0)/ascale+a0;
 thelat=(y-1.0)/bscale+b0;
 [alon,alat]=ilambert1(thelon,thelat,ydeg,xdeg,iopt);
elseif iopt == 5                 % polar stereographic
 thelon=(x-1.0)*ascale+a0;
 thelat=(y-1.0)*bscale+b0;
 [alon,alat]=ipolster(thelon,thelat,xdeg,ydeg);
elseif (iopt == 8) | (iopt == 9) | (iopt == 10) %  EASE2
 thelon=x-1.0+a0;
 thelat=y-1.0+b0;
 [alon,alat]=iease2grid(iopt,thelon,thelat,ascale,bscale);
elseif (iopt == 11) | (iopt == 12) | (iopt == 13) %  EASE1
 thelon=x-1.0+a0;
 thelat=y-1.0+b0;
 [alon,alat]=ieasegrid(iopt,thelon,thelat,ascale);
else
 disp(['*** unknown SIR transformation']);
 alon=0;
 alat=0;
end;






