%
% test matlab forward/reverse EASE2 grid transformation
% compare with the output of test_ease2,c
%

%for projt=8:10
for projt=8:8
  iopt=projt;
  isc=0;
  nease=isc;
  ind=0;
  
  % get base EASE2 map projection parameters
  [map_equatorial_radius_m, map_eccentricity, ...
	e2, map_reference_latitude, map_reference_longitude, ...
	map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
	map_scale, bcols, brows, r0, s0, epsilon] = ...
      ease2_map_info(iopt, isc, ind);
  
  nsx=bcols;       % X dim (horizontal=cols) pixels
  nsy=brows;       % Y dim (vertical=rows) pixels
  ascale=nease;    % base grid scale factor (0..5)
  bscale=ind;      % base grid scale index (0..2)
  a0=0.0;          % X origin pixel - 1
  b0=0.0;          % Y origin pixel - 1
  xdeg=(nsx/2.0);  % map center X pixel
  ydeg=(nsy/2.0);  % map center Y pixel

  head=zeros([256 1]);
  head(1)=nsx;
  head(2)=nsy;
  head(17)=iopt;
  head(3)=xdeg;
  head(4)=ydeg;
  head(6)=ascale;
  head(7)=bscale;
  head(8)=a0;
  head(9)=b0;

  for k=0:1
    switch projt
      case 8 % ease2 grid north 
	name='EASE2 N';      
	alon=0.0;
	alat=90.0-k*20;

      case 9  % ease2 grid south
	name='EASE2 S';      
	alon=120.0;
	alat=-90.0+k*20;
    
      case 10 % ease2 grid cylindrical
	name='EASE2 T';      
	alon=0.0;
	alat=25.0-k*10;
    end
    
    [alon alat iopt]
    [x y]=latlon2pix(alon, alat, head);
    y=nsy-y+1;  % convert from matlab coordinates to SIR coordinates
    [ix iy]=f2ipix(x, y, head);
    y1=nsy-y+1;  % convert from SIR to matlab coordinates
    [lon, lat]=pix2latlon(x, y1, head);

    if k==0
      fprintf('\n%d %s ascale=%f bscale=%f a0=%f b0=%f\n           nsx=%d nsy=%d xdeg=%f ydeg=%f\n\n',projt,name,ascale,bscale,a0,b0,nsx,nsy,xdeg,ydeg);
      fprintf('Forward check:\n');
    end
          
    fprintf(' BYU:  (lon,lat) %f %f => %f %f  %d %d ( x,y)\n              => %f %f\n',alon,alat,x,y,ix,iy,lon,lat);
    x=x-1.5;
    y=nsy-y+0.5;
    fprintf(' NSIDC:(lon,lat) %f %f => %f %f\n',alon,alat,x,y);
  end
  
  fprintf('\nInverse check:\n');
    
  for k1=0:2
     for kk=0:2
      x=1.0+k1*(nsx/2)-0.5;
      if k1==2, x=x-1.0; end;	
      if kk>0, x=x+0.5; end;
      y=1.0+k1*(nsy/2)-0.5;
      if k1==2, y=y-1.0; end;
      if kk>1, y=y+0.5; end;

      y2=nsy-y+1;  % convert to matlab coordinates from SIR coordinates
      [lon lat]=pix2latlon(x, y2, head);
      [x1,y1]=latlon2pix(lon, lat, head);
      y1=nsy-y1+1;  % convert from matlab coordinates to SIR coordinates
      [ix,iy]=f2ipix(x, y1, head);
      
      fprintf(' BYU:  (x,y) %6.2f %6.2f => %f %f => %f %f => %d %d\n',x,y,lon,lat,x1,y1,ix,iy);
     end
  end
end