% Process corr_img.mat files that are produced in the
% high_res_eps_v_sigma.m script

corr_img = load('/Users/spencerlow/Documents/src/Tb_v_sigma/corr_img.mat');%'/Users/spencerlow/Documents/MATLAB/corr_img.mat');
rad_avg = load('/Users/spencerlow/Documents/src/Tb_v_sigma/rad_avg.mat');%'/Users/spencerlow/Documents/MATLAB/rad_avg.mat');
scat_avg = load('/Users/spencerlow/Documents/src/Tb_v_sigma/scat_avg.mat');%'/Users/spencerlow/Documents/MATLAB/scat_avg.mat');

rad = rad_avg.rad_avg;
scat = scat_avg.scat_avg;

numb_step = 160;

stepx = size(rad,2) / numb_step;
stepy = size(rad,1) / numb_step;

figure(1)
imagesc(corr_img.corr_img)
colorbar 
axis off
title('High Resolution Correlation')
%saveas(figure(1),'/Users/spencerlow/Documents/src/images/high_res_corr.png')

correlated = corr_img.corr_img > .5;

figure(2)
imagesc(rad)
colorbar
axis off
title('Epsilon')
%saveas(figure(2),'/Users/spencerlow/Documents/src/images/epsilon.png')


figure(3)
imagesc(scat)
colorbar
axis off
title('Sigma-0')
%saveas(figure(3),'/Users/spencerlow/Documents/src/images/sigma.png')


figure(4)
plot((corr_img.corr_img(1350:1400,1750:1800) .* correlated(1350:1400,1750:1800)),'.')



% Find box with highest average coorelation
% Average coorelation = sqrt(corr1^2 + corr2^2)

i = 1;
j = 1;
h = 1;
k = 1;

while i < numb_step - 1
    j = 1;
    while j < numb_step - 1
        corr_avg(j,i) = sqrt(sum(sum(corr_img.corr_img(j*stepy : (j + 1) * stepy , i*stepx : (i + 1) * stepx).^2,'omitnan'),'omitnan'));
        j = j + 1;
        k = k + 1;
    end  
    i = i + 1;
    h = h + 1;
end

figure(5)
imagesc(corr_avg)
axis off
title('Average Correlation')
%saveas(figure(5),'/Users/spencerlow/Documents/src/images/corr_avg.png')

figure(6)
plot(scat(100 * stepy : 101 * stepy, 77 * stepx : 78 *stepx),rad(100 * stepy : 101 * stepy, 77 * stepx : 78 *stepx),'.')
xlabel('Sigma-0')
ylabel('(Th - Tv)/(Tb + Tb)')
title('Epsilon vs. Sigma-0')
%saveas(figure(6),'/Users/spencerlow/Documents/src/images/eps_v_sig.png')



corr_avg(100,77) = 2 * corr_avg(100,77);

figure(7)
imagesc(corr_avg)
colormap(jet)
colorbar
caxis([0,2])


