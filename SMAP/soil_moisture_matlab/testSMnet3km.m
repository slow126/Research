%Creates a map of soil moisture from a TB image and proper ancillary data

clear;
year=2016;
% days=[2,25,100,112,190,210,278,296];
days=[2];
res=1; % 1=3km Sentinel/SMAP ancillary, 2=9km SMAP ancillary, 3=36km SMAP ancillary
whichones=1; % 1:do ones 1-6, 2: do ones 7-12

mapplot=1;      % Plot the resultant soil moisture plots
ancilplot=0;    % Plot some of the ancillary data
compplot=0;     % Plot error vs. different variables
wfraccorrect=0; % Correct for water body fractions - for now this means ignoring pixels with any water

maxsm=0.6;
minsm=0.02;

if(whichones==1)
    load('smNetsSIR.mat');
    rmse1=zeros(size(days));
    rmse2=zeros(size(days));
    rmse3=zeros(size(days));
    rmse4=zeros(size(days));
    rmse5=zeros(size(days));
    rmse6=zeros(size(days));
    totalsumsq1=0;
    totalsumsq2=0;
    totalsumsq3=0;
    totalsumsq4=0;
    totalsumsq5=0;
    totalsumsq6=0;
    totalmeas1=0;
    totalmeas2=0;
    totalmeas3=0;
    totalmeas4=0;
    totalmeas5=0;
    totalmeas6=0;
elseif(whichones==2)
    load('smNetsSIR2.mat');
    rmse7=zeros(size(days));
    rmse8=zeros(size(days));
    rmse9=zeros(size(days));
    rmse10=zeros(size(days));
    rmse11=zeros(size(days));
    rmse12=zeros(size(days));
    totalsumsq7=0;
    totalsumsq8=0;
    totalsumsq9=0;
    totalsumsq10=0;
    totalsumsq11=0;
    totalsumsq12=0;
    totalmeas7=0;
    totalmeas8=0;
    totalmeas9=0;
    totalmeas10=0;
    totalmeas11=0;
    totalmeas12=0;
end

