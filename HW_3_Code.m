clear all;
trials = 100000;
 
X_vector = random('Binomial', 20, 0.2, [1, trials]);

for i =1:21    
    count (i, 1) = i-1 ; 
    count (i, 2) = sum( (i-1) == X_vector ); 
                       
end
 
pvec = count(:, 2)/trials;
bar ( count(:, 1), pvec); 

clear all;
values = geornd(.1, 1, 100000);
 
for i =1:100 
    counts (i, 1) = i-1 ; 
    counts (i, 2) = sum( (i-1) == values );
                                                           
end
pval = counts (:, 2)/100000; 
bar (counts(:, 1), pval);

clear all;
poison = poissrnd(3,1,100000);

for i = 1:21
    kount (i, 1) = i-1;
    kount (i, 2) = sum( (i-1) == poison);
end

ppoison = kount (:, 2) / 100000;
bar (kount(:, 1), ppoison);

clear all;
X = random('Binomial', 4, 0.25, [1, 100000]);
for i = 1:100000
    Y(i) = (X(i) - 1)^2;
end

for j = 1:9
    c (j,1) = j-1;
    c (j, 2) = sum ( (j-1) == X);
end

pX = c(:, 2) / 100000;
bar (c(:, 1), pX);

for j = 1:10
    c (j,1) = j-1;
    c (j, 2) = sum ( (j-1) == Y);
end

pY = c(:, 2) / 100000;
bar (c(:, 1), pY);

    

