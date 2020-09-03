%% Options and EASE-2 Info

% clear;
% extradata = 0; This is set in soilMoistureMap_SIR
showplottb = false; %Plot the data
year = 2016;
day = 153; % Julian day - remember 2016 is a leap year 

load('smNets.mat');

%% Soil Moisture loading

% tbfolder = ['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/'];
% sirfile = [tbfolder 'E2T_3125.sir'];
% [tbav, head, descrip, iaopt]=loadsir(sirfile);
% tbav(tbav==100)=NaN;
nday=day+1;

tbaid=H5F.open(['/auto/temp/brown/smData/globusdata/' num2str(year) '/NSIDC-0738-EASE2_T3.125km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-SIR-JPL-v1.0.nc'], 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
tbdid=H5F.open(['/auto/temp/brown/smData/globusdata/' num2str(year) '/NSIDC-0738-EASE2_T3.125km-SMAP_LRM-' num2str(year) num2str(day, '%03d') '-1.4V-D-SIR-JPL-v1.0.nc'], 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
tbadataid=H5D.open(tbaid,'TB');
tbddataid=H5D.open(tbdid,'TB');
tbaav=H5D.read(tbadataid,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
tbaav=fliplr(rot90(tbaav*.01,3));
tbaav(tbaav==600)=NaN;
tbaav(tbaav==0)=NaN;
tbdav=H5D.read(tbddataid,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
tbdav=fliplr(rot90(tbdav*.01,3));
tbdav(tbdav==600)=NaN;
tbdav(tbdav==0)=NaN;

tbav=nan(size(tbaav));
tbav(~isnan(tbaav) & isnan(tbdav)) = tbaav(~isnan(tbaav) & isnan(tbdav));
tbav(isnan(tbaav) & ~isnan(tbdav)) = tbdav(isnan(tbaav) & ~isnan(tbdav));
tbav(~isnan(tbaav) & ~isnan(tbdav)) = (tbaav(~isnan(tbaav) & ~isnan(tbdav)) + tbdav(~isnan(tbaav) & ~isnan(tbdav)))/2;

sirfolder = ['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/'];
ancfolder = [sirfolder 'ancillarysir/'];
ancfolder2 = ['/auto/temp/brown/smData/' num2str(year) '/' num2str(nday) '/ancillarysir/'];
sirfile = [ancfolder 'alb_3125-' num2str(day) '.sir'];
[albav, head, descrip, iaopt]=loadsir(sirfile);
sir2file = [ancfolder2 'alb_3125-' num2str(nday) '.sir'];
[tmp, head, descrip, iaopt]=loadsir(sir2file);
albav(albav==-1)=NaN;
tmp(tmp==-1)=NaN;
albav(~isnan(albav) & ~isnan(tmp)) = (albav(~isnan(albav) & ~isnan(tmp)) + tmp(~isnan(albav) & ~isnan(tmp)))/2;
albav(isnan(albav) & ~isnan(tmp)) = tmp(isnan(albav) & ~isnan(tmp));

sirfile = ['/auto/temp/brown/smData/clayf_3125.sir'];
[clayf, head, descrip, iaopt]=loadsir(sirfile);
clayf(clayf==-1)=NaN;

sirfile = [ancfolder 'inc_3125-' num2str(day) '.sir'];
[incav, head, descrip, iaopt]=loadsir(sirfile);
sir2file = [ancfolder2 'inc_3125-' num2str(nday) '.sir'];
[tmp, head, descrip, iaopt]=loadsir(sir2file);
incav(incav==0)=NaN;
tmp(tmp==0)=NaN;
incav(~isnan(incav) & ~isnan(tmp)) = (incav(~isnan(incav) & ~isnan(tmp)) + tmp(~isnan(incav) & ~isnan(tmp)))/2;
incav(isnan(incav) & ~isnan(tmp)) = tmp(isnan(incav) & ~isnan(tmp));

sirfile = [ancfolder 'retqual_3125-' num2str(day) '.sir'];
[qualav, head, descrip, iaopt]=loadsir(sirfile);
qualav=uint16(qualav);
qualav(qualav==-1)=NaN;

sirfile = [ancfolder 'rgh_3125-' num2str(day) '.sir'];
[rghav, head, descrip, iaopt]=loadsir(sirfile);
sir2file = [ancfolder2 'rgh_3125-' num2str(nday) '.sir'];
[tmp, head, descrip, iaopt]=loadsir(sir2file);
rghav(rghav==-1)=NaN;
tmp(tmp==-1)=NaN;
rghav(~isnan(rghav) & ~isnan(tmp)) = (rghav(~isnan(rghav) & ~isnan(tmp)) + tmp(~isnan(rghav) & ~isnan(tmp)))/2;
rghav(isnan(rghav) & ~isnan(tmp)) = tmp(isnan(rghav) & ~isnan(tmp));

sirfile = [sirfolder 'mysm_3125_V-' num2str(day) '.sir'];
[smav, head, descrip, iaopt]=loadsir(sirfile);
smav(smav==0)=NaN;

sirfile = [ancfolder 'surftemp_3125-' num2str(day) '.sir'];
[tempav, head, descrip, iaopt]=loadsir(sirfile);
sir2file = [ancfolder2 'surftemp_3125-' num2str(nday) '.sir'];
[tmp, head, descrip, iaopt]=loadsir(sir2file);
tempav(tempav==220)=NaN;
tmp(tmp==220)=NaN;
tempav(~isnan(tempav) & ~isnan(tmp)) = (tempav(~isnan(tempav) & ~isnan(tmp)) + tmp(~isnan(tempav) & ~isnan(tmp)))/2;
tempav(isnan(tempav) & ~isnan(tmp)) = tmp(isnan(tempav) & ~isnan(tmp));

sirfile = [ancfolder 'vop_3125-' num2str(day) '.sir'];
[vopav, head, descrip, iaopt]=loadsir(sirfile);
sir2file = [ancfolder2 'vop_3125-' num2str(nday) '.sir'];
[tmp, head, descrip, iaopt]=loadsir(sir2file);
vopav(vopav==-1)=NaN;
tmp(tmp==-1)=NaN;
vopav(~isnan(vopav) & ~isnan(tmp)) = (vopav(~isnan(vopav) & ~isnan(tmp)) + tmp(~isnan(vopav) & ~isnan(tmp)))/2;
vopav(isnan(vopav) & ~isnan(tmp)) = tmp(isnan(vopav) & ~isnan(tmp));

%% Make SM Map with Neural Network
nnsm=nan(size(smav));
for x=1:11104
    for y=1:4320
        validav=(~isnan(smav(y,x)) & ~isnan(tbav(y,x)) & ~isnan(incav(y,x)) & ~isnan(tempav(y,x)) & ~isnan(vopav(y,x)) & ~isnan(albav(y,x)) & ~isnan(rghav(y,x)) & (qualav(y,x)==0 | qualav(y,x)==8));

        if(validav)
            nnin=[tbam(y,x), incam(y,x), tempam(y,x), vopam(y,x), albam(y,x), rgham(y,x)];
            nnsm(y,x)=smnet5(nnin');
        end
    end
end

nnsm(nnsm>0.5)=0.5;
nnsm(nnsm<0.05)=0.05;

%% Compare the NN Winds to the Current Model
fprintf("Creating comparison histograms.\n");
smdif1=nnsm-smav;
valids=find(~isnan(smdif1));
rmse=sqrt(sum(smdif1(valids).^2)/length(valids));

figure
imagesc(nnsm);
colorbar;
title('NN SM Image');
    
figure;
imagesc(smdif1,[0 1]);
title(['NN SM minus My 3.125 km SM:  RMSE=' num2str(rmse,4)]);
colorbar

if showplottb
    figure
    imagesc(smav);
    colorbar;
    title('SM Image');
    
    figure
    imagesc(tempav);
    colorbar;
    title('Temperature Image');
    
    figure
    imagesc(tbaav);
    colorbar;
    title('Brightness Temperature Image - from SIR file');
    
    figure
    imagesc(vwcav);
    colorbar;
    title('Vegetation Water Content Image');
    
    figure
    imagesc(albav);
    colorbar;
    title('Albedo Image');
    
    figure
    imagesc(incav);
    colorbar;
    title('Boresight Incidence Image');
    
    figure
    imagesc(rghav);
    colorbar;
    title('Soil Roughness Image');
    
    figure
    imagesc(vopav);
    colorbar;
    title('Vegetation Opacity Image');
    
    figure
    imagesc(qualav);
    colorbar;
    title('Retrieval Quality Image')
end

%% Optionally write data to sir
if 0
    fprintf('Writing map to SIR file\n');
    sirfile = '/auto/temp/brown/smData/2015/153/ancillarysir/alb_3125-153.sir';
    [~, head, descrip, iaopt]=loadsir(sirfile); %This is just to get the head, descrip,iaopt

    moisture_map(isnan(moisture_map)) = -1;
    head(10)=-1; %ioff
    head(11)=10000; %iscale
    head(49)=-1; %nodata
    head(50)=0.05; %vmin
    head(51)=0.5; %vmax
    writesir(['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/nnsm_3125_V-' num2str(day) '.sir'],moisture_map,head,0,descrip,iaopt);
end

disp('Done');