function [outputArg1,outputArg2] = get_goodData(tbval, pointer, aresp1, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav,)

[ nsy1 , nsx1 ] = size(tbav);

moisture_map=NaN(size(tbav));
% if(res==1)
%     possible_mois = 0.02:.0001:.65;
%     %         possible_mois = 0.02:.001:.5;
% else
%     possible_mois = 0.02:.001:.5;
% end

        inc=incav*pi./180; %read the incidence angle
        quality=round(qualav); %read the retrieval quality
        
        if(res==1)
            badqual=~(quality ~= 0) .* (quality ~= 16) .* (quality ~= 64) .* (quality ~= 80);
        else
            badqual=~(quality ~= 0) .* (quality ~= 8);
        end
        
        good_pixels = ones(size(tbav,1),size(tbav,2));
        good_pixels = good_pixels .* ~((wfracav > 0) .* wfraccorrect) .* ~isnan(tbav) .* ~isnan(clayf) .* ~isnan(tempav) ...
                .* ~isnan(albav) .* ~isnan(vopav) .* ~isnan(inc) .* ~isnan(rghav);% .* badqual ;
%             continue; %skip if we don't have all necessary info, or bad quality
        good_pixels(good_pixels == 0) = NaN;


end

