Our Working Environment

Every piece of code in an example, and every answer to an end-of-chapter question can be downloaded from the book’s website at [`http://www.ocaml-book.com/`](http://www.ocaml-book.com/) and built on the reader’s machine. The programs should work on Unix (including Linux), Mac OS X, and Microsoft Windows.

Since several of our programs require tail-recursive list functions, we provide a wrapper to the Standard Library List module which provides them. In addition, three small utility functions (`take`, `drop`, and `from`) are provided in a Util module. These modules are contained in the module More. So, by writing `open More`, the Util module is available, and all functions in the List module are tail-recursive.

If using OPAM, the OCaml Package Manager, this package may be installed by writing `opam install` `more-ocaml`. Then (or by installing in another manner – see the online resources for details) our modules are available in the top level:

`         OCaml  `  
`  `  
`# #use "topfind";;  `  
`- : unit = ()  `  
`Findlib has been successfully loaded. Additional directives:  `  
`  #require "package";;      to load a package  `  
`  #list;;                   to list the available packages  `  
`  #camlp4o;;                to load camlp4 (standard syntax)  `  
`  #camlp4r;;                to load camlp4 (revised syntax)  `  
`  #predicates "p,q,...";;   to set these predicates  `  
`  Topfind.reset();;         to force that packages will be reloaded  `  
`  #thread;;                 to enable threads  `  
`  `  
`- : unit = ()  `  
`# #require "more";;  `  
`/Users/john/.opam/4.02.0/lib/ocaml/more.cma: loaded  `  
`/Users/john/.opam/4.02.0/lib/more: added to search path  `  
`# open More;;  `  
`# Util.take;;  `  
`- : 'a list -> int -> 'a list = <fun> `

They are also available when compiling stand-alone programs with the bytecode compiler `ocamlc `or the native code compiler `ocamlopt`:

` ocamlfind ocamlc -package more program.ml -linkpkg -o program  `  
`ocamlfind ocamlopt -package more program.ml -linkpkg -o program `

Further instructions, including for use on platforms where OPAM is not supported, are given in the online resources.

Timing with the Unix module

Sometimes we will wish to see how much time a piece of code takes. This can be achieved using the function `gettimeofday `from the Unix module (contrary to its name, this module also works on Windows). This function returns a floating-point number representing the time since 00:00:00 GMT, Jan. 1, 1970, in seconds:

`         OCaml  `  
`  `  
`# #use "topfind";;  `  
`- : unit = ()  `  
`Findlib has been successfully loaded. Additional directives:  `  
`  #require "package";;      to load a package  `  
`  #list;;                   to list the available packages  `  
`  #camlp4o;;                to load camlp4 (standard syntax)  `  
`  #camlp4r;;                to load camlp4 (revised syntax)  `  
`  #predicates "p,q,...";;   to set these predicates  `  
`  Topfind.reset();;         to force that packages will be reloaded  `  
`  #thread;;                 to enable threads  `  
`  `  
`- : unit = ()  `  
`# #require "unix";;  `  
`/Users/john/.opam/4.01.0/lib/ocaml/unix.cma: loaded  `  
`# Unix.gettimeofday ();;  `  
`- : float = 1407679005.43897  `  
`# Unix.gettimeofday ();;  `  
`- : float = 1407679011.08860302 `

Now, by evaluating `Unix.gettimeofday ()`, running a piece of code, and evaluating `Unix.gettimeofday ()` once more, we can calculate the elapsed time. To use the Unix module when compiling stand-alone programs:

` ocamlfind ocamlc -package more,unix program.ml -linkpkg -o program  `  
`ocamlfind ocamlopt -package more,unix program.ml -linkpkg -o program `