function [ new_vector ] = find_new_vector( vector,step,minus_or_plus )
% Function that returns a new y for compiling multiple standard deviations
% into one pixel. Using y_step to find size of area to compile.
% array [new_y ] = find_new_y( array y, int y_step, string "+" or "-")
vector = cell2mat(vector);
new_vector = zeros(1,length(vector));

if(contains(minus_or_plus,'-'))
    edge = (vector - step) < 1;
    vector = vector - step;
    vector = vector .* ~edge;
    new_vector = vector + edge;
elseif(contains(minus_or_plus,'+'))
    edge = (vector + step) > length(vector);
    vector = vector + step;
    vector = vector .* ~edge;
    edge = edge * length(vector);
    new_vector = vector + edge;
else
    disp('Error');
end





% This code works but trying to be better.
%{
for i = 1:length(vector)
    % Start with minus
    if(strfind(minus_or_plus,'-'))
        if(vector(i) - step < 1)
            new_vector(i) = 1;
        else
            new_vector(i) = vector(i) - step;
        end
    end
    
    % If plus 
    if(strfind(minus_or_plus,'+'))
        if(vector(i) + step > length(vector))
            new_vector(i) = length(vector);
        else
            new_vector(i) = vector(i) + step;
        end
        
    end
%}

end

