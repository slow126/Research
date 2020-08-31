j = 1;

for i = 275:303
   out(:,:,j) = sm2tb(sm(j).sm, 2016, i, 1);
   out(:,:,j) = tb2sm(out(:,:,j), 2016, i, 1);
   j = j + 1;
end

tb = nanmean(out,3);


% Use meas_meta_setupSMAP to make setup files, and look at meas_meta_sir2b
% to look how they are read in. 

