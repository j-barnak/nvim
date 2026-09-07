## `B` `ASSEMBLY GENERATION AND CODE EMISSION TABLES`

![](media/a26394c5fd9047c0974071f62d6ff4719089a6da.jpg)

In each chapter where we updated the conversion from TACKY to assembly or the code emission pass, I included tables summarizing those passes. From Chapter 4 on, these tables showed only the changes made in that chapter, not the entire pass. This appendix presents the complete tables summarizing these passes at the end of Part I, Part II, and Part III.

## `Part I`

The first set of tables in this section illustrates how your compiler should convert every TACKY construct to assembly at the end of Part I. The second set of tables illustrates how your compiler should emit every assembly construct at the end of Part I.

### `Converting TACKY to Assembly`

Tables B-1 through B-5 show the complete conversion from TACKY to assembly at the end of Part I.

`Table B-1:` `Converting Top-Level TACKY Constructs to Assembly`

TACKY top-level construct Assembly top-level construct

```
Program(top_level_defs)
```

```
Program(top_level_defs)
```

```
Function(name, global, params,
         instructions)
```

```
Function(name, global,
         [Mov(Reg(DI), param1),
          Mov(Reg(SI), param2),
          <copy next four parameters from registers>,
          Mov(Stack(16), param7),
          Mov(Stack(24), param8), 
          <copy remaining parameters from stack>] +
         instructions)
```

```
StaticVariable(name, global, init)
```

```
StaticVariable(name, global, init)
```

`Table B-2:` `Converting TACKY Instructions to Assembly`

| `TACKY instruction`                            | `Assembly instructions`                                                                                        |
|------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `Return(val)`                                  | `Mov(val, Reg(AX)) Ret`                                                                                        |
| `Unary(Not, src, dst)`                         | `Cmp(Imm(0), src) Mov(Imm(0), dst) SetCC(E, dst)`                                                              |
| `Unary(unary_operator, src, dst)`              | `Mov(src, dst) Unary(unary_operator, dst)`                                                                     |
| `Binary(Divide, src1, src2, dst)`              | `Mov(src1, Reg(AX)) Cdq Idiv(src2) Mov(Reg(AX), dst)`                                                          |
| `Binary(Remainder, src1, src2, dst)`           | `Mov(src1, Reg(AX)) Cdq Idiv(src2) Mov(Reg(DX), dst)`                                                          |
| `Binary(arithmetic_operator, src1, src2, dst)` | `Mov(src1, dst) Binary(arithmetic_operator, src2, dst)`                                                        |
| `Binary(relational_operator, src1, src2, dst)` | `Cmp(src2, src1) Mov(Imm(0), dst) SetCC(relational_operator, dst)`                                             |
| `Jump(target)`                                 | `Jmp(target)`                                                                                                  |
| `JumpIfZero(condition, target)`                | `Cmp(Imm(0), condition) JmpCC(E, target)`                                                                      |
| `JumpIfNotZero(condition, target)`             | `Cmp(Imm(0), condition) JmpCC(NE, target)`                                                                     |
| `Copy(src, dst)`                               | `Mov(src, dst)`                                                                                                |
| `Label(identifier)`                            | `Label(identifier)`                                                                                            |
| `FunCall(fun_name, args, dst)`                 | \<fix stack alignment\> \<set up arguments\> Call(fun_name) \<deallocate arguments/padding\> Mov(Reg(AX), dst) |

`Table B-3:` `Converting TACKY Arithmetic Operators to Assembly`

| `TACKY operator` | `Assembly operator` |
|------------------|---------------------|
| `Complement`     | `Not`               |
| `Negate`         | `Neg`               |
| `Add`            | `Add`               |
| `Subtract`       | `Sub`               |
| `Multiply`       | `Mult`              |

`Table B-4:` `Converting TACKY Comparisons to Assembly`

| `TACKY comparison` | `Assembly condition code` |
|--------------------|---------------------------|
| `Equal`            | `E`                       |
| `NotEqual`         | `NE`                      |
| `LessThan`         | `L`                       |
| `LessOrEqual`      | `LE`                      |
| `GreaterThan`      | `G`                       |
| `GreaterOrEqual`   | `GE`                      |

`Table B-5:` `Converting TACKY Operands to Assembly`

| `TACKY operand`   | `Assembly operand`   |
|-------------------|----------------------|
| `Constant(int)`   | `Imm(int)`           |
| `Var(identifier)` | `Pseudo(identifier)` |

### `Code Emission`

Tables B-6 through B-10 show the complete code emission pass at the end of Part I.

`Table B-6:` `Formatting Top-Level Assembly Constructs`

Assembly top-level construct Output

```
Program(top_levels)
```

```
Print out each top-level construct. On Linux, add at end of file:
    .section .note.GNU-stack,"",@progbits
```

```
Function(name, global, instructions)
```

```
    <global-directive>
    .text
<name>:
    pushq    %rbp
    movq     %rsp, %rbp 
    <instructions>
```

Initialized to zero

```
StaticVariable(name, global, init)
```

```
    <global-directive>
    .bss
    <alignment-directive>
<name>:
    .zero 4
```

Initialized to nonzero value

```
    <global-directive>
    .data
   <alignment-directive>
<name>:
    .long <init>
```

Global directive

```
If global is true:
.globl <identifier>
Otherwise, omit this directive.
```

Alignment directive Linux only .align 4

macOS or Linux .balign 4

`Table B-7:` `Formatting Assembly Instructions`

Assembly instruction Output

```
Mov(src, dst)
```

```
movl    <src>, <dst>
```

```
Ret
```

```
movq    %rbp, %rsp
popq    %rbp
ret
```

```
Unary(unary_operator, operand)
```

```
<unary_operator>     <operand>
```

```
Binary(binary_operator, src, dst)
```

```
<binary_operator>    <src>, <dst>
```

```
Idiv(operand)
```

```
idivl   <operand>
```

```
Cdq
```

```
cdq
```

```
AllocateStack(int)
```

```
subq    $<int>, %rsp
```

