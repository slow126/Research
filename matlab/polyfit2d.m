function p = polyfit2d(x,y,z,n,m)
% P= POLYFIT2D(x,y,z,n,m) finds the coefficients of a 
%  polynomial function of 2 variables formed from the
%  data in vectors x and y of degrees n and m, respectively,
%  that fit	the data in vector z in a least-squares sense.  
%
% The regression problem is formulated in matrix format as:
%
%	z = A*P   So that if the polynomial is cubic in  
%             x and linear in y, the problem becomes:
%
%	z = [y.*x.^3  y.*x.^2  y.*x  y x.^3  x.^2  x  ones(length(x),1)]*
%	    [p31 p21 p11 p01 p30 p20 p10 p00]'                      
%		
%  Note that the various xy products are column vectors of length(x).
%
%  The coefficents of the output p    
%  matrix are arranged as shown:
%
%      p31 p30 
%      p21 p20 
%      p11 p10 
%      p01 p00
%
% The indices on the elements of p correspond to the 
% order of x and y associated with that element.
%
% For a solution to exist, the number of ordered 
% triples [x,y,z] must equal or exceed (n+1)*(m+1).
% Note that m or n may be zero.
%
% To evaluate the resulting polynominal function,
% use POLYVAL2D.

% Perry W. Stout  June 29, 1995
% 4829 Rockland Way
% Fair Oaks, CA  95628
% (916) 966-0236
% Based on the Matlab function polyfit.

if any((size(x) ~= size(y)) | (size(z) ~= size(y)))
	error('X, Y,and Z vectors must be the same size')
end

x = x(:); y = y(:); z= z(:);  % Switches vectors to columns--matrices, too

if length(x) < (n+1)*(m+1)
 error('Number of points must equal or exceed order of polynomial function.')
end

n = n + 1;
m = m + 1; % Increments n and m to equal row, col numbers of p.

a = zeros(max(size(x)),n*m);

% Construct the extended Vandermonde matrix, containing all xy products.

 for i1= 1:m
   for j1=1:n
	     a(:,j1+(i1-1)*n) = (x.^(n-j1)).*(y.^(m-i1));
   end
 end
p1 = (a\z);
% Reform p as a matrix.

p=[];
for i1=1:m
p=[p, p1((n*(i1-1)+1):(n*i1))];
end

