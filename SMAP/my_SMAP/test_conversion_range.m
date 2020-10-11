year = 2016;
day = 276;
res = 1;
end_day = 10;

if ismac
    PATH = '/Users/low/CLionProjects/SMAP/sir/setup_files/SMvb*.setup';
elseif isunix
    addpath(genpath('/home/spencer/Documents/MATLAB'));
    addpath(genpath('/media/spencer/Scratch_Disk/SMAP/sir/setup_files'));
    PATH = '/media/spencer/Scratch_Disk/SMAP/sir/setup_files/SMvb*.setup';
end


for i = 1:end_day
    [tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day+i-1,0,res);
    figure(1)
    imagesc(tbav);
    
    tic
    [moisture_map] = tb2sm_parallel(tbav, year, day + i - 1, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav, 0:.001:1);
    toc
    
%     tic
    [moisture_map2] = tb2sm(tbav, year, day + i - 1, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
% %     toc
%     
    moisture_map(isnan(moisture_map)) = 0;
    moisture_map2(isnan(moisture_map2)) = 0;
    
    diff = moisture_map - moisture_map2;
    
    figure(2)
    imagesc(moisture_map);

    [tb_map] = sm2tb_v2(moisture_map, year, day + i - 1, res, tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
    
    [tb_map2] = sm2tb(moisture_map, year, day + i - 1, res, tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
    
    diff2 = tb_map - tb_map2;

    figure(3)
    imagesc(tb_map);

    
    [moisture_map] = tb2sm_parallel(tb_map, year, day + i - 1, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav, 0:.001:1);

    [moisture_map2] = tb2sm(tb_map2, year, day + i - 1, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);

    
    [tb_map] = sm2tb_v2(moisture_map, year, day + i - 1, res, tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
    
    [tb_map2] = sm2tb(moisture_map2, year, day + i - 1, res, tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
    
    
    
    diff2 = tb_map - tb_map2;

    
    
    sm(i).mois = moisture_map;
    tb2(i).tb = tb_map;
    
end

moisture = zeros(size(sm(1).mois,1),size(sm(1).mois,2),length(sm));
tb_conv = zeros(size(sm(1).mois,1),size(sm(1).mois,2),length(sm));
for i = 1:end_day
    moisture(:,:,i) = sm(i).mois;
    tb_conv(:,:,i) = tb2(i).tb;
end