for dayidx=1:length(days)
    day=days(dayidx);
    [tbav, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,day,0,res);
    disp(['Loaded data for day ' num2str(day)]);

    [ nsy1 , nsx1 ] = size(tbav);

    if(whichones==1)
        moisture_map1=nan(nsy1,nsx1);
        moisture_map2=nan(nsy1,nsx1);
        moisture_map3=nan(nsy1,nsx1);
        moisture_map4=nan(nsy1,nsx1);
        moisture_map5=nan(nsy1,nsx1);
        moisture_map6=nan(nsy1,nsx1);
    elseif(whichones==2)
        moisture_map7=nan(nsy1,nsx1);
        moisture_map8=nan(nsy1,nsx1);
        moisture_map9=nan(nsy1,nsx1);
        moisture_map10=nan(nsy1,nsx1);
        moisture_map11=nan(nsy1,nsx1);
        moisture_map12=nan(nsy1,nsx1);
    end

    % We'll go pixel by pixel, but could do matrix math 
    for picx=1:nsx1
        for picy=1:nsy1
            tb=tbav(picy,picx); %read the brightness temperature
            localtemp=tempav(picy,picx); %read the surface temperature
            vwc=vwcav(picy,picx); %read the vegetation water content
            albedo=albav(picy,picx); %read the scattering albedo
            vegop=vopav(picy,picx); %read the vegetation opacity
            inc=incav(picy,picx); %read the incidence angle
            roughness=rghav(picy,picx); %read the soil roughness
            quality=round(qualav(picy,picx)); %read the retrieval quality
            localclay=clayf(picy,picx); %read the soil clay fraction
            wbfrac=wfracav(picy,picx); %read the water body fraction
            
            if(res==1)
                badqual=(quality ~= 0 && quality ~= 16 && quality ~= 64 && quality ~= 80);
            else
                badqual=(quality ~= 0 && quality ~= 8);
            end

            if((wbfrac > 0 && wfraccorrect) || isnan(tb) || isnan(localclay) || isnan(localtemp) ...
                    || isnan(albedo) || isnan(vegop) || isnan(inc) || isnan(roughness) || badqual )
                continue; %skip if we don't have all necessary info, or bad quality
            end
            netins=[tb, inc, localclay, localtemp, vegop, albedo, roughness, wbfrac];
            if(whichones==1)
                moisture_map1(picy,picx)=smnet5(netins');
                moisture_map2(picy,picx)=smnet5_5(netins');
                moisture_map3(picy,picx)=smnet10(netins');
                moisture_map4(picy,picx)=smnet10_10(netins');
                moisture_map5(picy,picx)=smnet15(netins');
                moisture_map6(picy,picx)=smnet15_15(netins');
            elseif(whichones==2)
                moisture_map7(picy,picx)=smnet15_15_15(netins');
                moisture_map8(picy,picx)=smnet20(netins');
                moisture_map9(picy,picx)=smnet20_20(netins');
                moisture_map10(picy,picx)=smnet20_20_20(netins');
                moisture_map11(picy,picx)=smnet25(netins');
                moisture_map12(picy,picx)=smnet25_25(netins');
            end
        end
        if(mod(picx,1000)==0)
            fprintf('%d\n',picx); %Just to track progress
        end
    end
    
    if(whichones==1)
        moisture_map1(moisture_map1>maxsm) = maxsm;
        moisture_map2(moisture_map2>maxsm) = maxsm;
        moisture_map3(moisture_map3>maxsm) = maxsm;
        moisture_map4(moisture_map4>maxsm) = maxsm;
        moisture_map5(moisture_map5>maxsm) = maxsm;
        moisture_map6(moisture_map6>maxsm) = maxsm;
        moisture_map1(moisture_map1<minsm) = minsm;
        moisture_map2(moisture_map2<minsm) = minsm;
        moisture_map3(moisture_map3<minsm) = minsm;
        moisture_map4(moisture_map4<minsm) = minsm;
        moisture_map5(moisture_map5<minsm) = minsm;
        moisture_map6(moisture_map6<minsm) = minsm;
    elseif(whichones==2)
        moisture_map7(moisture_map7>maxsm) = maxsm;
        moisture_map8(moisture_map8>maxsm) = maxsm;
        moisture_map9(moisture_map9>maxsm) = maxsm;
        moisture_map10(moisture_map10>maxsm) = maxsm;
        moisture_map11(moisture_map11>maxsm) = maxsm;
        moisture_map12(moisture_map12>maxsm) = maxsm;
        moisture_map7(moisture_map7<minsm) = minsm;
        moisture_map8(moisture_map8<minsm) = minsm;
        moisture_map9(moisture_map9<minsm) = minsm;
        moisture_map10(moisture_map10<minsm) = minsm;
        moisture_map11(moisture_map11<minsm) = minsm;
        moisture_map12(moisture_map12<minsm) = minsm;
    end
    

    %% Here on is just creating different plots and maps

    if ancilplot % Optionally plot some ancillary data
        figure
        imagesc(tbav,[100 300]);
        title('Brightness Temperature');
        colorbar

        figure
        imagesc(clayf);
        title('Clay Fraction');
        colorbar

        figure
        imagesc(rghav);
        title('Soil Roughness');
        colorbar

        figure
        imagesc(vwcav);
        title('VWC');
        colorbar

        figure
        imagesc(tempav);
        title('Surface Temperature');
        colorbar
    end

    %% Error plots and maps
    smav(smav>maxsm)=maxsm; %Bound this since it was trained on max=.05  36 km stuff?
    if(whichones==1)
        error1=smav-moisture_map1;
        error2=smav-moisture_map2;
        error3=smav-moisture_map3;
        error4=smav-moisture_map4;
        error5=smav-moisture_map5;
        error6=smav-moisture_map6;
        cursum1=nansum(reshape(error1.^2,1,[]));
        cursum2=nansum(reshape(error2.^2,1,[]));
        cursum3=nansum(reshape(error3.^2,1,[]));
        cursum4=nansum(reshape(error4.^2,1,[]));
        cursum5=nansum(reshape(error5.^2,1,[]));
        cursum6=nansum(reshape(error6.^2,1,[]));
        curmeas1=length(find(~isnan(error1)));
        curmeas2=length(find(~isnan(error2)));
        curmeas3=length(find(~isnan(error3)));
        curmeas4=length(find(~isnan(error4)));
        curmeas5=length(find(~isnan(error5)));
        curmeas6=length(find(~isnan(error6)));
        totalsumsq1=totalsumsq1+cursum1;
        totalsumsq2=totalsumsq2+cursum2;
        totalsumsq3=totalsumsq3+cursum3;
        totalsumsq4=totalsumsq4+cursum4;
        totalsumsq5=totalsumsq5+cursum5;
        totalsumsq6=totalsumsq6+cursum6;
        totalmeas1=totalmeas1+curmeas1;
        totalmeas2=totalmeas2+curmeas2;
        totalmeas3=totalmeas3+curmeas3;
        totalmeas4=totalmeas4+curmeas4;
        totalmeas5=totalmeas5+curmeas5;
        totalmeas6=totalmeas6+curmeas6;
        rmse1(dayidx) = sqrt(cursum1/curmeas1);
        rmse2(dayidx) = sqrt(cursum2/curmeas2);
        rmse3(dayidx) = sqrt(cursum3/curmeas3);
        rmse4(dayidx) = sqrt(cursum4/curmeas4);
        rmse5(dayidx) = sqrt(cursum5/curmeas5);
        rmse6(dayidx) = sqrt(cursum6/curmeas6);
    elseif(whichones==2)
        error7=smav-moisture_map7;
        error8=smav-moisture_map8;
        error9=smav-moisture_map9;
        error10=smav-moisture_map10;
        error11=smav-moisture_map11;
        error12=smav-moisture_map12;
        cursum7=nansum(reshape(error7.^2,1,[]));
        cursum8=nansum(reshape(error8.^2,1,[]));
        cursum9=nansum(reshape(error9.^2,1,[]));
        cursum10=nansum(reshape(error10.^2,1,[]));
        cursum11=nansum(reshape(error11.^2,1,[]));
        cursum12=nansum(reshape(error12.^2,1,[]));
        curmeas7=length(find(~isnan(error7)));
        curmeas8=length(find(~isnan(error8)));
        curmeas9=length(find(~isnan(error9)));
        curmeas10=length(find(~isnan(error10)));
        curmeas11=length(find(~isnan(error11)));
        curmeas12=length(find(~isnan(error12)));
        totalsumsq7=totalsumsq7+cursum7;
        totalsumsq8=totalsumsq8+cursum8;
        totalsumsq9=totalsumsq9+cursum9;
        totalsumsq10=totalsumsq10+cursum10;
        totalsumsq11=totalsumsq11+cursum11;
        totalsumsq12=totalsumsq12+cursum12;
        totalmeas7=totalmeas7+curmeas7;
        totalmeas8=totalmeas8+curmeas8;
        totalmeas9=totalmeas9+curmeas9;
        totalmeas10=totalmeas10+curmeas10;
        totalmeas11=totalmeas11+curmeas11;
        totalmeas12=totalmeas12+curmeas12;
        rmse7(dayidx) = sqrt(cursum7/curmeas7);
        rmse8(dayidx) = sqrt(cursum8/curmeas8);
        rmse9(dayidx) = sqrt(cursum9/curmeas9);
        rmse10(dayidx) = sqrt(cursum10/curmeas10);
        rmse11(dayidx) = sqrt(cursum11/curmeas11);
        rmse12(dayidx) = sqrt(cursum12/curmeas12);
    end
    

    if mapplot
        figure
        imagesc(moisture_map5,[0.02 0.6]);
        title(['My Soil Moisture Map (RMSE = ' num2str(rmse5(dayidx),3), ')']);
        colormap jet(128);
        colorbar

        figure
        smavplot=smav;
        smavplot(isnan(moisture_map5))=NaN;
        imagesc(smavplot,[0.02 0.6]);
        title('NSIDC SM');
        colormap jet(128);
        colorbar
        
        figure
        imagesc(abs(error5),[0.02 0.6]);
        title('Error Map');
        colormap jet(128);
        colorbar
    end
% 
%     if compplot
%         figure
%         plot(vwcav(~isnan(vwcav) & ~isnan(error)),error(~isnan(vwcav) & ~isnan(error)),'.b')
%         title('Error vs. VWC')
%         colorbar
% 
%         figure
%         plot(albav(~isnan(albav) & ~isnan(error)),error(~isnan(albav) & ~isnan(error)),'.b')
%         title('Error vs. Albedo')
%         colorbar
% 
%         figure
%         plot(clayf(~isnan(clayf) & ~isnan(error)),error(~isnan(clayf) & ~isnan(error)),'.b')
%         title('Error vs. Clay Fraction')
%         colorbar
% 
%         figure
%         plot(incav(~isnan(incav) & ~isnan(error)),error(~isnan(incav) & ~isnan(error)),'.b')
%         title('Error vs. Incidence')
%         colorbar
% 
%         figure
%         plot(rghav(~isnan(rghav) & ~isnan(error)),error(~isnan(rghav) & ~isnan(error)),'.b')
%         title('Error vs. Soil Roughness')
%         colorbar
% 
%         figure
%         plot(tbav(~isnan(tbav) & ~isnan(error)),error(~isnan(tbav) & ~isnan(error)),'.b')
%         title('Error vs. Brightness Temperature')
%         colorbar
% 
%         figure
%         plot(tempav(~isnan(tempav) & ~isnan(error)),error(~isnan(tempav) & ~isnan(error)),'.b')
%         title('Error vs. Surface Temperature')
%         colorbar
% 
%         figure
%         plot(vopav(~isnan(vopav) & ~isnan(error)),error(~isnan(vopav) & ~isnan(error)),'.b')
%         title('Error vs. Vegetation Opacity')
%         colorbar
%     end
end

if(whichones==1)
    totalrmse1=sqrt(totalsumsq1/totalmeas1);
    totalrmse2=sqrt(totalsumsq2/totalmeas2);
    totalrmse3=sqrt(totalsumsq3/totalmeas3);
    totalrmse4=sqrt(totalsumsq4/totalmeas4);
    totalrmse5=sqrt(totalsumsq5/totalmeas5);
    totalrmse6=sqrt(totalsumsq6/totalmeas6);
    disp(['Total rmse1=' num2str(totalrmse1,3)]);
    disp(['Total rmse2=' num2str(totalrmse2,3)]);
    disp(['Total rmse3=' num2str(totalrmse3,3)]);
    disp(['Total rmse4=' num2str(totalrmse4,3)]);
    disp(['Total rmse5=' num2str(totalrmse5,3)]);
    disp(['Total rmse6=' num2str(totalrmse6,3)]);
elseif(whichones==2)
    totalrmse7=sqrt(totalsumsq7/totalmeas7);
    totalrmse8=sqrt(totalsumsq8/totalmeas8);
    totalrmse9=sqrt(totalsumsq9/totalmeas9);
    totalrmse10=sqrt(totalsumsq10/totalmeas10);
    totalrmse11=sqrt(totalsumsq11/totalmeas11);
    totalrmse12=sqrt(totalsumsq12/totalmeas12);
    disp(['Total rmse7=' num2str(totalrmse7,3)]);
    disp(['Total rmse8=' num2str(totalrmse8,3)]);
    disp(['Total rmse9=' num2str(totalrmse9,3)]);
    disp(['Total rmse10=' num2str(totalrmse10,3)]);
    disp(['Total rmse11=' num2str(totalrmse11,3)]);
    disp(['Total rmse12=' num2str(totalrmse12,3)]);
end

