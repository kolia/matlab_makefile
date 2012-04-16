function [targs , complements] = match_pattern(target_strings , pattern)

% fprintf('\n\n========= MATCHING PATTERN  %s ==========\n',pattern)

n = length(pattern) ;
targs = {} ;
complements = {} ;
for i=1:length(target_strings)
    if length(target_strings{i}) >= n && strcmp(target_strings{i}(1:n) , pattern)
        targs = [targs ;  [':' target_strings{i}]] ;
        complements = [complements ; target_strings{i}(n+1:end)] ;
    end
end

if isempty(targs)
    fprintf('\nWarning: no target found matching    %s*\n',pattern)
end
end