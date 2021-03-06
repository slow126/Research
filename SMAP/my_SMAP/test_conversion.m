year = 2016;
day = 276;
res = 1;

[tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
figure(1)
imagesc(tbav);

[moisture_map] = tb2sm(tbav, year, day, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
figure(2)
imagesc(moisture_map);

[tb_map] = sm2tb(moisture_map, year, day, res, tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
figure(3)
imagesc(tb_map);

[moisture_map] = tb2sm(tb_map, year, day, res, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
figure(2)
imagesc(moisture_map);

[tb_map] = sm2tb(moisture_map, year, day, res, tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav);
figure(3)
imagesc(tb_map);