function [land,bits,NSX,NSY] = loadlandmap

landfile='/auto/share/ref/WorldLandBitMap.dat';
disp(['Reading Land Map: ' landfile]);

NSX=(4*9000)/32; NSY=18000;
NRECLEN=NSX*NSY*4;

NX=NSX;
NY=NSY;

for i=1:32
  bits(i) = 2^(i-1);
end

fid=fopen(landfile,'r','ieee-be');
[land,cnt] = fread(fid,inf,'uint32');
fclose(fid);

disp('Done reading land map');

