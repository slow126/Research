aearth=6378.1363;
FLAT=3.3528131778969144e-3;

egg_lon=229.8908
egg_lat=87.1406

xlon=[ 3.8584    3.6810    2.2433    2.3756    3.1061    3.4435 4.2097 4.1200    3.8584];
ylat=[-0.0760   -0.0748    0.1346    0.1377    0.1174    0.1000 -0.0122 -0.0543   -0.0760];

    r=(1.0-FLAT*(sin(egg_lat*pi/180)^2))*aearth;
    r2=r*cos((egg_lat+ylat)*pi/180);
    xrel=r2.*sin(xlon*pi/180);
    yrel=r*sin(ylat*pi/180)+(1-cos(xlon*pi/180))*sin(egg_lat*pi/180).*r2;

    r2x=r*cos((egg_lat+ylat)*pi/180);
    dlon=asin(xrel./r2x);
    dlat=asin((yrel-(1-cos(dlon))*sin(egg_lat).*r2x)/r);
    xxlon=dlon*180/pi;
    yylat=dlat*180/pi;

[xlon-xxlon; ylat-yylat]

figure(1)
plot(xlon,ylat,'r');
hold on
plot(xxlon,yylat,'g')
hold off
