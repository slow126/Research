function [data, sm_meas] = tb2sm_footprints_v4(data)
% year=2016; %Data only downloaded from 2016
% days=277:285; %Any day or range of days. Data downloaded currently from 1:31, 92:121, 183:213, 275:305
% res=1; % 1=3km Sentinel/SMAP ancillary, 2=9km SMAP ancillary, 3=36km SMAP ancillary

wfraccorrect=1; % Correct for water body fractions - for now this means ignoring pixels with any water


possible_mois = 0.02:0.0001:0.6;
sm_meas = zeros(length(data),1);


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

        
        [min_err, dif_ind] = nanmin(abs(bsxfun(@minus, poss_emis, real(emis'))));
        real_emis = real(emis');
        
        sm_meas(i) = possible_mois(dif_ind);
%         data(i).sm_meas = sm_meas(i);
%         data(i).sm_resp = (data(i).resp - nanmin(data(i).resp)) / (nanmax(data(i).resp) - nanmin(data(i).resp));
%         data(i).sm_resp = data(i).sm_resp - nanmean(data(i).sm_resp);
%         continue
        
%         new_max = 1.1 * data(i).tb_meas;
%         new_min = .9 * data(i).tb_meas;
%         tb_footprint = data(i).tb_meas .* (data(i).resp / nanmean(data(i).resp));
%         old_range = nanmax(tb_footprint(:)) - nanmin(tb_footprint(:));
%         new_range = new_max - new_min;
% %         new_range = nanmax(tb_footprint(:)) - shift - (nanmin(tb_footprint(:)) + shift);
%          
%         
%         tb_compress = (tb_footprint - nanmin(tb_footprint(:))) * new_range / old_range + (new_min);

        tb_resp = data(i).resp;
        tb_resp_max = nanmax(tb_resp(:));
        tb_footprint = tb_resp;
%         tb_footprint = (tb_resp / 1000);
        tb_footprint = 0.1 * (tb_footprint - nanmean(tb_footprint(:))) + nanmean(tb_footprint(:));
        
        tb_compress = data(i).tb_meas .* tb_footprint ./ nanmean(tb_footprint(:));

        emis= tb_compress ./ data(i).tempav; %calculate the rough emissivity
        
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

        
        [min_err, dif_ind] = nanmin(abs(bsxfun(@minus, poss_emis, real(emis'))));
        real_emis = real(emis');
        
        

        
        footprint = possible_mois(dif_ind)';
        data(i).sm = footprint';
        
        sm_prf = (footprint) / (sm_meas(i));
        
%         sm_prf = (sm_prf - nanmin(sm_prf(:))) / (nanmax(sm_prf(:)) - nanmin(sm_prf(:)));

%        dielec=(sm2dc_v2(sm_prf,data(i).clayf)); %Use dielectric mixing model
%             
%         emis=1-abs((bsxfun(@times, dielec, cos(data(i).inc)) - (bsxfun(@minus, dielec, sin(data(i).inc) .^ 2)).^0.5)...
%              ./(bsxfun(@times, dielec, cos(data(i).inc)) + (bsxfun(@minus, dielec, sin(data(i).inc).^2)).^0.5)).^2;
%          
%         
%             
% 
%         emis = (emis - 1) ./ exp(h.*cos(data(i).inc).^2) + 1; % Add surface roughness effects
%         emis = emis .* (cantrans.^2 + data(i).albav .* cantrans - data(i).albav.*cantrans.^2) + 1 - cantrans.^2 - data(i).albav + data(i).albav .* cantrans.^2; %Add vegetation effects
%         sm_prf2 = emis .* data(i).tempav;

        
        data(i).sm_resp = (sm_prf - nanmean(sm_prf(:))); %100 * (sm_prf - nanmean(sm_prf(:))) + nanmean(sm_prf(:)); %((1 ./ (sm_prf + 0.00001)));
%         data(i).sm_resp = data(i).sm_resp + nanmin(data(i).sm_resp(:));
        data(i).sm_meas = sm_meas(i);
            
%             total2 = ones(11568,4872) * NaN;
%             figure(10)
%             total2(data(i).pt) = data(i).sm_resp;
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
%             
%             total2 = ones(11568,4872) * NaN;
%             figure(11)
%             total2(data(i).temp_pt) = data(i).temp_resp;
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
%             my_mesh = temp(315:327, 8463:8500) / nanmax(temp(:));
%             surf(my_mesh)
% %             imagesc(my_mesh)
%             
%             set(gca,'XTick',[1:8500-8463+1]);
%             xticklabels({3*[-19:18]})
%             set(gca,'YTick',[1:327-315+1]);
%             yticklabels({3*[-6:8]})
%             xlabel('Distance in Kilometers from center of Response', 'FontSize',18)
%             ylabel('Distance in Kilometers from center of Response', 'FontSize', 18)
% %             imagesc(temp)
% %             daspect([1 1 .025])
%             colorbar
%             drawnow
%             
%             total2 = ones(11568,4872) * NaN;
%             figure(12)
%             total2(data(i).pt) = tb_compress;
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
%             
%             total2 = ones(11568,4872) * NaN;
%             figure(13)
%             total2(data(i).pt) = footprint;
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
%             
%             total2 = ones(11568,4872) * NaN;
%             figure(14)
%             total2(data(i).pt) = sm_prf;
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
        

end