```
DeallocateStack(int)
```

```
addq    $<int>, %rsp
```

```
Push(operand)
```

```
pushq   <operand>
```

```
Call(label)
```

```
call    <label>
or
call    <label>@PLT
```

```
Cmp(operand, operand)
```

```
cmpl    <operand>, <operand>
```

```
Jmp(label)
```

```
jmp     .L<label>
```

```
JmpCC(cond_code, label)
```

```
j<cond_code>      .L<label>
```

```
SetCC(cond_code, operand)
```

```
set<cond_code>    <operand>
```

```
Label(label)
```

```
.L<label>:
```

`Table B-8:` `Instruction Names for Assembly Operators`

| `Assembly operator` | `Instruction name` |
|---------------------|--------------------|
| `Neg`               | `negl`             |
| `Not`               | `notl`             |
| `Add`               | `addl`             |
| `Sub`               | `subl`             |
| `Mult`              | `imull`            |

`Table B-9:` `Instruction Suffixes for Condition Codes`

| `Condition code` | `Instruction suffix` |
|------------------|----------------------|
| `E`              | `e`                  |
| `NE`             | `ne`                 |
| `L`              | `l`                  |
| `LE`             | `le`                 |
| `G`              | `g`                  |
| `GE`             | `ge`                 |

`Table B-10:` `Formatting Assembly Operands`

| `Assembly operand` |          | `Output`              |
|--------------------|----------|-----------------------|
| `Reg(AX)`          | `8-byte` | `%rax`                |
|                    | `4-byte` | `%eax`                |
|                    | `1-byte` | `%al`                 |
| `Reg(DX)`          | `8-byte` | `%rdx`                |
|                    | `4-byte` | `%edx`                |
|                    | `1-byte` | `%dl`                 |
| `Reg(CX)`          | `8-byte` | `%rcx`                |
|                    | `4-byte` | `%ecx`                |
|                    | `1-byte` | `%cl`                 |
| `Reg(DI)`          | `8-byte` | `%rdi`                |
|                    | `4-byte` | `%edi`                |
|                    | `1-byte` | `%dil`                |
| `Reg(SI)`          | `8-byte` | `%rsi`                |
|                    | `4-byte` | `%esi`                |
|                    | `1-byte` | `%sil`                |
| `Reg(R8)`          | `8-byte` | `%r8`                 |
|                    | `4-byte` | `%r8d`                |
|                    | `1-byte` | `%r8b`                |
| `Reg(R9)`          | `8-byte` | `%r9`                 |
|                    | `4-byte` | `%r9d`                |
|                    | `1-byte` | `%r9b`                |
| `Reg(R10)`         | `8-byte` | `%r10`                |
|                    | `4-byte` | `%r10d`               |
|                    | `1-byte` | `%r10b`               |
| `Reg(R11)`         | `8-byte` | `%r11`                |
|                    | `4-byte` | `%r11d`               |
|                    | `1-byte` | `%r11b`               |
| `Stack(int)`       |          | \<int\> (%rbp)        |
| `Imm(int)`         |          | \$ \<int\>            |
| `Data(identifier)` |          | \<identifier\> (%rip) |

## `Part II`

The first set of tables in this section illustrates how your compiler should convert every TACKY construct to assembly at the end of Part II. The second set of tables illustrates how your compiler should emit every assembly construct at the end of Part II.

### `Converting TACKY to Assembly`

Tables B-11 through B-16 show the complete conversion from TACKY to assembly at the end of Part II.

`Table B-11:` `Converting Top-Level TACKY Constructs to Assembly`

TACKY top-level construct Assembly top-level construct

Program(top_level_defs)

```
Program(top_level_defs + <all StaticConstant constructs for
       floating-point constants>)
```

Return value in registers or no return value

```
Function(name,
         global,
         params,
         instructions)
```

```
Function(name, global, 
  [<copy Reg(DI) into first int param/eightbyte>,
   <copy Reg(SI) into second int param/eightbyte>,
   <copy next four int params/eightbytes from registers>,
    Mov(Double,
        Reg(XMM0),
        <first double param/eightbyte>),
```

```
    Mov(Double,
        Reg(XMM1),
        <second double param/eightbyte>),
    <copy next six double params/eightbytes from registers>,
    <copy Memory(BP, 16) into first stack param/eightbyte>,
    <copy Memory(BP, 24) into second stack param/eightbyte>,
    <copy remaining params/eightbytes from stack>] +
  instructions)
```

Return value on stack

```
Function(name, global,
    [Mov(Quadword,
        Reg(DI),
        Memory(BP, -8)),
    <copy Reg(SI) into first int param/eightbyte>,
    <copy Reg(DX) into second int param/eightbyte>,
    <copy next three int params/eightbytes from registers>,
    Mov(Double,
        Reg(XMM0),
        <first double param/eightbyte>),
    Mov(Double,
        Reg(XMM1),
        <second double param/eightbyte>),
    <copy next six double params/eightbytes from registers>,
    <copy Memory(BP, 16) into first stack param/eightbyte>,
    <copy Memory(BP, 24) into second stack param/eightbyte>,
    <copy remaining params/eightbytes from stack>] +
  instructions)
```

```
StaticVariable(name, global, t,
               init_list)
```

```
StaticVariable(name, global, <alignment of t>,
               init_list)
```

```
StaticConstant(name, t, init)
```

```
StaticConstant(name, <alignment of t>, init)
```

`Table B-12:` `Converting TACKY Instructions to Assembly`

TACKY instruction Assembly instructions

Return(val) Return on stack

```
Mov(Quadword, Memory(BP, -8), Reg(AX))
Mov(Quadword,
     <first eightbyte of return value>,
     Memory(AX, 0))
 Mov(Quadword,
     <second eightbyte of return value>,
     Memory(AX, 8))
 <copy rest of return value>
 Ret
```

Return in registers

```
<move integer parts of return value into RAX, RDX>
<move double parts of return value into XMM0, XMM1>
Ret
```

No return value

```
Ret
```

