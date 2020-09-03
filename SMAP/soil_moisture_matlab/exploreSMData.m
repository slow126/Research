function [ struct_out ] = exploreSMData( filename, ampm, plot )
%exploreSMData Explores the soil moisture HDF5, as well as ancillary data
%   Uses hdf5load to explore the contents, then optionally plots

smfulldata=hdf5load(filename);

if (ampm == 1)
%     latitude=smfulldata.Soil_Moisture_Retrieval_Data_AM.latitude;
%     latitude(latitude < -9000) = nan;
%     
%     longitude=smfulldata.Soil_Moisture_Retrieval_Data_AM.longitude;
%     longitude(longitude < -9000) = nan;
%     
%     albedo=smfulldata.Soil_Moisture_Retrieval_Data_AM.albedo;
%     albedo(albedo < -9000) = nan;
%     
%     incidence=smfulldata.Soil_Moisture_Retrieval_Data_AM.boresight_incidence;
%     incidence(incidence < -9000) = nan;
% 
%     ft_fraction=smfulldata.Soil_Moisture_Retrieval_Data_AM.freeze_thaw_fraction;
%     ft_fraction(ft_fraction < -9000) = nan;
% 
%     lc_class=smfulldata.Soil_Moisture_Retrieval_Data_AM.landcover_class;
%     lc_class(lc_class < -9000) = nan;
%     lc_class(lc_class == 254) = nan;
% 
%     lc_fraction=smfulldata.Soil_Moisture_Retrieval_Data_AM.landcover_class_fraction;
%     lc_fraction(lc_fraction < -9000) = nan;
%     
%     ret_qual=smfulldata.Soil_Moisture_Retrieval_Data_AM.retrieval_qual_flag;
%     ret_qual(ret_qual == 7) = nan;
% 
%     rwb_fraction=smfulldata.Soil_Moisture_Retrieval_Data_AM.radar_water_body_fraction;
%     rwb_fraction(rwb_fraction < -9000) = nan;
%     
%     swb_fraction=smfulldata.Soil_Moisture_Retrieval_Data_AM.static_water_body_fraction;
%     swb_fraction(swb_fraction < -9000) = nan;
% 
%     roughness=smfulldata.Soil_Moisture_Retrieval_Data_AM.roughness_coefficient;
%     roughness(roughness < -9000) = nan;

    SM=smfulldata.Soil_Moisture_Retrieval_Data_AM.soil_moisture;
    SM(SM < -9000) = nan;
    
    SMerr=smfulldata.Soil_Moisture_Retrieval_Data_AM.soil_moisture_error;
    SMerr(SMerr < -9000) = nan;

