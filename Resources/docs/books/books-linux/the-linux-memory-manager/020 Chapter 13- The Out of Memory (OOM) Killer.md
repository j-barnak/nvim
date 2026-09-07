


**13**



**T H E O U T O F M E M O R Y ( O O M )**



**K I L L E R**



When we are unable to allocate memory due to zones

dipping below their minimum watermark, memory re-

serves are exhausted, and direct reclaim has failed we

must take drastic action to avoid the system becom-

ing unusable. At this stage the Out of Memory (OOM)

Killer steps in, finds the biggest memory hog and kills

the process and all associated threads. In this chapter

we explore how this is implemented and the criteria

the OOM killer uses to determine which process to

eliminate.

One of the central tenets of the Linux memory management subsystem

is the disconnect between virtual memory mappings and the physical mem-

ory which backs them.

Ordinarily, a mapping performed by [malloc()](https://man7.org/linux/man-pages/man3/malloc.3.html) or [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) will result in ab-

solutely no physical memory being allocated. Instead, the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

object describing a process’s address space object will have a new

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (Virtual Memory Area or “VMA”) object assigned to

it, describing the mapped range (see chapters 3 and 4 for an in-depth discus-

sion).




The actual allocation of memory is therefore only performed when a pro-

cess attempts to access it, at which point a CPU hardware fault arises which

is trapped by the kernel and processed as a “page fault” (see Chapter 6).

On page fault, the faulting address is checked to determine whether it is

address is within a valid VMA range. If so, memory is allocated as necessary, if not a segfault signal is sent to the process.

As a result, it becomes entirely possible for a process to access a valid

mapping that causes the kernel to attempt to allocate physical memory, only to find it is unable to do so.

In this situation the kernel must do something in order to maintain system

stability, as the mapping of the memory is a long-distant memory and there is no mechanism by which to indicate to the process which mapped it that the allocation could not be performed.



**N O T E** It’s also important to note that, even if the mapping process could somehow be in-

formed, it would most likely result in that process simply terminating, as it is rarely the case that an arbitrary allocation can simply be allowed to fail. Given that the process(es) which are causing the memory pressure might well be distinct from the one happening to fault, this wouldn’t even necessarily help relieve the underlying mem-ory pressure anyway.



That something is the Out of Memory (OOM) killer, which resolves the

situation by determining which process is using the most memory (subject to manual user adjustment via the /proc/oom_score_adj interface see Section

13.2) and kills it, thus (hopefully) freeing sufficient memory to complete the failing allocation.

The selection of a process to kill (the “victim”) and freeing it (“reaping”

it) are two separate events, occurring at different times. The victim is se-lected as soon as the OOM killer event occurs, and then a kernel thread as-signed to reaping victim threads is woken to perform the actual freeing of memory.

A failed allocation will be retried as long as forward progress is made

in freeing up memory, and the selection of an OOM victim constitutes progress, thus the actual result of the killing will tell after it has been ini-

tiated. See Section 13.4 below for a detailed examination of how this oc-

curs and Chapter 11 for a detailed examination of how forward progress is utilised as a concept on reclaim.

A manual invocation of the OOM killer can also be performed via the

sysrq-f operation, see Section 13.1.2 for details.



**13.1 Causes of Out of Memory Conditions**



***13.1.1 Memory Allocation***

As described in Chapter 2, in order to ensure that the system never reaches a point where memory is so critically low that the kernel might not be able to function, we must maintain minimum reserves and establish watermarks below which we start to attempt to free up memory.







These watermarks are maintained per-zone, per-NUMA node (if NUMA

is enabled) and determine the point at which reclaim occurs. Reclaim is the

means by which the kernel frees up memory without killing any processes

(see chapter 11 for a detailed exploration of reclaim).

While this is covered in chapter 2, but briefly—a zone is simply a named

physical memory range. For instance, the first 16 MiB of x86-64 machines

is designated [ZONE_DMA](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n432)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n432) as this is the only range of physical memory very old

DMA devices could access. Each NUMA node further subdivides the physi-

cal memory range, associating CPUs with the memory they are electronically

local to. Nodes can span multiple zones.



**N O T E** NUMA is an abbreviation for Non-Uniform Memory Access, and describes the mech-

anism by which the kernel handles architectures which have memory which is not

equally fast to access from all CPUs. Beyond the fundamentals around nodes and

zones, this is out of scope for the book.



For file-backed memory, reclaim can be as simple as dropping memory

from the page cache (see chapter 9), for anonymous i.e. non-file backed

memory this involves swapping memory out to disk. Kernel memory allo-

cated using the slab allocator might also reduce cache sizes via shrinkers (the

slab allocator is out of scope for the book).

When physical memory is allocated, it ultimately originates from a spe-

cific zone (see chapter 2 for the details as to how this is designated). When

doing so, the zone watermarks are checked. There are three core water-

marks – [WMARK_MIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n350), [WMARK_LOW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n351) and [WMARK_HIGH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n352) (there’s also [WMARK_PROMO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n353), but this is

used by NUMA for very specific purposes which are out of scope here).

When the low watermark is reached, indirect reclaim is started in the

form of the kswapd kernel thread (there is one process per NUMA node).

This performs reclaim in the background until at least one zone which could

serve the allocation reaches the high watermark, at which point it sleeps

(again, see chapter 11 for more on reclaim).

If the memory pressure is extreme, this might not be enough – in this

instance, a zone might reach the minimum water mark at which point direct

reclaim can occur – this is reclaim that the process must wait until before

proceeding.

Finally, if the direct reclaim cannot free up sufficient memory, we are

left in a difficult position where we are simply unable to service a page fault,

which renders the process unable to continue executing.

The simplest solution to this would be to kill the faulting process causing

the allocation, however this would be unfair – the disconnect between map-

ping and backing of memory in linux means that a faulting process may have

absolutely no relation to one which is using excessive memory.



**N O T E** It’s actually possible to cause the kernel to kill the allocating process via the

*vm.oom_kill_allocating_task* tunable. See Section 13.3 for details.







Instead, we invoke the Out Of Memory killer to elect the most appropri-

ate victim to kill whose memory we can immediately free. This maintains system stability even in the face of extreme memory pressure.

It’s worth reflecting on how we might end up in this situation in the first

place – how can a process allocate more memory than the system has avail-able? The answer is overcommit – by default, the kernel does not constrain memory mapping such that it must fit in available physical memory, rather it simply disallows any one mapping which exceeds available physical and swap

memory (see Chapter 4 for more details on this).



***13.1.2 sysrq-f***

The [sysrq](https://kernel.org/doc/html/v6.0/admin-guide/sysrq.html) interface is a means by which users can perform actions using a special key combination (typically alt + the sysrq/print screen key + a letter to indicate the task to perform).

This may not even be enabled by your kernel (you can determine this by

examining the kernel.sysrq tunable which masks out various available sysrq operations). Even if unavailable from the command line, it’s possible to trig-ger sysrq events by writing to the /proc/sysrq-trigger procfs interface.

An OOM killer-relevant operation exposed by this interface is sysrq-f,

which causes the out of memory killer to be unconditionally invoked and to kill the process using the most resources as if an allocation had failed.

This will not result in a kernel panic no matter the outcome of the OOM

killer invocation, it will simply perform the kernel’s process selection logic and terminate the selected process.

See Section 13.4 for a detailed analysis as to how this actually imple-

mented within the kernel.



**13.2 OOM Killer Score Adjustment**



It is possible to adjust the likelihood of a process being selected for termina-tion via the OOM killer score adjustment interface as exposed per-process via procfs in /proc/\$pid/oom_score_adj (there is also an /proc/\$pid/oom_adj inter-face, however this is deprecated and simply used to calculate a value to set oom_score_adj to so we disregard it).

The score is standardised to a range of-1000 to 1000, and defaults to 0. At

0 , the process is as likely as any other (unadjusted) process to be selected by the OOM killer. At-1000 the process will never be killed by the OOM killer, and at 1000 the process will almost certainly be selected (unless an alterna-tive process which also has a very high adjustment score assigned uses more memory).

When the OOM killer considers a process for termination, it does so by

determining how much resident memory it is utilising and compares it to all the other processes in the system, selecting the one that is using the most resident memory.







**N O T E** It’s possible to “constrain” the OOM killer to specific cgroups, cpusets or NUMA

arrangements, however this is out of the scope of the book so we consider only the

“global” OOM killer scenario where we examine all running processes and examine

their total resident memory usage as a proportion of all available memory.



This calculation is performed in terms of the number of base pages

each process is using, a value which we can adjust per-process using the per-

process oom_score_adj value.

The adjustment score is expressed in units of one tenth of a percent of

total available memory (combining RAM and total swap). This is used to cal-

culate the equivalent in base pages and this is simply added to the number

of base pages of RAM and swap a candidate process is using, thus adjusting

the likelihood of that process being selected.

This score can therefore be seen as either permitting a process to utilise

a certain percentage of system memory before being considered for termina-

tion (if negative) or to be treated as if it already uses a certain percentage of

memory before examining its actual usage (if positive).

For instance, a process with an oom_score_adj of -400 can utilise 40% of

memory and swap before it will be considered for termination (unless all

other processes have negative adjustment scores), and a process with an

oom_score_adj of 20 will be treated as if it is already using 2% more of mem-

ory and swap than it actually is.



**N O T E** A value of*-1000*, i.e. the minimum possible OOM score adjustment, is given special

treatment and explicitly excludes a process from being considered by the OOM killer.



See Section 13.4 for a detailed analysis of how the kernel actually per-

forms the selection of the “bad” process to be terminated.



***13.2.1 OOM Score***

It’s possible to read the current “score” of a process via /proc/\$pid/oom_score,

as implemented by [proc_oom_score()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n549)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n549)

This determines the number of base pages of memory a process occu-

pies including any adjustment by its /proc/\$pid/oom_score_adj, converting this

into integer units expressed in tenth of a percent of total RAM and swap and

then “normalising” it to a range of 0 to 2000.

This normalisation is performed by offsetting the tenth of a percent

score value by 1000 (thus mapping the minimum possible value to 0 rather

than-1000), and scaling this sum by two thirds.

This scaling by two thirds accounts for the absolute maximum a pro-

cess could (theoretically, but not practically) occupy, i.e. 100% of memory

and the maximum possible oom_score_adj, which summed to the offset value

would equal 3000, scaling by two thirds constrains this to a maximum value of

2000 instead.

This dance is performed as the value had always been constrained to this

range in the past, and userland processes might be reliant on this remaining

the case.







**13.3 OOM Killer Alternative Behaviours**