Unary(Not, src, dst) Integer

```
Cmp(<src type>, Imm(0), src)
Mov(<dst type>, Imm(0), dst)
SetCC(E, dst)
```

double

```
Binary(Xor, Double, Reg(<X>), Reg(<X>))
Cmp(Double, src, Reg(<X>))
Mov(<dst type>, Imm(0), dst)
SetCC(E, dst)
```

```
Unary(Negate, src, dst)
(double negation)
```

```
Mov(Double, src, dst)
Binary(Xor, Double, Data(<negative-zero>, 0), dst)
And add a top-level constant:
StaticConstant(<negative-zero>, 16,
                DoubleInit(-0.0))
```

Unary(unary_operator, src, dst)

```
Mov(<src type>, src, dst)
Unary(unary_operator, <src type>, dst)
```

Signed

```
Binary(Divide, src1,
       src2, dst)
(integer division)
```

```
Mov(<src1 type>, src1, Reg(AX))
Cdq(<src1 type>)
Idiv(<src1 type>, src2)
Mov(<src1 type>, Reg(AX), dst)
```

Unsigned

```
Mov(<src1 type>, src1, Reg(AX))
Mov(<src1 type>, Imm(0), Reg(DX))
Div(<src1 type>, src2)
Mov(<src1 type>, Reg(AX), dst)
```

Signed

```
Binary(Remainder, src1,
       src2, dst)
```

```
Mov(<src1 type>, src1, Reg(AX))
Cdq(<src1 type>) 
div(<src1 type>, src2)
Mov(<src1 type>, Reg(DX), dst)
```

Unsigned

```
Mov(<src1 type>, src1, Reg(AX))
Mov(<src1 type>, Imm(0), Reg(DX))
Div(<src1 type>, src2)
Mov(<src1 type>, Reg(DX), dst)
```

```
Binary(arithmetic_operator, src1,
       src2, dst)
```

```
Mov(<src1 type>, src1, dst)
Binary(arithmetic_operator, <src1 type>, src2, dst)
```

```
Binary(relational_operator, src1,
      src2, dst)
```

```
Cmp(<src1 type>, src2, src1)
Mov(<dst type>, Imm(0), dst)
SetCC(relational_operator, dst)
```

Jump(target)

```
Jmp(target)
```

Integer

```
JumpIfZero(condition,
           target)
```

```
Cmp(<condition type>, Imm(0), condition)
JmpCC(E, target)
```

double

```
Binary(Xor, Double, Reg(<X>), Reg(<X>))
Cmp(Double, condition, Reg(<X>))
JmpCC(E, target)
```

Integer

```
JumpIfNotZero(condition,
              target)
```

```
Cmp(<condition type>, Imm(0), condition)
JmpCC(NE, target)
```

double

```
Binary(Xor, Double, Reg(<X>), Reg(<X>))
Cmp(Double, condition, Reg(<X>))
JmpCC(NE, target)
```

Copy(src, dst) Scalar

```
Mov(<src type>, src, dst)
```

Structure

```
Mov(<first chunk type>,
     PseudoMem(src, 0),
     PseudoMem(dst, 0))
Mov(<next chunk type>,
     PseudoMem(src, <first chunk size>),
     PseudoMem(dst, <first chunk size>))
<copy remaining chunks>
```

Load(ptr, dst) Scalar

```
Mov(Quadword, ptr, Reg(<R>))
Mov(<dst type>, Memory(<R>, 0), dst)
```

Structure

```
Mov(Quadword, ptr, Reg(<R>))
Mov(<first chunk type>,
     Memory(<R>, 0),
     PseudoMem(dst, 0))
Mov(<next chunk type>,
     Memory(<R>, <first chunk size>),
     PseudoMem(dst, <first chunk size>))
<copy remaining chunks>
```

Store(src, ptr) Scalar

```
Mov(Quadword, ptr, Reg(<R>))
Mov(<src type>, src, Memory(<R>, 0))
```

Structure

```
Mov(Quadword, ptr, Reg(<R>))
Mov(<first chunk type>,
     PseudoMem(src, 0),
     Memory(<R>, 0))
Mov(<next chunk type>,
     PseudoMem(src, <first chunk size>),
     Memory(<R>, <first chunk size>))
<copy remaining chunks>
```

GetAddress(src, dst)

```
Lea(src, dst)
```

Constant index

```
AddPtr(ptr, index, scale,
        dst)
```

```
Mov(Quadword, ptr, Reg(<R>))
Lea(Memory(<R>, index * scale), dst)
```

Variable index and scale of 1, 2, 4, or 8

```
Mov(Quadword, ptr, Reg(<R1>))
Mov(Quadword, index, Reg(<R2>))
Lea(Indexed(<R1>, <R2>, scale), dst)
```

Variable index and other scale

```
Mov(Quadword, ptr, Reg(<R1>))
Mov(Quadword, index, Reg(<R2>))
Binary(Mult, Quadword, Imm(scale), Reg(<R2>))
Lea(Indexed(<R1>, <R2>, 1), dst)
```

src is scalar

```
CopyToOffset(src, dst,
             offset)
```

```
Mov(<src type>, src, PseudoMem(dst, offset))
```

src is a structure

```
Mov(<first chunk type>,
     PseudoMem(src, 0),
     PseudoMem(dst, offset))
Mov(<next chunk type>,
     PseudoMem(src, <first chunk size>),
     PseudoMem(dst, offset + <first chunk size>))
<copy remaining chunks>
```

dst is scalar

```
CopyFromOffset(src,
               offset,
               dst)
```

```
Mov(<dst type>, PseudoMem(src, offset), dst)
```

dst is a structure

```
Mov(<first chunk type>,
     PseudoMem(src, offset),
     PseudoMem(dst, 0))
Mov(<next chunk type>,
     PseudoMem(src, offset + <first chunk size>),
     PseudoMem(dst, <first chunk size>))
<copy remaining chunks>
```

Label(identifier)

```
Label(identifier)
```

dst will be returned in memory

```
FunCall(fun_name, args,
         dst)
```

