%Creates a map of soil moisture from a TB image and proper ancillary data
clear;
year=2016;
day=10;
pol1=2;         % 1 - Horizontal, 2 - Vertical
ancilplot=0;    % Plot some of the ancillary data
compplot=0;     % Plot error vs. different variables


[tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav]=data_loadSIR(year,day,0,1);
disp('Loaded data');

[ nsy1 , nsx1 ] = size(tbav);
% nsx1=4000; %Only looking at North America
% nsy1=1600; %Only looking at North America

moisture_map=nan(nsy1,nsx1);
possible_mois = 0.05:.001:.5;

% We'll go pixel by pixel, but could do matrix math 
for picx=1:nsx1
    for picy=1:nsy1
        tb=tbav(picy,picx); %read the brightness temperature
        localtemp=tempav(picy,picx); %read the surface temperature
        vwc=vwcav(picy,picx); %read the vegetation water content
        albedo=albav(picy,picx); %read the scattering albedo
        vegop=vopav(picy,picx); %read the vegetation opacity
        inc=incav(picy,picx)*pi/180; %read the incidence angle
        roughness=rghav(picy,picx); %read the soil roughness
        quality=qualav(picy,picx); %read the retrieval quality
        localclay=clayf(picy,picx); %read the soil clay fraction
        
        emis=tb/localtemp; %calculate the rough emissivity
        
        if(isnan(tb) || isnan(localclay) || isnan(localtemp) ...
                || isnan(albedo) || isnan(vegop) || isnan(inc) || isnan(roughness) )%|| (quality ~= 0 && quality ~= 8) )%|| isnan(vwc)) %Not sure on the quality flag
            continue; %skip if we don't have all necessary info, or bad quality
        end
        
        % Vegetation and roughness correction
        h=roughness;
        cantrans=exp(-vegop); %Canopy transmissivity
        emis=(emis-1+cantrans^2+albedo-albedo*cantrans^2)/(cantrans^2+albedo*cantrans-albedo*cantrans^2); %remove vegetation effects
        emis=1-(1-emis)*exp(h*cos(inc)^2); %remove surface roughness effects
        
        if(isnan(emis))
            moisture_map(picy,picx)  = NaN;
            continue;
        end
        
        
        dielec=sm2dc(possible_mois,localclay*ones(size(possible_mois))); %Use dielectric mixing model
                                                                        %to convert possible soil
                                                                        %moistures to emissivities
        
        switch pol1 %Fresnel's equations to convert emissivity to dielectric constant
            case 1    % Horizontal
                poss_emis=1-abs((cos(inc) - sqrt(dielec - sin(inc)^2))./(cos(inc) + sqrt(dielec - sin(inc)^2))).^2;
            case 2    % Vertical - This is what is reported in NSIDC data
                poss_emis=1-abs((dielec*cos(inc) - sqrt(dielec - sin(inc)^2))./(dielec*cos(inc) + sqrt(dielec - sin(inc)^2))).^2;
            otherwise
                printf('Unrecognized polarization');
                exit();
        end
        
        [min_err, dif_ind] = min(abs(poss_emis-real(emis)));
        
        moisture_map(picy,picx)=possible_mois(dif_ind); %Store the final soil moisture value
    end
    if(mod(picx,100)==0)
        fprintf('%d\n',picx); %Just to track progress
    end
end

%% Here on is just creating different plots and maps

