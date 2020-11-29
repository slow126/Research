function [sm_meas2, sm_fill_array, sm_response_array, sm_footprint] = tb2sm_graph(tbav, fill_array, resp_array,  year, day, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav, sm_meas)
% year=2016; %Data only downloaded from 2016
% days=277:285; %Any day or range of days. Data downloaded currently from 1:31, 92:121, 183:213, 275:305
% res=1; % 1=3km Sentinel/SMAP ancillary, 2=9km SMAP ancillary, 3=36km SMAP ancillary

wfraccorrect=1; % Correct for water body fractions - for now this means ignoring pixels with any water

rmse=zeros(size(days));
mean_err=zeros(size(days));
totalsumsq=0;
totalsum=0;
totalmeas=0;

% load 'poss_emis.mat';
% poss_emis_par = poss_emis;
% clear poss_emis;

% load 'dielec.mat'
% dielec_par = dielec;
% clear dielec;

% [tbav2, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
disp(['Loaded data for day ' num2str(day)]);

[ nsy1 , nsx1 ] = size(smav);


if(res==1)
    possible_mois = (0.0001:.0001:0.5);
    %         possible_mois = 0.02:.001:.5;
else
    possible_mois = 0.02:.001:.5;
end

count = 1;
% We'll go pixel by pixel, but could do matrix math

tb_map = zeros(size(incav));
moisture_map = zeros(size(incav));
tbval = tbav;
m = 1;
nsize = size(incav,1) * size(incav,2);
ave = zeros(1,nsize);
total = zeros(1,nsize);
resp_total = zeros(1,nsize);
count = zeros(1,nsize);

% for i = 1:length(resp_array)
%         total(fill_array(i).pt) = total(fill_array(i).pt) + tbav(i) .* resp_array(i).resp';
%         resp_total(fill_array(i).pt) = resp_total(fill_array(i).pt) + resp_array(i).resp';
%         count(fill_array(i).pt) = count(fill_array(i).pt) + 1;
%         ave(fill_array(i).pt) = nansum(tbav(i) .* resp_array(i).resp') ./ nansum(resp_array(i).resp);
% end

ave = resp_total ./ count;


tb_map = NaN(size(incav));
moisture_map = NaN(size(tb_map));


for i = 1:1000 %length(tbav)
    
    
    
    tb_map(:) = NaN;
    %     junk(my_ifsirlex(i,size(junk,2),size(junk,1))) = tbval(i);
    tb_map = reshape(tb_map,1,[]);
%     tb_map(fill_array(i).pt) = (tbval(i) .* normalize(resp_array(i).resp,'range') );

    tb_map(fill_array(i).pt) = (tbval(i) .* resp_array(i).resp) ./ nanmean(resp_array(i).resp);
    tb_map = reshape(tb_map, [nsx1, nsy1]);
    tb_map = flipud(tb_map');
    
    
    idx = find(~isnan(tb_map));
    
    
    tb=tb_map(idx); %read the brightness temperature
    localtemp=tempav(idx); %read the surface temperature
    vwc=vwcav(idx); %read the vegetation water content
    albedo=albav(idx); %read the scattering albedo
    vegop=vopav(idx); %read the vegetation opacity
    inc=incav(idx)*pi/180; %read the incidence angle
    roughness=rghav(idx); %read the soil roughness
    quality=round(qualav(idx)); %read the retrieval quality
    localclay=clayf(idx); %read the soil clay fraction
    wbfrac=wfracav(idx); %read the water body fraction
    localtemp(localtemp == 220) = NaN;

    
    if(res==1)
        badqual=(quality ~= 0 .* quality ~= 16 .* quality ~= 64 .* quality ~= 80);
    else
        badqual=(quality ~= 0 && quality ~= 8);
    end
    
    good = ones(size(tb));
    good = ((wbfrac > 0 .* wfraccorrect) .* ~isnan(tb) .* ~isnan(localclay) .* ~isnan(localtemp) ...
        .* ~isnan(albedo) .* ~isnan(vegop) .* ~isnan(inc) .* ~isnan(roughness));% .* ~badqual );
    
    good = find(good);
    
    if isempty(good)
        continue;
    end
    
    
    %             if(wfraccorrect && wbfrac > 0)
    %                 salinity=35; % Is there a salinity map?
    %                 tbwater=tb_water(localtemp,salinity,inc);
    %                 tb=(tb-tbwater*wbfrac)/(1-wbfrac);
    %             end
    
    
%     for p = -40:40
%         emis=(tb + p)./localtemp; %calculate the rough emissivity
%         
%         % Vegetation and roughness correction
%         h=rghav(idx);
%         cantrans=exp(-vegop); %Canopy transmissivity
%         emis=(emis-1+cantrans.^2+albedo-albedo.*cantrans.^2)./(cantrans.^2+albedo.*cantrans-albedo.*cantrans.^2); %remove vegetation effects
%         emis=1-(1-emis).*exp(h.*cos(inc).^2); %remove surface roughness effects
%         [my_emis(p + 41), ndx] = nanmax(emis);
%         my_tb(p+41) = tb(ndx) + p;
%         
% %         total2 = ones(size(tb_map)) .* 10;
% %         figure(10)
% %         total2(idx) = emis;
% %         imagesc(total2)
% % %             imagesc(temp)
% %         drawnow
%     end
    
        emis=tb./localtemp; %calculate the rough emissivity
%         emis(emis > .9) = .9;
        
%         figure(12)
%         plot(tb(find(~isnan(emis))), emis(find(~isnan(emis))),'.')
        
        % Vegetation and roughness correction
        h=rghav(idx);
        cantrans=exp(-vegop); %Canopy transmissivity
        emis=(emis-1+cantrans.^2+albedo-albedo.*cantrans.^2)./(cantrans.^2+albedo.*cantrans-albedo.*cantrans.^2); %remove vegetation effects
        emis=1-(1-emis).*exp(h.*cos(inc).^2); %remove surface roughness effects

    %         if(isnan(emis))
    %             moisture_map(picy,picx)  = NaN;
    %             continue;
    %         end
    
    
    
    
    dielec=(sm2dc_footprint(possible_mois,localclay)); %Use dielectric mixing model
    
    
    
    %C = bsxfun(@times,inc_vec(good),dielec');
    poss_emis=1-abs((bsxfun(@times, dielec', cos(inc)') - (bsxfun(@minus, dielec', sin(inc)' .^ 2)).^0.5)...
        ./(bsxfun(@times, dielec', cos(inc)') + (bsxfun(@minus, dielec', sin(inc)'.^2)).^0.5)).^2;
    
%     figure(10)
%     plot(my_tb, my_emis)
%     
%     figure(11)
%     plot(poss_emis)
    
%     figure(12)
%     plot(tb(find(~isnan(emis))), emis(find(~isnan(emis))),'.')
    
    
    
    
    [min_err, dif_ind] = min(abs(bsxfun(@minus, poss_emis, real(emis'))));
    real_emis = real(emis');
    
    %         moisture_map(idx)=possible_mois(dif_ind); %Store the final soil moisture value
    %
    %         moisture_map = flipud(moisture_map);
    
    mask = find(~isnan(emis));
    moisture_map(:) = NaN;
    moisture_map = reshape(moisture_map,[nsy1, nsx1]);
    moisture_map(idx(mask)) = possible_mois(dif_ind(mask));
    %         moisture_map = reshape_img(moisture_map,1,[]);
    moisture_map = flipud(moisture_map);
    moisture_map = moisture_map';
    moisture_map = reshape(moisture_map,1,[]);
    
    footprint = moisture_map(find(~isnan(moisture_map)));
    
%     figure(10)
%     total2 = moisture_map;
%     temp = reshape(total2, [11568,4872]);
%     temp = flipud(temp');
% %     imagesc(temp(300:338, 8460:8560))
%     imagesc(temp)
%     drawnow
    
    
    %             sm_meas(j) = possible_mois(dif_ind);
    %             sm_fill_array(j).pt = fill_array(i).pt;
    %             sm_response_array(j).resp = resp_array(i).resp;
    %             j = j + 1;
    
    if ~isempty(find(footprint,1))
%         temp = possible_mois(dif_ind);
%         mask = (footprint > 0) .* ~isnan(real_emis);
%         mask = find(mask);
%         [junk_min, middle_idx] = nanmin(abs(fill_array(i).pt - (nanmax(fill_array(i).pt(mask)) + nanmin(fill_array(i).pt(mask))) / 2));
%         
%         sm_meas(m) = temp(middle_idx);
%         sm_meas(m) = nanmin(footprint);
        
        sm_fill_array(m).pt = (fill_array(i).pt(mask));
%         sm_meas(i)
        footprint = footprint ./ (1 + sm_meas(i));
        footprint = footprint;
        sm_response_array(m).resp = footprint';
        sm_footprint(m).print = footprint';
        sm_meas2(m) = sm_meas(i);
        
        
                total2 = ones(size(total)) * -1;
                total3 = ones(size(total)) * -1;
                if length(sm_response_array(m).resp) > 140
        
                    figure(10)
                    total2(sm_fill_array(m).pt) = sm_response_array(m).resp;
                    temp = reshape(total2, [11568,4872]);
                    temp = flipud(temp');
                    imagesc(temp(310:338, 8480:8520))
%                     imagesc(temp)
                    drawnow
        
                    figure(11)
                    total3(fill_array(m).pt) = resp_array(m).resp;
                    temp = reshape(total3, [11568,4872]);
                    temp = flipud(temp');
                    imagesc(temp(310:338, 8480:8520))
%                     imagesc(temp)
                    drawnow
                end
%         
%                     figure(12)
% %                     total3(fill_array(m).pt) = normalize(resp_array(m).resp,'range') * tbav(i) ;
%                     total3(fill_array(m).pt) = resp_array(m).resp * tbav(i) ./ nanmean(resp_array(m).resp) ;
%                     temp = reshape(total3, [11568,4872]);
%                     temp = flipud(temp');
%                     imagesc(temp(300:338, 8460:8560))
% %                     imagesc(temp)
%                     drawnow
%         
%                     figure(13)
%                     total2(sm_fill_array(m).pt) = sm_response_array(m).resp .* sm_meas(i);
%                     temp = reshape(total2, [11568,4872]);
%                     temp = flipud(temp');
%                     imagesc(temp(300:338, 8460:8560))
% %                     imagesc(temp)
%                     drawnow
%                  end
        
        
        %         foot = NaN(1,4872 * 11568);
        %         foot(fill_array(i).pt(mask)) = footprint;
        
        m = m + 1;
    end
end