It’s possible to adjust the standard behaviour of the OOM killer further via two specific tunables—vm.panic_on_oom and vm.oom_kill_allocating_task.



***13.3.1 vm.panic_on_oom***

The vm.panic_on_oom tunable causes the OOM killer to unconditionally cause a kernel panic in the event of an Out of Memory condition, except if it was

triggered by sysrq-f (see Section 13.1.2).

This tunable can be tailored to only cause the panic on global OOM

killer invocations rather than ones constrained to cgroup, cpusets or NUMA arrangements, however these types of OOM killer events are out of scope of the book so we disregard this mode of operation.

This might be useful in situations where it is simply unacceptable for the

OOM killer to be invoked and it being so is indicative of the system failing to perform as required.



***13.3.2 vm.oom_kill_allocating_task***

The vm.oom_kill_allocating_task tunable, if set, causes the allocating process to be the one which is terminated regardless of whether that process utilises a large amount of memory or not.



**N O T E** If the process’s *oom_score_adj* is set to the minimum value, i.e.*-1000*, then even if this

tunable is set it will not be terminated and instead the default OOM killer behaviour will proceed.



This is unlikely to be the kind of behaviour that a user would actually de-

sire in practice, especially as the faulting process might itself be utilising very little memory, and the process which is actually causing the problem might cause a great deal of collateral damage of other faulting processes before it is finally reaped.



**13.4 Kernel Interface**



We examine an overview of the kernel interface in Figure 13-1.







Core allocation path sysrq-f invocation



