%Loads all of the data out of the HDF5 Files specified in the lists found
%below. This data is used in soilMoistureMap_v3.m to recreate the NSIDC
%SMAP soil moisture retrieval algorithm. Uses a drop in the bucket approach
%to map to EASE-2 Grid, but data should already be EASE-2 gridded so 
%averaging shouldn't affect much.  

%% Options and EASE-2 Info

% clear;
showplottb = true;
year = 2015;
day = 153; % Julian day - remember 2016 is a leap year 
pol='v'; % h = horizontal, v = vertical (NASA L2B SM use vertical)
        

% compare with BYU .sir EASE2grid parameters
iopt=10; % EASE2-T - Leave this
ind=2; % Match the files you are reading in
isc=2; % Match the files you are reading in

[map_equatorial_radius_m, map_eccentricity, ...
e2, map_reference_latitude, map_reference_longitude, ...
map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
map_scale, bcols, brows, r0, s0, epsilon] = newease2_map_info(iopt, isc, ind);

%% Soil Moisture loading
fileloc = ['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/*.h5'];
filelist = dir(fileloc); % Now days from above will become the number of satellite passes to plot

gridpic = nan(brows,bcols);
temppic = nan(brows,bcols);
tbpic = nan(brows,bcols);
vwcpic = nan(brows,bcols);
albpic = nan(brows,bcols);
incpic = nan(brows,bcols);
rghpic = nan(brows,bcols);
voppic = nan(brows,bcols);
qualpic = nan(brows,bcols);
countim = zeros(brows,bcols);

for filechoice=1:length(filelist)
    FILE_NAME=[filelist(filechoice).folder '/' filelist(filechoice).name];

    % Open the HDF5 File.
    file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

%     if(type=='L2')
        % Open the dataset.
        DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data/soil_moisture';
        data_id = H5D.open(file_id, DATAFIELD_NAME);

        DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data/surface_temperature';
        temp_id = H5D.open(file_id, DATAFIELD_NAME);

        if(pol=='v')
            DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data/tb_v_corrected';
        else
            DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data/tb_h_corrected';
        end
        tb_id = H5D.open(file_id, DATAFIELD_NAME);

        DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data/vegetation_water_content';
        vwc_id = H5D.open(file_id, DATAFIELD_NAME);

        Lat_NAME = 'Soil_Moisture_Retrieval_Data/latitude';
        lat_id=H5D.open(file_id, Lat_NAME);

        Lon_NAME = 'Soil_Moisture_Retrieval_Data/longitude';
        lon_id=H5D.open(file_id, Lon_NAME);

        Alb_NAME = 'Soil_Moisture_Retrieval_Data/albedo';
        alb_id=H5D.open(file_id, Alb_NAME);

        Inc_NAME = 'Soil_Moisture_Retrieval_Data/boresight_incidence';
        inc_id=H5D.open(file_id, Inc_NAME);

        Rgh_NAME = 'Soil_Moisture_Retrieval_Data/roughness_coefficient';
        rgh_id=H5D.open(file_id, Rgh_NAME);

        Vop_NAME = 'Soil_Moisture_Retrieval_Data/vegetation_opacity';
        vop_id=H5D.open(file_id, Vop_NAME);

        qual_NAME = 'Soil_Moisture_Retrieval_Data/retrieval_qual_flag';
        qual_id=H5D.open(file_id, qual_NAME);
