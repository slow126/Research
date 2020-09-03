%Loads all of the data out of the HDF5 Files specified in the lists found
%below. This data is used in soilMoistureMap_v3.m to recreate the NSIDC
%SMAP soil moisture retrieval algorithm. Uses a drop in the bucket approach
%to map to EASE-2 Grid, but data should already be EASE-2 gridded so 
%averaging shouldn't affect much.  

%% Options and EASE-2 Info

% clear;
loadextra = false; % Loads extra flags and options on top of main data
showplottb = false; %Plot the data

year = 2016;
day = 1; % Julian day - remember 2016 is a leap year 
pol='v'; % h = horizontal, v = vertical (NASA L2B SM use vertical)
        

% compare with BYU .sir EASE2grid parameters
iopt=10; % EASE2-T - Leave this
ind=2; % Leave this
isc=2; % Match the files you are reading in

[map_equatorial_radius_m, map_eccentricity, ...
e2, map_reference_latitude, map_reference_longitude, ...
map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
map_scale, bcols, brows, r0, s0, epsilon] = ease2_map_info(iopt, isc, ind);

%% Soil Moisture loading
fileloc = ['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/*.h5'];
filelist = dir(fileloc); % Now days from above will become the number of satellite passes to plot
%%
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

if loadextra
    ftfrac = nan(brows,bcols);
    gridsurf = nan(brows,bcols);
    radwaterfrac = nan(brows,bcols);
    qualop1 = nan(brows,bcols);
    qualop2 = nan(brows,bcols);
    qualop3 = nan(brows,bcols);
    qualop4 = nan(brows,bcols);
    qualop5 = nan(brows,bcols);
    l2err = nan(brows,bcols);
    smop1 = nan(brows,bcols);
    smop2 = nan(brows,bcols);
    smop3 = nan(brows,bcols);
    smop4 = nan(brows,bcols);
    smop5 = nan(brows,bcols);
    statwaterfrac = nan(brows,bcols);
    surfflag = nan(brows,bcols);
    surfwaterfrac = nan(brows,bcols);
    tbqual = nan(brows,bcols);
    vopop1 = nan(brows,bcols);
    vopop2 = nan(brows,bcols);
    vopop3 = nan(brows,bcols);
    vopop4 = nan(brows,bcols);
    vopop5 = nan(brows,bcols);
end

for filechoice=1:length(filelist)
    FILE_NAME=[filelist(filechoice).folder '/' filelist(filechoice).name];

    % Open the HDF5 File.
