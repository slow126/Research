function out=area_poly(x,y)
%
% function out=area_poly(ix,iy)
%
% compute area of polygon defined by vertex list (ix,iy)
% polygon need not be convex and last point can be same as first

% written by DG Long at BYU 2/9/2008 + based on BYU DSPLIB routine AREAF

out=0;
if length(x)<4  % (x,y) does not define polygon
  return
end

out=x(end)*y(1)-x(1)*y(end);
for i=1:length(x)-1
  out=out+x(i)*y(i+1)-x(i+1)*y(i); % poly area
end
out=abs(out)/2;