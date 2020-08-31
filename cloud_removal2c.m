%Take the the lower median modified mean of the all values that are
%identified as being water. 

path1 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.01/*.nc';
path2 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.02/*.nc';
path3 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.03/*.nc';
path4 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.04/*.nc';
path5 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.05/*.nc';
path6 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.06/*.nc';
path7 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.07/*.nc';
path8 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.08/*.nc';
path9 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.09/*.nc';
path10 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.10/*.nc';
path11 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.11/*.nc';
path12 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.12/*.nc';
path13 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.13/*.nc';
path14 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.14/*.nc';
path15 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.15/*.nc';
path16 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.16/*.nc';
path17 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.17/*.nc';
path18 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.18/*.nc';
path19 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.12/*.nc';
path20 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.20/*.nc';
path21 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.21/*.nc';
path22 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.22/*.nc';
path23 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.23/*.nc';
path24 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.24/*.nc';
path25 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.25/*.nc';
path26 = '/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.26/*.nc';

cp = [271,250];
%360,110 is an example of a cloud free data point.\
%797,10 is an example of a cloudy data point.

paths = {path1,path2,path3,path4,path5,path6,path7,path8,path9,path10,path11,path12....
    path13,path14,path15,path16,path17,path18,path19,path20,path21,path22...
    path24,path25,path26};
%temp = {path5,path6,path7,path8};


path1 = '/Users/spencerlow/Documents/src/sirdump/*.nc';
paths = {path1};
directory = char(paths);


numbers = average_cloud(directory,'All','T',25,36,'V','A');
numbers = rmfield(numbers(:),'count');
numbers = rmfield(numbers(:),'pix_sum');
numbers = rmfield(numbers(:),'std_count');
numbers = rmfield(numbers(:),'std_sum');

numbers = numbers';

%Hybrid MMA Calculation

%[index(length(numbers)).above_mean] = deal(0);
[index(length(numbers)).sum] = deal(0);
%[index(length(numbers)).count] = deal(0);
[index(length(numbers)).mma] = deal(0);

count = [];
above_mean = zeros(size(numbers(1).TB,1),size(numbers(1).TB,2));
compile = cat(3,numbers(:).TB);
compile(~compile) = NaN;
%tb_median = compile(ceil(end/2),3);
middle = (((max(compile,[],3)-min(compile,[],3))/2 + min(compile,[],3)));
for i = 1 : length(numbers)    
    
    
    %above_mid = numbers(i).TB > middle;
    
    above_mid = numbers(i).TB > middle;
    below_mid = numbers(i).TB < middle & numbers(i).TB > 0;
    
    %Above the middle MMA
    if i == 1
        index(i).sum = numbers(i).TB.*above_mid;
        count = above_mid;
    else
        index(i).sum = index(i-1).sum + numbers(i).TB.*above_mid;
        count = count + above_mid;
    end
    index(i).mma = index(i).sum ./ count;
    
    %Below the middle MMA
    if i == 1
        index(i).bsum = numbers(i).TB .* below_mid;
        bcount = below_mid;
    else
        index(i).bsum = index(i-1).bsum + numbers(i).TB .* below_mid;
        bcount = bcount + below_mid;
    end
    index(i).bmma = index(i).bsum ./ bcount;
    
end


water = mean(compile,3,'omitnan') < middle;
%water = index(length(numbers)).mma < 200;

index(length(numbers)).mma = index(length(numbers)).mma .* ~water + index(i).bmma .* water;%mea(compile,3,'omitnan') .* water;

%Change to standard deviation of the time series rather than the standard
%deviation of the pixel. 

std_dev = std(compile,0,3,'omitnan');



%threshold = numbers(1).TB_std_dev < 1.25 & numbers(1).TB_std_dev > 0;
threshold = std_dev < 1.25 & std_dev > 0;

normal_mean = threshold.*numbers(length(numbers)).pix_avg;
mma = (~threshold.*index(length(numbers)).mma);

TB_eff = normal_mean + mma;
%%%%%%
%{
water = TB_eff < 200;

index(length(numbers)).mma = index(length(numbers)).mma .* ~water + index(length(numbers)).bmma .* water;%mea(compile,3,'omitnan') .* water;

%Change to standard deviation of the time series rather than the standard
%deviation of the pixel. 

std_dev = std(compile,0,3,'omitnan');



%threshold = numbers(1).TB_std_dev < 1.25 & numbers(1).TB_std_dev > 0;
threshold = std_dev < 1.25 & std_dev > 0;

normal_mean = threshold.*numbers(length(numbers)).pix_avg;
mma = (~threshold.*index(length(numbers)).mma);

TB_eff = normal_mean + mma;
%}
%%%%%%% 

%replace the nan's in the image

%valid = numbers(1).TB > 0;
%TB_eff(~valid) = NaN;

    for i = 1:length(numbers)
        found = (numbers(i).TB > 0); %Replace 0's with NaN to help create better scaled images
        numbers(i).TB(~found) = NaN;
        missing = (numbers(i).TB == 600); %Remove missing values
        numbers(i).TB(missing) = NaN;
    end
    
for i = 1 : length(numbers)
    temp_avg(:,:,i) =  numbers(length(numbers)).pix_avg;
end

% Attempt to calculate the standard deviation of all values less than the
% mean to try and determine the standard deviation of the temperature drop
% that is caused by clouds.
temp_std = compile < temp_avg;
temp_comp = temp_std .* compile;
temp_comp(isnan(temp_comp)) = 0;
temp_comp(~temp_comp) = NaN;
cloud_std = std((temp_comp),[],3,'omitnan');
    
figure(1)
imagesc(numbers(1).TB')%(475:540,275:370)')
set(gca, 'CLim', [50, 350]);
colorbar
impixelinfo
%title('brightness temperature for first path')
saveas(figure(1),'TB.png')


figure(2)
imagesc(cloud_std')
set(gca,'CLim',[0,20]);
colorbar
impixelinfo
title('cloud standard deviation')


figure(3)
imagesc(std_dev')%(475:540,275:370)')
%set(gca, 'CLim', [15, 46]);
colormap pink
colorbar
impixelinfo
%saveas(figure(3),'clouds.png')

figure(4)
imagesc(TB_eff')%(475:540,275:370)')
set(gca, 'CLim', [50, 350]);
colorbar
impixelinfo
%title('hybrid mma')
%saveas(figure(4),'hybridmma.png')

figure(5)
imagesc(index(length(numbers)).mma')%(475:540,275:370)')
set(gca, 'CLim', [50, 350]);
colorbar
impixelinfo
%saveas(figure(5),'modifiedmean.png')

figure(6)
imagesc(numbers(length(numbers)).pix_avg')%(475:540,275:370)')
set(gca, 'CLim', [50, 350]);
colorbar
impixelinfo
saveas(figure(6),'mean.png')

clouds = numbers(3).pix_avg .* ~threshold;
temp = clouds == 0;
clouds(temp) = NaN;

%{
figure(7)
imagesc(clouds')
colorbar
impixelinfo
title('clouds')
%}
for i = 1:length(numbers)    
    seq1(i) = numbers(i).TB(cp(1)-1,cp(2)-1);
    seq2(i) = numbers(i).TB(cp(1)-1,cp(2));
    seq3(i) = numbers(i).TB(cp(1)-1,cp(2)+1);
    seq4(i) = numbers(i).TB(cp(1),cp(2)-1);
    seq5(i) = numbers(i).TB(cp(1),cp(2));
    seq6(i) = numbers(i).TB(cp(1),cp(2)+1);
    seq7(i) = numbers(i).TB(cp(1)+1,cp(2)-1);
    seq8(i) = numbers(i).TB(cp(1)+1,cp(2));
    seq9(i) = numbers(i).TB(cp(1)+1,cp(2)+1);
end

sequence = [seq1,seq2,seq3,seq4,seq5,seq6,seq7,seq8,seq9];

figure(8)
histogram(temp_comp(100,100,:),20)%histogram(seq5,26)

figure(9)
histogram(compile(100,100,:),20)
%{

for i = 1: size(numbers(1).TB,1)
    for j = 1: size(numbers(1).TB,2)
        if isnan(numbers(1).TB(i,j))
            TB(i,j) = NaN;
        elseif numbers(1).TB_std_dev(i,j) > 1.25 %&& ~isnan(numbers(1).TB(i,j))
            %MMA
            for k = 1: length(numbers)
                if numbers(k).TB(i,j) > numbers(length(numbers)).pix_avg(i,j)
                    above_mean(k) = numbers(k).TB(i,j);
                else
                    above_mean(k) = NaN;
                end
                
            end
            TB(i,j) = nansum(above_mean)/sum(~isnan(above_mean));
        else
            TB(i,j) = numbers(length(numbers)).pix_avg(i,j);
        end    
    end
end


same = sum(sum(TB == TB_eff));

figure(3)
imagesc(TB')
colorbar
impixelinfo

for i=1:size(numbers(1).TB,1)
    for j = 1:size(numbers(1).TB,2)
        if isnan(numbers(1).TB(i,j))
            test(i,j) = NaN;
        else
            for k = 1: length(numbers)
                if numbers(k).TB(i,j) > numbers(length(numbers)).pix_avg(i,j)
                    above(k) = numbers(k).TB(i,j);
                else
                    above(k) = NaN;
                end
                test(i,j) = nansum(above)/sum(~isnan(above));
            
            end
        end
    end
end

figure(3)
imagesc(TB')
colorbar
impixelinfo

figure(4)
imagesc(numbers(length(numbers)).pix_avg')
colorbar
impixelinfo

figure(5)
imagesc(test')
colorbar
impixelinfo

%}






