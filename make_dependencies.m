function dependencies = make_dependencies(targets , target_string)

dependencies = struct ;
if makefile_syntax(target_string,'target')
    try
        target = targets.(target_string(2:end)).ACTION ;
        dependencies = make_dependencies(targets,target) ;
    end
    dependencies.(target_string(2:end)) = [] ;
elseif isa(target_string,'cell')
%     fprintf('\ntarget_string is a cell in make_dependencies\n')
%     target_string
    for i=1:length(target_string)
        d = make_dependencies(targets , target_string{i}) ;
        fields = fieldnames(d) ;
        for j=1:length(fields)
            dependencies.(fields{j}) = [] ;
        end
    end
end