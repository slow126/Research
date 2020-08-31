function tbrsir_to_sir(year,day,showplottb,writeout,toworkspace) 
% Loads NetCDF rSIR enhanced SMAP data from paths below, and optionally writes them
% out to SIR files
%% Options and EASE-2 Info   
res=1; %res 1: 3 km, 2: 9 km, 3: 36 km

% compare with BYU .sir EASE2grid parameters
iopt=10; % EASE2-T - Leave this
if(res==1)
    ind=3; % Match the files you are reading in
    isc=3; % Match the files you are reading in
elseif(res==2)
    ind=2; % Match the files you are reading in
    isc=2; % Match the files you are reading in
elseif(res==3)
    ind=2; % Match the files you are reading in
    isc=0; % Match the files you are reading in
end

[map_equatorial_radius_m, map_eccentricity, ...
e2, map_reference_latitude, map_reference_longitude, ...
map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
map_scale, bcols, brows, ~, s0, epsilon] = newease2_map_info(iopt, isc, ind);

%% Soil Moisture loading
if(res==1)
    fileam=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M03km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-SIR-JPL-v1.0.nc'];
    filepm=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M03km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-D-SIR-JPL-v1.0.nc'];
elseif(res==2)
    fileam=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M09km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-SIR-JPL-v1.0.nc'];
    filepm=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M09km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-D-SIR-JPL-v1.0.nc'];
elseif(res==3)
    fileam=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M36km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-GRD-JPL-v1.0.nc'];
    filepm=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M36km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-D-GRD-JPL-v1.0.nc'];
end


%Load AM/PM Data
tbam = ncread(fileam,'TB');
tbpm = ncread(filepm,'TB');
incam = ncread(fileam,'Incidence_angle');
incpm = ncread(filepm,'Incidence_angle');

% Replace the invalid range values with NaN.
tbam(tbam < double(50)) = NaN;
tbam(tbam > double(350)) = NaN;
tbpm(tbpm < double(50)) = NaN;
tbpm(tbpm > double(350)) = NaN;
incam(incam < double(0)) = NaN;
incam(incam > double(90)) = NaN;
incpm(incpm < double(0)) = NaN;
incpm(incpm > double(90)) = NaN;

%Now combine AM and PM
tbav=nan(size(tbam));
tbav(isnan(tbam) & ~isnan(tbpm))=tbpm(isnan(tbam) & ~isnan(tbpm));
tbav(~isnan(tbam) & isnan(tbpm))=tbam(~isnan(tbam) & isnan(tbpm));
tbav(~isnan(tbam) & ~isnan(tbpm))=(tbam(~isnan(tbam) & ~isnan(tbpm))+tbpm(~isnan(tbam) & ~isnan(tbpm)))/2;

incav=nan(size(incam));
incav(isnan(incam) & ~isnan(incpm))=incpm(isnan(incam) & ~isnan(incpm));
incav(~isnan(incam) & isnan(incpm))=incam(~isnan(incam) & isnan(incpm));
incav(~isnan(incam) & ~isnan(incpm))=(incam(~isnan(incam) & ~isnan(incpm))+incpm(~isnan(incam) & ~isnan(incpm)))/2;

tbav=rot90(flip(tbav,1),3);
incav=rot90(flip(incav,1),3);