```
Lea(dst, Reg(DI))
<fix stack alignment>
<move arguments to general-purpose registers, starting with RSI>
<move arguments to XMM registers>
<push arguments onto the stack>
Call(fun_name)
<deallocate arguments/padding>
```

dst will be returned in registers

```
<fix stack alignment>
<move arguments to general-purpose registers>
<move arguments to XMM registers>
<push arguments onto the stack>
Call(fun_name)
<deallocate arguments/padding>
<move integer parts of return value from RAX, RDX into dst>
<move double parts of return value from XMM0, XMM1 into dst>
```

dst is absent

```
<fix stack alignment>
<move arguments to general-purpose registers>
<move arguments to XMM registers>
<push arguments onto the stack>
Call(fun_name)
<deallocate arguments/padding>
```

ZeroExtend(src, dst)

```
MovZeroExtend(<src type>, <dst type>, src, dst)
```

SignExtend(src, dst)

```
Movsx(<src type>, <dst type>, src, dst)
```

Truncate(src, dst)

```
Mov(<dst type>, src, dst)
```

IntToDouble(src, dst) char or signed char

```
Movsx(Byte, Longword, src, Reg(<R>))
Cvtsi2sd(Longword, Reg(<R>), dst)
```

int or long

```
Cvtsi2sd(<src type>, src, dst)
```

DoubleToInt(src, dst) char or signed char

```
Cvttsd2si(Longword, src, Reg(<R>))
Mov(Byte, Reg(<R>), dst)
```

int or long

```
Cvttsd2si(<dst type>, src, dst)
```

UIntToDouble(src, dst) unsigned char

```
MovZeroExtend(Byte, Longword, src, Reg(<R>))
Cvtsi2sd(Longword, Reg(<R>), dst)
```

unsigned int

```
MovZeroExtend(Longword, Quadword, src, Reg(<R>))
Cvtsi2sd(Quadword, Reg(<R>), dst)
```

unsigned long

```
Cmp(Quadword, Imm(0), src)
JmpCC(L, <label1>)
Cvtsi2sd(Quadword, src, dst)
Jmp(<label2>)
Label(<label1>)
Mov(Quadword, src, Reg(<R1>))
Mov(Quadword, Reg(<R1>), Reg(<R2>))
Unary(Shr, Quadword, Reg(<R2>))
Binary(And, Quadword, Imm(1), Reg(<R1>))
Binary(Or, Quadword, Reg(<R1>), Reg(<R2>))
Cvtsi2sd(Quadword, Reg(<R2>), dst)
Binary(Add, Double, dst, dst) Label(<label2>)
```

DoubleToUInt(src, dst) unsigned char

```
Cvttsd2si(Longword, src, Reg(<R>))
Mov(Byte, Reg(<R>), dst)
```

unsigned int

```
Cvttsd2si(Quadword, src, Reg(<R>))
Mov(Longword, Reg(<R>), dst)
```

unsigned long

```
Cmp(Double, Data(<upper-bound>, 0), src)
JmpCC(AE, <label1>)
Cvttsd2si(Quadword, src, dst)
Jmp(<label2>)
Label(<label1>)
Mov(Double, src, Reg(<X>))
Binary(Sub, Double, Data(<upper-bound>, 0), Reg(<X>))
Cvttsd2si(Quadword, Reg(<X>), dst)
Mov(Quadword, Imm(9223372036854775808), Reg(<R>))
Binary(Add, Quadword, Reg(<R>), dst)
Label(<label2>)
And add a top-level constant:
StaticConstant(<upper-bound>, 8,
                DoubleInit(9223372036854775808.0))
```

`Table B-13:` `Converting TACKY Arithmetic Operators to Assembly`

| `TACKY operator`          | `Assembly operator` |
|---------------------------|---------------------|
| `Complement`              | `Not`               |
| Negate (integer negation) | `Neg`               |
| `Add`                     | `Add`               |
| `Subtract`                | `Sub`               |
| `Multiply`                | `Mult`              |
| Divide ( double division) | `DivDouble`         |

`Table B-14:` `Converting TACKY Comparisons to Assembly`

| `TACKY comparison` |                              | `Assembly condition code` |
|--------------------|------------------------------|---------------------------|
| `Equal`            |                              | `E`                       |
| `NotEqual`         |                              | `NE`                      |
| `LessThan`         | `Signed`                     | `L`                       |
| `LessThan`         | Unsigned, pointer, or double | `B`                       |
| `LessOrEqual`      | `Signed`                     | `LE`                      |
|                    | Unsigned, pointer, or double | `BE`                      |
| `GreaterThan`      | `Signed`                     | `G`                       |
|                    | Unsigned, pointer, or double | `A`                       |
| `GreaterOrEqual`   | `Signed`                     | `GE`                      |
|                    | Unsigned, pointer, or double | `AE`                      |

`Table B-15:` `Converting TACKY Operands to Assembly`

| `TACKY operand`                 |                   | `Assembly operand`                                                                                    |
|---------------------------------|-------------------|-------------------------------------------------------------------------------------------------------|
| `Constant(ConstChar(int))`      |                   | `Imm(int)`                                                                                            |
| `Constant(ConstInt(int))`       |                   | `Imm(int)`                                                                                            |
| `Constant(ConstLong(int))`      |                   | `Imm(int)`                                                                                            |
| `Constant(ConstUChar(int))`     |                   | `Imm(int)`                                                                                            |
| `Constant(ConstUInt(int))`      |                   | `Imm(int)`                                                                                            |
| `Constant(ConstULong(int))`     |                   | `Imm(int)`                                                                                            |
| `Constant(ConstDouble(double))` |                   | Data( \<ident\> , 0) And add a top-level constant: StaticConstant( \<ident\> , 8, DoubleInit(double)) |
| `Var(identifier)`               | `Scalar value`    | `Pseudo(identifier)`                                                                                  |
|                                 | `Aggregate value` | `PseudoMem(identifier, 0)`                                                                            |

`Table B-16:` `Converting Types to Assembly`

