scat85 = load('/Users/spencerlow/Downloads/scat_avg85.mat');
rad85 = load('/Users/spencerlow/Downloads/rad_avg85.mat');
corr85 = load('/Users/spencerlow/Downloads/corr_img85.mat');


scat = double(scat85.scat);
rad = double(rad85.rad_avg);

scat_mean = nanmean(nanmean(scat));
scat_std = nanstd(nanstd(scat));
rad_mean = nanmean(nanmean(rad));
rad_std = nanstd(nanstd(rad));

scat_sim = rad(2000:3049,1000:2049);
%scat_sim = normrnd(scat_mean,scat_std,[1050,1050]);%.*rad(3000:4049,2000:3049);
rad_sim = scat(2000:3049,1000:2049);
%rad_sim = normrnd(rad_mean,rad_std,[1050,1050]);%.*scat(3000:4049,2000:3049);



window = 25;
corr_sim = zeros(1050,1050);

for i = window : size(scat_sim,1) - window + 1
    for j = window : size(scat_sim,2) - window + 1
        corr_sim(i,j) = corr2(rad_sim(i-window+1:i+window-1,j-window+1:j+window-1),...
            scat_sim(i-window+1:i+window-1,j-window+1:j+window-1));
    end
end


figure(1)
imagesc(scat_sim)

figure(2)
imagesc(rad_sim)

figure(3)
imagesc(corr_sim)

