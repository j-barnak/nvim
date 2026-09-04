## Abstract

This document defines Abstract Data Type representation format.


## Definition

ADT format is used to represent uniformely ADT object across different
languages. It is designed to be a proper subset of many languages,
including Python, Javascript, OCaml and many others. This property
makes this format ideal for languages with `eval` function. The format
of the language is pretty simple (EBNF):

```
adt = constr,  args.
args = "()"
     | "(", arg, { ",", arg } ")".

arg = adt | int | str.

constr = upper, {upper | lower}.
str = "\\\"" ? any ascii char ? "\\\"".
int = ? c-style integer literal ?.
lower = ? lower case ascii ?.
upper = ? upper case ascii ?.
```
