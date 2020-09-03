% Creates the Neural Networks which are used in wind vector retrieval

trainfiles=["/auto/temp/brown/smData/2016/5/SMAP_L3_SM_P_20160105_R16020_001.h5", ... %Winter 1
    "/auto/temp/brown/smData/2016/15/SMAP_L3_SM_P_20160115_R16020_001.h5", ... %Winter 2
    "/auto/temp/brown/smData/2016/95/SMAP_L3_SM_P_20160404_R16020_001.h5", ... %Spring 1
    "/auto/temp/brown/smData/2016/105/SMAP_L3_SM_P_20160414_R16020_001.h5", ... %Spring 2
    "/auto/temp/brown/smData/2016/185/SMAP_L3_SM_P_20160703_R16020_001.h5", ... %Summer 1
    "/auto/temp/brown/smData/2016/195/SMAP_L3_SM_P_20160713_R16020_001.h5", ... %Summer 2
    "/auto/temp/brown/smData/2016/280/SMAP_L3_SM_P_20161006_R16020_001.h5", ... %Fall 1
    "/auto/temp/brown/smData/2016/290/SMAP_L3_SM_P_20161016_R16020_001.h5" ... %Fall 2
    ];


              
for tfile=1:length(trainfiles)
%% Load Data
    fname=char(trainfiles(tfile));
    fprintf('reading file %s\n',fname);
    
    nsx = 406; %These are for 36 km resolution.
    nsy = 964;

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
    
    %% Neural Network Data Formatting
    validam=find(~isnan(smam) & ~isnan(tbam) & ~isnan(incam) & ~isnan(tempam) & ~isnan(vopam) & ~isnan(albam) & ~isnan(rgham) & (qualam==0 | qualam==8) & ~isnan(wfracam));
    validpm=find(~isnan(smpm) & ~isnan(tbpm) & ~isnan(incpm) & ~isnan(temppm) & ~isnan(voppm) & ~isnan(albpm) & ~isnan(rghpm) & (qualpm==0 | qualpm==8) & ~isnan(wfracpm));
    
    flatsm=[smam(validam); smpm(validpm)];
    flattemp=[tempam(validam); temppm(validpm)];
    flattb=[tbam(validam); tbpm(validpm)];
    flatalb=[albam(validam); albpm(validpm)];
    flatinc=[incam(validam); incpm(validpm)];
    flatvop=[vopam(validam); voppm(validpm)];
    flatrgh=[rgham(validam); rghpm(validpm)];
    flatwfrac=[wfracam(validam); wfracpm(validpm)];
    
    nnins=[flattb, flatinc, flattemp, flatvop, flatalb, flatrgh, flatwfrac];
    if(tfile==1)
        finalins=nnins;
        finalouts=flatsm;
    else
        finalins=[finalins; nnins];
        finalouts=[finalouts; flatsm];
    end
end

%% Neural Network Train and Testing, then saved
backstyle='trainlm';
% smhlneurons5=5;
% smhlneurons5_5=[5 5];
% smhlneurons10=10;
% smhlneurons10_10=[10 10];
% smhlneurons15=15;
% smhlneurons15_15=[15 15];
smhlneurons15_15_15=[15 15 15];
smhlneurons20=20;
smhlneurons20_20=[20 20];
smhlneurons20_20_20=[20 20 20];
smhlneurons25=25;
smhlneurons25_25=[25 25];

% fprintf("Creating Speed Neural Net 1.\n");
% smnet5=feedforwardnet(smhlneurons5,backstyle);
% smnet5.trainParam.epochs=1000;
% [smnet5, TR1]=train(smnet5,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 2.\n");
% smnet5_5=feedforwardnet(smhlneurons5_5,backstyle);
% smnet5_5.trainParam.epochs=1000;
% [smnet5_5, TR2]=train(smnet5_5,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 3.\n");
% smnet10=feedforwardnet(smhlneurons10,backstyle);
% smnet10.trainParam.epochs=1000;
% [smnet10, TR3]=train(smnet10,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 4.\n");
% smnet10_10=feedforwardnet(smhlneurons10_10,backstyle);
% smnet10_10.trainParam.epochs=1000;
% [smnet10_10, TR4]=train(smnet10_10,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 5.\n");
% smnet15=feedforwardnet(smhlneurons15,backstyle);
% smnet15.trainParam.epochs=1000;
% [smnet15, TR5]=train(smnet15,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 6.\n");
% smnet15_15=feedforwardnet(smhlneurons15_15,backstyle);
% smnet15_15.trainParam.epochs=1000;
% [smnet15_15, TR6]=train(smnet15_15,finalins',finalouts');

fprintf("Creating Speed Neural Net 7.\n");
smnet15_15_15=feedforwardnet(smhlneurons15_15_15,backstyle);
smnet15_15_15.trainParam.epochs=1000;
[smnet15_15_15, TR7]=train(smnet15_15_15,finalins',finalouts');

fprintf("Creating Speed Neural Net 8.\n");
smnet20=feedforwardnet(smhlneurons20,backstyle);
smnet20.trainParam.epochs=1000;
[smnet20, TR8]=train(smnet20,finalins',finalouts');

fprintf("Creating Speed Neural Net 9.\n");
smnet20_20=feedforwardnet(smhlneurons20_20,backstyle);
smnet20_20.trainParam.epochs=1000;
[smnet20_20, TR9]=train(smnet20_20,finalins',finalouts');

fprintf("Creating Speed Neural Net 10.\n");
smnet20_20_20=feedforwardnet(smhlneurons20_20_20,backstyle);
smnet20_20_20.trainParam.epochs=1000;
[smnet20_20_20, TR10]=train(smnet20_20_20,finalins',finalouts');

fprintf("Creating Speed Neural Net 11.\n");
smnet25=feedforwardnet(smhlneurons25,backstyle);
smnet25.trainParam.epochs=1000;
[smnet25, TR11]=train(smnet25,finalins',finalouts');

fprintf("Creating Speed Neural Net 12.\n");
smnet25_25=feedforwardnet(smhlneurons25_25,backstyle);
smnet25_25.trainParam.epochs=1000;
[smnet25_25, TR12]=train(smnet25_25,finalins',finalouts');


% save('smNets.mat','smnet5','smnet10','smnet15','smnet5_5','smnet10_10','smnet15_15');
save('smNets2.mat','smnet15_15_15','smnet20','smnet20_20','smnet20_20_20','smnet25','smnet25_25');
