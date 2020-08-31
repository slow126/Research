function writerawimage(a,fname,amin,amax)
%
% function writerawimage(a,fname,amin,amax)
%
% writes the image array a to the file 'fname' one byte per value,
% scaled 0-255 where zero corresponds to amin and 255 to amax
% if [r c]=size(a), image is stored as 
%
fid=fopen(fname,'w');
if fid==0
  error(['*** Can not open output file "' fname '"']);
end

if exist('amin')== 1
  themin=amin;
else
  themin=min(min(a));
end

if exist('amax')== 1
  themax=amax;
else
  themax=max(max(a));
end

b=(a-themin)*255/(themax-themin);
fwrite(fid,b','int8');
fclose(fid);

disp(['Min, max: ', num2str(themin) ',' num2str(themax)]);
[r c]=size(a);
disp(['Size: x=' num2str(c) '  y=' num2str(r)]);
