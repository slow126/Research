function [thelon, thelat]=ease2grid(iopt,alon,alat,ascale,bscale)
%
% function [thelon thelat]=ease2grid(iopt,lon,lat,ascale,bscale)
%
%	computes the forward "ease2" grid transform
%
%	given a lat,lon (alat,alon) and the scale (ascale) the image
%	transformation coordinates (thelon,thelat) are comuted
%	using the "ease2 grid" (version 2.0) transformation given in IDL
%	source code supplied by MJ Brodzik
%
%	RADIUS EARTH=6378.137 KM (WGS 84)
%	MAP ECCENTRICITY=0.081819190843 (WGS84)
%
%	inputs:
%	  iopt: projection type 8=EASE2 N, 9-EASE2 S, 10=EASE2 T/M
%	  alon, alat: lon, lat (deg) to convert (can be outside of image)
%          ascale and bscale should be integer valued)
%	  ascale: grid scale factor (0..5)  pixel size is (bscale/2^ascale)
%	  bscale: base grid scale index (ind=int(bscale))
%
%         for definitions of isc and ind see ease2_map_info
%
%	outputs:
%	  thelon: X coordinate in pixels (can be outside of image)
%

% written by D. Long  7 Mar 2014
% revised by D. Long 25 Jan 2015 + vectorized

DTR=0.01745329241994;
ind = round(bscale);
isc = round(ascale);
dlon = alon;
phi = DTR * alat;
lam = dlon;

% get base EASE2 map projection parameters
[map_equatorial_radius_m, map_eccentricity, ...
  e2, map_reference_latitude, map_reference_longitude, ...
  map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
  map_scale, bcols, brows, r0, s0, epsilon] = ease2_map_info(iopt, isc, ind);

dlon = dlon - map_reference_longitude;
dlon(dlon<-180)=dlon(dlon<-180)+360.0;
dlon(dlon<-180)=dlon(dlon<-180)+360.0;
dlon(dlon>180)=dlon(dlon>180)-360.0;
dlon(dlon>180)=dlon(dlon>180)-360.0;
%while dlon<-180.0, dlon=dlon+360.0; end;
%while dlon>180.0, dlon=dlon-360.0; end;
lam = DTR * dlon;
    
sin_phi=sin(phi);
q = ( 1.0 - e2 ) .* ( ( sin_phi ./ ( 1.0 - e2 * sin_phi .* sin_phi ) ) ...
    - ( 1.0 ./ ( 2.0 * map_eccentricity ) ) ...
    .* log( ( 1.0 - map_eccentricity .* sin_phi ) ...
    ./ ( 1.0 + map_eccentricity .* sin_phi ) ) );

switch (iopt)
  case 8   % EASE2 grid north
    qp = 1.0 - ( ( 1.0 - e2 ) / ( 2.0 * map_eccentricity ) ...
	* log( ( 1.0 - map_eccentricity ) ...
	/ ( 1.0 + map_eccentricity ) ) );
%    if abs( qp - q ) < epsilon 
%      rho = 0.0;
%    else
      rho = map_equatorial_radius_m * sqrt( qp - q );
      rho(abs(qp-q)<epsilon)=0.0;
%    end
    x =  rho .* sin( lam );
    y = -rho .* cos( lam );
      
  case 9   % EASE2 grid south
    qp = 1.0 - ( ( 1.0 - e2 ) / ( 2.0 * map_eccentricity ) ...
	* log( ( 1.0 - map_eccentricity ) ...
	/ ( 1.0 + map_eccentricity ) ) );
%    if abs( qp + q ) < epsilon 
%      rho = 0.0;
%    else
      rho = map_equatorial_radius_m * sqrt( qp + q );
      rho(abs(qp-q)<epsilon)=0.0;
%    end
    x = rho .* sin( lam );
    y = rho .* cos( lam );
    
  case 10   % EASE2 cylindrical
    x =   map_equatorial_radius_m * kz * lam;
    y = ( map_equatorial_radius_m * q ) / ( 2.0 * kz );    
    
  otherwise
    error('*** invalid EASE2 projection specificaion in ease2grid');      
end
 
thelon = r0 + ( x / map_scale ) + 0.5; 
thelat = s0 + ( y / map_scale ) + 0.5;

