sample_length = 100;

noiseCOEF = 5;
norm_noise = true;

if(norm_noise)
    X_noise = (-1).^binornd(1,.5,1,sample_length).*normrnd(1,1,[1,sample_length]);
    Y_noise = (-1).^binornd(1,.5,1,sample_length).*normrnd(1,1,[1,sample_length]);
else
    X_noise = (-1).^binornd(1,.5,1,sample_length).*rand([1,sample_length]);
    Y_noise = (-1.)^binornd(1,.5,1,sample_length).*rand([1,sample_length]);
end
    
a = 1:sample_length;
% a = ones(1,sample_length);
X = a + noiseCOEF*X_noise;

Original_X = X;
b = 2*a;
Y = b + noiseCOEF*Y_noise;


figure(1)
for i = 1:4
    if i == 1
        newX = iterative_vector(X,Y,a,b);
        newY = iterative_vector(Y,X,b,a);
    else
        newX = iterative_vector(newX,newY,a,b);
        newY = iterative_vector(newY,newX,b,a);
    end
    
    plot(newX)
    hold on
    plot(newY)
    hold on
end

hold off


figure(2)
plot(X)
hold on
plot(Y)
hold off
legend('X','Y')
