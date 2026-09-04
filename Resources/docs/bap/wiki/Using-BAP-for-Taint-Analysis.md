## Easy way

The easiest way to use the BAP taint engine is to use IDA. In fact even [IDA Free will work][1]. Just point your mouse to a variable (in disassembler view or in a decompilation view) and hit `Shift-A` if you want to taint the value stored in this variable, or `Ctrl-Shift-A` if you want to taint a value to which the value stored in the variable is pointing. The bap-ida-python will assemble all the necessary flags and run bap for you and will display results by highlighting the tainted program terms. 

If you don't want to use IDA you need to pass all options to bap manually, and it could be cumbersome. Fortunately, we have a new mechanism in bap 1.4, called recipes, that can assemble all command-line options along with utility files in one file. But later about this. 


## Running Primus Taint Analysis

Primus is a Microexecution framework that evaluates a program lifted into the BAP Intermediate Representation and provides callbacks that a user could leverage for a different kind of analysis. The [Bap_taint][2] framework provides a generic OCaml interface for taint analysis. It can also be accessed from [Primus Lisp][3]. There are also convenience passes, that can introduce taint for you, for example, the `taint` pass can taint values based on the program terms where they are generated. 

### The simplest example

```
bap ./exe --taint-reg=malloc_result \
       --run \
       --run-entry-points=all-subroutines \
       --primus-limit-max-length=4096 \
       --primus-promiscuous-mode \
       --primus-greedy-scheduler \
       --primus-propagate-taint-from-attributes \
       --primus-propagate-taint-to-attributes \
       --print-bir-attr=tainted-{ptrs,regs} \
       --dump=bir:result.out \
       --report-progress    
```

Of course, with the new recipe system, it could be as easy as `bap ./exe --taint-reg=malloc_result --recipe=propagate-taint`, if you have the propagate-taint recipe available. However, before that, let's look underneath the hood, and try to understand what each option means. All options are explained in detail in the help pages of the corresponding plugins. I.e., to understand the `--taint-reg` option read `bap --help` and find the `reg` option. Nevertheless, let's go through all of them.

The `--taint-reg=malloc_result` option marks each term that has this variable as a term that produces tainted values. So every time we evaluate the return argument of a call to malloc, we taint the value. 

The `---run` option will run Primus. 

The `--run-entry-points=all-subroutines` will specify the set of entry points for Primus, let's run each function from start.

The `--primus-limit-max-length=4096` limits the maximum length of each path to 4096 RTL instructions, this will ensure that the analysis terminates, while we may miss some dependencies.

The `--primus-promiscuous-mode` enables the promiscuous execution mode for Primus, in which the interpreter will ignore segmentation faults and branch conditions.

The `--primus-greedy-scheduler` chooses the scheduling strategy, that will evaluate paths in a greedy manner.

The `--primus-propagate-taint-from-attributes` propagates the taint attributes that were set up by the taint plugin to the taint introduction operations [taint-introduce-directly][5] and [taint-introduce-indirectly][6]. 

The ` --primus-propagate-taint-to-attributes` does the opposite, it propagates taints to term attributes. 

The `--print-bir-attr=tainted-{ptrs,regs}` tells the printer to output the taint attributes. 

Finally, the `--dump=bir:result.out`  tells to output the IR to the `result.out`.

The `--report-progress` is here just to make you occupied while you're are waiting for the analysis to finish.

### Analyzing results

The IR in the result.out will be annotated with  the `tainted-regs` and `tainted-ptrs` attributes which are dictionaries from variables to taint identifiers. For example,

```
000001a7: 
.tainted-regs {R0 => [0000019d]}
000003aa: memmove_result := R0
```

Tells us that the `R0` variable that is assigned to `memmove_result` is tainted with the `000019d` taint. And the 0000019d is a term identifier of a term that was responsible for introducing taint:
```
$ grep 0000019d: result.out 
0000019d: call @malloc with return %0000019e
```

### Real World Analysis

Of course, greping the IR dump is hardly the best way of analyzing the results of taint analysis. The real-world analysis would be either written in OCaml, as [Saluki][7] (see also the [paper][8 or in Primus Lisp, like [Check value][10] the modern reimplementation of Saluki (part of it). Here is how the [check-value][11] is used to check that the values of some functions are checked. Those analyses could be run using the `--primus-lisp-load` option.


### Using Recipes

Of course, this is quite a few options, and it is easier to manage them via the recipe system. I've packed the simple example in a [recipe](https://mirrors.aegis.cylab.cmu.edu/bap/recipes/propagate-taint.recipe) for you, so you can get it:

```
wget https://mirrors.aegis.cylab.cmu.edu/bap/recipes/propagate-taint.recipe
```

and now running taint analysis is much easier

```
bap ./exe --recipe=propagate-taint --taint-reg=malloc_result
```

A recipe is a simple `zip` file and you can use Emacs to edit it directly. Beware, this is a new feature, and there are still some lurking bugs as well as the lack of documentation. So don't hesitate to ask. You can use our [gitter for the immediate help][12]

[1]: https://github.com/BinaryAnalysisPlatform/bap-ida-python/blob/master/docs/IDAPython_on_IDADemo.md

[2]: https://binaryanalysisplatform.github.io/bap/api/master/bap-taint/Bap_taint/Std/index.html

[3]: https://binaryanalysisplatform.github.io/bap/api/lisp/#sec-7-89
[4]: https://binaryanalysisplatform.github.io/bap/api/man1/bap-plugin-taint.1.html

[5]: https://binaryanalysisplatform.github.io/bap/api/lisp/#sec-7-89
[6]: https://binaryanalysisplatform.github.io/bap/api/lisp/#sec-7-90
[7]: https://github.com/BinaryAnalysisPlatform/bap-plugins/tree/master/saluki
[8]: https://github.com/BinaryAnalysisPlatform/bap-plugins/blob/master/saluki/paper.pdf
[10]: https://github.com/BinaryAnalysisPlatform/bap/blob/master/plugins/primus_test/lisp/check-value.lisp
[11]: https://github.com/BinaryAnalysisPlatform/bap/blob/master/plugins/primus_test/lisp/warn-unused.lisp

[12]: https://gitter.im/BinaryAnalysisPlatform/bap