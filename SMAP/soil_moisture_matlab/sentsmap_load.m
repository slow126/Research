function sentsmap_load(year,day,showplottb,writeout,toworkspace)
%Loads 3 km SMAP-SENTINEL data  

%% Options and EASE-2 Info

% clear;
pol='v'; % h = horizontal, v = vertical (NASA L2B SM use vertical)
        

% compare with BYU .sir EASE2grid parameters
iopt=10; % EASE2-T - Leave this
ind=3; % Match the files you are reading in
isc=3; % Match the files you are reading in

[map_equatorial_radius_m, map_eccentricity, ...
e2, map_reference_latitude, map_reference_longitude, ...
map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
map_scale, bcols, brows, r0, s0, epsilon] = newease2_map_info(iopt, isc, ind);

%% Soil Moisture loading
fileloc = ['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/SMAP*SM_SP*.h5'];
filelist = dir(fileloc); % Now days from above will become the number of satellite passes to plot

gridpic = nan(brows,bcols);
temppic = nan(brows,bcols);
tbpic = nan(brows,bcols);
vwcpic = nan(brows,bcols);
albpic = nan(brows,bcols);
incpic = nan(brows,bcols);
rghpic = nan(brows,bcols);
voppic = nan(brows,bcols);
wfracpic = nan(brows,bcols);
qualpic = nan(brows,bcols);
countim = zeros(brows,bcols);

