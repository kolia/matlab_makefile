% Kolia's MATLAB TASK MANAGER:
%
% A tool for specifying calculations that depend on other calculations that
% depend on other calculations, etc.
% 
% The system works around a  TARGET  file and the notion of CONTEXT.
%
% - The targets.m TARGET file specifies which targets depend on which,
% what functions should be called to make each target calculation, 
% whether calculated target should be saved to hard disk, and where
% they should be saved. Results that are to be saved on disk are
% not recalculated if the corresponding file can be found.
%
% - The CONTEXT is a structure which serves to distiguish different
% conditions under which a calculation can be done: for different data
% sets, different parameters, etc. The context also serves as a means to
% generate filenames for saved calculations, in folders reflecting the
% context of each calculation.
%
% See 'targets.m' for an example of a TARGET file. Note that the TARGETS file 
% MUST be called 'targets.m'
%
%
%
% The TARGET file should contain:
%
% - SAVE_HERE.ROOT_DIRECTORY: root directory where results are saved (string)
%
% - SAVE_HERE.USING_FOLDERS : N-by-2 cell array specifying in which
%       subdirectory of SAVE_HERE.ROOT_DIRECTORY each result is saved.
%       Each row corresponds to a pair  ( dependency , folder ) where
%       - 'dependency' is a string, the name of a target
%       - 'folder' is a function of the context which returns a string, the
%          folder name corresponding to 'dependency'.
%       An example of SAVE_HERE.USING_FOLDERS with a single dependency
%       could be:
%       SAVE_HERE.USING_FOLDERS = 
%           {'DataSet'  @(context)sprintf('DataSet_%d',context.DataSetNumber)}
%       The result of a calculation which depends on the data set number (42)
%       will be saved in ROOT_DIRECTORY/DataSet_42, whereas the result of a
%       calcuation which does not depend on a data set number will be saved
%       in ROOT_DIRECTORY/.
%
% - t :  a structure containing all targets. Examples:
%       - t.target0.SAVE = { @make_target0 ':target2' 10 ':target4' } ;
%           target0 will be saved to disk. It will be calculated by
%           invoking the function 'make_target0' with 3 arguments: the
%           result of calculating target2, the number 10, and the result
%           of calculating target4.
%       - t.target1 = matlab expression exp1
%           the result target1 is the result of matlab expression exp1. The
%           resut is not saved to disk, but it is saved in memory inside
%           context.STORE
%       The grammar for a target is (in BNF style, using the first rule that
%       matches, as in Parser Expression Grammars):
%
%       <target> = [':' <target>]                         Example: ':target1'
%       <target> = { @make_function (list of <target>s) }
%       <target> = a matlab expression that doesn't match the above 2 rules.
%
%       - ':target1' stands for 'the result of calculating target1'
%       - { @make_function (list of <target>s) } stands for the result of
%       calling 'make_function' with the result of evaluating the list of
%       <target>s as arguments.
%       - Any matlab expression which is not of these two forms stands for
%       itself.
%
%
%
% WHAT IT DOES:
%
%   Evaluating ':target1' starts with the definition t.target1
%
% - If t.target1 is of the form  ':some_other_target', then
%   'some_other_target' is first sought as a field in context. If
%   'some_other_target' it is not a field of the structure 'context', then
%   it is sought as a field in context.STORE, where previous calculations
%   have been stored. If it is not found there and t.target1 has field
%   'SAVE', it is sought in the file system, with filename 'target1.mat' in
%   the folder calculated using SAVE_HERE.ROOT_DIRECTORY and
%   SAVE_HERE.USING_FOLDERS. If 'target1.mat' was not found at that
%   location, then 'some_other_target' is calculated using the rule
%   t.some_other_target
%
% - If t.target1 is of the form { @make_function (list of <target>s) },
%   then each target in the list of arguments is retrieved from context,
%   context.STORE, from saved file, or calculated, and then the function
%   'make_function' is called with those arguments.