[\_\_alloc_pages_may_oom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4381) [moom_callback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/tty/sysrq.c?h=v6.0#n385)



[out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107)



[select_bad_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n364) [oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1014)



[oom_evaluate_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308) [\_\_oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n197)



[oom_badness()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n201) [mark_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757) Send SIGKILL [queue_oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n691)



1. Evaluate & 2. Kill & queue for

Choose Process reaping if kill fails



*Figure 13-1: OOM Killer Kernel Interface*



The OOM killer implementation is conveniently entirely implemented

in the [mm/oom_kill.c](https://elixir.bootlin.com/linux/v6.0/source/mm/oom_kill.c) file. It is invoked via the [out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107) function and

parameterised by a [struct oom_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n29) object, as shown in Listing 13-1.



25 */\**

26 *\* Details of the page allocation that triggered the oom killer that are used*

*to*

27 *\* determine what should be killed.*

28 *\*/*

29 **struct** oom_control {

30 */\* Used to determine cpuset \*/*

31 **struct** zonelist \*zonelist;

32

33 */\* Used to determine mempolicy \*/*

34 **nodemask_t** \*nodemask;

35

36 */\* Memory cgroup in which oom is invoked, or NULL for global oom \*/*

37 **struct** mem_cgroup \*memcg;

38

39 */\* Used to determine cpuset and node locality requirement \*/*

40 **const gfp_t** gfp_mask;

41

42 */\**







43 *\* order == -1 means the oom kill is required by sysrq, otherwise only*

44 *\* for display purposes.* 45 *\*/*

46 **const int** order;

47

48 */\* Used by oom implementation, do not set \*/* 49 **unsigned long** totalpages; 50 **struct** task_struct \*chosen; 51 **long** chosen_points; 52

53 */\* Used to print the constraint info. \*/* 54 **enum** oom_constraint constraint; 55 };



*Listing 13-1:* include/linux/oom.h: [*struct oom_control*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n29)



Before we investigate the OOM killer’s code, let’s examine the fields of

this object which controls the process.



**zonelist** A [struct zonelist](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n878) (See Chapter 2 for more details, but broadly

this is an array of [struct zoneref](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n859) objects each containing a link to a

[struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) object (which describes the portion of a zone belonging to

a specific node) and an [enum zone_type](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n420) index value which indicates which

type of zone this is, e.g. [ZONE_DMA](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n432), [ZONE_DMA32](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n435), [ZONE_NORMAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n442)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n442) etc.) object con-

taining a list of zones spanned by this NUMA node if the [\_\_GFP_THISNODE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n108) flag is set, otherwise zones spanned by all nodes, starting with this one in order of the expense of accessing memory on each node. From the

point of view of the OOM killer, this is referenced in [constrained_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n251)

to determine whether the cgroup [cpuset](https://man7.org/linux/man-pages/man7/cpuset.7.html) functionality constrains the allo-

cation (see the [cgroup v2 admin guide on cpuset settings).](https://kernel.org/doc/html/v6.0/admin-guide/cgroup-v2.html#cpuset-interface-files) cgroups are out of scope for the book.

**nodemask** If a NUMA memory policy is in force which restricts which nodes

can be utilised for the allocation, then this parameter will be non-NULL and indicate on which nodes processes we consider for killing may be located. A detailed discussion of NUMA memory policies is out of scope for the book.

**memcg** Out of memory conditions can occur within a memory cgroup

controller or memcg. If so, the condition will be triggered by

[mem_cgroup_out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memcontrol.c?h=v6.0#n1630), which will specify the memcg which has en-tered an out of memory condition.

Out of memory conditions for memcgs are handled somewhat differ-ently than the global kind and follow different code paths, however dis-cussion of this topic is out of scope for the book.

**gfp_mask** The Get Free Pages (GFP) flags specified for the physical alloca-

tion which caused the out of memory failure. These parameterise kernel allocation functions, modifying how these allocations are performed. This is useful information in a few respects – for the NUMA case, if







[\_\_GFP_THISNODE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n108) is specified, then we know not to further consider node constraints.

In additional this is informational and allows us to report it back to the user.

**order** Indicates the order of the allocation being performed for informa-

tional purposes only. Set to-1 if sysrq-f was used to trigger the OOM killer manually.

**totalpages** internal The total number of base pages of memory available in

the system as a whole (comprising both physical memory and swap.

**chosen** internal Tracks the process chosen to be terminated.

**chosen_points** internal Tracks the “badness points” assigned to the chosen

process.

**constraints** internal Indicates memory policy, cgroup, etc. constraints ap-

plied to the out of memory killer invocation. The discussion of these are out of scope for the book.



***13.4.1 Allocating Memory at Risk of OOM***

As explored in Chapter 2, we attempt to allocate memory using Per-CPU-

Page (PCP) lists, failing this we try to allocate such that no zone has its mem-

ory reduced below the low water mark. Should this fail, we enter into the

allocation “slow path” and invoke [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) (see Section 11.1

and the Listings starting with 11-1 in Chapter 11 for more details).

Reclaim will, under this circumstance, attempt to allocate from a zone at

the minimum watermark. Should this fail, and the allocation flags permit it,

direct reclaim will be attempted to synchronously make available memory to

fulfil the request.

If, finally, this fails to free up sufficient memory to satisfy the allocation,

then [\_\_alloc_pages_may_oom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4381) is invoked to make a last gasp attempt at allocat-

ing the memory, invoking the OOM killer and freeing up memory if neces-

sary to do so.

We explore this function in Listing 13-2.



4380 **static inline struct** page \* 4381 **\_\_alloc_pages_may_oom**(**gfp_t** gfp_mask, **unsigned int** order, 4382 **const struct** alloc_context \*ac, **unsigned long** \*did_some_progress) 4383 {

4384 **struct** oom_control oc = { 4385 .zonelist = ac-\>zonelist, 4386 .nodemask = ac-\>nodemask, 4387 .memcg = **NULL**, 4388 .gfp_mask = gfp_mask, 4389 .order = order, 4390 };

4391 **struct** page \*page; 4392







4393 \*did_some_progress = 0; 4394

4395 */\**

4396 *\* Acquire the oom lock. If that fails, somebody else is* 4397 *\* making progress for us.* 4398 *\*/*

4399 **if** (!**mutex_trylock**(&oom_lock)) { 4400 \*did_some_progress = 1; 4401 **schedule_timeout_uninterruptible**(1); 4402 **return NULL**; 4403 }

4404

4405 */\**

4406 *\* Go through the zonelist yet one more time, keep very high watermark*

4407 *\* here, this is only to catch a parallel oom killing, we must fail if*

4408 *\* we're still under heavy pressure. But make sure that this reclaim*

4409 *\* attempt shall not depend on \_\_GFP_DIRECT_RECLAIM && !\_\_GFP_NORETRY*

4410 *\* allocation which will never fail due to oom_lock already held.*

4411 *\*/*

4412 page = **get_page_from_freelist**((gfp_mask \| **\_\_GFP_HARDWALL**) & 4413 ~**\_\_GFP_DIRECT_RECLAIM**, order, 4414 **ALLOC_WMARK_HIGH**\|**ALLOC_CPUSET**, ac); 4415 **if** (page)

4416 **goto out**; 4417

4418 */\* Coredumps can quickly deplete all memory reserves \*/* 4419 **if** (current-\>flags & **PF_DUMPCORE**) 4420 **goto out**; 4421 */\* The OOM killer will not help higher order allocs \*/* 4422 **if** (order \> **PAGE_ALLOC_COSTLY_ORDER**) 4423 **goto out**; 4424 */\**

4425 *\* We have already exhausted all our reclaim opportunities without any*

4426 *\* success so it is time to admit defeat. We will skip the OOM killer*

4427 *\* because it is very likely that the caller has a more reasonable*

4428 *\* fallback than shooting a random task.* 4429 *\**

4430 *\* The OOM killer may not free memory on a specific node.* 4431 *\*/*

4432 **if** (gfp_mask & (**\_\_GFP_RETRY_MAYFAIL** \| **\_\_GFP_THISNODE**)) 4433 **goto out**; 4434 */\* The OOM killer does not needlessly kill tasks for lowmem \*/* 4435 **if** (ac-\>highest_zoneidx \< **ZONE_NORMAL**) 4436 **goto out**; 4437 **if** (**pm_suspended_storage**()) 4438 **goto out**; 4439 */\**







4440 *\* XXX: GFP_NOFS allocations should rather fail than rely on* 4441 *\* other request to make a forward progress.* 4442 *\* We are in an unfortunate situation where out_of_memory cannot* 4443 *\* do much for this context but let's try it to at least get* 4444 *\* access to memory reserved if the current task is killed (see* 4445 *\* out_of_memory). Once filesystems are ready to handle allocation*

4446 *\* failures more gracefully we should just bail out here.* 4447 *\*/*

4448

4449 */\* Exhausted what can be done so it's blame time \*/* 4450 **if** (**out_of_memory**(&oc) \|\| 4451 **WARN_ON_ONCE_GFP**(gfp_mask & **\_\_GFP_NOFAIL**, gfp_mask)) { 4452 \*did_some_progress = 1; 4453

4454 */\**

4455 *\* Help non-failing allocations by giving them access to*

*memory*

4456 *\* reserves* 4457 *\*/*

4458 **if** (gfp_mask & **\_\_GFP_NOFAIL**) 4459 page = **\_\_alloc_pages_cpuset_fallback**(gfp_mask, order, 4460 **ALLOC_NO_WATERMARKS**, ac); 4461 }

4462 **out**:

4463 **mutex_unlock**(&oom_lock); 4464 **return** page;

4465 }



*Listing 13-2:* mm/page_alloc.c: [*\_\_alloc_pages_may_oom()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4381)



The function starts by attempting to acquire the global out of memory

lock, [oom_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n67)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n67) It treats the lock being contended as an indicator that another

process is performing out of memory handling, and treats this as indicating

that progress is being made.



**N O T E** The [*\_\_alloc_pages_may_oom()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4381) function operates in a best effort fashion—if progress

of any kind has been made, the calling [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) function will loop

around and try the allocation again.



We attempt to allocate memory again via [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166), only

setting a very high watermark and disallowing direct reclaim—this is a last

gasp attempt to see whether we can avoid killing a process, as if a process is

being torn down in parallel this may succeed in which case it’s safe to abort

the operation.

We then handle some edge cases—if the current process is performing a

core dump then all memory reserves might quickly be depleted if we permit

the allocation to succeed.

Equally higher order folios which reclaim struggles to provide (as deter-

mined by the order exceeding [PAGE_ALLOC_COSTLY_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40), hardcoded to order-3)







are unlikely to be helped by the freeing of folios from a memory hog, so in this case we also fail the allocation.

Equally if the [\_\_GFP_RETRY_MAYFAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n219) flag is set then it is fine for us to fail and

we should not resort to invoking the OOM killer. Also if [\_\_GFP_THISNODE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n108) is set, we cannot help as we are unable to restrict the operation to this node alone.

If the maximum zone that can be allocated is less than [ZONE_NORMAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n442), we

again cannot be certain that the killing of a process will free memory in the required zone, so we abort in this case also.

Finally, if the global [gfp_allowed_mask](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n268) value has [\_\_GFP_IO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n214) or [\_\_GFP_FS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n215)

cleared, as checked by [pm_suspended_storage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n340)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n340) then this indicates that the freeing of memory via the OOM killer will not succeed correctly and thus we must abort the allocation.

Finally, we are ready to actually invoke the OOM killer, which is done via

[out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107). If this succeeds, or if the [\_\_GFP_NOFAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n220) flag was set, indicating that we cannot tolerate an allocation failure, we indicating progress was in-

deed made, and if the [\_\_GFP_NOFAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n220) flag is set we attempt an allocation with no watermark limitations performed in order to access all available memory reserves.

See Chapter 2 for more details on GFP flags and physical allocation, and

## Chapter 11 for more on the calling [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) function.

We examine [out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107) in Listing 13-5 and Section 13.4.3.



***13.4.2 Manual OOM Killer Invocation Via sysrq-f***

When a user invokes the sysrq key stroke with the f key (typically Control + Sysrq/PrintScrn + F), and sysrq is enabled at a level that permits this (or the user manually passes f to /proc/sysrq-trigger), this invokes a man-

ual run of the OOM killer via [sysrq_handle_moom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/tty/sysrq.c?h=v6.0#n404) which ultimately invokes

[moom_callback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/tty/sysrq.c?h=v6.0#n385) which we examine in Listing 13-3.



385 **static void moom_callback**(**struct** work_struct \*ignored) 386 {

387 **const gfp_t** gfp_mask = **GFP_KERNEL**; 388 **struct** oom_control oc = { 389 .zonelist = **node_zonelist**(first_memory_node, gfp_mask), 390 .nodemask = **NULL**, 391 .memcg = **NULL**, 392 .gfp_mask = gfp_mask, 393 .order = -1, 394 };

395

396 **mutex_lock**(&oom_lock); 397 **if** (!**out_of_memory**(&oc)) 398 **pr_info**("OOM request ignored. No task eligible\n"); 399 **mutex_unlock**(&oom_lock); 400 }



*Listing 13-3:* drivers/tty/sysrq.c: [*moom_callback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/tty/sysrq.c?h=v6.0#n385)







We configure an [struct oom_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n29) object and pass it to [out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107) in

the same way we invoke the OOM killer on allocation, however importantly

we set the order to-1 to indicate that this is a manual invocation.

If the attempt to kill a memory hog fails, then we simply report that this

effort failed here.

Within the OOM killer implementation we use the fact that the order

of a manual sysrq-invoked OOM killer invocation sets order to -1 to identify

this and avoid certain behaviours that are pertinent only to low memory sce-

narios such as panic-on-oom and panicking should no process be found to

terminate. This check is performed by [is_sysrq_oom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n156) which we examine in

Listing 13-4.



152 */\**

153 *\* order == -1 means the oom kill is required by sysrq, otherwise only* 154 *\* for display purposes.*

155 *\*/*

156 **static inline bool is_sysrq_oom**(**struct** oom_control \*oc) 157 {

158 **return** oc-\>order == -1; 159 }



*Listing 13-4:* mm/oom_kill.c: [*is_sysrq_oom()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n156)



***13.4.3 The Out of Memory Killer***

The key function which performs the out of memory handling is

[out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107), which we explore in Listing 13-5 (eliding OOM killer noti-

fier and cgroup/NUMA constraint logic).



1098 */\*\**

1099 *\* out_of_memory - kill the "best" process when we run out of memory* 1100 *\* @oc: pointer to struct oom_control* 1101 *\**

1102 *\* If we run out of memory, we have the choice between either* 1103 *\* killing a random task (bad), letting the system crash (worse)* 1104 *\* OR try to be smart about which process to kill. Note that we* 1105 *\* don't have to be perfect here, we just have to be good.* 1106 *\*/*

1107 **bool out_of_memory**(**struct** oom_control \*oc) 1108 {

1109 **unsigned long** freed = 0; 1110

1111 **if** (**oom_killer_disabled**) 1112 **return false**;

. . .

1121 */\**

1122 *\* If current has a pending SIGKILL or is exiting, then automatically*

1123 *\* select it. The goal is to allow it to allocate so that it may*







1124 *\* quickly exit and free its memory.* 1125 *\*/*

1126 **if** (**task_will_free_mem**(**current**)) { 1127 **mark_oom_victim**(**current**); 1128 **queue_oom_reaper**(**current**); 1129 **return true**; 1130 }

1131

1132 */\**

1133 *\* The OOM killer does not compensate for IO-less reclaim.* 1134 *\* pagefault_out_of_memory lost its gfp context so we have to* 1135 *\* make sure exclude 0 mask - all other users should have at least*

1136 *\* \_\_\_GFP_DIRECT_RECLAIM to get here. But mem_cgroup_oom() has to*

1137 *\* invoke the OOM killer even if it is a GFP_NOFS allocation.* 1138 *\*/*

1139 **if** (oc-\>gfp_mask && !(oc-\>gfp_mask & **\_\_GFP_FS**) && !**is_memcg_oom**(oc)) 1140 **return true**;

. . .

1149 **check_panic_on_oom**(oc); 1150

1151 **if** (!**is_memcg_oom**(oc) && **sysctl_oom_kill_allocating_task** && 1152 **current**-\>mm && !**oom_unkillable_task**(**current**) &&

. . .

1154 **current**-\>signal-\>oom_score_adj != **OOM_SCORE_ADJ_MIN**) { 1155 **get_task_struct**(**current**); 1156 oc-\>chosen = **current**; 1157 **oom_kill_process**(oc, "Out of memory (oom_kill_allocating_task)

");

1158 **return true**; 1159 }

1160

1161 **select_bad_process**(oc); 1162 */\* Found nothing?!?! \*/* 1163 **if** (!oc-\>chosen) { 1164 **dump_header**(oc, **NULL**); 1165 **pr_warn**("Out of memory and no killable processes...\n"); 1166 */\**

1167 *\* If we got here due to an actual allocation at the* 1168 *\* system level, we cannot survive this and will enter* 1169 *\* an endless loop in the allocator. Bail out now.* 1170 *\*/*

1171 **if** (!**is_sysrq_oom**(oc) && !**is_memcg_oom**(oc)) 1172 **panic**("System is deadlocked on memory\n"); 1173 }

1174 **if** (oc-\>chosen && oc-\>chosen != (**void** \*)-1UL) 1175 **oom_kill_process**(oc, !**is_memcg_oom**(oc) ? "Out of memory" : 1176 "Memory cgroup out of memory");







1177 **return** !!oc-\>chosen; 1178 }



*Listing 13-5:* mm/oom_kill.c: [*out_of_memory()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107)



We start by checking whether the OOM killer is completely disabled

via the [oom_killer_disabled](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n480) global. This is disabled by [oom_killer_disable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n818)

on power events or kexec (a means by which a new kernel can be loaded

into a running kernel) in [freeze_processes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/power/process.c?h=v6.0#n120)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/power/process.c?h=v6.0#n120) The OOM is re-enabled via

[oom_killer_enable().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n797)

We then invoke the [task_will_free_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n870) on the current process (we ex-

amine this in Listing 13-7), which determines whether a process is in the

process of freeing memory (i.e. by exiting and tearing down its memory),

in which case we should mark it as the target OOM victim and queue it to be

reaped immediately, exiting indicating the OOM killing has been initiated.

We mark a process as an OOM victim via [mark_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757) which we ex-

amine in Listing 13-18, and queue it for reaping via [queue_oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n691) which

we examine in Listing 13-21.

If a GFP mask has been specified by the failed allocation, and this has

[\_\_GFP_FS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n215) cleared, this indicates that the filesystem cannot be accessed (for in-

stance the allocation was made by a filesystem and this flag has been cleared

to prevent an infinite regression), but this is not a condition we can satisfy,

as killing a process can’t provide memory in this context.

By convention, under these circumstances, we return true, indicating

that we should loop around and attempt allocations again.

We then check to see whether we ought to panic on OOMs as specified

by the vm.panic_on_oom tunable via [check_panic_on_oom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1063) which we examine in

Listing 13-6 (eliding out of scope constrained NUMA/cgroup allocation

checks).



1063

1064 **static void check_panic_on_oom**(**struct** oom_control \*oc) 1065 {

1066 **if** (**likely**(!**sysctl_panic_on_oom**)) 1067 **return**;

. . .

1077 */\* Do not panic for oom kills triggered by sysrq \*/* 1078 **if** (**is_sysrq_oom**(oc)) 1079 **return**;

1080 **dump_header**(oc, **NULL**); 1081 **panic**("Out of memory: %s panic_on_oom is enabled\n", 1082 **sysctl_panic_on_oom** == 2 ? "compulsory" : "system-wide"); 1083 }



*Listing 13-6:* mm/oom_kill.c: [*check_panic_on_oom()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1063)



If the [sysctl_panic_on_oom](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n55) global variable has been set as a result of the

vm.panic_on_oom tunable having been set, then we only fail to panic if the

OOM killer was invoked via sysrq-f.







Returning to [out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107) in Listing 13-5, we then check for the

vm.oom_kill_allocating_task tunable being set, checking firstly that this is a userland thread.

We determine whether it is a userland thread by asserting that the cur-

rent thread’s [struct task_struct-\>mm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) value is non-NULL. This field points at the

[struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) describing the userland process’s virtual address space), so it being NULL indicates that this process is a kernel thread (note that kernel threads may sometimes have this value set to something non-NULL, so this is sufficient, but not necessary).

We then check to see whether the current process is “unkillable” as de-

termined by [oom_unkillable_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n162) (which we examine in Listing **??**), if not and the current process’s oom_score_adj is not set to the minimum value

[OOM_SCORE_ADJ_MIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/oom.h?h=v6.0#n9), then we go ahead and select the current process, setting

[struct oom_control-\>chosen](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n29) to the current process (the current thread’s de-

scribing [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) object being pinned first via [get_task_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/task.h?h=v6.0#n108)).

Ultimately [oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1014) is invoked to perform the killing (we ex-

amine this later in Listing 13-15). Note that this is very different from the

[task_will_free_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n870) case we examined above—this is because a lot more housekeeping needs to be done if the process (and thus related threads) are not currently in the process of exiting.

Finally in this instance we exit indicating the OOM killer has succeeded. After this we have now eliminated all of the edge cases and reach the

core logic—deferring the selection of the bad process to [select_bad_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n364)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n364)

which we examine shortly in Listing 13-10.

If we cannot select a bad process this way, then we are in a state of crisis

and report as such (unless this is a sysrq-f invocation of the OOM killer), panicking the kernel.

Otherwise, if a process was chosen we again rely on [oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1014)

(which we examine in Listing 13-15) to perform the actual killing of the pro-cess.

We return to [task_will_free_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n870) examining it in Listing 13-7.



863 */\**

864 *\* Checks whether the given task is dying or exiting and likely to* 865 *\* release its address space. This means that all threads and processes* 866 *\* sharing the same mm have to be killed or exiting.* 867 *\* Caller has to make sure that task-\>mm is stable (hold task_lock or* 868 *\* it operates on the current).* 869 *\*/*

870 **static bool task_will_free_mem**(**struct** task_struct \*task) 871 {

872 **struct** mm_struct \*mm = task-\>mm; 873 **struct** task_struct \*p; 874 **bool** ret = **true**;

875

876 */\**

877 *\* Skip tasks without mm because it might have passed its exit_mm and*

878 *\* exit_oom_victim. oom_reaper could have rescued that but do not rely*







879 *\* on that for now. We can consider find_lock_task_mm in future.* 880 *\*/*

881 **if** (!mm)

882 **return false**;

883

884 **if** (!**\_\_task_will_free_mem**(task)) 885 **return false**;

886

887 */\**

888 *\* This task has already been drained by the oom reaper so there are*

889 *\* only small chances it will free some more* 890 *\*/*

891 **if** (**test_bit**(**MMF_OOM_SKIP**, &mm-\>flags)) 892 **return false**;

893

894 **if** (**atomic_read**(&mm-\>mm_users) \<= 1) 895 **return true**;

896

897 */\**

898 *\* Make sure that all tasks which share the mm with the given tasks*

899 *\* are dying as well to make sure that a) nobody pins its mm and* 900 *\* b) the task is also reapable by the oom reaper.* 901 *\*/*

902 **rcu_read_lock**();

903 **for_each_process**(p) { 904 **if** (!**process_shares_mm**(p, mm)) 905 **continue**; 906 **if** (**same_thread_group**(task, p)) 907 **continue**; 908 ret = **\_\_task_will_free_mem**(p); 909 **if** (!ret) 910 **break**; 911 }

912 **rcu_read_unlock**();

913

914 **return** ret;

915 }



*Listing 13-7:* mm/oom_kill.c: [*task_will_free_mem()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n870)



**N O T E** Processes in Linux can be confusing—each [*struct task_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) object repre-

sents a task, which is referred to in the kernel as a process but maps to a thread.

[*for_each_process()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n645) iterates over each task, i.e. each thread.



This function is parameterised by [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) for the task we want

to determine whether killing its owning process (or more strictly, thread

group leader) and thus itself alongside it is about to free up memory (and







thus selection of the process as the ostensible victim avoids unnecessarily killing still-running processes).

This wraps the [\_\_task_will_free_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n842) function which determines whether

killing a process will free memory. We examine this later in Listing 13-9.

To start with, we exclude the case where its [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) virtual ad-

dress space descriptor is not present, as we cannot be sure that we’re not past the point where memory would already have been freed.

We then invoke [\_\_task_will_free_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n842) to determine whether the task will

indeed free memory. If not, then we trivially return false.

If so, then we have some edge cases to consider—we examine the

[struct mm_struct-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field to see if the [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70) flag has been set. If it has, this indicates that memory has already been drained by the OOM reaper, so we are not going to see any more memory freed.

Finally if there is nothing pinning the virtual address space i.e.

[struct mm_struct-\>mm_users](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) is not increased (mm_users equal to one indicates that userland alone makes use of the virtual mapping), then we have no rea-

son to contradict the result of [\_\_task_will_free_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n842) and return true.

If the virtual address space is being used by the kernel in some fash-

ion, we need to consider a very specific edge case—consider tasks that were spawned in such a way as to share the virtual memory address space, but not sharing signals with other threads sharing the same address space.

This can be achieved via [clone()](https://man7.org/linux/man-pages/man2/clone.2.html) with [CLONE_VM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/sched.h?h=v6.0#n11) set (indicating that the vir-

tual address space should be shared), but without [CLONE_SIGHAND](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/sched.h?h=v6.0#n14) set, indicat-ing that it does process signals sent to the thread group (meaning that other threads utilising the same virtual address space will die, but it won’t).

Also, a kernel thread can make use of a userland virtual address space

and essentially adapt it to be its own via [kthread_use_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/kthread.c?h=v6.0#n1405), and equally this task will not exit alongside the userland thread group which established the virtual address space in the first instance.

To assess this, we iterate through all tasks via [for_each_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n645)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n645) ignore

ones which do not share the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) checked via [process_shares_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n490)

(see Listing 13-8), or ones which share the same signal handler, which we

know will certainly exit alongside the task being queried (checked via [)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#nsame_thread_group()).

Finally if we find any that do not fit into this category, then we have

found an outlier as described above. We then check this task manually

against [\_\_task_will_free_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n842) (in Listing 13-9). If this fails, then we exit the loop and return false, otherwise if all checks pass, we return true.



484 */\**

485 *\* task-\>mm can be NULL if the task is the exited group leader. So to* 486 *\* determine whether the task is using a particular mm, we examine all the*

487 *\* task's threads: if one of those is using this mm then this task was also*

488 *\* using it.*

489 *\*/*

490 **bool process_shares_mm**(**struct** task_struct \*p, **struct** mm_struct \*mm) 491 {

492 **struct** task_struct \*t; 493







494 **for_each_thread**(p, t) { 495 **struct** mm_struct \*t_mm = **READ_ONCE**(t-\>mm); 496 **if** (t_mm) 497 **return** t_mm == mm; 498 }

499 **return false**;

500 }



*Listing 13-8:* mm/oom_kill.c: [*process_shares_mm()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n490)



The [process_shares_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n490) function iterates through each of the tasks associ-

ated with each thread belonging to the same thread group (i.e. each thread

of the associated userland process), checking to see if any match the queried

[struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) virtual address space object.

This is necessary as each task might be exiting, and thus may not be ref-

erencing a [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486). If one exists then the process shares the virtual

address space, even if it is partially exited.



842 **static inline bool \_\_task_will_free_mem**(**struct** task_struct \*task) 843 {

844 **struct** signal_struct \*sig = task-\>signal;

845

846 */\**

847 *\* A coredumping process may sleep for an extended period in* 848 *\* coredump_task_exit(), so the oom killer cannot assume that* 849 *\* the process will promptly exit and release memory.* 850 *\*/*

851 **if** (sig-\>core_state) 852 **return false**;

853

854 **if** (sig-\>flags & **SIGNAL_GROUP_EXIT**) 855 **return true**;

856

857 **if** (**thread_group_empty**(task) && (task-\>flags & **PF_EXITING**)) 858 **return true**;

859

860 **return false**;

861 }



*Listing 13-9:* mm/oom_kill.c: [*\_\_task_will_free_mem()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n842)



The [\_\_task_will_free_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n842) function starts by handling the edge case sce-

nario of a process which is core dumping—this is a time-consuming process

so even though the process is exiting, we are not going to see memory freed

in time to be useful, so we consider this process to not be freeing memory

for the purposes of the function.

We then consider the two cases which indicate that the process will exit—

the [SIGNAL_GROUP_EXIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n254) flag has been set, indicating that a signal indicating

process exit has been issued, or the [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)-\>flags field has the

[PF_EXITING](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1704) flag set indicating that the task is in process of being shut down







(since there is no signal, we must also check the thread group is empty, i.e.

this is the only task, done via [thread_group_empty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n726)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n726)



***13.4.4 Victim Selection***

We examine the function which selects the process [select_bad_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n364) in

Listing 13-10.



360 */\**

361 *\* Simple selection loop. We choose the process with the highest number of*

362 *\* 'points'. In case scan was aborted, oc-\>chosen is set to -1.* 363 *\*/*

364 **static void select_bad_process**(**struct** oom_control \*oc) 365 {

366 oc-\>chosen_points = **LONG_MIN**;

. . .

371 **struct** task_struct \*p; 372

373 **rcu_read_lock**(); 374 **for_each_process**(p) 375 **if** (**oom_evaluate_task**(p, oc)) 376 **break**; 377 **rcu_read_unlock**();

. . .

379 }



*Listing 13-10:* mm/oom_kill.c: [*select_bad_process()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n364)



The [select_bad_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n364) function accumulates “points” assigned to each

process which map to the amount of resident memory used by each process (expressed as a signed long integer), starting at the minimum value possible.

The points assigned to the process with the maximum number of points

is assigned to [struct oom_control-\>chosen_points](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n29), along with the associated

process in [struct oom_control-\>chosen](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n29).

We simply iterate through each process, evaluating each via

[oom_evaluate_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308) (shown in Listing 13-11) which calculates each pro-

cess’s score, and updates the [struct oom_control-\>chosen_points](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n29) and

[struct oom_control-\>chosen](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n29) fields.

If at any stage the [oom_evaluate_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308) function returns false, this indi-

cates that the [struct oom_control-\>chosen](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n29) has been set to an invalid value in-dicating that the operation failed, and thus the loop should be exited early (note that this nonetheless indicates success, as the abort implies that the OOM killer need not select a new victim).



308 **static int oom_evaluate_task**(**struct** task_struct \*task, **void** \*arg) 309 {

310 **struct** oom_control \*oc = arg; 311 **long** points;

312







313 **if** (**oom_unkillable_task**(task)) 314 **goto** next;

. . .

320 */\**

321 *\* This task already has access to memory reserves and is being killed*

*.*

322 *\* Don't allow any other task to have access to the reserves unless*

323 *\* the task has MMF_OOM_SKIP because chances that it would release*

324 *\* any memory is quite low.* 325 *\*/*

326 **if** (!**is_sysrq_oom**(oc) && **tsk_is_oom_victim**(task)) { 327 **if** (**test_bit**(**MMF_OOM_SKIP**, &task-\>signal-\>oom_mm-\>flags)) 328 **goto** next; 329 **goto** abort; 330 }

331

332 */\**

333 *\* If task is allocating a lot of memory and has been marked to be*

334 *\* killed first if it triggers an oom, then select it.* 335 *\*/*

336 **if** (**oom_task_origin**(task)) { 337 points = **LONG_MAX**; 338 **goto** select; 339 }

340

341 points = **oom_badness**(task, oc-\>totalpages); 342 **if** (points == **LONG_MIN** \|\| points \< oc-\>chosen_points) 343 **goto** next;

344

345 select:

346 **if** (oc-\>chosen)

347 **put_task_struct**(oc-\>chosen); 348 **get_task_struct**(task); 349 oc-\>chosen = task; 350 oc-\>chosen_points = points; 351 next:

352 **return** 0;

353 abort:

354 **if** (oc-\>chosen)

355 **put_task_struct**(oc-\>chosen); 356 oc-\>chosen = (**void** \*)-1**UL**; 357 **return** 1;

358 }



*Listing 13-11:* mm/oom_kill.c: [*oom_evaluate_task()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308)

We start by evaluating whether the task under examination is unkillable,

which we do via [oom_unkillable_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n162) which we examine in Listing **??**.







161 */\* return true if the task is not adequate as candidate victim task. \*/* 162 **static bool oom_unkillable_task**(**struct** task_struct \*p) 163 {

164 **if** (**is_global_init**(p)) 165 **return true**; 166 **if** (p-\>flags & **PF_KTHREAD**) 167 **return true**; 168 **return false**;

169 }



*Listing 13-12:* mm/oom_kill.c: [*oom_unkillable_task()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n162)



In [oom_unkillable_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n162) we assess whether a task simply cannot be killed.

There are two instances—the global init process, as tested by [is_global_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1692) (this is the very first task run in userland) and kernel threads—we test this by

determining if the task has the [PF_KTHREAD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1723) flag set identifying it as such.

If neither of these are the case, then the task is not considered unkill-

able.

Returning to [oom_evaluate_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308) after asserting that the task is in fact

not unkillable, we then check, should this not be a sysrq-f invocation of the OOM killer (as this test is relevant only under severe memory pressure),

whether the task is already marked as an OOM victim via [tsk_is_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n75)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n75)

In this instance, if the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) which is currently being killed by

the OOM killer does not have the [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70) flag set, this indicates that we should abort as a task in the process of being killed and thus any memory re-serves may not be accessible at this time (but will become accessible as soon as the killing is complete).

If [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70) is set, this indicates that the virtual address space de-

scribed by the associated [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) is of no interest to OOM and thus we can proceed with examining the next task.

When a process is known to be about to allocate a great deal of memory,

it makes sense to ensure that, if the OOM killer is invoked, that it is the pro-cess selected as victim.

In these instances, [set_current_oom_origin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n60) is used to mark the current

process as such, later cleared via [clear_current_oom_origin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n65) and tested for in

[oom_evaluate_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308) via [oom_task_origin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n70).

This is set by the ring buffer when allocating memory on behalf of a user-

land thread, by Kernel Shared Memory (KSM) under certain circumstances (out of scope for the book) and by the swap file mechanism when the user

invokes [swapoff](https://man7.org/linux/man-pages/man8/swapoff.8.html) to disable a swap file.

In [oom_evaluate_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308) we check for this condition, and if it is present,

mark this task as if it had the maximum possible points so it almost certainly gets selected.

Finally, once all edge cases have been considered, we take the usual route

applicable to most processes wherein we evaluate the “badness” of the task

via [oom_badness()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n201) which we examine in Listing 13-13.



192 */\*\**







193 *\* oom_badness - heuristic function to determine which candidate task to kill*

194 *\* @p: task struct of which task we should calculate* 195 *\* @totalpages: total present RAM allowed for page allocation* 196 *\**

197 *\* The heuristic for determining which task to kill is made to be as simple*

*and*

198 *\* predictable as possible. The goal is to return the highest value for the*

199 *\* task consuming the most memory to avoid subsequent oom failures.* 200 *\*/*

201 **long oom_badness**(**struct** task_struct \*p, **unsigned long** totalpages) 202 {

203 **long** points;

204 **long** adj;

205

206 **if** (**oom_unkillable_task**(p)) 207 **return LONG_MIN**;

208

209 p = **find_lock_task_mm**(p); 210 **if** (!p)

211 **return LONG_MIN**;

212

213 */\**

214 *\* Do not even consider tasks which are explicitly marked oom* 215 *\* unkillable or have been already oom reaped or the are in* 216 *\* the middle of vfork* 217 *\*/*

218 adj = (**long**)p-\>signal-\>oom_score_adj; 219 **if** (adj == **OOM_SCORE_ADJ_MIN** \|\| 220 **test_bit**(**MMF_OOM_SKIP**, &p-\>mm-\>flags) \|\| 221 **in_vfork**(p)) { 222 **task_unlock**(p); 223 **return LONG_MIN**; 224 }

225

226 */\**

227 *\* The baseline for the badness score is the proportion of RAM that*

*each*

228 *\* task's rss, pagetable and swap space use.* 229 *\*/*

230 points = **get_mm_rss**(p-\>mm) + **get_mm_counter**(p-\>mm, **MM_SWAPENTS**) + 231 **mm_pgtables_bytes**(p-\>mm) / **PAGE_SIZE**; 232 **task_unlock**(p);

233

234 */\* Normalize to oom_score_adj units \*/* 235 adj \*= totalpages / 1000; 236 points += adj;

237







238 **return** points;

239 }



*Listing 13-13:* mm/oom_kill.c: [*oom_badness()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n201)



Here we again assert that the task is not unkillable via

[oom_unkillable_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n162) (see Listing **??**), using LONG_MIN, i.e. the minimum pos-sible signed long integer value to provide effectively the minimum possible score thus to preclude this task from being chosen.

Next, we acquire a lock around the task to prevent it disappearing below

us via [find_lock_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n133)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n133) which we examine in Listing 13-14.



127 */\**

128 *\* The process p may have detached its own -\>mm while exiting or through* 129 *\* kthread_use_mm(), but one or more of its subthreads may still have a valid*

130 *\* pointer. Return p, or any of its subthreads with a valid -\>mm, with* 131 *\* task_lock() held.*

132 *\*/*

133 **struct** task_struct \***find_lock_task_mm**(**struct** task_struct \*p) 134 {

135 **struct** task_struct \*t; 136

137 **rcu_read_lock**();

138

139 **for_each_thread**(p, t) { 140 **task_lock**(t); 141 **if** (**likely**(t-\>mm)) 142 **goto found**; 143 **task_unlock**(t); 144 }

145 t = **NULL**;

146 **found**:

147 **rcu_read_unlock**(); 148

149 **return** t;

150 }



*Listing 13-14:* mm/oom_kill.c: [*find_lock_task_mm()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n133)



In [find_lock_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n133) we iterate through each task representing a thread

within the same process as the task passed in, determining if any maintain a

reference to the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) describing the virtual address space shared between them.

This is done as the process may be in the process of being destroyed but

at least one thread might still maintain a reference to the virtual address space and that suffices for our needs.

Once we have established a lock on the task we can be certain it can’t be

removed, so it is therefore safe to return. Should we not find such a thread, we return NULL.







Returning to [oom_badness()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n201) in Listing 13-13, we note that again should

[find_lock_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n133) return NULL, we set the score to the minimum possible to

indicate that this process should not be selected.

We then consider three final edge cases—if the /proc/\$pid/oom_score_adj

for the process is set to the minimum possible score ([OOM_SCORE_ADJ_MIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/oom.h?h=v6.0#n9)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/oom.h?h=v6.0#n9) or

if the process has had the [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70) flag set (indicating that the process is

unlikely to yield any significant memory if freed), or if we are in the midst of

a [vfork()](https://man7.org/linux/man-pages/man2/vfork.2.html) operation, then we indicate the task should not be selected by re-

turning LONG_MIN (and of course, releasing the lock on the task before doing

so).

The first two of these cases are self-explanatory—both are explicitly in-

tended to indicate that the process is not to be considered for OOM killing,

the third requires a little explanation, however.

A [vfork()](https://man7.org/linux/man-pages/man2/vfork.2.html) operation (which can also be achieved via the [clone()](https://man7.org/linux/man-pages/man2/clone.2.html) system

call specifying [CLONE_VFORK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/sched.h?h=v6.0#n17)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/sched.h?h=v6.0#n17) is similar to an ordinary [fork()](https://man7.org/linux/man-pages/man2/fork.2.html), only no page ta-

bles are copied and the parent process is suspended until the child exits or

calls [execve()](https://man7.org/linux/man-pages/man2/execve.2.html)[.](https://man7.org/linux/man-pages/man2/execve.2.html)

In [oom_badness()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n201) we check to see if the task is a vforked child of a parent

via [in_vfork()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n170)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n170) In which case, it has no memory to free, and we consider its

parent separately.

With all edge cases considered, we calculate the “badness” score for a

process, i.e. an index value proportional to its resident memory process,

taking into account any /proc/\$pid/oom_score_adj modifiers.

We calculate the “badness” score by obtaining the sum of the resident

base pages, swap entries and page tables used by the process, adding the

oom_score_adj modifier, expressed in base pages (the adjustment score is ex-

pressed in thousandths of the total number of base pages available in the

system).

After retrieving the pertinent data from the task, we relinquish its lock

before adding the adjustment value and returning the same.



***13.4.5 Victim Killing***

Returning to [out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107) (as shown in Listing 13-5), we see that, once a

process has been selected for termination, the actual killing of the process

is deferred to [oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1014), which we examine in Listing 13-15 (eliding

out of scope cgroup handling).



1014 **static void oom_kill_process**(**struct** oom_control \*oc, **const char** \*message) 1015 {

1016 **struct** task_struct \*victim = oc-\>chosen;

. . .

1018 **static DEFINE_RATELIMIT_STATE**(oom_rs, **DEFAULT_RATELIMIT_INTERVAL**, 1019 **DEFAULT_RATELIMIT_BURST**); 1020

1021 */\**

1022 *\* If the task is already exiting, don't alarm the sysadmin or kill*

1023 *\* its children or threads, just give it access to memory reserves*







1024 *\* so it can die quickly* 1025 *\*/*

1026 **task_lock**(victim); 1027 **if** (**task_will_free_mem**(victim)) { 1028 **mark_oom_victim**(victim); 1029 **queue_oom_reaper**(victim); 1030 **task_unlock**(victim); 1031 **put_task_struct**(victim); 1032 **return**;

1033 }

1034 **task_unlock**(victim); 1035

1036 **if** (**\_\_ratelimit**(&oom_rs)) 1037 **dump_header**(oc, victim);

. . .

1046 **\_\_oom_kill_process**(victim, message);

. . .

1058 }



*Listing 13-15:* mm/oom_kill.c: [*oom_kill_process()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1014)



We establish a ratelimit variable oom_rs in order to limit the repetition of

OOM killer output. Discussion of the details of this are out of scope for the book.

We acquire a lock on the task, then again evaluate whether the process

is being killed and thus will trivially free memory, via [task_will_free_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n870) as

shown in Listing 13-7.

If so, then the task is marked as OOM victim (which in turn gives

the process access to memory reserves in service of it freeing memory)

via [mark_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757) (see Listing 13-18), and queue it for reaping via

[queue_oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n691) (see Listing 13-21), before unlocking it and reducing its reference count.



**N O T E** In [*oom_evaluate_task()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308) (as shown in Listing 13-11) we increment the chosen task’s

reference count via [*get_task_struct()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/task.h?h=v6.0#n108)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/task.h?h=v6.0#n108) so we can be confident that the task will not have disappeared beneath us at this point.



We then output details about the chosen process (in a rate-limited fash-

ion to avoid spamming the kernel ring buffer) via [dump_header()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n452)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n452) which we

examine in Listing 13-16 (eliding out of scope cgroup logic).



452 **static void dump_header**(**struct** oom_control \*oc, **struct** task_struct \*p) 453 {

454 **pr_warn**("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d,

oom_score_adj=%hd\n",

455 current-\>comm, oc-\>gfp_mask, &oc-\>gfp_mask, oc-\>order, 456 current-\>signal-\>oom_score_adj); 457 **if** (!**IS_ENABLED**(**CONFIG_COMPACTION**) && oc-\>order) 458 **pr_warn**("COMPACTION is disabled!!!\n");







459

460 **dump_stack**();

. . .

464 **show_mem**(**SHOW_MEM_FILTER_NODES**, oc-\>nodemask); 465 **if** (**should_dump_unreclaim_slab**()) 466 **dump_unreclaimable_slab**();

. . .

468 **if** (**sysctl_oom_dump_tasks**) 469 **dump_tasks**(oc); 470 **if** (p)

471 **dump_oom_summary**(oc, p); 472 }



*Listing 13-16:* mm/oom_kill.c: [*dump_header()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n452)



The [dump_header()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n452) function outputs the familiar OOM killer header, in-

dicating the current state of free memory via [show_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/show_mem.c?h=v6.0#n11) alongside slab in-

formation and if the vm.oom_dump_tasks tunable is set, output a list of tasks

alongside their memory usage and /proc/\$pid/oom_score_adj values.

See Section 14.4 in Chapter 14 for an examination of an example output

in detail to see how this looks in practice.

Returning to [oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1014) and Listing 13-15, we see that we defer

the heavy lifting of marking the process to be killed to [\_\_oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n197),

which we examine starting in Listing 13-17 (eliding out of scope cgroup and

event logic).



917 **static void \_\_oom_kill_process**(**struct** task_struct \*victim, **const char** \*message

)

918 {

919 **struct** task_struct \*p; 920 **struct** mm_struct \*mm; 921 **bool** can_oom_reap = **true**;

922

923 p = **find_lock_task_mm**(victim); 924 **if** (!p) {

925 **pr_info**("%s: OOM victim %d (%s) is already exiting. Skip

killing the task\n",

926 message, **task_pid_nr**(victim), victim-\>comm); 927 **put_task_struct**(victim); 928 **return**;

929 } **else if** (victim != p) { 930 **get_task_struct**(p); 931 **put_task_struct**(victim); 932 victim = p; 933 }

934

935 */\* Get a reference to safely compare mm after task_unlock(victim) \*/*

936 mm = victim-\>mm;

937 **mmgrab**(mm);







. . .

943 */\**

944 *\* We should send SIGKILL before granting access to memory reserves*

945 *\* in order to prevent the OOM victim from depleting the memory* 946 *\* reserves from the user space under its control.* 947 *\*/*

948 **do_send_sig_info**(**SIGKILL**, **SEND_SIG_PRIV**, victim, **PIDTYPE_TGID**); 949 **mark_oom_victim**(victim); 950 **pr_err**("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB,

file-rss:%lukB, shmem-rss:%lukB, UID:%u pgtables:%lukB oom_score_adj:%hd\\ n",

951 message, **task_pid_nr**(victim), victim-\>comm, **K**(mm-\>total_vm), 952 **K**(**get_mm_counter**(mm, **MM_ANONPAGES**)), 953 **K**(**get_mm_counter**(mm, **MM_FILEPAGES**)), 954 **K**(**get_mm_counter**(mm, **MM_SHMEMPAGES**)), 955 **from_kuid**(&**init_user_ns**, **task_uid**(victim)), 956 **mm_pgtables_bytes**(mm) \>\> 10, victim-\>signal-\>oom_score_adj); 957 **task_unlock**(victim);



*Listing 13-17:* mm/oom_kill.c: [*\_\_oom_kill_process()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n197) *Header*



In [\_\_oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n197) we start by invoking [find_lock_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n133) (as shown

in Listing 13-14) to find and lock a task that belongs to the same process as

the target victim task and also references a valid [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object de-scribing the process’s virtual address space.

If we are unable to do so, we note that the process is already exiting, re-

duce the reference count an exit, otherwise, if the task we are obtained dif-fers from the target victim one, we increment its reference count and decre-ment the victim’s and swap them.

We then use [mmgrab()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n35) to increment the [struct mm_struct-\>mm_count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) asso-

ciated with the virtual address space, which protects the object from being freed even if the owning task exits.

Prior to marking the process as being a victim, we send a SIGKILL signal

to unconditionally start the exit of the process and to activate all the various checks in the memory management code around a pending fatal signal to prevent depletion of memory reserves which are made available once the victim status is marked.

The process is marked as a victim via [mark_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757) which we examine

in Listing 13-18. After doing so we output information about this, before releasing the lock on the task.

The actual killing of the process is performed by the OOM reaper, which

we discuss in Section 13.4.6 (eliding out of scope task freezing and tracing logic).



747 */\*\**

748 *\* mark_oom_victim - mark the given task as OOM victim* 749 *\* @tsk: task to mark*

750 *\**

751 *\* Has to be called with oom_lock held and never after*







752 *\* oom has been disabled already.* 753 *\**

754 *\* tsk-\>mm has to be non NULL and caller has to guarantee it is stable (either*

755 *\* under task_lock or operate on the current).* 756 *\*/*

757 **static void mark_oom_victim**(**struct** task_struct \*tsk) 758 {

759 **struct** mm_struct \*mm = tsk-\>mm;

760

761 **WARN_ON**(**oom_killer_disabled**);

. . .

766 */\* oom_mm is bound to the signal struct life time. \*/* 767 **if** (!**cmpxchg**(&tsk-\>signal-\>oom_mm, **NULL**, mm)) { 768 **mmgrab**(tsk-\>signal-\>oom_mm); 769 **set_bit**(**MMF_OOM_VICTIM**, &mm-\>flags); 770 }

. . .

779 **atomic_inc**(&**oom_victims**);

. . .

781 }



*Listing 13-18:* mm/oom_kill.c: [*mark_oom_victim()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757)



The [mark_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757) function references the [struct task_struct-\>signal](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)’s

[struct signal_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n93)-\>oom_mm field which is of [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) type and keeps

track of the virtual address space subject to OOM reaping.

We atomically compare and exchange this field against that of the victim

task, and if there is none already in place (which would indicate that the pro-

cess is already subject to OOM killing) then we invoke [mmgrab()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n35) to increment

the virtual address space’s reference count and mark the address space as

being a victim using the [MMF_OOM_VICTIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n74) flag, before incrementing the atomic

count of current OOM victims, [oom_victims](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n477).

With the victim marked, we now proceed with ensuring we cover all tasks

which share the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) but do not exist in the same thread group,

before performing final cleanup tasks in Listing 13-19.



917 */\**

918 *\* Kill all user processes sharing victim-\>mm in other thread groups,*

*if*

919 *\* any. They don't get access to memory reserves, though, to avoid*

920 *\* depletion of all memory. This prevents mm-\>mmap_lock livelock when*

*an*

921 *\* oom killed thread cannot exit because it requires the semaphore and*

922 *\* its contended by another thread trying to allocate memory itself.*

923 *\* That thread will now get access to memory reserves since it has a*

924 *\* pending fatal signal.* 925 *\*/*

926 **rcu_read_lock**();

927 **for_each_process**(p) {







928 **if** (!**process_shares_mm**(p, mm)) 929 **continue**; 930 **if** (**same_thread_group**(p, victim)) 931 **continue**; 932 **if** (**is_global_init**(p)) { 933 can_oom_reap = **false**; 934 **set_bit**(**MMF_OOM_SKIP**, &mm-\>flags); 935 **pr_info**("oom killer %d (%s) has mm pinned by %d (%s)\n

",

936 **task_pid_nr**(victim), victim-\>comm, 937 **task_pid_nr**(p), p-\>comm); 938 **continue**; 939 }

940 */\**

941 *\* No kthread_use_mm() user needs to read from the userspace*

*so*

942 *\* we are ok to reap it.* 943 *\*/*

944 **if** (**unlikely**(p-\>flags & **PF_KTHREAD**)) 945 **continue**; 946 **do_send_sig_info**(**SIGKILL**, **SEND_SIG_PRIV**, p, **PIDTYPE_TGID**); 947 }

948 **rcu_read_unlock**(); 949

950 **if** (can_oom_reap) 951 **queue_oom_reaper**(victim); 952

953 **mmdrop**(mm);

954 **put_task_struct**(victim); 955 }

956 **\#undef K**



*Listing 13-19:* mm/oom_kill.c: [*\_\_oom_kill_process()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n197) *Footer*



In the latter part of [\_\_oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n197) shown in Listing 13-19 we both

handle the edge case of tasks which share the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) but do not

exist in the same thread group, which can occur when [clone()](https://man7.org/linux/man-pages/man2/clone.2.html) is used with

[CLONE_VM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/sched.h?h=v6.0#n11) set but without [CLONE_SIGHAND](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/sched.h?h=v6.0#n14)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/sched.h?h=v6.0#n14) or if kernel threads “adopt” the virtual

address space via [kthread_use_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/kthread.c?h=v6.0#n1405).

We iterate through each process via [for_each_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n645), ignoring ones

which do not share the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486), checked via [process_shares_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n490), or

those which share the same signal handler,checked via [.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#nsame_thread_group())

We then consider the unusual case of the global initialisation process

pinning the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) a process which is unkillable, checked via

[is_global_init()—if ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1692)so we disallow the reaping and mark the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

as one to be skipped in further evaluation via the [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70) flag.







If the task is a kernel thread, we skip forwards, as we are safe to reap the

memory, as any attempt to read memory from a reaped process’s virtual ad-

dress space will be handled appropriately.

Finally, ordinary instances of non-thread group shared [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

are set the SIGKILL signal. This is done to prevent this tasks from causing is-

sues by allocating memory when we are trying to reap the same virtual ad-

dress space.

After considering these edge case tasks, we then proceed with queueing

the process for reaping via [queue_oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n691) which we examine in Listing

13-21.

We then drop the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) and [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) reference

counts we had elevated in order to pin these objects in memory throughout

the operation.



***13.4.6 OOM Reaper***

The actual killing of processes is performed by the OOM “reaper” which

runs in a dedicated kernel thread represented by the [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) in

the static variable [oom_reaper_th](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n507).

The reaper uses the [oom_reaper_wait](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n508) wait queue in order to trigger the

thread to awaken and perform reaping, storing the head of the list of tasks

to reap in [oom_reaper_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n509) (a linked list of tasks to reap is maintained us-

ing the [struct task_struct-\>oom_reaper_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) field to tie the tasks together)

and operating on these fields (and reaping in general) is protected by the

[oom_reaper_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n510) spinlock.



**N O T E** A wait queue is a list of tasks waiting for an event to occur and is a key synchroni-

sation mechanism within the kernel. Waiting tasks suspend their operation until

the specified condition resolves to true. A deeper discussion of this primitive is out of

scope for the book.



The OOM reaper is initialised in [oom_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n732)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n732) which we examine in Listing

13-20.



732 **static int \_\_init oom_init**(**void**) 733 {

734 **oom_reaper_th** = **kthread_run**(**oom_reaper**, **NULL**, "**oom_reaper**"); 735 **\#ifdef CONFIG_SYSCTL**

736 **register_sysctl_init**("vm", **vm_oom_kill_table**); 737 **\#endif**

738 **return** 0;

739 }



*Listing 13-20:* mm/oom_kill.c: [*oom_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n732)



This starts the oom_reaper kernel thread which runs [oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n639) (see List-

ing 13-24) whose [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) is stored in [oom_reaper_th](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n507)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n507) as well as regis-

tering sysctl handlers.







The kernel thread runs the [oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n639) function, which we examine in

Listing 13-24. Before examining this, we examine [queue_oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n691) in List-

ing 13-21, the function which queues a task for reaping.



682 */\**

683 *\* Give the OOM victim time to exit naturally before invoking the oom_reaping.*

684 *\* The timers timeout is arbitrary... the longer it is, the longer the worst*

685 *\* case scenario for the OOM can take. If it is too small, the oom_reaper can*

686 *\* get in the way and release resources needed by the process exit path.* 687 *\* e.g. The futex robust list can sit in Anon\|Private memory that gets reaped*

688 *\* before the exit path is able to wake the futex waiters.* 689 *\*/*

690 **\#define OOM_REAPER_DELAY** (2\*HZ) 691 **static void queue_oom_reaper**(**struct** task_struct \*tsk) 692 {

693 */\* mm is already queued? \*/* 694 **if** (**test_and_set_bit**(**MMF_OOM_REAP_QUEUED**, &tsk-\>signal-\>oom_mm-\>flags)

)

695 **return**;

696

697 **get_task_struct**(tsk); 698 **timer_setup**(&tsk-\>oom_reaper_timer, **wake_oom_reaper**, 0); 699 tsk-\>oom_reaper_timer.expires = **jiffies** + **OOM_REAPER_DELAY**; 700 **add_timer**(&tsk-\>oom_reaper_timer); 701 }



*Listing 13-21:* mm/oom_kill.c: [*queue_oom_reaper()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n691)



Importantly, before being queued for reaping, the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

describing the process’s virtual address space will have been placed into

[struct task_struct-\>signal-\>oom_mm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) by [mark_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757)

The [struct signal_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n93) field [struct task_struct-\>signal](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) represents the

shared signal handler for tasks in a thread group (i.e. threads in a process) and thus represents the thread group or process as a whole, thus this is why

we store the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) to be reaped here.

The [MMF_OOM_REAP_QUEUED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n75) [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) flag marks the process as queued

for OOM reaping, so [queue_oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n691) checks whether this is already set, exiting if so, otherwise setting it.

Note that by the point we are queueing a process for reaping, we will

already have sent a SIGKILL signal to the process in [\_\_oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n197) (as

shown in Listing 13-17). We therefore delay the start of the reaping in hopes that exiting the process this way does the reaping for us.

This therefore renders the reaping a last gasp effort to hollow out unre-

sponsive processes freeing as much memory as possible. The delay before

waking the reaper is specified in [OOM_REAPER_DELAY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n690) and is hardcoded to 2 sec-onds (as the comment indicates this is a heuristically determined value).



**N O T E** The reference count of both the [*struct task_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) and the [*struct mm_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) objects

are carefully maintained—the task’s being incremented by [*oom_evaluate_task()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n308) (List-







ing 13-11) upon selection and [*queue_oom_reaper()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n691) (Listing 13-21) upon queuing

and decremented when each is done with it. The [*struct mm_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)[’s](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) reference count

is incremented in [*\_\_oom_kill_process()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n197) and [*mark_oom_victim()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757) and released when

used.



When the timer expires, the [wake_oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n661) function is invoked to

cause the reaper thread to wake up. We examine this in Listing 13-22 (elid-

ing out of scope tracing hooks).



661 **static void wake_oom_reaper**(**struct** timer_list \*timer) 662 {

663 **struct** task_struct \*tsk = **container_of**(timer, **struct** task_struct, 664 **oom_reaper_timer**); 665 **struct** mm_struct \*mm = tsk-\>signal-\>oom_mm; 666 **unsigned long** flags;

667

668 */\* The victim managed to terminate on its own - see exit_mmap \*/* 669 **if** (**test_bit**(**MMF_OOM_SKIP**, &mm-\>flags)) { 670 **put_task_struct**(tsk); 671 **return**;

672 }

673

674 **spin_lock_irqsave**(&**oom_reaper_lock**, flags); 675 tsk-\>**oom_reaper_list** = **oom_reaper_list**; 676 **oom_reaper_list** = tsk; 677 **spin_unlock_irqrestore**(&**oom_reaper_lock**, flags);

. . .

679 **wake_up**(&**oom_reaper_wait**); 680 }



*Listing 13-22:* mm/oom_kill.c: [*wake_oom_reaper()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n661)



The [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) describing the victim process’s virtual address space

is checked to see if it has the [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70) flag set. If so the reference count

for the task is dropped and we exit.

This flag is set when a process should not be considered for OOM killing

and set when we know for sure this is the case. One important case of set-

ting this flag is in [exit_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3075), invoked when releasing all memory mappings

in the process. We examine the pertinent part in Listing 13-23.



3074 */\* Release all mmaps. \*/*

3075 **void exit_mmap**(**struct** mm_struct \*mm) 3076 {

. . .

3084 **if** (**unlikely**(**mm_is_oom_victim**(mm))) { 3085 */\**

3086 *\* Manually reap the mm to free as much memory as possible.*

3087 *\* Then, as the oom reaper does, set MMF_OOM_SKIP to disregard*







3088 *\* this mm from further consideration. Taking mm-\>mmap_lock*

*for*

3089 *\* write after setting MMF_OOM_SKIP will guarantee that the*

*oom*

3090 *\* reaper will not run on this mm again after mmap_lock is*

3091 *\* dropped.* 3092 *\**

3093 *\* Nothing can be holding mm-\>mmap_lock here and the above*

*call*

3094 *\* to mmu_notifier_release(mm) ensures mmu notifier callbacks*

*in*

3095 *\* \_\_oom_reap_task_mm() will not block.* 3096 *\*/*

3097 (**void**)**\_\_oom_reap_task_mm**(mm); 3098 **set_bit**(**MMF_OOM_SKIP**, &mm-\>flags); 3099 }

. . .

3130 }



*Listing 13-23:* mm/mmap.c: [*exit_mmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3075) *OOM killer logic*



This means that we definitely know that the [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70) flag will be

set for an exiting process, and thus our delay in executing the reaper will have given the process, having received a SIGKILL signal, a chance to exit and thus for us to skip it here. It also performs a manual reaping via

[\_\_oom_reap_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n512) (see Listing 13-27) to ensure we reap as much memory as possible.

Returning to [wake_oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n661) in Listing 13-22, once we have checked

for [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70), we then acquire the [oom_reaper_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n510) before placing this task

at the top of the [oom_reaper_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n509) and waking up the reaper thread using the

[oom_reaper_wait](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n508) wait queue.

This causes [oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n639) to be woken up in the oom reaper kernel thread

(listed as \[oom_reaper\] to userland), which we examine in Listing 13-24.



639 **static int oom_reaper**(**void** \*unused) 640 {

641 **set_freezable**();

642

643 **while** (**true**) {

644 **struct** task_struct \*tsk = **NULL**; 645

646 **wait_event_freezable**(**oom_reaper_wait**, **oom_reaper_list** != **NULL**)

;

647 **spin_lock_irq**(&**oom_reaper_lock**); 648 **if** (**oom_reaper_list** != **NULL**) { 649 tsk = **oom_reaper_list**; 650 **oom_reaper_list** = tsk-\>**oom_reaper_list**; 651 }

652 **spin_unlock_irq**(&**oom_reaper_lock**);







653

654 **if** (tsk)

655 **oom_reap_task**(tsk); 656 }

657

658 **return** 0;

659 }



*Listing 13-24:* mm/oom_kill.c: [*oom_reaper()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n639)



This starts by marking the process as “freezable” via [set_freezable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/freezer.c?h=v6.0#n161) , indi-

cating that it can be frozen during suspend power events. Discussion of this

is out of scope for the book.

Afterwards, we enter an infinite loop, where we wait on the

[oom_reaper_wait](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n508) wait queue, proceeding only if it is both notified and the con-

dition that [oom_reaper_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n509) is not empty is fulfilled.

If so, we acquire the [oom_reaper_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n510) which protects [oom_reaper_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n509)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n509) then

pop the top of the list, checking to ensure that the list is indeed non-empty.

We then defer the actual reaping to [oom_reap_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n608) which we examine in

Listing 13-25. After this is done we loop around and check the list again.



608 **static void oom_reap_task**(**struct** task_struct \*tsk) 609 {

610 **int** attempts = 0; 611 **struct** mm_struct \*mm = tsk-\>signal-\>oom_mm;

612

613 */\* Retry the mmap_read_trylock(mm) a few times \*/* 614 **while** (attempts++ \< **MAX_OOM_REAP_RETRIES** && !**oom_reap_task_mm**(tsk, mm)

)

615 **schedule_timeout_idle**(**HZ**/10);

