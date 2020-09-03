%
% matlab script to illustrate the use of meshgrid and matrices
% written by D.G. Long 11 Sep 2014

% define a 2d array with entries that indicate the row, column
disp('original array')
A=[11 12 13; 21 22 23; 31 32 33; 41 42 43]

% get input array sizes
[Nrows,Ncols]=size(A);
Nel=Nrows*Ncols;
fprintf('Size of A: %d,%d  %d,%d  elements=%d\n',size(A),Nrows,Ncols,Nel)

% illustrate display of matrix using imagesc
figure(1)
imagesc(A)
colorbar
axis image
title('axis image (sized axis ij)')

figure(2)
imagesc(A)
colorbar
axis ij
title('axis ij = axis normal')

figure(2)
imagesc(A)
colorbar
axis xy
title('axis xy (vertical flip compared to axis ij)')

% illustrate use of meshgrid
indrows=1:Nrows;  % this is a row vector
indcols=1:Ncols;  % this is a row vector

% use meshgrid to create matrices with indexes to rows, cols
% note: output arrays are transposes of conventional definitions
[rowmat,colmat]=meshgrid(indrows,indcols); % [X,Y] = MESHGRID(x,y)
rowmat
colmat

myfigure(4)
subplot(1,2,1)
imagesc(rowmat)
colorbar
axis image
title('rowmat')
subplot(1,2,2)
imagesc(colmat)
colorbar
axis image
title('colmat')

% create index array to elements of array
% note added transpose to insure output is cardinal order
ind=sub2ind([Nrows,Ncols],reshape(rowmat',1,Nel),reshape(colmat',1,Nel));
ind

% preallocate array
B=zeros([Nrows, Ncols]);
% copy array using index array -- should be the same as original
B(ind)=A

% create a column vector
x=(0:Ncols-1)';

% do a (conventional) matrix multiply
y=A*x

% do matrix multiply using transpose
y=x'*A'