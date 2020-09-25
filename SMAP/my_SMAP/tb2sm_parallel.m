function [moisture_map] = tb2sm_parallel(tbav, year, day, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav)
% year=2016; %Data only downloaded from 2016
% days=277:285; %Any day or range of days. Data downloaded currently from 1:31, 92:121, 183:213, 275:305
% res=1; % 1=3km Sentinel/SMAP ancillary, 2=9km SMAP ancillary, 3=36km SMAP ancillary

wfraccorrect=1; % Correct for water body fractions - for now this means ignoring pixels with any water

rmse=zeros(size(days));
mean_err=zeros(size(days));
totalsumsq=0;
totalsum=0;
totalmeas=0;

% [tbav2, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
disp(['Loaded data for day ' num2str(day)]);

[ nsy1 , nsx1 ] = size(tbav);

moisture_map=NaN(size(tbav));
if(res==1)
    possible_mois = 0.00:.001:1;
    %         possible_mois = 0.02:.001:.5;
else
    possible_mois = 0.02:.001:.5;
end

        inc=incav*pi./180; %read the incidence angle
        quality=round(qualav); %read the retrieval quality
        
        if(res==1)
            badqual=~(quality ~= 0) .* (quality ~= 16) .* (quality ~= 6) .* (quality ~= 80);
        else
            badqual=~(quality ~= 0) .* (quality ~= 8);
        end
        
        good_pixels = ones(size(tbav,1),size(tbav,2));
        good_pixels = good_pixels .* ~((wfracav > 0) .* wfraccorrect) .* ~isnan(tbav) .* ~isnan(clayf) .* ~isnan(tempav) ...
                .* ~isnan(albav) .* ~isnan(vopav) .* ~isnan(inc) .* ~isnan(rghav) .* badqual ;
%             continue; %skip if we don't have all necessary info, or bad quality
        good_pixels(good_pixels == 0) = NaN;
        
        
        
        
        %             if(wfraccorrect && wbfrac > 0)
        %                 salinity=35; % Is there a salinity map?
        %                 tbwater=tb_water(localtemp,salinity,inc);
        %                 tb=(tb-tbwater*wbfrac)/(1-wbfrac);
        %             end
        
        emis=tbav./tempav; %calculate the rough emissivity
        
        % Vegetation and roughness correction
        h=rghav;
        cantrans=exp(-vopav); %Canopy transmissivity
        emis=(emis-1+cantrans.^2+albav-albav.*cantrans.^2)./(cantrans.^2+albav.*cantrans-albav.*cantrans.^2); %remove vegetation effects
        emis=1-(1-emis).*exp(h.*cos(inc).^2); %remove surface roughness effects
        
%         if(isnan(emis))
%             moisture_map(picy,picx)  = NaN;
%             continue;
%         end
        
        clay_dim1 = size(clayf,1);
        clay_dim2 = size(clayf,2);
        
       
        clay_vec = reshape(clayf,[1,clay_dim1 * clay_dim2]);
        good_clay = reshape(good_pixels,[1,clay_dim1 * clay_dim2]);
        
        
        good_clay(isnan(good_clay)) = 0;
        good = find(good_clay);
        inc_vec = reshape(inc, [1, clay_dim1 * clay_dim2]);
        emis_vec = reshape(emis, [1, clay_dim1 * clay_dim2]);
        moisture_map = zeros(1, length(emis_vec));
        
        
        dielec=(sm2dc_parallel(possible_mois,clay_vec(good))); %Use dielectric mixing model
        
            
    
        %C = bsxfun(@times,inc_vec(good),dielec');
         poss_emis=1-abs((bsxfun(@times, dielec', cos(inc_vec(good))) - (bsxfun(@minus, dielec', sin(inc_vec(good)) .^ 2)).^0.5)...
             ./(bsxfun(@times, dielec', cos(inc_vec(good))) + (bsxfun(@minus, dielec', sin(inc_vec(good)).^2)).^0.5)).^2;

        
        [min_err, dif_ind] = min(abs(bsxfun(@minus, poss_emis, real(emis_vec(good)))));
        
        moisture_map(good)=possible_mois(dif_ind); %Store the final soil moisture value
        
        moisture_map = reshape(moisture_map,[size(emis,1), size(emis,2)]);
        
        emis_vec = emis_vec(good);
        
        save('poss_emis.mat','poss_emis', '-v7.3');
        save('dielec.mat','dielec', '-v7.3');
        
        
        %to convert possible soil
        %moistures to emissivities
        
%         poss_emis=1-abs((dielec.*cos(inc) - (dielec - sin(inc).^2).^0.5)./(dielec.*cos(inc) + (dielec - sin(inc).^2).^0.5)).^2;
% 
%         
%         [min_err, dif_ind] = min(abs(poss_emis-real(emis)));
%         
%         moisture_map(picy,picx)=possible_mois(dif_ind); %Store the final soil moisture value

    
    
end

