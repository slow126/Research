function [w_u,w_v,ncep_time]=read_ncep1(filename)
%
% [w_u,w_v]=read_ecmwf(filename)
% 
% This program will read an NCEP1 file. 
% Input: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% filename : the filename of NCEP1 file including the directory name.
% Output: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  w_u : Wind u component
%  w_v : Wind v component
% ncep_time : time code
%  if the file doesn't exist the return w_u and w_v will be -9999.
%

gain=0.01;
if (~isempty(filename)) 
file = fopen(filename,'r','ieee-be');
header=fread(file,360,'int32');
iyear=header(1);
if iyear>80
    iyear=1900+iyear;
else
    iyear=2000+iyear;
end
imon=header(2);
iday=header(3);
ihr=header(4);
%the date num is also from jan 1,1958,
ncep_time(1)=datenum(iyear,imon,iday)-datenum(1958,1,1);
ncep_time(2)=ihr/100;

w_u=zeros(360,181);
w_v=zeros(360,181);

%read the u component of the wind field
for i=1:181
  w_u(:,i)=(fread(file,360,'int32')*gain);
end

%read the v component of the wind field
for i=1:181
  w_v(:,i)=(fread(file,360,'int32')*gain);
end

fclose(file);

w_u=w_u';
w_v=w_v';

end

