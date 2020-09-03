function flag=inside(x0,y0,px,py,del)
%
% function flag=inside(x0,y0,px,py,<del>)
%
% return 1 if the point (x0,y0) is inside the polygon on on the
% polygon boundary where the polygon is defined by
% the ordered (CCW or CW) set of points (px,py).
% return 0 if not.  Note that the last point of px and py should be
% the same as the first point, i.e. px(end)=px(1), py(end)=py(1)
% del specifies the relative accuracy of the computation, 
% with del=0 <default> exact.  del>0 allows points "close" 
% to the boundary to be included in the polygon. 
%
% algorithm: if point is within polygon then the area of the polygon
% is equal to the sum of the area of all the triangles created by 
% connections to the vertices of the polygon

% written by DG Long at BYU 2/9/2008 + based on BYU DSPLIB routine INSIDEF

del1=0;
if exist('del','var')
  del1=abs(del);
end
flag=0*x0;
if length(px)<4  % (px,py) do not define polygon
  return
end

a1=0;
a2=x0(:)*0;
for i=1:length(px)-1
  a1=a1+px(i)*py(i+1)-px(i+1)*py(i); % poly area
  a2=a2+abs(x0(:)*(py(i)-py(i+1))+...
            y0(:)*(px(i+1)-px(i))+...
            px(i)*py(i+1)-px(i+1)*py(i)); % triangle area
end

ind=find(a2~=0);
if length(ind)>0
  a1=abs(a1);
  a=abs((a1-a2(ind))/a1);
  ind2=find(a<=del1+eps(1));
  flag(ind(ind2))=1;
end
return
