function bool = makefile_syntax(target,type)

switch type
    case 'target_pattern'
        bool = isa(target,'char') && length(target)>1 && target(1) == ':' && target(end) == '*' ;
    case 'target'
        bool = isa(target,'char') && ~isempty(target) && target(1) == ':' ;
    case 'target_action'
        bool = isa(target,'cell') && ~isempty(target) && isa(target{1},'function_handle') ;
    case 'target_filename'
        bool = isa(target,'char') && strcmp(target,'$SELF') ;
    case 'fix_me'
        bool = isa(target,'char') && strcmp(target,'$FIX') ;
    otherwise
        bool = 0 ;
end

end