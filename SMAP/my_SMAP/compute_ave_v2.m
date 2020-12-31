function [ave] = compute_ave_v2(pow, data, a_val,fig)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    ave = zeros(size(a_val));
    total = zeros(size(a_val));
    resp_total = zeros(size(a_val));
    for i = 1:length(pow)
%         data(i).sm_resp = data(i).sm_resp;
        total(data(i).pt) = total(data(i).pt) + pow(i) .* data(i).sm_resp;
        resp_total(data(i).pt) = resp_total(data(i).pt) + data(i).sm_resp;
        ave(data(i).pt) = nansum(pow(i) .* data(i).sm_resp) ./ nansum(data(i).sm_resp);
       
%     total2 = ones(size(total)) * -1;
%     if length(response_array(i).resp) > 140
%         for j = 1:length(response_array(i).resp)
%             figure(10)
%             total2(fill_array(i).pt(j)) = pow(i) .* response_array(i).resp(j);
%             temp = reshape(total2, [11568,4872]);
%             temp = flipud(temp');
% %             imagesc(temp(300:338, 8460:8560))
%             imagesc(temp)
%             drawnow
%         end
%     end
    
%     temp = total;
%     figure(2)
%     temp = reshape(total, [11568,4872]);
%     temp = flipud(temp');
%     imagesc(temp(900:1400,8150:8350))
%     drawnow
    end
    ave = total ./ resp_total;
    
    figure(fig)
    temp = reshape(ave, [11568,4872]);
    temp(isnan(temp)) = NaN;
    temp = flipud(temp');
%     imagesc(temp(900:1400,8150:8350))
    imagesc(temp)
    drawnow

end

