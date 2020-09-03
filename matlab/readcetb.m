function cetb=readcetb(filename,iopt)
%
% cetb=readcetb(filename<,ioption>)
%
%  inputs: filename
%          ioption : array read option (options may be "or"-ed together)
%               0 = all (same as 31)
%	        1 = TB only
%	        2 = TB_num only
%	        4 = inc only
%	        8 = tb_std only
%	       16 = tb_time only
%
% simple matlab routine to read contents of a CETB .NC file
% to a matlab structure.  Includes options to not read everything
% to speed the run.
%

% written by DGL at BYU 11 Mar 2017

if nargin>1
  ioption=iopt;
else
  ioption=0;
end

isTB=0;
cetb=[];
if exist(filename,'file')==2  % if file exists, process
  % get variable arrays
  if ioption==0 | mod(ioption,2)==1
    %sf=ncreadatt(filename,'TB','scale_factor');
    %off=ncreadatt(filename,'TB','add_offset');

    % check to see if TB array is defined
    ncid=netcdf.open(filename,'NC_NOWRITE');
    varid = netcdf.inqVarID(ncid,'TB');
    if varid
      cetb.TB=ncread(filename,'TB'); %*sf+off;
      isTB=1;
      cetb.xdim=size(cetb.TB,1); % transpose
      cetb.ydim=size(cetb.TB,2);
    else % if not, check for sig array
      varid = netcdf.inqVarID(ncid,'sig');
      if varid
	cetb.sig=ncread(filename,'sig'); %*sf+off;
	cetb.xdim=size(cetb.sig,1); % transpose
	cetb.ydim=size(cetb.sig,2);
      end
    end
    netcdf.close(ncid);
    
  end
  if ioption==0 | mod(ioption/2,2)==1
    cetb.TB_num=ncread(filename,'TB_num_samples');
  end  
  if ioption==0 | mod(ioption/4,2)==1
    %sf=ncreadatt(filename,'Incidence_angle','scale_factor');
    %off=ncreadatt(filename,'Incidence_angle','add_offset');
    cetb.TB_inc=ncread(filename,'Incidence_angle'); %*sf+off;
  end
  if ioption==0 | mod(ioption/8,2)==1
    %sf=ncreadatt(filename,'TB_std_dev','scale_factor');
    %off=ncreadatt(filename,'TB_std_dev','add_offset');
    cetb.TB_std=ncread(filename,'TB_std_dev'); %*sf+off;
  end  
  if ioption==0 | mod(ioption/16,2)==1
    cetb.TB_time=ncread(filename,'TB_time');
  end
  
  % get key global attributes
  cetb.time=ncread(filename,'time');  % single day value
  %cetb.xdim=size(cetb.TB,2);
  %cetb.ydim=size(cetb.TB,1);
  NC_GLOBAL='/';
  cetb.instrument=ncreadatt(filename,NC_GLOBAL,'instrument');
  cetb.platform=ncreadatt(filename,NC_GLOBAL,'platform');
  cetb.tstart=ncreadatt(filename,NC_GLOBAL,'time_coverage_start');
  cetb.tstop=ncreadatt(filename,NC_GLOBAL,'time_coverage_end');
  cetb.xres=ncreadatt(filename,NC_GLOBAL,'geospatial_x_resolution');
  cetb.yres=ncreadatt(filename,NC_GLOBAL,'geospatial_y_resolution');
  
  % get key variable attributes
  cetb.time_reference=ncreadatt(filename,'time','units');
  
  if isTB 
    cetb.tdiv=ncreadatt(filename,'TB','temporal_division');
    if cetb.tdiv(1)=='A' | cetb.tdiv(1)=='D'  % ET2
      cetb.lat_org=0.0;
      cetb.tlocal_start=0.0;
      cetb.tlocal_end=1440.0;
    else % E2N or E2S
      cetb.lat_org=ncreadatt(filename,'crs','latitude_of_projection_origin');
      cetb.tlocal_start=ncreadatt(filename,'TB','temporal_division_local_start_time');
      cetb.tlocal_end=ncreadatt(filename,'TB','temporal_division_local_end_time');
    end
    cetb.fpol=ncreadatt(filename,'TB','frequency_and_polarization');  
  else
    cetb.tdiv=ncreadatt(filename,'sig','temporal_division');
    if cetb.tdiv(1)=='A' | cetb.tdiv(1)=='D'  % ET2
      cetb.lat_org=0.0;
      cetb.tlocal_start=0.0;
      cetb.tlocal_end=1440.0;
    else % E2N or E2S
      cetb.lat_org=ncreadatt(filename,'crs','latitude_of_projection_origin');
      cetb.tlocal_start=ncreadatt(filename,'sig','temporal_division_local_start_time');
      cetb.tlocal_end=ncreadatt(filename,'sig','temporal_division_local_end_time');
    end
    cetb.fpol=ncreadatt(filename,'sig','frequency_and_polarization');  
  end

  if 1 % modify everything to support BYU .SIR tools 
  % create header array and flip image arrays to be consistent 
  % with BYU .SIR matlab convention
  if isfield(cetb,'TB')
    cetb.tb_head=cetb_sir_head(cetb,filename,'TB');
    cetb.TB=cetb.TB';
  end
  if isfield(cetb,'sig')
    cetb.tb_head=cetb_sir_head(cetb,filename,'sig');
    cetb.sig=cetb.sig';
  end
  if isfield(cetb,'TB_inc')
    cetb.tb_inc_head=cetb_sir_head(cetb,filename,'TB_inc');
    cetb.TB_inc=cetb.TB_inc';
  end
  if isfield(cetb,'TB_std')
    cetb.tb_std_head=cetb_sir_head(cetb,filename,'TB_std');
    cetb.TB_std=cetb.TB_std';
  end
  if isfield(cetb,'TB_num')
    cetb.tb_num_head=cetb_sir_head(cetb,filename,'TB_num');
    cetb.TB_num=cetb.TB_num';
  end
  if isfield(cetb,'TB_time')
    cetb.tb_time_head=cetb_sir_head(cetb,filename,'TB_time');
    cetb.TB_time=cetb.TB_time';
  end  
end
  
else % file not found
  message(['*** nonexistant file ',filename]);
end