616

617 **if** (attempts \<= **MAX_OOM_REAP_RETRIES** \|\| 618 **test_bit**(**MMF_OOM_SKIP**, &mm-\>flags)) 619 **goto done**;

620

621 **pr_info**("oom_reaper: unable to reap pid:%d (%s)\n", 622 **task_pid_nr**(tsk), tsk-\>comm); 623 **sched_show_task**(tsk); 624 **debug_show_all_locks**();

625

626 **done**:

627 tsk-\>oom_reaper_list = **NULL**;

628

629 */\**

630 *\* Hide this mm from OOM killer because it has been either reaped or*

631 *\* somebody can't call mmap_write_unlock(mm).* 632 *\*/*

633 **set_bit**(**MMF_OOM_SKIP**, &mm-\>flags);

634







635 */\* Drop a reference taken by queue_oom_reaper \*/* 636 **put_task_struct**(tsk); 637 }



*Listing 13-25:* mm/oom_kill.c: [*oom_reap_task()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n608)



We attempt to reap up to [MAX_OOM_REAP_RETRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n607) times before giving up, in-

voking [oom_reap_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n567) (see Listing 13-26) to do so. Whether we succeed

or not, we set the [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70) flag in the process’s [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

As previously noted, this is applicable to processes which did not exit

within [OOM_REAPER_DELAY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n690) i.e. 2 seconds, so this will typically be those which are in an unresponsive state.

Each time we attempt to reap a process we suspend the process for

1/10th of a second. The reason that the reaper might fail is typically due

to not being able to acquire a read lock on [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) (it at-tempts to acquire this optimistically but does not wait on it), so waiting may allow any active writers to complete their work.

This ensures that reaping doesn’t become stalled (we constrain the

amount time we wait) and we do not contend on this lock, preventing a pro-cess which might be in the process of freeing memory from proceeding.

if we succeed in reaping the process or the process has become marked

with [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70) then we are done. Otherwise we output debug data to the kernel ring buffer.

In either case we clear the next task in the reaper list (i.e.

[struct task_struct-\>oom_reaper_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)), which we will have already put at the

head of [oom_reaper_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n509), and mark the process [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70)

We examine [oom_reap_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n567) in Listing 13-26, eliding tracing hooks.



561 */\**

