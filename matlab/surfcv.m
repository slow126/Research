function [Tx,Ty,Tz] = surfcv(x,y,z,f,const);
%SURFCV 3-D surface of constant value plot.
%   SURFCV(X,Y,Z,F,CONST) draws a surface of constant value
%   for a function of three variables:  F(X,Y,Z) = CONST .
%   The arrays X,Y,Z define the coordinates for F and
%   must be monotonic and 3-D plaid (as if produced by
%   meshgrid).  The surface is calculated by linear
%   interpolation of the values of F and is drawn with 
%   triangular patches using FILL3.  The color of each 
%   point on the surface is determined by its distanse 
%   from the origin.  F must be an M-by-N-by-P volume 
%   array.
%
%   SURFCV(F,CONST) assumes X=1:N, Y=1:M, Z=1:P.
%
%   H = SURFCV(...) returns a column vector of handles 
%   to PATCH objects, one handle per patch.
%
%   [TX,TY,TZ] = SURFCV(X,Y,Z,F,CONST); returns 3-by-K
%   arrays specifying x,y,z coordinates of the vertices
%   of the triangular patches, where K is the number
%   of patches.  FILL3(TX,TY,TZ,C) can be used to draw
%   the surface.
%
%   Example: To visualize the surface 
%        1./(x.^2+y.^2) +  1./(y.^2+z.^2) + 1./(z.^2+x.^2) = 2
%   over the range -3 < x < 3, -3 < y < 3, -3 < z < 3, 
%
%      [x,y,z] = meshgrid(-3:.4:3, -3:.6:3, -3:.4:3);
%      f = 1./(x.^2+y.^2) +  1./(y.^2+z.^2) + 1./(z.^2+x.^2);
%      const = 2;
%      surfcv(x,y,z,f,const);

%  Copyright (c) 1997 Ruslan L. Davidchack
%                     University of Kansas, Lawrence, KS
%                     davidchack@kuphsx.phsx.ukans.edu
%                     http://weizen.chem.ukans.edu/ruslan
%      created:  Sep 29, 1997; 

%Short description of the algorithm.
%   Function F is defined on the M-by-N-by-P 3-D grid which 
%   divides the space into (M-1)*(N-1)*(P-1) cubes.   
%   F specifies values of the function at the vertices.
%   The surface of constant value cuts a patch through a 
%   cube if F < CONST for some vertices of the cube and 
%   F > CONST for others. 
%     Note: F is slightly modified on the input to assure 
%           that it does not exactly equal CONST on a vertex,
%           and thus a vertex of a surface element belongs to
%           only one edge (see below). 
%   Every vertex of the patch lays on the edge of the 
%   cube and its coordinates can be determined by linear 
%   interpolation between the values of the function on the
%   ends of the edge. Two vertices of a patch are connected 
%   if they lay on the edges that belong to the same face of
%   a cube. If a patch has more than three vertices, it is
%   subdivided into triangular elements by additional 
%   connections between vertices that do not belong to the
%   same face.  
%   The idea of the algorithm is to group the edges which
%   contain vertices of the surface patches into pairs according 
%   to their affiliation with the faces (there can be only 2 or 4   
%   patch vertices on a face).  Then the edge pairs are grouped
%   according to their affiliation with the cubes.  The "cube-edge" 
%   array, thus created, is then decomposed into triplets of patch
%   vertices.  There can be more than one patch per cube and 
%   the algorithm handles this case as well.
%Naming convensions
%   ve - vertex, ed - edge, fa - face, cu - cube
%   nv - number of vertices, ne - number of edges, etc.
%   ce - coordinates of edges, cf - coordinates of faces, etc.
%   ie - indices of edges, ia - indices of faces, etc.

%Simple case to follow the algorithm
%      [x,y,z] = meshgrid(1:4, 1:3, 1:2); const = 15;
%      f = x.^2 + y.^2 + z.^2; 
%Different cool surfaces:
% 1.   [x,y,z] = meshgrid(-3:.2:3, -3:.2:3, -3:.2:1.6); const = 7;
%      f = 1./(x.^2+y.^2)+1./(y.^2+z.^2)+1./(z.^2+x.^2)+x.^2+y.^2+z.^2;
%     
% 2.   [x,y,z] = meshgrid(-2:.2:2, -2:.2:2, -2:.2:2);  const = 0;
%      f = (x.^2 + y.^2 + z.^2).^2 - 4*(x.^2 - y.^2 - z.^2);
%
% 3.   [x,y,z] = meshgrid(-2:.2:2, -2:.2:2, -2:.2:2);  const = 0;
%      f = x.^2 + y.^2 - z.^2.*(2 - z)./(2 + z);                 

  if nargin == 2,
    f = x; const = y;
    [x,y,z] = meshgrid(1:size(f,2),1:size(f,1),1:size(f,3));
  elseif nargin ~=5
    disp('Wrong number of input arguments'); return;
  end,  

