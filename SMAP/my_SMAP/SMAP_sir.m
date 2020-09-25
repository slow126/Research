function [a_val] = SMAP_sir(setup_in, outpath, storage_option, year, day)
VERSION = 1.3;
CREATE_NON = 1;
anodata_A=100.0;
anodata_C=-1.0;
anodata_I=-1.0;
anodata_Ia=0.0;
anodata_P=-1.0;
anodata_V=-1.0;
anodata_E=-15.0;

fprintf("BYU SSM/I meta SIR/SIRF program: C version %f\n",VERSION);
preloaded = 0
save_workspace = 0
res = 1;
sm_space = 0

if (~exist('setup_in', 'var') | ~exist('outpath', 'var') | ~exist('storage_option', 'var'))
    fprintf("\nusage: %s setup_in outpath storage_option\n\n",setup_in);
    fprintf(" input parameters:\n");
    fprintf("   setup_in        = input setup file\n");
    fprintf("   outpath         = output path\n");
    fprintf("   storage_option  = (0=mem only [def], 1=file only, 2=mem then file\n");
    return
end

a_init = 150.0;
meas_offset = 0;
sensor_in = "";
MAX_FILL = 1000;
HASAZANG = 0;
HS = 20;
AVE_INIT = 1;
NOISY = false;

nhead = 0;
file_in = setup_in;
file_id = fopen(file_in, 'r');

ang = 0.0; %Temporary. Simulated SIR doesn't seem to have this info.
REL_EOF = 2;
MAXFILES = 2;
nspace = 0;
nfiles = 0;
cur_file = 0;

file_in = setup_in;
file_id = fopen(file_in, 'r');

fseek(file_id, 0, 'eof');
nls(nfiles + 1)=ftell(file_id);
%     nls = ftell(file_id);

frewind(file_id);

% Read in header
dumb = fread(file_id, 1, 'int32');
irecords = fread(file_id, 1, 'int32');
dumb = fread(file_id, 1, 'int32');
dumb = fread(file_id, 1, 'int32');

nsx = fread(file_id, 1, 'int32');
nsy = fread(file_id, 1, 'int32');
ascale = fread(file_id, 1, 'float32');
bscale = fread(file_id, 1, 'float32');
a0 = fread(file_id, 1, 'float32');
b0 = fread(file_id, 1, 'float32');
xdeg = fread(file_id, 1, 'float32');
ydeg = fread(file_id, 1, 'float32');

dumb = fread(file_id, 1, 'int32');
dumb = fread(file_id, 1, 'int32');

isday = fread(file_id, 1, 'int32');
ieday = fread(file_id, 1, 'int32');
ismin = fread(file_id, 1, 'int32');
iemin = fread(file_id, 1, 'int32');
iyear = fread(file_id, 1, 'int32');
iregion = fread(file_id, 1, 'int32');
iopt = fread(file_id, 1, 'int32');
ipol =  fread(file_id, 1, 'int32');
latl = fread(file_id, 1, 'float32');
lonl = fread(file_id, 1, 'float32');
lath = fread(file_id, 1, 'float32');
lonh = fread(file_id, 1, 'float32');
regname = fread(file_id, 10, 'char');
regname = char(regname);
dumb = fread(file_id, 1, 'int32');
dumb = fread(file_id, 1, 'int32');
nsx2 = fread(file_id, 1, 'int32');
nsy2 = fread(file_id, 1, 'int32');
non_size_x = fread(file_id, 1, 'int32');
non_size_y = fread(file_id, 1, 'int32');
ascale2 = fread(file_id, 1, 'float32');
bscale2 = fread(file_id, 1, 'float32');
a02 = fread(file_id, 1, 'float32');
b02 = fread(file_id, 1, 'float32');
xdeg2 = fread(file_id, 1, 'float32');
ydeg2 = fread(file_id, 1, 'float32');

dumb = fread(file_id, 1, 'int32');

