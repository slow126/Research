function island = isitland(alat,alon,land,bits,NSX,NSY);

%27.6,277.3 - no !!
%28,277.3 - yes
%28.5,279.3 - no!!
%28,276 - no

if abs(alat)>90
  island=0;
else
  i=round(mod(alon+180.0+360.0,360.0)*100.0+0.5);
  if i<0,i=0;end;
  if i>36000,i=36000;end;
  j=round((alat+90.0)*100.0+0.5);
  if j>18000,j=18000;end;
  if j<0,j=0;end;

  if (j < 0); j=0; end;
  if (j > 17999); j=17999; end;
  if (i < 0); i=0; end;
  if (i > 36000); i=0; end;
  
  k=floor(i/32);
  l=mod(i,32);
  n=j*NSX+k+1;
  if n>length(land)
    error(sprintf('*** land location error encountered %f %f %d %d %d %d',alat,alon,NSX,NSY,n,length(land)));
  end
  ib=bitand(land(n),bits(l+1));

  if (ib ~= 0)
    island = 0;
  else
    island = 1;
  end
end
