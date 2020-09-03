function data_loadSLURM(year,day,showplot,writeout,toworkspace)
%Loads all of the data out of the HDF5 Files specified in the lists found
%below. This data is used in soilMoistureMap_v3.m to recreate the NSIDC
%SMAP soil moisture retrieval algorithm. Uses a drop in the bucket approach
%to map to EASE-2 Grid, but data should already be EASE-2 gridded so 
%averaging shouldn't affect much.  Optionally writes SIR files from loaded
%data

%% Options and EASE-2 Info
    pol='v'; % h = horizontal, v = vertical (NASA L2B SM use vertical)
    res=2; % 1=36 km, 2=9km

    % compare with BYU .sir EASE2grid parameters
    iopt=10; % EASE2-T - Leave this
    ind=2; % Leave this
    if(res==1)
        isc=0;
    elseif(res==2)
        isc=2;
    end

%     [map_equatorial_radius_m, map_eccentricity, ...
%     e2, map_reference_latitude, map_reference_longitude, ...
%     map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
%     map_scale, bcols, brows, r0, s0, epsilon] = ease2_map_info(iopt, isc, ind);

    %% Soil Moisture loading
    if(res==1)
        fileloc = ['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/SMAP_L3_SM_P_2*.h5'];
    elseif(res==2)
        fileloc = ['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/SMAP_L3_SM_P_E*.h5'];
    end
    filelist = dir(fileloc); % Now days from above will become the number of satellite passes to plot
    FILE_NAME=[filelist(1).folder '/' filelist(1).name];
    
    %Load AM Data
    lat = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/latitude');
    lon = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/longitude');
    smav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/soil_moisture');
    tempav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/surface_temperature');
    if pol == 'h'
        tbav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/tb_h_corrected');
    else
        tbav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/tb_v_corrected');
        tbuncav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/tb_v_uncorrected');
    end
    vwcav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/vegetation_water_content');
    albav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/albedo');
    incav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/boresight_incidence');
    rghav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/roughness_coefficient');
    vopav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/vegetation_opacity');
    qualav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/retrieval_qual_flag');
    qualav=double(qualav);
    wfracav = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_AM/radar_water_body_fraction');
    
    %Load PM Data
    latpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/latitude_pm');
    lonpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/longitude_pm');
    smpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/soil_moisture_pm');
    temppm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/surface_temperature_pm');
    if pol == 'h'
        tbpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/tb_h_corrected_pm');
    else
        tbpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/tb_v_corrected_pm');
        tbuncpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/tb_v_corrected_pm');
    end
    vwcpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/vegetation_water_content_pm');
    albpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/albedo_pm');
    incpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/boresight_incidence_pm');
    rghpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/roughness_coefficient_pm');
    voppm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/vegetation_opacity_pm');
    qualpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/retrieval_qual_flag_pm');
    qualpm = double(qualpm);
    wfracpm = h5read(FILE_NAME,'/Soil_Moisture_Retrieval_Data_PM/radar_water_body_fraction_pm');
    
    % Replace the fill value with NaN.
    lat(lat==double(-9999)) = NaN;
    lon(lon==double(-9999)) = NaN;
    smav(smav==double(-9999)) = NaN;
    tempav(tempav==double(-9999)) = NaN;
    tbav(tbav==double(-9999)) = NaN;
    tbuncav(tbuncav==double(-9999)) = NaN;
    vwcav(vwcav==double(-9999)) = NaN;
    albav(albav==double(-9999)) = NaN;
    incav(incav==double(-9999)) = NaN;
    rghav(rghav==double(-9999)) = NaN;
    vopav(vopav==double(-9999)) = NaN;
    qualav(qualav==double(65534)) = NaN;
    wfracav(wfracav==double(-9999)) = NaN;
    
    latpm(latpm==double(-9999)) = NaN;
    lonpm(lonpm==double(-9999)) = NaN;
    smpm(smpm==double(-9999)) = NaN;
    temppm(temppm==double(-9999)) = NaN;
    tbpm(tbpm==double(-9999)) = NaN;
    tbuncpm(tbuncpm==double(-9999)) = NaN;
    vwcpm(vwcpm==double(-9999)) = NaN;
    albpm(albpm==double(-9999)) = NaN;
    incpm(incpm==double(-9999)) = NaN;
    rghpm(rghpm==double(-9999)) = NaN;
    voppm(voppm==double(-9999)) = NaN;
    qualpm(qualpm==double(65534)) = NaN;
    wfracpm(wfracpm==double(-9999)) = NaN;
    
    % Replace the invalid range values with NaN.
    smav(smav < double(0.02)) = NaN;
    smav(smav > double(0.5)) = NaN;
    tempav(tempav < double(0)) = NaN;
    tempav(tempav > double(350)) = NaN;
    tbav(tbav < double(0)) = NaN;
    tbav(tbav > double(330)) = NaN;
    tbuncav(tbuncav < double(0)) = NaN;
    tbuncav(tbuncav > double(330)) = NaN;
    vwcav(vwcav < double(0)) = NaN;
    vwcav(vwcav > double(20)) = NaN;
    albav(albav < double(0)) = NaN;
    albav(albav > double(1)) = NaN;
    incav(incav < double(0)) = NaN;
    incav(incav > double(90)) = NaN;
    rghav(rghav < double(0)) = NaN;
    rghav(rghav > double(1)) = NaN;
    vopav(vopav < double(0)) = NaN;
    vopav(vopav > double(10)) = NaN;
    wfracav(wfracav < double(0)) = NaN;
    wfracav(wfracav > double(1)) = NaN;

    smpm(smpm < double(0.02)) = NaN;
    smpm(smpm > double(0.5)) = NaN;
    temppm(temppm < double(0)) = NaN;
    temppm(temppm > double(350)) = NaN;
    tbpm(tbpm < double(0)) = NaN;
    tbpm(tbpm > double(330)) = NaN;
    tbuncpm(tbuncpm < double(0)) = NaN;
    tbuncpm(tbuncpm > double(330)) = NaN;
    vwcpm(vwcpm < double(0)) = NaN;
    vwcpm(vwcpm > double(20)) = NaN;
    albpm(albpm < double(0)) = NaN;
    albpm(albpm > double(1)) = NaN;
    incpm(incpm < double(0)) = NaN;
    incpm(incpm > double(90)) = NaN;
    rghpm(rghpm < double(0)) = NaN;
    rghpm(rghpm > double(1)) = NaN;
    voppm(voppm < double(0)) = NaN;
    voppm(voppm > double(10)) = NaN;
    wfracpm(wfracpm < double(0)) = NaN;
    wfracpm(wfracpm > double(1)) = NaN;
    
    %Fill in blanks in AM image with PM measurements.
    lat(isnan(lat) & ~isnan(latpm))=latpm(isnan(lat) & ~isnan(latpm));
    lon(isnan(lon) & ~isnan(lonpm))=lonpm(isnan(lon) & ~isnan(lonpm));
    smav(isnan(smav) & ~isnan(smpm))=smpm(isnan(smav) & ~isnan(smpm));
    tempav(isnan(tempav) & ~isnan(temppm))=temppm(isnan(tempav) & ~isnan(temppm));
    tbav(isnan(tbav) & ~isnan(tbpm))=tbpm(isnan(tbav) & ~isnan(tbpm));
    tbuncav(isnan(tbuncav) & ~isnan(tbuncpm))=tbuncpm(isnan(tbuncav) & ~isnan(tbuncpm));
    vwcav(isnan(vwcav) & ~isnan(vwcpm))=vwcpm(isnan(vwcav) & ~isnan(vwcpm));
    albav(isnan(albav) & ~isnan(albpm))=albpm(isnan(albav) & ~isnan(albpm));
    incav(isnan(incav) & ~isnan(incpm))=incpm(isnan(incav) & ~isnan(incpm));
    rghav(isnan(rghav) & ~isnan(rghpm))=rghpm(isnan(rghav) & ~isnan(rghpm));
    vopav(isnan(vopav) & ~isnan(voppm))=voppm(isnan(vopav) & ~isnan(voppm));
    qualav(qualav==7 & qualpm~=7)=qualpm(qualav==7 & qualpm~=7);
    wfracav(isnan(wfracav) & ~isnan(wfracpm))=wfracpm(isnan(wfracav) & ~isnan(wfracpm));
    
    % Average areas that are covered in AM and PM
