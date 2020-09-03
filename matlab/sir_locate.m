function [lon,lat]=sir_locate(head)
%
% function [lon lat]=sir_locate(head)
%
% interactively select a point in an image displayed by showsir
% and return the lat,lon of the point.  The header info from loadsir
% should be passed in as head
%
% to display result nicely: disp(['Lon ',num2str(lon),'   Lat ',num2str(lat)]);

[x y]=ginput(1);
[lon lat]=pix2latlon(x,y,head);
%disp(['Lon ',num2str(lon),'   Lat ',num2str(lat)]);
