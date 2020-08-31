%function nsid = read_NSID(inpfile)
%Function to read the .nc files from the NSID dataset
%Spencer Low


function nsid = read_NSID_cloud(inpfile,freq)

nsid = [];

%Check existance of file
if ~exist(inpfile,'file')
  error(['input file "',inpfile,'" does not exist']);
  return;
else
      NC_GLOBAL=netcdf.getConstant('NC_GLOBAL');
  
  % open netcdf file for reading
  ncfile=netcdf.open ( inpfile, 'NOWRITE');
  if ncfile < 1
    error(['netcdf open error ',num2str(ncfile),' for file "',inpfile,'"']);
    return;
  end
       
%Get Global Attributes
    %nsid.conventions = netcdf.getAtt(ncfile,NC_GLOBAL,'Conventions');
    nsid.name = inpfile;
    nsid.freq = freq;
    %nsid.title = netcdf.getAtt(ncfile,NC_GLOBAL,'title');
    %nsid.product_version = netcdf.getAtt(ncfile,NC_GLOBAL,'product_version');
    %nsid.software_version_id = netcdf.getAtt(ncfile,NC_GLOBAL,'software_version_id');
    %nsid.software_repository = netcdf.getAtt(ncfile,NC_GLOBAL,'software_repository');
    %nsid.history = netcdf.getAtt(ncfile,NC_GLOBAL,'history');
    %nsid.comment = netcdf.getAtt(ncfile,NC_GLOBAL,'comment');
    %nsid.source = netcdf.getAtt(ncfile,NC_GLOBAL,'source');
    %nsid.references = netcdf.getAtt(ncfile,NC_GLOBAL,'references');
    %nsid.metadata_link = netcdf.getAtt(ncfile,NC_GLOBAL,'metadata_link');
    %nsid.summary = netcdf.getAtt(ncfile,NC_GLOBAL,'summary');
    %nsid.institution = netcdf.getAtt(ncfile,NC_GLOBAL,'institution');
    %nsid.publisher_type = netcdf.getAtt(ncfile,NC_GLOBAL,'publisher_type');
    %nsid.publisher_url = netcdf.getAtt(ncfile,NC_GLOBAL,'publisher_url');
    %nsid.publisher_email = netcdf.getAtt(ncfile,NC_GLOBAL,'publisher_email');
    %nsid.program = netcdf.getAtt(ncfile,NC_GLOBAL,'program');
    %nsid.project = netcdf.getAtt(ncfile,NC_GLOBAL,'project');
    %nsid.standard_name_vocabulary = netcdf.getAtt(ncfile,NC_GLOBAL,'standard_name_vocabulary');
    %nsid.cdm_data_type = netcdf.getAtt(ncfile,NC_GLOBAL,'cdm_data_type');
    %nsid.keywords = netcdf.getAtt(ncfile,NC_GLOBAL,'keywords');
    %nsid.keywords_vocabulary = netcdf.getAtt(ncfile,NC_GLOBAL,'keywords_vocabulary');
    %nsid.source=netcdf.getAtt(ncfile,NC_GLOBAL,'source');
    %nsid.filename=netcdf.getAtt(ncfile,NC_GLOBAL,'id');
    nsid.startdate=netcdf.getAtt(ncfile,NC_GLOBAL,'time_coverage_start');
    nsid.enddate=netcdf.getAtt(ncfile,NC_GLOBAL,'time_coverage_end');
    nsid.created=netcdf.getAtt(ncfile,NC_GLOBAL,'date_created');
    %nsid.geospatial_lat_min=netcdf.getAtt(ncfile,NC_GLOBAL,'geospatial_lat_min');
    %nsid.geospatial_lat_max=netcdf.getAtt(ncfile,NC_GLOBAL,'geospatial_lat_max');
    %nsid.geospatial_lon_min=netcdf.getAtt(ncfile,NC_GLOBAL,'geospatial_lon_min');
    %nsid.geospatial_lon_max=netcdf.getAtt(ncfile,NC_GLOBAL,'geospatial_lon_min');
    
%Get Variables
    %nsid.time = netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,'time'));
    %nsid.y = netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,'y'));
    %nsid.x = netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,'x'));
    %nsid.crs = netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,'crs'));
    nsid.TB = double(netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,'TB')))*.01;
    %nsid.TB_num_samples = netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,'TB_num_samples'));
    %nsid.Incidence_angle = double(netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,'Incidence_angle')))*.01;
    nsid.TB_std_dev = double(netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,'TB_std_dev')))*.01;
    %nsid.TB_time = netcdf.getVar(ncfile,netcdf.inqVarID(ncfile,'TB_time'));
    
%Close the NC file
    netcdf.close(ncfile);
end
