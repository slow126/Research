function [u,v]=col_ncep1(time,lat,lon,selection)
%
% [u,v]=col_ncep1(time,lat,lon,[selection])
% read an NCEP1 file 
%
% Input: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%  time : Mx1 element array of times, in days from Jan 1 1958
%   lat : MxN element array of data lattitudes
%   lon : MxN element array of data longitudes
% [selection] is an optional parameter.  If present and non-empty
% it is the (w/o path) name of the NCEP1 file to use and no temporal
% intepolation is applied.
% Output: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  u, v : u,v wind components (9999,9999 is nodata)
%

% written 13 Feb 2006 by DGL at BYU based on version by CongLing Nie
% revised 15 Feb 2006 by DGL at BYU to include [selection] option

if ~(size(time,1)==size(lat,1) & size(time,1)==size(lon,1))
  error('*** incompatible arrays in col_ncep1');
end

% the path where the data is stored
dat_path='/auto/work/long/jpl/NCEP1_qscat/';
% working path if file is gzipped
tmp_path='/tmp';

ecm_time_beg=min(min(time(find(time>0))));
ecm_time_end=max(max(time(find(time>0))));
wrong_data=1;

%start time of NCEP1
% ecm_ymd_beg=utc582ymd(ecm_time_beg(1));
% ecm_year_beg=ecm_ymd_beg(1,1);
% ecm_mon_beg=ecm_ymd_beg(1,2);
% ecm_day_beg=ecm_ymd_beg(1,3);
ecm_hr_beg=floor((ecm_time_beg-floor(ecm_time_beg))*4)*6;
date_beg=datenum(floor(ecm_time_beg)+ecm_hr_beg/24);
%determine time of NCEP1 end
ecm_hr_end=ceil((ecm_time_end-floor(ecm_time_end))*4)*6;
date_end=datenum(floor(ecm_time_end)+ecm_hr_end/24);
if (date_beg == date_end)
  date_end=date_end+6/24;
end

ecm_file=[date_beg+datenum('01/01/1958'):6/24:date_end+datenum('01/01/1958')];

if nargin>3
  if ~isempty(selection) % override range of times
    ecm_file=[ecm_file(1) ecm_file(1)];
  end
end

for i=1:length(ecm_file)
  ecm_year=datestr(ecm_file(i),'yyyy');
  ecm_mon=datestr(ecm_file(i),'mm');
  ecm_day=datestr(ecm_file(i),'dd');
  ecm_jd=num2str(julday(str2num(ecm_mon),str2num(ecm_day),str2num(ecm_year))-julday(1,1,str2num(ecm_year))+1);
  ecm_hr=datestr(ecm_file(i),'HH');
  diryear=ecm_year;
  
  filename=[dat_path diryear '/SNWP1' ecm_year ecm_jd ecm_hr];

  if nargin>3
    if ~isempty(selection) % override range of times
      filename=[dat_path diryear '/' selection];
    end
  end

  
  dir_1=dir(filename);
  disp(filename)
  
  if isempty(dir_1)
    newname=[tmp_path 'SNWP1' ecm_year ecm_jd ecm_hr];
    if nargin>3
      if ~isempty(selection) % override range of times
	newname=[tmp_path selection];
      end
    end
    
    %    disp(newname)
    dir_3=dir(newname);
    if isempty(dir_3)
      filename1=[dat_path diryear '/SNWP1' ecm_year ecm_jd ecm_hr '.gz'];
      if nargin>3
	if ~isempty(selection) % override range of times
	  filename1=[dat_path diryear '/' selection '.gz'];
	end
      end

      %      disp(newname)
      dir_2=dir(filename1);
      if isempty(dir_2)
	wrong_data=0;
%	disp('*** an appropriate NCEP1 file could not be located');
      else
	% file is gzipped, copy to temp location and ungzip
	line=sprintf('!cp %s %s; gunzip %s.gz',filename1,tmp_path,newname');
	eval(line);
	dir_1=dir(newname);
	if isempty(dir_1)
	  wrong_data=0;
%	  disp('*** an appropriate NCEP1 file could not be located');
	else
	  %open and read NCEP file
	  [w_u,w_v,ncep_time]=read_ncep1(newname);
	  u_stack(:,:,i)=[w_u w_u(:,1)];
	  v_stack(:,:,i)=[w_v w_v(:,1)];
	end
      end
    else
      %open and NCEP1 file
      [w_u,w_v,ncep_time]=read_ncep1(newname);
      u_stack(:,:,i)=[w_u w_u(:,1)];
      v_stack(:,:,i)=[w_v w_v(:,1)];
    end
  else
    %open and NCEP1 file
    [w_u,w_v,ncep_time]=read_ncep1(filename);
    u_stack(:,:,i)=[w_u w_u(:,1)];
    v_stack(:,:,i)=[w_v w_v(:,1)];
  end
  
end

if wrong_data~=0
  %compute the interpolation time
  ecm_diff=(time+datenum('01/01/1958'));
  time_diff=(ecm_diff-ecm_file(1))*24/6;
  lat1=mod(lat+90,180); % convert lat to NCEP1 index
  lon1=mod(lon+360,360);    % convert lon to NCEP1 index
  %do time/space interpolation
  [M,N]=size(lat);
  [u,v]=interp_uv(u_stack,v_stack,repmat(time_diff,1,N),lat1,lon1);
else  % return no-data flag
  disp('*** an appropriate NCEP1 file could not be located');
  u=-9999;
  v=-9999;   
end
