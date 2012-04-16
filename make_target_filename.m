function filename = make_target_filename(context,target_string)

if ~isfield(context,'SAVE_HERE') || ~isfield(context.SAVE_HERE,'ROOT_DIRECTORY')
    context.SAVE_HERE.ROOT_DIRECTORY = 'RESULTS_SAVED_HERE' ;
    fprintf('\ncontext.SAVE_HERE.ROOT_DIRECTORY not defined. Using ''RESULTS_SAVED_HERE''...\n')
end

if ~isfield(context,'SAVE_HERE') || ~isfield(context.SAVE_HERE,'USING_FOLDERS')
    context.SAVE_HERE.USING_FOLDERS = {} ;
    fprintf('\ncontext.SAVE_HERE.USING_FOLDERS not defined: no subfolders will be created.\n')
end

filename = context.SAVE_HERE.ROOT_DIRECTORY ;

N_deps = size(context.SAVE_HERE.USING_FOLDERS,1) ;
if N_deps>0
    dependencies = make_dependencies(context.TARGETS,[':' target_string]) ;
    for i=1:N_deps
        if isfield(dependencies,context.SAVE_HERE.USING_FOLDERS{i,1})
            filename = sprintf('%s/%s',filename,context.SAVE_HERE.USING_FOLDERS{i,2}(context)) ;
        end
    end
    if makefile_syntax(target_string,'target')
        file = target_string(2:end) ;
    else
        file = target_string ;
    end
    filename = sprintf('%s/%s',filename , file) ;
end
end