%     surf_temp=smfulldata.Soil_Moisture_Retrieval_Data_AM.surface_temperature;
%     surf_temp(surf_temp < -9000) = nan;
%     
%     surf_flag=smfulldata.Soil_Moisture_Retrieval_Data_AM.surface_flag;
%     surf_flag(surf_flag == 2047) = nan;
% 
%     tb_3=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_3_corrected;
%     tb_3(tb_3 < -9000) = nan;
%     
%     tb_qual3=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_3;
%     tb_qual3(tb_qual3 == 30719) = nan;
% 
%     tb_4=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_4_corrected;
%     tb_4(tb_4 < -9000) = nan;
%     
%     tb_qual4=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_4;
%     tb_qual4(tb_qual4 == 30719) = nan;
% 
%     tb_h=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_h_corrected;
%     tb_h(tb_h < -9000) = nan;
%     
%     tb_qualh=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_h;
%     tb_qualh(tb_qualh == 65535) = nan;
%     
%     tb_v=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_v_corrected;
%     tb_v(tb_v < -9000) = nan;
%     
%     tb_qualv=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_v;
%     tb_qualv(tb_qualv == 65535) = nan;
% 
%     veg_op=smfulldata.Soil_Moisture_Retrieval_Data_AM.vegetation_opacity;
%     veg_op(veg_op < -9000) = nan;
% 
%     vwc=smfulldata.Soil_Moisture_Retrieval_Data_AM.vegetation_water_content;
%     vwc(vwc < -9000) = nan;
%     vwc(vwc == 0) = nan;
elseif(ampm == 2)
%     latitude=smfulldata.Soil_Moisture_Retrieval_Data_PM.latitude_pm;
%     latitude(latitude < -9000) = nan;
%     
%     longitude=smfulldata.Soil_Moisture_Retrieval_Data_PM.longitude_pm;
%     longitude(longitude < -9000) = nan;
%     
%     albedo=smfulldata.Soil_Moisture_Retrieval_Data_PM.albedo_pm;
%     albedo(albedo < -9000) = nan;
%     
%     incidence=smfulldata.Soil_Moisture_Retrieval_Data_PM.boresight_incidence_pm;
%     incidence(incidence < -9000) = nan;
% 
%     ft_fraction=smfulldata.Soil_Moisture_Retrieval_Data_PM.freeze_thaw_fraction_pm;
%     ft_fraction(ft_fraction < -9000) = nan;
% 
%     lc_class=smfulldata.Soil_Moisture_Retrieval_Data_PM.landcover_class_pm;
%     lc_class(lc_class < -9000) = nan;
%     lc_class(lc_class == 254) = nan;
% 
%     lc_fraction=smfulldata.Soil_Moisture_Retrieval_Data_PM.landcover_class_fraction_pm;
%     lc_fraction(lc_fraction < -9000) = nan;
%     
%     ret_qual=smfulldata.Soil_Moisture_Retrieval_Data_PM.retrieval_qual_flag_pm;
%     ret_qual(ret_qual == 7) = nan;
% 
%     rwb_fraction=smfulldata.Soil_Moisture_Retrieval_Data_PM.radar_water_body_fraction_pm;
%     rwb_fraction(rwb_fraction < -9000) = nan;
%     
%     swb_fraction=smfulldata.Soil_Moisture_Retrieval_Data_PM.static_water_body_fraction_pm;
%     swb_fraction(swb_fraction < -9000) = nan;
% 
%     roughness=smfulldata.Soil_Moisture_Retrieval_Data_PM.roughness_coefficient_pm;
%     roughness(roughness < -9000) = nan;

    SM=smfulldata.Soil_Moisture_Retrieval_Data_PM.soil_moisture_pm;
    SM(SM < -9000) = nan;
    
    SMerr=smfulldata.Soil_Moisture_Retrieval_Data_PM.soil_moisture_error_pm;
    SMerr(SMerr < -9000) = nan;

