
 

**8**

 

**M A N I P U L A T I N G U S E R L A N D**

 

**M E M O R Y**

 

There are a number of situations where both kernel

and userland need to manipulation userland mem-

ory. This chapter firstly examines the means by which

the kernel can do so, via direct user memory access

(uaccess) and the Get User Pages (GUP) mechanisms,

before examining a number of userland APIs for

manipulating the attributes of userland memory:

[mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html), [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html), [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) and [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html)[.](https://man7.org/linux/man-pages/man2/mprotect.2.html)

 

**8.1 Accessing User Memory from the Kernel**

 

Sometimes the kernel needs to access userland memory. This is significantly

less straightforward than accessing kernel memory, which can simply be ad-

dressed using the direct mapping (or kernel text mapping) via [\_\_pa()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n42)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n42) [\_\_va()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n59),

[virt_to_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n854) and friends and for which only kernel synchronisation need

be considered.

Userland mappings, on the other hand, are not at all so easily accessed

– they each have their own independent page tables which must be walked

if we need to determine the folios associated with them, may be accessed


 

and manipulated at any time by userland and can disappear from under you altogether as the userland process maps and unmaps memory.

There are two separate parts of the kernel that enable the kernel to ac-

cess user memory – user access (or uaccess for short) and the Get User Pages (GUP) interface. We will examine both.

User access functions are used by the kernel mode of the current process

to simply do a best effort to transfer data between kernel and user memory, with no attempt to perform locks or adjust reference counts of any kind.

GUP on the other hand allow folios to be pinned (i.e. incrementing the

underlying folio’s reference count such that they will not be freed until un-pinned), optionally returns folio and VMA objects and allows fine-grained control over how the whole operation is performed.

 

***8.1.1 User Access***

Many kernel system calls read data from or write data to userland mappings. These occur in kernel mode from the context of the current process, so if the specified userland virtual address is valid, either its userland mappings will be in place or it can be faulted in as required (i.e. the address will be marked valid in a VMA).

The uaccess functionality takes advantage of this by performing a very

carefully orchestrated and tailored version of a memcpy() from kernel mode.

The fundamental issue with doing this, and the reason why you must

never access user memory directly in the kernel, is that unhandled page faults originating from kernel mode ordinarily have no means of recovery and thus result in a kernel oops.

Note that when userland memory is accessed from the kernel and a page

fault occurs which is correctly handled (i.e. faulted in), then everything func-

tions as if that memory had been faulted in by userland. See section 6 for details on page fault logic.

However, some kernel functions are given a special designation whereby

they are permitted to fault. These use what is known as an ‘exception table’ to mark regions of kernel virtual memory where access is permitted as well as information on how to recover from the error.

