function [sm_meas] = tb2sm_good_meas(tbav, fill_array, resp_array, year, day, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav, possible_mois)
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
tbval = tbav;

tb_temp = zeros(1, size(incav,1) * size(incav,2));
good_pixels = NaN(size(tb_temp));
meas_len = length(tbav);


for i = 1:length(tbav)
    tb_temp(fill_array(i).pt(ceil(end/2))) = tbav(i);
    good_pixels(fill_array(i).pt(ceil(end/2))) = 1;
end

good_pixels = reshape_img(good_pixels,size(smav,2),size(smav,1));

tbav = tb_temp;
tbav = reshape(tbav, fliplr(size(incav)));
tbav = flipud(tbav');
tbav(tbav == 0) = NaN;


[ nsy1 , nsx1 ] = size(tbav);



moisture_map=NaN(size(tbav));
inc = incav .* pi ./ 180;



        
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
        
            
         poss_emis=1-abs((bsxfun(@times, dielec', cos(inc_vec(good))) - (bsxfun(@minus, dielec', sin(inc_vec(good)) .^ 2)).^0.5)...
             ./(bsxfun(@times, dielec', cos(inc_vec(good))) + (bsxfun(@minus, dielec', sin(inc_vec(good)).^2)).^0.5)).^2;

        
        [min_err, dif_ind] = min(abs(bsxfun(@minus, poss_emis, real(emis_vec(good)))));
        
        moisture_map(good)=possible_mois(dif_ind); %Store the final soil moisture value
        
        moisture_map = reshape(moisture_map,[size(emis,1), size(emis,2)]);
        
        emis_vec = emis_vec(good);
        
        moisture_map = flipud(moisture_map);
        moisture_map = moisture_map';
        moisture_map = reshape(moisture_map, 1, length(tb_temp));
        
        
        sm_meas = moisture_map(find((moisture_map)));
        


        junk = 1;


    
    
end