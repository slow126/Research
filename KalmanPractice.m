dt = .1;
t = 0:dt:10;

g = -9.8;
P = 1000;

X_0 = [P;
       0];
u = g;

truth = P + g*t + 1/2*g*t.^2;

noise = 5 * normrnd(0,1,[1,101]);

meas = truth + noise;

for i = 1:length(t)
    A = [1 dt; 
        0 1];

    B = [1/2 * dt^2;
        dt];
    
    if i == 1
        X_i(i).pos = A * X_0 + B * u + noise(i);
    else
        X_i(i).pos = A * X_i(i-1).pos + B * u + noise(i);
    end
    
    
    
end



for i = 1:length(t)
    position(i) = X_i(i).pos(1);
end

figure(1)
plot(t,position)
hold on
plot(t,meas)
hold on
plot(t,truth)
hold off
legend('Calculated','Measured','Truth')



