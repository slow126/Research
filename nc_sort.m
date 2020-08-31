directory = '/Users/spencerlow/Documents/src/time_series/*.nc';
char_directory = char(directory);
directory = dir(char_directory);

j = 1;
k = 1;
for i = 1 : length(directory)
    if contains(directory.name(i),'NSIDC')
        rad(j) = directory.name(i);
        j = j + 1;
    elseif contains(directory.name(i),'sir')
        scat(k) = directory.name(i);
        k = k + 1;
    end
end

j = 1;
k = 1;
for i = 1 : length(rad)
    if contains(rad(i),'H')
        rad_H(j) = rad(i);
        j = j + 1;
    elseif contains(rad(i),'V')
        rad_V(k) = rad(i);
        k = k + 1;
    end
end



