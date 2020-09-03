function [ expect_of_A_given_B ] = cond_expect( A_vector, B_vector, B )
% E(A|B=b) where B is within 10% of b. Vectors must be the same length

B_logical = (B_vector <= B + abs(B/10) & B_vector >= B - abs(B/10));

expect_of_A_given_B = nansum(A_vector .* B_logical) / nansum(B_logical);


end

