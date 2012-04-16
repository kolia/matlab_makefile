function [R,context] = iterate_contexts(targs , context_fields , context_filter , varargin)

if nargin<3
    context_filter = @(c)1;
end

context = initialize_context() ;

if nargin>1
    for i=1:size(context_fields,1)
        context.(context_fields{i,1}) = context_fields{i,2} ;
    end
end

rand('twister', sum(100*clock));  % reset rand seed

if ~isfield(context,'R')
    context.R = cell(25+40,6) ;
end

if ~isa(targs,'cell')
    targs = {targs} ;
end

PastTypes = {'stim_isi' 'stim'} ;

for pt=1:length(PastTypes)
   
for e=1:2 %:-1:1
    if e == 1
        RunOrder = 1 ;
        CellNums = load_result('../DATA/Experiment_1/CellNums') ;
    elseif e == 2
        RunOrder  = [5 6 4 3] ; % randperm(6)
        CellNums = load_result('../DATA/Experiment_2/CellNums') ;
    end
    CellOrder = CellNums ; % CellNums(randperm(length(CellNums))) ;
for r=RunOrder
    for c=CellOrder
        ec = (e-1)*40+c ;
%         R{ec,r} = struct ;
        
        context.ExperimentNum = e ;
        context.CellNum  = c  ;
        context.RunNum   = r  ;
        context.PastType = PastTypes{pt} ;
        context.STORE    = [] ;
  
        if context_filter(context,varargin{:})
            
            if strcmp(context.MODE,'MAKE')
                fprintf('\n\n-------------------   Experiment %d   Cell %d   Run %d   %s -------------------\n\n',...
                    context.ExperimentNum , context.CellNum, context.RunNum,context.PastType)
            end
            
            for i=1:length(targs)
                targ = [':' targs{i}] ;
                [result,context] = make_target( targ , context) ;
                if makefile_syntax(targ,'target_pattern')
                    new_fields = fieldnames(result) ;
                    for j=1:length(new_fields)
                        context.R{ec,r}.(new_fields{j}) = result.(new_fields{j}) ;
                    end
                elseif makefile_syntax(targ,'target')
                    context.R{ec,r}.(targ(2:end)) = result ;
                else
                    fprintf('\n\nERROR? iterate_cells_runs should be called with targets or target patterns only!\n\n')
                end
            end
            
        end
    end
end
end
end

R = context.R ;

end