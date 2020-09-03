function DTL = LandDist(lat,lon)
%function DTL = LandDist(lat,lon)
%   Distance to land calculator
%
%   Returns a 1 byte integer value corresponding to 
%   a relative distance to land measure. Uses Dr. Long's 
%   'WorldLandDistMap.dat' file for land distance determination.

DTLFileName = '/auto/share/ref/WorldLandDistMap.dat';
NSX2_coast = 36000;

n=floor(mod(lon+180,360)*100+0.5);
m=floor((lat+90.0)*100.0+0.5);

n(n<0)=0;
n(n>35999)=0;
m(m<0)=0;
m(m>17999)=17999;

k = m*NSX2_coast+n;
DTL=lat*0;

DTLfileID = fopen(DTLFileName,'r');
for n=1:length(lat)
  if k(n)>0
    fseek(DTLfileID,k(n),-1);
    DTL(n) = fread(DTLfileID,1,'uchar');
  end
end
fclose(DTLfileID);