if ancilplot % Optionally plot some ancillary data
    maxim=max(tbav(:));
    figure(16)
    imagesc(tbav,[100 maxim]);
    title('Brightness Temperature');
    colorbar

    emissiv = bsxfun(@rdivide,tbav,tempav);
    figure(17)
    imagesc(emissiv);
    title('Emissivity');
    colorbar

    figure(18)
    imagesc(clayf);
    title('Clay Fraction');
    colorbar
    
    figure(19)
    imagesc(rghav);
    title('Soil Roughness');
    colorbar

    figure(20)
    imagesc(vwcav);
    title('VWC');
    colorbar

    figure(21)
    imagesc(tempav);
    title('Surface Temperature');
    colorbar
    
    if extradata
        figure(22)
        imagesc(ftav);
        colorbar;
        title('Freeze Thaw Image');
        
        figure(23)
        imagesc(gridsurfav);
        colorbar;
        title('Grid Surface Status Image');

        figure(24)
        imagesc(radwaterfracav);
        colorbar;
        title('Radar Water Body Fraction Image');

        figure(25)
        imagesc(qualop1av);
        colorbar;
        title('Retrieval Quality Option 1 Image');
        
        figure(26)
        imagesc(qualop2av);
        colorbar;
        title('Retrieval Quality Option 2 Image');
        
        figure(27)
        imagesc(qualop3av);
        colorbar;
        title('Retrieval Quality Option 3 Image');
        
        figure(28)
        imagesc(qualop4av);
        colorbar;
        title('Retrieval Quality Option 4 Image');
        
        figure(29)
        imagesc(qualop5av);
        colorbar;
        title('Retrieval Quality Option 5 Image');

        figure(30)
        imagesc(l2errav);
        colorbar;
        title('NSIDC Soil Moisture Error Image');

        figure(31)
        imagesc(smop1av);
        colorbar;
        title('Soil Moisture Option 1 Image');
        
        figure(32)
        imagesc(smop2av);
        colorbar;
        title('Soil Moisture Option 2 Image');
        
        figure(33)
        imagesc(smop3av);
        colorbar;
        title('Soil Moisture Option 3 Image');
        
        figure(34)
        imagesc(smop4av);
        colorbar;
        title('Soil Moisture Option 4 Image');
        
        figure(35)
        imagesc(smop5av);
        colorbar;
        title('Soil Moisture Option 5 Image');

        figure(36)
        imagesc(statwaterfracav);
        colorbar;
        title('Static Water Body Fraction Image');

        figure(37)
        imagesc(surfflagav);
        colorbar;
        title('Surface Flag Image');

        figure(38)
        imagesc(surfwaterfracav);
        colorbar;
        title('Surface Water Fraction MB Image');

        figure(39)
        imagesc(tbqualav);
        colorbar;
        title('TB Quality Image');

        figure(40)
        imagesc(vopop1av);
        colorbar;
        title('Vegetation Opacity Option 1 Image');
        
        figure(41)
        imagesc(vopop2av);
        colorbar;
        title('Vegetation Opacity Option 2 Image');
        
        figure(42)
        imagesc(vopop3av);
        colorbar;
        title('Vegetation Opacity Option 3 Image');
        
        figure(43)
        imagesc(vopop4av);
        colorbar;
        title('Vegetation Opacity Option 4 Image');
        
        figure(44)
        imagesc(vopop5av);
        colorbar;
        title('Vegetation Opacity Option 5 Image');
    end
end

%% Error plots and maps
% rmse=0;
error=smav-moisture_map;
rmse = sqrt(nanmean(reshape(error.^2,1,[])));

% myvec=moisture_map(~isnan(moisture_map) & ~isnan(smav));
% smvec=smav(~isnan(moisture_map) & ~isnan(smav));
% [myvec, sortinds]=sort(myvec);
% smvec=smvec(sortinds);
% lfit=polyfit(myvec,smvec,1);
% x1 = linspace(.05,0.5,100);
% f1 = polyval(lfit,x1);
% oddlim=1.05*x1+0.08;
% oddind=find((smav > 1.05*moisture_map + 0.08) | (smav < 0.75*moisture_map-.05));
% goodind=find(~((smav > 1.05*moisture_map + 0.08) | (smav < 0.75*moisture_map-.05)) & (qualav == 0 | qualav == 8));
% oddindmin=find((moisture_map == 0.05) & (smav > 0.05));
% goodindmin=find(~((moisture_map == 0.05) & (smav > 0.05)));
% oddindmax=find((moisture_map == 0.5) & (smav < 0.5));
% goodindmax=find(~((moisture_map == 0.5) & (smav < 0.5)));

figure%figure(1)
imagesc(moisture_map,[0 0.5]);
title(['My Soil Moisture Map (RMSE = ' num2str(rmse,3), ')']);
colorbar

figure%figure(2)
imagesc(smav(1:nsy1,1:nsx1),[0 0.5]);
title('NSIDC SM');
colorbar

% figure(3)
% hold on
% plot(moisture_map(goodind),smav(goodind),'.b');
% plot(moisture_map(oddind),smav(oddind),'.k');
% plot(x1,f1,'r');
% plot(x1,oddlim,'c');
% title(['NSIDC SM vs. My SM (y=' num2str(lfit(1),2) 'x+' num2str(lfit(2),2) ')']);
% xlabel('My SM');
% ylabel('NSIDC SM');
% xlim([0.05 0.5]);
% ylim([0.05 0.5]);
% hold off