| `Source type`           |                                         | `Assembly type`                                                       | `Alignment`                 |
|-------------------------|-----------------------------------------|-----------------------------------------------------------------------|-----------------------------|
| `Char`                  |                                         | `Byte`                                                                | `1`                         |
| `SChar`                 |                                         | `Byte`                                                                | `1`                         |
| `UChar`                 |                                         | `Byte`                                                                | `1`                         |
| `Int`                   |                                         | `Longword`                                                            | `4`                         |
| `UInt`                  |                                         | `Longword`                                                            | `4`                         |
| `Long`                  |                                         | `Quadword`                                                            | `8`                         |
| `ULong`                 |                                         | `Quadword`                                                            | `8`                         |
| `Double`                |                                         | `Double`                                                              | `8`                         |
| `Pointer(referenced_t)` |                                         | `Quadword`                                                            | `8`                         |
| `Array(element, size)`  | `Variables that are 16 bytes or larger` | ByteArray( \<size of element\> \* size, 16)                           | `16`                        |
|                         | `Everything else`                       | ByteArray( \<size of element\> \* size, \<alignment of element\> )    | Same alignment as element   |
| `Structure(tag)`        |                                         | ByteArray( \<size from type table\> , \<alignment from type table\> ) | `Alignment from type table` |

### `Code Emission`

Tables B-17 through B-23 show the complete code emission pass at the end of Part II.

`Table B-17:` `Formatting Top-Level Assembly Constructs`

Assembly top-level construct Output

Program(top_levels)

```
Print out each top-level construct.
On Linux, add at end of file:
     .section .note.GNU-stack,"",@progbits
```

Function(name, global, instructions)

```
    <global-directive>
     .text
 <name>:
     pushq    %rbp
     movq     %rsp, %rbp
     <instructions>
```

Integer initialized to zero, or any variable initialized only with ZeroInit

```
StaticVariable(name, global,
               alignment,
               init_list)
```

```
    <global-directive>
     .bss
     <alignment-directive>
 <name>:
     <init_list>
```

All other variables

```
    <global-directive>
     .data
     <alignment-directive>
 <name>:
     <init_list>
```

Linux

```
StaticConstant(name, alignment,
               init)
```

```
    .section .rodata
     <alignment-directive>
 <name>:
     <init>
```

macOS (8-byte-aligned numeric constants)

```
    .literal8
    .balign 8
 <name>:
     <init>
```

macOS (16-byte-aligned numeric constants)

```
    .literal16
    .balign 16
 <name>:
     <init>
     .quad 0
```

macOS (string constants)

```
    .cstring
 <name>:
     <init>
```

Global directive

```
  If global is true:
 .globl <identifier>
 Otherwise, omit this directive.
```

Alignment directive Linux only

```
.align <alignment>
```

macOS or Linux

```
.balign <alignment>
```

`Table B-18:` `Formatting Static Initializers`

Static initializer Output

CharInit(0) .zero 1

CharInit(i) .byte \<i\>

IntInit(0) .zero 4

IntInit(i) .long \<i\>

LongInit(0) .zero 8

LongInit(i) .quad \<i\>

UCharInit(0) .zero 1

UCharInit(i) .byte \<i\>

UIntInit(0) .zero 4

UIntInit(i) .long \<i\>

ULongInit(0) .zero 8

ULongInit(i) .quad \<i\>

ZeroInit(n) .zero \<n\>

DoubleInit(d)

```
.double <d>
 or
 .quad <d-interpreted-as-long>
```

StringInit(s, True) .asciz " \<s\> "

StringInit(s, False) .ascii " \<s\> "

PointerInit(label) .quad \<label\>

`Table B-19:` `Formatting Assembly Instructions`

Assembly instruction Output

Mov(t, src, dst)

```
mov<t>   <src>, <dst>
```

Movsx(src_t, dst_t, src, dst)

```
movs<src_t><dst_t>    <src>, <dst>
```

MovZeroExtend(src_t, dst_t, src, dst)

```
movz<src_t><dst_t>    <src>, <dst>
```

Lea

```
leaq     <src>, <dst>
```

Cvtsi2sd(t, src, dst)

```
cvtsi2sd<t>     <src>, <dst>
```

Cvttsd2si(t, src, dst)

```
cvttsd2si<t>    <src>, <dst>
```

Ret

```
movq     %rbp, %rsp
popq     %rbp
ret
```

Unary(unary_operator, t, operand)

```
<unary_operator><t>     <operand>
```

Binary(Xor, Double, src, dst)

```
xorpd    <src>, <dst>
```

Binary(Mult, Double, src, dst)

```
mulsd    <src>, <dst>
```

Binary(binary_operator, t, src, dst)

```
<binary_operator><t>    <src>, <dst>
```

Idiv(t, operand)

```
idiv<t>  <operand>
```

Div(t, operand)

```
div<t>   <operand>
```

Cdq(Longword)

```
cdq
```

Cdq(Quadword)

```
cqo
```

Push(operand)

```
pushq    <operand>
```

Call(label)

```
call     <label>
or
call     <label>@PLT
```

Cmp(Double, operand, operand)

```
comisd   <operand>, <operand>
```

Cmp(t, operand, operand)

```
cmp<t>   <operand>, <operand>
```

Jmp(label)

```
jmp      .L<label>
```

JmpCC(cond_code, label)

```
j<cond_code>      .L<label>
```

SetCC(cond_code, operand)

```
set<cond_code>    <operand>
```

Label(label)

```
.L<label>:
```

`Table B-20:` `Instruction Names for Assembly Operators`

| `Assembly operator`                | `Instruction name` |
|------------------------------------|--------------------|
| `Neg`                              | `neg`              |
| `Not`                              | `not`              |
| `Shr`                              | `shr`              |
| `Add`                              | `add`              |
| `Sub`                              | `sub`              |
| Mult (integer multiplication only) | `imul`             |
| `DivDouble`                        | `div`              |
| `And`                              | `and`              |
| `Or`                               | `or`               |
| `Shl`                              | `shl`              |
| `ShrTwoOp`                         | `shr`              |

