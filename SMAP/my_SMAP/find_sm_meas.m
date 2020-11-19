function [data_idx] = find_sm_meas(fill_array, res, albav, incav, qualav, clayf, vopav, rghav, tempav, wfracav)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


inc=incav*pi./180; %read the incidence angle
quality=round(qualav); %read the retrieval quality
wfraccorrect = 1;

if(res==1)
    badqual=~(quality ~= 0) .* (quality ~= 16) .* (quality ~= 64) .* (quality ~= 80);
else
    badqual=~(quality ~= 0) .* (quality ~= 8);
end

good_pixels = ones(size(tempav,1),size(tempav,2));
good_pixels = good_pixels .* ~((wfracav > 0) .* wfraccorrect) .* ~isnan(clayf) .* ~isnan(tempav) ...
        .* ~isnan(albav) .* ~isnan(vopav) .* ~isnan(inc) .* ~isnan(rghav); % .* badqual ;
%             continue; %skip if we don't have all necessary info, or bad quality
good_pixels(good_pixels == 0) = NaN;
good_pixels = reshape_img(good_pixels, 1, []);

[nsy1, nsx1] = size(tempav);
        


good_img = zeros(1,size(clayf,1) * size(clayf,2));
k = 1;
repeats = zeros(1,length(fill_array));
for i = 1:length(fill_array)
%     if nansum(good_pixels(fill_array(i).pt)) > 0
    if good_pixels(fill_array(i).pt(ceil(end/2))) == 1
        if (nansum(ismember(repeats, fill_array(i).pt(ceil(end/2)))) == 0)
            repeats(i) = fill_array(i).pt(ceil(end/2));
            [temp_min, temp_idx] = min(abs(fill_array(i).pt - nanmedian(fill_array(i).pt)));
            data_idx(k) = i;%fill_array(i).pt(temp_idx);
            k = k + 1;
        end
    end
end
       
good_img(data_idx) = 1;
good_img = reshape_img(good_img, size(clayf,2),size(clayf,1));
imagesc(good_img);


        
end

