function [alon,alat]=iease2grid(iopt,thelon,thelat,ascale,bscale)
%
% function [alon,alat]=iease2grid(iopt,thelon,thelat,ascale,bscale)
%
%	computes the inverse "ease2" grid transform
%
%	given image (pixel) coordinates (thelon,thelat) the correpsonding
%       lat,lon (alon,alat) are computed 
%	using the "ease2 grid" (version 2.0) transformation given in IDL
%	source code supplied by MJ Brodzik
%
%	RADIUS EARTH=6378.137 KM (WGS 84)
%	MAP ECCENTRICITY=0.081819190843 (WGS84)
%
%	inputs:
%	  iopt: projection type 8=EASE2 N, 9-EASE2 S, 10=EASE2 T/M
%	  thelon: X coordinate in pixels (can be outside of image)
%	  thelat: Y coordinate in pixels (can be outside of image)
%	  alon, alat: lon, lat (deg) to convert (can be outside of image)
%          ascale and bscale should be integer valued)
%	  ascale: grid scale factor (0..5)  pixel size is (bscale/2^ascale)
%	  bscale: base grid scale index (ind=int(bscale))
%
%          NSIDC .grd file for isc=0
%           project type    ind=0     ind=1         ind=3
% 	       N         EASE2_N25km EASE2_N30km EASE2_N36km  
%              S         EASE2_S25km EASE2_S30km EASE2_S36km 
%              T/M       EASE2_T25km EASE2_M25km EASE2_M36km 
%
%          cell size (m) for isc=0 (scale is reduced by 2^isc)
%           project type    ind=0     ind=1            ind=3
%	       N          25000.0     30000.0         36000.0
%              S          25000.0     30000.0         36000.0
%              T/M       T25025.26   M25025.2600081  M36032.220840584
%	      
%	  for a given base cell size isc is related to NSIDC .grd file names
%	     isc        N .grd name   S .grd name   T .grd name
%	      0	      EASE2_N25km     EASE2_S25km     EASE2_T25km  
%	      1	      EASE2_N12.5km   EASE2_S12.5km   EASE2_T12.5km  
%	      2	      EASE2_N6.25km   EASE2_S6.25km   EASE2_T6.25km  
%	      3	      EASE2_N3.125km  EASE2_S3.125km  EASE2_T3.125km  
%	      4	      EASE2_N1.5625km EASE2_S1.5625km EASE2_T1.5625km  
%
%	outputs:
%	  alon, alat: lon, lat location in deg  (can be outside of image)
%

% written by D. Long  7 Mar 2014
% revised by D. Long 25 Jan 2015 + vectorized

RTD=57.29577951308232;
ind = round(bscale);
isc = round(ascale);

% get base EASE2 map projection parameters
[map_equatorial_radius_m, map_eccentricity, ...
  e2, map_reference_latitude, map_reference_longitude, ...
  map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
  map_scale, bcols, brows, r0, s0, epsilon] = ease2_map_info(iopt, isc, ind);

e4 = e2 * e2;
e6 = e4 * e2;

% qp is the function q evaluated at phi = 90.0 deg
qp = ( 1.0 - e2 ) * ( ( 1.0 / ( 1.0 - e2 ) ) ...
    - ( 1.0 / ( 2.0 * map_eccentricity ) ) ...
    * log( ( 1.0 - map_eccentricity ) ...
    / ( 1.0 + map_eccentricity ) ) );

x = (thelon - r0 - 0.5) * map_scale;
y = (thelat - 0.5 - s0) * map_scale;
  
switch (iopt)
  case 8   % EASE2 grid north 
    rho2 = ( x .* x ) + ( y .* y );
    arg=1.0 - ( rho2 / ( map_equatorial_radius_m * map_equatorial_radius_m * qp ) );
    %if arg >  1.0, arg=1.0; end;      
    %if arg < -1.0, arg=-1.0; end;
    arg(arg>1.0)=1.0;
    arg(arg<-1.0)=-1.0;
    beta = asin( arg );
    lam = atan2( x, -y );

  case 9   % EASE2 grid south
    rho2 = ( x .* x ) + ( y .* y );
    arg = 1.0 - ( rho2  / ( map_equatorial_radius_m * map_equatorial_radius_m * qp ) );
    %if arg >  1.0, arg=1.0; end;      
    %if arg < -1.0, arg=-1.0; end;
    arg(arg>1.0)=1.0;
    arg(arg<-1.0)=-1.0;
    beta = -asin( arg );
    lam = atan2( x, y );

  case 10  % EASE2 cylindrical
    arg = 2.0 * y * kz / ( map_equatorial_radius_m * qp ) ;
    %if arg >  1.0, arg=1.0; end;      
    %if (arg < -1.0) arg=-1.0; end;
    arg(arg>1.0)=1.0;
    arg(arg<-1.0)=-1.0;
    beta = asin( arg );
    lam = x / ( map_equatorial_radius_m * kz );

  otherwise
    error('*** invalid EASE2 projection specificaion in iease2grid');      
end

phi = beta ...
    + ( ( ( e2 / 3.0 ) + ( ( 31.0 / 180.0 ) * e4 ) ...
    + ( ( 517.0 / 5040.0 ) * e6 ) ) * sin( 2.0 * beta ) ) ...
    + ( ( ( ( 23.0 / 360.0 ) * e4) ...
    + ( ( 251.0 / 3780.0 ) * e6 ) ) * sin( 4.0 * beta ) ) ...
    + ( ( ( 761.0 / 45360.0 ) * e6 ) * sin( 6.0 * beta ) );
   
alat = RTD * phi;
alon = map_reference_longitude + ( RTD*lam );
%while (alon> 180), alon=alon-360.0; end;
%while (alon<-180), alon=alon+360.0; end;
alon(alon>180)=alon(alon>180)-360.0;
alon(alon>180)=alon(alon>180)-360.0;
alon(alon<-180)=alon(alon<-180)+360.0;
alon(alon<-180)=alon(alon<-180)+360.0;


