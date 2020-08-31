%Creates a map of soil moisture from a TB image and proper ancillary data
%using an algorithm patterned after the SMAP passive soil moisture
%extraction algorithm

clear;
year=2016; %Data only downloaded from 2016
days=276:276; %Any day or range of days. Data downloaded currently from 1:31, 92:121, 183:213, 275:305 
res=1; % 1=3km Sentinel/SMAP ancillary, 2=9km SMAP ancillary, 3=36km SMAP ancillary
mapplot=0;      % Plot the resultant soil moisture plots
ancilplot=0;    % Plot some of the ancillary data
compplot=0;     % Plot error vs. different variables
wfraccorrect=1; % Correct for water body fractions - for now this means ignoring pixels with any water

rmse=zeros(size(days));
mean_err=zeros(size(days));
totalsumsq=0;
totalsum=0;
totalmeas=0;
my_ind = 1;
for dayidx=1:length(days)
    day=days(dayidx);
    [tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
    disp(['Loaded data for day ' num2str(day)]);

    [ nsy1 , nsx1 ] = size(tbav);

    moisture_map=NaN(size(tbav));
    if(res==1)
        possible_mois = 0.02:.001:.6;
%         possible_mois = 0.02:.001:.5;
    else
        possible_mois = 0.02:.001:.5;
    end

    % We'll go pixel by pixel, but could do matrix math 
    for picx=1:nsx1
        for picy=1:nsy1
            neighbors=[picx-1,picy-1; picx-1,picy; picx-1, picy+1; picx, picy-1; picx, picy+1; ...
                picx+1, picy-1; picx+1, picy; picx+1, picy+1];
            tb=tbav(picy,picx); %read the brightness temperature
            localtemp=tempav(picy,picx); %read the surface temperature
            vwc=vwcav(picy,picx); %read the vegetation water content
            albedo=albav(picy,picx); %read the scattering albedo
            vegop=vopav(picy,picx); %read the vegetation opacity
            inc=incav(picy,picx)*pi/180; %read the incidence angle
            roughness=rghav(picy,picx); %read the soil roughness
            quality=round(qualav(picy,picx)); %read the retrieval quality
            localclay=clayf(picy,picx); %read the soil clay fraction
            wbfrac=wfracav(picy,picx); %read the water body fraction
            
            if(res==1)
                badqual=(quality ~= 0 && quality ~= 16 && quality ~= 64 && quality ~= 80);
            else
                badqual=(quality ~= 0 && quality ~= 8);
            end

            if((wbfrac > 0 && wfraccorrect) || isnan(tb) || isnan(localclay) || isnan(localtemp) ...
                    || isnan(albedo) || isnan(vegop) || isnan(inc) || isnan(roughness) || badqual )
                continue; %skip if we don't have all necessary info, or bad quality
            end
            
            
            
%             if(wfraccorrect && wbfrac > 0)
%                 salinity=35; % Is there a salinity map? 
%                 tbwater=tb_water(localtemp,salinity,inc);
%                 tb=(tb-tbwater*wbfrac)/(1-wbfrac);
%             end
            
            emis=tb/localtemp; %calculate the rough emissivity

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
                                                                            
            poss_emis=1-abs((dielec*cos(inc) - sqrt(dielec - sin(inc)^2))./(dielec*cos(inc) + sqrt(dielec - sin(inc)^2))).^2;
%             switch pol1 %Fresnel's equations to convert emissivity to dielectric constant
%                 case 1    % Horizontal
%                     poss_emis=1-abs((cos(inc) - sqrt(dielec - sin(inc)^2))./(cos(inc) + sqrt(dielec - sin(inc)^2))).^2;
%                 case 2    % Vertical - This is what is reported in NSIDC data
%                     poss_emis=1-abs((dielec*cos(inc) - sqrt(dielec - sin(inc)^2))./(dielec*cos(inc) + sqrt(dielec - sin(inc)^2))).^2;
%                 otherwise
%                     printf('Unrecognized polarization');
%                     exit();
%             end

            [min_err, dif_ind] = min(abs(poss_emis-real(emis)));

            moisture_map(picy,picx)=possible_mois(dif_ind); %Store the final soil moisture value
        end
        if(mod(picx,1000)==0)
            fprintf('%d\n',picx); %Just to track progress
        end
    end

    %% Here on is just creating different plots and maps

    if ancilplot % Optionally plot some ancillary data
        figure
        imagesc(tbav,[100 300]);
        title('Brightness Temperature');
        colorbar

        emissiv = bsxfun(@rdivide,tbav,tempav);
        figure
        imagesc(emissiv);
        title('Emissivity');
        colorbar

        figure
        imagesc(clayf);
        title('Clay Fraction');
        colorbar

        figure
        imagesc(rghav);
        title('Soil Roughness');
        colorbar

        figure
        imagesc(vwcav);
        title('VWC');
        colorbar

        figure
        imagesc(tempav);
        title('Surface Temperature');
        colorbar
    end

    %% Error plots and maps
    error=smav(1:nsy1,1:nsx1)-moisture_map;
    cursum=nansum(reshape(error,1,[]));
    cursumsq=nansum(reshape(error.^2,1,[]));
    curmeas=length(find(~isnan(error)));
    totalsum=totalsum+cursum;
    totalsumsq=totalsumsq+cursumsq;
    totalmeas=totalmeas+curmeas;
    rmse(dayidx) = sqrt(cursumsq/curmeas);
    mean_err(dayidx) = cursum/curmeas;

    if mapplot
        figure
        imagesc(moisture_map,[0 0.5]);
        title(['My Soil Moisture Map (RMSE = ' num2str(rmse(dayidx),3), ')']);
        colormap jet(128);
        colorbar

        figure
        imagesc(smav(1:nsy1,1:nsx1),[0 0.5]);
        title('NSIDC SM');
        colormap jet(128);
        colorbar
        
        figure
        imagesc(abs(error),[0 0.5]);
        title('Abs Error Map');
        colormap jet(128);
        colorbar
    end

    if compplot
        figure
        plot(vwcav(~isnan(vwcav) & ~isnan(error)),error(~isnan(vwcav) & ~isnan(error)),'.b')
        title('Error vs. VWC')
        colorbar

        figure
        plot(albav(~isnan(albav) & ~isnan(error)),error(~isnan(albav) & ~isnan(error)),'.b')
        title('Error vs. Albedo')
        colorbar

        figure
        plot(clayf(~isnan(clayf) & ~isnan(error)),error(~isnan(clayf) & ~isnan(error)),'.b')
        title('Error vs. Clay Fraction')
        colorbar

        figure
        plot(incav(~isnan(incav) & ~isnan(error)),error(~isnan(incav) & ~isnan(error)),'.b')
        title('Error vs. Incidence')
        colorbar

        figure
        plot(rghav(~isnan(rghav) & ~isnan(error)),error(~isnan(rghav) & ~isnan(error)),'.b')
        title('Error vs. Soil Roughness')
        colorbar

        figure
        plot(tbav(~isnan(tbav) & ~isnan(error)),error(~isnan(tbav) & ~isnan(error)),'.b')
        title('Error vs. Brightness Temperature')
        colorbar

        figure
        plot(tempav(~isnan(tempav) & ~isnan(error)),error(~isnan(tempav) & ~isnan(error)),'.b')
        title('Error vs. Surface Temperature')
        colorbar

        figure
        plot(vopav(~isnan(vopav) & ~isnan(error)),error(~isnan(vopav) & ~isnan(error)),'.b')
        title('Error vs. Vegetation Opacity')
        colorbar
    end
    sm(my_ind).sm = moisture_map;
    my_ind = my_ind + 1;
end
%%

totalmeanerr=totalsum/totalmeas;
totalrmse=sqrt(totalsumsq/totalmeas);
disp(['Total mean err=' num2str(totalmeanerr,3)]);
disp(['Total rmse=' num2str(totalrmse,3)]);


% scatdens(smav(~isnan(error)),moisture_map(~isnan(error)));

C=jet(128);
moisture_map(isnan(moisture_map))=0;
imwrite(im2uint8(moisture_map),C,['ims/moismap36km-' num2str(day) '.jpg']);
smav(isnan(smav))=0;
imwrite(im2uint8(smav),C,['ims/nsidcmap36km-' num2str(day) '.jpg']);
error(isnan(error))=0;
imwrite(im2uint8(error),C,['ims/errmap36km-' num2str(day) '.jpg']);

