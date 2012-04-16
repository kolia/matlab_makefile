function [result,context] = make_target(target,context)

global indentation

here = pwd ;

if makefile_syntax(target,'target_action')
    
    nargs = length(target)-1 ;
    args  = cell(nargs,1) ;
    ARG_STRING = '' ;
    for a=1:nargs
        args{a} = make_target(target{a+1},context) ;
        ARG_STRING = sprintf('%s,args{%d}',ARG_STRING,a) ;
    end
%     fprintf('\nevaluating %s(%s) ;\n',func2str(target{1}),ARG_STRING(2:end))
    result = eval(sprintf('%s(%s) ;',func2str(target{1}),ARG_STRING(2:end))) ;
    if strcmp(func2str(target{1}),'load')
        fields = fieldnames(result) ;
        result = result.(fields{1}) ;
    end
    
elseif makefile_syntax(target,'target_pattern')

%     fprintf('\n+++ make_target  pattern = %s\n',target)
    
    targets = match_pattern(fieldnames(context.TARGETS) , target(2:end-1)) ;
    
    n = size(targets,1) ;
    for i=1:n
        [r,context] = make_target(targets{i},context) ;
        result.(targets{i}(2:end)) = r ;
    end
    
elseif makefile_syntax(target,'target')
    target_string = target(2:end) ;
    fprintf('\n%smaking %s:\n', indentation,target_string)
    context.CURRENT_TARGET_FILENAME = make_target_filename(context,target_string) ;
    found_result = 0 ;
    if isfield(context.STORE,target_string)
        result = context.STORE.(target_string) ;
        found_result = 1 ;
    elseif isfield(context,target_string)
        result = context.(target_string) ;
        found_result = 1 ;
    end
    if found_result
        fprintf('%s.   %s retrieved from context\n',indentation,target_string)
        return
    end
    
    t = context.TARGETS.(target_string) ;
    
    %     fprintf('\n==> make_target  target = %s\n',t.TARGET_STRING)
    
    if strcmp(t.PERSISTENCE,'SAVE') || strcmp(t.PERSISTENCE,'FIX')
        try 
            if strcmp(t.PERSISTENCE,'FIX')
                fprintf('%s    trying to load %s\n',indentation,context.CURRENT_TARGET_FILENAME)
            end
            result = load(context.CURRENT_TARGET_FILENAME) ;
            fields = fieldnames(result) ;
            result = result.(fields{1}) ;
            fprintf('%s-   loaded %s\n',indentation,context.CURRENT_TARGET_FILENAME)
            if ~strcmp(t.PERSISTENCE,'FIX')
                return
            else
                fprintf('loaded target to be FIXED ...\n')
                context.FIX_ME = result ;
            end
        catch ME , ME.stack ;
            if strcmp(t.PERSISTENCE,'FIX')
                fprintf('%sNOTHING TO BE FIXED\n',indentation)
                result = 'NOTHING TO FIX' ;
                return
            elseif ~strcmp(context.MODE,'MAKE') % if not making, ignore long calculations.
                result = [] ;
                return
            end
            fprintf('%s-   could not load %s\n',indentation,context.CURRENT_TARGET_FILENAME)
        end
    end
    if ~exist('indentation','var') , indentation = '' ; end
    
%     fprintf('\n%smaking %s:\n', indentation,t.TARGET_STRING)
    
    %         filename = make_target_filename(context,target_string)
    %         try result = load(filename) ;
    %             fields = fieldnames(result) ;
    %             result = result.(fields{1}) ;
    %             fprintf('%s-   loaded %s\n\n',indentation,filename)
    %         catch ME , ME.stack ;
    
    indentation = [indentation '    '] ;
    [result , context] = make_target(t.ACTION,context) ;
    indentation = indentation(1:end-4) ;
    
    if strcmp(t.PERSISTENCE,'SAVE') || strcmp(t.PERSISTENCE,'FIX')
        mkdir(context.CURRENT_TARGET_FILENAME)
        rmdir(context.CURRENT_TARGET_FILENAME)
        save( context.CURRENT_TARGET_FILENAME, 'result')
        fprintf('\n%s+   saved %s\n',indentation,context.CURRENT_TARGET_FILENAME)
%     elseif strcmp(t.PERSISTENCE,'PLOT')
%         mkdir(context.CURRENT_TARGET_FILENAME)
%         rmdir(context.CURRENT_TARGET_FILENAME)
%         hg_recursive_save(result) ;
    else
        context.STORE.(t.TARGET_STRING) = result ;
        fprintf('\n%s+   context now includes %s\n',indentation,t.TARGET_STRING)
    end
elseif makefile_syntax(target,'target_filename')
    result = context.CURRENT_TARGET_FILENAME ;
elseif makefile_syntax(target,'fix_me')
    result = context.FIX_ME ;
else
    result = target ;
end

cd(here)
end