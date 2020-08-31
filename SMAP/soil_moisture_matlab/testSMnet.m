% Creates the Neural Networks which are used in soil moisture retrieval

whichplot=0; %Which of the files in trainfiles to plot (1 to length(trainfiles)). Set to 0 for no plotting.

trainfiles=["/auto/temp/brown/smData/2016/2/SMAP_L3_SM_P_20160102_R16020_001.h5", ... %Winter 1
    "/auto/temp/brown/smData/2016/25/SMAP_L3_SM_P_20160125_R16020_001.h5", ... %Winter 2
    "/auto/temp/brown/smData/2016/100/SMAP_L3_SM_P_20160409_R16020_001.h5", ... %Spring 1
    "/auto/temp/brown/smData/2016/112/SMAP_L3_SM_P_20160421_R16020_001.h5", ... %Spring 2
    "/auto/temp/brown/smData/2016/190/SMAP_L3_SM_P_20160708_R16020_001.h5", ... %Summer 1
    "/auto/temp/brown/smData/2016/210/SMAP_L3_SM_P_20160728_R16020_001.h5", ... %Summer 2
    "/auto/temp/brown/smData/2016/278/SMAP_L3_SM_P_20161004_R16020_001.h5", ... %Fall 1
    "/auto/temp/brown/smData/2016/296/SMAP_L3_SM_P_20161022_R16020_001.h5" ... %Fall 2
    ];

load('smNets.mat');

