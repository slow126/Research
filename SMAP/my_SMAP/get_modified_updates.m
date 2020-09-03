function [a_val, a_temp, tot, sx, sx2, total] = get_modified_updates(power, ang, count,...
    fill_array, response_array, a_val, sx, sx2, a_temp, tot, nsx, nsy)

total = zeros(length(fill_array),1);
num = zeros(length(fill_array), 1);
ave = zeros(length(fill_array), 1);

% scale = 0;
% update = 0;
% test = 0;

% i = 0;
% n = 0;
%
% m = 0;

% old_nsx = size(a_val,1);
% old_nsy = size(a_val,2);
% a_val = reshape(a_val, [nsx, nsy]);
% a_val = sm2tb(flipud(a_val'), 2016, 275, 1);
% a_val = flipud(a_val);
% a_val = reshape(a_val', [old_nsx, old_nsy]);


ave = total ./ num;
update_idx = ones(size(ave,1), size(ave,2));
update_idx(ave == 0) = 0;

scale = power ./ ave;
% update = zeros(size(scale,1),size(scale,2));

scale(scale > 0) = sqrt(scale(scale > 0));
scale(scale <= 0) = 1;

for i=1:length(scale)
    if scale(i) > 1
        update(i).upd = 1.0./((0.5/ave(i))*(1.0-1.0/scale(i))+1.0./((a_val(fill_array(i).pt) * scale(i))));
    else
        update(i).upd =  0.5 * ave(i) * (1.0 - scale(i)) + (a_val(fill_array(i).pt)) * scale(i);
    end
    
    tot(fill_array(i).pt) = tot(fill_array(i).pt) + response_array(i).resp;
    test = (a_temp(fill_array(i).pt) .* (tot(fill_array(i).pt) - response_array(i).resp) + update(i).upd .* response_array(i).resp) ./ tot(fill_array(i).pt);
    a_temp(fill_array(i).pt) = test;
    sx(fill_array(i).pt) = (sx(fill_array(i).pt) .* (tot(fill_array(i).pt) - response_array(i).resp) + response_array(i).resp .* ang(i)) ./ tot(fill_array(i).pt);
    sx2(fill_array(i).pt) = (sx2(fill_array(i).pt) .* (tot(fill_array(i).pt) - response_array(i).resp) + response_array(i).resp .* (ang(i).^2)) ./ tot(fill_array(i).pt);
    

%     temp4 = a_val;
%     temp4(a_temp > 0) = a_temp(a_temp > 0);
%     temp3 = reshape(temp4, [nsx, nsy]);
%     figure(3)
%     imagesc(temp3)
%     colormap(gray)
    
end




end

