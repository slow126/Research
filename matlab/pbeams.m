function pbeams(d,count,order)
%
% function pbeams(d,cout,order)
%
% plots all 8 beams 
%

clg;

for b=1:8
 k=(b-1)*2+1;

 bb=b+1;
 if floor(b/2) == b/2
  bb=bb-2;
 end
 subplot(4,2,bb)

 [ant pol ipol bname] = ant_decode(b);

 hold on;

 if count(k) > 1

  plot(d(1:count(k),k),d(1:count(k+1),k+1),'.')

  if order > -1 
   mninc=min(d(1:count(k),k));
   mxinc=max(d(1:count(k),k));
   inc=mninc:mxinc;

   [p S]=polyfit(d(1:count(k),k),d(1:count(k+1),k+1),order);
   curve=polyval(p,inc);

   ptype=type_string(k);
   plot(inc,curve,ptype)
  end

 end

 title(bname)

end;

hold off

	