fprintf("\nInput file header info: '%s'\n",file_in);
fprintf("  Year, day range: %d %d - %d\n",iyear,isday,ieday);
fprintf("  Image size: %d x %d = %d   Projection: %d\n",nsx,nsy,nsx*nsy,iopt);
fprintf("  Origin: %f,%f  Span: %f,%f\n",a0,b0,xdeg,ydeg);
fprintf("  Scales: %f,%f  Pol: %d  Reg: %d\n",ascale,bscale,ipol,iregion);
fprintf("  Region: '%s'   Records: %d\n",regname,irecords);
fprintf("  Corners: LL %f,%f UR %f,%f\n",latl,lonl,lath,lonh);
fprintf("  Grid size: %d x %d = %d  Scales %d %d\n",nsx2,nsy2,nsx2*nsy2,non_size_x,non_size_y);
fprintf("  Grid Origin: %f,%f  Grid Span: %f,%f\n",a02,b02,xdeg2,ydeg2);
fprintf("  Grid Scales: %f,%f\n",ascale2,bscale2);
fprintf("\n");

if ipol > 2
    meas_offset = 200.0;
    fprintf("Special polarization ipol=%d;  meas_offset reset to %f\n",ipol,meas_offset);
end

if meas_offset ~= 0
    anodata_A=-300.0;
end
fprintf("Non-zero meas_offset %f; A_nodata_A reset to %f\n",meas_offset,anodata_A);

