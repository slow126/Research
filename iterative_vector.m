function [ a_hat ] = iterative_vector(X,Y,a,b)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

sample_length = length(a);

beta_A = cond_expect(a,b,b(sample_length)) / b(sample_length);

Var_X = var_of_lsr(X);
Var_Y = var_of_lsr(Y);

myXFIT_vars = polyfit((1:sample_length),X,1);
myXFIT = myXFIT_vars(1)*(1:sample_length) + myXFIT_vars(2);

myYFIT_vars = polyfit((1:sample_length),Y,1);
myYFIT = myYFIT_vars(1)*(1:sample_length) + myYFIT_vars(2);
  
for i = -100:200
    
    alpha = i/100;
    a = (1-alpha) * X + (alpha * beta_A) * Y;
    
    true_var(i+101) = var_of_lsr(a);
    
%     true_var(i+101) = var(a_hat);

    Var_ALT(i+101) = (1-alpha)^2 * var(X,'omitnan') + alpha^2*beta_A^2 * var(Y,'omitnan');

end

for i = -100:200
    alpha(i+101) = i/100;
    %a_hat(i+101) = (1-alpha(i+101)) * X + (alpha(i+101) * beta) * Y;
end

longMIN = min(Var_ALT);
lowMIN = min(true_var);
calculated_min_location = var_of_lsr(X)/(var_of_lsr(X) + beta_A^2*var_of_lsr(Y));
my_min_alpha = alpha(true_var == lowMIN);

Raw_Var = Var_X*ones(1,length(true_var));

a_hat = (1-my_min_alpha) * X + (my_min_alpha * beta_A) * Y;


end