%     datastruct = hdf5load(FILE_NAME);
    
    lat = h5read(FILE_NAME,'Soil_Moisture_Retrieval_Data_AM/latitude');
    lon = datastruct.Soil_Moisture_Retrieval_Data_AM.longitude;
    data = datastruct.Soil_Moisture_Retrieval_Data_AM.soil_moisture;
    temp_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.surface_temperature;
    if pol == 'h'
        tb_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.tb_h_corrected;
    else
        tb_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.tb_v_corrected;
    end
    vwc_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.vegetation_water_content;
    alb_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.albedo;
    inc_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.boresight_incidence;
    rgh_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.roughness_coefficient;
    vop_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.vegetation_opacity;
    qual_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.retrieval_qual_flag;
    
    % Replace the fill value with NaN.
    data(data==double(-9999)) = NaN;
    temp_dat(temp_dat==double(-9999)) = NaN;
    tb_dat(tb_dat==double(-9999)) = NaN;
    vwc_dat(vwc_dat==double(-9999)) = NaN;
    alb_dat(alb_dat==double(-9999)) = NaN;
    inc_dat(inc_dat==double(-9999)) = NaN;
    rgh_dat(rgh_dat==double(-9999)) = NaN;
    vop_dat(vop_dat==double(-9999)) = NaN;
    qual_dat(qual_dat==double(65534)) = NaN;
    
    % Replace the invalid range values with NaN.
    data(data < double(0.02)) = NaN;
    data(data > double(0.5)) = NaN;
    temp_dat(temp_dat < double(0)) = NaN;
    temp_dat(temp_dat > double(350)) = NaN;
    tb_dat(tb_dat < double(0)) = NaN;
    tb_dat(tb_dat > double(330)) = NaN;
    vwc_dat(vwc_dat < double(0)) = NaN;
    vwc_dat(vwc_dat > double(20)) = NaN;
    alb_dat(alb_dat < double(0)) = NaN;
    alb_dat(alb_dat > double(1)) = NaN;
    inc_dat(inc_dat < double(0)) = NaN;
    inc_dat(inc_dat > double(90)) = NaN;
    rgh_dat(rgh_dat < double(0)) = NaN;
    rgh_dat(rgh_dat > double(1)) = NaN;
    vop_dat(vop_dat < double(0)) = NaN;
    vop_dat(vop_dat > double(10)) = NaN;
    
    if loadextra
        ft_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.freeze_thaw_fraction;
        gs_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.grid_surface_status;
        rwb_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.radar_water_body_fraction;
        statwb_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.static_water_body_fraction;
        if pol == 'h'
            tbqualflag_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_h;
            surfwmb_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.surface_water_fraction_mb_h;
        else
            tbqualflag_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_v;
            surfwmb_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.surface_water_fraction_mb_v;
        end
        l2err_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.soil_moisture_error;
        sflag_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.surface_flag;
        rqf1_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.retrieval_qual_flag_option1;
        rqf2_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.retrieval_qual_flag_option2;
        rqf3_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.retrieval_qual_flag_option3;
        rqf4_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.retrieval_qual_flag_option4;
        rqf5_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.retrieval_qual_flag_option5;
        smop1_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.soil_moisture_option1;
        smop2_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.soil_moisture_option2;
        smop3_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.soil_moisture_option3;
        smop4_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.soil_moisture_option4;
        smop5_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.soil_moisture_option5;
        vop1_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.vegetation_opacity_option1;
        vop2_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.vegetation_opacity_option2;
        vop3_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.vegetation_opacity_option3;
        vop4_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.vegetation_opacity_option4;
        vop5_dat = datastruct.Soil_Moisture_Retrieval_Data_AM.vegetation_opacity_option5;
        
        ft_dat(ft_dat==-9999) = NaN;
        gs_dat(gs_dat==65534) = NaN;
        rwb_dat(rwb_dat==-9999) = NaN;
        statwb_dat(statwb_dat==-9999) = NaN;
        tbqualflag_dat(tbqualflag_dat==65534) = NaN;
        surfwmb_dat(surfwmb_dat==-9999) = NaN;
        l2err_dat(l2err_dat==-9999) = NaN;
        sflag_dat(sflag_dat==65534) = NaN;
        rqf1_dat(rqf1_dat==65534) = NaN;
        rqf2_dat(rqf2_dat==65534) = NaN;
        rqf3_dat(rqf3_dat==65534) = NaN;
        rqf4_dat(rqf4_dat==65534) = NaN;
        rqf5_dat(rqf5_dat==65534) = NaN;
        smop1_dat(smop1_dat==-9999) = NaN;
        smop2_dat(smop2_dat==-9999) = NaN;
        smop3_dat(smop3_dat==-9999) = NaN;
        smop4_dat(smop4_dat==-9999) = NaN;
        smop5_dat(smop5_dat==-9999) = NaN;
        vop1_dat(vop1_dat==-9999) = NaN;
        vop2_dat(vop2_dat==-9999) = NaN;
        vop3_dat(vop3_dat==-9999) = NaN;
        vop4_dat(vop4_dat==-9999) = NaN;
        vop5_dat(vop5_dat==-9999) = NaN;
        
        ft_dat(ft_dat < double(0)) = NaN;
        ft_dat(ft_dat > double(1)) = NaN;
        gs_dat(gs_dat < double(0)) = NaN;
        gs_dat(gs_dat > double(1)) = NaN;
        rwb_dat(gs_dat < double(0)) = NaN;
        rwb_dat(gs_dat > double(1)) = NaN;
        statwb_dat(gs_dat < double(0)) = NaN;
        statwb_dat(gs_dat > double(1)) = NaN;
        surfwmb_dat(surfwmb_dat < double(0)) = NaN;
        surfwmb_dat(surfwmb_dat > double(1)) = NaN;
        l2err_dat(l2err_dat < double(0)) = NaN;
        l2err_dat(l2err_dat > double(0.2)) = NaN;
        smop1_dat(smop1_dat < double(0.02)) = NaN;
        smop1_dat(smop1_dat > double(0.5)) = NaN;
        smop2_dat(smop2_dat < double(0.02)) = NaN;
        smop2_dat(smop2_dat > double(0.5)) = NaN;
        smop3_dat(smop3_dat < double(0.02)) = NaN;
        smop3_dat(smop3_dat > double(0.5)) = NaN;
        smop4_dat(smop4_dat < double(0.02)) = NaN;
        smop4_dat(smop4_dat > double(0.5)) = NaN;
        smop5_dat(smop5_dat < double(0.02)) = NaN;
        smop5_dat(smop5_dat > double(0.5)) = NaN;
        vop1_dat(vop1_dat < double(0)) = NaN;
        vop1_dat(vop1_dat > double(10)) = NaN;
        vop2_dat(vop2_dat < double(0)) = NaN;
        vop2_dat(vop2_dat > double(10)) = NaN;
        vop3_dat(vop3_dat < double(0)) = NaN;
        vop3_dat(vop3_dat > double(10)) = NaN;
        vop4_dat(vop4_dat < double(0)) = NaN;
        vop4_dat(vop4_dat > double(10)) = NaN;
        vop5_dat(vop5_dat < double(0)) = NaN;
        vop5_dat(vop5_dat > double(10)) = NaN;
    end
    clear datastruct;

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
                if loadextra
                    ftfrac(yr(l),xr(l)) = ft_dat(idx(l));
                    gridsurf(yr(l),xr(l)) = gs_dat(idx(l));
                    radwaterfrac(yr(l),xr(l)) = rwb_dat(idx(l));
                    qualop1(yr(l),xr(l)) = rqf1_dat(idx(l));
                    qualop2(yr(l),xr(l)) = rqf2_dat(idx(l));
                    qualop3(yr(l),xr(l)) = rqf3_dat(idx(l));
                    qualop4(yr(l),xr(l)) = rqf4_dat(idx(l));
                    qualop5(yr(l),xr(l)) = rqf5_dat(idx(l));
                    l2err(yr(l),xr(l)) = l2err_dat(idx(l));
                    smop1(yr(l),xr(l)) = smop1_dat(idx(l));
                    smop2(yr(l),xr(l)) = smop2_dat(idx(l));
                    smop3(yr(l),xr(l)) = smop3_dat(idx(l));
                    smop4(yr(l),xr(l)) = smop4_dat(idx(l));
                    smop5(yr(l),xr(l)) = smop5_dat(idx(l));
                    statwaterfrac(yr(l),xr(l)) = statwb_dat(idx(l));
                    surfflag(yr(l),xr(l)) = sflag_dat(idx(l));
                    surfwaterfrac(yr(l),xr(l)) = surfwmb_dat(idx(l));
                    tbqual(yr(l),xr(l)) = tbqualflag_dat(idx(l));
                    vopop1(yr(l),xr(l)) = vop1_dat(idx(l));
                    vopop2(yr(l),xr(l)) = vop2_dat(idx(l));
                    vopop3(yr(l),xr(l)) = vop3_dat(idx(l));
                    vopop4(yr(l),xr(l)) = vop4_dat(idx(l));
                    vopop5(yr(l),xr(l)) = vop5_dat(idx(l));
                end
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
                if loadextra
                    ftfrac(yr(l),xr(l)) = ftfrac(yr(l),xr(l)) + ft_dat(idx(l));
                    gridsurf(yr(l),xr(l)) = gridsurf(yr(l),xr(l)) + gs_dat(idx(l));
                    radwaterfrac(yr(l),xr(l)) = radwaterfrac(yr(l),xr(l)) + rwb_dat(idx(l));
                    qualop1(yr(l),xr(l)) = qualop1(yr(l),xr(l)) + rqf1_dat(idx(l));
                    qualop2(yr(l),xr(l)) = qualop2(yr(l),xr(l)) + rqf2_dat(idx(l));
                    qualop3(yr(l),xr(l)) = qualop3(yr(l),xr(l)) + rqf3_dat(idx(l));
                    qualop4(yr(l),xr(l)) = qualop4(yr(l),xr(l)) + rqf4_dat(idx(l));
                    qualop5(yr(l),xr(l)) = qualop5(yr(l),xr(l)) + rqf5_dat(idx(l));
                    l2err(yr(l),xr(l)) = l2err(yr(l),xr(l)) + l2err_dat(idx(l));
                    smop1(yr(l),xr(l)) = smop1(yr(l),xr(l)) + smop1_dat(idx(l));
                    smop2(yr(l),xr(l)) = smop2(yr(l),xr(l)) + smop2_dat(idx(l));
                    smop3(yr(l),xr(l)) = smop3(yr(l),xr(l)) + smop3_dat(idx(l));
                    smop4(yr(l),xr(l)) = smop4(yr(l),xr(l)) + smop4_dat(idx(l));
                    smop5(yr(l),xr(l)) = smop5(yr(l),xr(l)) + smop5_dat(idx(l));
                    statwaterfrac(yr(l),xr(l)) = statwaterfrac(yr(l),xr(l)) + statwb_dat(idx(l));
                    surfflag(yr(l),xr(l)) = surfflag(yr(l),xr(l)) + sflag_dat(idx(l));
                    surfwaterfrac(yr(l),xr(l)) = surfwaterfrac(yr(l),xr(l)) + surfwmb_dat(idx(l));
                    tbqual(yr(l),xr(l)) = tbqual(yr(l),xr(l)) + tbqualflag_dat(idx(l));
                    vopop1(yr(l),xr(l)) = vopop1(yr(l),xr(l)) + vop1_dat(idx(l));
                    vopop2(yr(l),xr(l)) = vopop2(yr(l),xr(l)) + vop2_dat(idx(l));
                    vopop3(yr(l),xr(l)) = vopop3(yr(l),xr(l)) + vop3_dat(idx(l));
                    vopop4(yr(l),xr(l)) = vopop4(yr(l),xr(l)) + vop4_dat(idx(l));
                    vopop5(yr(l),xr(l)) = vopop5(yr(l),xr(l)) + vop5_dat(idx(l));
                end
            end
        end
    end
    clear alb_dat data ft_data gs_dat inc_dat l2err_dat qual_dat rgh_dat  ...
        rqf1_dat rqf2_dat rqf3_dat rqf4_dat rqf5_dat rwb_dat sflag_dat smop1_dat ...
        smop2_dat smop3_dat smop4_dat smop5_dat statwb_dat surfwmb_dat tb_dat ...
        tbqualflag_dat temp_dat vop1_dat vop2_dat vop3_dat vop4_dat vop5_dat vwc_dat;
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
clear gridpic temppic tbpic vwcpic albpic incpic rghpic voppic qualpic;

