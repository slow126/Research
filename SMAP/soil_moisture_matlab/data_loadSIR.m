function [tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav] = data_loadSIR(year,day,showplottb,res)
%Loads all of the data out of the HDF5 Files specified in the lists found
%below. This data is used in soilMoistureMap_v3.m to recreate the NSIDC
%SMAP soil moisture retrieval algorithm. Uses an approach
%to map to EASE-2 Grid where multiple measurements, but data should already be EASE-2 gridded so 
%averaging shouldn't affect much.  

%% Options and EASE-2 Info
extradata=0;
pol='v'; % h = horizontal, v = vertical (NASA L2B SM use vertical)
tbopt=2; % 1 = NSIDC Tb, 2 = rSIR Tb
%res 1=3km Sentinel/SMAP ancillary, 2=9km SMAP ancillary, 3=36km SMAP ancillary

%% Soil Moisture loading

if(res==1)
    if ismac
        sirfolder=['smData/' num2str(year) '/' num2str(day) '/ancillarysir/'];
        smData_dir = 'smData/';
    elseif isunix
        sirfolder=['/media/spencer/Scratch_Disk/MATLAB/SMAP/soil_moisture_matlab/smData/' num2str(year) '/' num2str(day) '/ancillarysir/'];
        smData_dir = '/media/spencer/Scratch_Disk/MATLAB/SMAP/soil_moisture_matlab/smData/';
    end
    
    if(tbopt==1)
        [tbav, head, descrip, iaopt]=loadsir([sirfolder 'tb_3km-' num2str(day) '.sir']);
        [incav, head, descrip, iaopt]=loadsir([sirfolder 'inc_3km-' num2str(day) '.sir']);
    else
        [tbav, head, descrip, iaopt]=loadsir([sirfolder 'tb2_3km-' num2str(day) '.sir']);
        [incav, head, descrip, iaopt]=loadsir([sirfolder 'inc2_3km-' num2str(day) '.sir']);
    end
    
    [albav, head, descrip, iaopt]=loadsir([sirfolder 'alb_3km-' num2str(day) '.sir']);
    [qualav, head, descrip, iaopt]=loadsir([sirfolder 'retqual_3km-' num2str(day) '.sir']);
    [clayf, head, descrip, iaopt]=loadsir(strcat(smData_dir, 'clayf_3km.sir'));
    [vopav, head, descrip, iaopt]=loadsir([sirfolder 'vop_3km-' num2str(day) '.sir']);
    [rghav, head, descrip, iaopt]=loadsir([sirfolder 'rgh_3km-' num2str(day) '.sir']);
    [smav, head, descrip, iaopt]=loadsir([sirfolder 'sm_3km-' num2str(day) '.sir']);
    [vwcav, head, descrip, iaopt]=loadsir([sirfolder 'vwc_3km-' num2str(day) '.sir']);
    [tempav, head, descrip, iaopt]=loadsir([sirfolder 'surftemp_3km-' num2str(day) '.sir']);
    [wfracav, head, descrip, iaopt]=loadsir([sirfolder 'wfrac_3km-' num2str(day) '.sir']);
    
    clayf(clayf < 0 | clayf > 1)=NaN;
    tbav(tbav < 0 | tbav > 330)=NaN;
    albav(albav < 0 | albav > 1)=NaN;
    incav(incav < 0 | incav > 90)=NaN;
    qualav(qualav < 0 | qualav > 255)=NaN;
    vopav(vopav < 0 | vopav > 1)=NaN;
    rghav(rghav < 0 | rghav > 2)=NaN;
    smav(smav < 0.02 | smav > 0.6)=NaN;
    vwcav(vwcav < 0 | vwcav > 30)=NaN;
    tempav(tempav < 200 | tempav > 350)=NaN;
    wfracav(wfracav < 0 | wfracav > 1)=NaN;
    