`Table B-21:` `Instruction Suffixes for Assembly Types`

| `Assembly type` | `Instruction suffix` |
|-----------------|----------------------|
| `Byte`          | `b`                  |
| `Longword`      | `l`                  |
| `Quadword`      | `q`                  |
| `Double`        | `sd`                 |

`Table B-22:` `Instruction Suffixes for Condition Codes`

| `Condition code` | `Instruction suffix` |
|------------------|----------------------|
| `E`              | `e`                  |
| `NE`             | `ne`                 |
| `L`              | `l`                  |
| `LE`             | `le`                 |
| `G`              | `g`                  |
| `GE`             | `ge`                 |
| `A`              | `a`                  |
| `AE`             | `ae`                 |
| `B`              | `b`                  |
| `BE`             | `be`                 |

`Table B-23:` `Formatting Assembly Operands`

Assembly operand Output

Reg(AX) 8-byte %rax

4-byte %eax

1-byte %al

Reg(DX) 8-byte %rdx

4-byte %edx

1-byte %dl

Reg(CX) 8-byte %rcx

4-byte %ecx

1-byte %cl

Reg(DI) 8-byte %rdi

4-byte %edi

1-byte %dil

Reg(SI) 8-byte %rsi

4-byte %esi

1-byte %sil

Reg(R8) 8-byte %r8

4-byte %r8d

1-byte %r8b

Reg(R9) 8-byte %r9

4-byte %r9d

1-byte %r9b

Reg(R10) 8-byte %r10

4-byte %r10d

1-byte %r10b

Reg(R11) 8-byte %r11

4-byte %r11d

1-byte %r11b

Reg(SP) %rsp

Reg(BP) %rbp

Reg(XMM0) %xmm0

Reg(XMM1) %xmm1

Reg(XMM2) %xmm2

Reg(XMM3) %xmm3

Reg(XMM4) %xmm4

Reg(XMM5) %xmm5

Reg(XMM6) %xmm6

Reg(XMM7) %xmm7

Reg(XMM14) %xmm14

Reg(XMM15) %xmm15

Memory(reg, int) \<int\> ( \<reg\> )

Indexed(reg1, reg2, int)

```
(<reg1>,
<reg2>, <int>)
```

Imm(int)

```
$<int>
```

Data(identifier, int)

```
<identifier>
+<int>(%rip)
```

## `Part III`

In Part III, we don’t change the conversion from TACKY to assembly, but we do add some new registers to the assembly AST and update the code emission pass accordingly. How the code emission pass looks at the end of this section depends on whether you completed Part II first or skipped straight from Part I to Part III.

Tables B-24 through B-28 show the complete code emission pass at the end of Part III if you skipped over Part II.

`Table B-24:` `Formatting Top-Level Assembly Constructs`

Assembly top-level construct Output

Program(top_levels)

```
Print out each top-level construct.
On Linux, add at end of file:
     .section .note.GNU-stack,"",@progbits
```

Function(name, global, instructions)

```
     <global-directive>
     .text
 <name>:
     pushq    %rbp
     movq     %rsp, %rbp
     <instructions>
```

StaticVariable(name, global, init) Initialized to zero

```
     <global-directive>
     .bss
     <alignment-directive>
<name>:
     .zero 4
```

Initialized to nonzero value

```
     <global-directive>
     .data
     <alignment-directive>
 <name>:
     .long <init>
```

Global directive

```
 If global is true:
.globl <identifier>
 Otherwise, omit this directive.
```

Alignment directive Linux only

```
.align 4
```

macOS or Linux

```
.balign 4
```

`Table B-25:` `Formatting Assembly Instructions`

Assembly instruction Output

Mov(src, dst)

```
movl     <src>, <dst>
```

Ret

```
movq     %rbp, %rsp
popq     %rbp
ret
```

Unary(unary_operator, operand)

```
<unary_operator>     <operand>
```

Binary(binary_operator, src, dst)

```
<binary_operator>    <src>, <dst>
```

Idiv(operand)

```
idivl    <operand>
```

Cdq

```
cdq
```

AllocateStack(int)

```
subq     $<int>, %rsp
```

DeallocateStack(int)

```
addq     $<int>, %rsp
```

Push(operand)

```
pushq    <operand>
```

Pop(reg)

```
popq     <reg>
```

Call(label)

```
call    <label>
or
call    <label>@PLT
```

Cmp(operand, operand)

```
cmpl    <operand>, <operand>
```

Jmp(label)

```
jmp     .L<label>
```

JmpCC(cond_code, label)

```
j<cond_code>      .L<label>
```

SetCC(cond_code, operand)

```
set<cond_code>    <operand>
```

Label(label)

```
.L<label>:
```

`Table B-26:` `Instruction Names for Assembly Operators`

| `Assembly operator` | `Instruction name` |
|---------------------|--------------------|
| `Neg`               | `negl`             |
| `Not`               | `notl`             |
| `Add`               | `addl`             |
| `Sub`               | `subl`             |
| `Mult`              | `imull`            |

`Table B-27:` `Instruction Suffixes for Condition Codes`

| `Condition code` | `Instruction suffix` |
|------------------|----------------------|
| `E`              | `e`                  |
| `NE`             | `ne`                 |
| `L`              | `l`                  |
| `LE`             | `le`                 |
| `G`              | `g`                  |
| `GE`             | `ge`                 |

`Table B-28:` `Formatting Assembly Operands`

