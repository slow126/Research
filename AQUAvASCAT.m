dir_sir = 'ASCAT/sirs/*-a-*.sir';
directory = dir(dir_sir);

for i = 1:size(directory,1)
    sig(i).sig = reduce_size_byN(loadsir(directory(i).name),4);
    france_sir(:,:,i) = sig(i).sig(80:130, 1400:1450);
end

dir_tb = 'ASCAT/tb/*12.5*06V*.nc';
directory = dir(dir_tb);

for i = 1:size(directory,1)
    tb(i).tb = universal_nsid(directory(i).name,'rad',true);
    france_tb(:,:,i) = tb(i).tb.TB(1400:1450, 80:130)';
end

france_tb(france_tb < 100) = NaN;
france_sir(france_sir < -12) = NaN;

for i = 1:4
    figure(i)
    plot(make_oneDim(france_sir(:,:,i)), make_oneDim(france_tb(:,:,i)),'.')
end