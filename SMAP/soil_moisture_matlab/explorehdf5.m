clear;
type='T';
addpath borders
addpath __MACOSX

% mapname='filt_ciaworld180';
mapname='filt_northamer';
mappath='/auto/archive/cia/';   % full path to file
% sir_file=sprintf('/home/brown/soil_moisture/work/SMhb-a-E2N15-153-154.sir');
sir_file=sprintf('/home/brown/Downloads/QS_XbhaN3C1999200.19992541353');
% sir_file=sprintf('/auto/temp/brown/current_sir_practice/output/010/msfa-a-E2S17-010-011.sir');
% sir_file=sprintf('/home/brown/Downloads/msfa-a-NAm09-001-005.sir');

[newsir, head1, descrip1, iaopt1]=loadsir(sir_file);
outtry=NaN(size(newsir));

map_types=[1 2 3 4 5 6 7 8 9 10];  % which map elements to plot

if type=='T'
    num=fopen('all_TBh5.lis');
    filecell=textscan(num,'%s');
    filelist=filecell{1};
end

for filechoice=1:29

    if type=='A'
        switch filechoice
            case 1
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01820_D_20150605T003018_R13080_001.h5');
            case 2
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01821_D_20150605T020843_R13080_001.h5');
            case 3
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01822_D_20150605T034713_R13080_001.h5');
            case 4
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01823_D_20150605T052543_R13080_001.h5');
            case 5
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01824_D_20150605T070408_R13080_001.h5');
            case 6
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01825_D_20150605T084238_R13080_001.h5');
            case 7
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01826_D_20150605T102104_R13080_001.h5');
            case 8
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01827_D_20150605T115933_R13080_001.h5');
            case 9
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01828_D_20150605T133759_R13080_001.h5');
            case 10
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01829_D_20150605T151628_R13080_001.h5');
            case 11
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01830_D_20150605T165454_R13080_001.h5');
            case 12
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01831_D_20150605T183324_R13080_001.h5');
            case 13
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01832_D_20150605T201149_R13080_001.h5');
            case 14
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01833_D_20150605T215019_R13080_001.h5');
            case 15
                FILE_NAME=sprintf('/home/brown/soil_moisture/hdf5/SMAP_L2_SM_A_01834_D_20150605T232844_R13080_001.h5');
        end
            
        
        % Copyright (C) 2015 The HDF Group
        %   All Rights Reserved 
        %
        %  This example code illustrates how to access and visualize SMAP L2 file
        % in MATLAB. 
        %
        %  If you have any questions, suggestions, comments on this example, please 
        % use the HDF-EOS Forum (http://hdfeos.org/forums). 
        % 
        %  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
        % product that is not listed in the HDF-EOS Comprehensive Examples page 
        % (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
        % or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
        %                                   
        % Usage:save this script and run (without .m at the end)
        %                                   
        %
        % $matlab -nosplash -nodesktop -r SMAP_L2_SM_P_03721_D_20151013T000528_R11920_001_h5
        %
        % Tested under: MATLAB R2015a
        % Last updated: 2015-12-17

        % Open the HDF5 File.
        file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

        % Open the dataset.
        DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data/soil_moisture';
        data_id = H5D.open (file_id, DATAFIELD_NAME);

        Lat_NAME='Soil_Moisture_Retrieval_Data/latitude';
        lat_id=H5D.open(file_id, Lat_NAME);

        Lon_NAME='Soil_Moisture_Retrieval_Data/longitude';
        lon_id=H5D.open(file_id, Lon_NAME);

        % Read the dataset.
        data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

        lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

        lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


        % Read the fill value.
        ATTRIBUTE = '_FillValue';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

        % Read the units.
        ATTRIBUTE = 'units';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        units = H5A.read(attr_id, 'H5ML_DEFAULT');

        % Read the valid_max.
        ATTRIBUTE = 'valid_max';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        valid_max = H5A.read(attr_id, 'H5ML_DEFAULT');

        % Read the valid_min.
        ATTRIBUTE = 'valid_min';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        valid_min = H5A.read(attr_id, 'H5ML_DEFAULT');

        % Read title attribute.
        ATTRIBUTE = 'long_name';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        long_name=H5A.read (attr_id, 'H5ML_DEFAULT');

        % Close and release resources.
        H5A.close (attr_id)
        H5D.close (data_id);
        H5F.close (file_id);
        
    elseif type=='T'
        FILE_NAME=filelist{filechoice};
        % Copyright (C) 2015 The HDF Group
        %   All Rights Reserved 
        %
        %  This example code illustrates how to access and visualize SMAP L1C file
        % in MATLAB. 
        %
        %  If you have any questions, suggestions, comments on this example, please 
        % use the HDF-EOS Forum (http://hdfeos.org/forums). 
        % 
        %  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
        % product that is not listed in the HDF-EOS Comprehensive Examples page 
        % (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
        % or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
        %                                   
        % Usage:save this script and run (without .m at the end)
        %                                   
        %
        % $matlab -nosplash -nodesktop -r SMAP_L1C_TB_03721_D_20151013T000528_R11920_001_h5
        %
        % Tested under: MATLAB R2015a
        % Last updated: 2015-12-17

        % Open the HDF5 File.
        file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

        % Open the dataset.
        DATAFIELD_NAME = 'Global_Projection/cell_tb_h_fore';
        data_id = H5D.open(file_id, DATAFIELD_NAME);

        Lat_NAME='Global_Projection/cell_lat';
        lat_id=H5D.open(file_id, Lat_NAME);

        Lon_NAME='Global_Projection/cell_lon';
        lon_id=H5D.open(file_id, Lon_NAME);

        % Read the dataset.
        data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

        lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

        lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


        % Read the fill value.
        ATTRIBUTE = '_FillValue';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

        % Read the units.
        ATTRIBUTE = 'units';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        units = H5A.read(attr_id, 'H5ML_DEFAULT');

        % Read the valid_max.
        ATTRIBUTE = 'valid_max';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        valid_max = H5A.read(attr_id, 'H5ML_DEFAULT');

        % Read the valid_min.
        ATTRIBUTE = 'valid_min';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        valid_min = H5A.read(attr_id, 'H5ML_DEFAULT');

        % Read title attribute.
        ATTRIBUTE = 'long_name';
        attr_id = H5A.open_name (data_id, ATTRIBUTE);
        long_name=H5A.read (attr_id, 'H5ML_DEFAULT');

        % Close and release resources.
        H5A.close (attr_id)
        H5D.close (data_id);
        H5F.close (file_id);

%         % Replace the fill value with NaN.
%         data(data==fillvalue) = NaN;
% 
%         % Replace the invalid range values with NaN.
%         data(data < double(valid_min)) = NaN;
%         data(data > double(valid_max)) = NaN;
    end


    % Replace the fill value with NaN.
    data(data==double(fillvalue)) = NaN;

    % Replace the invalid range values with NaN.
    data(data < double(valid_min)) = NaN;
    data(data > double(valid_max)) = NaN;

    % f=figure('Name', FILE_NAME, 'visible', 'off');
    % 
    % % Create the plot.
    % axesm('MapProjection','eqdcylin',...
    %       'Frame','on','Grid','on', ...
    %       'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
    %       'south')
    % 
    % % Plot the data.
    % cm = colormap('Jet');
    % min_data=min(min(data));
    % max_data=max(max(data));
    % caxis([min_data max_data]);
    % k = size(data);
    % [count, n] = size(cm);
    % datap=data(~isnan(data));
    % latp=lat(~isnan(data));
    % lonp=lon(~isnan(data));
    % scatterm(latp, lonp, 1, datap);    
    % coast = load('coast.mat');
    % plotm(coast.lat,coast.long,'k');
    % tightmap;
    %

    hitlon=lon(~isnan(data));
    hitlat=lat(~isnan(data));
    hitdata=data(~isnan(data));
%     maxlat=max(hitlat);
%     minlat=min(hitlat);
%     maxlon=max(hitlon);
%     minlon=min(hitlon);

%     [rowlim,collim] = size(outtry);
%     for ind = 1:length(data)
%         [col,row]=latlon2pix(lon(ind),lat(ind),head1);
%         if (row >= .5 && col >= .5 && row <= rowlim  && col <= collim)
%             if isnan(outtry(round(row),round(col)))    % Currently just takes the first encountered value for a pixel
%                 outtry(round(row),round(col))=data(ind);
%             end
%         end
%     end
    scatter(hitlon,hitlat,ones(size(hitlat)),hitdata,'filled');
    hold on
    fprintf('Finished with hdf %d\n',filechoice);
end

hold off
% figure
% imagesc(outtry);
title('Try for data map');
colorbar
%%
hold on;

% load map file
str=sprintf('load %s%s.dat;',mappath,mapname);
eval(str);  % load map file
str=sprintf('mapinfo=%s;',mapname);
eval(str);
str=sprintf('clear %s;',mapname);
eval(str);

% select information to plot

for imap=1:length(map_types)

  map_type=map_types(imap);
  ind=find(mapinfo(:,4)==map_type);
  if ~isempty(ind)  
    % copy desired data into convenient arrays
    lons=mapinfo(ind,2);
    lats=mapinfo(ind,1);
    pen=mapinfo(ind,3);
    
    if (lons > 360)
      lons=lons-360;
    end

    % plot map info data onto image
    ind(length(ind)+1)=3;
    ind=find(pen==3);
    n=length(ind);
  
    for k=1:n-1
      lon2=lons(ind(k):ind(k+1)-1);
      lat2=lats(ind(k):ind(k+1)-1);
      [x, y] = latlon2pix1(lon2,lat2,head1);
      l=length(x);
      if l > 1
	% this loop is for plotting into the image
%	for i=1:l-1
	  % lineout is a mex function in the tools directory
	  % it returns a list of pixel addresses which are covered with line
%	  p=lineout(x(i)-1,y(i)-1,x(i+1)-1,y(i+1)-1,nsx,nsy);
%	  A(p)=+10;  % draw line into image array by setting to high value
%	end
	% plot vectors on top of image
        plot(x,y,'k');
      end
    end
  end  
end

axis image
axis off

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction.
units1 = sprintf('%s', char(units));

% long_name is pretty long so use a small font.
% set (get(h, 'title'), 'string', units1, 'FontSize', 8, ...
%                    'Interpreter', 'None', ...
%                    'FontWeight','bold');
  
% name = sprintf('%s', long_name);

% Unit is also long so we use a small font.
% title('Map Try');
% title({FILE_NAME; name}, ... 
%       'Interpreter', 'None', 'FontSize', 10,'FontWeight','bold');
% saveas(f, [FILE_NAME '.m.png']);
% exit;

rmpath borders
rmpath __MACOSX