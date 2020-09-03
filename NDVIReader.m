function [ NDVIData ] = NDVIReader( filename,printOptionFlag,desiredDataset )
% SMAPReader( str filename, bool printOptionFlag, int desiredDataset ) 
% is a function that reads SMAP L3 datasets. Input a string for the 
% filename and a bool for printOptionFlag.
%
% printOptionFlag = false : All the available datasets will be read into
% smapData.
% printOptionFlag = true : All available datasets will be printed to
% terminal and the user will be prompted to select a dataset. 
%
% desiredDataset can be entered to automatically grab the a predetermined
% dataset. This is the number of the dataset that is desired. It is indexed
% from 1. 0 is used if the there is no predetermined, desired dataset.
% 
% If you want all the data use the following inputs:
% NDVIReader(filename, false, 0)

NDVIInfo = ncinfo( filename );
ncfile = netcdf.open(filename, 'NOWRITE');
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
    for i = 1:length(NDVIInfo.Attributes)
        NDVIData.(NDVIInfo.Attributes(i).Name) = ...
            netcdf.getAtt(ncfile,NC_GLOBAL,NDVIInfo.Attributes(i).Name);
    end
    
    if(~printOptionFlag && (desiredDataset == 0))
        for i=1:length(NDVIInfo.Variables)
            NDVIData.(NDVIInfo.Variables(i).Name) = ...
                netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,NDVIInfo.Variables(i).Name));

        end
    elseif(printOptionFlag && (desiredDataset == 0))
        disp('Select Option: ')
        for i=1:length(NDVIInfo.Variables)          
            disp(strcat(num2str(i),'. ',NDVIInfo.Variables(i).Name))            
        end
        prompt = 'Select Option: ';
        option = input(prompt);
        
        NDVIData.(NDVIInfo.Variables(option).Name) = ...
            netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,NDVIInfo.Variables(option).Name));
    elseif (printOptionFlag && (desiredDataset > 0))
        disp('Options: ')
       for i=1:length(NDVIInfo.Variables)          
            disp(strcat(num2str(i),'. ',NDVIInfo.Variables(i).Name))    
        end
       NDVIData.(NDVIInfo.Variables(desiredDataset).Name) = ...
            netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,NDVIInfo.Variables(desiredDataset).Name));
    elseif (~printOptionFlag && (desiredDataset > 0))
        NDVIData.(NDVIInfo.Variables(desiredDataset).Name) = ...
            netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,NDVIInfo.Variables(desiredDataset).Name));
    end
end

