function [ ncData ] = ncReader( filename )
%ncReader takes a netcdf4 file type supplied by the NSIDC, and reads all
%the attributes and variables and outputs in a 1x1 struct. 

ncINFO = ncinfo(filename);
scale = 0.01;

NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
% Open netcdf file for reading
ncfile = netcdf.open(filename, 'NOWRITE');

for i = 1:length(ncINFO.Attributes)
    ncData.(ncINFO.Attributes(i).Name) = ...
        netcdf.getAtt(ncfile,NC_GLOBAL,ncINFO.Attributes(i).Name);
    
end

for i = 1:length(ncINFO.Variables)
    if(strcmp(ncINFO.Variables(i).Name,'TB') || strcmp(ncINFO.Variables(i).Name,'Incidence_angle')...
            || strcmp(ncINFO.Variables(i).Name,'TB_std_dev'))
        ncData.(ncINFO.Variables(i).Name) = ...
            netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,ncINFO.Variables(i).Name)) * scale;
    else
        ncData.(ncINFO.Variables(i).Name) = ...
            netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,ncINFO.Variables(i).Name));
    end
end

