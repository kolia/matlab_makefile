function R = gather_targets(context,gather,targs,R)
% Fold over contexts to gather all results for specified targets
% Current usage:
%       gather_targets(context , @(targ) gather_cells_runs(main(targ,'GET')),targets) ;

if nargin<4
    R = struct ;
end


if isa(targs,'cell')
    for i=1:length(targs)
        R = gather_targets(context,gather,targs{i},R) ;
    end
elseif makefile_syntax(targs,'target_pattern')
    R = gather_targets(context,gather, match_pattern(fieldnames(context.TARGETS),targs(2:end-1)) ,R) ;
elseif makefile_syntax(targs,'target')
    fprintf('%s\n',targs)
    targ = targs(2:end) ;
    R.(targ) = gather(targ) ;
else
    fprintf('\nInvalid syntax in gather_targets!\n')
end

end