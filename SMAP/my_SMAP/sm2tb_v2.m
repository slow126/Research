function [tb_map] = sm2tb_parallel(moisture_map, year, day, res, tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav)
% [tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
disp(['Loaded data for day ' num2str(day)]);

[ nsy1 , nsx1 ] = size(tbav);

tb_map=NaN(size(tbav));
if(res==1)
    possible_mois = 0:.001:1;
%     possible_mois = 0.02:.001:.6;
    %         possible_mois = 0.02:.001:.5;
else
    possible_mois = 0.02:.001:0.5;
end
wfraccorrect=1;

% We'll go pixel by pixel, but could do matrix math


                   inc=incav*pi./180; %read the incidence angle
        quality=round(qualav); %read the retrieval quality
        
        if(res==1)
            badqual=~(quality ~= 0) .* (quality ~= 16) .* (quality ~= 64) .* (quality ~= 80);
        else
            badqual=~(quality ~= 0) .* (quality ~= 8);
        end
        
        good_pixels = ones(size(tbav,1),size(tbav,2));
        good_pixels = good_pixels .* ~((wfracav > 0) .* wfraccorrect) .* ~isnan(tbav) .* ~isnan(clayf) .* ~isnan(tempav) ...
                .* ~isnan(albav) .* ~isnan(vopav) .* ~isnan(inc) .* ~isnan(rghav) .* badqual ;
        good_pixels(good_pixels == 0) = NaN;
        
        emis=tbav./tempav; %calculate the rough emissivity
        
        % Vegetation and roughness correction
        h=rghav;
        cantrans=exp(-vopav); %Canopy transmissivity

        clay_dim1 = size(clayf,1);
        clay_dim2 = size(clayf,2);
        
       
        clay_vec = reshape(clayf,[1,clay_dim1 * clay_dim2]);
        good_clay = reshape(good_pixels,[1,clay_dim1 * clay_dim2]);
        
        
        good_clay(isnan(good_clay)) = 0;
        good = find(good_clay);
        inc_vec = reshape(inc, [1, clay_dim1 * clay_dim2]);
        emis_vec = reshape(emis, [1, clay_dim1 * clay_dim2]);
        moisture_map = reshape(moisture_map, [1, clay_dim1 * clay_dim2]);
        h = reshape(h, [1, clay_dim1 * clay_dim2]);
        cantrans = reshape(cantrans, [1, clay_dim1 * clay_dim2]);
        albav = reshape(albav, [1, clay_dim1 * clay_dim2]);
        tb_map = reshape(tb_map, [1, clay_dim1 * clay_dim2]);
        
        
        dielec=(sm2dc_v2(moisture_map(good),clay_vec(good))); %Use dielectric mixing model
            
        emis=1-abs((bsxfun(@times, dielec, cos(inc_vec(good))) - (bsxfun(@minus, dielec, sin(inc_vec(good)) .^ 2)).^0.5)...
             ./(bsxfun(@times, dielec, cos(inc_vec(good))) + (bsxfun(@minus, dielec, sin(inc_vec(good)).^2)).^0.5)).^2;
            

            emis = (emis - 1) ./ exp(h(good).*cos(inc_vec(good)).^2) + 1; % Add surface roughness effects
            emis = emis .* (cantrans(good).^2 + albav(good) .* cantrans(good) - albav(good).*cantrans(good).^2) + 1 - cantrans(good).^2 - albav(good) + albav(good) .* cantrans(good).^2; %Add vegetation effects
            tb = emis .* tempav(good);

            tb_map(good) = tb;
            tb_map = reshape(tb_map, size(tbav));



end