smav=flip(smav,1);
tempav=flip(tempav,1);
tbav=flip(tbav,1);
vwcav=flip(vwcav,1);
albav=flip(albav,1);
incav=flip(incav,1);
rghav=flip(rghav,1);
vopav=flip(vopav,1);
qualav=flip(qualav,1);

if loadextra
    ftav = bsxfun(@rdivide,ftfrac,countim);
    gridsurfav = bsxfun(@rdivide,gridsurf,countim);
    radwaterfracav = bsxfun(@rdivide,radwaterfrac,countim);
    qualop1av = bsxfun(@rdivide,qualop1,countim);
    qualop2av = bsxfun(@rdivide,qualop2,countim);
    qualop3av = bsxfun(@rdivide,qualop3,countim);
    qualop4av = bsxfun(@rdivide,qualop4,countim);
    qualop5av = bsxfun(@rdivide,qualop5,countim);
    l2errav = bsxfun(@rdivide,l2err,countim);
    smop1av = bsxfun(@rdivide,smop1,countim);
    smop2av = bsxfun(@rdivide,smop2,countim);
    smop3av = bsxfun(@rdivide,smop3,countim);
    smop4av = bsxfun(@rdivide,smop4,countim);
    smop5av = bsxfun(@rdivide,smop5,countim);
    statwaterfracav = bsxfun(@rdivide,statwaterfrac,countim);
    surfflagav = bsxfun(@rdivide,surfflag,countim);
    surfwaterfracav = bsxfun(@rdivide,surfwaterfrac,countim);
    tbqualav = bsxfun(@rdivide,tbqual,countim);
    vopop1av = bsxfun(@rdivide,vopop1,countim);
    vopop2av = bsxfun(@rdivide,vopop2,countim);
    vopop3av = bsxfun(@rdivide,vopop3,countim);
    vopop4av = bsxfun(@rdivide,vopop4,countim);
    vopop5av = bsxfun(@rdivide,vopop5,countim);
    clear ftfrac gridsurf radwaterfrac qualop1 qualop2 qualop3 qualop4 qualop5 ...
        l2err smop1 smop2 smop3 smop4 smop5 statwaterfrac surfflag surfwaterfrac ...
        tbqual vopop1 vopop2 vopop3 vopop4 vopop5;
    
    ftav = flip(ftav,1);
    gridsurfav = flip(gridsurfav,1);
    radwaterfracav = flip(radwaterfracav,1);
    qualop1av = flip(qualop1av,1);
    qualop2av = flip(qualop2av,1);
    qualop3av = flip(qualop3av,1);
    qualop4av = flip(qualop4av,1);
    qualop5av = flip(qualop5av,1);
    l2errav = flip(l2errav,1);
    smop1av = flip(smop1av,1);
    smop2av = flip(smop2av,1);
    smop3av = flip(smop3av,1);
    smop4av = flip(smop4av,1);
    smop5av = flip(smop5av,1);
    statwaterfracav = flip(statwaterfracav,1);
    surfflagav = flip(surfflagav,1);
    surfwaterfracav = flip(surfwaterfracav,1);
    tbqualav = flip(tbqualav,1);
    vopop1av = flip(vopop1av,1);
    vopop2av = flip(vopop2av,1);
    vopop3av = flip(vopop3av,1);
    vopop4av = flip(vopop4av,1);
    vopop5av = flip(vopop5av,1);
