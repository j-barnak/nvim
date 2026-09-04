# Description
The graphs show the current quality of BAP lifting and disassembling facilities. Each architecture is represented with 
five kinds of graphs:
- summary
- error structure
- instructions
- binary/library ratio
- stats

A *summary* graph shows a percentage of successfully disassembled and lifted instructions over all tests. A *structure of the error* is shown in the next chart. We distinguish between three kinds of errors. A semantic soundness error occurs when an instruction was lifted incorrectly. A semantic completeness error designates that our lifters do not support this instruction. Finally, a disassembler error happens when the backend is unable to decode the provided chunk of code. The latter error shows a quality of the disassembler backend (LLVM in our case). An *instructions* graph shows total numbers and is helpful to get a grasp of how much data were processed during the experiment. A binary/library ratio graph shows how much time we spent in a library vs a binary in each experiment. And the last graph shows some descriptive statistics computed for each tested binary. Other than soundness and completeness error probabilities, that are described above, it also shows a likelihood of false negative error, that describes how much code our disassembler misses during the control flow graph reconstruction. 

------

## Results for `arm`, obtained from binaries passed to `qemu` tracer 
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/arm_3.8_qemu/summary.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/arm_3.8_qemu/errors-structure.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/arm_3.8_qemu/total-numbers.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/arm_3.8_qemu/bin-lib-ratio.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/arm_3.8_qemu/stats.png]]

------

## Results for `x86-64`, obtained from binaries built with `gcc` and passed to `pin` tracer 
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_gcc/summary.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_gcc/errors-structure.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_gcc/total-numbers.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_gcc/bin-lib-ratio.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_gcc/stats.png]]

------

## Results for `x86-64`, obtained from binaries built with `clang` and passed to `pin` tracer 
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_clang/summary.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_clang/errors-structure.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_clang/total-numbers.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_clang/bin-lib-ratio.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_pin_clang/stats.png]]

------

## Results for `x86-64`, obtained from binaries built with `gcc` and passed to `qemu` tracer  
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_gcc/summary.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_gcc/errors-structure.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_gcc/total-numbers.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_gcc/bin-lib-ratio.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_gcc/stats.png]]

------

## Results for `x86-64`, obtained from binaries built with `clang` and passed to `qemu` tracer 
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_clang/summary.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_clang/errors-structure.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_clang/total-numbers.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_clang/bin-lib-ratio.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86-64_3.8_qemu_clang/stats.png]]

------

## Results for `x86`, obtained from binaries built with `gcc` and passed to `qemu` tracer
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86_3.8_qemu_gcc/summary.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86_3.8_qemu_gcc/errors-structure.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86_3.8_qemu_gcc/total-numbers.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86_3.8_qemu_gcc/bin-lib-ratio.png]]
[[https://github.com/gitoleg/bap-veri/blob/graphs/graph/x86_3.8_qemu_gcc/stats.png]]

------