562 *\* Reaps the address space of the give task.* 563 *\**

564 *\* Returns true on success and false if none or part of the address space*

565 *\* has been reclaimed and the caller should retry later.* 566 *\*/*

567 **static bool oom_reap_task_mm**(**struct** task_struct \*tsk, **struct** mm_struct \*mm) 568 {

569 **bool** ret = **true**;

570

571 **if** (!**mmap_read_trylock**(mm)) {

. . .

573 **return false**; 574 }

575

576 */\**

577 *\* MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't* 578 *\* work on the mm anymore. The check for MMF_OOM_SKIP must run* 579 *\* under mmap_lock for reading because it serializes against the* 580 *\* mmap_write_lock();mmap_write_unlock() cycle in exit_mmap().* 581 *\*/*







582 **if** (**test_bit**(**MMF_OOM_SKIP**, &mm-\>flags)) {

. . .

574 **goto out_unlock**; 575 }

. . .

589 */\* failed to reap part of the address space. Try again later \*/* 590 ret = **\_\_oom_reap_task_mm**(mm); 591 **if** (!ret)

592 **goto out_finish**;

593

594 **pr_info**("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-

rss:%lukB, shmem-rss:%lukB\n",

595 **task_pid_nr**(tsk), tsk-\>comm, 596 **K**(**get_mm_counter**(mm, **MM_ANONPAGES**)), 597 **K**(**get_mm_counter**(mm, **MM_FILEPAGES**)), 598 **K**(**get_mm_counter**(mm, **MM_SHMEMPAGES**))); 599 **out_finish**:

. . .

601 **out_unlock**:

602 **mmap_read_unlock**(mm);

603

604 **return** ret;

605 }



*Listing 13-26:* mm/oom_kill.c: [*oom_reap_task_mm()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n567)



The [oom_reap_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n567) function is a wrapper around [\_\_oom_reap_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n512)

(see Listing 13-27), optimistically attempting to acquire a read lock on the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore via [mmap_read_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n131). If this fails, it

exits indicating failure.

Once we have acquired this lock, we repeat the check for [MMF_OOM_SKIP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n70),

as this may be set by [exit_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3075) when the process is exiting, (as shown in

Listing 13-23).

We repeat this check here after we have acquired the lock, as it will have

acquired a write lock on the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore, meaning

that our read lock guarantees we are serialised against this.

This ensures that we do not waste time trying to reap the process when it

has already been stripped of memory.

If it should not be skipped, then we invoke [\_\_oom_reap_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n512). If this in-

dicates success, we output details of the reaping, in either case we relinquish

the read lock on [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>mmap_lock.

We examine [\_\_oom_reap_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n512) in Listing 13-27, eliding out of scope

MMU notifier logic.



512 **bool \_\_oom_reap_task_mm**(**struct** mm_struct \*mm) 513 {

514 **struct** vm_area_struct \*vma; 515 **bool** ret = **true**;

516







517 */\**

