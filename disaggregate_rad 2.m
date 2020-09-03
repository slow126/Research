% Uses the SMAP algorithm to create higher resolution radiometer images. 

% TODO: Create all the readers and get all the data.
% TB_M: Medium resolution. It is the enhanced resolution of TB
% TB_C: Course resolution. It is the raw DIB resolution of TB
% B_C: The slope or E(TB|sigma) of TB = alpha + B_C * sigma
% sigma_M: The medium resolution of backscatter.
% sigma_C: The course resolution of backscatter.
% gamma: der(sigma)/der(cross_sigma)
% cross_sigma: Cross polarization of sigma



sigma_F = 2*ones([36,36,10]); 

z = size(sigma_F,3);

sigma_M = zeros(9,9,size(sigma_F,3));
sigma_C = zeros(1,1,size(sigma_F,3));

cross_sigma_M = zeros(9,9,size(sigma_F,3));

for i = 1:size(sigma_F,3)
    sigma_M(:,:,i) = reduce_size_byN(sigma_F(:,:,i),4);
    sigma_C(:,:,i) = reduce_size_byN(sigma_F(:,:,i),36);
end

TB_C = ones([1 1 10]);

my_Beta_vars = polyfit(reshape(TB_C,1,z),reshape(sigma_C,1,z),1);
B_C = my_Beta_vars(1,1);

gamma = diff(sigma_M) / diff(cross_sigma_M);

TB_M = TB_C + B_C * ((sigma_M - sigma_C) + gamma * (cross_sigma_C - cross_sigma_M));