elseif(res==2)
    sirfolder=['smData/' num2str(year) '/' num2str(day) '/ancillarysir/'];
    if(tbopt==1)
        [tbav, head, descrip, iaopt]=loadsir([sirfolder 'tb-E2T-' num2str(day) '.sir']);
        [incav, head, descrip, iaopt]=loadsir([sirfolder 'inc-E2T-' num2str(day) '.sir']);
    else
        [tbav, head, descrip, iaopt]=loadsir([sirfolder 'tb2-E2T-' num2str(day) '.sir']);
        [incav, head, descrip, iaopt]=loadsir([sirfolder 'inc2-E2T-' num2str(day) '.sir']);
    end
    
    [albav, head, descrip, iaopt]=loadsir([sirfolder 'alb-E2T-' num2str(day) '.sir']);
    [qualav, head, descrip, iaopt]=loadsir([sirfolder 'retqual-E2T-' num2str(day) '.sir']);
    [clayf, head, descrip, iaopt]=loadsir(strcat(smData_dir, 'clayf.sir'));
    [vopav, head, descrip, iaopt]=loadsir([sirfolder 'vop-E2T-' num2str(day) '.sir']);
    [rghav, head, descrip, iaopt]=loadsir([sirfolder 'rgh-E2T-' num2str(day) '.sir']);
    [smav, head, descrip, iaopt]=loadsir([sirfolder 'sm-E2T-' num2str(day) '.sir']);
    [vwcav, head, descrip, iaopt]=loadsir([sirfolder 'vwc-E2T-' num2str(day) '.sir']);
    [tempav, head, descrip, iaopt]=loadsir([sirfolder 'surftemp-E2T-' num2str(day) '.sir']);
    [wfracav, head, descrip, iaopt]=loadsir([sirfolder 'wfrac-E2T-' num2str(day) '.sir']);
    
    clayf(clayf < 0 | clayf > 1)=NaN;
    tbav(tbav < 0 | tbav > 330)=NaN;
    albav(albav < 0 | albav > 1)=NaN;
    incav(incav < 0 | incav > 90)=NaN;
    qualav(qualav < 0 | qualav > 255)=NaN;
    vopav(vopav < 0 | vopav > 1)=NaN;
    rghav(rghav < 0 | rghav > 2)=NaN;
    smav(smav < 0.02 | smav > 0.5)=NaN;
    vwcav(vwcav < 0 | vwcav > 30)=NaN;
    tempav(tempav < 200 | tempav > 350)=NaN;
    wfracav(wfracav < 0 | wfracav > 1)=NaN;
elseif(res==3)
    sirfolder=['smData/' num2str(year) '/' num2str(day) '/ancillarysir/'];
    if(tbopt==1)
        [tbav, head, descrip, iaopt]=loadsir([sirfolder 'tb_36km-' num2str(day) '.sir']);
        [incav, head, descrip, iaopt]=loadsir([sirfolder 'inc_36km-' num2str(day) '.sir']);
    else
        [tbav, head, descrip, iaopt]=loadsir([sirfolder 'tb2_36km-' num2str(day) '.sir']);
        [incav, head, descrip, iaopt]=loadsir([sirfolder 'inc2_36km-' num2str(day) '.sir']);
    end
    
    [albav, head, descrip, iaopt]=loadsir([sirfolder 'alb_36km-' num2str(day) '.sir']);
    [qualav, head, descrip, iaopt]=loadsir([sirfolder 'retqual_36km-' num2str(day) '.sir']);
    [clayf, head, descrip, iaopt]=loadsir('smData/clayf_36km.sir');
    [vopav, head, descrip, iaopt]=loadsir([sirfolder 'vop_36km-' num2str(day) '.sir']);
    [rghav, head, descrip, iaopt]=loadsir([sirfolder 'rgh_36km-' num2str(day) '.sir']);
    [smav, head, descrip, iaopt]=loadsir([sirfolder 'sm_36km-' num2str(day) '.sir']);
    [vwcav, head, descrip, iaopt]=loadsir([sirfolder 'vwc_36km-' num2str(day) '.sir']);
    [tempav, ~, descrip, iaopt]=loadsir([sirfolder 'surftemp_36km-' num2str(day) '.sir']);
    [wfracav, head, descrip, iaopt]=loadsir([sirfolder 'wfrac_36km-' num2str(day) '.sir']);
    
    clayf(clayf < 0 | clayf > 1)=NaN;
    tbav(tbav < 0 | tbav > 330)=NaN;
    albav(albav < 0 | albav > 1)=NaN;
    incav(incav < 0 | incav > 90)=NaN;
    qualav(qualav < 0 | qualav > 255)=NaN;
    vopav(vopav < 0 | vopav > 1)=NaN;
    rghav(rghav < 0 | rghav > 2)=NaN;
    smav(smav < 0.02 | smav > 0.5)=NaN;
    vwcav(vwcav < 0 | vwcav > 30)=NaN;
    tempav(tempav < 200 | tempav > 350)=NaN;
    wfracav(wfracav < 0 | wfracav > 1)=NaN;
end

%% Plot Figures

if showplottb
    figure
    imagesc(smav);
%     colormap jet(128);
    colorbar;
    title('SM Image');
    
    figure
    imagesc(tempav);
    colorbar;
    title('Temperature Image');
    
    figure
    imagesc(tbav,[250 320]);
%     colormap jet(128);
    colorbar;
    title('Brightness Temperature Image - from SIR file');
    
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
    
    if extradata
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

end

% C=jet(256);
% maxsm=.5;
% minsm=.05;
% smav=(smav-minsm)/(maxsm-minsm);
% smav(isnan(smav))=0;
% imwrite(im2uint8(smav),C,'/auto/temp/brown/Downloads/tb2sm_sm2.jpg');
% maxtb=320;
% mintb=250;
% tbav=(tbav-mintb)/(maxtb-mintb);
% tbav(isnan(tbav))=0;
% imwrite(im2uint8(tbav),C,'/auto/temp/brown/Downloads/tb2sm_tb2.jpg');
