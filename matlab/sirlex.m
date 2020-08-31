function [n, m] = sirlex(x,y,head)
%
%  function [n m] = sirlex(x,y,head)
%
%	Given (x,y) locations in matlab convention, compute the 
%       lexicographic index n of the SIR image array pixels that
%       correspond to the same point.  Points outside of the array
%       have NaN returned.  The array m has such points edited out.
%	1 <= x < nsx+1 and 1 <= x < nsx+1 then ix=floor(x) iy=floor(y)
%
% INPUTS:
%   x,y  - x,y location of pixels (e.g., output of latlon2pix - matlab)
%   head - header array from load sir
%
% OUTPUTS:
%   n - pixel index location (matlab coordinates)
%   m - pixel index location (matlab coordinates) [valid points only]
%

nsx=head(1);
nsy=head(2);
y1=y;

%y1=nsy-y1+1;    % convert from matlab coordinates to SIR coordinates

y1=floor(y);
x1=floor(x);

x1(find(x>nsx | x < 1))=NaN;
y1(find(y>nsy | y < 1))=NaN;

% n=(y1-1)*nsx+x1;   % this is the fortran index

n=(x1-1)*nsy+y1;     % this is the matlab index
m=n(find(n < Inf));