The key user access function, [copy_from_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uaccess.h?h=v6.0#n149) and [copy_to_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uaccess.h?h=v6.0#n157) use pre-

cisely this mechanism in order to perform these actions. Examining both:-

 

148 **static \_\_always_inline unsigned long \_\_must_check** 149 **copy_from_user**(**void** \*to, **const void \_\_user** \*from, **unsigned long** n) 150 {

151 **if** (**check_copy_size**(to, n, **false**)) 152 n = **\_copy_from_user**(to, from, n); 153 **return** n;

154 }

 

*Listing 8-1:* include/linux/uaccess.h: [*copy_from_user()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uaccess.h?h=v6.0#n149)

 

156 **static \_\_always_inline unsigned long \_\_must_check**

 



 

157 **copy_to_user**(**void \_\_user** \*to, **const void** \*from, **unsigned long** n) 158 {

159 **if** (**check_copy_size**(from, n, **true**)) 160 n = **\_copy_to_user**(to, from, n); 161 **return** n;

162 }

 

*Listing 8-2:* include/linux/uaccess.h: [*copy_to_user()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uaccess.h?h=v6.0#n157)

 

Note that \_\_must_check is a compiler directive that generates a warning if

the returned value is not used and \_\_user is a static analysis tag used to assert

that the pointers passed are userland ones.

Each are parameterised by from and to indicating source and target

buffers respectively, n specifies how many bytes to copy and the return value

indicates the number of bytes that could not be copied. This being non-zero

typically implies a page fault has occurred, so this can be used as an error

indicator – if the result is zero then the operation succeeded, otherwise it

failed. Trailing bytes are cleared on failure.

The actual implementation of these functions are provided by

[\_copy_from_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/usercopy.c?h=v6.0#n10) and [\_copy_to_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/usercopy.c?h=v6.0#n26) which can be inlined depending on ar-

chitecture, but on x86-64, which we focus on, it is not. Examining these:-

 

10 **unsigned long \_copy_from_user**(**void** \*to, **const void \_\_user** \*from, **unsigned long**

n\)

11 {

12 **unsigned long** res = n;

13 **might_fault**();

14 **if** (!**should_fail_usercopy**() && **likely**(**access_ok**(from, n))) {

15 **instrument_copy_from_user**(to, from, n);

16 res = **raw_copy_from_user**(to, from, n);

17 }

18 **if** (**unlikely**(res))

19 **memset**(to + (n - res), 0, res);

20 **return** res;

21 }

 

*Listing 8-3:* lib/usercopy.c: [*\_copy_from_user()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/usercopy.c?h=v6.0#n10)

 

26 **unsigned long \_copy_to_user**(**void \_\_user** \*to, **const void** \*from, **unsigned long** n

)

27 {

28 **might_fault**();

29 **if** (**should_fail_usercopy**())

30 **return** n;

31 **if** (**likely**(**access_ok**(to, n))) {

32 **instrument_copy_to_user**(to, from, n);

33 n = **raw_copy_to_user**(to, from, n);

34 }

35 **return** n;

 



 

36 }

 

*Listing 8-4:* lib/usercopy.c: [*\_copy_to_user()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/usercopy.c?h=v6.0#n26)

 

Note that:-

 

• [might_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/kernel.h?h=v6.0#n197) is used by kernel lock/atomic sleep debugging and only

meaningful when either CONFIG_PROVE_LOCKING or CONFIG_DEBUG_ATOMIC_SLEEP are configured.

• [should_fail_usercopy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/fault-inject-usercopy.c?h=v6.0#n35) is part of the fault injection logic (only meaningful

if CONFIG_FAULT_INJECTION_USERCOPY is configured) and out of scope for the book.

• [instrument_copy_from_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/instrumented.h?h=v6.0#n133) and [instrument_copy_to_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/instrumented.h?h=v6.0#n116) are used by

KASAN and KCSAN both of which are out of scope of the book.

 

The [access_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/uaccess.h?h=v6.0#n40) macro determines whether the specified address is valid

for userland access, which in x86-64 uses the generic [\_\_access_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/access_ok.h?h=v6.0#n31) handler which simply checks that the address is below the maximum permitted user-

land virtual address, [TASK_SIZE_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n64)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n64)

The heavy lifting is left to the raw versions of the functions. Examining

these:-

 

49 **static \_\_always_inline \_\_must_check unsigned long** 50 **raw_copy_from_user**(**void** \*dst, **const void \_\_user** \*src, **unsigned long** size) 51 {

52 **return copy_user_generic**(dst, (**\_\_force void** \*)src, size); 53 }

 

*Listing 8-5:* arch/x86/include/asm/uaccess_64.h: [*raw_copy_from_user()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/uaccess_64.h?h=v6.0#n50)

 

55 **static \_\_always_inline \_\_must_check unsigned long** 56 **raw_copy_to_user**(**void \_\_user** \*dst, **const void** \*src, **unsigned long** size) 57 {

58 **return copy_user_generic**((**\_\_force void** \*)dst, src, size); 59 }

 

*Listing 8-6:* arch/x86/include/asm/uaccess_64.h: [*raw_copy_to_user()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/uaccess_64.h?h=v6.0#n56)

 

Note that \_\_force is a static analysis hint that has no effect for an ordinary

build. It indicates that the pointer should not be checked for address space consistency.

These both invoke [copy_user_generic()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/uaccess_64.h?h=v6.0#n28) which performs the actual copy

operation:-

 

27 **static \_\_always_inline \_\_must_check unsigned long** 28 **copy_user_generic**(**void** \*to, **const void** \*from, **unsigned** len) 29 {

30 **unsigned** ret;

31

32 */\**

 



 

33 *\* If CPU has ERMS feature, use copy_user_enhanced_fast_string.*

34 *\* Otherwise, if CPU has rep_good feature, use*

*copy_user_generic_string.*

35 *\* Otherwise, use copy_user_generic_unrolled.*

36 *\*/*

37 **alternative_call_2**(**copy_user_generic_unrolled**,

38 **copy_user_generic_string**,

39 **X86_FEATURE_REP_GOOD**,

40 **copy_user_enhanced_fast_string**,

41 **X86_FEATURE_ERMS**,

42 **ASM_OUTPUT2**("=a" (ret), "=D" (to), "=S" (from),

43 "=d" (len)),

44 "1" (to), "2" (from), "3" (len)

45 : "memory", "rcx", "r8", "r9", "r10", "r11");

46 **return** ret;

47 }

 

*Listing 8-7:* arch/x86/include/asm/uaccess_64.h: [*copy_user_generic()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/uaccess_64.h?h=v6.0#n28)

 

This x86-64-specific routine invokes different assembly routines to per-

form the actual copy depending on available CPU features. For the sake of

brevity we will examine only one, [copy_user_enhanced_fast_string()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/lib/copy_user_64.S?h=v6.0#n161):-

 

149 */\**

150 *\* Some CPUs are adding enhanced REP MOVSB/STOSB instructions.* 151 *\* It's recommended to use enhanced REP MOVSB/STOSB if it's enabled.* 152 *\**

153 *\* Input:*

154 *\* rdi destination*

155 *\* rsi source*

156 *\* rdx count*

157 *\**

158 *\* Output:*

159 *\* eax uncopied bytes or 0 if successful.* 160 *\*/*

161 **SYM_FUNC_START**(**copy_user_enhanced_fast_string**) 162 **ASM_STAC**

163 */\* CPUs without FSRM should avoid rep movsb for short copies \*/* 164 **ALTERNATIVE** "cmpl \$64, %edx; jb copy_user_short_string", "",

**X86_FEATURE_FSRM**

165 **movl** %edx,%ecx

166 1: **rep** movsb

167 **xorl** %eax,%eax

168 **ASM_CLAC**

169 **RET**

170

171 12: **movl** %ecx,%edx */\* ecx is zerorest also \*/* 172 **jmp** .**Lcopy_user_handle_tail**

173

 



 

174 **\_ASM_EXTABLE_CPY**(1b, 12b) 175 **SYM_FUNC_END**(**copy_user_enhanced_fast_string**)

 

*Listing 8-8:* arch/x86/lib/copy_user_64.S: [*copy_user_enhanced_fast_string()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/lib/copy_user_64.S?h=v6.0#n161)

 

A description of how the actual copy is performed here is out of scope,

other than to observe that we operate directly on the supplied addresses with no further abstraction. The key thing to note here is the invocation of

the assembler macro [\_ASM_EXTABLE_CPY()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/asm.h?h=v6.0#n218). This is used at compile time to spec-ify that the exception table should contain the address of the instruction at label 1 (the one performing the actual copy) and, if an unhandled page fault occurs while executing it, to resume execution at label 12. This is performed

in [\_ASM_EXTABLE_TYPE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/asm.h?h=v6.0#n135)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/asm.h?h=v6.0#n135)

 

135 **\# define \_ASM_EXTABLE_TYPE**(from, to, type) \\ 136 .**pushsection** "\_\_ex_table","a" ; \\ 137 .**balign** 4 ; \\ 138 .**long** (from) - . ; \\ 139 .**long** (to) - . ; \\ 140 .**long** type ; \\ 141 .**popsection**

 

*Listing 8-9:* arch/x86/include/asm/asm.h: [*\_ASM_EXTABLE_TYPE()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/asm.h?h=v6.0#n135)

 

This sets up an entry in the exception table of type

[struct exception_table_entry](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/extable.h?h=v6.0#n23), storing the permitted exception address (here denoted from) and fixup address (here denoted to) relative to the exception table entry to save on space.

If a page fault within the memory range being read from/to occurs and

is handled successfully, then the operation proceeds as if it were performed in userland. However, if an invalid address is accessed or another error oc-curs on page fault, then it receives special handling.

The function which determines whether an invalid page fault in kernel

mode can be handled or ought to result in a kernel oops (and thus poten-

tially a system lockup) in x86-64 is [kernelmode_fixup_or_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n712). Stripping out irrelevant details:-

 

711 **static noinline void**

712 **kernelmode_fixup_or_oops**(**struct** pt_regs \*regs, **unsigned long** error_code, 713 **unsigned long** address, **int** signal, **int** si_code, 714 **u32** pkey) 715 {

716 **WARN_ON_ONCE**(**user_mode**(regs)); 717

718 */\* Are we prepared to handle this kernel fault? \*/* 719 **if** (**fixup_exception**(regs, **X86_TRAP_PF**, error_code, address)) {

. . .

750 **return**;

751 }

. . .

 



 

760 **page_fault_oops**(regs, error_code, address); 761 }

 

*Listing 8-10:* arch/x86/mm/fault.c: [*kernelmode_fixup_or_oops()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n712)

 

This invokes [fixup_exception()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/extable.c?h=v6.0#n205) to check whether the faulting address is

referenced in an exception table (and perform the fixup if so). If it isn’t then

[page_fault_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n632) is called.

Examining this function:-

 

205 **int fixup_exception**(**struct** pt_regs \*regs, **int** trapnr, **unsigned long** error_code

,

206 **unsigned long** fault_addr) 207 {

208 **const struct** exception_table_entry \*e; 209 **int** type, reg, imm;

. . .

225 e = **search_exception_tables**(regs-\>ip); 226 **if** (!e)

227 **return** 0;

228

229 type = **FIELD_GET**(**EX_DATA_TYPE_MASK**, e-\>data); 230 reg = **FIELD_GET**(**EX_DATA_REG_MASK**, e-\>data); 231 imm = **FIELD_GET**(**EX_DATA_IMM_MASK**, e-\>data);

232

233 **switch** (type) {

. . .

242 **case EX_TYPE_COPY**: 243 **return ex_handler_copy**(e, regs, trapnr);

. . .

275 }

276 **BUG**();

277 }

 

*Listing 8-11:* arch/x86/mm/extable.c: [*fixup_exception()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/extable.c?h=v6.0#n205)

 

The key function here is [search_exception_tables()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/extable.c?h=v6.0#n54) which searches each of

the kernel, module and BPF exception tables for the faulting address. The

key of these for the purposes of uaccess being the kernel table searched by

[search_kernel_exception_table()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/extable.c?h=v6.0#n47). This invokes [search_extable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/extable.c?h=v6.0#n112) to do the heavy

lifting.

This performs a binary search over the exception table for the address,

using [ex_to_insn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/extable.c?h=v6.0#n18) to obtain the faulting instruction from the stored relative

address:-

 

18 **static inline unsigned long ex_to_insn**(**const struct** exception_table_entry \*x)

19 {

20 **return** (**unsigned long**)&x-\>insn + x-\>insn;

21 }

 



 

*Listing 8-12:* lib/extable.c: [*ex_to_insn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/extable.c?h=v6.0#n18)

 

Which offsets from the location of the exception table entry to obtain

the correct address with which to compare the faulting one.

Once an entry is located, [ex_handler_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/extable.c?h=v6.0#n140) is invoked to perform the

fixup. This in turn invokes [ex_handler_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/extable.c?h=v6.0#n97) which calls [ex_handler_default()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/extable.c?h=v6.0#n32)

which fixes up the faulting instruction pointer using [ex_fixup_addr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/extable.c?h=v6.0#n27):-

 

26 **static inline unsigned long** 27 **ex_fixup_addr**(**const struct** exception_table_entry \*x) 28 {

29 **return** (**unsigned long**)&x-\>fixup + x-\>fixup; 30 }

 

*Listing 8-13:* arch/x86/mm/extable.c: [*ex_fixup_addr()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/extable.c?h=v6.0#n27)

 

This again uses the relative offset to point the instruction pointer at the

specified fixup address allowing the page fault to be cleared. This will result in a non-zero return value as not all bytes were copied and thus the caller can deduce an error has occurred.

When memory is copied between kernel and userspace but we have a

kernel virtual address for the source/target userland buffer, the functions

[copy_from_user_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/cacheflush.h?h=v6.0#n114) and [copy_to_user_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/cacheflush.h?h=v6.0#n106) are used.

These perform careful cache operations to ensure that, on architectures

where accessing the memory through the direct mapping might result in inconsistency in userland, the appropriate cache lines are invalidated. This is not applicable to x86-64.

 

***8.1.2 Get User Pages (GUP)***

The Get User Pages (GUP) interface consists of a number of functions used for walking userland mappings from the kernel and, in most cases, pinning their underlying folios (incrementing their reference count so they cannot be freed). Most of these are exported for drivers.

When pinning memory, the GUP functions retrieve a list of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)

objects (and in some cases, optionally, a list of [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) objects) associated with the specified range of user memory.

Note that we exclude discussions of huge pages (deferring all such discus-

sions to the dedicated chapter on the topic), as well as very specific features like DAX.

GUP can be used for operations other than pinning pages, for exam-

ple faulting in pages, marking them dirty or performing various checks on them. These are often exported by specific helper functions, which we ex-

amine briefly in section 8.1.9.

What GUP does with the input memory range is determined via GUP

flags, each of which which we will examine shortly. Firstly, let’s take a look at the core GUP API and supporting functions:-

 



 

Table 8-1: Core GUP functions

*GUP Function* *∗* *Must hold* *Sets* *Sets* *Sets* *Must output* *Can output*

mmap_lock ? FOLL_GET? FOLL_PIN? FOLL_TOUCH? pages? vmas?

[get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2245) *•* *If* pages set *•* *If* FOLL_GET *•*

[pin_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3221) *•* *•* *•* *•*

[get_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2272) *If* pages set *•* *If* FOLL_GET

[pin_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3243) *•* *•*

[get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3077) *•*

[get_user_pages_fast_only()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3032) *•*

[pin_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3110) *•* *•*

[pin_user_pages_fast_only()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3131) *•* *•*

[get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2198) *•* *If* pages set *•* *If* FOLL_GET *•*

[pin_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3186) *•* *•* *•* *•* *•*

 

*∗* and allows the use of FOLL_LONGTERM. We’ll get into what FOLL_GET, FOLL_PIN and FOLL_LONGTERM mean shortly.

Only the \_remote() variants permit access to the mm_struct of processes other

than the currently running one, and only some functions, notably the ones

that require the mmap_lock read semaphore to be held, return an array of

VMAs.

These core functions share the majority of their parameters, with some

additional ones that are specific to certain functions only. Examining them

all:-

 

• start – (all functions) – An initial page-aligned virtual address.

• nr_pages – (all functions) – The number of base pages to be processed.

• gup_flags – (all functions) – GUP flags modifying how the memory is

walked, what actions are to be performed and other modifiers.

• pages – (all functions) – A pointer to an optional output array of

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects in which to place these objects relating to map-ping pages (must have at last nr_pages entries). All functions which use FOLL_GET or FOLL_PIN should specify these in order to be able to have something to unpin later. This is not, however enforced for

[get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3077) or [get_user_pages_fast_only()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3032)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3032)

• vmas – get_user_pages\[\_remote\](), pin_user_pages\[\_remote\]() – A pointer to

an optional output array of [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) objects (must have at last nr_pages entries). The GUP functions which support this require

the caller to hold the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>mmap_lock read semaphore and will be invalidated as soon as this is dropped. The \_remote variants there-fore must not specify the locked parameter if they require VMAs to be returned (see below description of this parameter).

• mm – get_user_pages_remote(), pin_user_pages_remote() – An object of

[struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) type specifying the process address space in which to perform the GUP operation.

• locked – get_user_pages_remote(), pin_user_pages_remote() – A pointer

to an optional output boolean indicating whether the mmap_lock read

 



 

semaphore has been dropped due to VM_FAULT_RETRY. If specified, then the vmas parameter cannot be used as VMAs are no longer valid once the lock is dropped.

 

All of the functions return the number of base pages that the actions

have been applied to, or a negative error code if something has gone wrong.

 

***8.1.3 Pinning Folios***

Pinning folios of userland memory simply means incrementing the underly-ing folio’s reference count in order that they will not be freed until the folio is unpinned. This can be done with both anonymous and file-backed mem-ory.

If a folio is pinned there is no guarantee that the userland mapping still

exists on return, or is even meaningful in any way from userland’s perspec-tive. Therefore the strongest guarantee we can give is that these folios were

valid at some point. See the [pin user pages](https://kernel.org/doc/html/v6.0/core-api/pin_user_pages.html) documentation for more on the background of this.

There are two means of pinning folios – FOLL_GET which can be only be

performed via the get\_\*() family of functions, and FOLL_PIN which is per-formed only (and unconditionally) via the pin\_\*() functions. Both op-erations require that the pages output parameter be specified to return

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)s.

The former simply increments the reference count of the underlying

folio to ensure it is not freed and expects the user to call [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122) or

[put_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1167) to decrement the reference count. The latter uses a different means of pinning termed GUP pinning (described below) to achieve the

same ends and must be unpinned via [unpin_user_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n240)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n240) [unpin_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n410)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n410)

[unpin_user_pages_dirty_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n299) or [unpin_user_page_range_dirty_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n365).

When deciding which interface to use the criteria are as follows\*:-

 

• Use get\_\*\_user_pages\*() when the user memory access is short-term, i.e.

all actions are performed pinned under the mmap_lock (or no pinning is

performed). Either data is manipulated (e.g. [\_\_access_remote_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5438)) or

only [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)[/](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) or [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) metadata is. Note that this memory will be subject to reclaim, migration and be-coming a CoW mapping on fork once the lock is released.

• Use pin\_\*\_user_pages\*() when memory needs to be pinned longer than

the mmap_lock is held. Memory can either be kept briefly during which an operation occurs (e.g. DMA writeback) or for the long term, at which point the FOLL_LONGTERM flag should be specified to prevent memory frag-mentation (this causes the memory to be migrated to an unmovable page block, more on this below).

In either case, the memory cannot be reclaimed or become a CoW map-ping on fork and any existing CoW mapping is immediately unshared even if read-only.

 

\*. See the [pin user pages](https://kernel.org/doc/html/v6.0/core-api/pin_user_pages.html) documentation for a lot more detail on this



 

The key users of the pin\_\*() functions are DMA\* routines utilising user-

land memory for DMA operations, though other users which ultimately

touches folio data, such as direct I/O, also use it.

THis is checked permit other parts of the kernel to determine

whether these folios are likely to be used for DMA or otherwise have

their data manipulated. This is checked by [folio_maybe_dma_pinned()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1498) and

[page_maybe_dma_pinned()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1515). The places where this check are performed are:-

 

**Reclaim** – Skips memory reclaim of folios which are marked this way in

[shrink_page_list() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)

**procfs** – The /proc/\$pid/clear_refs logic, when used to clear the [soft-dirty](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html) bit,

uses this in [pte_is_pinned()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1074), called from [clear_soft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1090)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1090) This causes GUP pinned folios to be skipped for this operation (also based on other criteria).

**Reverse mapping** , clear anonymous exclusive – Used in the function

[page_try_share_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n285), which is used to strip the anonymous exclu-sive folio flag when a folio is potentially about to be shared. If the folio is GUP pinned, then this operation is not performed.

**Fork** , avoid CoW on GUP pinned – The function [page_needs_cow_for_dma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1526)

is used by [page_try_dup_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n234). This returns an error code if a folio is GUP pinned. This is most notably used by the fork logic ultimately

invoked via [copy_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1272) (called by [dup_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580) to force a copy. It is additionally used by huge page logic in the same fashion.

 

When FOLL_PIN is used, the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) flag [MMF_HAS_PINNED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n84) flag is set

in [mm_set_has_pinned_flag()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n437) for the lifetime of the mm_struct and used as an

early exit condition for [page_needs_cow_for_dma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1526) described above, for effi-

ciency.

The pinning and unpinning of GUP pinned folios is tracked by

/proc/vmstat in the nr_foll_pin_acquired and nr_foll_pin_released statistics.

The actual pinning of non-compound folios is performed by either

[try_grab_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n202) or [try_grab_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n124). In each case FOLL_GET results in a refer-

ence count being incremented by one for each folio pinned, and FOLL_PIN

increments instead by [GUP_PIN_COUNTING_BIAS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1210) for each folio pinned. Unpinning

FOLL_PIN folios ultimately invokes [gup_put_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n170) which performs the reverse

action.

In this case, reference count increments/decrements are multiplied by

GUP_PIN_COUNTING_BIAS 10 , specified as 2, for FOLL_PIN as the value is both easy to

‘eyeball’ when debugging and unlikely to skew the existing reference count

so this can easily be ascertained.

However for compound folios, we have sufficient space in the 2nd

subpage to store a precise GUP-pin count, compound_pincount, accessed via

[compound_pincount_ptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n314) or [folio_pincount_ptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1468). You can see this in action in

[folio_maybe_dma_pinned() :-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1498)

 

\*. DMA refers to Direct Memory Access – which refers to devices’s ability to read or write mem-

ory directly rather than have memory accesses mediated by the CPU.

 



 

1473 */\*\**

1474 *\* folio_maybe_dma_pinned - Report if a folio may be pinned for DMA.* 1475 *\* @folio: The folio.*

1476 *\**

1477 *\* This function checks if a folio has been pinned via a call to* 1478 *\* a function in the pin_user_pages() family.* 1479 *\**

1480 *\* For small folios, the return value is partially fuzzy: false is not fuzzy,*

1481 *\* because it means "definitely not pinned for DMA", but true means "probably*

1482 *\* pinned for DMA, but possibly a false positive due to having at least* 1483 *\* GUP_PIN_COUNTING_BIAS worth of normal folio references".* 1484 *\**

1485 *\* False positives are OK, because: a) it's unlikely for a folio to* 1486 *\* get that many refcounts, and b) all the callers of this routine are* 1487 *\* expected to be able to deal gracefully with a false positive.* 1488 *\**

1489 *\* For large folios, the result will be exactly correct. That's because* 1490 *\* we have more tracking data available: the compound_pincount is used* 1491 *\* instead of the GUP_PIN_COUNTING_BIAS scheme.* 1492 *\**

1493 *\* For more information, please see Documentation/core-api/pin_user_pages.rst.*

1494 *\**

1495 *\* Return: True, if it is likely that the page has been "dma-pinned".* 1496 *\* False, if the page is definitely not dma-pinned.* 1497 *\*/*

1498 **static inline bool folio_maybe_dma_pinned**(**struct** folio \*folio) 1499 {

1500 **if** (**folio_test_large**(folio)) 1501 **return atomic_read**(**folio_pincount_ptr**(folio)) \> 0; 1502

1503 */\**

1504 *\* folio_ref_count() is signed. If that refcount overflows, then* 1505 *\* folio_ref_count() returns a negative value, and callers will avoid*

1506 *\* further incrementing the refcount.* 1507 *\**

1508 *\* Here, for that overflow case, use the sign bit to count a little*

1509 *\* bit higher via unsigned math, and thus still get an accurate result*

*.*

1510 *\*/*

1511 **return** ((**unsigned int**)**folio_ref_count**(folio)) \>= 1512 **GUP_PIN_COUNTING_BIAS**; 1513 }

 

*Listing 8-14:* include/linux/mm.h: [*folio_maybe_dma_pinned()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1498)

 

Note the careful handling of reference count overflow.

 



 

A flag that is closely related to FOLL_PIN (and requires it to be set to be

available) is FOLL_LONGTERM. This is a hint that the mapping is indefinite and

likely to have its data manipulated while in use.

When FOLL_LONGTERM is used, each folio is checked to determine

whether it is long-term pinnable (i.e. is not in ZONE_MOVABLE or other-

wise unavailable long-term) via [is_longterm_pinnable_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1539)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1539) and unpins

them if not. This is checked either in [try_grab_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n124) for the fast path or

[check_and_migrate_movable_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1935) otherwise.

This also invokes some additional checks (for example, disallowing this

mode for VMAs which are marked for DAX, i.e. direct access, bypassing the

page cache, a topic that is out of scope for the book) to take into account

this intended usage of the GUP-pinned memory.

 

***8.1.4 Follow Flags***

What we actually do with these mappings is determined by the gup_flags field

via ‘follow’ flags prefixed with FOLL\_ and declared in the [include/linux/mm.h](https://elixir.bootlin.com/linux/v6.0/source/include/linux/mm.h)

header. Examining each:-

 

• [FOLL_GET](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2884) – One of the two core pinning flags, see the above section on pin-

ning for a description.

• [FOLL_PIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2898) – One of the two core pinning flags, see thes above section on pin-

ning for a description.

• [FOLL_LONGTERM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2896) – A hint that folios being GUP pinned will have a long life

time, see the above section on pinning for a description.

• [FOLL_TOUCH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2883) – This sets the PG_accessed folio flag in [follow_page_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519)

and [follow_pfn_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n461) via [pte_mkyoung()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n333), and if FOLL_WRITE is set, also marks it dirty (see description of this flag below). It is implic-

itly set in [get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2245)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2245) [\_\_get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2109) (therefore

also in [get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2198) and [pin_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3186)), and

[get_user_pages_unlocked().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2272)

• [FOLL_HWPOISON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2890) – Walk the memory range and, if memory is discovered to

be hardware poisoned (i.e. marked by hardware as unavailable) when faulted in, explicitly return an-EHWPOISON error instead of-EFAULT error in

[vm_fault_to_errno(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2957)Used exclusively by the KVM virtualisation logic.

• [FOLL_DUMP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2885) – As the name suggests, used by the core dump functionality

in [get_dump_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1911), though also used elsewhere. This flag checks whether folios that are unavailable would ultimately result in references to the zero page and prevents them from being faulted in. This is checked in

[no_page_table()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n444) and [follow_page_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519)

• [FOLL_FORCE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2886) – Overrides VMA flags VM_READ and VM_WRITE and per-

mits access to any VMA. Checked in [can_follow_write_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n482) and

[check_vma_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1027). A very powerful and dangerous flag that should be used carefully and sparingly. Typically used by ptrace to access other-wise inaccessible memory.

 



 

• [FOLL_NOWAIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2887) – Indicates that the mmap_lock should not be dropped, and

we should not wait when retrying a page fault. This maps on to the

[FAULT_FLAG_RETRY_NOWAIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n867) flag. If this flag is specified, then it also implies

[FAULT_FLAG_ALLOW_RETRY. ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n866)This flag is checked in [faultin_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n960)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n960) See section

6 for details on how this flag impacts page faulting.

• [FOLL_NOFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2889) – Indicates that memory should not be faulted in, and if

a fault were required, the-EFAULT error should instead be returned.

Checked in [faultin_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n960).

• [FOLL_MIGRATION](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2892) – Causes migration logic to be invoked if a page table

mapping is not valid, rather than immediately trying to fault folios in (or, if FOLL_NOFAULT is specified, return an error), try to wait for migration

folios to be populated. This used by the [Kernel Samepage Merging (KSM)](https://kernel.org/doc/html/v6.0/admin-guide/mm/ksm.html) functionality (out of scope for the book).

• [FOLL_REMOTE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2894) – Indicates that the GUP actions are to be per-

formed on a remote mm_struct. Set by [get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2198) and

[pin_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3186). When this is set, arch-specific access checks in-

voked by [check_vma_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1027) faults have remote access enabled and any

page faults are invoked with the [FAULT_FLAG_REMOTE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n871) set.

• [FOLL_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2895) – Enforces that what is being pinned consists only of anony-

mous folios. This is checked in [check_vma_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1027) and returns a-EFAULT

error if the VMA is not anonymous (as checked by [vma_is_anonymous()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n629)).

• [FOLL_SPLIT_PMD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2897) – Used as part of the huge page functionality, caus-

ing huge pages at the PMD level to be split into base pages. This is

used by [make_device_exclusive_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2310) and calls [split_huge_pmd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/huge_mm.h?h=v6.0#n196) from

[follow_pmd_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n646). We intentionally do not cover the huge page logic con-tained within GUP here in order to maintain brevity, see the chapter on huge page support for more details on page splitting.

• [FOLL_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2882) – Check to ensure that the memory range is writeable (unless

FOLL_FORCE overrides this, in which case we proceed regardless) and fault in. If FOLL_TOUCH is also specified set the page table dirty flag (in either

[follow_page_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519) or [follow_pfn_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n461)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n461)

• [FOLL_NUMA](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2891) – If a page mapping is indicative of NUMA balancing being

performed on the memory mapped, treat it as if the page is not mapped in order to trigger a page fault (see the NUMA chapter for more on

NUMA balancing). Checked in [follow_page_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519) and [follow_pmd_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n646).

This is set in [\_\_get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140) for all cases other than when FOLL_FORCE is specified.

• [FOLL_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2893) – Maps on to the fault flag [FAULT_FLAG_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869) and set when

the mmap_lock has been released on faulting in pages (indicating that a VM_FAULT_RETRY or VM_FAULT_COMPLETED fault has arisen), and faulting in will

be retried in [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387).

• [FOLL_FAST_ONLY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2899) – Set by the functions [get_user_pages_fast_only()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3032) and

[pin_user_pages_fast_only()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3131). This prevents these functions from falling back to non-fast versions if a page fault is needed.

 



[pin_user_pages_fast_only()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3131) [get_user_pages_fast_only()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3032)

 

[pin_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3110) [get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3077)

 

[pin_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3221) [get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2245) [internal_get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2964)

Slow path, no *FOLL_FAST_ONLY*

[check_and_migrate_movable_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1935) [\_\_gup_longterm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063) [\_\_gup_longterm_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2892)

 

[\_\_get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2109) [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) [get_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2272)

 

[get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2198) [\_\_get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140) [pin_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3243)

 

[pin_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3186) [follow_page_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n844) [lockless_pages_from_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2915)

 

[faultin_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n960) [follow_p4d_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n794) [gup_pgd_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2849)

 

[handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) [follow_pud_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n754) [gup_p4d_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2824)

 

Fault in page... [follow_pmd_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n646) [gup_pud_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2796)

 

[follow_page_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519) [gup_pmd_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2753)

If FOLL_GET/PIN

[try_grab_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n202) [gup_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2367)

 

[try_grab_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n124)

 

*Figure 8-1: GUP functions*

 

Note that:-

 

• Denotes non-static GUP functions.

 

• Denotes key functions.

 

***8.1.5 GUP Functions***

We will examine all of the code paths from figure 8-1 one-by-one to examine

how the Get User Pages functionality logic actually operates.

There are two key code paths which all of the GUP functions take – for

the \_fast() functions, passing through [lockless_pages_from_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2915) and for the

non-fast functions, passing through [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) To start with,

let’s examine the non-fast GUP functions:-

 

2229 */\*\**

 



 

2230 *\* get_user_pages() - pin user pages in memory* 2231 *\* @start:* *starting user address* 2232 *\* @nr_pages:* *number of pages from start to pin* 2233 *\* @gup_flags: flags modifying lookup behaviour* 2234 *\* @pages:* *array that receives pointers to the pages pinned.* 2235 *\** *Should be at least nr_pages long. Or NULL, if caller* 2236 *\** *only intends to ensure the pages are faulted in.* 2237 *\* @vmas:* *array of pointers to vmas corresponding to each page.* 2238 *\** *Or NULL if the caller does not require them.* 2239 *\**

2240 *\* This is the same as get_user_pages_remote(), just with a less-flexible*

2241 *\* calling convention where we assume that the mm being operated on belongs to*

2242 *\* the current task, and doesn't allow passing of a locked parameter. We also*

2243 *\* obviously don't pass FOLL_REMOTE in here.* 2244 *\*/*

2245 **long get_user_pages**(**unsigned long** start, **unsigned long** nr_pages, 2246 **unsigned int** gup_flags, **struct** page \*\*pages, 2247 **struct** vm_area_struct \*\*vmas) 2248 {

2249 **if** (!**is_valid_gup_flags**(gup_flags)) 2250 **return**-**EINVAL**; 2251

2252 **return \_\_gup_longterm_locked**(current-\>mm, start, nr_pages, 2253 pages, vmas, gup_flags \| **FOLL_TOUCH**); 2254 }

 

*Listing 8-15:* mm/gup.c: [*get_user_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2245)

 

This requires the mmap_lock read semaphore to be held on entry. It checks

flags for the get\_\*() core functions before invoking [\_\_gup_longterm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063) to do the heavy lifting, with FOLL_TOUCH set. Examining the check function,

[is_valid_gup_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2089):-

 

2089 **static bool is_valid_gup_flags**(**unsigned int** gup_flags) 2090 {

2091 */\**

2092 *\* FOLL_PIN must only be set internally by the pin_user_pages\*() APIs,*

2093 *\* never directly by the caller, so enforce that with an assertion:*

2094 *\*/*

2095 **if** (**WARN_ON_ONCE**(gup_flags & **FOLL_PIN**)) 2096 **return false**; 2097 */\**

2098 *\* FOLL_PIN is a prerequisite to FOLL_LONGTERM. Another way of saying*

2099 *\* that is, FOLL_LONGTERM is a specific case, more restrictive case of*

2100 *\* FOLL_PIN.*

2101 *\*/*

2102 **if** (**WARN_ON_ONCE**(gup_flags & **FOLL_LONGTERM**)) 2103 **return false**; 2104

 



 

2105 **return true**;

2106 }

 

*Listing 8-16:* mm/gup.c: [*is_valid_gup_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2089)

 

This enforces the rule that FOLL_PIN and FOLL_LONGTERM flags can only be set

by the pin\_\*() functions.

Examining the pin variant, [pin_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3221):-

 

3204 */\*\**

3205 *\* pin_user_pages() - pin user pages in memory for use by other devices* 3206 *\**

3207 *\* @start:* *starting user address* 3208 *\* @nr_pages:* *number of pages from start to pin* 3209 *\* @gup_flags: flags modifying lookup behaviour* 3210 *\* @pages:* *array that receives pointers to the pages pinned.* 3211 *\** *Should be at least nr_pages long.* 3212 *\* @vmas:* *array of pointers to vmas corresponding to each page.* 3213 *\** *Or NULL if the caller does not require them.* 3214 *\**

3215 *\* Nearly the same as get_user_pages(), except that FOLL_TOUCH is not set, and*

3216 *\* FOLL_PIN is set.*

3217 *\**

3218 *\* FOLL_PIN means that the pages must be released via unpin_user_page().*

*Please*

3219 *\* see Documentation/core-api/pin_user_pages.rst for details.* 3220 *\*/*

3221 **long pin_user_pages**(**unsigned long** start, **unsigned long** nr_pages, 3222 **unsigned int** gup_flags, **struct** page \*\*pages, 3223 **struct** vm_area_struct \*\*vmas) 3224 {

3225 */\* FOLL_GET and FOLL_PIN are mutually exclusive. \*/* 3226 **if** (**WARN_ON_ONCE**(gup_flags & **FOLL_GET**)) 3227 **return**-**EINVAL**; 3228

3229 **if** (**WARN_ON_ONCE**(!pages)) 3230 **return**-**EINVAL**; 3231

3232 gup_flags \|= **FOLL_PIN**; 3233 **return \_\_gup_longterm_locked**(current-\>mm, start, nr_pages, 3234 pages, vmas, gup_flags); 3235 }

 

*Listing 8-17:* mm/gup.c: [*pin_user_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3221)

 

This performs a check to ensure that FOLL_GET is not set, setting FOLL_PIN

before again invoking the shared function [\_\_gup_longterm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063) to do the

heavy lifting.

Examining the remote variant, [get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2198)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2198)

 



 

2138 */\*\**

2139 *\* get_user_pages_remote() - pin user pages in memory* 2140 *\* @mm:* *mm_struct of target mm* 2141 *\* @start:* *starting user address* 2142 *\* @nr_pages:* *number of pages from start to pin* 2143 *\* @gup_flags: flags modifying lookup behaviour* 2144 *\* @pages:* *array that receives pointers to the pages pinned.* 2145 *\** *Should be at least nr_pages long. Or NULL, if caller* 2146 *\** *only intends to ensure the pages are faulted in.* 2147 *\* @vmas:* *array of pointers to vmas corresponding to each page.* 2148 *\** *Or NULL if the caller does not require them.* 2149 *\* @locked:* *pointer to lock flag indicating whether lock is held and* 2150 *\** *subsequently whether VM_FAULT_RETRY functionality can be* 2151 *\** *utilised. Lock must initially be held.* 2152 *\**

2153 *\* Returns either number of pages pinned (which may be less than the* 2154 *\* number requested), or an error. Details about the return value:* 2155 *\**

2156 *\* -- If nr_pages is 0, returns 0.* 2157 *\* -- If nr_pages is \>0, but no pages were pinned, returns -errno.* 2158 *\* -- If nr_pages is \>0, and some pages were pinned, returns the number of*

2159 *\** *pages pinned. Again, this may be less than nr_pages.* 2160 *\**

2161 *\* The caller is responsible for releasing returned @pages, via put_page().*

2162 *\**

2163 *\* @vmas are valid only as long as mmap_lock is held.* 2164 *\**

2165 *\* Must be called with mmap_lock held for read or write.* 2166 *\**

2167 *\* get_user_pages_remote walks a process's page tables and takes a reference*

2168 *\* to each struct page that each user address corresponds to at a given* 2169 *\* instant. That is, it takes the page that would be accessed if a user* 2170 *\* thread accesses the given user virtual address at that instant.* 2171 *\**

2172 *\* This does not guarantee that the page exists in the user mappings when*

2173 *\* get_user_pages_remote returns, and there may even be a completely different*

2174 *\* page there in some cases (eg. if mmapped pagecache has been invalidated*

2175 *\* and subsequently re faulted). However it does guarantee that the page* 2176 *\* won't be freed completely. And mostly callers simply care that the page*

2177 *\* contains data that was valid \*at some point in time\*. Typically, an IO*

2178 *\* or similar operation cannot guarantee anything stronger anyway because*

2179 *\* locks can't be held over the syscall boundary.* 2180 *\**

2181 *\* If gup_flags & FOLL_WRITE == 0, the page must not be written to. If the*

*page*

2182 *\* is written to, set_page_dirty (or set_page_dirty_lock, as appropriate) must*

2183 *\* be called after the page is finished with, and before put_page is called.*

 



 

2184 *\**

2185 *\* get_user_pages_remote is typically used for fewer-copy IO operations,* 2186 *\* to get a handle on the memory by some means other than accesses* 2187 *\* via the user virtual addresses. The pages may be submitted for* 2188 *\* DMA to devices or accessed via their kernel linear mapping (via the* 2189 *\* kmap APIs). Care should be taken to use the correct cache flushing APIs.*

2190 *\**

2191 *\* See also get_user_pages_fast, for performance critical applications.* 2192 *\**

2193 *\* get_user_pages_remote should be phased out in favor of* 2194 *\* get_user_pages_locked\|unlocked or get_user_pages_fast. Nothing* 2195 *\* should use get_user_pages_remote because it cannot pass* 2196 *\* FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.* 2197 *\*/*

2198 **long get_user_pages_remote**(**struct** mm_struct \*mm, 2199 **unsigned long** start, **unsigned long** nr_pages, 2200 **unsigned int** gup_flags, **struct** page \*\*pages, 2201 **struct** vm_area_struct \*\*vmas, **int** \*locked) 2202 {

2203 **if** (!**is_valid_gup_flags**(gup_flags)) 2204 **return**-**EINVAL**; 2205

2206 **return \_\_get_user_pages_remote**(mm, start, nr_pages, gup_flags, 2207 pages, vmas, locked); 2208 }

 

*Listing 8-18:* mm/gup.c: [*get_user_pages_remote()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2198)

 

This again checks the flags are valid for the get\_\*() set of GUP func-

tions via [is_valid_gup_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2089) before invoking the shared remote function

[\_\_get_user_pages_remote().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2109)

Examining its pin equivalent, [pin_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3186):-

 

3164 */\*\**

3165 *\* pin_user_pages_remote() - pin pages of a remote process* 3166 *\**

3167 *\* @mm:* *mm_struct of target mm* 3168 *\* @start:* *starting user address* 3169 *\* @nr_pages:* *number of pages from start to pin* 3170 *\* @gup_flags: flags modifying lookup behaviour* 3171 *\* @pages:* *array that receives pointers to the pages pinned.* 3172 *\** *Should be at least nr_pages long.* 3173 *\* @vmas:* *array of pointers to vmas corresponding to each page.* 3174 *\** *Or NULL if the caller does not require them.* 3175 *\* @locked:* *pointer to lock flag indicating whether lock is held and* 3176 *\** *subsequently whether VM_FAULT_RETRY functionality can be* 3177 *\** *utilised. Lock must initially be held.* 3178 *\**

 



 

3179 *\* Nearly the same as get_user_pages_remote(), except that FOLL_PIN is set.*

*See*

3180 *\* get_user_pages_remote() for documentation on the function arguments,*

*because*

3181 *\* the arguments here are identical.* 3182 *\**

3183 *\* FOLL_PIN means that the pages must be released via unpin_user_page().*

*Please*

3184 *\* see Documentation/core-api/pin_user_pages.rst for details.* 3185 *\*/*

3186 **long pin_user_pages_remote**(**struct** mm_struct \*mm, 3187 **unsigned long** start, **unsigned long** nr_pages, 3188 **unsigned int** gup_flags, **struct** page \*\*pages, 3189 **struct** vm_area_struct \*\*vmas, **int** \*locked) 3190 {

3191 */\* FOLL_GET and FOLL_PIN are mutually exclusive. \*/* 3192 **if** (**WARN_ON_ONCE**(gup_flags & **FOLL_GET**)) 3193 **return**-**EINVAL**; 3194

3195 **if** (**WARN_ON_ONCE**(!pages)) 3196 **return**-**EINVAL**; 3197

3198 gup_flags \|= **FOLL_PIN**; 3199 **return \_\_get_user_pages_remote**(mm, start, nr_pages, gup_flags, 3200 pages, vmas, locked); 3201 }

 

*Listing 8-19:* mm/gup.c: [*pin_user_pages_remote()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3186)

 

This checks to ensure that the invalid FOLL_GET is not set, that pages are

specified, and then sets FOLL_PIN before invoking the shared remote function

[\_\_get_user_pages_remote().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2109)

Let’s examine it now:-

 

2109 **static long \_\_get_user_pages_remote**(**struct** mm_struct \*mm, 2110 **unsigned long** start, **unsigned long**

nr_pages,

2111 **unsigned int** gup_flags, **struct** page \*\*

pages,

2112 **struct** vm_area_struct \*\*vmas, **int** \*locked) 2113 {

2114 */\**

2115 *\* Parts of FOLL_LONGTERM behavior are incompatible with* 2116 *\* FAULT_FLAG_ALLOW_RETRY because of the FS DAX check requirement on*

2117 *\* vmas. However, this only comes up if locked is set, and there are*

2118 *\* callers that do request FOLL_LONGTERM, but do not set locked. So,*

2119 *\* allow what we can.* 2120 *\*/*

2121 **if** (gup_flags & **FOLL_LONGTERM**) {

 



 

2122 **if** (**WARN_ON_ONCE**(locked)) 2123 **return**-**EINVAL**; 2124 */\**

2125 *\* This will check the vmas (even if our vmas arg is NULL)*

2126 *\* and return -ENOTSUPP if DAX isn't allowed in this case:*

2127 *\*/*

2128 **return \_\_gup_longterm_locked**(mm, start, nr_pages, pages, 2129 vmas, gup_flags \| **FOLL_TOUCH** \| 2130 **FOLL_REMOTE**); 2131 }

2132

2133 **return \_\_get_user_pages_locked**(mm, start, nr_pages, pages, vmas, 2134 locked, 2135 gup_flags \| **FOLL_TOUCH** \| **FOLL_REMOTE**); 2136 }

 

*Listing 8-20:* mm/gup.c: [*\_\_get_user_pages_remote()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2109)

 

If the FOLL_LONGTERM flag is set, this invokes [\_\_gup_longterm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063) oth-

erwise it invokes [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) and in both cases FOLL_TOUCH and

FOLL_REMOTE are set to indicate that folios should be touched and that a re-

mote mm_struct is being accessed.

Since this function, as well as the others previously examined, ref-

erence [\_\_gup_longterm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063) let’s examine this now (we will examine

[\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) shortly):-

 

2059 */\**

2060 *\* \_\_gup_longterm_locked() is a wrapper for \_\_get_user_pages_locked which* 2061 *\* allows us to process the FOLL_LONGTERM flag.* 2062 *\*/*

2063 **static long \_\_gup_longterm_locked**(**struct** mm_struct \*mm, 2064 **unsigned long** start, 2065 **unsigned long** nr_pages, 2066 **struct** page \*\*pages, 2067 **struct** vm_area_struct \*\*vmas, 2068 **unsigned int** gup_flags) 2069 {

2070 **unsigned int** flags; 2071 **long** rc;

2072

2073 **if** (!(gup_flags & **FOLL_LONGTERM**)) 2074 **return \_\_get_user_pages_locked**(mm, start, nr_pages, pages,

vmas,

2075 **NULL**, gup_flags); 2076 flags = **memalloc_pin_save**(); 2077 **do** {

2078 rc = **\_\_get_user_pages_locked**(mm, start, nr_pages, pages, vmas, 2079 **NULL**, gup_flags); 2080 **if** (rc \<= 0)

 



 

2081 **break**; 2082 rc = **check_and_migrate_movable_pages**(rc, pages, gup_flags); 2083 } **while** (!rc);

2084 **memalloc_pin_restore**(flags); 2085

2086 **return** rc;

2087 }

 

*Listing 8-21:* mm/gup.c: [*\_\_gup_longterm_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063)

 

Note that all invocations of [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) pass NULL as the

locked parameter, which means that, if folios need to be faulted in, they can-not be retried with the mmap_lock being dropped.

If the FOLL_LONGTERM flag is not set, we simply invoke

\_\_get_user_pages_locked() otherwise, if this flag is set, we firstly invoke

[memalloc_pin_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n351) to set the process allocation flag [PF_MEMALLOC_PIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1727)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1727)

This is used by [current_gfp_context()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n203) to mask out the \_\_GFP_MOVABLE alloca-

tion flag for all physical allocations for the process, meaning faulted in folios will be from a page block of non-movable memory. This flag is unset again

after the loop completes via [memalloc_pin_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n359).

In each loop iterate, if we either fail to pin any folios (no forward

progress), or an error arises, we simply exit with that result. Otherwise, we

invoke the function [check_and_migrate_movable_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1935) (eliding huge page and device coherent page code as out of scope):-

 

1929 */\**

1930 *\* Check whether all pages are pinnable, if so return number of pages. If*

*some*

1931 *\* pages are not pinnable, migrate them, and unpin all pages. Return zero if*

1932 *\* pages were migrated, or if some pages were not successfully isolated.* 1933 *\* Return negative error if migration fails.* 1934 *\*/*

1935 **static long check_and_migrate_movable_pages**(**unsigned long** nr_pages, 1936 **struct** page \*\*pages, 1937 **unsigned int** gup_flags) 1938 {

1939 **unsigned long** isolation_error_count = 0, i; 1940 **struct** folio \*prev_folio = **NULL**; 1941 **LIST_HEAD**(movable_page_list); 1942 **bool** drain_allow = **true**, coherent_pages = **false**; 1943 **int** ret = 0;

1944

1945 **for** (i = 0; i \< nr_pages; i++) { 1946 **struct** folio \*folio = **page_folio**(pages\[i\]); 1947

1948 **if** (folio == prev_folio) 1949 **continue**; 1950 prev_folio = folio;

. . .

 



 

1982 **if** (**folio_is_longterm_pinnable**(folio)) 1983 **continue**;

. . .

1994 **if** (!**folio_test_lru**(folio) && drain_allow) { 1995 **lru_add_drain_all**(); 1996 drain_allow = **false**; 1997 }

1998

1999 **if** (**folio_isolate_lru**(folio)) { 2000 isolation_error_count++; 2001 **continue**; 2002 }

2003 **list_add_tail**(&folio-\>lru, &movable_page_list); 2004 **node_stat_mod_folio**(folio, 2005 **NR_ISOLATED_ANON** + **folio_is_file_lru**(folio

),

2006 **folio_nr_pages**(folio)); 2007 }

2008

2009 **if** (!**list_empty**(&movable_page_list) \|\| isolation_error_count \|\| 2010 coherent_pages) 2011 **goto unpin_pages**; 2012

2013 */\**

2014 *\* If list is empty, and no isolation errors, means that all pages are*

2015 *\* in the correct zone.* 2016 *\*/*

2017 **return** nr_pages;

 

*Listing 8-22:* mm/gup.c: [*check_and_migrate_movable_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1935) *get movable pages*

This is used to determine how many folios are actually long-term

pinnable and, if any are not, unpin them all, before trying to migrate all non-

movable folios.

This function has 3 different possible return values – nr_pages, the num-

ber of folios that were passed to it (i.e. the number that were able to be

pinned by [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) 0 if migration succeeded and a negative

number if an error arose.

Therefore, if we succeed at migrating folios we try pinning them again in

the next iteration of the loop.

The first part of this function tries to determine how many folios need

migration, storing them in movable_page_list and performing the steps (ex-

amining distinct folios only):-

 

1. Check whether the folio is long-term pinnable via the function

[folio_is_longterm_pinnable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1565). If so, then examine the next folio.

2. If the folio is non-LRU, i.e. in a folio batch awaiting LRU designation,

trigger an LRU drain (see section 11.7.12), but only once during the iteration in order to rate-limit this expensive operation.

 



 

3. Try to isolate the folio (remove it from all existing LRU lists) via

[folio_isolate_lru()\*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2254) , if the isolation attempt fails (i.e. the folio has become non-LRU since the drain), the isolation_error_count is incre-mented.

4. Append the folio to the movable_page_list and update statistics.

 

If, in this process no folios are found that fail the

folio_is_longterm_pinnable() test, we simply return the nr_pages to indi-cate that no action was taken. Otherwise we proceed with the unpinning.

Examining [folio_is_longterm_pinnable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1565):-

 

1565 **static inline bool folio_is_longterm_pinnable**(**struct** folio \*folio) 1566 {

1567 **return is_longterm_pinnable_page**(&folio-\>page); 1568 }

 

*Listing 8-23:* include/linux/mm.h: [*folio_is_longterm_pinnable()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1565)

Which invokes [is_longterm_pinnable_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1539) (eliding out of scope CMA

handling):-

 

1539 **static inline bool is_longterm_pinnable_page**(**struct** page \*page) 1540 {

. . .

1547 */\* The zero page may always be pinned \*/* 1548 **if** (**is_zero_pfn**(**page_to_pfn**(page))) 1549 **return true**; 1550

1551 */\* Coherent device memory must always allow eviction. \*/* 1552 **if** (**is_device_coherent_page**(page)) 1553 **return false**; 1554

1555 */\* Otherwise, non-movable zone pages can be pinned. \*/* 1556 **return** !**is_zone_movable_page**(page); 1557 }

 

*Listing 8-24:* include/linux/mm.h: [*is_longterm_pinnable_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1539)

By default, the zero page is pinnable as by its nature it never moves. De-

vice coherent memory (out of scope for the book) is absolutely not pinnable.

Finally we are left with [is_zone_movable_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n811):-

 

811 **static inline bool is_zone_movable_page**(**const struct** page \*page) 812 {

813 **return page_zonenum**(page) == **ZONE_MOVABLE**; 814 }

 

\*. See the reclaim chapter for more details on [folio_isolate_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2254), however broadly this pulls a

page out of its current LRU list ready for it to be transferred into another. See section 11.2 for more on LRUs as a concept.

 



 

*Listing 8-25:* include/linux/mmzone.h: [*is_zone_movable_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n811)

 

For the majority of examined pages the need to migrate to an unmovable

page block will be determined by whether they are located in [ZONE_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n503) or

not.

Once the list of movable pages is established in movable_page_list, we

move on to attempting to migrate them:-

 

2019 **unpin_pages**:

2020 */\**

2021 *\* pages\[i\] might be NULL if any device coherent pages were found.*

2022 *\*/*

2023 **for** (i = 0; i \< nr_pages; i++) { 2024 **if** (!pages\[i\]) 2025 **continue**; 2026

2027 **if** (gup_flags & **FOLL_PIN**) 2028 **unpin_user_page**(pages\[i\]); 2029 **else**

2030 **put_page**(pages\[i\]); 2031 }

2032

2033 **if** (!**list_empty**(&movable_page_list)) { 2034 **struct** migration_target_control mtc = { 2035 .nid = **NUMA_NO_NODE**, 2036 .gfp_mask = **GFP_USER** \| **\_\_GFP_NOWARN**, 2037 };

2038

2039 ret = **migrate_pages**(&movable_page_list, alloc_migration_target

,

2040 **NULL**, (**unsigned long**)&mtc, **MIGRATE_SYNC**, 2041 **MR_LONGTERM_PIN**, **NULL**); 2042 **if** (ret \> 0) */\* number of pages not migrated \*/* 2043 ret = -**ENOMEM**; 2044 }

2045

2046 **if** (ret && !**list_empty**(&movable_page_list)) 2047 **putback_movable_pages**(&movable_page_list); 2048 **return** ret;

2049 }

 

*Listing 8-26:* mm/gup.c: [*check_and_migrate_movable_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1935) *unpin pages*

 

This starts by relinquishing the reference count on each page acquired

when invoking [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387), or if the page was GUP-pinned un-

pinned via [unpin_user_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n240). We are about to migrate these which requires

them to be unpinned.

 



 

If we have at least some pages to move we then invoke [migrate_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n1395)

to do so (see the chapter on migration for details as to how this functions). Finally, if an error occurred on migration we put the pages back where they

were via [putback_movable_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n137)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n137)

 

**8.1.5.1 Unlocked GUP Functions**

We have now examined the key non-fast interfaces to the GUP function-ality, however there are a few functions which are entered without the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) held, first of which is [\_\_gup_longterm_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2892)

which is invoked by [internal_get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2964) when the fast path cannot be used:-

 

2892 **static int \_\_gup_longterm_unlocked**(**unsigned long** start, **int** nr_pages, 2893 **unsigned int** gup_flags, **struct** page \*\*pages

)

2894 {

2895 **int** ret;

2896

2897 */\**

2898 *\* FIXME: FOLL_LONGTERM does not work with* 2899 *\* get_user_pages_unlocked() (see comments in that function)* 2900 *\*/*

2901 **if** (gup_flags & **FOLL_LONGTERM**) { 2902 **mmap_read_lock**(current-\>mm); 2903 ret = **\_\_gup_longterm_locked**(current-\>mm, 2904 start, nr_pages, 2905 pages, **NULL**, gup_flags); 2906 **mmap_read_unlock**(current-\>mm); 2907 } **else** {

2908 ret = **get_user_pages_unlocked**(start, nr_pages, 2909 pages, gup_flags); 2910 }

2911

2912 **return** ret;

2913 }

 

*Listing 8-27:* mm/gup.c: [*\_\_gup_longterm_unlocked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2892)

 

This simply invokes [\_\_gup_longterm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063) when FOLL_LONGTERM is set (see

listing 8-21) with a newly acquired read lock on the mmap_lock semaphore,

otherwise it invokes the more general exported [get_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2272) function:-

 

2257 */\**

2258 *\* get_user_pages_unlocked() is suitable to replace the form:* 2259 *\**

2260 *\** *mmap_read_lock(mm);* 2261 *\** *get_user_pages(mm, ..., pages, NULL);*

 



 

2262 *\** *mmap_read_unlock(mm);* 2263 *\**

2264 *\* with:*

2265 *\**

2266 *\** *get_user_pages_unlocked(mm, ..., pages);* 2267 *\**

2268 *\* It is functionally equivalent to get_user_pages_fast so* 2269 *\* get_user_pages_fast should be used instead if specific gup_flags* 2270 *\* (e.g. FOLL_FORCE) are not required.* 2271 *\*/*

2272 **long get_user_pages_unlocked**(**unsigned long** start, **unsigned long** nr_pages, 2273 **struct** page \*\*pages, **unsigned int** gup_flags) 2274 {

2275 **struct** mm_struct \*mm = current-\>mm; 2276 **int** locked = 1;

2277 **long** ret;

2278

2279 */\**

2280 *\* FIXME: Current FOLL_LONGTERM behavior is incompatible with* 2281 *\* FAULT_FLAG_ALLOW_RETRY because of the FS DAX check requirement on*

2282 *\* vmas. As there are no users of this flag in this call we simply*

2283 *\* disallow this option for now.* 2284 *\*/*

2285 **if** (**WARN_ON_ONCE**(gup_flags & **FOLL_LONGTERM**)) 2286 **return**-**EINVAL**; 2287

2288 **mmap_read_lock**(mm); 2289 ret = **\_\_get_user_pages_locked**(mm, start, nr_pages, pages, **NULL**, 2290 &locked, gup_flags \| **FOLL_TOUCH**); 2291 **if** (locked)

2292 **mmap_read_unlock**(mm); 2293 **return** ret;

2294 }

 

*Listing 8-28:* mm/gup.c: [*get_user_pages_unlocked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2272)

 

Again, this defers the heavy lifting to [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) af-

ter checking that FOLL_LONGTERM is not set (as this should be handled by

[\_\_gup_longterm_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2892) instead). Note that fault handling can result in the

mmap_lock being released so that is tracked and we only attempt to unlock if

the lock is still held (see section 6 for more on page faulting).

Finally, the GUP-pinned variant of this function, [pin_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3243)

mirrors its locked version [pin_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3221) in that it asserts that pages must

be specified, that FOLL_GET cannot be and sets FOLL_PIN if not already specified

before invoking [get_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2272) to do the heavy lifting:-

 

3238 */\**

3239 *\* pin_user_pages_unlocked() is the FOLL_PIN variant of* 3240 *\* get_user_pages_unlocked(). Behavior is the same, except that this one sets*

 



 

3241 *\* FOLL_PIN and rejects FOLL_GET.* 3242 *\*/*

3243 **long pin_user_pages_unlocked**(**unsigned long** start, **unsigned long** nr_pages, 3244 **struct** page \*\*pages, **unsigned int** gup_flags) 3245 {

3246 */\* FOLL_GET and FOLL_PIN are mutually exclusive. \*/* 3247 **if** (**WARN_ON_ONCE**(gup_flags & **FOLL_GET**)) 3248 **return**-**EINVAL**; 3249

3250 **if** (**WARN_ON_ONCE**(!pages)) 3251 **return**-**EINVAL**; 3252

3253 gup_flags \|= **FOLL_PIN**; 3254 **return get_user_pages_unlocked**(start, nr_pages, pages, gup_flags); 3255 }

 

*Listing 8-29:* mm/gup.c: [*pin_user_pages_unlocked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3243)

 

**8.1.5.2 Core Non-Fast GUP Functions**

All non-fast GUP functions eventually invoke [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) The bulk of this function is dedicated to handling fault retrying logic, which oc-curs where the lock parameter is non-NULL. Examining the start of the func-tion, which is the entirety of the logic should the caller not wish to retry:-

 

1383 */\**

1384 *\* Please note that this function, unlike \_\_get_user_pages will not* 1385 *\* return 0 for nr_pages \> 0 without FOLL_NOWAIT* 1386 *\*/*

1387 **static \_\_always_inline long \_\_get_user_pages_locked**(**struct** mm_struct \*mm, 1388 **unsigned long** start, 1389 **unsigned long** nr_pages, 1390 **struct** page \*\*pages, 1391 **struct** vm_area_struct \*\*vmas, 1392 **int** \*locked, 1393 **unsigned int** flags) 1394 {

1395 **long** ret, pages_done; 1396 **bool** lock_dropped; 1397

1398 **if** (locked) {

1399 */\* if VM_FAULT_RETRY can be returned, vmas become invalid \*/*

1400 **BUG_ON**(vmas); 1401 */\* check caller initialized locked \*/* 1402 **BUG_ON**(\*locked != 1); 1403 }

1404

1405 **if** (flags & **FOLL_PIN**)

 



 

1406 **mm_set_has_pinned_flag**(&mm-\>flags); 1407

1408 */\**

1409 *\* FOLL_PIN and FOLL_GET are mutually exclusive. Traditional behavior*

1410 *\* is to set FOLL_GET if the caller wants pages\[\] filled in (but has*

1411 *\* carelessly failed to specify FOLL_GET), so keep doing that, but*

*only*

1412 *\* for FOLL_GET, not for the newer FOLL_PIN.* 1413 *\**

1414 *\* FOLL_PIN always expects pages to be non-null, but no need to assert*

1415 *\* that here, as any failures will be obvious enough.* 1416 *\*/*

1417 **if** (pages && !(flags & **FOLL_PIN**)) 1418 flags \|= **FOLL_GET**; 1419

1420 pages_done = 0;

1421 lock_dropped = **false**; 1422 **for** (;;) {

1423 ret = **\_\_get_user_pages**(mm, start, nr_pages, flags, pages, 1424 vmas, locked); 1425 **if** (!locked) 1426 */\* VM_FAULT_RETRY couldn't trigger, bypass \*/* 1427 **return** ret;

 

*Listing 8-30:* mm/gup.c: [*\_\_get_user_pages_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) *non-retry logic*

 

We perform some sanity checks, set FOLL_GET if pages are specified but this

flag was not before performing the heavy lifting in [\_\_get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140) We

also set the [MMF_HAS_PINNED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n84) flag for the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object as described

previously if the page is to be pinned.

The lock parameter determines whether the page faulting mechanism

returning [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) or [VM_FAULT_COMPLETED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n755) can be handled. These are re-

turned when the [FAULT_FLAG_ALLOW_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n866) flag is specified to the fault-handler

(see section 6 for more on page faulting and the page cache chapter for

more on this specific behaviour) when a file-backed folio is locked typically

for write-back.

When this flag is set and the folio lock can’t be obtained, the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) lock is dropped in order to not have to block on

the writeback operation and t make forward progress without having to wait

for the lock to be released, in order to reduce contention on the mmap_lock.

Only functions which can handle the lock being dropped are able to do

this, specifically [\_\_get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2109) and [get_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2272) and

their callers– see figure 8-1 to see which functions these are, others simply

pass NULL as the lock parameter and thus this logic is skipped in these cases.

Examining the remainder of the function (reiterating the start of the

loop for clarity) which handles this case:-

 

1422 **for** (;;) {

1423 ret = **\_\_get_user_pages**(mm, start, nr_pages, flags, pages,

 



 

1424 vmas, locked);

. . .

1429 */\* VM_FAULT_RETRY or VM_FAULT_COMPLETED cannot return errors*

*\*/*

1430 **if** (!\*locked) { 1431 **BUG_ON**(ret \< 0); 1432 **BUG_ON**(ret \>= nr_pages); 1433 }

1434

1435 **if** (ret \> 0) { 1436 nr_pages -= ret; 1437 pages_done += ret; 1438 **if** (!nr_pages) 1439 **break**; 1440 }

1441 **if** (\*locked) { 1442 */\** 1443 *\* VM_FAULT_RETRY didn't trigger or it was a* 1444 *\* FOLL_NOWAIT.* 1445 *\*/* 1446 **if** (!pages_done) 1447 pages_done = ret; 1448 **break**; 1449 }

1450 */\**

1451 *\* VM_FAULT_RETRY triggered, so seek to the faulting offset.*

1452 *\* For the prefault case (!pages) we only update counts.*

1453 *\*/*

1454 **if** (**likely**(pages)) 1455 pages += ret; 1456 start += ret \<\< **PAGE_SHIFT**; 1457 lock_dropped = **true**; 1458

1459 **retry**:

1460 */\**

1461 *\* Repeat on the address that fired VM_FAULT_RETRY* 1462 *\* with both FAULT_FLAG_ALLOW_RETRY and* 1463 *\* FAULT_FLAG_TRIED. Note that GUP can be interrupted* 1464 *\* by fatal signals, so we need to check it before we* 1465 *\* start trying again otherwise it can loop forever.* 1466 *\*/*

1467

1468 **if** (**fatal_signal_pending**(current)) { 1469 **if** (!pages_done) 1470 pages_done = -**EINTR**; 1471 **break**; 1472 }

 



 

1473

1474 ret = **mmap_read_lock_killable**(mm); 1475 **if** (ret) { 1476 **BUG_ON**(ret \> 0); 1477 **if** (!pages_done) 1478 pages_done = ret; 1479 **break**; 1480 }

1481

1482 \*locked = 1; 1483 ret = **\_\_get_user_pages**(mm, start, 1, flags \| **FOLL_TRIED**, 1484 pages, **NULL**, locked); 1485 **if** (!\*locked) { 1486 */\* Continue to retry until we succeeded \*/* 1487 **BUG_ON**(ret != 0); 1488 **goto retry**; 1489 }

1490 **if** (ret != 1) { 1491 **BUG_ON**(ret \> 1); 1492 **if** (!pages_done) 1493 pages_done = ret; 1494 **break**; 1495 }

1496 nr_pages--; 1497 pages_done++; 1498 **if** (!nr_pages) 1499 **break**; 1500 **if** (**likely**(pages)) 1501 pages++; 1502 start += **PAGE_SIZE**; 1503 }

1504 **if** (lock_dropped && \*locked) { 1505 */\**

1506 *\* We must let the caller know we temporarily dropped the lock*

1507 *\* and so the critical section protected by it was lost.* 1508 *\*/*

1509 **mmap_read_unlock**(mm); 1510 \*locked = 0; 1511 }

1512 **return** pages_done; 1513 }

 

*Listing 8-31:* mm/gup.c: [*\_\_get_user_pages_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) *retry logic*

 

The logic is as follows:-

 

1. Attempt to process nr_pages pages started at address start via

[\_\_get_user_pages() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140)

 



 

2. Assert that neither an error occurred nor do we appear to have pro-

cessed more pages than expected (\_\_get_user_pages() returns either a positive number of pages processed or a negative error).

3. Update nr_pages and pages_done counts and if we have processed suffi-

cient pages, exit the loop.

4. We are now in the position where pages remain to be processed – if the

lock has not been dropped then we are not in the retry logic and thus must exit.

5. If the pages array of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) pointers was provided, then we update

the variable to point to the offset position based on how many pages have been processed.

Whether this was specified or not, offset start and set lock_dropped so we know to drop the lock before returning so the caller is aware the lock was dropped at least once even if it is later reacquired.

6. Check to see if a fatal signal is pending via [fatal_signal_pending()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n408). If so,

then continuing this operation is not useful and we should exit the loop.

7. Attempt to reacquire a read lock on the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

semaphore via [mmap_read_lock_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n121)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n121) If this fails, we return the error code.

8. Try to process (and thus fault in) one page via [\_\_get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140) with

FOLL_TRIED set to indicate that we have retried once. If we have to retry again (i.e. the lock has been dropped again), we keep retrying this oper-ation from step 6 until we succeed or an error occurs.

9. On success, update the counts and offsets accordingly and if we are

done, exit the loop, otherwise repeat the whole operation from step 1 again until we are done or an error occurs.

 

Now we will examine the core non-fast handler, [\_\_get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140), start-

ing with the rather complete comment describing it and initial checks and initialisation:-

 

1080 */\*\**

1081 *\* \_\_get_user_pages() - pin user pages in memory* 1082 *\* @mm:* *mm_struct of target mm* 1083 *\* @start:* *starting user address* 1084 *\* @nr_pages:* *number of pages from start to pin* 1085 *\* @gup_flags: flags modifying pin behaviour* 1086 *\* @pages:* *array that receives pointers to the pages pinned.* 1087 *\** *Should be at least nr_pages long. Or NULL, if caller* 1088 *\** *only intends to ensure the pages are faulted in.* 1089 *\* @vmas:* *array of pointers to vmas corresponding to each page.* 1090 *\** *Or NULL if the caller does not require them.* 1091 *\* @locked:* *whether we're still with the mmap_lock held* 1092 *\**

1093 *\* Returns either number of pages pinned (which may be less than the* 1094 *\* number requested), or an error. Details about the return value:*

 



 

1095 *\**

1096 *\* -- If nr_pages is 0, returns 0.* 1097 *\* -- If nr_pages is \>0, but no pages were pinned, returns -errno.* 1098 *\* -- If nr_pages is \>0, and some pages were pinned, returns the number of*

1099 *\** *pages pinned. Again, this may be less than nr_pages.* 1100 *\* -- 0 return value is possible when the fault would need to be retried.* 1101 *\**

1102 *\* The caller is responsible for releasing returned @pages, via put_page().*

1103 *\**

1104 *\* @vmas are valid only as long as mmap_lock is held.* 1105 *\**

1106 *\* Must be called with mmap_lock held. It may be released. See below.* 1107 *\**

1108 *\* \_\_get_user_pages walks a process's page tables and takes a reference to*

1109 *\* each struct page that each user address corresponds to at a given* 1110 *\* instant. That is, it takes the page that would be accessed if a user* 1111 *\* thread accesses the given user virtual address at that instant.* 1112 *\**

1113 *\* This does not guarantee that the page exists in the user mappings when* 1114 *\* \_\_get_user_pages returns, and there may even be a completely different* 1115 *\* page there in some cases (eg. if mmapped pagecache has been invalidated*

1116 *\* and subsequently re faulted). However it does guarantee that the page* 1117 *\* won't be freed completely. And mostly callers simply care that the page*

1118 *\* contains data that was valid \*at some point in time\*. Typically, an IO* 1119 *\* or similar operation cannot guarantee anything stronger anyway because* 1120 *\* locks can't be held over the syscall boundary.* 1121 *\**

1122 *\* If @gup_flags & FOLL_WRITE == 0, the page must not be written to. If* 1123 *\* the page is written to, set_page_dirty (or set_page_dirty_lock, as* 1124 *\* appropriate) must be called after the page is finished with, and* 1125 *\* before put_page is called.* 1126 *\**

1127 *\* If @locked != NULL, \*@locked will be set to 0 when mmap_lock is* 1128 *\* released by an up_read(). That can happen if @gup_flags does not* 1129 *\* have FOLL_NOWAIT.*

1130 *\**

1131 *\* A caller using such a combination of @locked and @gup_flags* 1132 *\* must therefore hold the mmap_lock for reading only, and recognize* 1133 *\* when it's been released. Otherwise, it must be held for either* 1134 *\* reading or writing and will not be released.* 1135 *\**

1136 *\* In most cases, get_user_pages or get_user_pages_fast should be used* 1137 *\* instead of \_\_get_user_pages. \_\_get_user_pages should be used only if* 1138 *\* you need some special @gup_flags.* 1139 *\*/*

1140 **static long \_\_get_user_pages**(**struct** mm_struct \*mm, 1141 **unsigned long** start, **unsigned long** nr_pages,

 



 

1142 **unsigned int** gup_flags, **struct** page \*\*pages, 1143 **struct** vm_area_struct \*\*vmas, **int** \*locked) 1144 {

1145 **long** ret = 0, i = 0; 1146 **struct** vm_area_struct \*vma = **NULL**; 1147 **struct** follow_page_context ctx = { **NULL** }; 1148

1149 **if** (!nr_pages)

1150 **return** 0; 1151

1152 start = **untagged_addr**(start); 1153

1154 **VM_BUG_ON**(!!pages != !!(gup_flags & (**FOLL_GET** \| **FOLL_PIN**))); 1155

1156 */\**

1157 *\* If FOLL_FORCE is set then do not force a full fault as the hinting*

1158 *\* fault information is unrelated to the reference behaviour of a task*

1159 *\* using the address space* 1160 *\*/*

1161 **if** (!(gup_flags & **FOLL_FORCE**)) 1162 gup_flags \|= **FOLL_NUMA**;

 

*Listing 8-32:* mm/gup.c: [*\_\_get_user_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140) *initialisation*

 

This starts by initialising local variables and handling the trivial case

where nr_pages is zero. The invocation of untagged_addr() is only relevant to architectures which tag addresses (x86-64, the architecture we examine in this book does not).

The key points here are that – if pages are specified then either FOLL_GET

or FOLL_PIN must be specified, equally if either of these flags are specified, then pages must be too (you cannot unpin pages without having a reference to them).

Finally, FOLL_NUMA is specified for all cases except FOLL_FORCE which causes

the GUP code to trigger a full fault when NUMA balancing is indicated\*. Ex-amining the remainder of the function which comprises its main loop (elid-ing out of scope gate area, huge page, device page map and manual cache maintenance logic):-

 

1164 **do** {

1165 **struct** page \*page; 1166 **unsigned int** foll_flags = gup_flags; 1167 **unsigned int** page_increm; 1168

1169 */\* first iteration or cross vma bound \*/* 1170 **if** (!vma \|\| start \>= vma-\>vm_end) {

 

\*. NUMA balancing is a process by which the kernel periodically unmaps memory and remaps it on a local node if it was not already.

 



 

1171 vma = **find_extend_vma**(mm, start);

. . .

1182 **if** (!vma) { 1183 ret = -**EFAULT**; 1184 **goto out**; 1185 } 1186 ret = **check_vma_flags**(vma, gup_flags); 1187 **if** (ret) 1188 **goto out**;

. . .

1205 }

1206 **retry**:

1207 */\**

1208 *\* If we have a pending SIGKILL, don't keep faulting pages and*

1209 *\* potentially allocating memory.* 1210 *\*/*

1211 **if** (**fatal_signal_pending**(current)) { 1212 ret = -**EINTR**; 1213 **goto out**; 1214 }

1215 **cond_resched**(); 1216

1217 page = **follow_page_mask**(vma, start, foll_flags, &ctx); 1218 **if** (!page \|\| **PTR_ERR**(page) == -**EMLINK**) { 1219 ret = **faultin_page**(vma, start, &foll_flags, 1220 **PTR_ERR**(page) == -**EMLINK**, locked); 1221 **switch** (ret) { 1222 **case** 0: 1223 **goto retry**; 1224 **case**-**EBUSY**: 1225 **case**-**EAGAIN**: 1226 ret = 0; 1227 **fallthrough**; 1228 **case**-**EFAULT**: 1229 **case**-**ENOMEM**: 1230 **case**-**EHWPOISON**: 1231 **goto out**; 1232 } 1233 **BUG**(); 1234 } **else if** (**PTR_ERR**(page) == -**EEXIST**) { 1235 */\** 1236 *\* Proper page table entry exists, but no*

*corresponding*

1237 *\* struct page. If the caller expects \*\*pages to be*

1238 *\* filled in, bail out now, because that can't be done*

1239 *\* for this page.* 1240 *\*/*

 



 

1241 **if** (pages) { 1242 ret = **PTR_ERR**(page); 1243 **goto out**; 1244 } 1245

1246 **goto next_page**; 1247 } **else if** (**IS_ERR**(page)) { 1248 ret = **PTR_ERR**(page); 1249 **goto out**; 1250 }

1251 **if** (pages) { 1252 pages\[i\] = page;

. . .

1256 }

1257 **next_page**:

1258 **if** (vmas) { 1259 vmas\[i\] = vma;

. . .

1261 }

1262 page_increm = 1 + (~(start \>\> **PAGE_SHIFT**) & ctx.page_mask);

. . .

1265 i += page_increm; 1266 start += page_increm \* **PAGE_SIZE**; 1267 nr_pages -= page_increm; 1268 } **while** (nr_pages); 1269 **out**:

. . .

1272 **return** i ? i : ret;

 

*Listing 8-33:* mm/gup.c: [*\_\_get_user_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140) *main loop*

 

The logic is as follows:-

 

1. If necessary, retrieve the current VMA containing start via

[find_extend_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2559). This either locates the VMA containing the address, or extends the stack if the range is within the stack. If so, we check that

the VMA flags are consistent via [check_vma_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1027) which we will examine shortly below. If we cannot find a VMA or the check fails we return an error.

2. If a fatal signal is pending we exit early with an EINTR error code. We

check this via [fatal_signal_pending()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n408). We also indicate that the scheduler

can deschedule us in favour of a higher priority task via [cond_resched()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n2082) as at this stage we’re well placed to do so (pertinent if the kernel is not running with full preemption).

3. We walk the page tables for the specified address via [follow_page_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n844),

this either returns a pointer to its [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) object, NULL if the page is not faulted in, or an error if one occurs. We discuss the details of this

function in section 8.1.6 below.

 



 

4. If either the page was not faulted in or an EMLINK error occurred, indicat-

ing that a shared mapping must be unshared (more on this in section

8.1.6), then we try to fault in the page via [faultin_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n960), discussed below

in section 8.1.7.

5. If the faulting in succeeds, we loop to step 2 and repeat the process

again. Note that a race could occur between pages being retrieved from the swap or migration or NUMA balancing or any other such operation and this GUP function so we could loop multiple times here.

6. If the faulting in fails with either EBUSY (indicates VM_FAULT_RETRY was re-

turned by the faulting logic) or EAGAIN (indicates VM_FAULT_COMPLETED was returned by the faulting logic) then we simply exit so the process can be tried again by the caller, otherwise the return value is set to the error code.

7. If [follow_page_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n844) returned the EEXIST error this indicates that the en-

try is valid but there is no struct page associated with the entry. If the user expects pages to be returned, something we now simply cannot do, then we error out, otherwise we simply move on to the next page (see

section 6.12 for more details on this kind of mapping.)

8. If the follow operation simply resulted in an error then set the return

value to that error code and exit.

9. If we succeeded in retrieving a page, place it in the pages array if it exists.

10. If the user requires the VMA to be returned, place a pointer to the VMA

in the supplied array. Note that these will only be valid as long as a lock

on the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore is held.

11. We increment i, which counts the number of base pages we have pro-

cessed, by one. Note that here the logic seems more complicated even with parts of the code elided – this is to handle huge page logic which we exclude from this discussion for the sake of brevity. In non-huge page cases page_increm will always be 1. We additionally increment start by a base page size and decrement nr_pages by 1.

12. Finally, if any pages were processed, we return the count, otherwise we

return an error if any occurred or zero if we could simply not progress. We prioritise indicating how many pages were pinned or had actions performed upon them so the caller can retry or otherwise respond to the fact that others were not processed as they intend.

 

Returning to [check_vma_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1027) (eliding out of scope DAX and secret

memory logic):-

 

1027 **static int check_vma_flags**(**struct** vm_area_struct \*vma, **unsigned long** gup_flags

)

1028 {

1029 **vm_flags_t** vm_flags = vma-\>vm_flags; 1030 **int** write = (gup_flags & **FOLL_WRITE**); 1031 **int** foreign = (gup_flags & **FOLL_REMOTE**);

 



 

1032

1033 **if** (vm_flags & (**VM_IO** \| **VM_PFNMAP**)) 1034 **return**-**EFAULT**; 1035

1036 **if** (gup_flags & **FOLL_ANON** && !**vma_is_anonymous**(vma)) 1037 **return**-**EFAULT**;

. . .

1045 **if** (write) {

1046 **if** (!(vm_flags & **VM_WRITE**)) { 1047 **if** (!(gup_flags & **FOLL_FORCE**)) 1048 **return**-**EFAULT**; 1049 */\** 1050 *\* We used to let the write,force case do COW in a*

1051 *\* VM_MAYWRITE VM_SHARED !VM_WRITE vma, so ptrace*

*could*

1052 *\* set a breakpoint in a read-only mapping of an*

1053 *\* executable, without corrupting the file (yet only*

1054 *\* when that file had been opened for writing!).*

1055 *\* Anon pages in shared mappings are surprising: now*

1056 *\* just reject it.* 1057 *\*/* 1058 **if** (!**is_cow_mapping**(vm_flags)) 1059 **return**-**EFAULT**; 1060 }

1061 } **else if** (!(vm_flags & **VM_READ**)) { 1062 **if** (!(gup_flags & **FOLL_FORCE**)) 1063 **return**-**EFAULT**; 1064 */\**

1065 *\* Is there actually any vma we can reach here which does not*

1066 *\* have VM_MAYREAD set?* 1067 *\*/*

1068 **if** (!(vm_flags & **VM_MAYREAD**)) 1069 **return**-**EFAULT**; 1070 }

1071 */\**

1072 *\* gups are always data accesses, not instruction* 1073 *\* fetches, so execute=false here* 1074 *\*/*

1075 **if** (!**arch_vma_access_permitted**(vma, write, **false**, foreign)) 1076 **return**-**EFAULT**; 1077 **return** 0;

1078 }

 

*Listing 8-34:* mm/gup.c: [*check_vma_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1027)

 

This performs sanity checks on the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s flags

given the specified GUP flags, including permissions checks.

An error is returned if:-

 



 

• Either VM_IO or VM_PFNMAP are specified, indicating that this is a raw map-

ping of device memory or a mapping from kernel memory respectively. These are not regions of memory that can be sanely interacted with via GUP.

• The FOLL_ANON GUP flag has been specified but the VMA is not anony-

mous.

• The VMA is read-only (i.e. does not have the VM_WRITE flag set), but

FOLL_WRITE is specified (unless FOLL_FORCE overrides this). If this is a

potentially-writable shared mapping (as determined by [is_cow_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1219)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1219) then we ignore FOLL_FORCE and error out anyway as indicated by the com-ment.

• The VMA does not permit reading (i.e. the VM_READ flag is cleared) and

FOLL_FORCE is not specified. If FOLL_FORCE is specified but the mapping can never become readable (i.e. does not have VM_MAYREAD set) then we error out regardless.

• The architecture-specific check [arch_vma_access_permitted()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/mmu_context.h?h=v6.0#n207) fails.

 

***8.1.6 Walking Page Tables***

In order to obtain the underlying physical pages below a userland page table

range, we must walk the page tables at each level manually. This process is

performed by a series of functions which operate at each level, beginning at

the PGD level with [follow_page_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n844) (eliding out of scope huge page and

ZONE_DEVICE memory):-

 

820 */\*\**

821 *\* follow_page_mask - look up a page descriptor from a user-virtual address*

822 *\* @vma: vm_area_struct mapping @address* 823 *\* @address: virtual address to look up* 824 *\* @flags: flags modifying lookup behaviour*

. . .

828 *\* @flags can have FOLL\_ flags set, defined in \<linux/mm.h\>*

. . .

833 *\* When getting an anonymous page and the caller has to trigger unsharing* 834 *\* of a shared anonymous page first, -EMLINK is returned. The caller should*

835 *\* trigger a fault with FAULT_FLAG_UNSHARE set. Note that unsharing is only*

836 *\* relevant with FOLL_PIN and !FOLL_WRITE.*

. . .

840 *\* Return: the mapped (struct page \*), %NULL if no mapping exists, or* 841 *\* an error pointer if there is a mapping to something not represented* 842 *\* by a page descriptor (see also vm_normal_page()).* 843 *\*/*

844 **static struct** page \***follow_page_mask**(**struct** vm_area_struct \*vma, 845 **unsigned long** address, **unsigned int** flags, 846 **struct** follow_page_context \*ctx)

 



 

847 {

848 **pgd_t** \*pgd;

849 **struct** page \*page; 850 **struct** mm_struct \*mm = vma-\>vm_mm;

. . .

861 pgd = **pgd_offset**(mm, address); 862

863 **if** (**pgd_none**(\*pgd) \|\| **unlikely**(**pgd_bad**(\*pgd))) 864 **return no_page_table**(vma, flags);

. . .

881 **return follow_p4d_mask**(vma, address, pgd, flags, ctx); 882 }

 

*Listing 8-35:* mm/gup.c: [*follow_page_mask()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n844)

 

On each occasion when a page table entry can’t be found, [no_page_table()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n444)

is invoked. This handles an edge case around core dumping:-

 

444 **static struct** page \***no_page_table**(**struct** vm_area_struct \*vma, 445 **unsigned int** flags) 446 {

447 */\**

448 *\* When core dumping an enormous anonymous area that nobody* 449 *\* has touched so far, we don't want to allocate unnecessary pages or*

450 *\* page tables. Return error instead of NULL to skip handle_mm_fault,*

451 *\* then get_dump_page() will return NULL to leave a hole in the dump.*

452 *\* But we can only make this optimization where a hole would surely*

453 *\* be zero-filled if handle_mm_fault() actually did handle it.* 454 *\*/*

455 **if** ((flags & **FOLL_DUMP**) && 456 (**vma_is_anonymous**(vma) \|\| !vma-\>vm_ops-\>**fault**)) 457 **return ERR_PTR**(-**EFAULT**); 458 **return NULL**;

459 }

 

*Listing 8-36:* mm/gup.c: [*no_page_table()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n444)

 

At each of the page table levels this is invoked when an entry cannot be

found (indicating that the memory needs to be faulted in).

Examining [follow_p4d_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n794) (eliding huge page handling):-

 

794 **static struct** page \***follow_p4d_mask**(**struct** vm_area_struct \*vma, 795 **unsigned long** address, **pgd_t** \*pgdp, 796 **unsigned int** flags, 797 **struct** follow_page_context \*ctx) 798 {

799 **p4d_t** \*p4d;

800 **struct** page \*page; 801

802 p4d = **p4d_offset**(pgdp, address);

 



 

803 **if** (**p4d_none**(\*p4d)) 804 **return no_page_table**(vma, flags);

. . .

806 **if** (**unlikely**(**p4d_bad**(\*p4d))) 807 **return no_page_table**(vma, flags);

. . .

817 **return follow_pud_mask**(vma, address, p4d, flags, ctx); 818 }

 

*Listing 8-37:* mm/gup.c: [*follow_p4d_mask()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n794)

 

This, as with all of the other page table walking logic, simply uses the

p\*d_offset() functions to access each page table level (see the virtual memory

## chapter for more on this). Similarly, [follow_pud_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n754) (eliding out of scope

huge page and device map logic):-

 

754 **static struct** page \***follow_pud_mask**(**struct** vm_area_struct \*vma, 755 **unsigned long** address, **p4d_t** \*p4dp, 756 **unsigned int** flags, 757 **struct** follow_page_context \*ctx) 758 {

759 **pud_t** \*pud;

. . .

761 **struct** page \*page; 762 **struct** mm_struct \*mm = vma-\>vm_mm;

763

764 pud = **pud_offset**(p4dp, address); 765 **if** (**pud_none**(\*pud)) 766 **return no_page_table**(vma, flags);

. . .

788 **if** (**unlikely**(**pud_bad**(\*pud))) 789 **return no_page_table**(vma, flags);

790

791 **return follow_pmd_mask**(vma, address, pud, flags, ctx); 792 }

 

*Listing 8-38:* mm/gup.c: [*follow_pud_mask()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n754)

 

Examining [follow_pmd_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n646) (eliding out of scope huge page logic, huge

page migration logic, device map logic):-

 

646 **static struct** page \***follow_pmd_mask**(**struct** vm_area_struct \*vma, 647 **unsigned long** address, **pud_t** \*pudp, 648 **unsigned int** flags, 649 **struct** follow_page_context \*ctx) 650 {

651 **pmd_t** \*pmd, pmdval; 652 **spinlock_t** \*ptl;

653 **struct** page \*page; 654 **struct** mm_struct \*mm = vma-\>vm_mm;

 



 

655

656 pmd = **pmd_offset**(pudp, address);

. . .

661 pmdval = **READ_ONCE**(\*pmd); 662 **if** (**pmd_none**(pmdval)) 663 **return no_page_table**(vma, flags);

. . .

707 **if** (**likely**(!**pmd_trans_huge**(pmdval))) 708 **return follow_page_pte**(vma, address, pmd, flags, &ctx-\>pgmap);

. . .

752 }

 

*Listing 8-39:* mm/gup.c: [*follow_pmd_mask()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n646)

 

Note that the [pmd_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n816) check is deferred to [follow_page_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519), which we

examine now, eliding out of scope Kernel Same page Merging (KSM) and device mapping logic:-

 

519 **static struct** page \***follow_page_pte**(**struct** vm_area_struct \*vma, 520 **unsigned long** address, **pmd_t** \*pmd, **unsigned int** flags, 521 **struct** dev_pagemap \*\*pgmap) 522 {

523 **struct** mm_struct \*mm = vma-\>vm_mm; 524 **struct** page \*page; 525 **spinlock_t** \*ptl;

526 **pte_t** \*ptep, pte; 527 **int** ret;

528

529 */\* FOLL_GET and FOLL_PIN are mutually exclusive. \*/* 530 **if** (**WARN_ON_ONCE**((flags & (**FOLL_PIN** \| **FOLL_GET**)) == 531 (**FOLL_PIN** \| **FOLL_GET**))) 532 **return ERR_PTR**(-**EINVAL**);

. . .

534 **if** (**unlikely**(**pmd_bad**(\*pmd))) 535 **return no_page_table**(vma, flags); 536

537 ptep = **pte_offset_map_lock**(mm, pmd, address, &ptl); 538 pte = \*ptep;

539 **if** (!**pte_present**(pte)) {

. . .

546 **if** (**likely**(!(flags & **FOLL_MIGRATION**))) 547 **goto no_page**; 548 **if** (**pte_none**(pte)) 549 **goto no_page**;

. . .

556 }

557 **if** ((flags & **FOLL_NUMA**) && **pte_protnone**(pte)) 558 **goto no_page**; 559

 



 

560 page = **vm_normal_page**(vma, address, pte);

 

*Listing 8-40:* mm/gup.c: [*follow_page_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519) *page lookup*

 

We start by asserting that we do not simultaneously specify both FOLL_PIN

and FOLL_GET, before performing the deferred [pmd_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n816) check, acquiring the

PTE lock via [pte_offset_map_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2302) (see the virtual memory chapter for more

on this) before checking whether the PTE entry is present and exiting if not

(eliding out of scope migration logic).

Finally we consider the NUMA hinting case, checked by [pte_protnone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n775), in

this instance no GUP should be performed and it should be treated as if the

page could not be found.

Finally, we obtain the underlying page via [vm_normal_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n612) (see section

6.12 for details).

Next, we perform a series of checks on the page:-

 

562 */\**

563 *\* We only care about anon pages in can_follow_write_pte() and don't*

564 *\* have to worry about pte_devmap() because they are never anon.* 565 *\*/*

566 **if** ((flags & **FOLL_WRITE**) && 567 !**can_follow_write_pte**(pte, page, vma, flags)) { 568 page = **NULL**; 569 **goto out**; 570 }

. . .

583 } **else if** (**unlikely**(!page)) { 584 **if** (flags & **FOLL_DUMP**) { 585 */\* Avoid special (like zero) pages in core dumps \*/*

586 page = **ERR_PTR**(-**EFAULT**); 587 **goto out**; 588 }

589

590 **if** (**is_zero_pfn**(**pte_pfn**(pte))) { 591 page = **pte_page**(pte); 592 } **else** {

593 ret = **follow_pfn_pte**(vma, address, ptep, flags); 594 page = **ERR_PTR**(ret); 595 **goto out**; 596 }

597 }

598

599 **if** (!**pte_write**(pte) && **gup_must_unshare**(flags, page)) { 600 page = **ERR_PTR**(-**EMLINK**); 601 **goto out**; 602 }

603

604 **VM_BUG_ON_PAGE**((flags & **FOLL_PIN**) && **PageAnon**(page) && 605 !**PageAnonExclusive**(page), page);

 



 

*Listing 8-41:* mm/gup.c: [*follow_page_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519) *page checks*

 

Firstly, we determine whether we are permitted to write fault

the memory if the GUP write flag FOLL_WRITE is set. This is done via

[can_follow_write_pte():-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n482)

 

481 */\* FOLL_FORCE can write to even unwritable PTEs in COW mappings. \*/* 482 **static inline bool can_follow_write_pte**(**pte_t** pte, **struct** page \*page, 483 **struct** vm_area_struct \*vma, 484 **unsigned int** flags) 485 {

486 */\* If the pte is writable, we can write to the page. \*/* 487 **if** (**pte_write**(pte)) 488 **return true**; 489

490 */\* Maybe FOLL_FORCE is set to override it? \*/* 491 **if** (!(flags & **FOLL_FORCE**)) 492 **return false**; 493

494 */\* But FOLL_FORCE has no effect on shared mappings \*/* 495 **if** (vma-\>vm_flags & (**VM_MAYSHARE** \| **VM_SHARED**)) 496 **return false**; 497

498 */\* ... or read-only private ones \*/* 499 **if** (!(vma-\>vm_flags & **VM_MAYWRITE**)) 500 **return false**; 501

502 */\* ... or already writable ones that just need to take a write fault*

*\*/*

503 **if** (vma-\>vm_flags & **VM_WRITE**) 504 **return false**; 505

506 */\**

507 *\* See can_change_pte_writable(): we broke COW and could map the page*

508 *\* writable if we have an exclusive anonymous page ...* 509 *\*/*

510 **if** (!page \|\| !**PageAnon**(page) \|\| !**PageAnonExclusive**(page)) 511 **return false**; 512

513 */\* ... and a write-fault isn't required for other reasons. \*/* 514 **if** (**vma_soft_dirty_enabled**(vma) && !**pte_soft_dirty**(pte)) 515 **return false**; 516 **return** !**userfaultfd_pte_wp**(vma, pte); 517 }

 

*Listing 8-42:* mm/gup.c: [*can_follow_write_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n482)

 



 

This starts by checking whether the page tables already map this read-

/write – if so then no write fault will occur and thus we do not need to indi-

cate that this page ought to be faulted in.

All other cases apply only if FOLL_FORCE is specified – the page must be pri-

vate, potentially writable (as determined by the VM_MAYWRITE flag), not already

writable (which a write fault would solve, i.e. not specify VM_WRITE), normal

(not a PFN map or similar), not exclusively anonymous and not in need of a

write fault to satisfy soft-dirty state.

This is a corner case designed to handle the situation where an anony-

mous folio was previously shared in multiple places due to forking, but is

now an exclusive mapping but still a Copy-on-Write mapping (where a Copy-

on-Write operation would simply map this exclusively). This is used for ex-

ample when performing MAP_POPULATE over a memory range mapped PROT_READ

only with a read/write file descriptor where the pages need to be touched.

Finally we consider the mapping is a special mapping, i.e.

[vm_normal_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n612) returns NULL (see section 6.12 for details). In the case that

we are core dumping, i.e. FOLL_DUMP is specified, then we error out as these

should not appearing, otherwise we we either simply return to page in the

case of the zero page or otherwise defer to [follow_pfn_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n461):-

 

461 **static int follow_pfn_pte**(**struct** vm_area_struct \*vma, **unsigned long** address, 462 **pte_t** \*pte, **unsigned int** flags) 463 {

464 **if** (flags & **FOLL_TOUCH**) { 465 **pte_t** entry = \*pte;

466

467 **if** (flags & **FOLL_WRITE**) 468 entry = **pte_mkdirty**(entry); 469 entry = **pte_mkyoung**(entry);

470

471 **if** (!**pte_same**(\*pte, entry)) { 472 **set_pte_at**(vma-\>vm_mm, address, pte, entry); 473 **update_mmu_cache**(vma, address, pte); 474 }

475 }

476

477 */\* Proper page table entry exists, but no corresponding struct page \*/*

478 **return**-**EEXIST**;

479 }

 

*Listing 8-43:* mm/gup.c: [*follow_pfn_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n461)

 

This marks the PTE entry dirty if both FOLL_TOUCH and FOLL_WRITE were

set before returning EEXIST. This indicates to [\_\_get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140) that no

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) could be associated with the address, if the caller requires an ar-

ray of pages then an error is returned otherwise this is not an issue.

Returning to the [follow_page_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519) page checks, we check to see whether

the page mapping is currently marked read-only but needs to be unshared in

order to address a thorny corner case – this is checked in [gup_must_unshare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2985):-

 



 

2968 */\**

2969 *\* Indicates for which pages that are write-protected in the page table,* 2970 *\* whether GUP has to trigger unsharing via FAULT_FLAG_UNSHARE such that the*

2971 *\* GUP pin will remain consistent with the pages mapped into the page tables*

2972 *\* of the MM.*

2973 *\**

2974 *\* Temporary unmapping of PageAnonExclusive() pages or clearing of* 2975 *\* PageAnonExclusive() has to protect against concurrent GUP:* 2976 *\* \* Ordinary GUP: Using the PT lock* 2977 *\* \* GUP-fast and fork(): mm-\>write_protect_seq* 2978 *\* \* GUP-fast and KSM or temporary unmapping (swap, migration):* 2979 *\** *clear/invalidate+flush of the page table entry* 2980 *\**

2981 *\* Must be called with the (sub)page that's actually referenced via the* 2982 *\* page table entry, which might not necessarily be the head page for a* 2983 *\* PTE-mapped THP.*

2984 *\*/*

2985 **static inline bool gup_must_unshare**(**unsigned int** flags, **struct** page \*page) 2986 {

2987 */\**

2988 *\* FOLL_WRITE is implicitly handled correctly as the page table entry*

2989 *\* has to be writable -- and if it references (part of) an anonymous*

2990 *\* folio, that part is required to be marked exclusive.* 2991 *\*/*

2992 **if** ((flags & (**FOLL_WRITE** \| **FOLL_PIN**)) != **FOLL_PIN**) 2993 **return false**; 2994 */\**

2995 *\* Note: PageAnon(page) is stable until the page is actually getting*

2996 *\* freed.*

2997 *\*/*

2998 **if** (!**PageAnon**(page)) 2999 **return false**; 3000 */\**

3001 *\* Note that PageKsm() pages cannot be exclusive, and consequently,*

3002 *\* cannot get pinned.* 3003 *\*/*

3004 **return** !**PageAnonExclusive**(page); 3005 }

 

*Listing 8-44:* include/linux/mm.h: [*gup_must_unshare()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2985)

 

GUP sharing \* deals with the scenario where a forked Copy-on-Write page

is read-only pinned, but mapped by more than one process. In this scenario, the pinned page will no longer be what’s mapped by the process in question once a fork takes place, which is likely not what the caller expects.

 

\*. Added in commit [a7f226604170: mm/gup: trigger FAULT_FLAG_UNSHARE when R/O-pinning](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a7f226604170)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a7f226604170)



 

This issue is resolved by ’unsharing’, i.e. triggering a CoW using the

[FAULT_FLAG_UNSHARE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n874) flag (see the page fault section 6 for more details on this)

– the criteria are a read-only GUP access with FOLL_PIN set on a non-exclusive

anonymous page as shown above.

Finally, once this is complete, we assert that no GUP unsharable mem-

ory escaped this check. We then move on to the actual pinning of pages and

cleanup tasks:-

 

607 */\* try_grab_page() does nothing unless FOLL_GET or FOLL_PIN is set. \*/*

608 **if** (**unlikely**(!**try_grab_page**(page, flags))) { 609 page = **ERR_PTR**(-**ENOMEM**); 610 **goto out**; 611 }

612 */\**

613 *\* We need to make the page accessible if and only if we are going*

614 *\* to access its content (the FOLL_PIN case). Please see* 615 *\* Documentation/core-api/pin_user_pages.rst for details.* 616 *\*/*

617 **if** (flags & **FOLL_PIN**) { 618 ret = **arch_make_page_accessible**(page); 619 **if** (ret) { 620 **unpin_user_page**(page); 621 page = **ERR_PTR**(ret); 622 **goto out**; 623 }

624 }

625 **if** (flags & **FOLL_TOUCH**) { 626 **if** ((flags & **FOLL_WRITE**) && 627 !**pte_dirty**(pte) && !**PageDirty**(page)) 628 **set_page_dirty**(page); 629 */\**

630 *\* pte_mkyoung() would be more correct here, but atomic care*

631 *\* is needed to avoid losing the dirty bit: it is easier to*

*use*

632 *\* mark_page_accessed().* 633 *\*/*

634 **mark_page_accessed**(page); 635 }

636 **out**:

637 **pte_unmap_unlock**(ptep, ptl); 638 **return** page;

639 **no_page**:

640 **pte_unmap_unlock**(ptep, ptl); 641 **if** (!**pte_none**(pte)) 642 **return NULL**; 643 **return no_page_table**(vma, flags); 644 }

 



 

*Listing 8-45:* mm/gup.c: [*follow_page_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519) *pinning and cleanup*

 

The actual pinning is performed by [try_grab_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n202) which we will ex-

amine shortly. If the FOLL_PIN flag was set, then we make it accessible

via [arch_make_page_accessible()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1653) which is only relevant for the s390 archi-tecture and, if FOLL_TOUCH flag is specified we mark the page accessed

via [mark_page_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n48) and, if FOLL_DIRTY is also set mark it dirty via

[set_page_dirty().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n60)

Finally, the PTE lock is released via [pte_unmap_unlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2311) and the pointer to

the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) object is returned.

Examining [try_grab_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n202):-

 

184 */\*\**

185 *\* try_grab_page() - elevate a page's refcount by a flag-dependent amount*

186 *\* @page:* *pointer to page to be grabbed* 187 *\* @flags:* *gup flags: these are the FOLL\_\* flag values.* 188 *\**

189 *\* This might not do anything at all, depending on the flags argument.* 190 *\**

191 *\* "grab" names in this file mean, "look at flags to decide whether to use*

192 *\* FOLL_PIN or FOLL_GET behavior, when incrementing the page's refcount.* 193 *\**

194 *\* Either FOLL_PIN or FOLL_GET (or neither) may be set, but not both at the*

*same*

195 *\* time. Cases: please see the try_grab_folio() documentation, with* 196 *\* "refs=1".*

197 *\**

198 *\* Return: true for success, or if no action was required (if neither FOLL_PIN*

199 *\* nor FOLL_GET was set, nothing is done). False for failure: FOLL_GET or*

200 *\* FOLL_PIN was set, but the page could not be grabbed.* 201 *\*/*

202 **bool \_\_must_check try_grab_page**(**struct** page \*page, **unsigned int** flags) 203 {

204 **struct** folio \*folio = **page_folio**(page); 205

206 **WARN_ON_ONCE**((flags & (**FOLL_GET** \| **FOLL_PIN**)) == (**FOLL_GET** \| **FOLL_PIN**))

;

207 **if** (**WARN_ON_ONCE**(**folio_ref_count**(folio) \<= 0)) 208 **return false**; 209

210 **if** (flags & **FOLL_GET**) 211 **folio_ref_inc**(folio); 212 **else if** (flags & **FOLL_PIN**) { 213 */\**

214 *\* Similar to try_grab_folio(): be sure to \*also\** 215 *\* increment the normal page refcount field at least once,*

216 *\* so that the page really is pinned.*

 



 

217 *\*/*

218 **if** (**folio_test_large**(folio)) { 219 **folio_ref_add**(folio, 1); 220 **atomic_add**(1, **folio_pincount_ptr**(folio)); 221 } **else** {

222 **folio_ref_add**(folio, **GUP_PIN_COUNTING_BIAS**); 223 }

224

225 **node_stat_mod_folio**(folio, **NR_FOLL_PIN_ACQUIRED**, 1); 226 }

227

228 **return true**;

229 }

 

*Listing 8-46:* mm/gup.c: [*try_grab_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n202)

 

This starts by obtaining the [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) associated with the page, that

FOLL_GET and FOLL_PIN are not wrongfully set together and that the folio’s ref-

erence count is positive.

The FOLL_GET case is simple – we simply increment the folio’s reference.

The FOLL_PIN case is more complicated – the first tail page of a huge folio has

a compound_pincount field which can store the pins.

For order-0 folios, we must resort to something of a hack. We instead

increment the reference count by 10 [GUP_PIN_COUNTING_BIAS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1210) [,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1210) which is set to 2

or 1*,* 024. This is chosen as a kind of mask far higher than you’d expect

a reference count to reach, and allows us to identify the pinned pages in

[folio_maybe_dma_pinned()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1498) described previously in listing 8-14.

 

***8.1.7 Faulting in Pages***

The actual faulting in of a page is performed via [faultin_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n960) which is refer-

enced through GUP whenever a faulting in operation has to be performed:-

 

955 */\**

956 *\* mmap_lock must be held on entry. If @locked != NULL and \*@flags* 957 *\* does not include FOLL_NOWAIT, the mmap_lock may be released. If it* 958 *\* is, \*@locked will be set to 0 and -EBUSY returned.* 959 *\*/*

960 **static int faultin_page**(**struct** vm_area_struct \*vma, 961 **unsigned long** address, **unsigned int** \*flags, **bool** unshare, 962 **int** \*locked) 963 {

964 **unsigned int** fault_flags = 0; 965 **vm_fault_t** ret;

966

967 **if** (\*flags & **FOLL_NOFAULT**) 968 **return**-**EFAULT**; 969 **if** (\*flags & **FOLL_WRITE**)

 



 

970 fault_flags \|= **FAULT_FLAG_WRITE**; 971 **if** (\*flags & **FOLL_REMOTE**) 972 fault_flags \|= **FAULT_FLAG_REMOTE**; 973 **if** (locked)

974 fault_flags \|= **FAULT_FLAG_ALLOW_RETRY** \| **FAULT_FLAG_KILLABLE**; 975 **if** (\*flags & **FOLL_NOWAIT**) 976 fault_flags \|= **FAULT_FLAG_ALLOW_RETRY** \|

**FAULT_FLAG_RETRY_NOWAIT**;

977 **if** (\*flags & **FOLL_TRIED**) { 978 */\**

979 *\* Note: FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED* 980 *\* can co-exist* 981 *\*/*

982 fault_flags \|= **FAULT_FLAG_TRIED**; 983 }

984 **if** (unshare) {

985 fault_flags \|= **FAULT_FLAG_UNSHARE**; 986 */\* FAULT_FLAG_WRITE and FAULT_FLAG_UNSHARE are incompatible \*/*

987 **VM_BUG_ON**(fault_flags & **FAULT_FLAG_WRITE**); 988 }

989

990 ret = **handle_mm_fault**(vma, address, fault_flags, **NULL**); 991

992 **if** (ret & **VM_FAULT_COMPLETED**) { 993 */\**

994 *\* With FAULT_FLAG_RETRY_NOWAIT we'll never release the* 995 *\* mmap lock in the page fault handler. Sanity check this.*

996 *\*/*

997 **WARN_ON_ONCE**(fault_flags & **FAULT_FLAG_RETRY_NOWAIT**); 998 **if** (locked) 999 \*locked = 0;

1000 */\**

1001 *\* We should do the same as VM_FAULT_RETRY, but let's not*

1002 *\* return -EBUSY since that's not reflecting the reality of*

1003 *\* what has happened - we've just fully completed a page* 1004 *\* fault, with the mmap lock released. Use -EAGAIN to show*

1005 *\* that we want to take the mmap lock \_again\_.* 1006 *\*/*

1007 **return**-**EAGAIN**; 1008 }

1009

1010 **if** (ret & **VM_FAULT_ERROR**) { 1011 **int** err = **vm_fault_to_errno**(ret, \*flags); 1012

1013 **if** (err)

1014 **return** err; 1015 **BUG**();

 



 

1016 }

1017

1018 **if** (ret & **VM_FAULT_RETRY**) { 1019 **if** (locked && !(fault_flags & **FAULT_FLAG_RETRY_NOWAIT**)) 1020 \*locked = 0; 1021 **return**-**EBUSY**; 1022 }

1023

1024 **return** 0;

1025 }

 

*Listing 8-47:* mm/gup.c: [*faultin_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n960)

 

This starts by checking whether the FOLL_NOFAULT flag is set – if so this is a

no-op, as clearly no fault should take place, and this is indicated by the func-

tion returning the EFAULT error code.

The FAULT_FLAG_WRITE and FAULT_FLAG_REMOTE flags are passed through from

the respective FOLL_WRITE and FOLL_REMOTE flags.

If the locked parameter is non-NULL then this indicates that the caller will

accept the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) being dropped for I/O and perform-

ing a fault retry, setting the FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_KILLABLE

flags as a consequence.

if the FOLL_NOWAIT flag is specified, then we are permitted to retry

for I/O but will not drop the lock, via the FAULT_FLAG_ALLOW_RETRY and

FAULT_FLAG_RETRY_NOWAIT flags.

Finally, if the unshare parameter was set true to handle the case where a

read fault needs to CoW a page, the FAULT_FLAG_UNSHARE flag is set. We also

check to ensure we are faulting read-only.

With all of this set up, the actual page fault is handled via

[handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129). For a detailed examination of this, see the page fault sec-

tion 6.

Once the actual faulting in is complete the return value is handled:-

 

• [VM_FAULT_COMPLETED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n755) – Indicates that the lock has been dropped for I/O

and the operation is complete. We update locked accordingly and return EAGAIN to indicate that this has occurred.

• [VM_FAULT_ERROR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n763) – An error has arisen, we convert it into an error code

via [vm_fault_to_errno()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2957) and exit (raising a kernel oops if the fault coude could not be converted to an error code.)

• [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) – The fault needs to be retrieved, indicate via EBUSY and

update locked accordingly.

 

***8.1.8 Fast GUP Functions***

The fast GUP path attempts to perform the same operation as

the non-fast kind but trying to avoid having to take a lock on the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore.

These differ from their non-fast counterparts in a few respects:-

 



 

• There is no means of returning an array of [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)

objects as these are only ever valid with the mmap_lock sempahore held and of course the fast path functions are trying to avoid this.

• The get\_\*() variants explicitly set the FOLL_GET flag, so the pages argument

must also be non-NULL.

• Unless the \*\_user_pages_fast_only() variants are used, the functions will

fall back to using the non-fast path if the fast one is unable to perform the operation locklessly.

• Only a subset of flags are permitted, see below:-

 

Table 8-2: GUP flag validity

GUP flag Non-fast Fast

FOLL_WRITE *•* *•*

FOLL_TOUCH *•*

FOLL_GET *•* *•*

FOLL_DUMP *•*

FOLL_FORCE *•* *•*

FOLL_NOWAIT *•*

FOLL_NOFAULT *•* *•*

FOLL_HWPOISON *•*

FOLL_NUMA *•*

FOLL_MIGRATION *•*

FOLL_TRIED *•*

FOLL_REMOTE *•*

FOLL_ANON *•*

FOLL_LONGTERM *•* *•*

FOLL_SPLIT_PMD *•*

FOLL_PIN *•* *•*

FOLL_FAST_ONLY *•*

 

Examining [get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3077)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3077)

 

3061 */\*\**

3062 *\* get_user_pages_fast() - pin user pages in memory* 3063 *\* @start:* *starting user address* 3064 *\* @nr_pages:* *number of pages from start to pin* 3065 *\* @gup_flags: flags modifying pin behaviour* 3066 *\* @pages:* *array that receives pointers to the pages pinned.* 3067 *\** *Should be at least nr_pages long.* 3068 *\**

3069 *\* Attempt to pin user pages in memory without taking mm-\>mmap_lock.* 3070 *\* If not successful, it will fall back to taking the lock and* 3071 *\* calling get_user_pages().* 3072 *\**

3073 *\* Returns number of pages pinned. This may be fewer than the number requested*

*.*

3074 *\* If nr_pages is 0 or negative, returns 0. If no pages were pinned, returns*

 



 

3075 *\* -errno.*

3076 *\*/*

3077 **int get_user_pages_fast**(**unsigned long** start, **int** nr_pages, 3078 **unsigned int** gup_flags, **struct** page \*\*pages) 3079 {

3080 **if** (!**is_valid_gup_flags**(gup_flags)) 3081 **return**-**EINVAL**; 3082

3083 */\**

3084 *\* The caller may or may not have explicitly set FOLL_GET; either way*

*is*

3085 *\* OK. However, internally (within mm/gup.c), gup fast variants must*

*set*

3086 *\* FOLL_GET, because gup fast is always a "pin with a +1 page refcount*

*"*

3087 *\* request.*

3088 *\*/*

3089 gup_flags \|= **FOLL_GET**; 3090 **return internal_get_user_pages_fast**(start, nr_pages, gup_flags, pages)

;

3091 }

 

*Listing 8-48:* mm/gup.c: [*get_user_pages_fast()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3077)

 

This checks [is_valid_gup_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2089) as do the non-fast get_user_pages\*() func-

tions (see listing 8-16) before unconditionally setting FOLL_GET and invoking

the shared [internal_get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2964) function.

Note that this form of the function will fall back to the non-fast path if it

cannot pin all of the requested pages. If this behaviour is not desired, then

[get_user_pages_fast_only()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3032) will pin pages using the fast method only:-

 

3012 */\*\**

3013 *\* get_user_pages_fast_only() - pin user pages in memory* 3014 *\* @start:* *starting user address* 3015 *\* @nr_pages:* *number of pages from start to pin* 3016 *\* @gup_flags: flags modifying pin behaviour* 3017 *\* @pages:* *array that receives pointers to the pages pinned.* 3018 *\** *Should be at least nr_pages long.* 3019 *\**

3020 *\* Like get_user_pages_fast() except it's IRQ-safe in that it won't fall back*

*to*

3021 *\* the regular GUP.*

3022 *\* Note a difference with get_user_pages_fast: this always returns the* 3023 *\* number of pages pinned, 0 if no pages were pinned.* 3024 *\**

3025 *\* If the architecture does not support this function, simply return with no*

3026 *\* pages pinned.*

3027 *\**

3028 *\* Careful, careful! COW breaking can go either way, so a non-write*

 



 

3029 *\* access can get ambiguous page results. If you call this function without*

3030 *\* 'write' set, you'd better be sure that you're ok with that ambiguity.* 3031 *\*/*

3032 **int get_user_pages_fast_only**(**unsigned long** start, **int** nr_pages, 3033 **unsigned int** gup_flags, **struct** page \*\*pages) 3034 {

3035 **int** nr_pinned;

3036 */\**

3037 *\* Internally (within mm/gup.c), gup fast variants must set FOLL_GET,*

3038 *\* because gup fast is always a "pin with a +1 page refcount" request.*

3039 *\**

3040 *\* FOLL_FAST_ONLY is required in order to match the API description of*

3041 *\* this routine: no fall back to regular ("slow") GUP.* 3042 *\*/*

3043 gup_flags \|= **FOLL_GET** \| **FOLL_FAST_ONLY**; 3044

3045 nr_pinned = **internal_get_user_pages_fast**(start, nr_pages, gup_flags, 3046 pages); 3047

3048 */\**

3049 *\* As specified in the API description above, this routine is not*

3050 *\* allowed to return negative values. However, the common core* 3051 *\* routine internal_get_user_pages_fast() \*can\* return -errno.* 3052 *\* Therefore, correct for that here:* 3053 *\*/*

3054 **if** (nr_pinned \< 0) 3055 nr_pinned = 0; 3056

3057 **return** nr_pinned; 3058 }

 

*Listing 8-49:* mm/gup.c: [*get_user_pages_fast_only()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3032)

 

This sets FOLL_FAST_ONLY and returns the number pinned or zero if an er-

ror occurs, no fall back to the non-fast path occurs. This is useful in situa-tions where the mmap_lock cannot be acquired.

Similarly, the GUP pin variants are similar to these, only setting FOLL_PIN

rather than FOLL_GET:-

 

3094 */\*\**

3095 *\* pin_user_pages_fast() - pin user pages in memory without taking locks* 3096 *\**

3097 *\* @start:* *starting user address* 3098 *\* @nr_pages:* *number of pages from start to pin* 3099 *\* @gup_flags: flags modifying pin behaviour* 3100 *\* @pages:* *array that receives pointers to the pages pinned.* 3101 *\** *Should be at least nr_pages long.* 3102 *\**

3103 *\* Nearly the same as get_user_pages_fast(), except that FOLL_PIN is set. See*

 



 

3104 *\* get_user_pages_fast() for documentation on the function arguments, because*

3105 *\* the arguments here are identical.* 3106 *\**

3107 *\* FOLL_PIN means that the pages must be released via unpin_user_page().*

*Please*

3108 *\* see Documentation/core-api/pin_user_pages.rst for further details.* 3109 *\*/*

3110 **int pin_user_pages_fast**(**unsigned long** start, **int** nr_pages, 3111 **unsigned int** gup_flags, **struct** page \*\*pages) 3112 {

3113 */\* FOLL_GET and FOLL_PIN are mutually exclusive. \*/* 3114 **if** (**WARN_ON_ONCE**(gup_flags & **FOLL_GET**)) 3115 **return**-**EINVAL**; 3116

3117 **if** (**WARN_ON_ONCE**(!pages)) 3118 **return**-**EINVAL**; 3119

3120 gup_flags \|= **FOLL_PIN**; 3121 **return internal_get_user_pages_fast**(start, nr_pages, gup_flags, pages)

;

3122 }

 

*Listing 8-50:* mm/gup.c: [*pin_user_pages_fast()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3110)

 

And the fast path only equivalent:-

 

3125 */\**

3126 *\* This is the FOLL_PIN equivalent of get_user_pages_fast_only(). Behavior*

3127 *\* is the same, except that this one sets FOLL_PIN instead of FOLL_GET.* 3128 *\**

3129 *\* The API rules are the same, too: no negative values may be returned.* 3130 *\*/*

3131 **int pin_user_pages_fast_only**(**unsigned long** start, **int** nr_pages, 3132 **unsigned int** gup_flags, **struct** page \*\*pages) 3133 {

3134 **int** nr_pinned;

3135

3136 */\**

3137 *\* FOLL_GET and FOLL_PIN are mutually exclusive. Note that the API*

3138 *\* rules require returning 0, rather than -errno:* 3139 *\*/*

3140 **if** (**WARN_ON_ONCE**(gup_flags & **FOLL_GET**)) 3141 **return** 0; 3142

3143 **if** (**WARN_ON_ONCE**(!pages)) 3144 **return** 0; 3145 */\**

3146 *\* FOLL_FAST_ONLY is required in order to match the API description of*

3147 *\* this routine: no fall back to regular ("slow") GUP.*

 



 

3148 *\*/*

3149 gup_flags \|= (**FOLL_PIN** \| **FOLL_FAST_ONLY**); 3150 nr_pinned = **internal_get_user_pages_fast**(start, nr_pages, gup_flags, 3151 pages); 3152 */\**

3153 *\* This routine is not allowed to return negative values. However,*

3154 *\* internal_get_user_pages_fast() \*can\* return -errno. Therefore,*

3155 *\* correct for that here:* 3156 *\*/*

3157 **if** (nr_pinned \< 0) 3158 nr_pinned = 0; 3159

3160 **return** nr_pinned; 3161 }

 

*Listing 8-51:* mm/gup.c: [*pin_user_pages_fast_only()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3131)

 

Each of these ultimately invoke [internal_get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2964)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2964) This is

somewhat equivalent to the non-fast [\_\_get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140) only with some addi-tional handling for the fast path:-

 

2964 **static int internal_get_user_pages_fast**(**unsigned long** start, 2965 **unsigned long** nr_pages, 2966 **unsigned int** gup_flags, 2967 **struct** page \*\*pages) 2968 {

2969 **unsigned long** len, end; 2970 **unsigned long** nr_pinned; 2971 **int** ret;

2972

2973 **if** (**WARN_ON_ONCE**(gup_flags & ~(**FOLL_WRITE** \| **FOLL_LONGTERM** \| 2974 **FOLL_FORCE** \| **FOLL_PIN** \| **FOLL_GET** \| 2975 **FOLL_FAST_ONLY** \| **FOLL_NOFAULT**))) 2976 **return**-**EINVAL**; 2977

2978 **if** (gup_flags & **FOLL_PIN**) 2979 **mm_set_has_pinned_flag**(&current-\>mm-\>flags); 2980

2981 **if** (!(gup_flags & **FOLL_FAST_ONLY**)) 2982 **might_lock_read**(&current-\>mm-\>mmap_lock); 2983

2984 start = **untagged_addr**(start) & **PAGE_MASK**; 2985 len = nr_pages \<\< **PAGE_SHIFT**; 2986 **if** (**check_add_overflow**(start, len, &end)) 2987 **return** 0; 2988 **if** (**unlikely**(!**access_ok**((**void \_\_user** \*)start, len))) 2989 **return**-**EFAULT**; 2990

2991 nr_pinned = **lockless_pages_from_mm**(start, end, gup_flags, pages);

 



 

2992 **if** (nr_pinned == nr_pages \|\| gup_flags & **FOLL_FAST_ONLY**) 2993 **return** nr_pinned; 2994

2995 */\* Slow path: try to get the remaining pages with get_user_pages \*/*

2996 start += nr_pinned \<\< **PAGE_SHIFT**; 2997 pages += nr_pinned; 2998 ret = **\_\_gup_longterm_unlocked**(start, nr_pages - nr_pinned, gup_flags, 2999 pages); 3000 **if** (ret \< 0) {

3001 */\**

3002 *\* The caller has to unpin the pages we already pinned so* 3003 *\* returning -errno is not an option* 3004 *\*/*

3005 **if** (nr_pinned) 3006 **return** nr_pinned; 3007 **return** ret; 3008 }

3009 **return** ret + nr_pinned; 3010 }

 

*Listing 8-52:* mm/gup.c: [*internal_get_user_pages_fast()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2964)

 

This asserts that the flags are permitted as described in figure 8-2, before

setting the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) MMF_HAS_PINNED flag via [mm_set_has_pinned_flag()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n437) if

pinning, as described previously.

Then we indicate that a lock can be acquired here if the FOLL_FAST_ONLY

flag is not set (since we can degrade to using the non-fast path), check for

overflow via [check_add_overflow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/overflow.h?h=v6.0#n62)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/overflow.h?h=v6.0#n62) check accessibility to the memory range via

[access_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/uaccess.h?h=v6.0#n40), before deferring the heavy lifting to [lockless_pages_from_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2915)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2915)

If fewer than expected pages are returned and FOLL_FAST_ONLY is speci-

fied then we simply return this count, otherwise we fall back to the non-fast

path for the remaining pages after offsetting to account for this invoking

[\_\_gup_longterm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063) to do so.

If we do fall back to this code path we, similar to [\_\_get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140) only

return an error if no pages have been pinned, if some have then we simply

indicate how many were.

Examining [lockless_pages_from_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2915)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2915)

 

2915 **static unsigned long lockless_pages_from_mm**(**unsigned long** start, 2916 **unsigned long** end, 2917 **unsigned int** gup_flags, 2918 **struct** page \*\*pages) 2919 {

2920 **unsigned long** flags; 2921 **int** nr_pinned = 0; 2922 **unsigned** seq;

2923

2924 **if** (!**IS_ENABLED**(**CONFIG_HAVE_FAST_GUP**) \|\| 2925 !**gup_fast_permitted**(start, end))

 



 

2926 **return** 0; 2927

2928 **if** (gup_flags & **FOLL_PIN**) { 2929 seq = **raw_read_seqcount**(&current-\>mm-\>write_protect_seq); 2930 **if** (seq & 1) 2931 **return** 0; 2932 }

2933

2934 */\**

2935 *\* Disable interrupts. The nested form is used, in order to allow full*

*,*

2936 *\* general purpose use of this routine.* 2937 *\**

2938 *\* With interrupts disabled, we block page table pages from being*

*freed*

2939 *\* from under us. See struct mmu_table_batch comments in* 2940 *\* include/asm-generic/tlb.h for more details.* 2941 *\**

2942 *\* We do not adopt an rcu_read_lock() here as we also want to block*

*IPIs*

2943 *\* that come from THPs splitting.* 2944 *\*/*

2945 **local_irq_save**(flags); 2946 **gup_pgd_range**(start, end, gup_flags, pages, &nr_pinned); 2947 **local_irq_restore**(flags); 2948

2949 */\**

2950 *\* When pinning pages for DMA there could be a concurrent write*

*protect*

2951 *\* from fork() via copy_page_range(), in this case always fail fast*

*GUP.*

2952 *\*/*

2953 **if** (gup_flags & **FOLL_PIN**) { 2954 **if** (**read_seqcount_retry**(&current-\>mm-\>write_protect_seq, seq))

{

2955 **unpin_user_pages_lockless**(pages, nr_pinned); 2956 **return** 0; 2957 } **else** {

2958 **sanity_check_pinned_pages**(pages, nr_pinned); 2959 }

2960 }

2961 **return** nr_pinned; 2962 }

 

*Listing 8-53:* mm/gup.c: [*lockless_pages_from_mm()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2915)

 

The whole idea here is to try to increment a reference count on pages

in the range optimistically on the assumption that the pages have not been

 



 

freed beneath us, this is ultimately done after traversing page tables as with

the non-fast path starting from [gup_pgd_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2849)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2849)

Given we do not possess the luxury of the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

which we are trying to avoid taking to reduce contention, we have to be care-

ful of races.

We check the state of the mm_struct-\>write_protect_seq lock to avoid a

race between forking and pinning (due to the fork logic branching on on

[page_maybe_dma_pinned()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1515)) on write-protecting newly CoW’d mappings \*.

See the [sequence counter locking](https://kernel.org/doc/html/v6.0/locking/seqlock.html) documentation for details, but essentially

it is an atomic sequence number which is set odd when the critical section is

being updated and even when not. Therefore, if the value is odd, we abort

the operation right away, otherwise we store the sequence number, retriev-

ing the value via [raw_read_seqcount()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/seqlock.h?h=v6.0#n373).

Once [gup_pgd_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2849) is complete, we check again via [read_seqcount_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/seqlock.h?h=v6.0#n443)

which checks to see whether the sequence number has changed since the

operation started, which would indicate a race may have occurred, erroring

out if so. Note the invocation of [sanity_check_pinned_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n32) when the race

does not occur is only relevant if CONFIG_DEBUG_VM is specified.

This race condition aside, we invoke [gup_pgd_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2849) with interrupts dis-

abled in order to prevent page tables disappearing from beneath us. This

function updates nr_pinned which we return.

Prior to this, we invoke the architecture-specific [gup_fast_permitted()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n264) to

determine whether the operation is permitted at all – for x86-64 this simply

checks to ensure the end of the range is a valid virtual address.

Similar to the non-fast path, we must traverse through the page table

levels, starting from PGD. Again we elide out-of-scope huge page handling

here:-

 

2849 **static void gup_pgd_range**(**unsigned long** addr, **unsigned long** end, 2850 **unsigned int** flags, **struct** page \*\*pages, **int** \*nr) 2851 {

2852 **unsigned long** next; 2853 **pgd_t** \*pgdp;

2854

2855 pgdp = **pgd_offset**(current-\>mm, addr); 2856 **do** {

2857 **pgd_t** pgd = **READ_ONCE**(\*pgdp); 2858

2859 next = **pgd_addr_end**(addr, end); 2860 **if** (**pgd_none**(pgd)) 2861 **return**;

. . .

2870 } **else if** (!**gup_p4d_range**(pgdp, pgd, addr, next, flags, pages,

nr))

2871 **return**;

 

\*. See commit [57efa1fe5957: mm/gup: prevent gup_fast from racing with COW during fork](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=57efa1fe5957)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=57efa1fe5957)



 

2872 } **while** (pgdp++, addr = next, addr != end); 2873 }

 

*Listing 8-54:* mm/gup.c: [*gup_pgd_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2849)

 

This iterates through the input range, crossing PGD entry boundaries as

necessary, deferring to the next level via [gup_p4d_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2824) (whose return value indicates if the operation has failed at any stage):-

 

2824 **static int gup_p4d_range**(**pgd_t** \*pgdp, **pgd_t** pgd, **unsigned long** addr, **unsigned**

**long** end,

2825 **unsigned int** flags, **struct** page \*\*pages, **int** \*nr) 2826 {

2827 **unsigned long** next; 2828 **p4d_t** \*p4dp;

2829

2830 p4dp = **p4d_offset_lockless**(pgdp, pgd, addr); 2831 **do** {

2832 **p4d_t** p4d = **READ_ONCE**(\*p4dp); 2833

2834 next = **p4d_addr_end**(addr, end); 2835 **if** (**p4d_none**(p4d)) 2836 **return** 0;

. . .

2842 } **else if** (!**gup_pud_range**(p4dp, p4d, addr, next, flags, pages,

nr))

2843 **return** 0; 2844 } **while** (p4dp++, addr = next, addr != end); 2845

2846 **return** 1;

2847 }

 

*Listing 8-55:* mm/gup.c: [*gup_p4d_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2824)

 

One difference here is the use of the [p4d_offset_lockless()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n1625) variant of the

page table offset function. This is exactly equivalent to the non-lockless one for all architectures except s390. See the virtual memory chapter for more on these functions in general.

Examining the same function for the next level, [gup_pud_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2796):-

 

2796 **static int gup_pud_range**(**p4d_t** \*p4dp, **p4d_t** p4d, **unsigned long** addr, **unsigned**

**long** end,

2797 **unsigned int** flags, **struct** page \*\*pages, **int** \*nr) 2798 {

2799 **unsigned long** next; 2800 **pud_t** \*pudp;

2801

2802 pudp = **pud_offset_lockless**(p4dp, p4d, addr); 2803 **do** {

2804 **pud_t** pud = **READ_ONCE**(\*pudp);

 



 

2805

2806 next = **pud_addr_end**(addr, end); 2807 **if** (**unlikely**(!**pud_present**(pud))) 2808 **return** 0;

. . .

2817 } **else if** (!**gup_pmd_range**(pudp, pud, addr, next, flags, pages,

nr))

2818 **return** 0; 2819 } **while** (pudp++, addr = next, addr != end); 2820

2821 **return** 1;

2822 }

 

*Listing 8-56:* mm/gup.c: [*gup_pud_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2796)

 

And for PMD:-

 

2753 **static int gup_pmd_range**(**pud_t** \*pudp, **pud_t** pud, **unsigned long** addr, **unsigned**

**long** end,

2754 **unsigned int** flags, **struct** page \*\*pages, **int** \*nr) 2755 {

2756 **unsigned long** next; 2757 **pmd_t** \*pmdp;

2758

2759 pmdp = pmd_offset_lockless(pudp, pud, addr); 2760 **do** {

2761 **pmd_t** pmd = **READ_ONCE**(\*pmdp); 2762

2763 next = pmd_addr_end(addr, end); 2764 **if** (!pmd_present(pmd)) 2765 **return** 0;

. . .

2789 } **else if** (!gup_pte_range(pmd, pmdp, addr, next, flags, pages,

nr))

2790 **return** 0; 2791 } **while** (pmdp++, addr = next, addr != end); 2792

2793 **return** 1;

2794 }

 

*Listing 8-57:* mm/gup.c: [*gup_pmd_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2753)

 

And finally we arrive at [gup_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2367) (eliding out of scope huge page,

device map, secret memory logic and s390-specific page accessibility logic):-

 

2348 */\**

2349 *\* Fast-gup relies on pte change detection to avoid concurrent pgtable* 2350 *\* operations.*

2351 *\**

2352 *\* To pin the page, fast-gup needs to do below in order:*

 



 

2353 *\* (1) pin the page (by prefetching pte), then (2) check pte not changed.*

2354 *\**

2355 *\* For the rest of pgtable operations where pgtable updates can be racy* 2356 *\* with fast-gup, we need to do (1) clear pte, then (2) check whether page*

2357 *\* is pinned.*

2358 *\**

2359 *\* Above will work for all pte-level operations, including THP split.* 2360 *\**

2361 *\* For THP collapse, it's a bit more complicated because fast-gup may be*

2362 *\* walking a pgtable page that is being freed (pte is still valid but pmd*

2363 *\* can be cleared already). To avoid race in such condition, we need to*

2364 *\* also check pmd here to make sure pmd doesn't change (corresponds to* 2365 *\* pmdp_collapse_flush() in the THP collapse code path).* 2366 *\*/*

2367 **static int gup_pte_range**(**pmd_t** pmd, **pmd_t** \*pmdp, **unsigned long** addr, 2368 **unsigned long** end, **unsigned int** flags, 2369 **struct** page \*\*pages, **int** \*nr) 2370 {

. . .

2372 **int** nr_start = \*nr, ret = 0; 2373 **pte_t** \*ptep, \*ptem; 2374

2375 ptem = ptep = **pte_offset_map**(&pmd, addr); 2376 **do** {

2377 **pte_t** pte = **ptep_get_lockless**(ptep); 2378 **struct** page \*page; 2379 **struct** folio \*folio; 2380

2381 */\**

2382 *\* Similar to the PMD case below, NUMA hinting must take slow*

2383 *\* path using the pte_protnone check.* 2384 *\*/*

2385 **if** (**pte_protnone**(pte)) 2386 **goto pte_unmap**; 2387

2388 **if** (!**pte_access_permitted**(pte, flags & **FOLL_WRITE**)) 2389 **goto pte_unmap**;

. . .

2400 } **else if** (**pte_special**(pte)) 2401 **goto pte_unmap**; 2402

2403 **VM_BUG_ON**(!**pfn_valid**(**pte_pfn**(pte))); 2404 page = **pte_page**(pte); 2405

2406 folio = **try_grab_folio**(page, 1, flags); 2407 **if** (!folio) 2408 **goto pte_unmap**;

 



 

. . .

2415 **if** (**unlikely**(**pmd_val**(pmd) != **pmd_val**(\*pmdp)) \|\| 2416 **unlikely**(**pte_val**(pte) != **pte_val**(\*ptep))) { 2417 **gup_put_folio**(folio, 1, flags); 2418 **goto pte_unmap**; 2419 }

2420

2421 **if** (!**pte_write**(pte) && **gup_must_unshare**(flags, page)) { 2422 **gup_put_folio**(folio, 1, flags); 2423 **goto pte_unmap**; 2424 }

. . .

2439 **folio_set_referenced**(folio); 2440 pages\[\*nr\] = page; 2441 (\*nr)++;

2442 } **while** (ptep++, addr += **PAGE_SIZE**, addr != end); 2443

2444 ret = 1;

2445

2446 **pte_unmap**:

. . .

2449 **pte_unmap**(ptem);

2450 **return** ret;

2451 }

 

*Listing 8-58:* mm/gup.c: [*gup_pte_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2367)

 

This follows the typical pattern of iterating through the page table as

with the page table levels above, however a key part of the lockless algorithm

is applied here – the value of and the pointer to the PMD entry containing

the reference to this PTE is passed in and prior to processing it the PTE

value is retrieved (the PMD check being more relevant to the out of scope

case of transparent huge page coalescing).

Note, again, that mapping and unmapping the PTE is a no-op on x86-64

and other modern 64-bit architectures, so these can be duly ignored for the

most part as 32-bit architectures are out of scope for the book.

In all cases where we cannot proceed with the lockless pinning of the un-

derlying page, we simply exit. Since we’re updating nr_Pages as we pin pages,

the progress of which pages we were able to pin will be propagated back to

the caller.

The function will exit in this fashion if the PTE entry indicates NUMA

hinting is taking place checked via [pte_protnone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n775) or if the mapping is special

checked via [pte_special()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n177) (see section 6.12 for more details).

Since we cannot fault pages in (this is the fast path after all), we explic-

itly check that the page table flags match expectations via the architecture-

specific [pte_access_permitted()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1409).

 



 

The most pertinent check here is whether the entry is writable should

FOLL_WRITE be specified, if not we simply exit early and (unless FOLL_FAST_ONLY is specified) we fallback to the slow path to fault the page in.

We assert that the PFN referenced by the PTE is valid via [pfn_valid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1627) as

by this point the checks prior to this stage should assure us of this fact.

We then are able to obtain a pointer to the underlying [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) via

[pte_page().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n224)

We then perform the actual pinning via [try_grab_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n124)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n124) which we will

examine in detail shortly. If this fails we abort.

After we pinned this page, we perform our consistency check – did the

PTE (or PMD in huge case) change beneath us while we were pinning? We do this be comparing PMD and PTE values before and after the operation –

if they do differ we release the pin via [gup_put_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n170) and abort.

After this, we check to see whether the page actually required unsharing

in which case we again undo our optimistic pinning via gup_put_folio().

Finally, we set the folio referenced flag PG_referenced as the GUP opera-

tion clearly implies that a reference has been made and we add it to the pages array.

Coming back to [try_grab_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n124):-

 

98 */\*\**

99 *\* try_grab_folio() - Attempt to get or pin a folio.*

100 *\* @page: pointer to page to be grabbed* 101 *\* @refs: the value to (effectively) add to the folio's refcount* 102 *\* @flags: gup flags: these are the FOLL\_\* flag values.* 103 *\**

104 *\* "grab" names in this file mean, "look at flags to decide whether to use*

105 *\* FOLL_PIN or FOLL_GET behavior, when incrementing the folio's refcount.* 106 *\**

107 *\* Either FOLL_PIN or FOLL_GET (or neither) must be set, but not both at the*

108 *\* same time. (That's true throughout the get_user_pages\*() and* 109 *\* pin_user_pages\*() APIs.) Cases:* 110 *\**

111 *\** *FOLL_GET: folio's refcount will be incremented by @refs.* 112 *\**

113 *\** *FOLL_PIN on large folios: folio's refcount will be incremented by* 114 *\** *@refs, and its compound_pincount will be incremented by @refs.* 115 *\**

116 *\** *FOLL_PIN on single-page folios: folio's refcount will be incremented by* 117 *\** *@refs \* GUP_PIN_COUNTING_BIAS.* 118 *\**

119 *\* Return: The folio containing @page (with refcount appropriately* 120 *\* incremented) for success, or NULL upon failure. If neither FOLL_GET* 121 *\* nor FOLL_PIN was set, that's considered failure, and furthermore,* 122 *\* a likely bug in the caller, so a warning is also emitted.* 123 *\*/*

124 **struct** folio \***try_grab_folio**(**struct** page \*page, **int** refs, **unsigned int** flags) 125 {

 



 

126 **if** (flags & **FOLL_GET**) 127 **return try_get_folio**(page, refs); 128 **else if** (flags & **FOLL_PIN**) { 129 **struct** folio \*folio;

130

131 */\**

132 *\* Can't do FOLL_LONGTERM + FOLL_PIN gup fast path if not in a*

133 *\* right zone, so fail and let the caller fall back to the*

*slow*

134 *\* path.*

135 *\*/*

136 **if** (**unlikely**((flags & **FOLL_LONGTERM**) && 137 !**is_longterm_pinnable_page**(page))) 138 **return NULL**;

139

140 */\**

141 *\* CAUTION: Don't use compound_head() on the page before this*

142 *\* point, the result won't be stable.* 143 *\*/*

144 folio = **try_get_folio**(page, refs); 145 **if** (!folio) 146 **return NULL**;

147

148 */\**

149 *\* When pinning a large folio, use an exact count to track it.*

150 *\**

151 *\* However, be sure to \*also\* increment the normal folio* 152 *\* refcount field at least once, so that the folio really* 153 *\* is pinned. That's why the refcount from the earlier* 154 *\* try_get_folio() is left intact.* 155 *\*/*

156 **if** (**folio_test_large**(folio)) 157 **atomic_add**(refs, **folio_pincount_ptr**(folio)); 158 **else**

159 **folio_ref_add**(folio, 160 refs \* (**GUP_PIN_COUNTING_BIAS**- 1)); 161 **node_stat_mod_folio**(folio, **NR_FOLL_PIN_ACQUIRED**, refs);

162

163 **return** folio; 164 }

165

166 **WARN_ON_ONCE**(1);

167 **return NULL**;

168 }

 

*Listing 8-59:* mm/gup.c: [*try_grab_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n124)

 



 

The FOLL_GET case is easy – the actual increment of the folio reference

count is achieved via [try_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n69) which is simply deferred to (we will ex-amine this shortly).

In the case of a FOLL_PIN, we start by checking whether FOLL_LONGTERM has

been specified. If so, the fast path, instead of migrating long term pinned pages to an unmovable page block, simply checks whether they already in

this state via [is_longterm_pinnable_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1539) (see listing 8-24), aborting if it is not.

As with FOLL_GET we try to increment the reference count via

[try_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n69), aborting if we cannot, in order to keep the page around for the next step.

Finally, similar, to [try_grab_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n202) we apply the GUP_PIN_COUNTING_BIAS (off-

set by one to account for the reference count increment we did to keep the page around) or in the case of a huge page increment its compound_pincount.

Examining [try_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n69) (eliding out of scope device mapping logic):-

 

65 */\**

66 *\* Return the folio with ref appropriately incremented,* 67 *\* or NULL if that failed.* 68 *\*/*

69 **static inline struct** folio \***try_get_folio**(**struct** page \*page, **int** refs) 70 {

71 **struct** folio \*folio; 72

73 **retry**:

74 folio = **page_folio**(page); 75 **if** (**WARN_ON_ONCE**(**folio_ref_count**(folio) \< 0)) 76 **return NULL**; 77 **if** (**unlikely**(!**folio_ref_try_add_rcu**(folio, refs))) 78 **return NULL**; 79

80 */\**

81 *\* At this point we have a stable reference to the folio; but it* 82 *\* could be that between calling page_folio() and the refcount* 83 *\* increment, the folio was split, in which case we'd end up* 84 *\* holding a reference on a folio that has nothing to do with the page*

85 *\* we were given anymore.* 86 *\* So now that the folio is stable, recheck that the page still* 87 *\* belongs to this folio.* 88 *\*/*

89 **if** (**unlikely**(**page_folio**(page) != folio)) {

. . .

92 **goto retry**; 93 }

94

95 **return** folio;

96 }

 

*Listing 8-60:* mm/gup.c: [*try_get_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n69)

 



 

The key operation here is [folio_ref_try_add_rcu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n266) which ultimately in-

vokes [folio_ref_add_unless()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n245) which will increment the folio’s reference num-

ber unless it is currently zero.

It’s out of scope here, but we will briefly touch upon transparent huge

pages functionality – this occasionally splits a higher order folio into order-0

folios. In this case, the folio associated with the input page may no longer

belong to the folio whose reference count we incremented, in which case we

must retry.

 

***8.1.9 GUP Helper Functions***

There are a number of parts of the kernel which invoke GUP logic through

means other than the fundamental GUP functions discussed here. These

hook into various parts of GUP, most notably the faulting logic.

The header file [include/linux/mm.h](https://elixir.bootlin.com/linux/v6.0/source/include/linux/mm.h) lists the exported functions like this,

however we shall examine one case in particular – [\_\_mm_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1652). This is im-

portant because it is the function used by the mapping logic when faulting

in pages when the MAP_POPULATE function is invoked:-

 

1645 */\**

1646 *\* \_\_mm_populate - populate and/or mlock pages within a range of address space*

*.*

1647 *\**

1648 *\* This is used to implement mlock() and the MAP_POPULATE / MAP_LOCKED mmap*

1649 *\* flags. VMAs must be already marked with the desired vm_flags, and* 1650 *\* mmap_lock must not be held.* 1651 *\*/*

1652 **int \_\_mm_populate**(**unsigned long** start, **unsigned long** len, **int** ignore_errors) 1653 {

1654 **struct** mm_struct \*mm = current-\>mm; 1655 **unsigned long** end, nstart, nend; 1656 **struct** vm_area_struct \*vma = **NULL**; 1657 **int** locked = 0;

1658 **long** ret = 0;

1659

1660 end = start + len; 1661

1662 **for** (nstart = start; nstart \< end; nstart = nend) { 1663 */\**

1664 *\* We want to fault in pages for \[nstart; end) address range.*

1665 *\* Find first corresponding VMA.* 1666 *\*/*

1667 **if** (!locked) { 1668 locked = 1; 1669 **mmap_read_lock**(mm); 1670 vma = **find_vma**(mm, nstart); 1671 } **else if** (nstart \>= vma-\>vm_end) 1672 vma = vma-\>vm_next;

 



 

1673 **if** (!vma \|\| vma-\>vm_start \>= end) 1674 **break**; 1675 */\**

1676 *\* Set \[nstart; nend) to intersection of desired address* 1677 *\* range with the first VMA. Also, skip undesirable VMA types.*

1678 *\*/*

1679 nend = **min**(end, vma-\>vm_end); 1680 **if** (vma-\>vm_flags & (**VM_IO** \| **VM_PFNMAP**)) 1681 **continue**; 1682 **if** (nstart \< vma-\>vm_start) 1683 nstart = vma-\>vm_start; 1684 */\**

1685 *\* Now fault in a range of pages. populate_vma_page_range()*

1686 *\* double checks the vma flags, so that it won't mlock pages*

1687 *\* if the vma was already munlocked.* 1688 *\*/*

1689 ret = **populate_vma_page_range**(vma, nstart, nend, &locked); 1690 **if** (ret \< 0) { 1691 **if** (ignore_errors) { 1692 ret = 0; 1693 **continue**; */\* continue at next VMA \*/* 1694 } 1695 **break**; 1696 }

1697 nend = nstart + ret \* **PAGE_SIZE**; 1698 ret = 0;

1699 }

1700 **if** (locked)

1701 **mmap_read_unlock**(mm); 1702 **return** ret; */\* 0 or negative error code \*/* 1703 }

 

*Listing 8-61:* mm/gup.c: [*\_\_mm_populate()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1652)

 

This acquires a read lock on the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore,

iterating through each VMA and performing the actual faulting in of pages

in each VMA via [populate_vma_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1535), taking care to write fault in Copy on Write (CoW) mappings, deferring the actual work of doing so to

[\_\_get_user_pages() :-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1140)

 

1515 */\*\**

1516 *\* populate_vma_page_range() - populate a range of pages in the vma.* 1517 *\* @vma:* *target vma*

1518 *\* @start: start address*

1519 *\* @end:* *end address*

1520 *\* @locked: whether the mmap_lock is still held* 1521 *\**

1522 *\* This takes care of mlocking the pages too if VM_LOCKED is set.* 1523 *\**

 



 

1524 *\* Return either number of pages pinned in the vma, or a negative error* 1525 *\* code on error.*

1526 *\**

1527 *\* vma-\>vm_mm-\>mmap_lock must be held.* 1528 *\**

1529 *\* If @locked is NULL, it may be held for read or write and will* 1530 *\* be unperturbed.*

1531 *\**

1532 *\* If @locked is non-NULL, it must held for read only and may be* 1533 *\* released. If it's released, \*@locked will be set to 0.* 1534 *\*/*

1535 **long populate_vma_page_range**(**struct** vm_area_struct \*vma, 1536 **unsigned long** start, **unsigned long** end, **int** \*locked) 1537 {

1538 **struct** mm_struct \*mm = vma-\>vm_mm; 1539 **unsigned long** nr_pages = (end - start) / **PAGE_SIZE**; 1540 **int** gup_flags;

1541 **long** ret;

1542

1543 **VM_BUG_ON**(!**PAGE_ALIGNED**(start)); 1544 **VM_BUG_ON**(!**PAGE_ALIGNED**(end)); 1545 VM_BUG_ON_VMA(start \< vma-\>vm_start, vma); 1546 VM_BUG_ON_VMA(end \> vma-\>vm_end, vma); 1547 **mmap_assert_locked**(mm); 1548

1549 */\**

1550 *\* Rightly or wrongly, the VM_LOCKONFAULT case has never used* 1551 *\* faultin_page() to break COW, so it has no work to do here.* 1552 *\*/*

1553 **if** (vma-\>vm_flags & **VM_LOCKONFAULT**) 1554 **return** nr_pages; 1555

1556 gup_flags = **FOLL_TOUCH**; 1557 */\**

1558 *\* We want to touch writable mappings with a write fault in order* 1559 *\* to break COW, except for shared mappings because these don't COW*

1560 *\* and we would not want to dirty them for nothing.* 1561 *\*/*

1562 **if** ((vma-\>vm_flags & (**VM_WRITE** \| **VM_SHARED**)) == **VM_WRITE**) 1563 gup_flags \|= **FOLL_WRITE**; 1564

1565 */\**

1566 *\* We want mlock to succeed for regions that have any permissions* 1567 *\* other than PROT_NONE.* 1568 *\*/*

1569 **if** (**vma_is_accessible**(vma)) 1570 gup_flags \|= **FOLL_FORCE**;

 



 

1571

1572 */\**

1573 *\* We made sure addr is within a VMA, so the following will* 1574 *\* not result in a stack expansion that recurses back here.* 1575 *\*/*

1576 ret = **\_\_get_user_pages**(mm, start, nr_pages, gup_flags, 1577 **NULL**, **NULL**, locked); 1578 **lru_add_drain**();

1579 **return** ret;

1580 }

 

*Listing 8-62:* mm/gup.c: [*populate_vma_page_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1535)

 

We won’t examine this too closely, but the key points here are that cus-

tomised logic is applied – here we always touch the pages, we make sure to write fault CoW mappings and use FOLL_FORCE to ensure that the process al-

ways succeeds. We eventually drain folio batches via [lru_add_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727) to en-

sure folios are present in LRU lists immediately afterwards (see section 11.7 for more on folio batches).

 

**8.2 Userland Memory Manipulation APIs**

 

***8.2.1 mlock()***

The [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) system call allows the user to specify that ranges of memory must not be subject to reclaim, but rather must be pinned into memory. This is parameterised by an address and a length over which this should be applied.

The practical upshot of this is that folios in the specified range are not

placed on any LRU list (synthetically they are placed on the [LRU_UNEVICTABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n283) list, but this does not exist in reality and is simply a designation indicating

for the folio not to be placed on a list at all). See Section 11.2 for more de-tails.

The [mlock2()](https://man7.org/linux/man-pages/man2/mlock2.2.html) system call provides the same functionality, only providing

a flags parameter allowing for the [MLOCK_ONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n39) flag to specified, indicating that the range should be locked and all future mappings should be locked as soon as they are faulted into memory.

The [munlock()](https://man7.org/linux/man-pages/man2/munlock.2.html) system call reverses this operation.

In addition to these, there are [mlockall()](https://man7.org/linux/man-pages/man2/mlockall.2.html) and [munlockall()](https://man7.org/linux/man-pages/man2/munlockall.2.html) system calls

which locks and unlocks all memory in the system.

The [mlockall()](https://man7.org/linux/man-pages/man2/mlockall.2.html) system call can specify flags, one or more of which must

be specified— [MCL_CURRENT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman.h?h=v6.0#n18), which indicates that all current mappings should

be locked, [MCL_FUTURE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman.h?h=v6.0#n19), which indicates all future mappings should be locked,

and finally [MCL_ONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman.h?h=v6.0#n20)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman.h?h=v6.0#n20) which is the [mlockall()](https://man7.org/linux/man-pages/man2/mlockall.2.html) equivalent of [MLOCK_ONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n39) which causes locking to occur on fault for mappings not already resident in memory.

By default, locking memory in this fashion causes non-resident memory

to be populated and made resident before being locked. The [MLOCK_ONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n39)

 



 

and [MCL_ONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman.h?h=v6.0#n20) flags alter this behaviour, locking all resident memory and

deferring the locking to the time at which they fault in.

The locking functionality is implemented using the [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) flag at the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) level, and utilising the folio flags [PG_mlocked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n123) and

[PG_unevictable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n121) to indicate that the memory should not be permitted to be

reclaimed.

The [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) system call is implemented in [mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n615) as shown in Listing 8-

63.

 

615 **SYSCALL_DEFINE2**(mlock, **unsigned long**, start, **size_t**, len) 616 {

617 **return do_mlock**(start, len, **VM_LOCKED**); 618 }

 

*Listing 8-63:* mm/mlock.c: [*mlock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n615) *System Call*

 

The [mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n615) system call defers the actual locking mechanism imple-

mented in [do_mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n568) (shown in Listing 8-66), specifying that we want

[VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) to be applied to the memory range, and as a consequence, to cause

all of the memory in the range to have the [PG_mlocked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n123) and [PG_unevictable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n121) flags

applied and thus to remove them from LRU lists and prevent reclaim.

The [mlock2()](https://man7.org/linux/man-pages/man2/mlock2.2.html) system call is similar and implemented in [mlock2()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n620) as shown

in Listing 8-64.

 

620 **SYSCALL_DEFINE3**(mlock2, **unsigned long**, start, **size_t**, len, **int**, flags) 621 {

622 vm_flags_t vm_flags = **VM_LOCKED**;

623

624 **if** (flags & ~**MLOCK_ONFAULT**) 625 **return**-**EINVAL**;

626

627 **if** (flags & **MLOCK_ONFAULT**) 628 vm_flags \|= **VM_LOCKONFAULT**;

629

630 **return do_mlock**(start, len, vm_flags); 631 }

 

*Listing 8-64:* mm/mlock.c: [*mlock2()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n620) *System Call*

 

The [mlock2()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n620) system call behaves similarly to the [mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n615) system call,

only it additionally checks for the [MLOCK_ONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n39) flag (also raising an error if

flags other than this were set), and if it is provided, specifies that both the

[VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) and the [VM_LOCKONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n291) flags should be set to [do_mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n568) (see Listing

8-66).

If no flags are specified (i.e. the flags argument is equal to zero), then

only [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) is provided to [do_mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n568)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n568) and the system call behaves identi-

cally to the [mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n615) system call.

The [munlock()](https://man7.org/linux/man-pages/man2/munlock.2.html) system call is implemented in [munlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n633) as shown in Listing

8-65.

 



 

633 **SYSCALL_DEFINE2**(munlock, **unsigned long**, start, **size_t**, len) 634 {

635 **int** ret;

636

637 start = **untagged_addr**(start); 638

639 len = **PAGE_ALIGN**(len + (**offset_in_page**(start))); 640 start &= **PAGE_MASK**; 641

642 **if** (**mmap_write_lock_killable**(current-\>mm)) 643 **return**-**EINTR**; 644 ret = **apply_vma_lock_flags**(start, len, 0); 645 **mmap_write_unlock**(current-\>mm); 646

647 **return** ret;

648 }

 

*Listing 8-65:* mm/mlock.c: [*munlock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n633) *System Call*

 

The [munlock()](https://man7.org/linux/man-pages/man2/munlock.2.html) system call first obtains an untagged address equivalent of

the provided start address (this is relevant only to architectures which are out of scope for the book).

The entire range is page-aligned, so all base pages touched by the range

will have the unlock operation applied to them.

A write lock on the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore is acquired

then released, and within the critical section the [apply_vma_lock_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n468) func-

tion (see Listing 8-68) is used to effect the unlocking operation, specifying zero in the flags parameter to indicate that any locking VMA flags should be cleared (and with them, the underlying folio flags updated to clear locking flags and place the memory back on reclaim LRU lists).

For the sake of brevity, we won’t examine the [mlockall()](https://man7.org/linux/man-pages/man2/mlockall.2.html) and [munlockall()](https://man7.org/linux/man-pages/man2/munlockall.2.html)

system call implementations as they are a variation on the same theme.

 

568 **static \_\_must_check int do_mlock**(**unsigned long** start, **size_t** len, vm_flags_t

flags)

569 {

570 **unsigned long** locked; 571 **unsigned long** lock_limit; 572 **int** error = -**ENOMEM**; 573

574 start = **untagged_addr**(start); 575

576 **if** (!**can_do_mlock**()) 577 **return**-**EPERM**; 578

579 len = **PAGE_ALIGN**(len + (**offset_in_page**(start))); 580 start &= **PAGE_MASK**; 581

 



 

582 lock_limit = **rlimit**(**RLIMIT_MEMLOCK**); 583 lock_limit \>\>= **PAGE_SHIFT**; 584 locked = len \>\> **PAGE_SHIFT**;

585

586 **if** (**mmap_write_lock_killable**(current-\>mm)) 587 **return**-**EINTR**;

588

589 locked += current-\>mm-\>locked_vm; 590 **if** ((locked \> lock_limit) && (!**capable**(**CAP_IPC_LOCK**))) { 591 */\**

592 *\* It is possible that the regions requested intersect with*

593 *\* previously mlocked areas, that part area in "mm-\>locked_vm"*

594 *\* should not be counted to new mlock increment count. So*

*check*

595 *\* and adjust locked count if necessary.* 596 *\*/*

597 locked -= **count_mm_mlocked_page_nr**(current-\>mm, 598 start, len); 599 }

600

601 */\* check against resource limits \*/* 602 **if** ((locked \<= lock_limit) \|\| **capable**(**CAP_IPC_LOCK**)) 603 error = **apply_vma_lock_flags**(start, len, flags);

604

605 **mmap_write_unlock**(current-\>mm); 606 **if** (error)

607 **return** error;

608

609 error = **\_\_mm_populate**(start, len, 0); 610 **if** (error)

611 **return \_\_mlock_posix_error_return**(error); 612 **return** 0;

613 }

 

*Listing 8-66:* mm/mlock.c: [*do_mlock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n568)

 

In [do_mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n568) we start by acquiring an untagged address (not relevant to

architectures in scope in the book), before performing a simple sanity check

via [can_do_mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n40) which we examine in Listing 8-67.

 

40 **bool can_do_mlock**(**void**)

41 {

42 **if** (**rlimit**(**RLIMIT_MEMLOCK**) != 0)

43 **return true**;

44 **if** (**capable**(**CAP_IPC_LOCK**))

45 **return true**;

46 **return false**;

47 }

 



 

*Listing 8-67:* mm/mlock.c: [*can_do_mlock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n40)

 

In [can_do_mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n40) we check to ensure that the [RLIMIT_MEMLOCK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/resource.h?h=v6.0#n35) resource limit

has not been set to indicate that no locking at all can be specified, if this is not the case we can proceed.

However if this is the case, we also check to see whether the process has

the [CAP_IPC_LOCK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/capability.h?h=v6.0#n215) [capability](https://man7.org/linux/man-pages/man7/capabilities.7.html)[,](https://man7.org/linux/man-pages/man7/capabilities.7.html) which overrides the limit and provides the pro-cess permission to alter memory locking regardless.

Returning to [do_mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n568) in Listing 8-66 we return with an error if these

basic checks fail, then we adjust the length and start of the specified range to make them page-aligned and therefore to ensure we span all pages contain-ing the specified range.

We attempt to acquire a write lock on the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

semaphore, and carefully check the [RLIMIT_MEMLOCK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/resource.h?h=v6.0#n35) limit, overriding it if the

process has the [CAP_IPC_LOCK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/capability.h?h=v6.0#n215) [capability](https://man7.org/linux/man-pages/man7/capabilities.7.html)[.](https://man7.org/linux/man-pages/man7/capabilities.7.html)

With all checks passing, the [apply_vma_lock_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n468) function is invoked

(see Listing 8-68) to apply the locking flags.

With the lock relinquished, the entire range is populated, i.e. faulted

into memory via [\_\_mm_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1652) (see Listing 8-61 and Section 8.1.9).

Importantly, [populate_vma_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1535) (see Listing 8-62), invoked by

[\_\_mm_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1652), will skip VMAs with the [VM_LOCKONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n291) flag set, so this will

have no impact on ranges locked via [mlock2()](https://man7.org/linux/man-pages/man2/mlock2.2.html) with [MLOCK_ONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n39) set.

We examine the invoked [apply_vma_lock_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n468) in Listing 8-68, eliding

debug asserts.

 

468 tatic **int apply_vma_lock_flags**(**unsigned long** start, **size_t** len, 469 **vm_flags_t** flags) 470 {

471 **unsigned long** nstart, end, tmp; 472 **struct** vm_area_struct \*vma, \*prev; 473 **int** error;

. . .

477 end = start + len; 478 **if** (end \< start)

479 **return**-**EINVAL**; 480 **if** (end == start) 481 **return** 0; 482 vma = **find_vma**(current-\>mm, start); 483 **if** (!vma \|\| vma-\>vm_start \> start) 484 **return**-**ENOMEM**; 485

486 prev = vma-\>vm_prev; 487 **if** (start \> vma-\>vm_start) 488 prev = vma; 489

490 **for** (nstart = start ; ; ) { 491 **vm_flags_t** newflags = vma-\>vm_flags & **VM_LOCKED_CLEAR_MASK**;

 



 

492

493 newflags \|= flags;

494

495 */\* Here we know that vma-\>vm_start \<= nstart \< vma-\>vm_end.*

*\*/*

496 tmp = vma-\>vm_end; 497 **if** (tmp \> end) 498 tmp = end; 499 error = **mlock_fixup**(vma, &prev, nstart, tmp, newflags); 500 **if** (error) 501 **break**; 502 nstart = tmp; 503 **if** (nstart \< prev-\>vm_end) 504 nstart = prev-\>vm_end; 505 **if** (nstart \>= end) 506 **break**;

507

508 vma = prev-\>vm_next; 509 **if** (!vma \|\| vma-\>vm_start != nstart) { 510 error = -**ENOMEM**; 511 **break**; 512 }

513 }

514 **return** error;

515 }

 

*Listing 8-68:* mm/mlock.c: [*apply_vma_lock_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n468)

 

The [apply_vma_lock_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n468) function starts by checking for overflow and

empty ranges, before trying to find the first VMA that ends after the start of

the specified range via [find_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2253) (see Listing 4-24 in Chapter 4), returning

an error should either no VMA exist after the specified start or if it located

VMA starts after this (both indicating that the range is invalid).

We then iterate through each of the VMAs in the range specified, clear-

ing locking flags specified by [VM_LOCKED_CLEAR_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n419) (defined as the bitwise

complement of [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) and [VM_LOCKONFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n291)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n291) before applying the specified

flags.

Doing it this way allows for the same function to be used for both locking

and unlocking memory ranges.

We specify tmp as either the end of the current VMA or the entire range

being modified, whichever one comes first before invoking [mlock_fixup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n404) to

do the heavy lifting.

After this, we exit if an error arose, before correctly accounting for the

fact that prev can be modified by [mlock_fixup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n404) during a merge, before reset-

ting everything ready for the next iteration, or if the iteration is complete,

exiting, and handling the case where the next VMA in the range is invalid.

 



 

The [mlock_fixup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n404) function handles any splitting/merging of VMAs as a

result of the application of the new VMA locking flag(s) which are duly set,

before setting folio-level flags via [mlock_vma_pages_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n363).

For brevity, we will not examine these functions in detail.

 

***8.2.2 mprotect()***

The [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html) system call allows users to alter the protection flags describ-ing a range of virtual memory, e.g. adjusting whether the memory range permits read, write or execute access (as well as some architecture/stack-specific flags).

The [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html) system call ultimately invokes [do_mprotect_pkey()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mprotect.c?h=v6.0#n562) to per-

form the modification, which follows the typical pattern of checks to ensure the specified ranges are valid before splitting/merging VMAs accordingly

via [mprotect_fixup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mprotect.c?h=v6.0#n539)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mprotect.c?h=v6.0#n539)

As the behaviour of [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html) is relatively straightforward, but lengthily

and similar to other user memory manipulation functions explored here, we won’t examine the kernel implementation in detail.

 

***8.2.3 mremap()***

The [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html) system call allows for the expansion, shrinking and/or reloca-tion of an existing memory mapping in a process’s virtual address space (i.e. that of a VMA).

By default, this operation will fail if there is insufficient free space to per-

form the operation (e.g. expansion of a VMA when another VMA already exists in the upper part of the range where the VMA would need to be ex-panded to.

However, there is a flags field which allows the specification of

[MREMAP_MAYMOVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n8) which permits the VMA to be moved, at which point pointers to the previously mapped memory range become invalidated.

If, however, the user requires the original mapping to remain, then the

[MREMAP_DONTUNMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n10) flag can be used (and if so, must be used in conjunction

with the [MREMAP_MAYMOVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n8) flag). This is only valid for private anonymous map-pings, and results in the original mapping being maintained but zeroed, i.e. now pointing to the zero page, thus providing zeroes on read, and resulting in a fresh page fault on write.

Finally, the [MREMAP_FIXED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n9) flag permits an additional parameter to be

passed in which a page-aligned fixed address must be specified to indicate where the memory mapping should be relocated. If this flag is specified,

then [MREMAP_MAYMOVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n8) must also be provided as well.

The kernel implementation of the [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html) system call in [mremap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mremap.c?h=v6.0#n886) is very

delicate as it must consider a great many different cases, so we will not exam-ine it in detail for sake of brevity.

 



 

***8.2.4 madvise()***

The [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) system call is used to modify attributes (provide “advice”) for a

memory range. It is considered advisory, as what can be manipulated by this

API are things which impact performance broadly speaking.

As a result, it is not usually guaranteed that the requested operation will

be performed.

The reason the kernel exposes the ability to do so is because the user

might well have more knowledge about how the memory range is intended

to be used than the kernel possesses.

We examine the userland interface in Listing 8-69.

 

**int madvise**(**void** \*addr, **size_t** length, **int** advice);

 

*Listing 8-69:* [*madvise()*](https://man7.org/linux/man-pages/man2/madvise.2.html) *User API*

 

As with all kernel memory interfaces this operates at a page granularity

and thus address must be page-aligned (otherwise a-EINVAL error will arise)

and the length will be rounded up to the page size.

What the function does depends on which flag is specified in the advice

field. This specifies a single flag which determines what [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) will do:

 

**MADV_RANDOM** Indicates that the memory region is going to be accessed ran-

domly and thus a minimal amount of read-ahead and read-behind

should be performed. Sets the [VM_RAND_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n287) VMA flag. Mutually exclu-sive of the MADV_NORMAL and MADV_SEQUENTIAL flags.

**MADV_SEQUENTIAL** Indicates that the memory region is going to be accessed

sequentially therefore aggressive read-ahead is appropriate. Sets

the [VM_RAND_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n287) VMA flag. Mutually exclusive of the MADV_NORMAL and MADV_RANDOM flags.

**MADV_NORMAL** Undoes any previously applied MADV_RANDOM or MADV_SEQUENTIAL in a

memory region.

**MADV_WILLNEED** If the memory range is anonymous, swap in all memory

in range and add an LRU drain so any folios are present in a non-LRU batch get placed into their appropriate LRU vectors. if the range is a shmem mapping, also swap the memory in. If the memory is file-

backed, trigger a read-ahead of the entire range. See Chapter 9 and

Section 9.7 for more details on readahead. This is equivalent to calling

[posix_fadvise()](https://man7.org/linux/man-pages/man2/posix_fadvise.2.html) on a file specifying [POSIX_FADV_WILLNEED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/fadvise.h?h=v6.0#n8)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/fadvise.h?h=v6.0#n8)

**MADV_DONTNEED** Unmap the entire range of memory, i.e. remove all page table

mappings and drop the reverse mapping (and thus a \_mapcount) from the underlying folio. This is a destructive action – if the memory is anony-mous, then it is not swapped out and the data is lost. If it is file-backed and dirty, it will not be written back to disk immediately. This operation will fail for mlock()ed memory. The underlying VMA is not adjusted so if this memory is accessed again the backing store will be faulted back in (though for anonymous pages

 



 

it will be the zero page). This operation is useful for userland freeing up memory it may need in the future but knows it does not need now.

**MADV_DONTNEED_LOCKED** The same as MADV_DONTNEED, however it will also remove

mappings for mlock()ed memory.

**MADV_FREE** (Anonymous only) Mark a memory range as lazy-free. This defers

clearing of the memory until reclaim, but prioritises it for this. If the memory is swapped out, then the mapping is simply removed. If it is in

the swap cache (see Chapter 12 for details) then the cache is freed.

**MADV_REMOVE** (File-backed only) Removes folios from a file-mapping, essen-

tially ‘punching a hole’ in the file mapping over the specified range, which will be mapped to the zero page. This requires the mapping to be shared and writeable, the memory cannot be locked and the filesystem

must support the [fallocate()](https://man7.org/linux/man-pages/man2/fallocate.2.html) mode FALLOC_FL_PUNCH_HOLE.

**MADV_DONTFORK** Indicates that the memory range must not be copied to a child

when a process forks. Sets the [VM_DONTCOPY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n289) VMA flag.

**MADV_DOFORK** Reverses the effect of the MADV_DONTFORK operation and clears the

VM_DONTCOPY VMA flag. Fails if the VM_IO VMA flag is set.

**MADV_WIPEONFORK** (Anonymous only) Marks that memory should be cleared on

fork. The memory must be private, i.e. not shared. Set the [VM_WIPEONFORK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n297) VMA flag.

**MADV_KEEPONFORK** (Anonymous only) Reverses the MADV_WIPEONFORK action.

**MADV_HWPOISON** Forms part of the memory failure functionality in the kernel.

Marks the memory as if it were corrupted by hardware as a form of fault-injection. Out of scope for the book.

**MADV_SOFT_OFFLINE** Forms part of the memory failure functionality in the ker-

nel. Removes memory from general usage through software means as if it were being offlined. Out of scope for the book.

**MADV_MERGEABLE** Forms part of the Kernel Same page Merging (KSM) func-

tionality, indicating that the memory range is a good target for KSM. Out of scope for the book.

**MADV_UNMERGEABLE** Reverses the MADV_MERGEABLE action.

**MADV_HUGEPAGE** Marks the memory range as being suitable for Transparent

Huge Page (THP) merging. Typically this is not required unless the /sys/kernel/mm/transparent_hugepage/enabled tuneable is set to madvise. Huge pages are out of scope for the book.

**MADV_NOHUGEPAGE** Marks a memory range as not being suitable to being

merged into THP. Huge pages are out of scope for the book.

**MADV_DONTDUMP** Marks memory such that it will not appear in core dumps. Sets

the [VM_DONTDUMP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n298) VMA flag.

**MADV_DODUMP** Reverses the MADV_DONTDUMP action, though it is invalid to do this

with non-hugetlb VMAs possessing flags in the [VM_SPECIAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n410) bitmap.

 



 

**MADV_COLD** Deactivates pages in the memory range, causing them to be more

likely to be reclaimed soon under memory pressure. This is used to mark memory that is not likely to be used soon.

**MADV_PAGEOUT** A stronger version of MADV_COLD – direct reclaim the memory in

the range immediately.

**MADV_POPULATE_READ** Fault-in the memory range immediately via the GUP func-

tion [faultin_vma_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1605) by touching the memory but not writing to it, i.e. CoW will not be activated.

**MADV_POPULATE_WRITE** Similar to MADV_POPULATE_READ, only triggering write faults,

i.e. CoW events where necessary.

 

Note that in addition to the [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) system call, there is also a

[process_madvise()](https://man7.org/linux/man-pages/man2/process_madvise.2.html) system call which allows you to provide memory advise for

a remote process.

The [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) system call is implemented in [madvise()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1424) and the

[process_madvise()](https://man7.org/linux/man-pages/man2/process_madvise.2.html) system call is implemented in [process_madvise()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1429)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1429) Both ul-

timately call [do_madvise()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1371) which we examine in Listing 8-70 (eliding out of

scope block device hotplug and memory failure logic and removal of address

tagging which is not relevant to x86-64).

 

1371 **int do_madvise**(**struct** mm_struct \*mm, **unsigned long** start, **size_t** len_in, **int**

behavior)

1372 {

1373 **unsigned long** end; 1374 **int** error;

1375 **int** write;

1376 **size_t** len;

. . .

1381 **if** (!**madvise_behavior_valid**(behavior)) 1382 **return**-**EINVAL**; 1383

1384 **if** (!**PAGE_ALIGNED**(start)) 1385 **return**-**EINVAL**; 1386 len = **PAGE_ALIGN**(len_in); 1387

1388 */\* Check to see whether len was rounded up from small -ve to zero \*/*

1389 **if** (len_in && !len) 1390 **return**-**EINVAL**; 1391

1392 end = start + len; 1393 **if** (end \< start)

1394 **return**-**EINVAL**; 1395

1396 **if** (end == start) 1397 **return** 0;

. . .

1404 write = **madvise_need_mmap_write**(behavior);

 



 

1405 **if** (write) {

1406 **if** (**mmap_write_lock_killable**(mm)) 1407 **return**-**EINTR**; 1408 } **else** {

1409 **mmap_read_lock**(mm); 1410 }

. . .

1413 error = **madvise_walk_vmas**(mm, start, end, behavior, 1414 **madvise_vma_behavior**);

. . .

1416 **if** (write)

1417 **mmap_write_unlock**(mm); 1418 **else**

1419 **mmap_read_unlock**(mm); 1420

1421 **return** error;

1422 }

 

*Listing 8-70:* mm/madvise.c: [*do_madvise()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1371)

 

We can see that in [do_madvise()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1317) (Listing 8-70) no matter what the

requested action is, we both ensure that the behaviour is valid via

[madvise_behavior_valid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1132) (which we examine in Listing 8-71) and that the start address is page-aligned, returning the EINVAL error code if either of these checks fail.

In addition, we perform some checks to ensure the range values speci-

fied are not so large as to overflow, and if the range turns out to be empty, we trivially indicate that the operation succeeded.

 

1131 **static bool**

1132 **madvise_behavior_valid**(**int** behavior) 1133 {

1134 **switch** (behavior) { 1135 **case MADV_DOFORK**: 1136 **case MADV_DONTFORK**: 1137 **case MADV_NORMAL**: 1138 **case MADV_SEQUENTIAL**: 1139 **case MADV_RANDOM**: 1140 **case MADV_REMOVE**: 1141 **case MADV_WILLNEED**: 1142 **case MADV_DONTNEED**: 1143 **case MADV_DONTNEED_LOCKED**: 1144 **case MADV_FREE**:

1145 **case MADV_COLD**:

1146 **case MADV_PAGEOUT**: 1147 **case MADV_POPULATE_READ**: 1148 **case MADV_POPULATE_WRITE**: 1149 **\#ifdef CONFIG_KSM**

1150 **case MADV_MERGEABLE**:

 



 

1151 **case MADV_UNMERGEABLE**: 1152 **\#endif**

1153 **\#ifdef CONFIG_TRANSPARENT_HUGEPAGE** 1154 **case MADV_HUGEPAGE**: 1155 **case MADV_NOHUGEPAGE**: 1156 **\#endif**

1157 **case MADV_DONTDUMP**: 1158 **case MADV_DODUMP**: 1159 **case MADV_WIPEONFORK**: 1160 **case MADV_KEEPONFORK**: 1161 **\#ifdef CONFIG_MEMORY_FAILURE** 1162 **case MADV_SOFT_OFFLINE**: 1163 **case MADV_HWPOISON**: 1164 **\#endif**

1165 **return true**; 1166

1167 **default**:

1168 **return false**; 1169 }

1170 }

 

*Listing 8-71:* mm/madvise.c: [*madvise_behavior_valid()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1132)

 

This ensures that the specified madvise flag is valid (i.e. a known one)

and also that, if a feature-specific flag is specified, then that feature has to be

enabled in the kernel configuration.

We then invoke [madvise_need_mmap_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n50) to determine whether the ac-

tion being performed needs to acquire the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) read-

/write semaphore for writing. The remainder simply need to acquire it for

reading in order that traversed VMAs remain stable throughout (see Section

4.3.4 in Chapter 4 for more details on this critical lock).

We examine this function in Listing 8-72.

 

45 */\**

46 *\* Any behaviour which results in changes to the vma-\>vm_flags needs to*

47 *\* take mmap_lock for writing. Others, which simply traverse vmas, need*

48 *\* to only take it for reading.*

49 *\*/*

50 **static int madvise_need_mmap_write**(**int** behavior)

51 {

52 **switch** (behavior) {

53 **case MADV_REMOVE**:

54 **case MADV_WILLNEED**:

55 **case MADV_DONTNEED**:

56 **case MADV_DONTNEED_LOCKED**:

57 **case MADV_COLD**:

58 **case MADV_PAGEOUT**:

59 **case MADV_FREE**:

60 **case MADV_POPULATE_READ**:

 



 

61 **case MADV_POPULATE_WRITE**: 62 **return** 0; 63 **default**:

64 */\* be safe, default to 1. list exceptions explicitly \*/* 65 **return** 1; 66 }

67 }

 

*Listing 8-72:* mm/madvise.c: [*madvise_need_mmap_write()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n50)

 

In order to be conservative and to avoid performing writes without ade-

quate locking, this function assumes locking unless a read lock is explicitly whitelisted as with the commands listed here.

Once we’ve determined whether a lock is required, we then acquire that

lock, and perform the required behaviour using [madvise_walk_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1194) (Which

we examine in Listing 8-73) which in turn uses [madvise_vma_behavior()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n992) to visit each VMA and perform the required action.

 

1193 **static**

1194 **int madvise_walk_vmas**(**struct** mm_struct \*mm, **unsigned long** start, 1195 **unsigned long** end, **unsigned long** arg, 1196 **int** (\***visit**)(**struct** vm_area_struct \*vma, 1197 **struct** vm_area_struct \*\*prev, **unsigned long**

start,

1198 **unsigned long** end, **unsigned long** arg)) 1199 {

1200 **struct** vm_area_struct \*vma; 1201 **struct** vm_area_struct \*prev; 1202 **unsigned long** tmp; 1203 **int** unmapped_error = 0; 1204

1205 */\**

1206 *\* If the interval \[start,end) covers some unmapped address* 1207 *\* ranges, just ignore them, but return -ENOMEM at the end.* 1208 *\* - different from the way of handling in mlock etc.* 1209 *\*/*

1210 vma = **find_vma_prev**(mm, start, &prev); 1211 **if** (vma && start \> vma-\>vm_start) 1212 prev = vma; 1213

1214 **for** (;;) {

1215 **int** error; 1216

1217 */\* Still start \< end. \*/* 1218 **if** (!vma) 1219 **return**-**ENOMEM**; 1220

1221 */\* Here start \< (end\|vma-\>vm_end). \*/* 1222 **if** (start \< vma-\>vm_start) {

 



 

1223 unmapped_error = -**ENOMEM**; 1224 start = vma-\>vm_start; 1225 **if** (start \>= end) 1226 **break**; 1227 }

1228

1229 */\* Here vma-\>vm_start \<= start \< (end\|vma-\>vm_end) \*/* 1230 tmp = vma-\>vm_end; 1231 **if** (end \< tmp) 1232 tmp = end; 1233

1234 */\* Here vma-\>vm_start \<= start \< tmp \<= (end\|vma-\>vm_end). \*/*

1235 error = **visit**(vma, &prev, start, tmp, arg); 1236 **if** (error) 1237 **return** error; 1238 start = tmp; 1239 **if** (prev && start \< prev-\>vm_end) 1240 start = prev-\>vm_end; 1241 **if** (start \>= end) 1242 **break**; 1243 **if** (prev) 1244 vma = prev-\>vm_next; 1245 **else** */\* madvise_remove dropped mmap_lock \*/* 1246 vma = **find_vma**(mm, start); 1247 }

1248

1249 **return** unmapped_error; 1250 }

 

*Listing 8-73:* mm/madvise.c: [*madvise_walk_vmas()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1194)

 

The [madvise_walk_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1194) function iterates through all VMAs in the range

specified, executing the visit() function for each. If at any stage a gap is lo-

cated, the returned error value is set to ENOMEM, however the operation is still

performed on all valid VMAs within the range.

We start by using [find_vma_prev()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2291) to locate the first VMA whose

[struct vm_area_struct-\>vm_end](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) exceeds start, and locates the prior VMA, if

one exists.

If the start address exceeds the beginning of the located VMA, we set

prev to the same VMA, as prev is intended to track the first VMA prior to the

start of the range.

We then enter a loop, where start is updated as we traverse VMAs in the

specified range.

If no VMA can be found, this indicates that start exceeds the range of

mapped VMAs and thus we simply return ENOMEM and exit, as there can be no

further VMAs to examine.

Since [find_vma_prev()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2291) (and equally [find_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2253), which it calls, which we ex-

amine in Listing 4-24 in Chapter 4) finds the first VMA whose end exceeds

 



 

the specified address, this can result in returning a VMA which begins after the address.

[madvise_walk_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1194) addresses this by checking for this condition, marking

the error condition as ENOMEM (as we span a gap), resetting start to the start of the VMA. If this exceeds the end of the specified range, then the range is invalid, there are no further VMAs to examine and we exit.

We then set tmp to the end of the current VMA (or the end of the range,

whichever is smaller), therefore obtaining the range within the VMA which we need to apply the visit() function to, and call it. If an error arises from this operation, we return that error value.

Note that we pass a pointer to the prev value which, if the caller uses this

value, will be updated.

At this point we reset start to the tmp value, which is the exclusive bound

on the currently examined VMA, and thus will be one past the end of the VMA we just examined.

Since the prev value might be updated by the caller, set to the VMA we

just examined, and a VMA merge might have taken place which could have merged this VMA with one after it, we must consider the case where the start value is located before the end of prev, and thus adjust it to the exclu-sive end value of this VMA.

We check whether we have completed the traversal (as indicated by start

equalling or exceeding end), exiting the loop if so.

Finally, we either use prev (if it exists) to locate the next VMA to examine,

or if this is not available, use [find_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2253) (see Listing 4-24) to locate the next VMA.

For more on VMA traversal, see Section 4.4.5 in Chapter 4.

When making use of the [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) system call, the [madvise_walk_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1194)

function will be called with visit set to [madvise_vma_behavior()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n992), which we ex-

amine in Listing 8-74.

The only other function which might be provided to [madvise_walk_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1194)

is [madvise_vma_anon_name()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1253)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1253) however this is invoked by [prctl()](https://man7.org/linux/man-pages/man2/prctl.2.html) with

[PR_SET_VMA_ANON_NAME](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/prctl.h?h=v6.0#n285) set, so is out of scope here.

 

987 */\**

988 *\* Apply an madvise behavior to a region of a vma. madvise_update_vma* 989 *\* will handle splitting a vm area into separate areas, each area with its own*

990 *\* behavior.*

991 *\*/*

992 **static int madvise_vma_behavior**(**struct** vm_area_struct \*vma, 993 **struct** vm_area_struct \*\*prev, 994 **unsigned long** start, **unsigned long** end, 995 **unsigned long** behavior) 996 {

997 **int** error;

998 **struct anon_vma_name** \*anon_name; 999 **unsigned long** new_flags = vma-\>vm_flags;

1000

1001 **switch** (behavior) {

 



 

1002 **case MADV_REMOVE**: 1003 **return madvise_remove**(vma, prev, start, end); 1004 **case MADV_WILLNEED**: 1005 **return madvise_willneed**(vma, prev, start, end); 1006 **case MADV_COLD**:

1007 **return madvise_cold**(vma, prev, start, end); 1008 **case MADV_PAGEOUT**: 1009 **return madvise_pageout**(vma, prev, start, end); 1010 **case MADV_FREE**:

1011 **case MADV_DONTNEED**: 1012 **case MADV_DONTNEED_LOCKED**: 1013 **return madvise_dontneed_free**(vma, prev, start, end, behavior); 1014 **case MADV_POPULATE_READ**: 1015 **case MADV_POPULATE_WRITE**: 1016 **return madvise_populate**(vma, prev, start, end, behavior); 1017 **case MADV_NORMAL**: 1018 new_flags = new_flags & ~**VM_RAND_READ** & ~**VM_SEQ_READ**; 1019 **break**;

1020 **case MADV_SEQUENTIAL**: 1021 new_flags = (new_flags & ~**VM_RAND_READ**) \| **VM_SEQ_READ**; 1022 **break**;

1023 **case MADV_RANDOM**: 1024 new_flags = (new_flags & ~**VM_SEQ_READ**) \| **VM_RAND_READ**; 1025 **break**;

1026 **case MADV_DONTFORK**: 1027 new_flags \|= **VM_DONTCOPY**; 1028 **break**;

1029 **case MADV_DOFORK**: 1030 **if** (vma-\>vm_flags & **VM_IO**) 1031 **return**-**EINVAL**; 1032 new_flags &= ~**VM_DONTCOPY**; 1033 **break**;

1034 **case MADV_WIPEONFORK**: 1035 */\* MADV_WIPEONFORK is only supported on anonymous memory. \*/*

1036 **if** (vma-\>vm_file \|\| vma-\>vm_flags & **VM_SHARED**) 1037 **return**-**EINVAL**; 1038 new_flags \|= **VM_WIPEONFORK**; 1039 **break**;

1040 **case MADV_KEEPONFORK**: 1041 new_flags &= ~**VM_WIPEONFORK**; 1042 **break**;

1043 **case MADV_DONTDUMP**: 1044 new_flags \|= **VM_DONTDUMP**; 1045 **break**;

1046 **case MADV_DODUMP**: 1047 **if** (!**is_vm_hugetlb_page**(vma) && new_flags & **VM_SPECIAL**) 1048 **return**-**EINVAL**;

 



 

1049 new_flags &= ~**VM_DONTDUMP**; 1050 **break**;

1051 **case MADV_MERGEABLE**: 1052 **case MADV_UNMERGEABLE**: 1053 error = **ksm_madvise**(vma, start, end, behavior, &new_flags); 1054 **if** (error) 1055 **goto out**; 1056 **break**;

1057 **case MADV_HUGEPAGE**: 1058 **case MADV_NOHUGEPAGE**: 1059 error = **hugepage_madvise**(vma, &new_flags, behavior); 1060 **if** (error) 1061 **goto out**; 1062 **break**;

1063 }

1064

1065 anon_name = **anon_vma_name**(vma); 1066 **anon_vma_name_get**(anon_name); 1067 error = **madvise_update_vma**(vma, prev, start, end, new_flags, 1068 anon_name); 1069 **anon_vma_name_put**(anon_name); 1070

1071 **out**:

1072 */\**

1073 *\* madvise() returns EAGAIN if kernel resources, such as* 1074 *\* slab, are temporarily unavailable.* 1075 *\*/*

1076 **if** (error == -**ENOMEM**) 1077 error = -**EAGAIN**; 1078 **return** error;

1079 }

 

*Listing 8-74:* mm/madvise.c: [*madvise_vma_behavior()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n992)

 

We won’t examine the details of each behaviour supported by

[madvise_vma_behavior(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n992)but we note that if the VMA is modified in cases which do not defer to a helper function to entirely perform the requested

action, we invoke [madvise_update_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n139) to apply changes in the VMA, which

we examine in Listing 8-75.

 

133 */\**

134 *\* Update the vm_flags on region of a vma, splitting it or merging it as* 135 *\* necessary. Must be called with mmap_sem held for writing;* 136 *\* Caller should ensure anon_name stability by raising its refcount even when*

137 *\* anon_name belongs to a valid vma because this function might free that vma.*

138 *\*/*

139 **static int madvise_update_vma**(**struct** vm_area_struct \*vma, 140 **struct** vm_area_struct \*\*prev, **unsigned long**

start,

 



 

141 **unsigned long** end, **unsigned long** new_flags, 142 **struct** anon_vma_name \*anon_name) 143 {

144 **struct** mm_struct \*mm = vma-\>vm_mm; 145 **int** error;

146 **pgoff_t** pgoff;

147

148 **if** (new_flags == vma-\>vm_flags && **anon_vma_name_eq**(anon_vma_name(vma),

anon_name)) {

149 \*prev = vma; 150 **return** 0; 151 }

152

153 pgoff = vma-\>vm_pgoff + ((start - vma-\>vm_start) \>\> **PAGE_SHIFT**); 154 \*prev = **vma_merge**(mm, \*prev, start, end, new_flags, vma-\>anon_vma, 155 vma-\>vm_file, pgoff, **vma_policy**(vma), 156 vma-\>vm_userfaultfd_ctx, anon_name); 157 **if** (\*prev) {

158 vma = \*prev; 159 **goto success**; 160 }

161

162 \*prev = vma;

163

164 **if** (start != vma-\>vm_start) { 165 **if** (**unlikely**(mm-\>map_count \>= **sysctl_max_map_count**)) 166 **return**-**ENOMEM**; 167 error = **\_\_split_vma**(mm, vma, start, 1); 168 **if** (error) 169 **return** error; 170 }

171

172 **if** (end != vma-\>vm_end) { 173 **if** (**unlikely**(mm-\>map_count \>= **sysctl_max_map_count**)) 174 **return**-**ENOMEM**; 175 error = **\_\_split_vma**(mm, vma, end, 0); 176 **if** (error) 177 **return** error; 178 }

179

180 **success**:

181 */\**

182 *\* vm_flags is protected by the mmap_lock held in write mode.* 183 *\*/*

184 vma-\>vm_flags = new_flags; 185 **if** (!vma-\>vm_file) { 186 error = **replace_anon_vma_name**(vma, anon_name);

 



 

187 **if** (error) 188 **return** error; 189 }

190

191 **return** 0;

192 }

 

*Listing 8-75:* mm/madvise.c: [*madvise_update_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n139)

 

The [madvise_update_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n139) function assumes that only the flags or anony-

mous VMA name might change, so starts by checking whether either of these have changed—if not, we have nothing to do and exit.

Otherwise, we need to determine whether we can merge the VMA with

ones immediately previous to or succeeding it. This is performed by VMA merging, and if this fails, splitting the VMA if the range being altered does not align with the entire length of the VMA (remembering that VMAs are defined by having the same characteristics, so if flags or the name of the VMA are altered this dictates that a new VMA is required).

The merging of the VMA is performed by [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122), which we explore

starting in Listing **??** in Section 5.1.1 and Chapter 5. VMA splitting is han-

dled by [\_\_split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676) which we explore in Listing 5-47 and Section 5.1.4 in the same chapter.

At this stage we have explored the general structure of the [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) sys-

tem call implementation, leaving the detailed implementation of the various operations unexplored for brevity. However exploring the functions refer-

enced by [madvise_vma_behavior()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n992) and shown in Listing 8-74 will indicate how each of these are implemented.

 



 

**9**

 