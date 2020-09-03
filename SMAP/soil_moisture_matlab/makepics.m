% Create some images used in the thesis

day=350;
year=2016;

% 3 km Stuff
tbaid1=H5F.open(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M03km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-SIR-JPL-v1.0.nc'], 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
tbdid1=H5F.open(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M03km-SMAP_LRM-' num2str(year) num2str(day, '%03d') '-1.4V-D-SIR-JPL-v1.0.nc'], 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
tbadataid1=H5D.open(tbaid1,'TB');
tbddataid1=H5D.open(tbdid1,'TB');
tbaav1=H5D.read(tbadataid1,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
tbaav1=fliplr(rot90(tbaav1*.01,3));
tbaav1(tbaav1==600)=NaN;
tbaav1(tbaav1==0)=NaN;
tbdav1=H5D.read(tbddataid1,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
tbdav1=fliplr(rot90(tbdav1*.01,3));
tbdav1(tbdav1==600)=NaN;
tbdav1(tbdav1==0)=NaN;

tbav1=nan(size(tbaav1));
tbav1(~isnan(tbaav1) & isnan(tbdav1)) = tbaav1(~isnan(tbaav1) & isnan(tbdav1));
tbav1(isnan(tbaav1) & ~isnan(tbdav1)) = tbdav1(isnan(tbaav1) & ~isnan(tbdav1));
tbav1(~isnan(tbaav1) & ~isnan(tbdav1)) = (tbaav1(~isnan(tbaav1) & ~isnan(tbdav1)) + tbdav1(~isnan(tbaav1) & ~isnan(tbdav1)))/2;

% 9 km Stuff
tbaid2=H5F.open(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M09km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-SIR-JPL-v1.0.nc'], 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
tbdid2=H5F.open(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M09km-SMAP_LRM-' num2str(year) num2str(day, '%03d') '-1.4V-D-SIR-JPL-v1.0.nc'], 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
tbadataid2=H5D.open(tbaid2,'TB');
tbddataid2=H5D.open(tbdid2,'TB');
tbaav2=H5D.read(tbadataid2,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
tbaav2=fliplr(rot90(tbaav2*.01,3));
tbaav2(tbaav2==600)=NaN;
tbaav2(tbaav2==0)=NaN;
tbdav2=H5D.read(tbddataid2,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
tbdav2=fliplr(rot90(tbdav2*.01,3));
tbdav2(tbdav2==600)=NaN;
tbdav2(tbdav2==0)=NaN;

tbav2=nan(size(tbaav2));
tbav2(~isnan(tbaav2) & isnan(tbdav2)) = tbaav2(~isnan(tbaav2) & isnan(tbdav2));
tbav2(isnan(tbaav2) & ~isnan(tbdav2)) = tbdav2(isnan(tbaav2) & ~isnan(tbdav2));
tbav2(~isnan(tbaav2) & ~isnan(tbdav2)) = (tbaav2(~isnan(tbaav2) & ~isnan(tbdav2)) + tbdav2(~isnan(tbaav2) & ~isnan(tbdav2)))/2;


% 36 km Stuff
tbaid3=H5F.open(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M36km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-GRD-JPL-v1.0.nc'], 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
tbdid3=H5F.open(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M36km-SMAP_LRM-' num2str(year) num2str(day, '%03d') '-1.4V-D-GRD-JPL-v1.0.nc'], 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
tbadataid3=H5D.open(tbaid3,'TB');
tbddataid3=H5D.open(tbdid3,'TB');
tbaav3=H5D.read(tbadataid3,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
tbaav3=fliplr(rot90(tbaav3*.01,3));
tbaav3(tbaav3==600)=NaN;
tbaav3(tbaav3==0)=NaN;
tbdav3=H5D.read(tbddataid3,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
tbdav3=fliplr(rot90(tbdav3*.01,3));
tbdav3(tbdav3==600)=NaN;
tbdav3(tbdav3==0)=NaN;

tbav3=nan(size(tbaav3));
tbav3(~isnan(tbaav3) & isnan(tbdav3)) = tbaav3(~isnan(tbaav3) & isnan(tbdav3));
tbav3(isnan(tbaav3) & ~isnan(tbdav3)) = tbdav3(isnan(tbaav3) & ~isnan(tbdav3));
tbav3(~isnan(tbaav3) & ~isnan(tbdav3)) = (tbaav3(~isnan(tbaav3) & ~isnan(tbdav3)) + tbdav3(~isnan(tbaav3) & ~isnan(tbdav3)))/2;

tbav1(tbav1<200)=NaN;
tbav2(tbav2<200)=NaN;
tbav3(tbav3<200)=NaN;

tbav1(tbav1>400)=NaN;
tbav2(tbav2>400)=NaN;
tbav3(tbav3>400)=NaN;

tbav1=(tbav1-200)/200;
tbav2=(tbav2-200)/200;
tbav3=(tbav3-200)/200;

tbav1(isnan(tbav1))=0;
tbav2(isnan(tbav2))=0;
tbav3(isnan(tbav3))=0;

imwrite(tbav1,'/home/brown/soil_moisture/presentation_images/tb_3ex.png','PNG');
imwrite(tbav2,'/home/brown/soil_moisture/presentation_images/tb_9ex.png','PNG');
imwrite(tbav3,'/home/brown/soil_moisture/presentation_images/tb_36ex.png','PNG');