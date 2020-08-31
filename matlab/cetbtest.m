%data = readcetb('/home/low/NSID/Radiometer/AQUA/2006/n5eil01u.ecs.nsidc.org/MEASURES/NSIDC-0630.001/2006.01.01/NSIDC-0630-EASE2_T6.25km-AQUA_AMSRE-2006001-23V-D-SIR-RSS-v1.0.nc',1);

%data = readcetb('/home/long/src/linux/mymeasures/src/cetb2sir/examples/NSIDC-0630-EASE2_T25km-AQUA_AMSRE-2009274-36V-A-GRD-RSS-v1.0.nc',1);

data = readcetb('/home/long/src/linux/mymeasures/src/cetb2sir/examples/NSIDC-0630-EASE2_T3.125km-AQUA_AMSRE-2008215-36V-A-SIR-RSS-v1.0.nc',1);

%data = readcetb('/home/long/src/linux/mymeasures/src/cetb2sir/examples/NSIDC-0630-EASE2_S3.125km-AQUA_AMSRE-2008215-36V-M-SIR-RSS-v1.0.nc',1);

printsirhead(data.tb_head)

y = (1:size(data.TB,1));
x = (1:size(data.TB,2));

[lon, lat] = pix2latlon(x,y,data.tb_head);
figure(1)
imagesc(lon,lat,data.TB)
axis xy

