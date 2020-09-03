noiseCOEF = 5;
a = [0,1,2];
b = 2*a;
X_noise = (-1).^binornd(1,.5).*normrnd(1,1);
Y_noise = (-1).^binornd(1,.5).*normrnd(1,1);
X = a + noiseCOEF*X_noise;
Y = b + noiseCOEF*Y_noise;

for i = 1:100
    
     newX = iterative_vector(X,Y,a,b);
     newY = iterative_vector(Y,X,b,a);
    
    X_noise = (-1).^binornd(1,.5).*normrnd(1,1);
    Y_noise = (-1).^binornd(1,.5).*normrnd(1,1);
    
    X = [X,i+X_noise];
    Y = [Y,2*i+Y_noise];
    
end
