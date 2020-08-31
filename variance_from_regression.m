sample_length = 100;

noiseCOEF = 5;
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

Var_X = var_of_lsr(X);

b = 2*a;
% b = 4 * ones(1,sample_length);
% b = 3-1/3*a;
% b = rand(1,sample_length);


Y = b + 2 * noiseCOEF*Y_noise ;
Var_Y = var_of_lsr(Y);
% Y = 4*ones(1,10);
%Y = ones(1,10) + [1:.1:1.9];

% rad = make_oneDim(rad_h);
% sig = make_oneDim(sigma_h);
% 
% a = rad(1500000:1600000)';
% b = sig(1500000:1600000)';
% 
% X = a;
% Y = b;
% sample_length = length(X);

beta = cond_expect(a,b,b(sample_length)) / b(sample_length);

save('X.mat','X');
save('Y.mat','Y');


myXFIT_vars = polyfit((1:sample_length),X,1);
myXFIT = myXFIT_vars(1)*(1:sample_length) + myXFIT_vars(2);

myYFIT_vars = polyfit((1:sample_length),Y,1);
myYFIT = myYFIT_vars(1)*(1:sample_length) + myYFIT_vars(2);
  
for i = -100:200
    
    alpha = i/100;
    a_hat = (1-alpha) * X + (alpha * beta) * Y;
    
    true_var(i+101) = var_of_lsr(a_hat);
    

end

for i = -100:200
    alpha(i+101) = i/100;
    %a_hat(i+101) = (1-alpha(i+101)) * X + (alpha(i+101) * beta) * Y;
end

lowMIN = min(true_var);
calculated_min_location = var_of_lsr(X)/(var_of_lsr(X) + beta^2*var_of_lsr(Y));
my_min_alpha = alpha(true_var == lowMIN);

Raw_Var = Var_X*ones(1,length(true_var));

beta_varY_varX = beta^2 * var(Y) / var(X);


figure(1)
plot(-1:.01:2,true_var)
hold on
plot(-1:.01:2,ones(1,length(true_var)) * Var_X);
plot(-1:.01:2,ones(1,length(true_var)) * Var_Y);
hold off
legend('Variance','Var(X)','Var(Y)')
title('Variance from Regression Line')

a_hat = (1-my_min_alpha) * X + (my_min_alpha * beta) * Y;
var(a_hat);
figure(2)
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
    
figure(3)
plot(a)
hold on
plot(myFIT)
plot(myXFIT)
hold off
legend('A','Reduced Variance Fit Line','Basic Fit')






