function projtest(fname);
%
% matlab code to compute proj and gdal_translate strings and generate a
% geotiff image for a BYU .SIR format file
% Note: geotiff conversion requires that sir2gif, proj4, and gdal_trans be in the path
%


% written by DGL at BYU 16 Apr 2009

% for test purposes
%fname='qush-NHe-a-20090961125-20090972249.ave';
%
[b head]=loadsir(fname);

% extract key projection information from header
nsx=head(1);
nsy=head(2);
orglon=head(3);
orglat=head(4);
ascale=head(6);
bscale=head(7);
a0=head(8);
b0=head(9);
iopt=head(17);
  
% proj info
if iopt==2 | iopt==1  % lambert equal area
  if iopt==1
    Erad=6378.0;
  else
    Erad=6378.135; F=298.26;
    era=(1.-1./F); dtr=0.01745329252;
    Erad=Erad*era/sqrt((era*cos(orglat*dtr))^2+(sin(dtr*orglat))^2);
  end
  % technically we should use +f=0 for this case but gdal_translate does
  % not support it, so we use the secondary line +rf=50000000 instead
  %projstr=sprintf('+a=%.3f +f=0 +proj=laea +lat_0=%f +lon_0=%f',Erad*1000,orglat,orglon);
  projstr=sprintf('+a=%.3f +rf=50000000 +proj=laea +lat_0=%f +lon_0=%f',Erad*1000,orglat,orglon);
  xscale=1/ascale;
  yscale=1/bscale;
  disp(sprintf('Proj string: "%s"',projstr));
elseif iopt==5      % polar stereographic
  Erad=6378.273; E2=0.006693883;
  pole=90;
  if orglat<0
    pole=-90;
  end
  % the first line is the correct one to use but gdal_translate does not
  % support it, so we use the second line instead  (note: correct datum is wgs72)
  %projstr=sprintf('+a=%.3f +e2=%f +proj=stere +lat_ts=%f +lat_0=%f +lon_0=%f',Erad*1000,E2,orglat,pole,orglon);
  projstr=sprintf('+wgs84 +proj=stere +lat_ts=%f +lat_0=%f +lon_0=%f',orglat,pole,orglon);
  xscale=ascale;
  yscale=bscale;
  disp(sprintf('Proj string: "%s"',projstr));
elseif iopt==8 | iopt==9 | iopt==10  % EASE2 grid
  xscale=1.0;
  yscale=1.0;
  disp('have not worked proj4 for EASE2 grid projections')
elseif iopt==11 | iopt==12 | iopt==13  % EASE1 grid
  xscale=1.0;
  yscale=1.0;
  disp('proj4 does not support EASE1 grid projections')
else
  xscale=1/ascale;
  yscale=1/bscale;
  disp('proj4 cannot handle this projection')
end

% compute corner locations

for xx=[0 1]
  ix=1+xx*(nsx-1);
  xc='L'; 
  if xx==1
    xc='U';
  end
  x0=a0+xx*(nsx-1)*xscale;
  
  for yy=[0 1]
    iy=1+yy*(nsy-1);
    yc='L'; 
    if yy==1
      yc='R';
    end
    y0=b0+yy*(nsy-1)*yscale;

    str=sprintf('%c%c',xc,yc);

    % for SIR
    % Matlab vertically flips the pixel locations so we have to account for this in the code
    my=nsy-iy+1;
    [lon, lat]=pix2latlon(ix,my,head);
    [x2, y2]=latlon2pix(lon,lat,head);
    if iopt==0  % rectangular lat/lon projection
       x=(ix-1.0)/ascale+a0;
       y=(iy-1.0)/bscale+b0;
       lon1=x;
       lat1=y;
    elseif iopt==1 | iopt==2  % lambert
      [x, y]=lambert1(lat,lon,orglat,orglon,iopt);
      [lon1, lat1]=ilambert1(x,y,orglat,orglon,iopt);
    elseif iopt==5        % polar stereographic
      [x, y]=polster(lon,lat,orglon,orglat);
      [lon1, lat1]=ipolster(x,y,orglon,orglat);
    elseif iopt==8 | iopt==9 | iopt==10  % EASE2 grid
      [x,y]=ease2grid(iopt,lon,lat,ascale);
      [lat1,lon1]=iease2grid(iopt,x,y,ascale);
      return;
    elseif iopt==11 | iopt==12 | iopt==13  % EASE1 grid
      % some problem with the matlab code
      [x,y]=easegrid(iopt,lon,lat,ascale);
      [lat1,lon1]=ieasegrid(iopt,x,y,ascale);
      return;
    else
      disp(sprintf('*** cannot handle this projection %d',iopt));
      return;
    end

    disp(sprintf('%s %d %d %f %f %f %f',str,ix,iy,x2,y2,ix-x2,iy-y2));
    disp(sprintf('   %f %f  lat,lon=%f %f  %f %f',x0,y0,lon,lat,x-x0,y-y0))
    disp(sprintf('   %f %f  lat,lon=%f %f  %f %f',x,y,lon1,lat1,lon-lon1,lat-lat1))

    if iopt==1 | iopt==2 | iopt==5   % for proj4 comparison
      iname='/tmp/in.lis'; oname='/tmp/out.lis';
      fid=fopen(iname,'w'); fprintf(fid,'%.8f %.8f',lon,lat); fclose(fid);
      cmd=sprintf('proj %s < %s > %s',projstr,iname,oname);
      system(cmd);
      fid=fopen(oname,'r'); [args, narg]=fscanf(fid,'%f %f'); fclose(fid);
      x1=args(1); y1=args(2);
      % for invproj4
      iname='/tmp/in.lis'; oname='/tmp/out.lis';
      fid=fopen(iname,'w'); fprintf(fid,'%.8f %.8f',x1,y1); fclose(fid);
      cmd=sprintf('invproj  %s -f "%%.10f" < %s > %s',projstr,iname,oname);
      system(cmd);
      fid=fopen(oname,'r'); [args, narg]=fscanf(fid,'%f %f'); fclose(fid);
      lon2=args(1); lat2=args(2);
      
      disp(sprintf('   %f %f  lat,lon=%f %f  %f %f',x1/1000,y1/1000,lon1,lat1,lon-lon2,lat-lat2))
    end
    
  end
end

if iopt==1 | iopt==2 | iopt==5   % generate gdal_parameters
  x0=a0;
  x1=a0+(nsx-1)*xscale;
  y0=b0;
  y1=b0+(nsy-1)*yscale;
  gdalstr=sprintf('-a_srs "%s" -a_ullr %f %f %f %f',projstr,x0*1000,y1*1000,x1*1000,y0*1000);
  disp(sprintf('gdal_translate string: %s',gdalstr));

  % create geotiff images
  % firt create gif file
  cmd=sprintf('sir2gifs6 %s %s.gif',fname,fname);
  system(cmd);

  % create gdal_translate command
  cmd=sprintf('gdal_translate %s -of GTiff -co compress=LZW %s.gif %s.tif',gdalstr,fname,fname);
  disp(cmd)

  % create the geotif file
  system(cmd);

end