%     surf_temp=smfulldata.Soil_Moisture_Retrieval_Data_PM.surface_temperature_pm;
%     surf_temp(surf_temp < -9000) = nan;
%     
%     surf_flag=smfulldata.Soil_Moisture_Retrieval_Data_PM.surface_flag_pm;
%     surf_flag(surf_flag == 2047) = nan;
% 
%     tb_3=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_3_corrected_pm;
%     tb_3(tb_3 < -9000) = nan;
%     
%     tb_qual3=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_qual_flag_3_pm;
%     tb_qual3(tb_qual3 == 30719) = nan;
% 
%     tb_4=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_4_corrected_pm;
%     tb_4(tb_4 < -9000) = nan;
%     
%     tb_qual4=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_qual_flag_4_pm;
%     tb_qual4(tb_qual4 == 30719) = nan;
% 
%     tb_h=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_h_corrected_pm;
%     tb_h(tb_h < -9000) = nan;
%     
%     tb_qualh=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_qual_flag_h_pm;
%     tb_qualh(tb_qualh == 65535) = nan;
%     
%     tb_v=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_v_corrected_pm;
%     tb_v(tb_v < -9000) = nan;
%     
%     tb_qualv=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_qual_flag_v_pm;
%     tb_qualv(tb_qualv == 65535) = nan;
% 
%     veg_op=smfulldata.Soil_Moisture_Retrieval_Data_PM.vegetation_opacity_pm;
%     veg_op(veg_op < -9000) = nan;
% 
%     vwc=smfulldata.Soil_Moisture_Retrieval_Data_PM.vegetation_water_content_pm;
%     vwc(vwc < -9000) = nan;
%     vwc(vwc == 0) = nan;
elseif(ampm == 3)
%     latitude=smfulldata.Soil_Moisture_Retrieval_Data_AM.latitude;
%     latitude(latitude < -9000) = nan;
%     latitude(isnan(latitude))=smfulldata.Soil_Moisture_Retrieval_Data_PM.latitude_pm(isnan(latitude));
%     latitude(latitude < -9000) = nan;
%     
%     longitude=smfulldata.Soil_Moisture_Retrieval_Data_AM.longitude;
%     longitude(longitude < -9000) = nan;
%     longitude(isnan(longitude))=smfulldata.Soil_Moisture_Retrieval_Data_PM.longitude_pm(isnan(longitude));
%     longitude(longitude < -9000) = nan;
%     
%     albedo=smfulldata.Soil_Moisture_Retrieval_Data_AM.albedo;
%     albedo(albedo < -9000) = nan;
%     albedo(isnan(albedo))=smfulldata.Soil_Moisture_Retrieval_Data_PM.albedo_pm(isnan(albedo));
%     albedo(albedo < -9000) = nan;
%     
%     incidence=smfulldata.Soil_Moisture_Retrieval_Data_AM.boresight_incidence;
%     incidence(incidence < -9000) = nan;
%     incidence(isnan(incidence))=smfulldata.Soil_Moisture_Retrieval_Data_PM.boresight_incidence_pm(isnan(incidence));
%     incidence(incidence < -9000) = nan;
% 
%     ft_fraction=smfulldata.Soil_Moisture_Retrieval_Data_AM.freeze_thaw_fraction;
%     ft_fraction(ft_fraction < -9000) = nan;
%     ft_fraction(isnan(ft_fraction))=smfulldata.Soil_Moisture_Retrieval_Data_PM.freeze_thaw_fraction_pm(isnan(ft_fraction));
%     ft_fraction(ft_fraction < -9000) = nan;
% 
%     lc_class=smfulldata.Soil_Moisture_Retrieval_Data_AM.landcover_class;
%     lc_class(lc_class == 254)=smfulldata.Soil_Moisture_Retrieval_Data_PM.landcover_class_pm(lc_class == 254);
%     lc_class(lc_class == 254) = nan;
% 
%     lc_fraction=smfulldata.Soil_Moisture_Retrieval_Data_AM.landcover_class_fraction;
%     lc_fraction(lc_fraction < -9000) = nan;
%     lc_fraction(isnan(lc_fraction))=smfulldata.Soil_Moisture_Retrieval_Data_PM.landcover_class_fraction_pm(isnan(lc_fraction));
%     lc_fraction(lc_fraction < -9000) = nan;
%     
%     ret_qual=smfulldata.Soil_Moisture_Retrieval_Data_AM.retrieval_qual_flag;
%     ret_qual(ret_qual == 7)=smfulldata.Soil_Moisture_Retrieval_Data_PM.retrieval_qual_flag_pm(ret_qual == 7);
%     ret_qual(ret_qual == 7) = nan;
% 
%     rwb_fraction=smfulldata.Soil_Moisture_Retrieval_Data_AM.radar_water_body_fraction;
%     rwb_fraction(rwb_fraction < -9000) = nan;
%     rwb_fraction(isnan(rwb_fraction))=smfulldata.Soil_Moisture_Retrieval_Data_PM.radar_water_body_fraction_pm(isnan(rwb_fraction));
%     rwb_fraction(rwb_fraction < -9000) = nan;
%     
%     swb_fraction=smfulldata.Soil_Moisture_Retrieval_Data_AM.static_water_body_fraction;
%     swb_fraction(swb_fraction < -9000) = nan;
%     swb_fraction(isnan(swb_fraction))=smfulldata.Soil_Moisture_Retrieval_Data_PM.static_water_body_fraction_pm(isnan(swb_fraction));
%     swb_fraction(swb_fraction < -9000) = nan;
% 
%     roughness=smfulldata.Soil_Moisture_Retrieval_Data_AM.roughness_coefficient;
%     roughness(roughness < -9000) = nan;
%     roughness(isnan(roughness))=smfulldata.Soil_Moisture_Retrieval_Data_PM.roughness_coefficient_pm(isnan(roughness));
%     roughness(roughness < -9000) = nan;

    SM=smfulldata.Soil_Moisture_Retrieval_Data_AM.soil_moisture;
    SM(SM < -9000) = nan;
    SM(isnan(SM))=smfulldata.Soil_Moisture_Retrieval_Data_PM.soil_moisture_pm(isnan(SM));
    SM(SM < -9000) = nan;
    
    SMerr=smfulldata.Soil_Moisture_Retrieval_Data_AM.soil_moisture_error;
    SMerr(SMerr < -9000) = nan;
    SMerr(isnan(SMerr))=smfulldata.Soil_Moisture_Retrieval_Data_PM.soil_moisture_error_pm(isnan(SMerr));
    SMerr(SMerr < -9000) = nan;

