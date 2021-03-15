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
        total(data(i).pt) = total(data(i).pt) + pow(i) .* (data(i).sm_resp);
        resp_total(data(i).pt) = resp_total(data(i).pt) + abs(data(i).sm_resp);
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
    ave = (total) ./ ((resp_total));
    
    figure(fig)
%     temp = reshape(ave, [11568,4872]);
    temp = reshape(ave, [316, 158]);
%     temp(temp == 0) = NaN;
    temp = flipud(temp');
%     imagesc(temp(900:1400,8150:8350))
%     temp(temp > 0.6) = 0.6;
%     temp(temp < 0) = 0;
%     temp(isnan(temp)) = -1;
%     temp = (temp - nanmin(temp(:))) ./ (nanmax(temp(:)) - nanmin(temp(:))) * 0.6 + 0.02;
%     temp(temp < 0) = NaN;
%     imagesc((temp(3274:3580, 3715:4000)))

%     temp(temp < 0) = temp(temp<0).^1.2;
    
%     ave(ave < 0) = abs(ave(ave<0).^1.2);

%     imagesc(abs(temp(3274:3580, 3715:4000)))
    
    imagesc(temp)
    drawnow

end