end_flag = 1;
if ~preloaded
    while(end_flag)
        dumb = fread(file_id, 1, 'int32');
        line = fread(file_id, 100, 'char');
        line = char(line);
        line = strcat(line(:)');
        dumb = fread(file_id, 1, 'int32');
        if(contains(line, "A_initialization"))
            x = strfind(line, "=");
            a_init = str2double(line(x + 1));
            fprintf("A_initialization of %f\n",a_init);
        end
        
        if(contains(line, "A_offset_value"))
            x = strfind(line, "=");
            meas_offset = str2double(line(x + 1));
            fprintf("A_offset of %f\n",meas_offset);
            if (meas_offset ~= 0.0)
                anodata_A=-300.0;
            end
            printf("A_nodata_A reset to %f\n",anodata_A);
        end
        
        if(contains(line, "Beam_code"))
            x = strfind(line, "=");
            ibeam = str2double(line(x + 1));
            fprintf("Beam code %d\n",ibeam);
        end
        
        if(contains(line, "Max_iterations"))
            x = strfind(line, "=");
            nits = str2double(line(x + 1));
            fprintf("Max iterations of %d\n",nits);
        end
        
        if (contains(line,"Max_Fill"))
            x = strfind(line,'=');
            MAXFILL=str2double(line(x + 1));
            fprintf("Max fill %d\n",MAXFILL);
        end
        
        if (contains(line,"Response_Multiplier"))
            x = strfind(line,'=');
        end
        
        if (contains(line,"Sensor"))
            x = strfind(line,'=');
            sensor_in = line(x+1:length(line));
            fprintf("Sensor '%s'\n",sensor_in);
        end
        
        if (contains(line,"Median_flag"))
            x = strfind(line, '=');
            x = x + 1;
            temp_sub = line(x:length(line));
            if (contains(temp_sub,"T")|| contains(temp_sub,"t"))
                median_flag=1;
            end
            if (contains(temp_sub,"F") || contains(temp_sub,"f"))
                median_flag=0;
            end
            fprintf("Median flag: %d\n",median_flag);
        end
        
        if (contains(line,"Has_Azimuth_Angle"))
            x = strfind(line,'=') + 1;
            temp_sub = line(x:length(line));
            if (contains(temp_sub,"T") || contains(temp_sub,"t"))
                HASAZANG=1;
                HS = HS + 4;
            end
            if (contains(temp_sub,"F") || contains(temp_sub,"f"))
                HASAZANG=0;
            end
            fprintf("Has azimuth angle: %d\n",HASAZANG);
        end
        
        if (contains(line,"SIRF_A_file"))
            x = strfind(line,'=');
            a_name = line(x+1:length(line));
        end
        
        if (contains(line,"SIRF_C_file"))
            x = strfind(line,'=');
            c_name = line(x+1:length(line));
        end
        
        if (contains(line,"SIRF_I_file"))
            x = strfind(line,'=');
            i_name = line(x+1:length(line));
        end
        
        if (contains(line,"SIRF_J_file"))
            x = strfind(line,'=');
            j_name = line(x+1:length(line));
        end
        
        if (contains(line,"SIRF_E_file"))
            x = strfind(line,'=');
            e_name = line(x+1:length(line));
        end
        
        if (contains(line,"SIRF_V_file"))
            x = strfind(line,'=');
            v_name = line(x+1:length(line));
        end
        
        if (contains(line,"SIRF_P_file"))
            x = strfind(line,'=');
            p_name = line(x+1:length(line));
        end
        
        if (contains(line,"AVE_A_file"))
            x = strfind(line,'=');
            a_name_ave = line(x+1:length(line));
        end
        
        if (contains(line,"NON_A_file"))
            x = strfind(line,'=');
            non_aname = line(x+1:length(line));
        end
        
        if (contains(line,"NON_V_file"))
            x = strfind(line,'=');
            non_vname = line(x+1:length(line));
        end
        
        if (contains(line,"GRD_A_file"))
            x = strfind(line,'=');
            grd_aname = line(x+1:length(line));
        end
        
        if (contains(line,"GRD_V_file"))
            x = strfind(line,'=');
            grd_vname = line(x+1:length(line));
        end
        
        if (contains(line,"GRD_I_file"))
            x = strfind(line,'=');
            grd_iname = line(x+1:length(line));
        end
        if (contains(line,"GRD_J_file"))
            x = strfind(line,'=');
            grd_jname = line(x+1:length(line));
        end
        if (contains(line,"GRD_P_file"))
            x = strfind(line,'=');
            grd_pname = line(x+1:length(line));
        end
        if (contains(line,"GRD_C_file"))
            x = strfind(line,'=');
            grd_cname = line(x+1:length(line));
        end
        if (contains(line,"Info_file"))
            x = strfind(line,'=');
            info_name = line(x+1:length(line));
        end
        
        if(contains(line, "End_header"))
            end_flag = 0;
        end
        
    end
    
    
    fprintf("\n");
    fprintf("A output file: '%s'\n",a_name);
    fprintf("I output file: '%s'\n",i_name);
    fprintf("J output file: '%s'\n",j_name);
    fprintf("C output file: '%s'\n",c_name);
    fprintf("P output file: '%s'\n",p_name);
    fprintf("E output file: '%s'\n",e_name);
    fprintf("SIR V output file: '%s'\n",v_name);
    fprintf("AVE A output file: '%s'\n",a_name_ave);
    if (CREATE_NON)
        fprintf("NON A output file: '%s'\n",non_aname);
        fprintf("NON V output file: '%s'\n",non_vname);
        Nfiles_out=16;
    else
        Nfiles_out=14;
    end
    fprintf("GRD A output file: '%s'\n",grd_aname);
    fprintf("GRD V output file: '%s'\n",grd_vname);
    fprintf("GRD I output file: '%s'\n",grd_iname);
    fprintf("GRD J output file: '%s'\n",grd_jname);
    fprintf("GRD P output file: '%s'\n",grd_pname);
    fprintf("GRD C output file: '%s'\n",grd_cname);
    fprintf("Info file: '%s'\n",info_name);
    fprintf("\n");
    
    
    head_len(nfiles + 1) = 20 + nsx * nsy * 4 + 8;
    
    median_flag=0;
    
    "File Size: "
    nls(nfiles + 1)
    head_len(nfiles + 1)
    
    nspace = 0;
    for i = 1:nfiles+1
        nspace = nspace + nls(i);
    end
    nspace = nspace * 1.01;
    
    
    a_val = zeros(nsx * nsy, 1);
    b_val = zeros(nsx * nsy, 1);
    a_temp = zeros(nsx * nsy, 1);
    sxy = zeros(nsx * nsy, 1);
    sx = zeros(nsx * nsy, 1);
    sx2 = zeros(nsx * nsy, 1);
    sy = zeros(nsx * nsy, 1);
    tot = zeros(nsx * nsy, 1);
    
    nsize = nsx * nsy;
    
    nrec = 0;
    ncnt = 0;
    nbyte = 0;
    store = int8(zeros(nsx * nsy, 1));
    idx = 1;
    
    dumb = fread(file_id, 1, 'int');
    store_idx = 1;
    while (true)
        if (nbyte + HS < nspace)
            %         store(store_idx:store_idx + HS - 1)=fread(file_id, HS, 'int8');
            tbval_temp = fread(file_id, 1, 'float');
            if length(tbval_temp)<1, break; end;
            tbval(store_idx) = tbval_temp;
            ang(store_idx) = fread(file_id, 1, 'float');
            count(store_idx) = fread(file_id, 1, 'int');
            ktime(store_idx) = fread(file_id, 1, 'int');
            iadd(store_idx) = fread(file_id, 1, 'int32');
            
            if HASAZANG
                azang(store_idx) = fread(file_id, 1, 'float64');
            end
        end
        
        keep = 0;
        if tbval(store_idx) < 340 && tbval(store_idx) > 1
            nbyte = nbyte + HS;
            ncnt = ncnt + 1;
            keep = 1;
        end
        
        if nbyte + count(store_idx) * 4 < nspace
            dumb = fread(file_id, 1, 'int');
            pointer(store_idx).pt = fread(file_id, count(store_idx), 'int');
            dumb = fread(file_id, 1, 'int');
            if keep == 1
                nbyte=nbyte+count(store_idx)*4;
            end
        end
        
        if nbyte + count(store_idx) * 2 < nspace
            dumb = fread(file_id, 1, 'int');
            aresp1(store_idx).resp = fread(file_id, count(store_idx), 'int16');
            dumb = fread(file_id, 1, 'int');
            if keep == 1
                nbyte=nbyte+count(store_idx)*2;
            end
        end
        
        
        %     store_idx = store_idx + HS;
        nrec = nrec + 1;
        if keep == 1
            store_idx = store_idx + 1;
        end
        dumb = fread(file_id, 1, 'int');
    end
    
    fclose(file_id);
    if save_workspace == 1
        save('smap_work.mat','-v7.3');
%         save('pointer.mat', pointer);
%         save('aresp1.mat',aresp1);
    end
else
    load('/Users/low/Documents/MATLAB/SMAP/my_SMAP/smap_work.mat');
%     load('/Users/low/Documents/MATLAB/SMAP/my_SMAP/pointer.mat');
%     load('/Users/low/Documents/MATLAB/SMAP/my_SMAP/aresp1.mat');
end



"Begin SIR/SIRF processing. First Initialize Working Arrays."
a_val = ones(nsize, 1) .* a_init;
b_val = zeros(nsize, 1);
% a_temp = zeros(nsize, 1);
sx = zeros(nsize, 1);
sy = zeros(nsize, 1);
sxy = zeros(nsize, 1);
sx2 = zeros(nsize, 1);
% tot = zeros(nsize, 1);

old_amin = a_init;
old_amax = a_init;
a_temp = zeros(nsize,1);
tot = zeros(nsize,1);

nits = 100;
old_nsx = size(a_val,1);
old_nsy = size(a_val,2);
[tbav2, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
% tb2_avg = nanmean(nanmean(tbav2));
% a_val = a_val * tb2_avg;

% [a_val2, junk] = compute_ave(tbval',count,pointer,aresp1,a_val, 0);
% a_val2(a_val2 == inf) = a_init;

read_start_day = day;
read_end_day = read_start_day + 4; 
a_val = ncread(strcat('/home/spencer/Documents/MATLAB/Research/SMAP/images/SMvb-E2T16-', int2str(read_start_day),'-',int2str(read_end_day),'.lis_dump.nc'),'ave_image');
a_val = reshape(a_val, [nsx, nsy]);
a_val = reshape(a_val, [old_nsx, old_nsy]);

if sm_space == 1
        a_val = reshape(a_val, [nsx, nsy]);
        a_val = tb2sm(flipud(a_val'), year, day, 1, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
        a_val = flipud(a_val);
        a_val = reshape(a_val', [old_nsx, old_nsy]);
end

sm_start_itr = 5;

for its = 1:nits
    a_temp = zeros(nsize,1);
    tot = zeros(nsize,1);
    strcat("SIRF iteration: ", string(its))

    if its > sm_start_itr + 1
        a_val = reshape(a_val, [nsx, nsy]);
        a_val = sm2tb(flipud(a_val'), year, day, 1, tbav2, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
        a_val = flipud(a_val);
        a_val = reshape(a_val', [old_nsx, old_nsy]);
    end
    
    
    if sm_space == 1
       update_sm = reshape(tbval, [nsx, nsy]);
       update_sm = sm2tb(flipud(update_sm'),year, day, 1, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav); 
       update_sm = fliup(update_sm);
       update_sm = reshape(update_sm', [old_nsx, old_nsy]);
       [a_val, a_temp, tot, sx, sx2, total] = get_updates(update_sm', ang, count, pointer, aresp1, a_val, sx, sx2, a_temp, tot, nsx, nsy);
        a_val(a_temp > 0) = a_temp(a_temp>0);
    else
        [a_val, a_temp, tot, sx, sx2, total] = get_updates(tbval', ang, count, pointer, aresp1, a_val, sx, sx2, a_temp, tot, nsx, nsy);
        a_val(a_temp > 0) = a_temp(a_temp>0);
    end

    if its == 1
        a_val(a_val == anodata_A) = NaN;
    end
%     my_temp = reshape(a_val, [nsx, nsy]);
%     my_temp = flipud(my_temp');
%     figure(its+1)
%     imagesc(my_temp)
%     colorbar;
%     drawnow();
    
    if its > sm_start_itr
        a_val = reshape(a_val, [nsx, nsy]);
        a_val = tb2sm(flipud(a_val'), year, day, 1, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
        [err(its), mean_err(its)] = compute_sm_err(smav, a_val)
        a_val = flipud(a_val);
        a_val = reshape(a_val', [old_nsx, old_nsy]);
    end
    
    
    
%     my_temp = reshape(a_val, [nsx, nsy]);
%     my_temp = flipud(my_temp');
%     figure(nits+its+i)
%     imagesc(my_temp)
%     drawnow();
end


% a_val = reshape(a_val, [nsx, nsy]);
% a_val = tb2sm(flipud(a_val'), 2016, 275, 1);
% a_val = flipud(a_val);
% a_val = reshape(a_val', [old_nsx, old_nsy]);


temp2 = reshape(a_val, [nsx, nsy]);
figure(2)
imagesc(fliplr(temp2)')
% colormap(gray)
title('MATLAB Code SIRF OUTPUT')
save('a_val.mat','a_val')


% [image, head, descrip, iaopt]=loadsir('simA.sir');
%
% figure(4)
% imagesc(flip(image',2))
% colormap(gray)
% title('C Code SIRF OUTPUT')
%
% diff = temp2 - flip(image',2);
% figure(5)
% imagesc(diff)
% colorbar

% for i = 1:nsy
%     ancil(1:nsx, i) = i:nsx + i - 1;
% end
%
% figure(6)
% imagesc(temp2 + ancil)
% colormap(gray)
end











