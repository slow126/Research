function [u,v]=col_ecmwf5(time,lat,lon)
%
% [u,v]=col_ecmwf(time,lat,lon)
% read the ECMWF file collocated with the ERS data, 
%
% Input: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%  time : Mx1 element array of times, in days from Jan 1 1958
%   lat : MxN element array of data lattitudes
%   lon : MxN element array of data longitudes
% Output: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  u, v : u,v wind components (9999,9999 is nodata)
%

% written 11 Feb 2006 by DGL at BYU based on version by CongLing Nie

if ~(size(time,1)==size(lat,1) & size(time,1)==size(lon,1))
  error('*** incompatible arrays in col_ecmwf');
end

% the path where the data is stored
dat_path='/auto/work/long/jpl/ECMWF_qscat/';
% working path if file is gzipped
tmp_path='/tmp';

ecm_time_beg=min(min(time(find(time>0))));
ecm_time_end=max(max(time(find(time>0))));
wrong_data=1;

%start time of ECMWF
% ecm_ymd_beg=utc582ymd(ecm_time_beg(1));
% ecm_year_beg=ecm_ymd_beg(1,1);
% ecm_mon_beg=ecm_ymd_beg(1,2);
% ecm_day_beg=ecm_ymd_beg(1,3);
ecm_hr_beg=floor((ecm_time_beg-floor(ecm_time_beg))*4)*6;
date_beg=datenum(floor(ecm_time_beg)+ecm_hr_beg/24);
%determine time of ECMWF end
ecm_hr_end=ceil((ecm_time_end-floor(ecm_time_end))*4)*6;
date_end=datenum(floor(ecm_time_end)+ecm_hr_end/24);
if (date_beg == date_end)
  date_end=date_end+6/24;
end

ecm_file=[date_beg+datenum('01/01/1958'):6/24:date_end+datenum('01/01/1958')];
%ecm_file-datenum('01/01/1999')
for i=1:length(ecm_file)
  ecm_year=datestr(ecm_file(i),'yy');
  ecm_mon=datestr(ecm_file(i),'mm');
  ecm_day=datestr(ecm_file(i),'dd');  
  ecm_hr=datestr(ecm_file(i),'HH');
  diryear=['20' ecm_year];
  if ecm_year == '99'
    diryear='1999';
  end
  
  filename=[dat_path diryear '/ecmwf' ecm_year ecm_mon ecm_day '.' ecm_hr 'z.dat'];
  dir_1=dir(filename);
  disp(filename)
  
  if isempty(dir_1)
    newname=[tmp_path 'ecmwf' ecm_year ecm_mon ecm_day '.' ecm_hr 'z.dat'];
%    disp(newname)
    dir_3=dir(newname);
    if isempty(dir_3)
      filename1=[dat_path diryear '/ecmwf' ecm_year ecm_mon ecm_day '.' ecm_hr 'z.dat.gz'];
%      disp(newname)
      dir_2=dir(filename1);
      if isempty(dir_2)
	wrong_data=0;
%	disp('*** an appropriate ECMWF file could not be located');
      else
	% file is gzipped, copy to temp location and ungzip
	line=sprintf('!cp %s %s; gunzip %s.gz',filename1,tmp_path,newname');
	eval(line);
	dir_1=dir(newname);
	if isempty(dir_1)
	  wrong_data=0;
%	  disp('*** an appropriate ECMWF file could not be located');
	else
	  %open and read ECMWF file
	  [w_u,w_v,ecmwf_time]=read_ecmwf2(newname);
	  u_stack(:,:,i)=[w_u w_u(:,1)];
	  v_stack(:,:,i)=[w_v w_v(:,1)];
	end
      end
    else
      %open and ECMWF file
      [w_u,w_v,ecmwf_time]=read_ecmwf2(newname);
      u_stack(:,:,i)=[w_u w_u(:,1)];
      v_stack(:,:,i)=[w_v w_v(:,1)];
    end
  else
    %open and ECMWF file
    [w_u,w_v,ecmwf_time]=read_ecmwf2(filename);
    u_stack(:,:,i)=[w_u w_u(:,1)];
    v_stack(:,:,i)=[w_v w_v(:,1)];
  end
  
end

if wrong_data~=0
  %compute the interpolation time
  ecm_diff=(time+datenum('01/01/1958'));
  time_diff=(ecm_diff-ecm_file(1))*24/6;
  lat1=mod(lat+90,180); % convert lat to ECMWF index
  lon1=mod(lon+360,360);    % convert lon to ECMWF index
  %do time/space interpolation
  [M,N]=size(lat);
  [u,v]=interp_uv(u_stack,v_stack,repmat(time_diff,1,N),lat1,lon1);
else  % return no-data flag
  disp('*** an appropriate ECMWF file could not be located');
  u=-9999;
  v=-9999;   
end