%     surf_temp=smfulldata.Soil_Moisture_Retrieval_Data_AM.surface_temperature;
%     surf_temp(surf_temp < -9000) = nan;
%     surf_temp(isnan(surf_temp))=smfulldata.Soil_Moisture_Retrieval_Data_PM.surface_temperature_pm(isnan(surf_temp));
%     surf_temp(surf_temp < -9000) = nan;
%     
%     surf_flag=smfulldata.Soil_Moisture_Retrieval_Data_AM.surface_flag;
%     surf_flag(surf_flag == 2047)=smfulldata.Soil_Moisture_Retrieval_Data_PM.surface_flag_pm(surf_flag == 2047);
%     surf_flag(surf_flag == 2047) = nan;
% 
%     tb_3=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_3_corrected;
%     tb_3(tb_3 < -9000) = nan;
%     tb_3(isnan(tb_3))=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_3_corrected_pm(isnan(tb_3));
%     tb_3(tb_3 < -9000) = nan;
%     
%     tb_qual3=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_3;
%     tb_qual3(tb_qual3 == 30719)=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_qual_flag_3_pm(tb_qual3 == 30719);
%     tb_qual3(tb_qual3 == 30719) = nan;
% 
%     tb_4=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_4_corrected;
%     tb_4(tb_4 < -9000) = nan;
%     tb_4(isnan(tb_4))=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_4_corrected_pm(isnan(tb_4));
%     tb_4(tb_4 < -9000) = nan;
%     
%     tb_qual4=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_4;
%     tb_qual4(tb_qual4 == 30719)=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_qual_flag_4_pm(tb_qual4 == 30719);
%     tb_qual4(tb_qual4 == 30719) = nan;
% 
%     tb_h=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_h_corrected;
%     tb_h(tb_h < -9000) = nan;
%     tb_h(isnan(tb_h))=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_h_corrected_pm(isnan(tb_h));
%     tb_h(tb_h < -9000) = nan;
%     
%     tb_qualh=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_h;
%     tb_qualh(tb_qualh == 65535)=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_qual_flag_h_pm(tb_qualh == 65535);
%     tb_qualh(tb_qualh == 65535) = nan;
%     
%     tb_v=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_v_corrected;
%     tb_v(tb_v < -9000) = nan;
%     tb_v(isnan(tb_v))=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_v_corrected_pm(isnan(tb_v));
%     tb_v(tb_v < -9000) = nan;
%     
%     tb_qualv=smfulldata.Soil_Moisture_Retrieval_Data_AM.tb_qual_flag_v;
%     tb_qualv(tb_qualv == 65535)=smfulldata.Soil_Moisture_Retrieval_Data_PM.tb_qual_flag_v_pm(tb_qualv == 65535);
%     tb_qualv(tb_qualv == 65535) = nan;
% 
%     veg_op=smfulldata.Soil_Moisture_Retrieval_Data_AM.vegetation_opacity;
%     veg_op(veg_op < -9000) = nan;
%     veg_op(isnan(veg_op))=smfulldata.Soil_Moisture_Retrieval_Data_PM.vegetation_opacity_pm(isnan(veg_op));
%     veg_op(veg_op < -9000) = nan;
% 
%     vwc=smfulldata.Soil_Moisture_Retrieval_Data_AM.vegetation_water_content;
%     vwc(vwc < -9000) = nan;
%     vwc(vwc == 0) = nan;
%     vwc(isnan(vwc))=smfulldata.Soil_Moisture_Retrieval_Data_PM.vegetation_water_content_pm(isnan(vwc));
%     vwc(vwc < -9000) = nan;
%     vwc(vwc == 0) = nan;
    