%     else
%         % Open the dataset.
%         DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_AM/soil_moisture';
%         data_id = H5D.open(file_id, DATAFIELD_NAME);
% 
%         DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_AM/surface_temperature';
%         temp_id = H5D.open(file_id, DATAFIELD_NAME);
% 
%         if(pol=='v')
%             DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_AM/tb_v_corrected';
%         else
%             DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_AM/tb_h_corrected';
%         end
%         tb_id = H5D.open(file_id, DATAFIELD_NAME);
% 
%         DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_AM/vegetation_water_content';
%         vwc_id = H5D.open(file_id, DATAFIELD_NAME);
% 
%         Lat_NAME = 'Soil_Moisture_Retrieval_Data_AM/latitude';
%         lat_id=H5D.open(file_id, Lat_NAME);
% 
%         Lon_NAME = 'Soil_Moisture_Retrieval_Data_AM/longitude';
%         lon_id=H5D.open(file_id, Lon_NAME);
% 
%         Alb_NAME = 'Soil_Moisture_Retrieval_Data_AM/albedo';
%         alb_id=H5D.open(file_id, Alb_NAME);
% 
%         Inc_NAME = 'Soil_Moisture_Retrieval_Data_AM/boresight_incidence';
%         inc_id=H5D.open(file_id, Inc_NAME);
% 
%         Rgh_NAME = 'Soil_Moisture_Retrieval_Data_AM/roughness_coefficient';
%         rgh_id=H5D.open(file_id, Rgh_NAME);
% 
%         Vop_NAME = 'Soil_Moisture_Retrieval_Data_AM/vegetation_opacity';
%         vop_id=H5D.open(file_id, Vop_NAME);
% 
%         qual_NAME = 'Soil_Moisture_Retrieval_Data_AM/retrieval_qual_flag';
%         qual_id=H5D.open(file_id, qual_NAME);
%     end
    
    % Read the dataset.
    data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    temp_dat=H5D.read (temp_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    tb_dat=H5D.read (tb_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    vwc_dat=H5D.read (vwc_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

    lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

    lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    alb_dat=H5D.read(alb_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    inc_dat=H5D.read(inc_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    rgh_dat=H5D.read(rgh_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    vop_dat=H5D.read(vop_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    qual_dat=H5D.read(qual_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    

    % Soil Moisture Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (data_id, ATTRIBUTE);
    fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
    H5A.close (attr_id);

    % Read the units.
    ATTRIBUTE = 'units';
    attr_id = H5A.open_name (data_id, ATTRIBUTE);
    units = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (data_id, ATTRIBUTE);
    valid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (data_id, ATTRIBUTE);
    valid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read title attribute.
    ATTRIBUTE = 'long_name';
    attr_id = H5A.open_name (data_id, ATTRIBUTE);
    long_name=H5A.read (attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    
    % Temperature Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (temp_id, ATTRIBUTE);
    tempfillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
    H5A.close (attr_id);

    % Read the units.
    ATTRIBUTE = 'units';
    attr_id = H5A.open_name (temp_id, ATTRIBUTE);
    tempunits = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (temp_id, ATTRIBUTE);
    tempvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (temp_id, ATTRIBUTE);
    tempvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    
    % TB Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (tb_id, ATTRIBUTE);
    tbfillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
    H5A.close (attr_id);

    % Read the units.
    ATTRIBUTE = 'units';
    attr_id = H5A.open_name (tb_id, ATTRIBUTE);
    tbunits = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (tb_id, ATTRIBUTE);
    tbvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (tb_id, ATTRIBUTE);
    tbvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    
    % VWC Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (vwc_id, ATTRIBUTE);
    vwcfillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
    H5A.close (attr_id);

    % Read the units.
    ATTRIBUTE = 'units';
    attr_id = H5A.open_name (vwc_id, ATTRIBUTE);
    vwcunits = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (vwc_id, ATTRIBUTE);
    vwcvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (vwc_id, ATTRIBUTE);
    vwcvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    % Albedo Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (alb_id, ATTRIBUTE);
    albfillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (alb_id, ATTRIBUTE);
    albvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (alb_id, ATTRIBUTE);
    albvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    % Incidence Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (inc_id, ATTRIBUTE);
    incfillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
    H5A.close (attr_id);

    % Read the units.
    ATTRIBUTE = 'units';
    attr_id = H5A.open_name (inc_id, ATTRIBUTE);
    incunits = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (inc_id, ATTRIBUTE);
    incvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (inc_id, ATTRIBUTE);
    incvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    % Soil Roughness Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (rgh_id, ATTRIBUTE);
    rghfillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (rgh_id, ATTRIBUTE);
    rghvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (rgh_id, ATTRIBUTE);
    rghvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    % Vegetation Opacity Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (vop_id, ATTRIBUTE);
    vopfillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (vop_id, ATTRIBUTE);
    vopvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (vop_id, ATTRIBUTE);
    vopvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    % Retrieval Quality Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (qual_id, ATTRIBUTE);
    qualfillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
    H5A.close (attr_id);

    % Close and release resources.
    H5D.close(data_id);
    H5D.close(temp_id);
    H5D.close(tb_id);
    H5D.close(vwc_id);
    H5D.close(alb_id);
    H5D.close(inc_id);
    H5D.close(rgh_id);
    H5D.close(vop_id);
    H5D.close(qual_id);
    H5F.close(file_id);

    % Replace the fill value with NaN.
    data(data==double(fillvalue)) = NaN;
    temp_dat(temp_dat==double(tempfillvalue)) = NaN;
    tb_dat(tb_dat==double(tbfillvalue)) = NaN;
    vwc_dat(vwc_dat==double(vwcfillvalue)) = NaN;
    alb_dat(alb_dat==double(albfillvalue)) = NaN;
    inc_dat(inc_dat==double(incfillvalue)) = NaN;
    rgh_dat(rgh_dat==double(rghfillvalue)) = NaN;
    vop_dat(vop_dat==double(vopfillvalue)) = NaN;
    qual_dat(qual_dat==double(qualfillvalue)) = NaN;
    
    % Replace the invalid range values with NaN.
    data(data < double(valid_min)) = NaN;
    data(data > double(valid_max)) = NaN;
    temp_dat(temp_dat < double(tempvalid_min)) = NaN;
    temp_dat(temp_dat > double(tempvalid_max)) = NaN;
    tb_dat(tb_dat < double(tbvalid_min)) = NaN;
    tb_dat(tb_dat > double(tbvalid_max)) = NaN;
    vwc_dat(vwc_dat < double(vwcvalid_min)) = NaN;
    vwc_dat(vwc_dat > double(vwcvalid_max)) = NaN;
    alb_dat(alb_dat < double(albvalid_min)) = NaN;
    alb_dat(alb_dat > double(albvalid_max)) = NaN;
    inc_dat(inc_dat < double(incvalid_min)) = NaN;
    inc_dat(inc_dat > double(incvalid_max)) = NaN;
    rgh_dat(rgh_dat < double(rghvalid_min)) = NaN;
    rgh_dat(rgh_dat > double(rghvalid_max)) = NaN;
    vop_dat(vop_dat < double(vopvalid_min)) = NaN;
    vop_dat(vop_dat > double(vopvalid_max)) = NaN;

    [thelon, thelat] = ease2grid(iopt,lon,lat,isc,ind); 
    % get list of valid lat/lon positions
    idx=find(lat>=-90 & lon>=-180);

    % convert to matlab pixel array indexes
    nsx=bcols;
    nsy=brows;
    xr=round(thelon(idx)+0.4999); % +0.4999 gives pixel center
    yr=round(thelat(idx)+0.4999);
    k=find(xr>1 & xr<=nsx & yr>1 & yr<=nsy);
    m=nsy*(xr-1)+yr;  % pixel index into array
    

    for l = 1:length(idx)
        if(~isnan(data(idx(l))) && ~isnan(temp_dat(idx(l))) && ~isnan(tb_dat(idx(l))) && ~isnan(vwc_dat(idx(l))))
            if(countim(yr(l),xr(l)) == 0)
                gridpic(yr(l),xr(l)) = data(idx(l));
                temppic(yr(l),xr(l)) = temp_dat(idx(l));
                tbpic(yr(l),xr(l)) = tb_dat(idx(l));
                vwcpic(yr(l),xr(l)) = vwc_dat(idx(l));
                albpic(yr(l),xr(l)) = alb_dat(idx(l));
                incpic(yr(l),xr(l)) = inc_dat(idx(l));
                rghpic(yr(l),xr(l)) = rgh_dat(idx(l));
                voppic(yr(l),xr(l)) = vop_dat(idx(l));
                qualpic(yr(l),xr(l)) = qual_dat(idx(l));
                countim(yr(l),xr(l)) = 1;
            else
                countim(yr(l),xr(l)) = countim(yr(l),xr(l)) + 1;
                gridpic(yr(l),xr(l)) = gridpic(yr(l),xr(l)) + data(idx(l));
                temppic(yr(l),xr(l)) = temppic(yr(l),xr(l)) + temp_dat(idx(l));
                vwcpic(yr(l),xr(l)) = vwcpic(yr(l),xr(l)) + vwc_dat(idx(l));
                albpic(yr(l),xr(l)) = albpic(yr(l),xr(l)) + alb_dat(idx(l));
                incpic(yr(l),xr(l)) = incpic(yr(l),xr(l)) + inc_dat(idx(l));
                rghpic(yr(l),xr(l)) = rghpic(yr(l),xr(l)) + rgh_dat(idx(l));
                voppic(yr(l),xr(l)) = voppic(yr(l),xr(l)) + vop_dat(idx(l));
                qualpic(yr(l),xr(l)) = qualpic(yr(l),xr(l)) + qual_dat(idx(l));
                tbpic(yr(l),xr(l)) = tbpic(yr(l),xr(l)) + tb_dat(idx(l));
            end
        end
    end
    
    fprintf('Finished with hdf %d\n',filechoice);
end

smav = bsxfun(@rdivide,gridpic,countim);
tempav = bsxfun(@rdivide,temppic,countim);
tbav = bsxfun(@rdivide,tbpic,countim);
vwcav = bsxfun(@rdivide,vwcpic,countim);
albav = bsxfun(@rdivide,albpic,countim);
incav = bsxfun(@rdivide,incpic,countim);
rghav = bsxfun(@rdivide,rghpic,countim);
vopav = bsxfun(@rdivide,voppic,countim);
qualav = bsxfun(@rdivide,qualpic,countim);
smav=flip(smav,1);
tempav=flip(tempav,1);
tbav=flip(tbav,1);
vwcav=flip(vwcav,1);
albav=flip(albav,1);
incav=flip(incav,1);
rghav=flip(rghav,1);
vopav=flip(vopav,1);
qualav=flip(qualav,1);
countim=flip(countim,1);

if showplottb
    figure
    imagesc(smav);
    colorbar;
    title('SM Image');
    
    figure
    imagesc(tempav);
    colorbar;
    title('Temperature Image');
    
    figure
    imagesc(tbav);
    colorbar;
    title('Brightness Temperature Image');
    
    figure
    imagesc(vwcav);
    colorbar;
    title('Vegetation Water Content Image');
    
    figure
    imagesc(albav);
    colorbar;
    title('Albedo Image');
    
    figure
    imagesc(incav);
    colorbar;
    title('Boresight Incidence Image');
    
    figure
    imagesc(rghav);
    colorbar;
    title('Soil Roughness Image');
    
    figure
    imagesc(vopav);
    colorbar;
    title('Vegetation Opacity Image');
    
    figure
    imagesc(qualav);
    colorbar;
    title('Retrieval Quality Image');
end