| `Assembly operand` |          | `Output`              |
|--------------------|----------|-----------------------|
| `Reg(AX)`          | `8-byte` | `%rax`                |
|                    | `4-byte` | `%eax`                |
|                    | `1-byte` | `%al`                 |
| `Reg(DX)`          | `8-byte` | `%rdx`                |
|                    | `4-byte` | `%edx`                |
|                    | `1-byte` | `%dl`                 |
| `Reg(CX)`          | `8-byte` | `%rcx`                |
|                    | `4-byte` | `%ecx`                |
|                    | `1-byte` | `%cl`                 |
| `Reg(BX)`          | `8-byte` | `%rbx`                |
|                    | `4-byte` | `%ebx`                |
|                    | `1-byte` | `%bl`                 |
| `Reg(DI)`          | `8-byte` | `%rdi`                |
|                    | `4-byte` | `%edi`                |
|                    | `1-byte` | `%dil`                |
| `Reg(SI)`          | `8-byte` | `%rsi`                |
|                    | `4-byte` | `%esi`                |
|                    | `1-byte` | `%sil`                |
| `Reg(R8)`          | `8-byte` | `%r8`                 |
|                    | `4-byte` | `%r8d`                |
|                    | `1-byte` | `%r8b`                |
| `Reg(R9)`          | `8-byte` | `%r9`                 |
|                    | `4-byte` | `%r9d`                |
|                    | `1-byte` | `%r9b`                |
| `Reg(R10)`         | `8-byte` | `%r10`                |
|                    | `4-byte` | `%r10d`               |
|                    | `1-byte` | `%r10b`               |
| `Reg(R11)`         | `8-byte` | `%r11`                |
|                    | `4-byte` | `%r11d`               |
|                    | `1-byte` | `%r11b`               |
| `Reg(R12)`         | `8-byte` | `%r12`                |
|                    | `4-byte` | `%r12d`               |
|                    | `1-byte` | `%r12b`               |
| `Reg(R13)`         | `8-byte` | `%r13`                |
|                    | `4-byte` | `%r13d`               |
|                    | `1-byte` | `%r13b`               |
| `Reg(R14)`         | `8-byte` | `%r14`                |
|                    | `4-byte` | `%r14d`               |
|                    | `1-byte` | `%r14b`               |
| `Reg(R15)`         | `8-byte` | `%r15`                |
|                    | `4-byte` | `%r15d`               |
|                    | `1-byte` | `%r15b`               |
| `Stack(int)`       |          | \<int\> (%rbp)        |
| `Imm(int)`         |          | \$ \<int\>            |
| `Data(identifier)` |          | \<identifier\> (%rip) |

Tables B-29 through B-35 show the complete code emission pass after completing Parts I, II, and III.

`Table B-29:` `Formatting Top-Level Assembly Constructs`

Assembly top-level construct Output

Program(top_levels)

```
Print out each top-level construct.
On Linux, add at end of file: 
    .section .note.GNU-stack,"",@progbits
```

Function(name, global, instructions)

```
    <global-directive>
    .text
 <name>:
     pushq    %rbp
     movq     %rsp, %rbp
    <instructions>
```

Integer initialized to zero, or any variable initialized only with ZeroInit

```
StaticVariable(name, global,
               alignment,
               init_list)
```

```
     <global-directive>
     .bss
     <alignment-directive>
 <name>:
     <init_list>
```

All other variables

```
     <global-directive>
     .data
     <alignment-directive>
 <name>:
     <init_list>
```

Linux

```
StaticConstant(name, alignment,
               init)
```

```
     .section .rodata
     <alignment-directive>
 <name>:
     <init>
```

macOS (8-byte-aligned numeric constants)

```
    .literal8
    .balign 8
 <name>:
     <init>
```

macOS (16-byte-aligned numeric constants)

```
    .literal16
    .balign 16
 <name>:
     <init>  
     .quad 0
```

macOS (string constants)

```
     .cstring
 <name>:
     <init>
```

Global directive

```
  If global is true:
 .globl <identifier>
 Otherwise, omit this directive.
```

Alignment directive Linux only

```
.align <alignment>
```

macOS or Linux

```
.balign <alignment>
```

`Table B-30:` `Formatting Static Initializers`

Static initializer Output

CharInit(0) .zero 1

CharInit(i) .byte \<i\>

IntInit(0) .zero 4

IntInit(i) .long \<i\>

LongInit(0) .zero 8

LongInit(i) .quad \<i\>

UCharInit(0) .zero 1

UCharInit(i) .byte \<i\>

UIntInit(0) .zero 4

UIntInit(i) .long \<i\>

ULongInit(0) .zero 8

ULongInit(i) .quad \<i\>

ZeroInit(n) .zero \<n\>

DoubleInit(d)

```
.double <d>
or
.quad <d-interpreted-as-long>
```

StringInit(s, True) .asciz " \<s\> "

StringInit(s, False) .ascii " \<s\> "

PointerInit(label) .quad \<label\>

`Table B-31:` `Formatting Assembly Instructions`

Assembly instruction Output

Mov(t, src, dst)

```
mov<t>   <src>, <dst>
```

Movsx(src_t, dst_t, src, dst)

```
movs<src_t><dst_t>    <src>, <dst>
```

MovZeroExtend(src_t, dst_t, src, dst)

```
movz<src_t><dst_t>    <src>, <dst>
```

Lea

```
leaq     <src>, <dst>
```

Cvtsi2sd(t, src, dst)

```
cvtsi2sd<t>     <src>, <dst>
```

Cvttsd2si(t, src, dst)

```
cvttsd2si<t>    <src>, <dst>  
```

Ret

```
movq     %rbp, %rsp
popq     %rbp
ret
```

Unary(unary_operator, t, operand)

```
<unary_operator><t>     <operand>
```

Binary(Xor, Double, src, dst)

```
xorpd    <src>, <dst>
```

Binary(Mult, Double, src, dst)

```
mulsd    <src>, <dst>
```

Binary(binary_operator, t, src, dst)

```
<binary_operator><t>    <src>, <dst>
```

Idiv(t, operand)

```
idiv<t>  <operand> 
```

Div(t, operand)

```
div<t>   <operand> 
```

Cdq(Longword)

```
cdq
```

Cdq(Quadword)

```
cqo
```

Push(operand)

```
pushq    <operand>
```

Pop(reg)

```
popq     <reg>
```

Call(label)

```
call     <label>
or
call     <label>@PLT
```

Cmp(Double, operand, operand)

```
comisd   <operand>, <operand>
```

