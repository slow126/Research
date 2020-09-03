function d = distll(a,b)
%DISTLL  Earth Surface Distance (km)
%   DISTLL(A,B) is the approximate distance (km) between 
%   points in A([latitude, longitude]) (degrees) and 
%   points in B([latitude, longitude]) (degrees). If A and B are 
%   two-dimensional matrices, DISTLL(A,B) returns a matrix of 
%   values corresponding to all combinations of distances 
%   between A and B. In the returned matrix, row indices 
%   correspond to points in A and column indices correspond to 
%   points in B.  (i.e. d(4,5) = approximate distance between
%   fourth entry of A and the fifth entry of B.) DISTLL(A,B) uses a
%   spherical-earth assumption with R = 6378.7 km.

a = a*pi/180;
b = b*pi/180;
bsize = size(b,1);
asize = size(a,1);

c = a(:,2)*ones(1,bsize) - (ones(asize,1)*b(:,2)');

d = sin(a(:,1))*ones(1,bsize).*(ones(asize,1)*sin(b(:,1))');
d = d + cos(a(:,1))*ones(1,bsize).*(ones(asize,1)*cos(b(:,1))').*cos(c);
d = 6378.7 * acos(d);
