plots = false;

% compare with BYU .sir EASE2grid parameters
% gndiopt=10; % EASE2-T
% gndind=2;
% gndisc=2;

% [gndmap_equatorial_radius_m, gndmap_eccentricity, ...
% gnde2, gndmap_reference_latitude, gndmap_reference_longitude, ...
% gndmap_second_reference_latitude, gndsin_phi1, gndcos_phi1, gndkz, ...
% gndmap_scale, gndbcols, gndbrows, gndr0, gnds0, gndepsilon] = ease2_map_info(gndiopt, gndisc, gndind);

if(~(exist('clayf','var')))
    % Load Station Information
    fid=fopen('/auto/data/smap/ancil/clay_M09_004.float32');
    clayf = fread(fid,[3856 1624],'float32');
    clayf=transpose(clayf);
else
    fprintf('Using already loaded values.\n\n');
end

clayf(clayf==-9999)=nan;

if(plots)
    figure
    imagesc(clayf);
    colorbar
end


