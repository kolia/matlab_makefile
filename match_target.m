function targs = match_target(targets , target_string)

% matched = 0 ;
if makefile_syntax(target_string,'target_pattern')
    target_strings = match_pattern(fieldnames(targets) , target_string(2:end-1)) ;
    n = size(target_strings,1) ;
    targs = cell(n,1) ;
    for i=1:n
        targs{i} = match_target(targets , target_strings{i}) ;
    end
%     matched = 1 ;
elseif makefile_syntax(target_string,'target') && isfield(targets,target_string(2:end))
    targs = targets.(target_string(2:end)) ;
%     matched = 1 ;
end

% if ~matched
%     targets= {} ;
%     fprintf('\nmatch_target could not match target_string = %s with targets:\n',target_string(2:end))
%     for i=1:size(target_cell,1)
%         fprintf('\n%s',target_cell{i,1})
%     end
% end

end