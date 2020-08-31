%fid=fopen('wvcgridsws.dat','r','ieee-be');  % ieee-be is PC
fid=fopen('wvcgridsws.dat','r');
glon=fread(fid,[76,1624],'float');
glat=fread(fid,[76,1624],'float');
fclose(fid);

%lon=reshape(glon,76*1624,1);
%lat=reshape(glat,76*1624,1);
%plot(lon,lat,'.');

ind=find(glon(:,1:700) < 180);  % make lon array continuous
glon(ind)=glon(ind)+360;
clear ind;

[c a]=size(glat);
[x1 y1]=meshgrid(0.5:a-0.5,0.5:c-0.5);
size(x1)
size(glon)

ngrid=10;
[x y]=meshgrid(0:1/ngrid:a-1/ngrid,0:1/ngrid:c-1/ngrid);
size(x)

lat=y*0;
lon=lat;

j=[1:a*ngrid];
at=floor((j-1)/ngrid+1);
for i=1:c*ngrid
  ct=floor((i-1)/ngrid+1);
  lat(i,j)=glat(ct,at);
  xx=x(i,j);
  yy=y(i,j);
  ind=find(xx>=0.5 & xx<= a-0.5 & yy>=0.5 & yy<=c-0.5);
  lat(i,ind)=interp2(x1,y1,glat,xx(ind),yy(ind));
  lon(i,j)=glon(ct,at);
  lon(i,ind)=interp2(x1,y1,glon,xx(ind),yy(ind));
end

size(at)
clear at
clear j
clear ind
clear xx
clear yy

disp('Saving data to files');

fid=fopen('HRgrid_lat_10.dat','w');  % ieee-be is PC
fwrite(fid,lat,'float');
fclose(fid);

ind=find(lon >= 360);   % make lon array 0...360
lon(ind)=lon(ind)-360;
clear ind

fid=fopen('HRgrid_lon_10.dat','w');  % ieee-be is PC
fwrite(fid,lon,'float');
fclose(fid);

figure(1);
%image((64/180)*(lat+90))
image((64/360)*lon)
colorbar;

n=100000;
glon=reshape(lon,76*1624*ngrid*ngrid,1);
glat=reshape(lat,76*1624*ngrid*ngrid,1);
figure(2);
plot(glon(1:n),glat(1:n),'.');





