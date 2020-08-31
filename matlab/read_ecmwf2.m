function [w_u,w_v,ecmwf_time]=read_ecmwf2(filename)
% [w_u,w_v,time]=read_ecmwf(filename)
%
% read ECMWF NWP model file
%
% Input: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% filename : the filename of ECMWF file including the directory name.
% %Output: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  w_u : Wind u component
%  w_v : Wind v component
%  time  file time (days since Jan 1, 1958)
% if the file doesn't exist the return w_u and w_v will be -9999.
%
gain=0.01;
if (~isempty(filename)) 
  file = fopen(filename,'r','ieee-be');
  header=fread(file,360,'int16');
  iyear=header(1);
  if iyear>80
    iyear=1900+iyear;
  else
    iyear=2000+iyear;
  end
  imon=header(2);
  iday=header(3);
  ihr=header(4);
  
  %the date num is from jan 1,1958
  ecmwf_time(1)=datenum(iyear,imon,iday)-datenum(1958,1,1);
  ecmwf_time(2)=ihr/100;
  
  %pre-allocate output arrays
  w_u=zeros(360,181);
  w_v=zeros(360,181);
  %read the u component wind field
  for i=1:181
    w_u(:,i)=fread(file,360,'int16')*gain;
  end
  
  %read the v component wind field
  for i=1:181
    w_v(:,i)=fread(file,360,'int16')*gain;
  end
  
  fclose(file);
  
  w_u=w_u';
  w_v=w_v';

end

