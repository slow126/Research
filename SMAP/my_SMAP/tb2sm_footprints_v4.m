function [data, sm_meas] = tb2sm_footprints_v4(data)
% year=2016; %Data only downloaded from 2016
% days=277:285; %Any day or range of days. Data downloaded currently from 1:31, 92:121, 183:213, 275:305
% res=1; % 1=3km Sentinel/SMAP ancillary, 2=9km SMAP ancillary, 3=36km SMAP ancillary

wfraccorrect=1; % Correct for water body fractions - for now this means ignoring pixels with any water


possible_mois = 0.01:0.0001:0.5;


for i = 1:length(data)
    
        emis = data(i).tb_meas./data(i).tempav(data(i).tb_meas_loc);
        h=data(i).rghav(data(i).tb_meas_loc);
        
        cantrans=exp(-1*data(i).vopav(data(i).tb_meas_loc)); %Canopy transmissivity
        emis=(emis-1+cantrans.^2+data(i).albav(data(i).tb_meas_loc)-data(i).albav(data(i).tb_meas_loc).*cantrans.^2)./(cantrans.^2+data(i).albav(data(i).tb_meas_loc).*cantrans-data(i).albav(data(i).tb_meas_loc).*cantrans.^2); %remove vegetation effects
        emis=1-(1-emis).*exp(h.*cos(data(i).inc(data(i).tb_meas_loc)).^2); %remove surface roughness effects
        
%         if(isnan(emis))
%             moisture_map(picy,picx)  = NaN;
%             continue;
%         end
        
        
        
        dielec=(sm2dc_footprint(possible_mois,data(i).clayf(data(i).tb_meas_loc)));
        
        
            
    
        %C = bsxfun(@times,inc_vec(good),dielec');
         poss_emis=1-abs((bsxfun(@times, dielec', cos(data(i).inc(data(i).tb_meas_loc))') - (bsxfun(@minus, dielec', sin(data(i).inc(data(i).tb_meas_loc))' .^ 2)).^0.5)...
             ./(bsxfun(@times, dielec', cos(data(i).inc(data(i).tb_meas_loc))') + (bsxfun(@minus, dielec', sin(data(i).inc(data(i).tb_meas_loc))'.^2)).^0.5)).^2;

        
        [min_err, dif_ind] = min(abs(bsxfun(@minus, poss_emis, real(emis'))));
        real_emis = real(emis');
        
        sm_meas(i) = possible_mois(dif_ind);
        

        emis=data(i).tb_meas .* (data(i).resp / nanmean(data(i).resp)) * (.75 * max(data(i).resp) - .25 * min(data(i).resp))./data(i).tempav; %calculate the rough emissivity
        
        % Vegetation and roughness correction
        h=data(i).rghav;
        
        cantrans=exp(-1*data(i).vopav); %Canopy transmissivity
        emis=(emis-1+cantrans.^2+data(i).albav-data(i).albav.*cantrans.^2)./(cantrans.^2+data(i).albav.*cantrans-data(i).albav.*cantrans.^2); %remove vegetation effects
        emis=1-(1-emis).*exp(h.*cos(data(i).inc).^2); %remove surface roughness effects
        
%         if(isnan(emis))
%             moisture_map(picy,picx)  = NaN;
%             continue;
%         end
        
        
        
        dielec=(sm2dc_footprint(possible_mois,data(i).clayf));
        
        
            
    
        %C = bsxfun(@times,inc_vec(good),dielec');
         poss_emis=1-abs((bsxfun(@times, dielec', cos(data(i).inc)') - (bsxfun(@minus, dielec', sin(data(i).inc)' .^ 2)).^0.5)...
             ./(bsxfun(@times, dielec', cos(data(i).inc)') + (bsxfun(@minus, dielec', sin(data(i).inc)'.^2)).^0.5)).^2;

        
        [min_err, dif_ind] = min(abs(bsxfun(@minus, poss_emis, real(emis'))));
        real_emis = real(emis');
        
        

        
        footprint = possible_mois(dif_ind)';
        data(i).sm = footprint';
        

        data(i).sm_resp = footprint / (sm_meas(i));

        
%         sm_meas(m) = nanmean(footprint);
%         sm_fill_array(m).pt = (data(i).pt)';
%         footprint = footprint ./ nanmean(footprint);
% %         footprint = footprint(mask) ./ sm_meas(i);
%         sm_response_array(m).resp = footprint;
%         sm_footprint(m).print = footprint;
% %         foot = NaN(1,4872 * 11568);
% %         foot(fill_array(i).pt(mask)) = footprint;
%         
%         
% 
%             total2 = ones(11568,4872) * -1;
%                     figure(10)
%             total2(data(i).pt) = data(i).sm_resp;
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
        
%         if length(sm_response_array(m).resp) > 140
%             
%             figure(10)
%             total2(data(i).pt) = footprint;
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
            
%             figure(11)
%             total3(fill_array(m).pt) = resp_array(m).resp;
%             temp = reshape(total3, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
%             
%             figure(12)
%             total3(fill_array(m).pt) = resp_array(m).resp * tbav(i) / nanmean(resp_array(m).resp);
%             temp = reshape(total3, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
%             
%             figure(13)
%             total2(sm_fill_array(m).pt) = sm_response_array(m).resp .* sm_meas(m);
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
%         end
%          m = m + 1;

%     end
end