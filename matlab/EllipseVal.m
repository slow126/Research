function Y = EllipseVal(X,A,revXY);
%
%   compute Y values corresponding to (arbitrary) conic section
%
%     Input:  X(n) is the array of n values of x
%             A = [a b c d e f]' is the vector of algebraic 
%              parameters of the fitting ellipse or hyperbola:
%              ax^2 + bxy + cy^2 +dx + ey + f = 0
%      (optional) revXY if present and non-zero, reverses X and Y
%     Output: Y(n,2) y values that solve
%             ax^2 + bxy + cy^2 +dx + ey + f = 0
%             Nan is returned for degenerate vales
%

Y=zeros([length(X(:)),2]);
if A(3)==0  % c==0
  Y(:)=NaN;
  return;
end

rev=0;
if exist('revXY') % check for optional variable
  if revXY > 0
    rev=1;
  end
end

% generate quadratic equation for y given x and solve for two
% values of y where aa y^2 + bb Y + cc = 0
if rev  % reverse role of x and y but use standard A definition
  aa=A(1);                          % a
  bb=A(2)*X(:)+A(4);                % bx+d
  cc=A(3)*X(:).^2+A(5)*X(:)+A(6);   % cx^2+ex+f
else
  aa=A(3);                          % c
  bb=A(2)*X(:)+A(5);                % bx+e
  cc=A(1)*X(:).^2+A(4)*X(:)+A(6);   % ax^2+dx+f
end
arg=sqrt(bb.^2-4*aa*cc);
Y(:,1)=(-bb+arg)./(2*aa);
Y(:,2)=(-bb-arg)./(2*aa);

% eliminate invalid Y values
Y(imag(Y)~=0)=NaN;

