function [sm_meas, sm_fill_array, sm_response_array, sm_footprint] = tb2sm_footprints_v3(tbav, fill_array, resp_array,  year, day, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav, sir_ave, sm_meas)
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
    possible_mois = 0.01:.001:1;
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

for i = 1:length(resp_array)
        total(fill_array(i).pt) = total(fill_array(i).pt) + tbav(i) .* resp_array(i).resp';
        resp_total(fill_array(i).pt) = resp_total(fill_array(i).pt) + resp_array(i).resp';
        count(fill_array(i).pt) = count(fill_array(i).pt) + 1;
        ave(fill_array(i).pt) = nansum(tbav(i) .* resp_array(i).resp') ./ nansum(resp_array(i).resp');
end

ave = resp_total ./ count;





good_img = ones(size(clayf,1),size(clayf,2));
good_img = good_img .* ((wfracav > 0) .* wfraccorrect) .* ~isnan(sir_ave) .* ~isnan(clayf) .* ~isnan(tempav) ...
    .* ~isnan(albav) .* ~isnan(vopav) .* ~isnan(incav) .* ~isnan(rghav);% .* badqual ;


good_clay_idx = find(good_img);
good_clay = clayf(good_clay_idx);



dielec_vec=(sm2dc_parallel(possible_mois, good_clay)); %Use dielectric mixing model
tb_map = NaN(1,nsize);
moisture_map = NaN(size(tb_map));


for i = 1:length(tbav)
    tb_map = reshape(tb_map,1,[]);
    tb_map(:) = NaN;
    %     junk(my_ifsirlex(i,size(junk,2),size(junk,1))) = tbval(i);
%     tb_map = reshape_img(tb_map,1,[]);


    tb_map(fill_array(i).pt) = tbval(i) .* resp_array(i).resp ./ nanmean(resp_array(i).resp);
%     tb_map = reshape_img(tb_map, size(tempav,2),size(tempav,1));
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
            tb_temp = tempav(idx);
            
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
            
            emis=tb(good)./tb_temp(good); %calculate the rough emissivity
        
        % Vegetation and roughness correction
        h=rghav(idx);
        h = h(good);
        cantrans=exp(-vegop(good)); %Canopy transmissivity
        emis=(emis-1+cantrans.^2+albedo(good)-albedo(good).*cantrans.^2)./(cantrans.^2+albedo(good).*cantrans-albedo(good).*cantrans.^2); %remove vegetation effects
        emis=1-(1-emis).*exp(h.*cos(inc(good)).^2); %remove surface roughness effects
        
%         if(isnan(emis))
%             moisture_map(picy,picx)  = NaN;
%             continue;
%         end
        
        
        
        c = ismember(good_clay_idx, idx);
        c = find(c);
        dielec = dielec_vec(c,:);
        
        
            
    
        %C = bsxfun(@times,inc_vec(good),dielec');
         poss_emis=1-abs((bsxfun(@times, dielec', cos(inc(good))') - (bsxfun(@minus, dielec', sin(inc(good))' .^ 2)).^0.5)...
             ./(bsxfun(@times, dielec', cos(inc(good))') + (bsxfun(@minus, dielec', sin(inc(good))'.^2)).^0.5)).^2;

        
        [min_err, dif_ind] = min(abs(bsxfun(@minus, poss_emis, real(emis'))));
        real_emis = real(emis');
        
%         moisture_map(idx)=possible_mois(dif_ind); %Store the final soil moisture value
%         
%         moisture_map = flipud(moisture_map);
            
%         footprint = possible_mois(dif_ind);
        moisture_map(:) = NaN;
        moisture_map = reshape(moisture_map,[nsy1, nsx1]);
        moisture_map(idx(good)) = possible_mois(dif_ind);
        moisture_map = flipud(moisture_map');
        moisture_map = reshape(moisture_map, 1, []);
        
        footprint = moisture_map(find(~isnan(moisture_map)));
            
%             sm_meas(j) = possible_mois(dif_ind);
%             sm_fill_array(j).pt = fill_array(i).pt;
%             sm_response_array(j).resp = resp_array(i).resp;
%             j = j + 1;
    
    if ~isempty(find(footprint,1))
        temp = possible_mois(dif_ind);
%         mask = (footprint > 0) .* ~isnan(real_emis);
%         mask = find(mask);
        mask = good;
        
        sm_meas(m) = nanmean(footprint);
        sm_fill_array(m).pt = (fill_array(i).pt(mask))';
        footprint = footprint ./ nanmean(footprint);
%         footprint = footprint(mask) ./ sm_meas(i);
        sm_response_array(m).resp = footprint;
        sm_footprint(m).print = footprint;
%         foot = NaN(1,4872 * 11568);
%         foot(fill_array(i).pt(mask)) = footprint;
        
        

%         total2 = ones(size(total)) * -1;
%         total3 = ones(size(total)) * -1;
%         if length(sm_response_array(m).resp) > 140
%             
%             figure(10)
%             total2(sm_fill_array(m).pt) = sm_response_array(m).resp;
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
%             imagesc(temp(300:338, 8460:8560))
% %             imagesc(temp)
%             drawnow
%             
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
         m = m + 1;

    end
end