%Make sure F == CONST is never true
  f1 = f;  
  if const == 0,
    f1(find(f == const)) = 1e-10;   
  else
    f1(find(f == const)) = (1 + 1e-10)*const;  
  end,

%Number of vertices in each direction:  nv = [M N P]
%   Total number of vertices = prod(nv) 
  nv = size(f1);  iv = reshape(1:prod(nv),nv);
  [ix,iy,iz] = meshgrid(1:nv(2),1:nv(1),1:nv(3));

%Number of edges of each orientation:  
%			ne = [(M-1)*N*P  M*(N-1)*P  M*N*(P-1)]
%   Total number of edges = sum(ne)
  ne = prod(nv) - prod(nv([2 1 1;3 3 2]));

%Determine indices of vertices that belong to each edge
%   Indexing of vertices is such as in f(:)
  ed = zeros(sum(ne),2);
%   Edges parallel to y-axis
  ed((1:ne(1)),1) = reshape(iv(1:nv(1)-1,:,:),ne(1),1); 
  ed((1:ne(1)),2) = ed((1:ne(1)),1) + 1;
%   Edges parallel to x-axis
  ie = (1:ne(2)) + ne(1);
  ed(ie,1) = reshape(iv(:,1:nv(2)-1,:),ne(2),1);
  ed(ie,2) = ed(ie,1) + nv(1); 
%   Edges parallel to z-axis
  ie = (1:ne(3)) + ne(1) + ne(2);
  ed(ie,1) = (1:ne(3))';
  ed(ie,2) = ed(ie,1) + nv(1)*nv(2); 