% trouble=smav;
% trouble(goodind)=nan;
% figure(4)
% imagesc(trouble,[0 0.5]);
% title('Trouble Areas off x=y');
% colorbar
% 
% trouble2=smav;
% trouble2(goodindmin)=nan;
% figure(5)
% imagesc(trouble2,[0 0.5]);
% title('Trouble Areas Min');
% colorbar
% 
% trouble3=smav;
% trouble3(goodindmax)=nan;
% figure(6)
% imagesc(trouble3,[0 0.5]);
% title('Trouble Areas Max');
% colorbar
% 
% 
% figure(7)
% imagesc(error);
% title('NSIDC - My SM error');
% colorbar

if compplot
    figure(8)
    plot(vwcav(~isnan(vwcav) & ~isnan(error)),error(~isnan(vwcav) & ~isnan(error)),'.b')
    title('Error vs. VWC')
    colorbar

    figure(9)
    plot(albav(~isnan(albav) & ~isnan(error)),error(~isnan(albav) & ~isnan(error)),'.b')
    title('Error vs. Albedo')
    colorbar

    figure(10)
    plot(clayf(~isnan(clayf) & ~isnan(error)),error(~isnan(clayf) & ~isnan(error)),'.b')
    title('Error vs. Clay Fraction')
    colorbar

    figure(11)
    plot(incav(~isnan(incav) & ~isnan(error)),error(~isnan(incav) & ~isnan(error)),'.b')
    title('Error vs. Incidence')
    colorbar

    figure(12)
    plot(rghav(~isnan(rghav) & ~isnan(error)),error(~isnan(rghav) & ~isnan(error)),'.b')
    title('Error vs. Soil Roughness')
    colorbar

    figure(13)
    plot(tbav(~isnan(tbav) & ~isnan(error)),error(~isnan(tbav) & ~isnan(error)),'.b')
    title('Error vs. Brightness Temperature')
    colorbar

    figure(14)
    plot(tempav(~isnan(tempav) & ~isnan(error)),error(~isnan(tempav) & ~isnan(error)),'.b')
    title('Error vs. Surface Temperature')
    colorbar

    figure(15)
    plot(vopav(~isnan(vopav) & ~isnan(error)),error(~isnan(vopav) & ~isnan(error)),'.b')
    title('Error vs. Vegetation Opacity')
    colorbar

    if extradata
        figure(45)
        plot(ftav(~isnan(ftav) & ~isnan(error)),error(~isnan(ftav) & ~isnan(error)),'.b')
        title('Error vs. Freeze Thaw')
        colorbar

        figure(46)
        plot(gridsurfav(~isnan(gridsurfav) & ~isnan(error)),error(~isnan(gridsurfav) & ~isnan(error)),'.b')
        title('Error vs. Grid Surface Status')
        colorbar

        figure(47)
        plot(radwaterfracav(~isnan(radwaterfracav) & ~isnan(error)),error(~isnan(radwaterfracav) & ~isnan(error)),'.b')
        title('Error vs. Radar Water Body Fraction')
        colorbar

        figure(48)
        plot(qualop1av(~isnan(qualop1av) & ~isnan(error)),error(~isnan(qualop1av) & ~isnan(error)),'.b')
        title('Error vs. Retrieval Quality Option 1')
        colorbar

        figure(49)
        plot(qualop2av(~isnan(qualop2av) & ~isnan(error)),error(~isnan(qualop2av) & ~isnan(error)),'.b')
        title('Error vs. Retrieval Quality Option 2')
        colorbar

        figure(50)
        plot(qualop3av(~isnan(qualop3av) & ~isnan(error)),error(~isnan(qualop3av) & ~isnan(error)),'.b')
        title('Error vs. Retrieval Quality Option 3')
        colorbar

        figure(51)
        plot(qualop4av(~isnan(qualop4av) & ~isnan(error)),error(~isnan(qualop4av) & ~isnan(error)),'.b')
        title('Error vs. Retrieval Quality Option 4')
        colorbar

        figure(52)
        plot(qualop5av(~isnan(qualop5av) & ~isnan(error)),error(~isnan(qualop5av) & ~isnan(error)),'.b')
        title('Error vs. Retrieval Quality Option 5')
        colorbar

        figure(53)
        plot(l2errav(~isnan(l2errav) & ~isnan(error)),error(~isnan(l2errav) & ~isnan(error)),'.b')
        title('Error vs. Soil Moisture Error(?)')
        colorbar

        figure(54)
        plot(smop1av(~isnan(smop1av) & ~isnan(error)),error(~isnan(smop1av) & ~isnan(error)),'.b')
        title('Error vs. Soil Moisture Option 1')
        colorbar

        figure(55)
        plot(smop2av(~isnan(smop2av) & ~isnan(error)),error(~isnan(smop2av) & ~isnan(error)),'.b')
        title('Error vs. Soil Moisture Option 2')
        colorbar

        figure(56)
        plot(smop3av(~isnan(smop3av) & ~isnan(error)),error(~isnan(smop3av) & ~isnan(error)),'.b')
        title('Error vs. Soil Moisture Option 3')
        colorbar

        figure(57)
        plot(smop4av(~isnan(smop4av) & ~isnan(error)),error(~isnan(smop4av) & ~isnan(error)),'.b')
        title('Error vs. Soil Moisture Option 4')
        colorbar

        figure(58)
        plot(smop5av(~isnan(smop5av) & ~isnan(error)),error(~isnan(smop5av) & ~isnan(error)),'.b')
        title('Error vs. Soil Moisture Option 5')
        colorbar

        figure(59)
        plot(statwaterfracav(~isnan(statwaterfracav) & ~isnan(error)),error(~isnan(statwaterfracav) & ~isnan(error)),'.b')
        title('Error vs. Static Water Body Fraction')
        colorbar

        figure(60)
        plot(surfflagav(~isnan(surfflagav) & ~isnan(error)),error(~isnan(surfflagav) & ~isnan(error)),'.b')
        title('Error vs. Surface Flag')
        colorbar

        figure(61)
        plot(surfwaterfracav(~isnan(surfwaterfracav) & ~isnan(error)),error(~isnan(surfwaterfracav) & ~isnan(error)),'.b')
        title('Error vs. Surface Water Fraction MB')
        colorbar

        figure(62)
        plot(tbqualav(~isnan(tbqualav) & ~isnan(error)),error(~isnan(tbqualav) & ~isnan(error)),'.b')
        title('Error vs. TB Quality')
        colorbar

        figure(63)
        plot(vopop1av(~isnan(vopop1av) & ~isnan(error)),error(~isnan(vopop1av) & ~isnan(error)),'.b')
        title('Error vs. Vegetation Opacity Option 1')
        colorbar

        figure(64)
        plot(vopop2av(~isnan(vopop2av) & ~isnan(error)),error(~isnan(vopop2av) & ~isnan(error)),'.b')
        title('Error vs. Vegetation Opacity Option 2')
        colorbar

        figure(65)
        plot(vopop3av(~isnan(vopop3av) & ~isnan(error)),error(~isnan(vopop3av) & ~isnan(error)),'.b')
        title('Error vs. Vegetation Opacity Option 3')
        colorbar

        figure(66)
        plot(vopop4av(~isnan(vopop4av) & ~isnan(error)),error(~isnan(vopop4av) & ~isnan(error)),'.b')
        title('Error vs. Vegetation Opacity Option 4')
        colorbar

        figure(67)
        plot(vopop5av(~isnan(vopop5av) & ~isnan(error)),error(~isnan(vopop5av) & ~isnan(error)),'.b')
        title('Error vs. Vegetation Opacity Option 5')
        colorbar
    end
end

%% Optionally write data to sir
if 0
    fprintf('Writing map to SIR file\n');
    ancfolder = ['/auto/temp/brown/smData/2016/1/ancillarysir/'];
    sirfile = [ancfolder 'alb_3km-1.sir'];
    [~, head, descrip, iaopt]=loadsir(sirfile); %This is just to get the head, descrip,iaopt

    moisture_map(isnan(moisture_map)) = -1;
    head(10)=-1; %ioff
    head(11)=10000; %iscale
    head(49)=-1; %nodata
    head(50)=0.05; %vmin
    head(51)=0.5; %vmax
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/mysm2_3km_V-' num2str(day) '.sir'],moisture_map,head,0,descrip,iaopt);
end

disp('Done');