% fileloc = ['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/*.h5'];
% filelist = dir(fileloc); % Now days from above will become the number of satellite passes to plot
% 
% tbpic = nan(brows,bcols);
% countim = zeros(brows,bcols);
% 
% for filechoice=1:length(filelist)
%     FILE_NAME=[filelist(filechoice).folder '/' filelist(filechoice).name];
% 
%     % Open the HDF5 File.
%     file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
% 
%     if(pol=='v')
%         DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data/tb_v_corrected';
%     else
%         DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data/tb_h_corrected';
%     end
%     tb_id = H5D.open(file_id, DATAFIELD_NAME);
%     
%     % Read the dataset.    
%     tb_dat=H5D.read (tb_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
%     
%     
%     % TB Attributes
%     % Read the fill value.
%     ATTRIBUTE = '_FillValue';
%     attr_id = H5A.open_name (tb_id, ATTRIBUTE);
%     tbfillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
%     H5A.close (attr_id);
% 
%     % Read the units.
%     ATTRIBUTE = 'units';
%     attr_id = H5A.open_name (tb_id, ATTRIBUTE);
%     tbunits = H5A.read(attr_id, 'H5ML_DEFAULT');
%     H5A.close (attr_id);
% 
%     % Read the valid_max.
%     ATTRIBUTE = 'valid_max';
%     attr_id = H5A.open_name (tb_id, ATTRIBUTE);
%     tbvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
%     H5A.close (attr_id);
% 
%     % Read the valid_min.
%     ATTRIBUTE = 'valid_min';
%     attr_id = H5A.open_name (tb_id, ATTRIBUTE);
%     tbvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
%     H5A.close (attr_id);
%    
% 
%     % Close and release resources.
%     H5D.close(tb_id);
% 
%     % Replace the fill value with NaN.
%     tb_dat(tb_dat==double(tbfillvalue)) = NaN;
%     
%     % Replace the invalid range values with NaN.
%     tb_dat(tb_dat < double(tbvalid_min)) = NaN;
%     tb_dat(tb_dat > double(tbvalid_max)) = NaN;
% 
%     [thelon, thelat] = ease2grid(iopt,lon,lat,isc,ind); 
%     % get list of valid lat/lon positions
%     idx=find(lat>=-90 & lon>=-180);
% 
%     % convert to matlab pixel array indexes
%     nsx=bcols;
%     nsy=brows;
%     xr=round(thelon(idx)+0.4999); % +0.4999 gives pixel center
%     yr=round(thelat(idx)+0.4999);
%     k=find(xr>1 & xr<=nsx & yr>1 & yr<=nsy);
%     m=nsy*(xr-1)+yr;  % pixel index into array
%     
% 
%     for l = 1:length(idx)
%         if(~isnan(tb_dat(idx(l))))
%             if(countim(yr(l),xr(l)) == 0)
%                 tbpic(yr(l),xr(l)) = tb_dat(idx(l));
%                 countim(yr(l),xr(l)) = 1;
%             else
%                 countim(yr(l),xr(l)) = countim(yr(l),xr(l)) + 1;
%                 tbpic(yr(l),xr(l)) = tbpic(yr(l),xr(l)) + tb_dat(idx(l));
%             end
%         end
%     end
%     
%     fprintf('Finished with hdf %d\n',filechoice);
% end
% 
% tbav = bsxfun(@rdivide,tbpic,countim);
% tbav=flip(tbav,1);

if showplottb
    figure
    imagesc(tbav);
    colorbar;
    title('Brightness Temperature Image');
    
    figure
    imagesc(incav);
    colorbar;
    title('Incidence Angle Image');
end

if writeout
    fprintf('Writing data to SIR files\n');
    if(res==1)
        ancfolder = ['/auto/temp/brown/smData/2016/1/ancillarysir/'];
        sirfile = [ancfolder 'alb_3km-1.sir'];
        [~, head, descrip, iaopt]=loadsir(sirfile); %This is just to get the head, descrip,iaopt

        tbav(isnan(tbav)) = -1;
        head(10)=-1; %ioff
        head(11)=100; %iscale
        head(49)=-1; %nodata
        head(50)=180; %vmin
        head(51)=295; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/tb2_3km-' num2str(day) '.sir'],tbav,head,0,descrip,iaopt);

        incav(isnan(incav)) = 0;
        head(10)=0; %ioff
        head(11)=1000; %iscale
        head(49)=0; %nodata
        head(50)=39.9; %vmin
        head(51)=40.1; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/inc2_3km-' num2str(day) '.sir'],incav,head,0,descrip,iaopt);
    elseif(res==2)
        ancfolder = ['/auto/temp/brown/smData/2016/1/ancillarysir/'];
        sirfile = [ancfolder 'alb-E2T-1.sir'];
        [~, head, descrip, iaopt]=loadsir(sirfile); %This is just to get the head, descrip,iaopt

        tbav(isnan(tbav)) = -1;
        head(10)=-1; %ioff
        head(11)=100; %iscale
        head(49)=-1; %nodata
        head(50)=180; %vmin
        head(51)=295; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/tb2-E2T-' num2str(day) '.sir'],tbav,head,0,descrip,iaopt);

        incav(isnan(incav)) = 0;
        head(10)=0; %ioff
        head(11)=1000; %iscale
        head(49)=0; %nodata
        head(50)=39.9; %vmin
        head(51)=40.1; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/inc2-E2T-' num2str(day) '.sir'],incav,head,0,descrip,iaopt);
    elseif(res==3)
        ancfolder = ['/auto/temp/brown/smData/2016/1/ancillarysir/'];
        sirfile = [ancfolder 'alb_36km-1.sir'];
        [~, head, descrip, iaopt]=loadsir(sirfile); %This is just to get the head, descrip,iaopt

        tbav(isnan(tbav)) = -1;
        head(10)=-1; %ioff
        head(11)=100; %iscale
        head(49)=-1; %nodata
        head(50)=180; %vmin
        head(51)=295; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/tb2_36km-' num2str(day) '.sir'],tbav,head,0,descrip,iaopt);

        incav(isnan(incav)) = 0;
        head(10)=0; %ioff
        head(11)=1000; %iscale
        head(49)=0; %nodata
        head(50)=39.9; %vmin
        head(51)=40.1; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/inc2_36km-' num2str(day) '.sir'],incav,head,0,descrip,iaopt);
    end
    disp('Done writing SIR files');
end

%% Optionally save the variables to the workspace
if toworkspace
    assignin('base','tbav',tbav,'incav',incav);
end
end