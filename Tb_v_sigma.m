% Script that divides cooresponding backscatter and brightness temperature
% images into a grid. Then compares each grid to find areas that have
% coorelation.

% Load images

% directory = '/home/low/NSID/comp_img/Temp/*.nc';

rangex1 = 3000;
rangex2 = 3500;
rangey1 = 3000;
rangey2 = 3500;

directory = '/Users/spencerlow/Documents/src/Tb_v_sigma';
[rad, scat] = multi_universal(directory,1);

for i = 1:length(scat)
    % scat(i).sig = reduce_size_byN(scat(i).sig,2);
    scat(i).sig(scat(i).sig < -32) = NaN;
end

rad = cat(3,rad(:).TB);
scat = cat(3,scat(:).sig);

rad_avg = sum(rad,3,'omitnan')./sum((rad > 0),3,'omitnan');
%fix scat_avg. 
scat_avg = sum(scat,3,'omitnan')./sum((scat > -33),3,'omitnan');
imagesc(scat_avg)

clear rad;
clear scat;

x1 = 1;
y1 = 1;
x2 = 1;
y2 = 1;

num_xsections = 80;
num_ysections = 80;
step_x = size(rad_avg,2)/num_xsections;
step_y = size(rad_avg,1)/num_ysections;
i = 1;
mask = zeros(size(rad_avg,1),size(rad_avg,2));
while x1 < size(rad_avg,2) - step_x
    y1 = 1;
    x2 = x1 + step_x;
    while y1 < size(rad_avg,1) - step_y
        % iterate y component
        %x2 = x1 + step_x;
        y2 = y1 + step_y;
        
        if abs(corr2(rad_avg(y1:y2,x1:x2),scat_avg(y1:y2,x1:x2))) > 0
            mask(y1:y2,x1:x2) = 1;
            corrco(y1:y2,x1:x2) = abs(corr2(rad_avg(y1:y2,x1:x2),scat_avg(y1:y2,x1:x2)));
        end
        %figure(i)
        %plot(rad_avg(x1:x2,y1:y2),scat_avg(x1:x2,y1:y2),'.');
        
        
        if y1 == 1
            %x1 = step_x;
            y1 = step_y;
        else
            %x1 = x1 + step_x;
            y1 = y1 + step_y;
        end
        i = i + 1;
    end
    % iterate x component
    
    if x1 == 1
        x1 = step_x;
        %y1 = step_y;
    else
        x1 = x1 + step_x;
        %y1 = y1 + step_y;
    end
    
end

figure(1)
plot(rad_avg(rangex1:rangex2,rangey1:rangey2),scat_avg(rangex1:rangex2,rangey1:rangey2),'.');
saveas(figure(1),'dotplot.png')

figure(2)
imagesc(scat_avg(rangex1:rangex2,rangey1:rangey2))
colorbar
impixelinfo
saveas(figure(2),'zoomedscat.png')

figure(3)
imagesc(rad_avg(rangex1:rangex2,rangey1:rangey2))
colorbar
impixelinfo
saveas(figure(3),'zoomedrad.png')

figure(4)
imagesc(mask(rangex1:rangex2,rangey1:rangey2))

figure(5)
imagesc(corrco(rangex1:rangex2,rangey1:rangey2))
colorbar
impixelinfo
saveas(figure(5),'zoomedcor.png')

figure(6)
imagesc(corrco)
colorbar
saveas(figure(6),'corrco.png')


