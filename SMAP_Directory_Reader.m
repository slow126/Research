directory = dir('/Users/spencerlow/Documents/SMAP/*.h5');

for i = 1:length(directory)
   smap(i).data = SMAPReader(directory(i).name,false);
end