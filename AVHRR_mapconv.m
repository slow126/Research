% test AVHRR NDVI projection remapping script

%template_file_name='qush-a-E2T99-257-257.sir';  % high res (takes long time)
template_file_name='qush-a-E2T99-257-257.grd'; % smaller and so faster

% input file
avhrr_name='AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc';

%% interactive selection of datasets
%%sel=NDVIReader(avhrr_name,true,0);

% pull individual datasets of interest
lat=NDVIReader(avhrr_name,false,1);
lon=NDVIReader(avhrr_name,false,2);
%time=NDVIReader(avhrr_name,false,3);
ndvi=NDVIReader(avhrr_name,false,4);
%timeofday=NDVIReader(avhrr_name,false,5);
%qa=NDVIReader(avhrr_name,false,6);

%size(lat.latitude)
%size(lon.longitude)
%size(ndvi.NDVI)

% note NDVI= -9999 is water or nodata

% read template SIR file to get projection information
[dat sirhead]=loadsir(template_file_name);

% for each pixel in the source file, compute corresponding location/pixel
% in destination file
dat(:)=-9998; % set default no-fill value (different than no data -9999)

% forward mapping (source locations -> destination locations)
% using nearest neighbor with only one value set when multiple source
% pixels map to a single destination pixel

fprintf('Start forward pass\n')
% (note: this could be more efficiently vectorized)
lons=double(lon.longitude);
for nlat=1:3600
  lats=zeros(size(lons))+double(lat.latitude(nlat));
  loc=sub2ind(size(ndvi.NDVI),1:7200,nlat+0*(1:7200));
  [x,y]=latlon2pix(lons,lats,sirhead);
  n=sirlex(x,y,sirhead);
  ind=find(~isnan(n));
  dat(n(ind))=double(ndvi.NDVI(loc(ind)));
end
fprintf('Forward pass completed\n');

% inverse mapping (destination locations <- nearest source location)
% only process unfilled points
lats=double(lat.latitude);
unfilled=find(dat==-9998);
if length(unfilled)>0
  fprintf('Start inverse pass %d\n',length(unfilled))
  [x,y]=isirlex(unfilled,sirhead);
  [lon,lat]=pix2latlon(x,y,sirhead);
  N=length(unfilled);
  ilon=zeros([N,1]);
  ilat=zeros([N,1]);
  for k=1:N
    [lmin,ilon(k)]=min(abs(lon(k)-lons));
    [lmin,ilat(k)]=min(abs(lat(k)-lats));
  end
  ind=find(ilon>0&ilon<7201&ilat>0&ilat<3601&~isnan(ilat)&~isnan(ilon));
  n=sub2ind(size(ndvi.NDVI),ilon(ind),ilat(ind));
  dat(unfilled(ind))=ndvi.NDVI(n);
  fprintf('Inverse pass completed\n');
end

%%%%%%%%%%%
%
% dat array now contains remapped image in template file projection
%
% change sir header info to reflect file contents and save result as a
% sir file for further analysis

% set text strings in sir header
sirhead=sirheadtext(sirhead,'AVHRR',avhrr_name,'NDVI', ...
    'AVHRR_NDVI','AVHRR_mapconv',date);

% change variable scaling to integers
sirhead=setsirhead('iscale',sirhead,1);
sirhead=setsirhead('ioff',sirhead,0);
sirhead=setsirhead('anodata',sirhead,-9999);
sirhead=setsirhead('vmin',sirhead,-10000);
sirhead=setsirhead('vmax',sirhead,9000);
sirhead=setsirhead('itype',sirhead,99); % note: using 99 since no standard
                                        % type code for NDVI

% get date from file
iyear=sscanf(ndvi.time_coverage_start(1:4),'%d');
mon=sscanf(ndvi.time_coverage_start(6:7),'%d');
day_of_month=sscanf(ndvi.time_coverage_start(8:9),'%d');
isday=date2doy(iyear,mon,day_of_month);
mon=sscanf(ndvi.time_coverage_end(6:7),'%d');
day_of_month=sscanf(ndvi.time_coverage_end(8:9),'%d');
ieday=date2doy(iyear,mon,day_of_month);
sirhead=setsirhead('isday',sirhead,isday); % start day from AVHRR file
sirhead=setsirhead('ieday',sirhead,ieday); % stop day from AVHRR file
sirhead=setsirhead('iyear',sirhead,isday); % four digit year from AVHRR file

% most other fields in header should not need to be changed


% write output file
outname=[avhrr_name '.E2T.sir'];
writesir(outname,dat,sirhead);

% show output image
showsir(dat,sirhead);  % b/w by default
colormap(jet);         % make colorful
