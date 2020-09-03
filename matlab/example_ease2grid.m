%
% example of how to use ease2 grid code
%
% written by D.G. Long 14 Oct 2014

% select a particular MEASURES EASE2 grid

% choose 1
iopt=8;  % EASE2 N
%iopt=9;  % EASE2 S
%iopt=10; % EASE2 T

ind=0;   % all MEASURES projections use this

% select one
isc=0;   % 25 km grid
%isc=1;   % 12.5 km grid
%isc=2;   % 6.25 km grid
%isc=3;   % 3.125 km grid
%isc=4;   % 1.5625 

% get key map parameters (only images size needed)
[map_equatorial_radius_m, map_eccentricity, ...
      e2, map_reference_latitude, map_reference_longitude, ...
      map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
      map_scale, bcols, brows, r0, s0, epsilon]=ease2_map_info(iopt,isc,ind);

% retained parameters
nsx=bcols;
nsy=brows;
ascale=isc;
bscale=ind;
[nsx nsy ascale bscale]

% generate arrays of lat/lon for the center of each pixel in grid
x=(1:nsx)-0.5;
y=(1:nsy)-0.5;
[X,Y]=meshgrid(x,y);

[lon,lat]=iease2grid(iopt,X,Y,ascale,bscale);

figure(1)
imagesc(lon)
colorbar;

figure(2)
imagesc(real(lat))
colorbar;

alat=lat(1,1);
alon=lon(1,1);

% convert lat/lon to pixel location
[X1,Y1]=ease2grid(iopt,alon,alat,ascale,bscale)

figure(3)
imagesc(X);colorbar
figure(4)
imagesc(Y);colorbar

[X1,Y1]=ease2grid(iopt,lon,lat,ascale,bscale);
max(max(abs(X1-X)))
max(max(abs(Y1-Y)))
figure(5)
imagesc(X1);colorbar
figure(6)
imagesc(Y1);colorbar

