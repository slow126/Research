scat85 = load('/Users/spencerlow/Downloads/scat_avg85.mat');
rad85 = load('/Users/spencerlow/Downloads/rad_avg85.mat');
corr85 = load('/Users/spencerlow/Downloads/corr_img85.mat');

figure(1)
imagesc(scat85.scat')
colorbar
axis off
title('OSCAT sigma0')
%saveas(figure(1),'/Users/spencerlow/Documents/src/T_images/sigma85.png')

figure(2)
imagesc(rad85.rad_avg')
colorbar
axis off
title('Epsilon from 85gHz')
%saveas(figure(2),'/Users/spencerlow/Documents/src/T_images/epsilon85.png')

figure(3)
imagesc(corr85.corr_img')
colorbar
axis off
title('Correlation Coefficient rho')
%saveas(figure(3),'/Users/spencerlow/Documents/src/T_images/rho85.png')

scat37 = load('/Users/spencerlow/Downloads/scat_avg37.mat');
rad37 = load('/Users/spencerlow/Downloads/rad_avg37.mat');
corr37 = load('/Users/spencerlow/Downloads/corr_img37.mat');

figure(4)
imagesc(scat37.scat')
colorbar
axis off
title('OSCAT sigma0')
%saveas(figure(4),'/Users/spencerlow/Documents/src/T_images/sigma37.png')

figure(5)
imagesc(rad37.rad_avg')
colorbar
axis off
title('Epsilon from 37gHz')
%saveas(figure(5),'/Users/spencerlow/Documents/src/T_images/epsilon37.png')

figure(6)
imagesc(corr37.corr_img')
colorbar
axis off
title('Correlation Coefficient rho')
%saveas(figure(6),'/Users/spencerlow/Documents/src/T_images/rho37.png')

highCorrpix = corr37.corr_img > .8;

