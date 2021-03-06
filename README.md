kolia's matlab_makefile
---------------------------

A tool for specifying calculations that depend on other calculations that
depend on other calculations...

matlab_makefile uses a `target.m` file and a `context` matlab structure.

- The `targets.m` file specifies which targets depend on which, what
functions should be called to build each target, whether the built
target should be saved to disk, and how to calculate the paths where
results should be saved. Targets are not rebuilt if they can be loaded
from disk.

- `context` is a matlab structure which contains contextual
information: which data set is being used, with which parameters, etc.
Information in `context` is also used to calculate file and folder names
where results will be stored.

See `examples/targets.m` for an example of a target file. Note that
the target file MUST be called `targets.m`

Informally, the grammar for a target is:

     <target> = [':' <target>]                      Example: :target1

     <target> = { @make_function (list of <target>s) }

     <target> = a matlab expression that doesn't match the above 2 rules

- `:target1` stands for 'the result of calculating target1'
      
- `{ @make_function (list of <target>s) }` stands for the result of
   calling `make_function` with the results from evaluating the list of
   targets as arguments.
 
- Any matlab expression which is not of these two forms stands for
      itself.

usage
-----

1. write a `targets.m` file.  see next section and `example/targets.m`

2. `context = initialize_context() ;`

3. add whatever contextual information you like as additional fields in `context`

4. `[result,context] = make_target('my_targets_*', context) ;`

this will build all targets in `targets.m` that match pattern
`'my_targets_*'`, using the additional info in `context`


target.m should contain
-----------------------

- `SAVE_HERE.ROOT_DIRECTORY`: root directory where results are saved (string)

- `SAVE_HERE.USING_FOLDERS`: N-by-2 cell array specifying in which
      subdirectory of `SAVE_HERE.ROOT_DIRECTORY` each result is saved.
      Each row corresponds to a pair  ( dependency , folder ) where
      - `dependency` is a string, the name of a target
      - `folder` is a function of the context which returns a string, the
         folder name corresponding to `dependency`.
      An example of `SAVE_HERE.USING_FOLDERS` with a single dependency
      could be:
      `SAVE_HERE.USING_FOLDERS = 
          {'DataSet'  @(context)sprintf('DataSet_%d',context.DataSetNumber)}`
      The result of a calculation which depends on the data set number (42)
      will be saved in `ROOT_DIRECTORY/DataSet_42`, whereas the result of a
      calcuation which does not depend on a data set number will be saved
      in `ROOT_DIRECTORY/`.

- `t` :  a structure containing all targets. Examples:
      - `t.target0.SAVE = { @make_target0 ':target2' 10 ':target4' } ;`
          Here, `target0` will be saved to disk because it has the field 
		  `.SAVE`. It will be built by
          calling the function `make_target0` with 3 arguments: the
          result of building `target2`, the number 10, and the result
          of building `target4`.
      - `t.target1 = matlab expression exp1`
          the result target1 is the result of matlab expression exp1. The
          result is not saved to disk, but it is saved in memory inside
          context.STORE



what it does
------------

  Evaluating `:target1` starts with the definition `t.target1`, which can 
  take two froms:

- `t.target1 = :some_other_target`

    `some_other_target` is first sought as `context.some_other_target.` 
    If `some_other_target` it is not a field of `context`
    it is sought as `context.STORE.some_other_target`, where previous builds
    have been stored. If it is not found there and `t.target1` has field
    `.SAVE` it is sought on disk with filename `target1.mat` in
    the folder calculated using `context` with `SAVE_HERE.ROOT_DIRECTORY` and
    `SAVE_HERE.USING_FOLDERS.` If `target1.mat` was not found at that
    location, then `some_other_target` is calculated using the rule
    `t.some_other_target.`

- `t.target1 = { @make_function (list of <target>s) }`

    each target in the list of arguments is retrieved from `context`,
    `context.STORE`, from disk, or rebuilt (as above), and then
    `make_function` is called with these as arguments.
