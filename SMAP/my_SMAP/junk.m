for i=1:length(my_errors)
    tot(i) = my_errors(i).err(1);
    root(i) = my_errors(i).err(2);
end

mean(tot)
mean(root)


% load sm
% load smav_range
% for i=1:length(smav_range)
%     smav(:,:,i) = smav_range(i).smav;
% end
% 
% figure(1)
% imagesc(nanmean(smav,3))
% 
% for i = 1:length(sm)
%     sm_brown(:,:,i) = sm(i).sm;
% end
% figure(2)
% imagesc(nanmean(sm_brown,3))