amrmse=zeros(length(trainfiles),6);
pmrmse=zeros(length(trainfiles),6);
for tfile=1:length(trainfiles)
%% Load Data
    fname=char(trainfiles(tfile));
    fprintf('reading file %s\n',fname);
    
    smam1=nan(964,406);
    smam2=nan(964,406); 
    smam3=nan(964,406); 
    smam4=nan(964,406); 
    smam5=nan(964,406); 
    smam6=nan(964,406);
    smpm1=nan(964,406);
    smpm2=nan(964,406); 
    smpm3=nan(964,406); 
    smpm4=nan(964,406); 
    smpm5=nan(964,406); 
    smpm6=nan(964,406);

    %Load AM Data
    smam = h5read(fname,'/Soil_Moisture_Retrieval_Data_AM/soil_moisture');
    tempam = h5read(fname,'/Soil_Moisture_Retrieval_Data_AM/surface_temperature');
    tbam = h5read(fname,'/Soil_Moisture_Retrieval_Data_AM/tb_v_corrected');
    albam = h5read(fname,'/Soil_Moisture_Retrieval_Data_AM/albedo');
    incam = h5read(fname,'/Soil_Moisture_Retrieval_Data_AM/boresight_incidence');
    rgham = h5read(fname,'/Soil_Moisture_Retrieval_Data_AM/roughness_coefficient');
    vopam = h5read(fname,'/Soil_Moisture_Retrieval_Data_AM/vegetation_opacity');
    qualam = h5read(fname,'/Soil_Moisture_Retrieval_Data_AM/retrieval_qual_flag');
    wfracam = h5read(fname,'/Soil_Moisture_Retrieval_Data_AM/radar_water_body_fraction');
    
    %Load PM Data
    smpm = h5read(fname,'/Soil_Moisture_Retrieval_Data_PM/soil_moisture_pm');
    temppm = h5read(fname,'/Soil_Moisture_Retrieval_Data_PM/surface_temperature_pm');
    tbpm = h5read(fname,'/Soil_Moisture_Retrieval_Data_PM/tb_v_corrected_pm');
    albpm = h5read(fname,'/Soil_Moisture_Retrieval_Data_PM/albedo_pm');
    incpm = h5read(fname,'/Soil_Moisture_Retrieval_Data_PM/boresight_incidence_pm');
    rghpm = h5read(fname,'/Soil_Moisture_Retrieval_Data_PM/roughness_coefficient_pm');
    voppm = h5read(fname,'/Soil_Moisture_Retrieval_Data_PM/vegetation_opacity_pm');
    qualpm = h5read(fname,'/Soil_Moisture_Retrieval_Data_PM/retrieval_qual_flag_pm');
    wfracpm = h5read(fname,'/Soil_Moisture_Retrieval_Data_PM/radar_water_body_fraction_pm');
    
    % Replace the fill value with NaN.
    smam(smam==double(-9999)) = NaN;
    tempam(tempam==double(-9999)) = NaN;
    tbam(tbam==double(-9999)) = NaN;
    albam(albam==double(-9999)) = NaN;
    incam(incam==double(-9999)) = NaN;
    rgham(rgham==double(-9999)) = NaN;
    vopam(vopam==double(-9999)) = NaN;
    qualam(qualam==double(65534)) = NaN;
    wfracam(wfracam==double(65534)) = NaN;
    
    smpm(smpm==double(-9999)) = NaN;
    temppm(temppm==double(-9999)) = NaN;
    tbpm(tbpm==double(-9999)) = NaN;
    albpm(albpm==double(-9999)) = NaN;
    incpm(incpm==double(-9999)) = NaN;
    rghpm(rghpm==double(-9999)) = NaN;
    voppm(voppm==double(-9999)) = NaN;
    qualpm(qualpm==double(65534)) = NaN;
    wfracpm(wfracpm==double(65534)) = NaN;
    
    % Replace the invalid range values with NaN.
    smam(smam < double(0.02)) = NaN;
    smam(smam > double(0.5)) = NaN;
    tempam(tempam < double(0)) = NaN;
    tempam(tempam > double(350)) = NaN;
    tbam(tbam < double(0)) = NaN;
    tbam(tbam > double(330)) = NaN;
    albam(albam < double(0)) = NaN;
    albam(albam > double(1)) = NaN;
    incam(incam < double(0)) = NaN;
    incam(incam > double(90)) = NaN;
    rgham(rgham < double(0)) = NaN;
    rgham(rgham > double(1)) = NaN;
    vopam(vopam < double(0)) = NaN;
    vopam(vopam > double(10)) = NaN;
    wfracam(wfracam < double(0)) = NaN;
    wfracam(wfracam > double(1)) = NaN;

    smpm(smpm < double(0.02)) = NaN;
    smpm(smpm > double(0.5)) = NaN;
    temppm(temppm < double(0)) = NaN;
    temppm(temppm > double(350)) = NaN;
    tbpm(tbpm < double(0)) = NaN;
    tbpm(tbpm > double(330)) = NaN;
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
    
    %% Make SM Map with Neural Network
    for x=1:406
        for y=1:964
            validam=(~isnan(smam(y,x)) & ~isnan(tbam(y,x)) & ~isnan(incam(y,x)) & ~isnan(tempam(y,x)) & ~isnan(vopam(y,x)) & ~isnan(albam(y,x)) & ~isnan(rgham(y,x)) & (qualam(y,x)==0 | qualam(y,x)==8) & ~isnan(wfracam(y,x)));
            validpm=(~isnan(smpm(y,x)) & ~isnan(tbpm(y,x)) & ~isnan(incpm(y,x)) & ~isnan(temppm(y,x)) & ~isnan(voppm(y,x)) & ~isnan(albpm(y,x)) & ~isnan(rghpm(y,x)) & (qualpm(y,x)==0 | qualpm(y,x)==8) & ~isnan(wfracpm(y,x)));

            if(validam)
                amin=[tbam(y,x), incam(y,x), tempam(y,x), vopam(y,x), albam(y,x), rgham(y,x), wfracam(y,x)];
                smam1(y,x)=smnet5(amin');
                smam2(y,x)=smnet5_5(amin');
                smam3(y,x)=smnet10(amin');
                smam4(y,x)=smnet10_10(amin');
                smam5(y,x)=smnet15(amin');
                smam6(y,x)=smnet15_15(amin');
            end
            if(validpm)
                pmin=[tbpm(y,x), incpm(y,x), temppm(y,x), voppm(y,x), albpm(y,x), rghpm(y,x), wfracpm(y,x)];
                smpm1(y,x)=smnet5(pmin');
                smpm2(y,x)=smnet5_5(pmin');
                smpm3(y,x)=smnet10(pmin');
                smpm4(y,x)=smnet10_10(pmin');
                smpm5(y,x)=smnet15(pmin');
                smpm6(y,x)=smnet15_15(pmin');
            end
        end
    end
%% Compare the NN SM to the Current Model
    fprintf("Creating comparison histograms.\n");
    smamdif1=abs(smam1-smam);
    smamdif2=abs(smam2-smam);
    smamdif3=abs(smam3-smam);
    smamdif4=abs(smam4-smam);
    smamdif5=abs(smam5-smam);
    smamdif6=abs(smam6-smam);
    smpmdif1=abs(smpm1-smpm);
    smpmdif2=abs(smpm2-smpm);
    smpmdif3=abs(smpm3-smpm);
    smpmdif4=abs(smpm4-smpm);
    smpmdif5=abs(smpm5-smpm);
    smpmdif6=abs(smpm6-smpm);
    validam=find(~isnan(smamdif1) & ~isnan(smamdif2) & ~isnan(smamdif3) & ~isnan(smamdif4) & ~isnan(smamdif5) & ~isnan(smamdif6));
    validpm=find(~isnan(smpmdif1) & ~isnan(smpmdif2) & ~isnan(smpmdif3) & ~isnan(smpmdif4) & ~isnan(smpmdif5) & ~isnan(smpmdif6));
    amrmse(tfile,1)=sqrt(sum(smamdif1(validam).^2)/length(validam));
    amrmse(tfile,2)=sqrt(sum(smamdif2(validam).^2)/length(validam));
    amrmse(tfile,3)=sqrt(sum(smamdif3(validam).^2)/length(validam));
    amrmse(tfile,4)=sqrt(sum(smamdif4(validam).^2)/length(validam));
    amrmse(tfile,5)=sqrt(sum(smamdif5(validam).^2)/length(validam));
    amrmse(tfile,6)=sqrt(sum(smamdif6(validam).^2)/length(validam));
    pmrmse(tfile,1)=sqrt(sum(smpmdif1(validpm).^2)/length(validpm));
    pmrmse(tfile,2)=sqrt(sum(smpmdif2(validpm).^2)/length(validpm));
    pmrmse(tfile,3)=sqrt(sum(smpmdif3(validpm).^2)/length(validpm));
    pmrmse(tfile,4)=sqrt(sum(smpmdif4(validpm).^2)/length(validpm));
    pmrmse(tfile,5)=sqrt(sum(smpmdif5(validpm).^2)/length(validpm));
    pmrmse(tfile,6)=sqrt(sum(smpmdif6(validpm).^2)/length(validpm));

    if(tfile==whichplot)
        figure;
        imagesc(smamdif1,[0 1]);
        title(['NN(1L\_5) AM SM Error Map RMSE=' num2str(amrmse(tfile,1),4)]);
        colorbar
        
        figure;
        imagesc(smpmdif1,[0 1]);
        title(['NN(1L\_5) PM SM Error Map RMSE=' num2str(pmrmse(tfile,1),4)]);
        colorbar
        
        figure;
        imagesc(smamdif2,[0 1]);
        title(['NN(2L\_5\_5) AM SM Error Map RMSE=' num2str(amrmse(tfile,2),4)]);
        colorbar
        
        figure;
        imagesc(smpmdif2,[0 1]);
        title(['NN(2L\_5\_5) PM SM Error Map RMSE=' num2str(pmrmse(tfile,2),4)]);
        colorbar
        
        figure;
        imagesc(smamdif3,[0 1]);
        title(['NN(1L\_10) AM SM Error Map RMSE=' num2str(amrmse(tfile,3),4)]);
        colorbar
        
        figure;
        imagesc(smpmdif3,[0 1]);
        title(['NN(1L\_10) PM SM Error Map RMSE=' num2str(pmrmse(tfile,3),4)]);
        colorbar
        
        figure;
        imagesc(smamdif4,[0 1]);
        title(['NN(2L\_10\_10) AM SM Error Map RMSE=' num2str(amrmse(tfile,4),4)]);
        colorbar
        
        figure;
        imagesc(smpmdif4,[0 1]);
        title(['NN(2L\_10\_10) PM SM Error Map RMSE=' num2str(pmrmse(tfile,4),4)]);
        colorbar
        
        figure;
        imagesc(smamdif5,[0 1]);
        title(['NN(1L\_15) AM SM Error Map RMSE=' num2str(amrmse(tfile,5),4)]);
        colorbar
        
        figure;
        imagesc(smpmdif5,[0 1]);
        title(['NN(1L\_15) PM SM Error Map RMSE=' num2str(pmrmse(tfile,5),4)]);
        colorbar
        
        figure;
        imagesc(smamdif6,[0 1]);
        title(['NN(2L\_15\_15) AM SM Error Map RMSE=' num2str(amrmse(tfile,6),4)]);
        colorbar
        
        figure;
        imagesc(smpmdif6,[0 1]);
        title(['NN(2L\_15\_15) PM SM Error Map RMSE=' num2str(pmrmse(tfile,6),4)]);
        colorbar
    end
end

figure
imagesc(amrmse);
title('AM RMSE');
xlabel('NN #');
ylabel('File #');
colorbar;

figure
imagesc(pmrmse);
title('PM RMSE');
xlabel('NN #');
ylabel('File #');
colorbar;