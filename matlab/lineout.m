%
%  mexfunction [indices xlist ylist]=lineout(x1,y1,x2,y2,NX,NY,res)
%
% Returns a list of addresses within a NX by NY image for a line 
% drawn between the pixels (x1,y1) and (x2,y2) in matlab lexicographic 
% order: indices=xlist+ylist*NY+1.  Units of (x1..y2) are pixels and 
% they can be outside of the image area.  If the line segment does not 
% intersect the region, the output will be an empty matrices.  xlist 
% and ylist are optional outputs.  res (>=1) controls the resolution
% of the line.
% 
% usage example:  
%  im=zeros([NX,NY]);
%  [ind,x,y]=lineout(x1,y1,x2,y2,NX,NY,10);
%  im(ind)=1.0;
%  image(im*32);
%
% note that im(ind) is equivalent to 
% for i=1:length(x)
%  im(x(i),y(i))=2;
% end
%