else
    fprintf("Invalid AM/PM Selection in exploreSMData\n");
end

if (plot == 1)
%     figure
%     imagesc(flipud(rot90(albedo)));
%     title('Albedo');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(incidence)));
%     title('Boresight Incidence');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(ft_fraction)));
%     title('Freeze Thaw Fraction');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(reshape(lc_class(1,:,:),964,406))));
%     title('Land Cover Class1');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(reshape(lc_class(2,:,:),964,406))));
%     title('Land Cover Class2');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(reshape(lc_class(3,:,:),964,406))));
%     title('Land Cover Class3');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(reshape(lc_fraction(1,:,:),964,406))));
%     title('Land Cover Fraction1');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(reshape(lc_fraction(2,:,:),964,406))));
%     title('Land Cover Fraction2');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(reshape(lc_fraction(3,:,:),964,406))));
%     title('Land Cover Fraction3');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(ret_qual)));
%     title('Retrieval Quality');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(roughness)));
%     title('Roughness');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(rwb_fraction)));
%     title('RWB Fraction');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(swb_fraction)));
%     title('SWB Fraction');
%     colorbar
    
    figure
    imagesc(flipud(rot90(SM)));
    title('Soil Moisture');
    colorbar
    
    figure
    imagesc(flipud(rot90(SMerr)));
    title('Soil Moisture Error');
    colorbar
    
%     figure
%     imagesc(flipud(rot90(surf_temp)));
%     title('Surface Temperature');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(surf_flag)));
%     title('Surface Flag');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(tb_3)));
%     title('TB_3');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(tb_qual3)));
%     title('TB_3 Quality');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(tb_4)));
%     title('TB_4');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(tb_qual4)));
%     title('TB_4 Quality');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(tb_h)));
%     title('TB_H');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(tb_qualh)));
%     title('TB_H Quality');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(tb_v)));
%     title('TB_V');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(tb_qualv)));
%     title('TB_V Quality');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(veg_op)));
%     title('Vegetation Opacity');
%     colorbar
%     
%     figure
%     imagesc(flipud(rot90(vwc)));
%     title('Vegetation Water Content');
%     colorbar

end

% struct_out=struct('latitude',latitude','longitude',longitude','albedo',albedo,'incidence',incidence,'ft_fraction',ft_fraction,'lc_class',lc_class,'lc_fraction',lc_fraction,'ret_qual',ret_qual,'roughness',roughness,'rwb_fraction',rwb_fraction,'swb_fraction',swb_fraction,'SM',SM,'SMerr',SMerr,'surf_temp',surf_temp,'surf_flag',surf_flag,'tb_3',tb_3,'tb_4',tb_4,'tb_h',tb_h,'tb_v',tb_v,'tb_qual3',tb_qual3,'tb_qual4',tb_qual4,'tb_qualh',tb_qualh,'tb_qualv',tb_qualv,'veg_op',veg_op,'vwc',vwc);

end

