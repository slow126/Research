function Iout = merode(varargin)
%   mErode Perform erosion on binary(2) or gray(256) image.
%   newI = merode(Image,Se,Ap,Method) performs erosion on the image
%   Image, using the binary structuring element Se.  Se is a matrix
%   containing only 1's and 0's. Ap is the active point in the Se  
%   Matrix, which define the point to erode. Method is a string that
%   can have one of these values:
%
%     'binary' -  processes the binary image 
%     'gray'   -  processes the gray image 
%
%   Notes: Be sure to select the right colormap to display the image
%
%   Example:
%    ============================
%    mI   = imread('test.tif');
%    mSe  = ones(3,2);
%    mAp  = [2,2];
%    newI = merode(mI,mSe,mAp,'gray');
%    figure;
%    subplot(2,1,1),imshow(mI);
%    subplot(2,1,2),imshow(newI);
%
%    ============================
%
%   See also mdilate.
%
%   Yali Wei, 26-Jan-1998
%   EE 619, Computer Vision, Dr. Aly.A Farag, Spring, 1998
%   This is a freeware :-)


Image=varargin{1};
Se=varargin{2};
Ap=varargin{3};
Method=varargin{4};


Isize=size(Image);
Iout=zeros(size(Image));
tmpSize=size(Se);


mCase=0;
if (strcmp(Method,'gray')) mCase=1; end;
if (strcmp(Method,'binary')) mCase=2; end;


switch mCase


case 0
 error('Wrong method for MERODE');


case 1
%gray image erosion
mImax=max(max(Image));


for i=1:Isize(1,1)
 for j=1:Isize(1,2)


    tmpM=zeros(size(Se));
    for m=1:tmpSize(1,1)
     for n=1:tmpSize(1,2)


       tmp1=i-Ap(1,1)+m;
       tmp2=j-Ap(1,2)+n;


       if(tmp1>0 & tmp2>0 & tmp1<=Isize(1,1) & tmp2<=Isize(1,2))
         tmpM(m,n)=Image(tmp1,tmp2)-Se(m,n);
       else
         tmpM(m,n)=mImax;
       end
     end
    end
    Iout(i,j)=min(min(tmpM));
 end
end


case 2
% binary image dilation


Iout=Image;
for i=1:Isize(1,1)
 for j=1:Isize(1,2)
  if(Image(i,j)>0)
    Image(i,j)=1;
  end
 end
end


for i=1:Isize(1,1)
 for j=1:Isize(1,2)


  if(Image(i,j)>0)
    for m=1:tmpSize(1,1)
     for n=1:tmpSize(1,2)
       tmp1=i-Ap(1,1)+m;
       tmp2=j-Ap(1,2)+n;
       if(tmp1>0 & tmp2>0 & tmp1<=Isize(1,1) & tmp2<=Isize(1,2))
         if (Image(tmp1,tmp2)~= Se(m, n))
            Iout(i, j)=0;
         end
       elseif(tmp1>Isize(1,1) | tmp2>Isize(1,2))
         Iout(i,j)=0;
       end
     end
    end
  end
 end
end
%for i=1:Isize(1,1)
% for j=1:Isize(1,2)
%    if(Iout(i,j)>1) Iout(i,j)=1; end;
% end
%end


otherwise
    error('Valid method to MERODE is gray and binary');
    
end