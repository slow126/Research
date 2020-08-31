% Creates the Neural Networks which are used in wind vector retrieval

days=[5,15,95,105,185,195,280,290];
year=2016;
res=3;
              
for dayidx=1:length(days)
    day=days(dayidx);
    [tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
    qualav=round(qualav);
    disp(['Loaded data for day ' num2str(day)]);
    
    %% Neural Network Data Formatting
    validmeas=find(~isnan(smav) & ~isnan(tbav) & ~isnan(incav) & ~isnan(tempav) & ~isnan(vopav) & ~isnan(albav) & ~isnan(clayf) & ~isnan(rghav) & (qualav==0 | qualav==8) & ~isnan(wfracav));
    
    
    flatsm=smav(validmeas);
    flatinc=incav(validmeas);
    flattb=tbav(validmeas);
    flatclay=clayf(validmeas);
    flattemp=tempav(validmeas);
    flatalb=albav(validmeas);
    flatvop=vopav(validmeas);
    flatrgh=rghav(validmeas);
    flatwfrac=wfracav(validmeas);
    
    nnins=[flattb, flatinc, flatclay, flattemp, flatvop, flatalb, flatrgh, flatwfrac];
    if(dayidx==1)
        finalins=nnins;
        finalouts=flatsm;
    else
        finalins=[finalins; nnins];
        finalouts=[finalouts; flatsm];
    end
end

%% Neural Network Train and Testing, then saved
backstyle='trainlm';
% smhlneurons5=5;
% smhlneurons5_5=[5 5];
% smhlneurons10=10;
% smhlneurons10_10=[10 10];
% smhlneurons15=15;
% smhlneurons15_15=[15 15];
smhlneurons15_15_15=[15 15 15];
smhlneurons20=20;
smhlneurons20_20=[20 20];
smhlneurons20_20_20=[20 20 20];
smhlneurons25=25;
smhlneurons25_25=[25 25];

% fprintf("Creating Speed Neural Net 1.\n");
% smnet5=feedforwardnet(smhlneurons5,backstyle);
% smnet5.trainParam.epochs=1000;
% [smnet5, TR1]=train(smnet5,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 2.\n");
% smnet5_5=feedforwardnet(smhlneurons5_5,backstyle);
% smnet5_5.trainParam.epochs=1000;
% [smnet5_5, TR2]=train(smnet5_5,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 3.\n");
% smnet10=feedforwardnet(smhlneurons10,backstyle);
% smnet10.trainParam.epochs=1000;
% [smnet10, TR3]=train(smnet10,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 4.\n");
% smnet10_10=feedforwardnet(smhlneurons10_10,backstyle);
% smnet10_10.trainParam.epochs=1000;
% [smnet10_10, TR4]=train(smnet10_10,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 5.\n");
% smnet15=feedforwardnet(smhlneurons15,backstyle);
% smnet15.trainParam.epochs=1000;
% [smnet15, TR5]=train(smnet15,finalins',finalouts');
% 
% fprintf("Creating Speed Neural Net 6.\n");
% smnet15_15=feedforwardnet(smhlneurons15_15,backstyle);
% smnet15_15.trainParam.epochs=1000;
% [smnet15_15, TR6]=train(smnet15_15,finalins',finalouts');

fprintf("Creating Speed Neural Net 7.\n");
smnet15_15_15=feedforwardnet(smhlneurons15_15_15,backstyle);
smnet15_15_15.trainParam.epochs=1000;
[smnet15_15_15, TR7]=train(smnet15_15_15,finalins',finalouts');

fprintf("Creating Speed Neural Net 8.\n");
smnet20=feedforwardnet(smhlneurons20,backstyle);
smnet20.trainParam.epochs=1000;
[smnet20, TR8]=train(smnet20,finalins',finalouts');

fprintf("Creating Speed Neural Net 9.\n");
smnet20_20=feedforwardnet(smhlneurons20_20,backstyle);
smnet20_20.trainParam.epochs=1000;
[smnet20_20, TR9]=train(smnet20_20,finalins',finalouts');

fprintf("Creating Speed Neural Net 10.\n");
smnet20_20_20=feedforwardnet(smhlneurons20_20_20,backstyle);
smnet20_20_20.trainParam.epochs=1000;
[smnet20_20_20, TR10]=train(smnet20_20_20,finalins',finalouts');

fprintf("Creating Speed Neural Net 11.\n");
smnet25=feedforwardnet(smhlneurons25,backstyle);
smnet25.trainParam.epochs=1000;
[smnet25, TR11]=train(smnet25,finalins',finalouts');

fprintf("Creating Speed Neural Net 12.\n");
smnet25_25=feedforwardnet(smhlneurons25_25,backstyle);
smnet25_25.trainParam.epochs=1000;
[smnet25_25, TR12]=train(smnet25_25,finalins',finalouts');


% save('smNetsSIR.mat','smnet5','smnet10','smnet15','smnet5_5','smnet10_10','smnet15_15');
save('smNetsSIR2.mat','smnet15_15_15','smnet20','smnet20_20','smnet20_20_20','smnet25','smnet25_25');