Cmp(t, operand, operand)

```
cmp<t>   <operand>, <operand>
```

Jmp(label)

```
jmp      .L<label>
```

JmpCC(cond_code, label)

```
j<cond_code>      .L<label>
```

SetCC(cond_code, operand)

```
set<cond_code>    <operand>
```

Label(label)

```
.L<label>:
```

`Table B-32:` `Instruction Names for Assembly Operators`

| `Assembly operator`                | `Instruction name` |
|------------------------------------|--------------------|
| `Neg`                              | `neg`              |
| `Not`                              | `not`              |
| `Shr`                              | `shr`              |
| `Add`                              | `add`              |
| `Sub`                              | `sub`              |
| Mult (integer multiplication only) | `imul`             |
| `DivDouble`                        | `div`              |
| `And`                              | `and`              |
| `Or`                               | `or`               |
| `Shl`                              | `shl`              |
| `ShrTwoOp`                         | `shr`              |

`Table B-33:` `Instruction Suffixes for Assembly Types`

| `Assembly type` | `Instruction suffix` |
|-----------------|----------------------|
| `Byte`          | `b`                  |
| `Longword`      | `l`                  |
| `Quadword`      | `q`                  |
| `Double`        | `sd`                 |

`Table B-34:` `Instruction Suffixes for Condition Codes`

| `Condition code` | `Instruction suffix` |
|------------------|----------------------|
| `E`              | `e`                  |
| `NE`             | `ne`                 |
| `L`              | `l`                  |
| `LE`             | `le`                 |
| `G`              | `g`                  |
| `GE`             | `ge`                 |
| `A`              | `a`                  |
| `AE`             | `ae`                 |
| `B`              | `b`                  |
| `BE`             | `be`                 |

`Table B-35:` `Formatting Assembly Operands`

| `Assembly operand`         |          | `Output`                          |
|----------------------------|----------|-----------------------------------|
| `Reg(AX)`                  | `8-byte` | `%rax`                            |
|                            | `4-byte` | `%eax`                            |
|                            | `1-byte` | `%al`                             |
| `Reg(DX)`                  | `8-byte` | `%rdx`                            |
|                            | `4-byte` | `%edx`                            |
|                            | `1-byte` | `%dl`                             |
| `Reg(CX)`                  | `8-byte` | `%rcx`                            |
|                            | `4-byte` | `%ecx`                            |
|                            | `1-byte` | `%cl`                             |
| `Reg(BX)`                  | `8-byte` | `%rbx`                            |
|                            | `4-byte` | `%ebx`                            |
|                            | `1-byte` | `%bl`                             |
| `Reg(DI)`                  | `8-byte` | `%rdi`                            |
|                            | `4-byte` | `%edi`                            |
|                            | `1-byte` | `%dil`                            |
| `Reg(SI)`                  | `8-byte` | `%rsi`                            |
|                            | `4-byte` | `%esi`                            |
|                            | `1-byte` | `%sil`                            |
| `Reg(R8)`                  | `8-byte` | `%r8`                             |
|                            | `4-byte` | `%r8d`                            |
|                            | `1-byte` | `%r8b`                            |
| `Reg(R9)`                  | `8-byte` | `%r9`                             |
|                            | `4-byte` | `%r9d`                            |
|                            | `1-byte` | `%r9b`                            |
| `Reg(R10)`                 | `8-byte` | `%r10`                            |
|                            | `4-byte` | `%r10d`                           |
|                            | `1-byte` | `%r10b`                           |
| `Reg(R11)`                 | `8-byte` | `%r11`                            |
|                            | `4-byte` | `%r11d`                           |
|                            | `1-byte` | `%r11b`                           |
| `Reg(R12)`                 | `8-byte` | `%r12`                            |
|                            | `4-byte` | `%r12d`                           |
|                            | `1-byte` | `%r12b`                           |
| `Reg(R13)`                 | `8-byte` | `%r13`                            |
|                            | `4-byte` | `%r13d`                           |
|                            | `1-byte` | `%r13b`                           |
| `Reg(R14)`                 | `8-byte` | `%r14`                            |
|                            | `4-byte` | `%r14d`                           |
|                            | `1-byte` | `%r14b`                           |
| `Reg(R15)`                 | `8-byte` | `%r15`                            |
|                            | `4-byte` | `%r15d`                           |
|                            | `1-byte` | `%r15b`                           |
| `Reg(SP)`                  |          | `%rsp`                            |
| `Reg(BP)`                  |          | `%rbp`                            |
| `Reg(XMM0)`                |          | `%xmm0`                           |
| `Reg(XMM1)`                |          | `%xmm1`                           |
| `Reg(XMM2)`                |          | `%xmm2`                           |
| `Reg(XMM3)`                |          | `%xmm3`                           |
| `Reg(XMM4)`                |          | `%xmm4`                           |
| `Reg(XMM5)`                |          | `%xmm5`                           |
| `Reg(XMM6)`                |          | `%xmm6`                           |
| `Reg(XMM7)`                |          | `%xmm7`                           |
| `Reg(XMM8)`                |          | `%xmm8`                           |
| `Reg(XMM9)`                |          | `%xmm9`                           |
| `Reg(XMM10)`               |          | `%xmm10`                          |
| `Reg(XMM11)`               |          | `%xmm11`                          |
| `Reg(XMM12)`               |          | `%xmm12`                          |
| `Reg(XMM13)`               |          | `%xmm13`                          |
| `Reg(XMM14)`               |          | `%xmm14`                          |
| `Reg(XMM15)`               |          | `%xmm15`                          |
| `Memory(reg, int)`         |          | \<int\> ( \<reg\> )               |
| `Indexed(reg1, reg2, int)` |          | ( \<reg1\> , \<reg2\> , \<int\> ) |
| `Imm(int)`                 |          | \$ \<int\>                        |
| `Data(identifier, 0)`      |          | \<identifier\> (%rip)             |
| `Data(identifier, int)`    |          | \<identifier\> + \<int\> (%rip)   |