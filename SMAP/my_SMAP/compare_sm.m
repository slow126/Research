load 'sm.mat'
load 'data_range.mat'
load 'smav_range.mat'

for i = 1:length(sm)
    jordan(:,:,i) = sm(i).sm;
    mine(:,:,i) = flipud(reshape(data(i).out, size(jordan,2), size(jordan,1))');
    mine(mine > 0.6) = NaN;
    [jordan_error(i).totalerr, jordan_error(i).rmse] = compute_sm_err(smav_range(i).smav, jordan(:,:,i));
    [my_error(i).totalerr, my_error(i).rmse] = compute_sm_err(smav_range(i).smav, mine(:,:,i));
    smav_temp(:,:,i) = smav_range(i).smav;
end

jordan_avg = nanmean(jordan,3);
mine_avg = nanmean(mine,3);
smav_avg = nanmean(smav_temp,3);

figure(1)
imagesc(jordan_avg)
caxis([0,1])
title('Jordan')

figure(2)
imagesc(mine_avg)
caxis([0,1])
title('Spencer')

diff = jordan_avg - mine_avg;

figure(3)
imagesc(diff)
title('Diff')
title('Diff between mine and Jordans')

figure(4)
imagesc(smav_avg - mine_avg)
title('Diff between mine and SMAP')

figure(5)
imagesc(smav_avg - jordan_avg)
title('Diff between Jordan and SMAP')