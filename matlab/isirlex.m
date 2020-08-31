function [x, y] = isirlex(m,head)
%
%  function [x y] = isirlex(m,head)
%
%	Given (m) locations in matlab lexicographic convention, compute the
%       corresponding (x,y) pixel locations
%	1 <= x < nsx+1 and 1 <= x < nsx+1 then ix=floor(x) iy=floor(y)
%
% INPUTS:
%   n - pixel index location (matlab coordinates)
%   head - header array from load sir
%
% OUTPUTS:
%   x,y  - x,y location of pixels (matlab convention)
%

nsx=head(1);
nsy=head(2);

m1=m(find(m < Inf));

% n=(y1-1)*nsx+x1;     % this is the fortran index
% n=(x1-1)*nsy+y1;     % this is the matlab index

% y=floor((m1-1)/nsx);   % using fortran index
% x=mod(m1-1,nsx)+1;

x=floor((m1-1)/nsy);   % using matlab index
y=mod(m1-1,nsy)+1;



