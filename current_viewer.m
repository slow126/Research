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

%paths = {path1,path2,path3};%,path4};
%temp = {path5,path6,path7,path8};
directory = char(paths);


numbers = average_cloud(directory,'AQUA_AMSRE','T',25,36,'H','A');
numbers = rmfield(numbers(:),'count');
numbers = rmfield(numbers(:),'pix_sum');
numbers = rmfield(numbers(:),'std_count');
numbers = rmfield(numbers(:),'std_sum');

numbers = numbers';

last = length(numbers);
numbers(last).pix_avg(numbers(last).pix_avg > 200) = NaN;

figure(1)
imagesc(numbers(last).pix_avg')
colorbar
impixelinfo