%     smav(~isnan(smav) & ~isnan(smpm))=(smpm(~isnan(smav) & ~isnan(smpm))+smav(~isnan(smav) & ~isnan(smpm)))/2;
%     tempav(~isnan(tempav) & ~isnan(temppm))=(temppm(~isnan(tempav) & ~isnan(temppm))+tempav(~isnan(tempav) & ~isnan(temppm)))/2;
%     tbav(~isnan(tbav) & ~isnan(tbpm))=(tbpm(~isnan(tbav) & ~isnan(tbpm))+tbav(~isnan(tbav) & ~isnan(tbpm)))/2;
%     tbuncav(~isnan(tbuncav) & ~isnan(tbuncpm))=(tbuncpm(~isnan(tbuncav) & ~isnan(tbuncpm))+tbuncav(~isnan(tbuncav) & ~isnan(tbuncpm)))/2;
%     vwcav(~isnan(vwcav) & ~isnan(vwcpm))=(vwcpm(~isnan(vwcav) & ~isnan(vwcpm))+vwcav(~isnan(vwcav) & ~isnan(vwcpm)))/2;
%     albav(~isnan(albav) & ~isnan(albpm))=(albpm(~isnan(albav) & ~isnan(albpm))+albav(~isnan(albav) & ~isnan(albpm)))/2;
%     incav(~isnan(incav) & ~isnan(incpm))=(incpm(~isnan(incav) & ~isnan(incpm))+incav(~isnan(incav) & ~isnan(incpm)))/2;
%     rghav(~isnan(rghav) & ~isnan(rghpm))=(rghpm(~isnan(rghav) & ~isnan(rghpm))+rghav(~isnan(rghav) & ~isnan(rghpm)))/2;
%     vopav(~isnan(vopav) & ~isnan(voppm))=(voppm(~isnan(vopav) & ~isnan(voppm))+vopav(~isnan(vopav) & ~isnan(voppm)))/2;
%     qualav(~isnan(qualav) & ~isnan(qualpm))=(qualpm(~isnan(qualav) & ~isnan(qualpm))+qualav(~isnan(qualav) & ~isnan(qualpm)))/2;
%     wfracav(~isnan(wfracav) & ~isnan(wfracpm))=(wfracpm(~isnan(wfracav) & ~isnan(wfracpm))+wfracav(~isnan(wfracav) & ~isnan(wfracpm)))/2;
    
    lat=rot90(flip(lat,1),3);
    lon=rot90(flip(lon,1),3);
    smav=rot90(flip(smav,1),3);
    tempav=rot90(flip(tempav,1),3);
    tbav=rot90(flip(tbav,1),3);
    tbuncav=rot90(flip(tbuncav,1),3);
    vwcav=rot90(flip(vwcav,1),3);
    albav=rot90(flip(albav,1),3);
    incav=rot90(flip(incav,1),3);
    rghav=rot90(flip(rghav,1),3);
    vopav=rot90(flip(vopav,1),3);
    qualav=rot90(flip(qualav,1),3);
    wfracav=rot90(flip(wfracav,1),3);

