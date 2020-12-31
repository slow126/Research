function [data] = get_goodData(tbval, pointer, aresp1, tbav, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav)


inc=incav*pi./180; %read the incidence angle
quality=round(qualav); %read the retrieval quality

wfraccorrect=1;

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

    good_pixels = reshape_img(good_pixels,1,[]);
    tbav = reshape_img(tbav,1,[]);
    albav = reshape_img(albav,1,[]);
    qualav = reshape_img(qualav,1,[]);
    clayf = reshape_img(clayf,1,[]);
    vopav = reshape_img(vopav,1,[]);
    rghav = reshape_img(rghav,1,[]);
    vwcav = reshape_img(vwcav,1,[]);
    tempav = reshape_img(tempav,1,[]);
    wfracav = reshape_img(wfracav,1,[]);
    inc = reshape_img(inc,1,[]);
    
    k = 1;
    for i = 1:length(tbval)
        if(~isnan(good_pixels(pointer(i).pt(ceil(end/2)))))
            temp = good_pixels(pointer(i).pt);
            mask = ~isnan(temp);
            mask = find(mask);
            
            data(k).tb_meas_loc = find(mask == ceil(length(temp)/2));
            data(k).tb_meas = tbval(i);
            data(k).pt = pointer(i).pt(mask);
            data(k).resp = aresp1(i).resp(mask);
            data(k).wfracav = wfracav(pointer(i).pt(mask))';
            data(k).tbav = tbav(pointer(i).pt(mask))';
            data(k).clayf = clayf(pointer(i).pt(mask))';
            data(k).tempav = tempav(pointer(i).pt(mask))';
            data(k).albav = albav(pointer(i).pt(mask))';
            data(k).vopav = vopav(pointer(i).pt(mask))';
            data(k).inc = inc(pointer(i).pt(mask))';
            data(k).rghav = rghav(pointer(i).pt(mask))';
            data(k).vwcav = vwcav(pointer(i).pt(mask))';
            data(k).sm = zeros(size(pointer(i).pt(mask)));
            data(k).idx = i;
            data(k).sm_resp = zeros(size(pointer(i).pt(mask)));
            k = k + 1;
        end
    end
    
        


end