for filechoice=1:length(filelist)
    FILE_NAME=[filelist(filechoice).folder '/' filelist(filechoice).name];

    % Open the HDF5 File.
    file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

    DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_3km/soil_moisture_3km';
    data_id = H5D.open(file_id, DATAFIELD_NAME);

    DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_3km/surface_temperature_3km';
    temp_id = H5D.open(file_id, DATAFIELD_NAME);

    if(pol=='v')
        DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_3km/tb_v_disaggregated_3km';
    else
        DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_3km/tb_h_disaggregated_3km';
    end
    tb_id = H5D.open(file_id, DATAFIELD_NAME);

    DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_3km/vegetation_water_content_3km';
    vwc_id = H5D.open(file_id, DATAFIELD_NAME);

    Lat_NAME = 'Soil_Moisture_Retrieval_Data_3km/latitude_3km';
    lat_id=H5D.open(file_id, Lat_NAME);

    Lon_NAME = 'Soil_Moisture_Retrieval_Data_3km/longitude_3km';
    lon_id=H5D.open(file_id, Lon_NAME);

    Alb_NAME = 'Soil_Moisture_Retrieval_Data_3km/albedo_3km';
    alb_id=H5D.open(file_id, Alb_NAME);

    Inc_NAME = 'Soil_Moisture_Retrieval_Data_3km/sigma0_incidence_angle_3km';
    inc_id=H5D.open(file_id, Inc_NAME);

    Rgh_NAME = 'Soil_Moisture_Retrieval_Data_3km/bare_soil_roughness_retrieved_3km';
    rgh_id=H5D.open(file_id, Rgh_NAME);

    Vop_NAME = 'Soil_Moisture_Retrieval_Data_3km/vegetation_opacity_3km';
    vop_id=H5D.open(file_id, Vop_NAME);

    qual_NAME = 'Soil_Moisture_Retrieval_Data_3km/retrieval_qual_flag_3km';
    qual_id=H5D.open(file_id, qual_NAME);
    
    col_NAME = 'Soil_Moisture_Retrieval_Data_3km/EASE_column_index_3km';
    col_id=H5D.open(file_id, col_NAME);
    
    row_NAME = 'Soil_Moisture_Retrieval_Data_3km/EASE_row_index_3km';
    row_id=H5D.open(file_id, row_NAME);
    
    wfrac_NAME = 'Soil_Moisture_Retrieval_Data_3km/water_body_fraction_3km';
    wfrac_id=H5D.open(file_id, wfrac_NAME);
    
    % Read the dataset.
    data=H5D.read (data_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    temp_dat=H5D.read (temp_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    tb_dat=H5D.read (tb_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    vwc_dat=H5D.read (vwc_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

    lat=H5D.read(lat_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

    lon=H5D.read(lon_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    alb_dat=H5D.read(alb_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    inc_dat=H5D.read(inc_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    rgh_dat=H5D.read(rgh_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    vop_dat=H5D.read(vop_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    qual_dat=H5D.read(qual_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    col_dat=H5D.read(col_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    row_dat=H5D.read(row_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    wfrac_dat=H5D.read(wfrac_id,'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    

    % Soil Moisture Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (data_id, ATTRIBUTE);
    fillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
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
    tempfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
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
    tbfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
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
    vwcfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
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
    albfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
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
    incfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

%     % Read the units.
%     ATTRIBUTE = 'units';
%     attr_id = H5A.open_name (inc_id, ATTRIBUTE);
%     incunits = H5A.read(attr_id, 'H5ML_DEFAULT');
%     H5A.close (attr_id);

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
    rghfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
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
    vopfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
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
    qualfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    % EASE Column Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (col_id, ATTRIBUTE);
    colfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (col_id, ATTRIBUTE);
    colvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (col_id, ATTRIBUTE);
    colvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    % EASE Column Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (row_id, ATTRIBUTE);
    rowfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (row_id, ATTRIBUTE);
    rowvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (row_id, ATTRIBUTE);
    rowvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);
    
    % Water Body Fraction Attributes
    % Read the fill value.
    ATTRIBUTE = '_FillValue';
    attr_id = H5A.open_name (wfrac_id, ATTRIBUTE);
    wfracfillvalue=H5A.read (attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_max.
    ATTRIBUTE = 'valid_max';
    attr_id = H5A.open_name (wfrac_id, ATTRIBUTE);
    wfracvalid_max = H5A.read(attr_id, 'H5ML_DEFAULT');
    H5A.close (attr_id);

    % Read the valid_min.
    ATTRIBUTE = 'valid_min';
    attr_id = H5A.open_name (wfrac_id, ATTRIBUTE);
    wfracvalid_min = H5A.read(attr_id, 'H5ML_DEFAULT');
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
    H5D.close(col_id);
    H5D.close(row_id);
    H5D.close(wfrac_id);
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
    col_dat(col_dat==double(colfillvalue)) = NaN;
    row_dat(row_dat==double(rowfillvalue)) = NaN;
    wfrac_dat(wfrac_dat==double(wfracfillvalue)) = NaN;
    
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
    col_dat(col_dat < double(colvalid_min)) = NaN;
    col_dat(col_dat > double(colvalid_max)) = NaN;
    row_dat(row_dat < double(rowvalid_min)) = NaN;
    row_dat(row_dat > double(rowvalid_max)) = NaN;
    wfrac_dat(wfrac_dat < double(wfracvalid_min)) = NaN;
    wfrac_dat(wfrac_dat > double(wfracvalid_max)) = NaN;

%     [thelon, thelat] = newease2grid(iopt,lon,lat,isc,ind); 
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
%         if(~isnan(data(idx(l))) && ~isnan(temp_dat(idx(l))) && ~isnan(tb_dat(idx(l))) && ~isnan(vwc_dat(idx(l))))
%             if(countim(yr(l),xr(l)) == 0)
%                 gridpic(yr(l),xr(l)) = data(idx(l));
%                 temppic(yr(l),xr(l)) = temp_dat(idx(l));
%                 tbpic(yr(l),xr(l)) = tb_dat(idx(l));
%                 vwcpic(yr(l),xr(l)) = vwc_dat(idx(l));
%                 albpic(yr(l),xr(l)) = alb_dat(idx(l));
%                 incpic(yr(l),xr(l)) = inc_dat(idx(l));
%                 rghpic(yr(l),xr(l)) = rgh_dat(idx(l));
%                 voppic(yr(l),xr(l)) = vop_dat(idx(l));
%                 qualpic(yr(l),xr(l)) = qual_dat(idx(l));
%                 countim(yr(l),xr(l)) = 1;
%             else
%                 countim(yr(l),xr(l)) = countim(yr(l),xr(l)) + 1;
%                 gridpic(yr(l),xr(l)) = gridpic(yr(l),xr(l)) + data(idx(l));
%                 temppic(yr(l),xr(l)) = temppic(yr(l),xr(l)) + temp_dat(idx(l));
%                 vwcpic(yr(l),xr(l)) = vwcpic(yr(l),xr(l)) + vwc_dat(idx(l));
%                 albpic(yr(l),xr(l)) = albpic(yr(l),xr(l)) + alb_dat(idx(l));
%                 incpic(yr(l),xr(l)) = incpic(yr(l),xr(l)) + inc_dat(idx(l));
%                 rghpic(yr(l),xr(l)) = rghpic(yr(l),xr(l)) + rgh_dat(idx(l));
%                 voppic(yr(l),xr(l)) = voppic(yr(l),xr(l)) + vop_dat(idx(l));
%                 qualpic(yr(l),xr(l)) = qualpic(yr(l),xr(l)) + qual_dat(idx(l));
%                 tbpic(yr(l),xr(l)) = tbpic(yr(l),xr(l)) + tb_dat(idx(l));
%             end
%         end
%     end
    
    [nx, ny]=size(col_dat);
    for x = 1:nx
        for y = 1:ny
            if(~isnan(data(x,y)) && ~isnan(temp_dat(x,y)) && ~isnan(tb_dat(x,y)) && ~isnan(vwc_dat(x,y))...
                    && ~isnan(alb_dat(x,y)) && ~isnan(inc_dat(x,y)) && ~isnan(rgh_dat(x,y)) && ~isnan(vop_dat(x,y)) && ~isnan(qual_dat(x,y)) && ~isnan(wfrac_dat(x,y)))
                if(countim(row_dat(x,y),col_dat(x,y)) == 0)
                    gridpic(row_dat(x,y),col_dat(x,y)) = data(x,y);
                    temppic(row_dat(x,y),col_dat(x,y)) = temp_dat(x,y);
                    tbpic(row_dat(x,y),col_dat(x,y)) = tb_dat(x,y);
                    vwcpic(row_dat(x,y),col_dat(x,y)) = vwc_dat(x,y);
                    albpic(row_dat(x,y),col_dat(x,y)) = alb_dat(x,y);
                    incpic(row_dat(x,y),col_dat(x,y)) = inc_dat(x,y);
                    rghpic(row_dat(x,y),col_dat(x,y)) = rgh_dat(x,y);
                    voppic(row_dat(x,y),col_dat(x,y)) = vop_dat(x,y);
                    qualpic(row_dat(x,y),col_dat(x,y)) = qual_dat(x,y);
                    wfracpic(row_dat(x,y),col_dat(x,y)) = wfrac_dat(x,y);
                    countim(row_dat(x,y),col_dat(x,y)) = 1;
                else
                    countim(row_dat(x,y),col_dat(x,y)) = countim(row_dat(x,y),col_dat(x,y)) + 1;
                    gridpic(row_dat(x,y),col_dat(x,y)) = gridpic(row_dat(x,y),col_dat(x,y)) + data(x,y);
                    temppic(row_dat(x,y),col_dat(x,y)) = temppic(row_dat(x,y),col_dat(x,y)) + temp_dat(x,y);
                    vwcpic(row_dat(x,y),col_dat(x,y)) = vwcpic(row_dat(x,y),col_dat(x,y)) + vwc_dat(x,y);
                    albpic(row_dat(x,y),col_dat(x,y)) = albpic(row_dat(x,y),col_dat(x,y)) + alb_dat(x,y);
                    incpic(row_dat(x,y),col_dat(x,y)) = incpic(row_dat(x,y),col_dat(x,y)) + inc_dat(x,y);
                    rghpic(row_dat(x,y),col_dat(x,y)) = rghpic(row_dat(x,y),col_dat(x,y)) + rgh_dat(x,y);
                    voppic(row_dat(x,y),col_dat(x,y)) = voppic(row_dat(x,y),col_dat(x,y)) + vop_dat(x,y);
                    qualpic(row_dat(x,y),col_dat(x,y)) = qualpic(row_dat(x,y),col_dat(x,y)) + qual_dat(x,y);
                    wfracpic(row_dat(x,y),col_dat(x,y)) = wfracpic(row_dat(x,y),col_dat(x,y)) + wfrac_dat(x,y);
                    tbpic(row_dat(x,y),col_dat(x,y)) = tbpic(row_dat(x,y),col_dat(x,y)) + tb_dat(x,y);
                end
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
wfracav = bsxfun(@rdivide,wfracpic,countim);
% smav=flip(smav,1);
% tempav=flip(tempav,1);
% tbav=flip(tbav,1);
% vwcav=flip(vwcav,1);
% albav=flip(albav,1);
% incav=flip(incav,1);
% rghav=flip(rghav,1);
% vopav=flip(vopav,1);
% qualav=flip(qualav,1);
% countim=flip(countim,1);

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
    
    figure
    imagesc(wfracav);
    colorbar;
    title('Water Body Fraction Image');
end

if writeout
    fprintf('Writing data to SIR files\n');
    ancfolder = ['/auto/temp/brown/smData/2016/1/ancillarysir/'];
    sirfile = [ancfolder 'alb_3km-1.sir'];
    [~, head, descrip, iaopt]=loadsir(sirfile); %This is just to get the head, descrip,iaopt

    tbav(isnan(tbav)) = -1;
    head(10)=-1; %ioff
    head(11)=100; %iscale
    head(49)=-1; %nodata
    head(50)=180; %vmin
    head(51)=295; %vmax
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/tb_3km-' num2str(day) '.sir'],tbav,head,0,descrip,iaopt);
    
    smav(isnan(smav)) = -1;
    head(10)=-1; %ioff
    head(11)=10000; %iscale
    head(49)=-1; %nodata
    head(50)=0.05; %vmin
    head(51)=0.5; %vmax
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/sm_3km-' num2str(day) '.sir'],smav,head,0,descrip,iaopt);

    tempav(isnan(tempav)) = 220;
    head(10)=200; %ioff
    head(11)=100; %iscale
    head(49)=220;
    head(50)=250;
    head(51)=330;
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/surftemp_3km-' num2str(day) '.sir'],tempav,head,0,descrip,iaopt);

    vwcav(isnan(vwcav)) = -1;
    head(10)=-1; %ioff
    head(11)=1000; %iscale
    head(49)=-1;
    head(50)=0;
    head(51)=20;
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vwc_3km-' num2str(day) '.sir'],vwcav,head,0,descrip,iaopt);

    albav(isnan(albav)) = -1;
    head(10)=-1; %ioff
    head(11)=10000; %iscale
    head(49)=-1;
    head(50)=0;
    head(51)=0.1;
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/alb_3km-' num2str(day) '.sir'],albav,head,0,descrip,iaopt);

    incav(isnan(incav)) = 0;
    head(10)=0; %ioff
    head(11)=1000; %iscale
    head(49)=0;
    head(50)=39.9;
    head(51)=40.1;
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/inc_3km-' num2str(day) '.sir'],incav,head,0,descrip,iaopt);

    rghav(isnan(rghav)) = -1;
    head(10)=-1; %ioff
    head(11)=10000; %iscale
    head(49)=-1;
    head(50)=0;
    head(51)=.2;
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/rgh_3km-' num2str(day) '.sir'],rghav,head,0,descrip,iaopt);

    vopav(isnan(vopav)) = -1;
    head(49)=-1;
    head(50)=0;
    head(51)=3;
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vop_3km-' num2str(day) '.sir'],vopav,head,0,descrip,iaopt);

    qualav(isnan(qualav)) = -1;
    head(10)=-1; %ioff
    head(11)=100; %iscale
    head(49)=-1;
    head(50)=0;
    head(51)=255;
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/retqual_3km-' num2str(day) '.sir'],qualav,head,0,descrip,iaopt);

    wfracav(isnan(wfracav)) = -1;
    head(10)=-1; %ioff
    head(11)=10000; %iscale
    head(49)=-1; %nodata
    head(50)=0; %vmin
    head(51)=1; %vmax
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/wfrac_3km-' num2str(day) '.sir'],wfracav,head,0,descrip,iaopt);
    
    disp('Done writing data to SIR files');
end


end

