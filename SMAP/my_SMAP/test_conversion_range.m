year = 2016;
day = 276;
res = 1;
end_day = 10;


for i = 1:end_day
    [tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day+i-1,0,res);
    figure(1)
    imagesc(tbav);

    [moisture_map] = tb2sm(tbav, year, day + i - 1, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
    figure(2)
    imagesc(moisture_map);

    [tb_map] = sm2tb(moisture_map, year, day + i - 1, res, tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
    figure(3)
    imagesc(tb_map);
% 
%     [moisture_map] = tb2sm(tb_map, year, day, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
%     figure(2)
%     imagesc(moisture_map);
    
    sm(i).mois = moisture_map;
    tb2(i).tb = tb_map;
    
end

moisture = zeros(size(sm(1).mois,1),size(sm(1).mois,2),length(sm));
tb_conv = zeros(size(sm(1).mois,1),size(sm(1).mois,2),length(sm));
for i = 1:end_day
    moisture(:,:,i) = sm(i).mois;
    tb_conv(:,:,i) = tb2(i).tb;
end