end

countim=flip(countim,1);

%% Plot Figures

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
    
    if loadextra
        figure
        imagesc(ftav);
        colorbar;
        title('Freeze Thaw Image');
        
        figure
        imagesc(gridsurfav);
        colorbar;
        title('Grid Surface Status Image');

        figure
        imagesc(radwaterfracav);
        colorbar;
        title('Radar Water Body Fraction Image');

        figure
        imagesc(qualop1av);
        colorbar;
        title('Retrieval Quality Option 1 Image');
        
        figure
        imagesc(qualop2av);
        colorbar;
        title('Retrieval Quality Option 2 Image');
        
        figure
        imagesc(qualop3av);
        colorbar;
        title('Retrieval Quality Option 3 Image');
        
        figure
        imagesc(qualop4av);
        colorbar;
        title('Retrieval Quality Option 4 Image');
        
        figure
        imagesc(qualop5av);
        colorbar;
        title('Retrieval Quality Option 5 Image');

        figure
        imagesc(l2errav);
        colorbar;
        title('NSIDC Soil Moisture Error Image');

        figure
        imagesc(smop1av);
        colorbar;
        title('Soil Moisture Option 1 Image');
        
        figure
        imagesc(smop2av);
        colorbar;
        title('Soil Moisture Option 2 Image');
        
        figure
        imagesc(smop3av);
        colorbar;
        title('Soil Moisture Option 3 Image');
        
        figure
        imagesc(smop4av);
        colorbar;
        title('Soil Moisture Option 4 Image');
        
        figure
        imagesc(smop5av);
        colorbar;
        title('Soil Moisture Option 5 Image');

        figure
        imagesc(statwaterfracav);
        colorbar;
        title('Static Water Body Fraction Image');

        figure
        imagesc(surfflagav);
        colorbar;
        title('Surface Flag Image');

        figure
        imagesc(surfwaterfracav);
        colorbar;
        title('Surface Water Fraction MB Image');

        figure
        imagesc(tbqualav);
        colorbar;
        title('TB Quality Image');

        figure
        imagesc(vopop1av);
        colorbar;
        title('Vegetation Opacity Option 1 Image');
        
        figure
        imagesc(vopop2av);
        colorbar;
        title('Vegetation Opacity Option 2 Image');
        
        figure
        imagesc(vopop3av);
        colorbar;
        title('Vegetation Opacity Option 3 Image');
        
        figure
        imagesc(vopop4av);
        colorbar;
        title('Vegetation Opacity Option 4 Image');
        
        figure
        imagesc(vopop5av);
        colorbar;
        title('Vegetation Opacity Option 5 Image');
    end