%Select edges crossed by the surface 
  se = find(prod(f1(ed)' - const) < 0)';   
  if isempty(se), disp('There is no surface in the specified range');
    return; end;
  ed = ed(se,:);

%Restore coordinates of the selected edges 
  ce = zeros(length(se),4);
  ce(:,4) = (se > ne(1)) + (se > ne(1)+ne(2)) + 1;
  ce(:,1:3) = [ix(ed(:,1)) iy(ed(:,1)) iz(ed(:,1))];
 
%Determine coordinates of the patch vertices  
%  ie = find(diff([ce(:,4);4]) > 0); 
%  ie1 = 1:ie(1);  ie2 = ie(1)+1:ie(2);  ie3 = ie(2)+1:ie(3);
  ie1 = find(ce(:,4) == 1); 
  ie2 = find(ce(:,4) == 2); 
  ie3 = find(ce(:,4) == 3); 
  ie = cumsum([length(ie1);length(ie2);length(ie3)]);
  ds = (const - f1(ed(:,1)))./diff(f1(ed)')';
  le = [x(1,2,1)-x(1,1,1);y(2,1,1)-y(1,1,1);z(1,1,2)-z(1,1,1)];
  xv = x(1,ce(:,1),1); xv = xv(:); xv(ie2) = xv(ie2) + ds(ie2).*le(1); 
  yv = y(ce(:,2),1,1); yv = yv(:); yv(ie1) = yv(ie1) + ds(ie1).*le(2); 
  zv = z(1,1,ce(:,3)); zv = zv(:); zv(ie3) = zv(ie3) + ds(ie3).*le(3); 

%Find faces containing the selected edges (maximum of 4 faces per edge)
  cf = repmat([(1:length(se))' ce],1,4);
%Edge-to-face coordinate transformation matrix
  etof = [0 0 0 0 0   0 -1  0  0 0   0 0 0 0  2   0  0  0 -1  2;...
	  0 0 0 0 0   0  0  0 -1 0   0 0 0 0 -1   0  0 -1  0 -1;...
          0 0 0 0 0   0  0 -1  0 0   0 0 0 0 -1   0 -1  0  0 -1];
  ie = diff([0;ie]);
  cf = cf + [repmat(etof(1,:),ie(1),1);repmat(etof(2,:),ie(2),1);...
             repmat(etof(3,:),ie(3),1)];
  cf = reshape(cf',5,4*length(se));

%Discard faces that are outside the range of x,y,z 
  cf(:,find(prod(cf) == 0)) = [];  cf = cf';
  i1 = find(cf(:,5) ~= 2);  cf(i1(find(cf(i1,3) > nv(1)-1)),:) = [];  
  i2 = find(cf(:,5) < 3);   cf(i2(find(cf(i2,2) > nv(2)-1)),:) = [];  
  i3 = find(cf(:,5) > 1);   cf(i3(find(cf(i3,4) > nv(3)-1)),:) = [];

%Find indices of the selected faces
  i1 = find(cf(:,5)==1); i2 = find(cf(:,5)==2); i3 = find(cf(:,5)==3);
%Number of faces of each orientation:
%                ne = [(M-1)*(N-1)*P  M*(N-1)*(P-1)  (M-1)*N*(P-1)]
  nf = [nv(3)*(nv(2)-1)*(nv(1)-1) nv(1)*(nv(2)-1)*(nv(3)-1)...
        nv(2)*(nv(3)-1)*(nv(1)-1)];
  fa = zeros(size(cf,1),1);  
  fa(i1) = cf(i1,3)+((cf(i1,2)-1)+(cf(i1,4)-1)*(nv(2)-1))*(nv(1)-1);
  fa(i2) = cf(i2,3)+((cf(i2,2)-1)+(cf(i2,4)-1)*(nv(2)-1))*nv(1)+nf(1);
  fa(i3) = cf(i3,3)+((cf(i3,2)-1)+(cf(i3,4)-1)*nv(2))*(nv(1)-1)+...
	   nf(1) + nf(2);
  [fa ia] = sort(fa);

%!!!!!!!! Check whether fac values come in pairs.
%   Each face can have only 2 or 4 selected edges.
%   The check below can be removed after debugging process 
%   is completed
if mod(length(fa),2) ~= 0,
  disp('Odd number!'); return,
else 
  if sum(diff(reshape(fa,2,length(fa)/2))) > 0,
  disp('Odd number!'); return, end, end;
%!!!!!!!!

%Combine face coord. with indices of edges that belong to the faces
  cf = [fa(1:2:end) reshape(cf(ia,1),2,length(fa)/2)' ...
        cf(ia(1:2:end),2:5)];

%Find cubes containing selected faces
  i1 = find(cf(:,7)==1); i2 = find(cf(:,7)==2); i3 = find(cf(:,7)==3);
  cc = repmat(cf(:,2:6),1,2);
  ftoc = [zeros(3,7) [0 0 -1;0 -1 0;-1 0 0]];
  cc = cc + [repmat(ftoc(1,:),length(i1),1);...
   repmat(ftoc(2,:),length(i2),1);repmat(ftoc(3,:),length(i3),1)];
  cc = reshape(cc',5,size(cf,1)*2);
  cc(:,find(prod(cc) == 0 | cc(4,:) > nv(1)-1 | cc(3,:) > nv(2)-1 |...
            cc(5,:) > nv(3)-1)) = [];  cc = cc';

  cu = cc(:,4) + ((cc(:,3)-1) + (cc(:,5)-1)*(nv(2)-1))*(nv(1)-1);
  [cu ic] = sort(cu); 
%Combine indices of selected cubes with indices of edges that belong
%   to them into a cube-edge index array
  cc = [cu cc(ic,1:2)];

%Combine edges into triplets composing surface patches
  ip = [];   cc = sortrows(cc);
  while 1,
%Indices of patches
    ic = find(diff([0;cc(:,1);0]) ~= 0);
%Indices of triangular patches
    ic3 = ic(find(diff(ic) == 3));
%Indices of patches with more than 3 vertices
    icm = ic(find(diff(ic) > 3));   
    
%Select triangular patches and take them out of the cube-edge array
    ic(end) = [];   ip = [ip [cc(ic,2:3)';cc(ic+1,3)']];
    if ~isempty(ic3),
      irm = repmat(ic3,1,3) + repmat(0:2,length(ic3),1);
    else irm = []; end,
    irm = [irm(:);icm];   cc(icm+1,2) = cc(icm,3);   cc(irm,:) = [];

%Sort new cube-edge index array or quit if it is empty
    if ~isempty(cc),  cc = sortrows(cc);  else, 
      disp(['Number of patches = ' num2str(size(ip,2))]); 
      break; end

%Find cases when there is more than one patch per cube 
    irm = find(sum(abs(diff(cc)')) == 0);
    if ~isempty(irm),
      %disp(['More than one patch in ' int2str(length(irm)) ' cubes']);
      irm = repmat(irm,2,1)+repmat([0;1],1,length(irm)); irm = irm(:);
      cc(irm,:) = []; end,

  end;  

  Tx = xv(ip);  Ty = yv(ip);  Tz = zv(ip);

%This is to compute area of each patch
%  x2 = Tx(2,:)-Tx(1,:); y2 = Ty(2,:)-Ty(1,:); z2 = Tz(2,:)-Tz(1,:); 
%  x3 = Tx(3,:)-Tx(1,:); y3 = Ty(3,:)-Ty(1,:); z3 = Tz(3,:)-Tz(1,:);
%A=sqrt((x2.*y3-x3.*y2).^2+(y2.*z3-y3.*z2).^2+(z2.*x3-z3.*x2).^2)./2; 

  if nargout < 3,
    C = sqrt(Tx.^2 + Ty.^2 + Tz.^2);  clf; 
    H = fill3(Tx,Ty,Tz,C);  axis image; %shading interp; light;
    set(gca,'xlim',[x(1) x(end)],'ylim',[y(1) y(end)],...
      'zlim',[z(1) z(end)],'box','on'); view(35,20);  
    Tx = H;  
  end
  if nargout == 0, clear Tx, end