518 *\* Tell all users of get_user/copy_from_user etc... that the content*

519 *\* is no longer stable. No barriers really needed because unmapping*

520 *\* should imply barriers already and the reader would hit a page fault*

521 *\* if it stumbled over a reaped memory.* 522 *\*/*

523 **set_bit**(**MMF_UNSTABLE**, &mm-\>flags); 524

525 **for** (vma = mm-\>mmap ; vma; vma = vma-\>vm_next) { 526 **if** (vma-\>vm_flags & (**VM_HUGETLB**\|**VM_PFNMAP**)) 527 **continue**; 528

529 */\**

530 *\* Only anonymous pages have a good chance to be dropped* 531 *\* without additional steps which we cannot afford as we* 532 *\* are OOM already.* 533 *\**

534 *\* We do not even care about fs backed pages because all* 535 *\* which are reclaimable have already been reclaimed and* 536 *\* we do not want to block exit_mmap by keeping mm ref* 537 *\* count elevated without a good reason.* 538 *\*/*

539 **if** (**vma_is_anonymous**(vma) \|\| !(vma-\>vm_flags & **VM_SHARED**)) {

. . .

541 **struct** mmu_gather tlb;

. . .

546 **tlb_gather_mmu**(&tlb, mm);

. . .

552 **unmap_page_range**(&tlb, vma, range.start, range.end,

**NULL**);

. . .

554 **tlb_finish_mmu**(&tlb); 555 }

556 }

557

558 **return** ret;

559 }



*Listing 13-27:* mm/oom_kill.c: [*\_\_oom_reap_task_mm()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n512)



The function starts by setting the [MMF_UNSTABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n71) flag in the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

describing the virtual address space of the process.

This flag is checked only by the helper function

[check_stable_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n102) which indicates that the SIGBUS signal should be

sent to the process, indicated by the fault code [VM_FAULT_SIGBUS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n743) (see Chapter 6 for more details on the page fault mechanism).

This is used in [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031) and [finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345) during the faulting

process, which will then indicate the SIGBUS rather than resolve the fault.







With this flag set, we iterate through each of the process address space’s

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) objects (see Section 4.4 for details on VMAs),

skipping those which describe hugetlb huge page mappings (as indicated

by the VMA flag [VM_HUGETLB](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n294)) or those which map memory untracked by the

kernel (e.g. directly exposing hardware memory mapping or kernel-mapped

memory), as indicated by [VM_PFNMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n279)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n279) We skip these as we are in no position

to free hugetlb memory in the first instance, and cannot free the memory in

the latter instance.

After this we check to see whether the memory is either mapped anony-

mous, checked by [vma_is_anonymous()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n629) or does not describe shared memory

(e.g. a MAP_PRIVATE mapping) as indicated by the [VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269) flag.

As the comment indicates, we consider only these cases as these are the

only ones we can be confident in freeing immediately. File-backed memory

always has an additional reference from the page cache and thus must be

processed through reclaim in order to ensure that any dirty data is written

back to disk so this is not as conducive to freeing memory quickly.

For each VMA we choose to free, we establish an [struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267) object

in order to aggregate the ranges of memory which we intend to free for the

purposes of invalidating the Translation Lookaside Buffer (TLB) which is a

cache mapping virtual address to physical ones.

See Section 7.1 for a detailed explanation of the process of invalidating

the TLB, unmapping and freeing memory.

We set up the [struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267) using [tlb_gather_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n297) (see Listing

7-54), unmap the page range, updating the TLB state in this object via

[unmap_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1631) (see Listing 7-60), before finalising the operation in

[tlb_finish_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n325) (see Listing 7-79).

When complete, we will have stripped all the low-hanging fruit and the

process will now be considered reaped. As a SIGKILL will have been issued by

this point this is the state it will remain in should it be entirely unresponsive,

otherwise it will eventually be killed.