end

%% Optionally write data to sir
if 0
fprintf('Writing data to SIR files\n');
ancfolder = ['/auto/temp/brown/smData/2015/153/ancillarysir/'];
sirfile = [ancfolder 'alb-E2T-153.sir'];
[~, head, descrip, iaopt]=loadsir(sirfile); %This is just to get the head, descrip,iaopt

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
head(51)=13;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/retqual-E2T-' num2str(day) '.sir'],qualav,head,0,descrip,iaopt);

ftav(isnan(ftav)) = -1;
head(10)=-1; %ioff
head(11)=10000; %iscale
head(49)=-1;
head(50)=0;
head(51)=1;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/ft-E2T-' num2str(day) '.sir'],ftav,head,0,descrip,iaopt);

gridsurfav(isnan(gridsurfav)) = -1;
head(49)=-1;
head(50)=0;
head(51)=1;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/gsstatus-E2T-' num2str(day) '.sir'],gridsurfav,head,0,descrip,iaopt);

radwaterfracav(isnan(radwaterfracav)) = -1;
head(49)=-1;
head(50)=0;
head(51)=1;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/rwfrac-E2T-' num2str(day) '.sir'],radwaterfracav,head,0,descrip,iaopt);

qualop1av(isnan(qualop1av)) = -1;
qualop2av(isnan(qualop2av)) = -1;
qualop3av(isnan(qualop3av)) = -1;
qualop4av(isnan(qualop4av)) = -1;
qualop5av(isnan(qualop5av)) = -1;
head(10)=-1; %ioff
head(11)=1000; %iscale
head(49)=-1;
head(50)=0;
head(51)=13;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/qualop1-E2T-' num2str(day) '.sir'],qualop1av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/qualop2-E2T-' num2str(day) '.sir'],qualop2av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/qualop3-E2T-' num2str(day) '.sir'],qualop3av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/qualop4-E2T-' num2str(day) '.sir'],qualop4av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/qualop5-E2T-' num2str(day) '.sir'],qualop5av,head,0,descrip,iaopt);

