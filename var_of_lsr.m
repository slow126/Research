function [ myvar ]= var_of_lsr( data )
% Calculates the variance from the least squares regression line. 

    sample_length = length(data);

    myFIT_vars = polyfit((1:sample_length),data,1);
    myFIT = myFIT_vars(1)*(1:sample_length) + myFIT_vars(2);

myvar = nansum(abs(data - myFIT))^2/(length(data)-1);


end

