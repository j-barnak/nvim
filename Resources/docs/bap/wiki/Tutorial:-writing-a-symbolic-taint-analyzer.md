This is a small tutorial in which we will write a simple symbolic taint analyzer. Surprisingly, we don't have one in BAP, but it is easy to implement one. The idea of a symbolic taint analyzer is that it will run taint analysis but use the symbolic executor for exploring the binary. We will be able to reuse any existing security policies but at the same time benefit from the precision of the symbolic executor (that will explore only feasible paths).

First of all, we need to define a [system][1] that will run the symbolic taint analyzer. A system is like an executable, which is built from components. We borrow the idea of systems from Common Lisp, [as well as inherit their syntax][2]. A system is defined as a collection of components and other systems. We can query for the available components and systems using `bap primus-components` and `bap primus-systems` commands. We will base our system on`bap:symbolic-executor` and will just add the taint analysis components, we will need only three of them:

```
(defsystem my:symbolic-taint-analyzer
  :description "analyzes taints using symbolic executor"
  :depends-on (bap:symbolic-executor)
  :components (bap:taint-primitives
               bap:taint-signals
               bap:propagate-taint-by-computation))
```

We need to put this in a file that has the `.asd` extension, e.g., `my-systems.asd` and put this file somewhere on the search path of the primus-system plugin. The current working directory will work, but you can add a path using `--primus-systems-add-path` parameter. Note, that the system definition file 

Now, we can run any taint analysis and specify our system using `--run-system=my:symbolic-taint-analyzer`, e.g.,

```
bap ./exe --run \
    --run-system=my:symbolic-taint-analyzer \
    --primus-lisp-load=posix,check-value \
    --primus-print-obs=incident
```

Of course, it is better to use recipes to pack all these options into a simple recipe (see `bap recipe --help`) but let's leave to the next tutorial. 

[1]: https://binaryanalysisplatform.github.io/bap/api/master/bap-primus/Bap_primus/Std/index.html#components-and-systems
[2]: http://cl-cookbook.sourceforge.net/systems.html