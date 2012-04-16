function context = initialize_context()

targets() ;  % defines  t (structure containing targets) and SAVE_HERE
targetnames = fieldnames(t) ;

targs = {} ;

fprintf('\n============================\nINITIAL CONTEXT:\n')

fprintf('\n============================\nSAVE_HERE:\n')
disp(SAVE_HERE)

fprintf('============================\nTARGETS:\n\n')
for i=1:length(targetnames)
    if isstruct(t.(targetnames{i})) && ~isempty(fieldnames(t.(targetnames{i})))
        info = fieldnames(t.(targetnames{i})) ;
        info = info{1} ;
        target_action = t.(targetnames{i}).(info) ;
    else
        info = [] ;
        target_action = t.(targetnames{i}) ;
    end
    
    new_targets = expand_target(targs ,  target_action) ;
    for j=1:size(new_targets,1)
        if ~isempty(new_targets{j}.TEMP)
            target_string = [targetnames{i} '_' new_targets{j}.TEMP] ;
        else
            target_string =  targetnames{i} ;
        end
        targs.(target_string) = rmfield(new_targets{j},'TEMP') ;
        targs.(target_string).TARGET_STRING = target_string ;
        targs.(target_string).PERSISTENCE = info ;
        targs.(target_string).ACTION = targs.(target_string).ACTION{1} ;
        
        fprintf('%s :\n',target_string)
        disp(targs.(target_string).ACTION)
    end
end

context.TARGETS = targs ;
context.SAVE_HERE = SAVE_HERE ;
context.STORE = [] ;
context.MODE = 'MAKE' ;   % default

% fprintf('\nin get_target: target_string = %s\n',target_string)
% target = match_target(target_cell , target_string) ;

end

function expanded = expand_target(targets , target)

if makefile_syntax(target,'target_pattern')
    [targs , complements] = match_pattern(fieldnames(targets),target(2:end-1)) ;
    expanded = cell(size(targs,1),1) ;
    for i=1:size(targs,1)
        expanded{i}.ACTION = {targs{i}} ;
        expanded{i}.TEMP   = complements{i} ;
    end
elseif makefile_syntax(target,'target_action')
    expanded = {} ;
    for i=1:length(target)
        next = expand_target(targets,target{i}) ;
        expanded = merge_targets(expanded,next) ;
    end
    for i=1:size(expanded,1)
        expanded{i}.ACTION = {expanded{i}.ACTION} ;
    end
else
    expanded{1}.ACTION = {target} ;
    expanded{1}.TEMP = '' ;
end

% fprintf('\n\n++++++++++  expanded +++++++++\n')
% expanded

end

function merged = merge_targets(expanded,next)

% fprintf('\n\n+++++ merging ++++++\n')
% expanded
% if ~isempty(expanded)
%     expanded{1}
% end
% next
% if ~isempty(next)
%     next{1}
% end

if isempty(expanded)
    merged = next ;
elseif isempty(next)
    merged = expanded ;
else
    N = size(expanded , 1) ;
    M = size(next     , 1) ;
    merged = cell(N*M,1) ;
    for i=1:N
        for j=1:M
            ij = (i-1)*M + j ;
            merged{ij}.TEMP = '' ;
            if isfield(expanded{i},'TEMP') && ~isempty(expanded{i}.TEMP)
                if isfield(next{j},'TEMP') && ~isempty(    next{j}.TEMP)
%                     fprintf('\n=== MERGING TEMPS ===')
%                     expanded{i}.TEMP
%                     next{j}.TEMP
                    if expanded{i}.TEMP(1) ~= '_'
                        merged{ij}.TEMP = ['_' expanded{i}.TEMP] ;
                    else
                        merged{ij}.TEMP = expanded{i}.TEMP ;
                    end
                    merged{ij}.TEMP = [merged{ij}.TEMP '_' next{j}.TEMP] ;
%                     merged{ij}.TEMP
                else
                    merged{ij}.TEMP = expanded{i}.TEMP ;
                end
            elseif isfield(next{j},'TEMP')
                merged{ij}.TEMP = next{j}.TEMP ;
            end

%             expanded{i}
%             expanded{i}.ACTION
            n = size(expanded{i}.ACTION ,2) ;
            m = size(    next{j}.ACTION ,2) ;
            merged{ij}.ACTION = cell(1,n+m) ;
            for k=1:n
                merged{ij}.ACTION{k}   = expanded{i}.ACTION{k} ;
            end
            for k=1:m
                merged{ij}.ACTION{n+k} = next{j}.ACTION{k} ;
            end
        end
    end
end

% merged
% if ~isempty(merged)
%     merged{1}
% end


end