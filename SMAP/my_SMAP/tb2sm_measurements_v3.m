function [sm_meas, sm_fill_array, sm_response_array] = tb2sm_measurements_v3(tbav, fill_array, resp_array,  year, day, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav)
% year=2016; %Data only downloaded from 2016
% days=277:285; %Any day or range of days. Data downloaded currently from 1:31, 92:121, 183:213, 275:305
% res=1; % 1=3km Sentinel/SMAP ancillary, 2=9km SMAP ancillary, 3=36km SMAP ancillary

wfraccorrect=1; % Correct for water body fractions - for now this means ignoring pixels with any water

rmse=zeros(size(days));
mean_err=zeros(size(days));
totalsumsq=0;
totalsum=0;
totalmeas=0;

load 'poss_emis.mat';
poss_emis_par = poss_emis;
clear poss_emis;

% load 'dielec.mat'
% dielec_par = dielec;
% clear dielec;

% [tbav2, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
disp(['Loaded data for day ' num2str(day)]);

[ nsy1 , nsx1 ] = size(smav);


if(res==1)
    possible_mois = 0.00:.001:1;
    %         possible_mois = 0.02:.001:.5;
else
    possible_mois = 0.02:.001:.5;
end

count = 1;
% We'll go pixel by pixel, but could do matrix math

tb_map = zeros(size(incav));
moisture_map = zeros(size(incav));
tbval = tbav;
j = 1;
for i = 1:length(tbav)
    %     junk(my_ifsirlex(i,size(junk,2),size(junk,1))) = tbval(i);
    [y,x] = my_ifsirlex(fill_array(i).pt,size(tb_map,1),size(tb_map,2));
    y = nsy1 - y;
    tb_map(y(1),x(1)) = tbval(i);
    x_meas(i) = x(1);
    y_meas(i) = y(1);
    
    picx = x_meas(i);
    picy = y_meas(i);
    neighbors=[picx-1,picy-1; picx-1,picy; picx-1, picy+1; picx, picy-1; picx, picy+1; ...
        picx+1, picy-1; picx+1, picy; picx+1, picy+1];
    tb=tb_map(picy,picx); %read the brightness temperature
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
    
    %         if(sum(dielec_par(count,:) == dielec) ~= 1001)
    %             my_stop = 1;
    %         else
    %             count = count + 1;
    %         end
    
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
    
    %         if(sum(poss_emis_par(:,count) == poss_emis') ~= 1001)
    %             temp = 1;
    %         else
    %             count = count + 1;
    %         end
    
    [min_err, dif_ind] = min(abs(poss_emis-real(emis)));
    
    moisture_map(picy,picx)=possible_mois(dif_ind); %Store the final soil moisture value
    sm_meas(j) = possible_mois(dif_ind);
    sm_fill_array(j).pt = fill_array(i).pt;
    sm_response_array(j).resp = resp_array(i).resp;
    j = j + 1;
end
