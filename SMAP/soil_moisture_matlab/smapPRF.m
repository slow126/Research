year=2016;
day=282;
res=1;

%AVerage a few days to reduce noise? - might smear island a bit?
%% Soil Moisture loading
if(res==1)
    fileam=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M03km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-SIR-JPL-v1.0.nc'];
    filepm=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M03km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-D-SIR-JPL-v1.0.nc'];
elseif(res==2)
    fileam=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M09km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-SIR-JPL-v1.0.nc'];
    filepm=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M09km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-D-SIR-JPL-v1.0.nc'];
elseif(res==3)
    fileam=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M36km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-A-GRD-JPL-v1.0.nc'];
    filepm=['/auto/temp/brown/smData/' num2str(year) '/' num2str(day) '/NSIDC-0738-EASE2_M36km-SMAP_LRM-' num2str(year) num2str(day,'%03d') '-1.4V-D-GRD-JPL-v1.0.nc'];
end

%Load AM/PM Data
tbam = ncread(fileam,'TB');
tbpm = ncread(filepm,'TB');
tbam(tbam < double(50)) = NaN;
tbam(tbam > double(350)) = NaN;
tbpm(tbpm < double(50)) = NaN;
tbpm(tbpm > double(350)) = NaN;
tbam=rot90(flip(tbam,1),3);
tbpm=rot90(flip(tbpm,1),3);


if(res==1)
%     [tbam, head, descrip, iaopt]=loadsir([sirfolder 'tb2_3km-' num2str(day) '.sir']);
%     tbam(tbam < 0 | tbam > 330)=NaN;
    
    %Pick out islands
    eastertb=tbam(3517:3577,2240:2300);
    rarotb=tbam(3290:3350,619:679);
    
    %Normalize Values
    eastertb=(eastertb-min(min(eastertb)))/(max(max(eastertb))-min(min(eastertb)));
    rarotb=(rarotb-min(min(rarotb)))/(max(max(rarotb))-min(min(rarotb)));

    %Mark the land pixels (approximated as a circle)
%     [xx yy]=meshgrid(-30:30,-30:30);
%     easterland=zeros(size(xx));
%     raroland=zeros(size(xx));
%     easterland((xx.^2+yy.^2)<=2.5^2)=1;
%     raroland((xx.^2+yy.^2)<=1^2)=1;
    
%     %Mark the land pixels (with fractions included
    [xx, yy]=meshgrid(-30:30,-30:30);
    easterland=zeros(size(xx));
    raroland=zeros(size(xx));
    easterland((abs(xx)<=2) & (abs(yy)<=2))=1;
    raroland(xx==0 & yy==0)=1;
    raroland(abs(xx)==1 & yy==0)=.9;
    raroland(xx==0 & abs(yy)==1)=.9;
    raroland(abs(xx)==1 & abs(yy)==1)=.4;
elseif(res==2)
%     [tbam, head, descrip, iaopt]=loadsir([sirfolder 'tb2-E2T-' num2str(day) '.sir']);
%     tbam(tbam < 0 | tbam > 330)=NaN;
    
    %Pick out islands
    eastertb=tbam(1171:1195,744:768);
    rarotb=tbam(1095:1119,204:228);
    
    %Normalize Values
    eastertb=(eastertb-min(min(eastertb)))/(max(max(eastertb))-min(min(eastertb)));
    rarotb=(rarotb-min(min(rarotb)))/(max(max(rarotb))-min(min(rarotb)));
    
    %Mark the land pixels (approximated as a circle)
    [xx yy]=meshgrid(-12:12,-12:12);
    easterland=zeros(size(xx));
    raroland=zeros(size(xx));
    easterland((xx.^2+yy.^2)<1^2)=1;
    raroland((xx.^2+yy.^2)<.5^2)=1;
elseif(res==3)
    [tbam, head, descrip, iaopt]=loadsir([sirfolder 'tb2_36km-' num2str(day) '.sir']);
    tbam(tbam < 0 | tbam > 330)=NaN;
    
    eastertb=tbam(:,:);
end

easterprf=ifftshift(ifft2(fftshift(fft2(eastertb))./fftshift(fft2(easterland))));
raroprf=ifftshift(ifft2(fftshift(fft2(rarotb))./fftshift(fft2(raroland))));
% easterprf=ifft2(fft2(eastertb)./fft2(easterland));
% raroprf=ifft2(fft2(rarotb)./fft2(raroland));
% 
% easterprf(abs(easterprf)<.5)=0;
% raroprf(abs(raroprf)<.5)=0;
%% Plot Figures

% myfigure(1)
% imagesc(tbam,[115 135]);
% % colormap jet(128);
% colorbar;
% title('Brightness Temperature');
% 
% myfigure(2)
% imagesc(tbpm,[115 135]);
% % colormap jet(128);
% colorbar;
% title('Brightness Temperature');

% myfigure(2)
% imagesc(eastertb);
% % colormap jet(128);
% colorbar;
% title('Brightness Temperature Over Easter Island');

myfigure(3)
imagesc(rarotb);
% colormap jet(128);
colorbar;
title('Brightness Temperature Over Rarotonga');

% myfigure(4)
% imagesc(easterland);
% % colormap jet(128);
% colorbar;
% title('Easter Island Land');

myfigure(5)
imagesc(raroland);
% colormap jet(128);
colorbar;
title('Rarotonga Land');

% myfigure(6)
% imagesc(abs(easterprf));
% % colormap jet(128);
% colorbar;
% title('PRF Magnitude from Easter Island');

myfigure(7)
imagesc(abs(raroprf));
% colormap jet(128);
colorbar;
title('PRF Magnitude from Rarotonga');

% myfigure(8)
% imagesc(angle(easterprf));
% % colormap jet(128);
% colorbar;
% title('PRF Phase from Easter Island');

% myfigure(9)
% imagesc(angle(raroprf));
% % colormap jet(128);
% colorbar;
% title('PRF Phase from Rarotonga');

myfigure(10)
fftdb=20*log(abs(fftshift(fft2(abs(raroprf)-mean(mean(abs(raroprf))))))+1); %No fft shift??
imagesc(fftdb);
% colormap jet(128);
colorbar;
title('FFT of Rarotonga');
if(res==1)
    xticklabels = (1/(30*6)*(-30:5:30)).^-1;
    xticks = linspace(1, size(fftdb, 2), numel(xticklabels));
    set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
    yticklabels = (1/(30*6)*(-30:5:30)).^-1;
    yticks = linspace(1, size(fftdb, 1), numel(yticklabels));
    set(gca, 'YTick', yticks, 'YTickLabel', flipud(yticklabels(:)))
elseif(res==2)
    xticklabels = (1/(12*18)*(-12:2:12)).^-1;
    xticks = linspace(1, size(fftdb, 2), numel(xticklabels));
    set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
    yticklabels = (1/(12*18)*(-12:2:12)).^-1;
    yticks = linspace(1, size(fftdb, 1), numel(yticklabels));
    set(gca, 'YTick', yticks, 'YTickLabel', flipud(yticklabels(:)))
end
xlabel('Information at x km resolution')
ylabel('Information at y km resolution')