%% Plot Figures

if showplot
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
    title('Corrected Brightness Temperature Image');
    
    figure
    imagesc(tbuncav);
    colorbar;
    title('Uncorrected Brightness Temperature Image');
    
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
    title('Radar Water Body Fraction Image');
    
%     figure
%     imagesc(lat);
%     colorbar;
%     title('Lat');
%     
%     figure
%     imagesc(lon);
%     colorbar;
%     title('Lon');
end

%% Optionally write data to sir
if writeout
    if(res==1)
        fprintf('Writing data to SIR files\n');
        ancfolder = ['/auto/temp/brown/smData/'];
        sirfile = [ancfolder 'clayf_36km.sir'];
        [~, head, descrip, iaopt]=loadsir(sirfile); %This is just to get the head, descrip,iaopt

        tbuncav(isnan(tbuncav)) = 100;
        head(10)=100; %ioff
        head(11)=100; %iscale
        head(49)=100; %nodata
        head(50)=180; %vmin
        head(51)=295; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/tbunc_36km-' num2str(day) '.sir'],tbuncav,head,0,descrip,iaopt);
        
        tbav(isnan(tbav)) = 100;
        head(10)=100; %ioff
        head(11)=100; %iscale
        head(49)=100; %nodata
        head(50)=180; %vmin
        head(51)=295; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/tb_36km-' num2str(day) '.sir'],tbav,head,0,descrip,iaopt);
        
        smav(isnan(smav)) = -1;
        head(10)=-1; %ioff
        head(11)=10000; %iscale
        head(49)=-1; %nodata
        head(50)=0.05; %vmin
        head(51)=0.5; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/sm_36km-' num2str(day) '.sir'],smav,head,0,descrip,iaopt);

        tempav(isnan(tempav)) = 220;
        head(10)=200; %ioff
        head(11)=100; %iscale
        head(49)=220;
        head(50)=250;
        head(51)=330;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/surftemp_36km-' num2str(day) '.sir'],tempav,head,0,descrip,iaopt);

        vwcav(isnan(vwcav)) = -1;
        head(10)=-1; %ioff
        head(11)=1000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=20;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vwc_36km-' num2str(day) '.sir'],vwcav,head,0,descrip,iaopt);

        albav(isnan(albav)) = -1;
        head(10)=-1; %ioff
        head(11)=10000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=0.1;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/alb_36km-' num2str(day) '.sir'],albav,head,0,descrip,iaopt);

        incav(isnan(incav)) = 0;
        head(10)=0; %ioff
        head(11)=1000; %iscale
        head(49)=0;
        head(50)=39.9;
        head(51)=40.1;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/inc_36km-' num2str(day) '.sir'],incav,head,0,descrip,iaopt);

        rghav(isnan(rghav)) = -1;
        head(10)=-1; %ioff
        head(11)=10000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=.2;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/rgh_36km-' num2str(day) '.sir'],rghav,head,0,descrip,iaopt);

        vopav(isnan(vopav)) = -1;
        head(49)=-1;
        head(50)=0;
        head(51)=3;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vop_36km-' num2str(day) '.sir'],vopav,head,0,descrip,iaopt);

        qualav(isnan(qualav)) = -1;
        head(10)=-1; %ioff
        head(11)=1000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=15;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/retqual_36km-' num2str(day) '.sir'],qualav,head,0,descrip,iaopt);
        
        wfracav(isnan(wfracav)) = -1;
        head(10)=-1; %ioff
        head(11)=10000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=1;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/wfrac_36km-' num2str(day) '.sir'],wfracav,head,0,descrip,iaopt);
    elseif(res==2)
        fprintf('Writing data to SIR files\n');
        ancfolder = ['/auto/temp/brown/smData/2015/153/ancillarysir/'];
        sirfile = [ancfolder 'alb-E2T-153.sir'];
        [~, head, descrip, iaopt]=loadsir(sirfile); %This is just to get the head, descrip,iaopt

        tbuncav(isnan(tbuncav)) = 100;
        head(10)=100; %ioff
        head(11)=100; %iscale
        head(49)=100; %nodata
        head(50)=180; %vmin
        head(51)=295; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/tbunc-E2T-' num2str(day) '.sir'],tbuncav,head,0,descrip,iaopt);
        
        tbav(isnan(tbav)) = 100;
        head(10)=100; %ioff
        head(11)=100; %iscale
        head(49)=100; %nodata
        head(50)=180; %vmin
        head(51)=295; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/tb-E2T-' num2str(day) '.sir'],tbav,head,0,descrip,iaopt);
        
        smav(isnan(smav)) = -1;
        head(10)=-1; %ioff
        head(11)=10000; %iscale
        head(49)=-1; %nodata
        head(50)=0.05; %vmin
        head(51)=0.5; %vmax
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/sm-E2T-' num2str(day) '.sir'],smav,head,0,descrip,iaopt);

        tempav(isnan(tempav)) = 220;
        head(10)=200; %ioff
        head(11)=100; %iscale
        head(49)=220;
        head(50)=250;
        head(51)=330;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/surftemp-E2T-' num2str(day) '.sir'],tempav,head,0,descrip,iaopt);

        vwcav(isnan(vwcav)) = -1;
        head(10)=-1; %ioff
        head(11)=1000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=20;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vwc-E2T-' num2str(day) '.sir'],vwcav,head,0,descrip,iaopt);

        albav(isnan(albav)) = -1;
        head(10)=-1; %ioff
        head(11)=10000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=0.1;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/alb-E2T-' num2str(day) '.sir'],albav,head,0,descrip,iaopt);

        incav(isnan(incav)) = 0;
        head(10)=0; %ioff
        head(11)=1000; %iscale
        head(49)=0;
        head(50)=39.9;
        head(51)=40.1;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/inc-E2T-' num2str(day) '.sir'],incav,head,0,descrip,iaopt);

        rghav(isnan(rghav)) = -1;
        head(10)=-1; %ioff
        head(11)=10000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=.2;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/rgh-E2T-' num2str(day) '.sir'],rghav,head,0,descrip,iaopt);

        vopav(isnan(vopav)) = -1;
        head(49)=-1;
        head(50)=0;
        head(51)=3;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vop-E2T-' num2str(day) '.sir'],vopav,head,0,descrip,iaopt);

        qualav(isnan(qualav)) = -1;
        head(10)=-1; %ioff
        head(11)=1000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=15;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/retqual-E2T-' num2str(day) '.sir'],qualav,head,0,descrip,iaopt);
    
        wfracav(isnan(wfracav)) = -1;
        head(10)=-1; %ioff
        head(11)=10000; %iscale
        head(49)=-1;
        head(50)=0;
        head(51)=1;
        writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/wfrac-E2T-' num2str(day) '.sir'],wfracav,head,0,descrip,iaopt);
    end
disp('Done writing data to SIR files');
end

%% Optionally save the variables to the workspace
if toworkspace
    save(['smdata-' num2str(year) '-' num2str(day) '.mat'],'lat','lon','smav','tempav','tbav', ...
        'vwcav','albav','incav','rghav','vopav','qualav','wfracav');
end

end