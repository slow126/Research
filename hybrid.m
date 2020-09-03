Tb = zeros(20,100);
for j = 1:20
    exist = binornd(1,.3);
    for i = 1:100
        cloud = binornd(1,.3);
        Tp(j,i) = normrnd(250,1);
        cloud = cloud * 20;
    
        Tb(j,i) = Tp(j,i) - cloud * exist;
    end
    
end

%real = mean(Tp,1); 
stddev = std(Tb,1);
threshold = stddev > 1.25;
average = mean(Tb,1);
temp2 = Tb > (max(Tb)-min(Tb))/2 + min(Tb);
above = Tb > (max(Tb)-min(Tb))/2 + min(Tb);%Tb > average;
above_avg = Tb .* above;
above_avg(~above_avg) = NaN;
mma = mean(above_avg,'omitnan');



hybrid_Tb = mma .* threshold + average .* ~threshold;

figure(1)
plot(ones(1,100)*mean(hybrid_Tb,'omitnan'))
hold on 
plot(hybrid_Tb)
hold on
plot(ones(1,100)*250)
hold on
plot(mean(Tp,1))
hold off
legend('Hybrid based off middle value','Average of Hybrid','Real Average','Real')
xlabel('Number of Pixels')
ylabel('Tb (K)')
axis([0 100 249 251.5])
saveas(figure(1), 'hybrid.png')

figure(2)
plot(ones(1,100)*mean(mma))
hold on
plot(mma)
hold on
plot(mean(Tp,1))
hold on
plot(ones(1,100)*250)
hold off
legend('MMA','Average of MMA','Real Average','Real')
xlabel('Number of Pixel')
ylabel('Tb')
axis([0 100 249 251.5])
saveas(figure(2),'mma.png')

figure(3)
plot(ones(1,100)*mean(average))
hold on
plot(average)
hold on
plot(ones(1,100)*250)
hold on
plot(mean(Tp,1))
hold off
legend('Mean of Average','Average','Real Avg','Real')
xlabel('Number of Pixel')
ylabel('Tb')
saveas(figure(3),'average.png')
