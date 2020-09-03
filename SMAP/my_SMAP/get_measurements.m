function [store, store2, pow, ang, count, ktime, iadd, nrec]  = get_measurements(file_id, NOISY)
while true
    %     store = fread(file_id, 16, 'char');
    
    iadd = fread(file_id, 1, 'int32');
    if length(iadd)<1, break; end;
    count = fread(file_id, 1, 'int32');
    pow = fread(file_id, 1, 'float32');
    azang = fread(file_id, 1, 'float32');
    
    pointer(idx).pt = fread(file_id, count, 'int32');
    aresp1(idx).resp = fread(file_id, count, 'float32');
    
    aresp1(idx).resp = aresp1(idx).resp/sum(aresp1(idx).resp);
    
    % drop zero gain terms
    pointer(idx).pt=pointer(idx).pt(aresp1(idx).resp>0);
    aresp1(idx).resp=aresp1(idx).resp(aresp1(idx).resp>0);
    
    idx = idx + 1;
    ncnt = ncnt + 1;
end



end

