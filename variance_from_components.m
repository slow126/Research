sample_length = 100;

noiseCOEF = 2;
norm_noise = true;

if(norm_noise)
    X_noise = (-1).^binornd(1,.5,1,sample_length).*normrnd(1,1,[1,sample_length]);
    Y_noise = (-1).^binornd(1,.5,1,sample_length).*normrnd(1,1,[1,sample_length]);
else
    X_noise = (-1).^binornd(1,.5,1,sample_length).*rand([1,sample_length]);
    Y_noise = (-1).^binornd(1,.5,1,sample_length).*rand([1,sample_length]);
end
    

a = 1:sample_length;
% a = ones(1,sample_length);
X = a + noiseCOEF*X_noise;

Original_X = X;

Var_X = var(X);

b = 2*a;
% b = 4 * ones(1,sample_length);
% b = 3-1/3*a;
% b = rand(1,sample_length);


Y = b + 2*noiseCOEF*Y_noise ;
Var_Y = var(Y);
% Y = 4*ones(1,10);
%Y = ones(1,10) + [1:.1:1.9];

beta = cond_expect(a,b,b(sample_length)) / b(sample_length);

% load('X.mat')
% load('Y.mat')

figure(1)
plot(X)
hold on
plot(Y)
hold off
legend('Pre-PCA X','Pre-PCA Y')

orig_X = X;
orig_Y = Y;

[COEFF, SCORE, LATENT, TSQUARED] = pca([X',Y'],'Centered',false);

pcaX = SCORE(:,1)'; % <- possibly important, PCA shifts the order of variables. So X and Y may be flipped. 
pcaY = SCORE(:,2)';

figure(2)
plot(X)
hold on
plot(Y)
hold off
legend('Post-PCA X','Post-PCA Y')

Var_X = var(X);
Var_Y = var(Y);

beta = cond_expect(a,b,b(sample_length)) / b(sample_length);

for i = -100:200
    
    alpha = i/100;
    a_hat = (1-alpha) * pcaX + (alpha * beta) * pcaY;
    
    true_var(i+101) = var_of_lsr(a_hat);
%     covXY = cov(X,Y);
%     true_var(i+101) = (1-alpha)^2 * var_of_lsr(X) + alpha^2*beta^2 * var_of_lsr(Y) + 2*(1-alpha)*(alpha*beta)*covXY(1,2);

end

for i = -100:200
    alpha(i+101) = i/100;
    %a_hat(i+101) = (1-alpha(i+101)) * X + (alpha(i+101) * beta) * Y;
end

lowMIN = min(true_var);
calculated_min_location = var_of_lsr(X)/(var_of_lsr(X) + beta^2*var_of_lsr(Y));
my_min_alpha = alpha(true_var == lowMIN);

figure(3)
plot(-1:.01:2,true_var)
hold on
plot(-1:.01:2,ones(1,length(true_var)) * Var_X);
plot(-1:.01:2,ones(1,length(true_var)) * Var_Y);
hold off
legend('Variance','Var(X)','Var(Y)')
title('Variance from Regression Line')

a_hat = (1-my_min_alpha) * X + (my_min_alpha * beta) * Y;
var(a_hat);
figure(4)
plot(1:sample_length,a_hat)
hold on
plot(1:sample_length,X)
plot(1:sample_length,Y)
hold off
legend('A hat', 'X','Y')

myFIT_vars = polyfit((1:sample_length),a_hat,1);
myFIT = myFIT_vars(1)*(1:sample_length) + myFIT_vars(2);

myXFIT_vars = polyfit((1:sample_length),X,1);
myXFIT = myXFIT_vars(1)*(1:sample_length) + myFIT_vars(2);
    
figure(5)
plot(a)
hold on
plot(myFIT)
plot(myXFIT)
hold off
legend('A','Reduced Variance Fit Line','Basic Fit')