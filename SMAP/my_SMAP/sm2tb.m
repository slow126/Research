function [tb_map] = sm2tb(moisture_map, year, day, res, tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav)
% [tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
disp(['Loaded data for day ' num2str(day)]);

[ nsy1 , nsx1 ] = size(tbav);

tb_map=NaN(size(tbav));
if(res==1)
    possible_mois = -0.02:.001:5;
%     possible_mois = 0.02:.001:.6;
    %         possible_mois = 0.02:.001:.5;
else
    possible_mois = 0.02:.001:.5;
end
wfraccorrect=1;

% We'll go pixel by pixel, but could do matrix math
for picx=1:nsx1
    for picy=1:nsy1
        if moisture_map(picy,picx) == 0
            tb_map(picy, picx) = 0;
        else
            neighbors=[picx-1,picy-1; picx-1,picy; picx-1, picy+1; picx, picy-1; picx, picy+1; ...
                picx+1, picy-1; picx+1, picy; picx+1, picy+1];
            tb2=tbav(picy,picx); %read the brightness temperature
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
            
            if((wbfrac > 0 && wfraccorrect) || isnan(tb2) || isnan(localclay) || isnan(localtemp) ...
                    || isnan(albedo) || isnan(vegop) || isnan(inc) || isnan(roughness) || badqual || isnan(moisture_map(picy,picx)))
                continue; %skip if we don't have all necessary info, or bad quality
            end
            %         emis=tb/localtemp; %calculate the rough emissivity
            
            % Vegetation and roughness correction
            h=roughness;
            cantrans=exp(-vegop); %Canopy transmissivity
            %         emis=(emis-1+cantrans^2+albedo-albedo*cantrans^2)/(cantrans^2+albedo*cantrans-albedo*cantrans^2); %remove vegetation effects
            %         emis=1-(1-emis)*exp(h*cos(inc)^2); %remove surface roughness effects
            
            %         if(isnan(emis))
            %             moisture_map(picy,picx)  = NaN;
            %             continue;
            %         end
            
            
            dielec=sm2dc(possible_mois,localclay*ones(size(possible_mois))); %Use dielectric mixing model
            %to convert possible soil
            %moistures to emissivities
            
            poss_emis=1-abs((dielec*cos(inc) - sqrt(dielec - sin(inc)^2))./(dielec*cos(inc) + sqrt(dielec - sin(inc)^2))).^2;
            
            mois_ind = find(moisture_map(picy,picx) == possible_mois); %Store the final soil moisture value
            
            emis = poss_emis(mois_ind);
            emis = (emis - 1) ./ exp(h*cos(inc)^2) + 1; % Add surface roughness effects
            emis = emis * (cantrans^2 + albedo * cantrans - albedo*cantrans^2) + 1 - cantrans^2 - albedo + albedo * cantrans^2; %Add vegetation effects
            tb = emis * localtemp;

            tb_map(picy, picx) = tb;
        end
        
    end
    if(mod(picx,1000)==0)
        fprintf('%d\n',picx); %Just to track progress
    end
    
    
end


end

