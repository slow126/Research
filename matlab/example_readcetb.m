%
% sample matlab routine to read and display the contents of
% a CETB .nc file
%
filename='/home/long/src/linux/mymeasures/src/cetb2sir/examples/NSIDC-0630-EASE2_N25km-AQUA_AMSRE-2009273-36V-E-GRD-RSS-v1.0.nc';
%
% read cetb file
cetb=readcetb(filename,0);  % all
%cetb=readcetb(filename,1);  % TB only

% display file using .SIR tool
myfigure(1);clf 
showsir(cetb.TB,cetb.tb_head)
title('TB')

myfigure(2);clf 
showsir(cetb.TB_num,cetb.tb_num_head)
title('TB\_num')

myfigure(3);clf 
showsir(cetb.TB_inc,cetb.tb_inc_head)
title('TB\_inc')

myfigure(4);clf 
showsir(cetb.TB_std,cetb.tb_std_head)
title('TB\_std')

myfigure(5);clf 
showsir(cetb.TB_time,cetb.tb_time_head)
title('TB\_time')

myfigure(5)
% draw a box in lat lon
lat=[65 85 85 65 65];
lon=[-50 -50 -30 -30 -50];
% convert lat/lons to pixel location
[X1,Y1]=latlon2pix1(lon,lat,cetb.tb_head);
% plot box in pixel coordinates
hold on;
plot(X1,Y1,'r');
hold off;

if 0 % illustrate lat/lon grid conversion of entire grid
  % generate arrays of lat/lon for the center of each pixel in grid
  nsx=sirheadvalue('nsx',cetb.tb_head);
  nsy=sirheadvalue('nsy',cetb.tb_head);  
  x=(1:nsx)-0.5;  % center
  y=(1:nsy)-0.5;
  x=(1:nsx)-0.5;  % LLC
  y=(1:nsy)-0.5;
  [X,Y]=meshgrid(x,y);
  [lon,lat]=pix2latlon(X,Y,cetb.tb_head);
  
  % convert lat/lons to pixel location
  [X1,Y1]=latlon2pix1(lon,lat,cetb.tb_head);
end