function [img] = reshape_img(img, nsx, nsy)
if (nsx ~= 1) && (nsy ~= 1)
    img = reshape(img, [nsx, nsy]);
    img = flipud(img');
else
    img = flipud(img);
    img = img';
    img = reshape(img, 1, []);
end

end