smop1av(isnan(smop1av)) = -1;
smop2av(isnan(smop2av)) = -1;
smop3av(isnan(smop3av)) = -1;
smop4av(isnan(smop4av)) = -1;
smop5av(isnan(smop5av)) = -1;
head(10)=-1; %ioff
head(11)=10000; %iscale
head(49)=-1;
head(50)=0;
head(51)=0.5;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/smop1-E2T-' num2str(day) '.sir'],smop1av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/smop2-E2T-' num2str(day) '.sir'],smop2av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/smop3-E2T-' num2str(day) '.sir'],smop3av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/smop4-E2T-' num2str(day) '.sir'],smop4av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/smop5-E2T-' num2str(day) '.sir'],smop5av,head,0,descrip,iaopt);

statwaterfracav(isnan(statwaterfracav)) = -1;
head(49)=-1;
head(50)=0;
head(51)=1;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/statwfrac-E2T-' num2str(day) '.sir'],statwaterfracav,head,0,descrip,iaopt);

surfflagav(isnan(surfflagav)) = -1;
head(10)=-1; %ioff
head(11)=10; %iscale
head(49)=-1;
head(50)=0;
head(51)=2000;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/sflag-E2T-' num2str(day) '.sir'],surfflagav,head,0,descrip,iaopt);

surfwaterfracav(isnan(surfwaterfracav)) = -1;
head(10)=-1; %ioff
head(11)=10000; %iscale
head(49)=-1;
head(50)=0;
head(51)=1;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/surfwfrac-E2T-' num2str(day) '.sir'],surfwaterfracav,head,0,descrip,iaopt);

tbqualav(isnan(tbqualav)) = -1;
head(10)=-1; %ioff
head(11)=1; %iscale
head(49)=-1;
head(50)=0;
head(51)=65534;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/tbqual-E2T-' num2str(day) '.sir'],tbqualav,head,0,descrip,iaopt);

vopop1av(isnan(vopop1av)) = -1;
vopop2av(isnan(vopop2av)) = -1;
vopop3av(isnan(vopop3av)) = -1;
vopop4av(isnan(vopop4av)) = -1;
vopop5av(isnan(vopop5av)) = -1;
head(10)=-1; %ioff
head(11)=1000; %iscale
head(49)=-1;
head(50)=0;
head(51)=9;
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vopop1-E2T-' num2str(day) '.sir'],vopop1av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vopop2-E2T-' num2str(day) '.sir'],vopop2av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vopop3-E2T-' num2str(day) '.sir'],vopop3av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vopop4-E2T-' num2str(day) '.sir'],vopop4av,head,0,descrip,iaopt);
writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/ancillarysir/vopop5-E2T-' num2str(day) '.sir'],vopop5av,head,0,descrip,iaopt);
disp('Done writing data to SIR files');
end