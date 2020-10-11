function [moisture_footprint] = tb2sm_footprint(tbav_meas,fill_array, resp_array, footprint, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav, possible_mois)
% year=2016; %Data only downloaded from 2016
% days=277:285; %Any day or range of days. Data downloaded currently from 1:31, 92:121, 183:213, 275:305
% res=1; % 1=3km Sentinel/SMAP ancillary, 2=9km SMAP ancillary, 3=36km SMAP ancillary

wfraccorrect=1; % Correct for water body fractions - for now this means ignoring pixels with any water



albav = reshape_img(albav,1,[]);
incav = reshape_img(incav,1,[]);
qualav = reshape_img(qualav,1,[]);
clayf = reshape_img(clayf,1,[]);
vopav = reshape_img(vopav,1,[]);
rghav = reshape_img(rghav,1,[]);
vwcav = reshape_img(vwcav,1,[]);
tempav = reshape_img(tempav,1,[]);
wfracav = reshape_img(wfracav,1,[]);


rmse=zeros(size(days));
mean_err=zeros(size(days));
totalsumsq=0;
totalsum=0;
totalmeas=0;


albav = albav(fill_array);
incav = incav(fill_array);
qualav = qualav(fill_array);
clayf = clayf(fill_array);
vopav = vopav(fill_array);
rghav = rghav(fill_array);
vwcav = vwcav(fill_array);
tempav = tempav(fill_array);
wfracav = wfracav(fill_array);


        moisture_footprint=NaN(size(footprint));

        inc=incav*pi./180; %read the incidence angle
        quality=round(qualav); %read the retrieval quality
        
        if(res==1)
            badqual=~(quality ~= 0) .* (quality ~= 16) .* (quality ~= 64) .* (quality ~= 80);
        else
            badqual=~(quality ~= 0) .* (quality ~= 8);
        end
        
        good_pixels = ones(1,length(fill_array));
        good_pixels = good_pixels .* ~((wfracav > 0) .* wfraccorrect) .* ~isnan(footprint') .* ~isnan(clayf) .* ~isnan(tempav) ...
                .* ~isnan(albav) .* ~isnan(vopav) .* ~isnan(inc) .* ~isnan(rghav);% .* badqual ;
        good_pixels(good_pixels == 0) = NaN;
        
        
        
        emis=footprint'./tempav; %calculate the rough emissivity
        
        % Vegetation and roughness correction
        h=rghav;
        cantrans=exp(-vopav); %Canopy transmissivity
        emis=(emis-1+cantrans.^2+albav-albav.*cantrans.^2)./(cantrans.^2+albav.*cantrans-albav.*cantrans.^2); %remove vegetation effects
        emis=1-(1-emis).*exp(h.*cos(inc).^2); %remove surface roughness effects
        
%         if(isnan(emis))
%             moisture_map(picy,picx)  = NaN;
%             continue;
%         end
        
        clay_vec = clayf;
        inc_vec = inc;
        emis_vec = emis;
        
        good = good_pixels;
        good(isnan(good)) = 0;
        moisture_footprint = zeros(1, length(emis_vec));
        good = find(good);
        
        
        dielec=(sm2dc_footprint(possible_mois,clay_vec(good))); %Use dielectric mixing model
        
            
    
        %C = bsxfun(@times,inc_vec(good),dielec');
         poss_emis=1-abs((bsxfun(@times, dielec', cos(inc_vec(good))) - (bsxfun(@minus, dielec', sin(inc_vec(good)) .^ 2)).^0.5)...
             ./(bsxfun(@times, dielec', cos(inc_vec(good))) + (bsxfun(@minus, dielec', sin(inc_vec(good)).^2)).^0.5)).^2;

        
        [min_err, dif_ind] = min(abs(bsxfun(@minus, poss_emis, real(emis_vec(good)))));
        
        moisture_footprint(good)=possible_mois(dif_ind); %Store the final soil moisture value
        
        moisture_footprint = reshape(moisture_footprint,[size(emis,1), size(emis,2)]);
        
        emis_vec = emis_vec(good);
        

    
    
end
