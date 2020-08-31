sample_length = 100;

noiseCOEF = .5;
norm_noise = true;

if(norm_noise)
    X_noise = (-1).^binornd(1,.5,1,sample_length).*normrnd(1,1,[1,sample_length]);
    Y_noise = (-1).^binornd(1,.5,1,sample_length).*normrnd(1,1,[1,sample_length]);
else
    X_noise = (-1).^binornd(1,.5,1,sample_length).*rand([1,sample_length]);
    Y_noise = (-1).^binornd(1,.5,1,sample_length).*rand([1,sample_length]);
end
    

% a = 1:sample_length;
a = ones(1,sample_length);
X = a + noiseCOEF*X_noise;

Original_X = X;

Var_X = var(X);

b = 2*a;
% b = 4 * ones(1,sample_length);
% b = 3-1/3*a;
% b = rand(1,sample_length);


Y = b + noiseCOEF*Y_noise ;
Var_Y = var(Y);
% Y = 4*ones(1,10);
%Y = ones(1,10) + [1:.1:1.9];

beta = cond_expect(a,b,b(sample_length)) / nanmean(b);

figure(1)
plot(X)
hold on
plot(Y)
hold off
legend('Pre-PCA X','Pre-PCA Y')

[COEFF, SCORE, LATENT, TSQUARED] = pca([X',Y'],'Centered',false);

% X = SCORE(:,1)'; % <- possibly important, PCA shifts the order of variables. So X and Y may be flipped. 
% Y = SCORE(:,2)';

Var_PCA_X = var(X);
Var_PCA_Y = var(Y);

p_a = 1/10;
p_b = 1/10;
p_ab = p_a * p_b;
p_aGb = p_ab / p_b;
e_b = mean(2*a);

[abCOEFF, abSCORE] = pca([a',b']);

aPCA = abSCORE(:,1)';
bPCA = abSCORE(:,2)';


% myXFIT_vars = polyfit((1:sample_length),X,1);
% myXFIT = myXFIT_vars(1)*(1:sample_length) + myXFIT_vars(2);
% 
% myYFIT_vars = polyfit((1:sample_length),Y,1);
% myYFIT = myYFIT_vars(1)*(1:sample_length) + myYFIT_vars(2);
  
for i = -100:200
    
    alpha = i/100;
    a_hat = (1-alpha) * X + (alpha * beta) * Y;
    
    
    true_var(i+101) = var(a_hat);
    
%     true_var(i+101) = var(a_hat);
    
    MY_VAR_A(i+101) = nansum((((1-alpha)*X + alpha*beta*Y) - nanmean((1-alpha)*X + alpha*beta*Y)).^2)/(length(X)-1);
    
    covXY = cov(X,Y);

    Var_ALT(i+101) = (1-alpha)^2 * var(X,'omitnan') + alpha^2*beta^2 * var(Y,'omitnan') + 2*(1-alpha)*(alpha*beta)*covXY(1,2);

end

for i = -100:200
    alpha(i+101) = i/100;
    %a_hat(i+101) = (1-alpha(i+101)) * X + (alpha(i+101) * beta) * Y;
end

longMIN = min(Var_ALT);
lowMIN = min(MY_VAR_A);
calculated_min_location = var(X)/(var(X) + beta^2*var(Y));
my_min_alpha = alpha(MY_VAR_A == lowMIN);

Raw_Var = Var_X*ones(1,length(true_var));

beta_varY_varX = beta^2 * var(Y) / var(X);


figure(2)
plot(X)
hold on
plot(Y)
hold off
legend('Post-PCA X','Post-PCA Y')

figure(3)
plot(-1:.01:2,MY_VAR_A)
hold on
plot(-1:.01:2,Var_ALT)
plot(-1:.01:2,true_var)
plot(-1:.01:2,Raw_Var)
hold off
legend('Low','Long','True','Raw Var')

figure(4)
plot(-1:.01:1.99,diff(MY_VAR_A))
hold on
plot(-1:.01:1.99,diff(Var_ALT))
plot(-1:.01:1.99,diff(true_var))
hold off
legend('Low','Long','True')

a_hat = (1-my_min_alpha) * X + (my_min_alpha * beta) * Y;
var(a_hat)
figure(5)
plot(a_hat)
hold on
plot(X)
plot(Y)
hold off
legend('A hat', 'X','Y')


%%%%%%%%%%%%%%%%%%%%%%%%%
% View how beta affects %
%%%%%%%%%%%%%%%%%%%%%%%%%

figure(6)
for j = -100:200

    beta = j/100;
    
    for i = -100:200
    alpha = i/100;
    a_hat = (1-alpha) * X + (alpha * beta) * Y;
    
    true_var(i+101) = var(a_hat);
    
    MY_VAR_A(i+101) = nansum((((1-alpha)*X + alpha*beta*Y) - nanmean((1-alpha)*X + alpha*beta*Y)).^2)/(length(X)-1);

    Var_ALT(i+101) = (1-alpha)^2 * var(X,'omitnan') + alpha^2*beta^2 * var(Y,'omitnan');

    end
    
    plot(-1:.01:2,true_var)
    hold on;
end
hold off;

figure(7)
plot(a)
hold on
plot(b)
plot(a_hat)
plot(X)
hold off

legend('A','B','A hat','X')

% figure(8)
% plot(myXFIT)
% hold on
% plot(myYFIT)
% plot(X)
% plot(Y)
% hold off
% ylim([0,b(sample_length) + 1])
