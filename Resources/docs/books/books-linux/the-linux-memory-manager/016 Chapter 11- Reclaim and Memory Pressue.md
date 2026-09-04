*.*

1312 *\*/*

1313 shift = dirty_ratelimit / (2 \* step + 1); 1314 **if** (shift \< **BITS_PER_LONG**) 1315 step = **DIV_ROUND_UP**(step \>\> shift, 8); 1316 **else**

1317 step = 0; 1318

1319 **if** (dirty_ratelimit \< balanced_dirty_ratelimit) 1320 dirty_ratelimit += step; 1321 **else**

1322 dirty_ratelimit -= step;

 

*Listing 10-93:* mm/page-writeback.c: [*wb_update_dirty_ratelimit()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1172) *refinement*

 

As usual we do not delve too deeply into the mathematics for brevity, but

we can see the steps taken here to smoothly adjust the dirty_ratelimit value.

Finally, we examine how these rate limit values are outputted in Listing

10-94.

 

1246 **WRITE_ONCE**(wb-\>dirty_ratelimit, **max**(dirty_ratelimit, 1UL)); 1247 wb-\>balanced_dirty_ratelimit = balanced_dirty_ratelimit;

. . .

1328 }

 

*Listing 10-94:* mm/page-writeback.c: [*wb_update_dirty_ratelimit()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1172) *suffix*

 

Here we store the raw balanced dirty rate balanced_dirty_ratelimit in

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>balanced_dirty_ratelimit and the smoothed dirty rate

dirty_ratelimit in [struct bdi_writeback-\>dirty_ratelimit](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**10.22 Maximum and Minimum Pause Time**

 

In order to prevent threads from entirely freezing and to avoid sleeps so long writeback falls off altogether, we specify a maximum task pause period,

calculated in [wb_max_pause()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1415)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1415) which we explore in Listing **??**.

 

1415 **static unsigned long wb_max_pause**(**struct** bdi_writeback \*wb, 1416 **unsigned long** wb_dirty) 1417 {

1418 **unsigned long** bw = **READ_ONCE**(wb-\>avg_write_bandwidth); 1419 **unsigned long** t;

1420

1421 */\**

1422 *\* Limit pause time for small memory systems. If sleeping for too long*

1423 *\* time, a small pool of dirty/writeback pages may go empty and disk*

*go*

1424 *\* idle.*

1425 *\**

1426 *\* 8 serves as the safety ratio.* 1427 *\*/*

1428 t = wb_dirty / (1 + bw / **roundup_pow_of_two**(1 + HZ / 8)); 1429 t++;

1430

1431 **return min_t**(**unsigned long**, t, **MAX_PAUSE**); 1432 }

 

*Listing 10-95:* mm/page-writeback.c: [*wb_max_pause()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1415)

 

This is always capped by [MAX_PAUSE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n47), which is hardcoded to 200ms, so we

are guaranteed that the pause time will never exceed this amount of time.

The function is passed the wb_dirty parameter which is derived from

[struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123)-\>wb_dirty and equal to the number of dirty and

writeback pages associated with the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object.

The bw variable is set to the [struct bdi_writeback-\>avg_write_bandwidth](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

value, determined in [wb_update_write_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1068) (see Listing 10-85).

Note that the offset-by-1 values are in place to avoid divide-by-zero here.

Ignoring these we see that this value ultimately amounts to a time period of

125ms, scaled by *wb*\_*dirty* , i.e. the fraction of dirty memory memory scaled

*bw*

by write bandwidth for this [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

This handles machines with very small memory which might otherwise

pause so long that block devices go idle.

Again the use of the HZ constant is to convert this value into units of

kernel-internal jiffies.

This calculation is simple relative to that for the minimum pause, which

is determined by [wb_min_pause()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1434)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1434) which we examine in Listing 10-96 (eliding some of the longer comments which, while useful, take up rather a lot of space).

 

1434 **static long wb_min_pause**(**struct** bdi_writeback \*wb,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1435 **long** max_pause, 1436 **unsigned long** task_ratelimit, 1437 **unsigned long** dirty_ratelimit, 1438 **int** \*nr_dirtied_pause) 1439 {

1440 **long** hi = **ilog2**(**READ_ONCE**(wb-\>avg_write_bandwidth)); 1441 **long** lo = **ilog2**(**READ_ONCE**(wb-\>dirty_ratelimit)); 1442 **long** t; */\* target pause \*/* 1443 **long** pause; */\* estimated next pause \*/* 1444 **int** pages; */\* target nr_dirtied_pause \*/* 1445

1446 */\* target for 10ms pause on 1-dd case \*/* 1447 t = **max**(1, **HZ** / 100);

. . .

1455 **if** (hi \> lo)

1456 t += (hi - lo) \* (10 \* **HZ**) / 1024;

. . .

1476 t = **min**(t, 1 + max_pause / 2); 1477 pages = dirty_ratelimit \* t / **roundup_pow_of_two**(**HZ**);

. . .

1487 **if** (pages \< **DIRTY_POLL_THRESH**) { 1488 t = max_pause; 1489 pages = dirty_ratelimit \* t / **roundup_pow_of_two**(**HZ**); 1490 **if** (pages \> **DIRTY_POLL_THRESH**) { 1491 pages = **DIRTY_POLL_THRESH**; 1492 t = **HZ** \* **DIRTY_POLL_THRESH** / dirty_ratelimit; 1493 }

1494 }

1495

1496 pause = **HZ** \* pages / (task_ratelimit + 1); 1497 **if** (pause \> max_pause) { 1498 t = max_pause; 1499 pages = task_ratelimit \* t / **roundup_pow_of_two**(**HZ**); 1500 }

1501

1502 \*nr_dirtied_pause = pages; 1503 */\**

1504 *\* The minimal pause time will normally be half the target pause time.*

1505 *\*/*

1506 **return** pages \>= **DIRTY_POLL_THRESH** ? 1 + t / 2 : t; 1507 }

 

*Listing 10-96:* mm/page-writeback.c: [*wb_min_pause()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1434)

 

We establish a baseline of 10ms, which we initially scale up using loga-

rithms such that this time is multiplied by *M* *M* for 2 concurrent threads, en-

suring that each thread receives sufficient time to dirty pages, while scaling

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

in such a way that we don’t slow things down. We clamp this to a maximum of half the previously determined maximum pause time.

Next we determine how many pages would have been dirtied had the

thread not been paused using the pased in per-thread dirty rate limit dirty_ratelimit (again utilising the HZ constant to convert between jiffies and seconds in the rate value) and place this value in pages.

We maintain a minimum dirty threshold of [DIRTY_POLL_THRESH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n53) pages,

which is hard-coded to 128 KiB, i.e. 32 pages for systems with 4 KiB page size.

This is to prevent threads which are writing back very slowly from trig-

gering the dirty throttling logic too often. If this threshold is not breached, then we revert to the maximum pause time to cause the thread to dirty more pages before triggering throttling again.

We output the number of pages form the function which is then

placed into [struct task_struct-\>nr_dirtied_pause](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727), which is used by

[balance_dirty_pages_ratelimited()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949) (see Listing 10-79) to rate limit invocations

of [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) which we explore in Listing 10-97 below.

Finally this function will typically only return with half of the target

pause time if we’ve exceeded [DIRTY_POLL_THRESH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n53) pages worth of pause time.

This allows processes to operate for a period of time without triggering

dirty throttling (as they will be rate limited) and reduces latency.

 

**10.23 Core Dirty Throttling**

The machinery discussed so far has all been in service of, and largely invoked by, the core dirty throttle mechanism implemented in

[balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) which we start examining in Listing 10-97 (eliding out of scope cgroup, tracing, strict BDI limit, flag handling logic and

[PF_LOCAL_THROTTLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1721) logic).

This function is invoked by [balance_dirty_pages_ratelimited()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949) after pages

have been dirtied (which we examined above in Listing 10-79) and is passed

the relevant [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object, the number of pages just dirtied

(equal to the current thread’s [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)-\>nr_dirtied) and flags (these flags are only used by an out of scope caller so we can ignore them).

 

1550 */\**

1551 *\* balance_dirty_pages() must be called by processes which are generating*

*dirty*

1552 *\* data. It looks at the number of dirty pages in the machine and will force*

1553 *\* the caller to wait once crossing the (background_thresh + dirty_thresh) /*

*2.*

1554 *\* If we're over \`background_thresh' then the writeback threads are woken to*

1555 *\* perform some writeout.* 1556 *\*/*

1557 **static int balance_dirty_pages**(**struct** bdi_writeback \*wb, 1558 **unsigned long** pages_dirtied, **unsigned int** flags

)

1559 {

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1560 **struct** dirty_throttle_control gdtc_stor = { **GDTC_INIT**(wb) };

. . .

1562 **struct** dirty_throttle_control \* **const** gdtc = &gdtc_stor;

. . .

1565 **struct** dirty_throttle_control \*sdtc; 1566 **unsigned long** nr_reclaimable; */\* = file_dirty \*/* 1567 **long** period;

1568 **long** pause;

1569 **long** max_pause;

1570 **long** min_pause;

1571 **int** nr_dirtied_pause; 1572 **bool** dirty_exceeded = **false**; 1573 **unsigned long** task_ratelimit; 1574 **unsigned long** dirty_ratelimit; 1575 **struct** backing_dev_info \*bdi = wb-\>bdi;

. . .

1577 **unsigned long** start_time = **jiffies**; 1578 **int** ret = 0;

 

*Listing 10-97:* mm/page-writeback.c: [*balance_dirty_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) *Prelude*

 

We start by establishing a [struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) objet which we

use to thread state through the process of dirty throttling, which is initialised

by [GDTC_INIT()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n152)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n152)

Note that we also keep a track of the start of the process in the start_time

parameter.

After this, we start an infinite loop, one which is typically exited without

repeating. We explore the beginning of this loop in Listing 10-98.

 

1580 **for** (;;) {

1581 **unsigned long** now = **jiffies**; 1582 **unsigned long** dirty, thresh, bg_thresh;

. . .

1587 nr_reclaimable = **global_node_page_state**(**NR_FILE_DIRTY**); 1588 gdtc-\>avail = **global_dirtyable_memory**(); 1589 gdtc-\>dirty = nr_reclaimable + **global_node_page_state**(

**NR_WRITEBACK**);

1590

1591 **domain_dirty_limits**(gdtc);

. . .

1600 dirty = gdtc-\>dirty; 1601 thresh = gdtc-\>thresh; 1602 bg_thresh = gdtc-\>bg_thresh;

. . .

1631 */\**

1632 *\* In laptop mode, we wait until hitting the higher threshold*

1633 *\* before starting background writeout, and then write out all*

1634 *\* the way down to the lower threshold. So slow writers cause*

1635 *\* minimal disk activity.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1636 *\**

1637 *\* In normal mode, we start background writeout at the lower*

1638 *\* background_thresh, to keep the amount of dirty memory low.*

1639 *\*/*

1640 **if** (!laptop_mode && nr_reclaimable \> gdtc-\>bg_thresh && 1641 !**writeback_in_progress**(wb)) 1642 **wb_start_background_writeback**(wb);

 

*Listing 10-98:* mm/page-writeback.c: [*balance_dirty_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) *Initial Checks*

 

We set the [struct dirty_throttle_control-\>avail](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) field to the total global

dirtyable memory pages value obtained by [global_dirtyable_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n344) as

shown in Listing 10-78, and the total number of dirty and writeback pages in the dirty field.

We then establish the global dirty and background threshold via

[domain_dirty_limits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n374) as described in Listing 10-88.

We set dirty, thresh and bg_thresh parameters to the

[struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) fields of the same name just established.

After this we, if not in laptop mode, dirty pages exceed the now estab-

lished background threshold variable and writeback is not in progress, we

start background writeback via [wb_start_background_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1219) as discussed in

Section 10.11.

Note that we do not examine laptop mode closely, however as can be ob-

served here this optionally delays background writeback for laptops in order to preserve battery life, and can be enabled via the vm.laptop_mode tunable.

Next, we gather the statistics previously discussed in order to be able to

perform dirty throttling, which we examine in Listing 10-99.

 

1644 */\**

1645 *\* Throttle it only when the background writeback cannot* 1646 *\* catch-up. This avoids (excessively) small writeouts* 1647 *\* when the wb limits are ramping up in case of !strictlimit.*

. . .

1655 *\*/*

1656 **if** (dirty \<= **dirty_freerun_ceiling**(thresh, bg_thresh) &&

. . .

1659 **unsigned long** intv;

. . .

1662 **free_running**:

1663 intv = **dirty_poll_interval**(dirty, thresh);

. . .

1666 **current**-\>dirty_paused_when = now; 1667 **current**-\>nr_dirtied = 0;

. . .

1670 **current**-\>nr_dirtied_pause = **min**(intv, m_intv); 1671 **break**; 1672 }

1673

1674 */\* Start writeback even when in laptop mode \*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1675 **if** (**unlikely**(!**writeback_in_progress**(wb))) 1676 **wb_start_background_writeback**(wb);

. . .

1680 */\**

1681 *\* Calculate global domain's pos_ratio and select the* 1682 *\* global dtc by default.* 1683 *\*/*

. . .

1685 **wb_dirty_limits**(gdtc);

. . .

1698 dirty_exceeded = (gdtc-\>wb_dirty \> gdtc-\>wb_thresh) && 1699 ((gdtc-\>dirty \> gdtc-\>thresh) \|\| strictlimit); 1700

1701 **wb_position_ratio**(gdtc); 1702 sdtc = gdtc;

. . .

1733 **if** (dirty_exceeded != wb-\>dirty_exceeded) 1734 wb-\>dirty_exceeded = dirty_exceeded; 1735

1736 **if** (**time_is_before_jiffies**(**READ_ONCE**(wb-\>bw_time_stamp) + 1737 **BANDWIDTH_INTERVAL**)) 1738 **\_\_wb_update_bandwidth**(gdtc, mdtc, **true**);

 

*Listing 10-99:* mm/page-writeback.c: [*balance_dirty_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) *Gather Statistics*

 

We start by determining whether the global number of dirty pages is

within the freerun regime (see figure 10-13). In this case we do not pause

the thread at all. This is regime in which systems typically operate most of

the time.

In this instance we determine the poll interval to rate limit threads

to via [dirty_poll_interval()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1406) (see Listing **??**). This is then assigned to

[struct task_struct-\>nr_dirtied_pause](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) to achieve this rate limiting.

We then reset the [struct task_struct-\>dirty_paused_when](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) and

[struct task_struct-\>nr_dirtied](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) fields, to indicate that we considered paus-

ing the thread now and are resetting the number of dirtied pages since last

pause.

After this the freerunning case exits the loop and returns. If we are not in the freerunning regime, then we are in the global dirty

control scope and must apply some throttling. We therefore proceed on this

basis.

We start by determining [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-specific dirty limits via

[wb_dirty_limits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1509) which we previously explored in Listing 10-89.

After this we determine whether we have exceeded the dirty threshold

for both the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) and globally and place this in dirty_exceeded,

which we also set in [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>dirty_exceeded for purposes of rate-

limiting.

We calculate the position ratio for the global

[struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) object via [wb_position_ratio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n889) (see Listing

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

10-86), and take a copy of the pointer to the global dirty throttle control object in sdtc.

Finally, if bandwidth updating is not idle (i.e. the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) is

still experiencing sufficiently regular writeback), as determined by checking whether the current time is less than the next point at which the bandwidth

update work queue is scheduled to run, [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>bw_time_stamp +

[BANDWIDTH_INTERVAL .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n58)

In this instance then [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) is invoked (see Listing 10-82

with update_ratelimit set, causing [wb_update_dirty_ratelimit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1172) to be invoked

(see Listing 10-92) updating the write bandwidth and dirty rate limit statis-tics.

Next we perform the actual pausing of the calling thread, explored in

Listing 10-100.

 

1740 */\* throttle according to the chosen dtc \*/* 1741 dirty_ratelimit = **READ_ONCE**(wb-\>dirty_ratelimit); 1742 task_ratelimit = ((**u64**)dirty_ratelimit \* sdtc-\>pos_ratio) \>\> 1743 **RATELIMIT_CALC_SHIFT**;

1744 max_pause = **wb_max_pause**(wb, sdtc-\>wb_dirty); 1745 min_pause = **wb_min_pause**(wb, max_pause, 1746 task_ratelimit, dirty_ratelimit,

1747 &nr_dirtied_pause); 1748

1749 **if** (**unlikely**(task_ratelimit == 0)) { 1750 period = max_pause; 1751 pause = max_pause; 1752 **goto** pause; 1753 }

1754 period = **HZ** \* pages_dirtied / task_ratelimit; 1755 pause = period; 1756 **if** (**current**-\>dirty_paused_when) 1757 pause -= now -**current**-\>dirty_paused_when; 1758 */\**

1759 *\* For less than 1s think time (ext3/4 may block the dirtier*

1760 *\* for up to 800ms from time to time on 1-HDD; so does xfs,*

1761 *\* however at much less frequency), try to compensate it in*

1762 *\* future periods by updating the virtual time; otherwise just*

1763 *\* do a reset, as it may be a light dirtier.* 1764 *\*/*

1765 **if** (pause \< min_pause) {

. . .

1778 **if** (pause \< -**HZ**) { 1779 **current**-\>dirty_paused_when = now; 1780 **current**-\>nr_dirtied = 0; 1781 } **else if** (period) { 1782 **current**-\>dirty_paused_when += period; 1783 **current**-\>nr_dirtied = 0; 1784 } **else if** (**current**-\>nr_dirtied_pause \<= pages_dirtied)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1785 **current**-\>nr_dirtied_pause += pages_dirtied; 1786 **break**; 1787 }

1788 **if** (**unlikely**(pause \> max_pause)) { 1789 */\* for occasional dropped task_ratelimit \*/* 1790 now += **min**(pause - max_pause, max_pause); 1791 pause = max_pause; 1792 }

1793

1794 pause:

. . .

1811 **\_\_set_current_state**(**TASK_KILLABLE**); 1812 wb-\>dirty_sleep = now; 1813 **io_schedule_timeout**(pause);

 

*Listing 10-100:* mm/page-writeback.c: [*balance_dirty_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) *Thread Pausing*

 

We establish the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) dirty rate limit and place it in

dirty_ratelimit, and scale it against the previously determined position ra-

tio and place this value in task_ratelimit.

We then use these values to determine the maximum and minimum

permitted thread pause times using [wb_max_pause()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1415) (see Listing **??**) and

[wb_min_pause()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1434) (see Listing 10-96).

If we find ourselves in the unlikely scenario where the rate limit is zero,

we immediately set the maximum pause and jump immediately into applying

it. This is the one scenario in which we actually continue in the loop and

pause again right away if necessary if a thread is so out of control as to be

dirtying at a rate which requires it.

Otherwise, we set *pages*\_*dirtied* period to . The pages_dirtied parameter is

*task*\_*ratelimit*

set to the current thread’s [struct task_struct-\>nr_dirtied](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) field, i.e. the num-

ber of pages dirtied since it was last paused. We multiply this result by HZ in

order to convert from seconds to jiffies.

This value therefore continues (in jiffies) the amount of time it would

have taken to dirty these pages at the rate limit.

We then obtain the time to pause by subtracting the current thread’s

[struct task_struct-\>dirty_paused_when](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) timestamp as, if we have dirtied faster

than the limit would allow, this number will be positive, otherwise it will be

negative.

We then examine the case of the pause being less than the minimum—if

we are writing slower than a second’s worth of dirtying, we simply reset this

value and the [struct task_struct-\>dirty_paused_when](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) timestamp to now as the

thread is so slow as to warrant being treated as if it were in a freerun state.

Next if the period is non-zero, indicating that the number of dirtied

pages is relatively significant in comparison to the dirty limit, we sum it to

the [struct task_struct-\>dirty_paused_when](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) field and reset the number of dirt-

ied pages, essentially ‘skipping’ these pages.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Finally if the number of dirtied pages is very small, but is higher than the

last determined minimum pause period, we increase this to allow for greater rate limiting.

All of the above (as with much of the kernel) are careful heuristic steps

taken to tune the design of the algorithm to suit real workloads. And each cause the loop to exit when done. Note that the current thread’s

[struct task_struct-\>nr_dirtied_pause](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) field is not updated except in the last case, even though we have obtained a local copy of what this value should be set to.

Next we consider the case of the determined pause period exceeding

the maximum pause value. In that case we offset the now variable by the dif-ference in pause time (up to a maximum of the maximum specified pause

time) which will be assigned to the [struct bdi_writeback-\>dirty_sleep](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) times-tamp on sleep. This is a heuristic step for internal purposes and will have

an impact for callers of [wb_recent_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-wbt.c?h=v6.0#n102)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-wbt.c?h=v6.0#n102) however this is out of scope for the book.

Finally we actually perform the pausing of the process, marking it as kil-

lable so the sleep can handle a SIGKILL signal correctly. and executing the

sleep via [io_schedule_timeout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/core.c?h=v6.0#n8696)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/core.c?h=v6.0#n8696)

After this we perform some house keeping and determine whether to

persist in the loop, as explored in Listing 10-101.

 

1740 **current**-\>dirty_paused_when = now + pause; 1741 **current**-\>nr_dirtied = 0; 1742 **current**-\>nr_dirtied_pause = nr_dirtied_pause; 1743

1744 */\**

1745 *\* This is typically equal to (dirty \< thresh) and can also*

1746 *\* keep "1000+ dd on a slow USB stick" under control.* 1747 *\*/*

1748 **if** (task_ratelimit) 1749 **break**; 1750

1751 */\**

1752 *\* In the case of an unresponsive NFS server and the NFS dirty*

1753 *\* pages exceeds dirty_thresh, give the other good wb's a pipe*

1754 *\* to go through, so that tasks on them still remain*

*responsive.*

1755 *\**

1756 *\* In theory 1 page is enough to keep the consumer-producer*

1757 *\* pipe going: the flusher cleans 1 page =\> the task dirties 1*

1758 *\* more page. However wb_dirty has accounting errors. So use*

1759 *\* the larger and more IO friendly wb_stat_error.* 1760 *\*/*

1761 **if** (sdtc-\>wb_dirty \<= **wb_stat_error**()) 1762 **break**; 1763

1764 **if** (**fatal_signal_pending**(**current**))

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1765 **break**; 1766 }

1767 **return** ret;

1768 }

 

*Listing 10-101:* mm/page-writeback.c: [*balance_dirty_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) *Suffix*

Finally we reset the current thread’s [struct task_struct-\>dirty_paused_when](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)

and nr_dirtied fields as a pause just occurred, and set the nr_dirtied_pause

field. To the value determined by [wb_min_pause()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1434) (see Listing 10-96).

Next we examine whether the task_ratelimit value is non-zero—if so, as

will almost certainly be the case, we exit the loop and the operation is com-

plete.

If it is indeed zero, then we have a thread that is dirtying at a very high

rate compared to the setpoint and which has thereby obtained a position

ratio value of zero (as determined by [wb_position_ratio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n889) (see Listing 10-86).

We first check to see if the [struct dirty_throttle_control-\>wb_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) field

indicates a very low number of dirtied pages, in which case we exit the loop

early. Equally we exit should a fatal signal be pending (rendering the con-

taining process subject to being torn down). In either case we exit.

Otherwise, in cases of extreme dirtying we repeat the procedure until we

are able to bring the thread into line.

 

**10.24 Writeback Chunk Size**

 

When writing back, we determine the ‘chunk size’ i.e the number of pages

to write back in one batched operation in [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) (see Listing

10-62) via [writeback_chunk_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1732)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1732) which we explore in Listing 10-102.

 

1732 **static long writeback_chunk_size**(**struct** bdi_writeback \*wb, 1733 **struct** wb_writeback_work \*work) 1734 {

1735 **long** pages;

1736

1737 */\**

1738 *\* WB_SYNC_ALL mode does livelock avoidance by syncing dirty* 1739 *\* inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX* 1740 *\* here avoids calling into writeback_inodes_wb() more than once.* 1741 *\**

1742 *\* The intended call sequence for WB_SYNC_ALL writeback is:* 1743 *\**

1744 *\** *wb_writeback()* 1745 *\** *writeback_sb_inodes()* *\<== called only once* 1746 *\** *write_cache_pages()* *\<== called once for each inode* 1747 *\** *(quickly) tag currently dirty pages* 1748 *\** *(maybe slowly) sync all tagged pages* 1749 *\*/*

1750 **if** (work-\>sync_mode == **WB_SYNC_ALL** \|\| work-\>tagged_writepages) 1751 pages = **LONG_MAX**;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1752 **else** {

1753 pages = **min**(wb-\>avg_write_bandwidth / 2, 1754 **global_wb_domain**.dirty_limit / **DIRTY_SCOPE**); 1755 pages = **min**(pages, work-\>nr_pages); 1756 pages = **round_down**(pages + **MIN_WRITEBACK_PAGES**, 1757 **MIN_WRITEBACK_PAGES**); 1758 }

1759

1760 **return** pages;

1761 }

 

*Listing 10-102:* fs/fs-writeback.c: [*writeback_chunk_size()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1732)

If the user specified that the writeback should be synchronised, then

we apply no limit and writeback as much as we can. This is done, in part, to avoid live locks as the comment describes.

Otherwise we limit any one operation to half of the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[’s](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

average write bandwidth (i.e. that requiring 1/2 a second of writeback to

occur), or if smaller, the dirty threshold scaled by [DIRTY_SCOPE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n32), i.e. limiting to 1/8 of the available dirtyable pages.

This is further limited to the [struct wb_writeback_work-\>nr_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) count of

pages to write, before being rounded down to the [MIN_WRITEBACK_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n37) limit, which is set to 4 MiB worth of data (1,024 pages for systems with a 4 KiB page size).

All of this is designed to heuristically avoid issues with locking and to

improve performance.

 

**10.25 Background Writeback Threshold**

 

When checking to determine whether the current [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object

has exceeded the background dirty threshold, we use [wb_over_bg_thresh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1964)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1964) as

invoked by [wb_check_background_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2095) and [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2095).

We examine this in Listing 10-103, eliding out of scope cgroup handling.

 

1955 */\*\**

1956 *\* wb_over_bg_thresh - does @wb need to be written back?* 1957 *\* @wb: bdi_writeback of interest* 1958 *\**

1959 *\* Determines whether background writeback should keep writing @wb or it's*

1960 *\* clean enough.*

1961 *\**

1962 *\* Return: %true if writeback should continue.* 1963 *\*/*

1964 **bool wb_over_bg_thresh**(**struct** bdi_writeback \*wb) 1965 {

1966 **struct** dirty_throttle_control gdtc_stor = { **GDTC_INIT**(wb) };

. . .

1968 **struct** dirty_throttle_control \* **const** gdtc = &gdtc_stor;

. . .

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1971 **unsigned long** reclaimable; 1972 **unsigned long** thresh; 1973

1974 */\**

1975 *\* Similar to balance_dirty_pages() but ignores pages being written*

1976 *\* as we're trying to decide whether to put more under writeback.* 1977 *\*/*

1978 gdtc-\>avail = **global_dirtyable_memory**(); 1979 gdtc-\>dirty = **global_node_page_state**(**NR_FILE_DIRTY**); 1980 **domain_dirty_limits**(gdtc); 1981

1982 **if** (gdtc-\>dirty \> gdtc-\>bg_thresh) 1983 **return true**; 1984

1985 thresh = **wb_calc_thresh**(gdtc-\>wb, gdtc-\>bg_thresh); 1986 **if** (thresh \< 2 \* **wb_stat_error**()) 1987 reclaimable = **wb_stat_sum**(wb, **WB_RECLAIMABLE**); 1988 **else**

1989 reclaimable = **wb_stat**(wb, **WB_RECLAIMABLE**); 1990

1991 **if** (reclaimable \> thresh) 1992 **return true**;

. . .

2015 **return false**;

2016 }

 

*Listing 10-103:* mm/page-writeback.c: [*wb_over_bg_thresh()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1964)

 

This function is something like a mini-[balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) (see Listing

10-97 above), only cut down in order to simply determine whether the back-

ground threshold has been exceeded.

A global [struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) state object gdtc is established, and

dirtyable memory assigned to avail via by [global_dirtyable_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n344) (see List-

ing 10-78) and the number of dirty pages set to the global count of dirty

files. Files being written back are not considered here, as they are in the gen-

eral dirty throttling logic, as we are attempting to see whether we need to

writeback further dirty pages.

We establish thresholds via [domain_dirty_limits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n374) as described in Listing

10-88, before simply seeing if the [struct dirty_throttle_control-\>dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) value

exceeds the background threshold just calculated. If so, then we return indi-

cating that the threshold has been breached, as global dirty pages do exceed

the global background threshold.

If this is not the case, we perform an additional check at the granularity

of the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object.

We invoke [wb_calc_thresh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n776) to determine the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

specified dirty threshold, which we examine in Listing 10-104.

 

776 **unsigned long wb_calc_thresh**(**struct** bdi_writeback \*wb, **unsigned long** thresh) 777 {

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

778 **struct** dirty_throttle_control gdtc = { **GDTC_INIT**(wb), 779 .thresh = thresh }; 780 **return \_\_wb_calc_thresh**(&gdtc); 781 }

 

*Listing 10-104:* mm/page-writeback.c: [*wb_calc_thresh()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n776)

 

This is simply a wrapper around [\_\_wb_calc_thresh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n749) (see Listing 10-90),

using a local stack variable for the [struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) object to pass state.

The [WB_RECLAIMABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n32) statistic we retrieve (being careful about low counts

to avoid inaccuracy) indicates the number of dirtied pages (though not yet being written back).

If this exceeds the hard dirty threshold of the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object,

we heuristically deem this worthy of background writeback and thus return indicating that the threshold has been breached, otherwise we do not.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**11**

 

**R E C L A I M A N D M E M O R Y P R E S S U R E**

 

Memory pressure arises when more memory is re-

quested than can be currently provided without dip-

ping into memory reserves. Reclaim is the means by

which the kernel relieves memory pressure. This is

critical, as Linux is profligate in caching file data in

the page cache, permits memory overcommit (allow-

ing users to map more memory than is physically avail-

able) and demand paging (actually allocating memory

only when the memory is used), so, as a result, mem-

ory pressure might arise at any time. This chapter ex-

plores the reclaim mechanism in detail.

There are two forms of reclaim—indirect reclaim, which occurs when a

zone from which memory is requested drops below the low watermark, and

direct reclaim, which occurs when z one drops below its minimum water-

mark.

See Section 2.4 in Chapter 2 for details of what nodes, zones and their

watermarks are, but briefly they are NUMA concepts with each node con-

taining memory with broadly equal access time to memory contained within

it, and zones describe contiguous physical memory ranges which are main-

The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

tained as distinct entities largely in order to account for hardware devices capable only of accessing memory within a particular range.

The relationship between memory usage, watermarks and the perfor-

mance of reclaim is shown in Figure 2-12 and Chapter 2, however for conve-

nience we reproduce it here in Figure 11-1.

 

Free pages

 

If any zone in a node

Allocate pages that could be allocated

from at the requested

High order has free pages

Start indirect equal to or exceeding

reclaim on the high water mark,

all nodes indirect reclaim sleeps

Low for that node.

 

Minimum

Direct reclaim,

block until page

allocated, or OOM.

Time

 

*Figure 11-1: Zone Watermarks*

 

We examine indirect and direct reclaim separately in Sections 11.4

and 11.3 respectively, before going on to examine the shared mechanism

through which reclaim is progressed within the kernel in Section 11.5.

As we can see in Figure 2-13 in Section 2.8.1 in Chapter 2 on physical

memory, regardless of the means by which the kernel invokes the physical

allocation of a memory page, all roads lead to [\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513) (as shown in

Listing 2-52 and Figure 2-14).

[\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513) attempts to allocate memory on the “fast path”, i.e. at

or above the low watermark in an eligible zone, requiring neither indirect nor direct reclaim. If this fails for all valid zones, we then revert to the “slow path” where indirect or direct reclaim can be invoked as required.

We examine the allocation “slow path” in Section 11.1, as this is the en-

try point for reclaim in the kernel as a whole.

After this, we examine the LRU mechanism which the kernel uses to

keep track of least recently used memory in order to decide what gets re-claimed, both that utilised for the page cache as well as that utilised for

anonymous memory, in Section 11.2.

We then examine how the actual reclaim mechanism proceeds for indi-

rect reclaim in Section 11.4 and direct reclaim in Section 11.3.

Finally, we examine folio batches, a means by which folios get stored

in fixed arrays before being processed in a batch once each folio batch be-

comes full. We examine this in Section 11.7.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**11.1 Physical Allocation Slow Path**

 

When allocating via the “fast path”, i.e. from either the Per-CPU-Pages (see

Section 2.7.3) or from a zone with its watermark at or above the [WMARK_LOW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n351)

level in [\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513), the kernel tries to do the least work possible to pro-

vide the memory.

However if all nodes and zones from which we could allocate have

free pages beneath the [WMARK_LOW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n351) level (accounting for reserves and allo-

cation flags which adjust this as determined in [\_\_zone_watermark_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3968), as

shown in Listing 2-59 and Section 2.8.2), we must take the “slow”path in

[\_\_alloc_pages_slowpath() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015)

We examine the core of the logic of this function in Figure 11-2.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[*WMARK_LOW*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n351) Disallow combination of [\_\_GFP_ATOMIC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n138)

allocation failed in and [\_\_GFP_DIRECT_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n216) flags.

[*\_\_alloc_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513) Warn if so & clear [\_\_GFP_ATOMIC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n138)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n138)

 

Determine allocation flags

via [gfp_to_alloc_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4816).

 

Determine preferred zone

via [first_zones_zonelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1289).

 

If [ALLOC_KSWAPD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n785) set, perform indirect

retry label, from Figure

reclaim (see Section 11.4) for

11-3 or Figure 11-4.

all nodes via [wake_all_kswapds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4796).

Return page to caller.

See if indirect reclaim saved us, try to Yes

allocate via [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) Success?

this time at [WMARK_MIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n350) watermark.

No

 

Can attempt compaction if water-

marks must be obeyed and order \>

[PAGE_ALLOC_COSTLY_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40) or both order

\> 1 & allocation is not movable.

 

Yes Try early direct compaction via

Try compaction?

[\_\_alloc_pages_direct_compact().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4476)

No

If [ALLOC_KSWAPD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n785) set, [wake_all_kswapds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4796)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4796) No

Success?

in case kswapd went back to sleep.

Yes

If [\_\_gfp_pfmemalloc_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4876) allows Return page to caller.

reserves to be used, update

flags and recalculate preferred

Return page to caller. zone via [first_zones_zonelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1289)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1289)

Yes

Try to allocate again via

Success?

[get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) .

Otherwise No, but can direct Return page to caller.

reclaim & ! Try direct reclaim via [PF_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713) Yes

Go to nopage label

[\_\_alloc_pages_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763) Success?

(see Figure 11-4).

(see Section 11.3).

Return page to caller. No

Yes Try direct compaction via

Success?

[\_\_alloc_pages_direct_compact() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4476)

Go to nopage label (see Figure 11-4).

No

If [\_\_GFP_NORETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n221) Yes is set, or if both

order \> [PAGE_ALLOC_COSTLY_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40) & Abort?

[!\_\_GFP_RETRY_MAYFAIL, ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n219)then abort. No

Go to Figure 11-3.

 

*Figure 11-2:* [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) *Core Logic*


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We will examine the code in detail starting at Listing 11-1 below. When

the initial attempt by [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) to allocate memory fails, we

attempt to retry, possibly invoking the OOM killer. We examine this logic in

Figure 11-3.

 

From Figure 11-2 To retry label in Figure 11-2.

Yes

Determine whether to retry

Retry?

To retry via [should_reclaim_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4910) label in Figure 11-2 .[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4910)

No

Yes

We retry compaction if direct

Retry compaction? reclaim made progress and

we [should_compact_retry().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4535)

Return page to caller.

No

Reclaim has not succeeded, Yes

so time for OOM killer via Success?

[\_\_alloc_pages_may_oom() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4381)

No

Go to nopage label (see Figure 11-4).

If the current thread is being OOM

Yes

killed [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n75)[tsk_is_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n75)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n75) & either

Abort?

[ALLOC_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n771) or [\_\_GFP_NOMEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n141) are

No set, abort to avoid *∞* looping. To retry label in Figure 11-2.

Yes

If [\_\_alloc_pages_may_oom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4381)

made forward progress, then Progress?

we have a reason to retry.

No

Go to nopage label (see Figure 11-4).

 

*Figure 11-3:* [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) *Retry/OOM Logic*

 

The logic invoked when no page can be found is shown in Figure 11-4.

 

From Figure 11-2 & Figure 11-3

 

If [\_\_GFP_NOFAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n220) is set, and di-

rect reclaim is permitted,

we must keep retrying.

Invoke [warn_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4335) (warning about

No

the failed allocation if [\_\_GFP_NOWARN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n247) Must retry?

To retry label in Figure 11-2.

is not set), and return NULL.

Yes

Sanity check flags and before order No

trying the allocation harder via Success?

[\_\_alloc_pages_cpuset_fallback().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4361)

Yes

Return page to caller.

 

*Figure 11-4:* [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) *No Page Logic*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

If we reach the slow path allocator function, [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015),

then we need to perform reclaim, whether indirect or direct.

We examine [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) starting with Listing 11-1 (eliding

some of the out of scope compaction logic, though keeping the general invo-cation for illustration, also eliding out of scope CMA and the majority of out of scope CPU set logic).

 

5014 **static inline struct** page \* 5015 **\_\_alloc_pages_slowpath**(**gfp_t** gfp_mask, **unsigned int** order, 5016 **struct** alloc_context \*ac) 5017 {

5018 **bool** can_direct_reclaim = gfp_mask & **\_\_GFP_DIRECT_RECLAIM**; 5019 **const bool** costly_order = order \> **PAGE_ALLOC_COSTLY_ORDER**; 5020 **struct** page \*page = **NULL**; 5021 **unsigned int** alloc_flags; 5022 **unsigned long** did_some_progress; 5023 **enum** compact_priority compact_priority; 5024 **enum** compact_result compact_result; 5025 **int** compaction_retries; 5026 **int** no_progress_loops; 5027 **unsigned int** cpuset_mems_cookie; 5028 **unsigned int** zonelist_iter_cookie; 5029 **int** reserve_flags; 5030

5031 */\**

5032 *\* We also sanity check to catch abuse of atomic reserves being used*

*by*

5033 *\* callers that are not in atomic context.* 5034 *\*/*

5035 **if** (**WARN_ON_ONCE**((gfp_mask & (**\_\_GFP_ATOMIC**\|**\_\_GFP_DIRECT_RECLAIM**)) == 5036 (**\_\_GFP_ATOMIC**\|**\_\_GFP_DIRECT_RECLAIM**))) 5037 gfp_mask &= ~**\_\_GFP_ATOMIC**;

 

*Listing 11-1:* mm/page_alloc.c: [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) *Preface*

 

We record whether we are able to perform direct reclaim in

can_direct_reclaim , which is determined by the user specifying

[\_\_GFP_DIRECT_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n216) (see Section 2.6 for a detailed description of GFP flags as a whole).

We also note whether we have exceeded a “costly” allocation size as

stored in costly_order. This is determined via the [PAGE_ALLOC_COSTLY_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40) value (hard-coded to order-3), beyond which allocations are determined to be unlikely to coalesce naturally under ordinary memory pressure on re-claim.

We perform a sanity check to ensure that direct reclaim is not specified

when an atomic allocation is requested (an atomic allocation is one per-formed in a context when sleep cannot be permitted such as interrupt con-text), as direct reclaim necessarily implies a non-atomic context (for instance, in real-time kernels, it triggers a voluntary context switch).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

In this instance the issue is warned about, but the allocation may pro-

ceed only with the atomic flag cleared on the assumption that the caller may

be trying to abuse memory reserved for atomic allocations.

After we perform this initial logic we proceed with performing indirect

reclaim if required, a case we examine in Listing 11-2.

 

5039 **restart**:

5040 compaction_retries = 0; 5041 no_progress_loops = 0; 5042 compact_priority = **DEF_COMPACT_PRIORITY**;

. . .

5046 */\**

5047 *\* The fast path uses conservative alloc_flags to succeed only until*

5048 *\* kswapd needs to be woken up, and to avoid the cost of setting up*

5049 *\* alloc_flags precisely. So we do that now.* 5050 *\*/*

5051 alloc_flags = **gfp_to_alloc_flags**(gfp_mask); 5052

5053 */\**

5054 *\* We need to recalculate the starting point for the zonelist iterator*

5055 *\* because we might have used different nodemask in the fast path, or*

5056 *\* there was a cpuset modification and we are retrying - otherwise we*

5057 *\* could end up iterating over non-eligible zones endlessly.* 5058 *\*/*

5059 ac-\>preferred_zoneref = **first_zones_zonelist**(ac-\>zonelist, 5060 ac-\>highest_zoneidx, ac-\>nodemask);

5061 **if** (!ac-\>preferred_zoneref-\>zone) 5062 **goto nopage**;

. . .

5077 **if** (alloc_flags & **ALLOC_KSWAPD**) 5078 **wake_all_kswapds**(order, gfp_mask, ac); 5079

5080 */\**

5081 *\* The adjusted alloc_flags might result in immediate success, so try*

5082 *\* that first*

5083 *\*/*

5084 page = **get_page_from_freelist**(gfp_mask, order, alloc_flags, ac); 5085 **if** (page)

5086 **goto got_pg**;

 

*Listing 11-2:* mm/page_alloc.c: [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) *Indirect Reclaim*

 

We start by determining the correct allocation flags to apply to this allo-

cation via [gfp_to_alloc_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4816). Previously we set some conservative values,

most notably [ALLOC_WMARK_LOW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n758)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n758) indicating that the allocation had to be at or

above the low watermark. This time we instead set [ALLOC_WMARK_MIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n757) and derive

the remainder of the flags in [gfp_to_alloc_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4816) as shown in Listing 11-3

(eliding build asserts for brevity and CMA and CPU set logic which is out of

scope).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

415 **static inline unsigned int** 416 **gfp_to_alloc_flags**(**gfp_t** gfp_mask) 417 {

418 **unsigned int** alloc_flags = **ALLOC_WMARK_MIN** \| **ALLOC_CPUSET**;

. . .

428 */\**

429 *\* The caller may dip into page reserves a bit more if the caller*

430 *\* cannot run direct reclaim, or if the caller has realtime scheduling*

431 *\* policy or is asking for \_\_GFP_HIGH memory. GFP_ATOMIC requests*

*will*

432 *\* set both ALLOC_HARDER (\_\_GFP_ATOMIC) and ALLOC_HIGH (\_\_GFP_HIGH).*

433 *\*/*

434 alloc_flags \|= (**\_\_force int**) 435 (gfp_mask & (**\_\_GFP_HIGH** \| **\_\_GFP_KSWAPD_RECLAIM**)); 436

437 **if** (gfp_mask & **\_\_GFP_ATOMIC**) { 438 */\**

439 *\* Not worth trying to allocate harder for \_\_GFP_NOMEMALLOC*

*even*

440 *\* if it can't schedule.* 441 *\*/*

442 **if** (!(gfp_mask & **\_\_GFP_NOMEMALLOC**)) 443 alloc_flags \|= **ALLOC_HARDER**;

. . .

449 } **else if** (**unlikely**(**rt_task**(**current**)) && **in_task**()) 450 alloc_flags \|= **ALLOC_HARDER**;

. . .

454 **return** alloc_flags; 455 }

 

*Listing 11-3:* mm/page_alloc.c: [*gfp_to_alloc_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4816)

 

This sets the [ALLOC_WMARK_MIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n757) flag, indicating that the zone from which

the allocation occurs should be at or above the minimum watermark, i.e.

[WMARK_MIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n350). It additionally sets [ALLOC_CPUSET](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n778) but this is out of scope for the book.

We determine whether to allow access to further reserves depending on

allocation flags, firstly if [\_\_GFP_HIGH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n139) is set then we set [ALLOC_HIGH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n778) (the two val-ues are maintained to be the same), which is used explicitly for 32-bit archi-tectures.

Secondly, and more importantly, if [\_\_GFP_KSWAPD_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n217) is set, then so is

[ALLOC_KSWAPD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n785) indicating that indirect reclaim can proceed.

If the allocation is atomic, as indicated by the [\_\_GFP_ATOMIC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n138) flag being

specified, and emergency reserves are not explicitly forbidden for use (i.e.

the [\_\_GFP_NOMEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n142) flag not being set), then we default to accessing these

reserves by setting the [ALLOC_HARDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n776) flag.

Finally, if the current thread (represented by the [current](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/current.h?h=v6.0#n18) macro) is a

real-time task as checked by [rt_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/rt.h?h=v6.0#n16) and is in task context as checked by

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[in_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/preempt.h?h=v6.0#n121) (i.e. not servicing a non-maskable interrupt or NMI, in a hard inter-

rupt or a soft interrupt handler), then this necessitates the use of emergency

reserves and [ALLOC_HARDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n776) is equally set in this instance.

Returning to the [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) code that invokes this in List-

ing 11-4, we redetermine the preferred zone in case this changed via the

[first_zones_zonelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1289) helper function, jumping to the no page handling

logic if none can be found (explored in Listing 11-9. For more on zone lists

see Section 2.4).

Importantly, next we check the likely now-established [ALLOC_KSWAPD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n785)

flag, and if set begin indirect reclaim for all zones on this node via

[wake_all_kswapds() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4796)which we explore in Listing 11-24 and Section 11.4.

With these flags adjusted to permit zone memory to be utilised up

to the minimum watermark, there’s a good chance that we can now

succeed in our attempt to allocate a page which we attempt to do via

[get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) (see Listing 2-55 in Section 2.8.2 and Chapter 2).

If so we return the successfully retrieved page.

If not, then memory pressure is significant—we cannot satisfy the request

even at minimum watermark level, so must now perform reclaim directly in

order to service it. We examine the direct reclaim logic in Listing 11-4.

 

5039 */\**

5040 *\* For costly allocations, try direct compaction first, as it's likely*

5041 *\* that we have enough base pages and don't need to reclaim. For non-*

5042 *\* movable high-order allocations, do that as well, as compaction will*

5043 *\* try prevent permanent fragmentation by migrating from blocks of the*

5044 *\* same migratetype.* 5045 *\* Don't try this for allocations that are allowed to ignore* 5046 *\* watermarks, as the ALLOC_NO_WATERMARKS attempt didn't yet happen.*

5047 *\*/*

5048 **if** (can_direct_reclaim && 5049 (costly_order \|\| 5050 (order \> 0 && ac-\>migratetype != **MIGRATE_MOVABLE**)) 5051 && !**gfp_pfmemalloc_allowed**(gfp_mask)) { 5052 page = **\_\_alloc_pages_direct_compact**(gfp_mask, order, 5053 alloc_flags, ac, 5054 **INIT_COMPACT_PRIORITY**, 5055 &compact_result); 5056 **if** (page) 5057 **goto got_pg**;

. . .

5141 }

5142

5143 **retry**:

5144 */\* Ensure kswapd doesn't accidentally go to sleep as long as we loop*

*\*/*

5145 **if** (alloc_flags & **ALLOC_KSWAPD**) 5146 **wake_all_kswapds**(order, gfp_mask, ac); 5147

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

5148 reserve_flags = **\_\_gfp_pfmemalloc_flags**(gfp_mask); 5149 **if** (reserve_flags) 5150 alloc_flags = **gfp_to_alloc_flags_cma**(gfp_mask, reserve_flags);

. . .

5152 */\**

5153 *\* Reset the nodemask and zonelist iterators if memory policies can be*

5154 *\* ignored. These allocations are high priority and system rather than*

5155 *\* user oriented.* 5156 *\*/*

5157 **if** (!(alloc_flags & **ALLOC_CPUSET**) \|\| reserve_flags) { 5158 ac-\>nodemask = **NULL**; 5159 ac-\>preferred_zoneref = **first_zones_zonelist**(ac-\>zonelist, 5160 ac-\>highest_zoneidx, ac-\>nodemask);

5161 }

5162

5163 */\* Attempt with potentially adjusted zonelist and alloc_flags \*/* 5164 page = **get_page_from_freelist**(gfp_mask, order, alloc_flags, ac); 5165 **if** (page)

5166 **goto got_pg**; 5167

5168 */\* Caller is not willing to reclaim, we can't balance anything \*/*

5169 **if** (!can_direct_reclaim) 5170 **goto nopage**; 5171

5172 */\* Avoid recursion of direct reclaim \*/* 5173 **if** (current-\>flags & **PF_MEMALLOC**) 5174 **goto nopage**; 5175

5176 */\* Try direct reclaim and then allocating \*/* 5177 page = **\_\_alloc_pages_direct_reclaim**(gfp_mask, order, alloc_flags, ac, 5178 &did_some_progress);

5179 **if** (page)

5180 **goto got_pg**; 5181

5182 */\* Try direct compaction and then allocating \*/* 5183 page = **\_\_alloc_pages_direct_compact**(gfp_mask, order, alloc_flags, ac, 5184 compact_priority, &compact_result);

5185 **if** (page)

5186 **goto got_pg**;

 

*Listing 11-4:* mm/page_alloc.c: [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) *Direct Reclaim*

 

While compaction is out of scope for the book, we identify the points at

which it would occur during slow-path allocation. Here, we firstly attempt direct compaction, i.e. a blocking form of compaction if and only if direct reclaim is generally permitted and either we have reached a costly order, or the allocation is higher order and the memory being allocated is not mov-

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

able (this may be the last opportunity to move memory that could be other-

wise coalesced before it becomes unmovable).

In these circumstances we invoke [\_\_alloc_pages_direct_compact()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4476), the de-

tails of which are out of scope for the book. If the allocation succeeds under

direct compaction, then the page is returned.

 

**N O T E** Compaction is the process by which the kernel migrates movable folios in order to

allow the coalescence of buddies into higher order folios. Through this process the

kernel is able to avert higher order fragmentation resulting in an inability to allocate

memory.

 

Next, if [ALLOC_KSWAPD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n785) is specified, we rewake kswapd for all zones of this

node via [wake_all_kswapds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4796) to ensure that indirect reclaim cannot go to sleep

while we are still attempting to allocate.

We then perform some housekeeping before invoking direct re-

claim itself. Firstly we check to see if we can use memory reserves via

[\_\_gfp_pfmemalloc_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4876) which we examine in Listing 11-5.

Note that we set alloc_flags to the result of this function via

[gfp_to_alloc_flags_cma() . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4151)CMA is out of scope for the book, but regardless

of this, whether enabled or not, it returns the reserve_flags parameter.

 

4872 */\**

4873 *\* Distinguish requests which really need access to full memory* 4874 *\* reserves from oom victims which can live with a portion of it* 4875 *\*/*

4876 **static inline int \_\_gfp_pfmemalloc_flags**(**gfp_t** gfp_mask) 4877 {

4878 **if** (**unlikely**(gfp_mask & **\_\_GFP_NOMEMALLOC**)) 4879 **return** 0; 4880 **if** (gfp_mask & **\_\_GFP_MEMALLOC**) 4881 **return ALLOC_NO_WATERMARKS**; 4882 **if** (**in_serving_softirq**() && (**current**-\>flags & **PF_MEMALLOC**)) 4883 **return ALLOC_NO_WATERMARKS**; 4884 **if** (!**in_interrupt**()) { 4885 **if** (**current**-\>flags & **PF_MEMALLOC**) 4886 **return ALLOC_NO_WATERMARKS**; 4887 **else if** (**oom_reserves_allowed**(**current**)) 4888 **return ALLOC_OOM**; 4889 }

4890

4891 **return** 0;

4892 }

 

*Listing 11-5:* mm/page_alloc.c: [*\_\_gfp_pfmemalloc_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4876)

 

This determines the circumstances under which emergency memory

reserves can be used—broadly [\_\_GFP_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n140) (which can also be specified

across a thread by setting the [PF_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713) flag in [struct task_struct-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727))

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

implies that watermarks can be ignored altogether and all memory in a zone

can be used (as indicated by [ALLOC_NO_WATERMARKS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n760)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n760)

 

**N O T E** Thread-specific allocation flags are often enabled and disabled via *xxx_save()* and

*xxx_restore()* helper functions, for instance [*PF_MEMALLOC*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713) can be set/cleared via

[*memalloc_noreclaim_save()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n339) and [*memalloc_noreclaim_restore()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n346) respectively.

 

In non-interrupt context, [oom_reserves_allowed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4857)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4857) is used to determine

if this is an out of memory (OOM) killer victim, in which case additional reserves are permitted as we know this process will soon be freed and will therefore soon free all of its memory at any rate (we denote this with the

[ALLOC_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n771) flag).

If [\_\_GFP_NOMEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n141) is set, this disallows the use of these reserves alto-

gether.

Returning to Listing 11-4, we then, if reserves can be used, we then elimi-

nate node mask restrictions and redetermine the preferred zone at which to

attempt allocation first via [first_zones_zonelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1289).

After this we regardless attempt to allocate a new page to see if chang-

ing these flags or indirect reclaim has led to a situation where the allocation

would now succeed via [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) (see Listing 2-55 in Section

2.8.2 and Chapter 2). If so, we return the folio.

At this point, we are ready to go ahead and try direct reclaim.

if can_direct_reclaim is not set, i.e. if the user did not specify

[\_\_GFP_DIRECT_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n216), we enter no page handling (see Listing 11-9). Equally, if

[PF_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713) is set, indicating that reclaim should not proceed (but emergency reserves should be used), we also enter no page handling.

This is important, because the direct reclaim logic itself sets this flag and

we want to avoid reclaim recursing over and over again.

Finally we perform the actual direct reclaim via

[\_\_alloc_pages_direct_reclaim(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763)which we examine in Listing 11-17 and

Section 11.3. If this succeeds we return the folio

If it does not, then finally we try direct compaction via

[\_\_alloc_pages_direct_compact(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4476)again returning the resultant folio if it suc-ceeds.

Once direct reclaim attempts have been exhausted we are at the point

where we must determine if a retry makes sense or not, which we examine in

Listing 11-6.

 

5188 */\* Do not loop if specifically requested \*/* 5189 **if** (gfp_mask & **\_\_GFP_NORETRY**) 5190 **goto nopage**; 5191

5192 */\**

5193 *\* Do not retry costly high order allocations unless they are* 5194 *\* \_\_GFP_RETRY_MAYFAIL* 5195 *\*/*

5196 **if** (costly_order && !(gfp_mask & **\_\_GFP_RETRY_MAYFAIL**)) 5197 **goto nopage**;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

5198

5199 **if** (**should_reclaim_retry**(gfp_mask, order, ac, alloc_flags, 5200 did_some_progress \> 0, &no_progress_loops))

5201 **goto retry**; 5202

5203 */\**

5204 *\* It doesn't make any sense to retry for the compaction if the order*

*-0*

5205 *\* reclaim is not able to make any progress because the current* 5206 *\* implementation of the compaction depends on the sufficient amount*

5207 *\* of free memory (see \_\_compaction_suitable)* 5208 *\*/*

5209 **if** (did_some_progress \> 0 && 5210 **should_compact_retry**(ac, order, alloc_flags, 5211 compact_result, &compact_priority, 5212 &compaction_retries)) 5213 **goto retry**;

 

*Listing 11-6:* mm/page_alloc.c: [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) *Retry Logic*

 

The purpose of this logic is to assess whether it makes sense to retry, and

if so, to do so. Firstly, if the [\_\_GFP_NORETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n221) flag is specified, this explicitly hints

that no retries should be attempted, so we immediately defer to the no page

handling (see Listing 11-9).

Costly allocations are, by their very definition, unlikely to succeed if di-

rect reclaim did not immediately provide a free folio so, unless the user

explicitly specifies that they want this behaviour via the [\_\_GFP_RETRY_MAYFAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n219)

flag, we also do not proceed with retry in this case.

Finally we defer the decision to a helper function, [should_reclaim_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4910)

which we examine in Listing 11-7. Note that as one of the parameters, we

pass in did_some_progress, a field set by [\_\_alloc_pages_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763) (see

Listing 11-17 in Section 11.3).

This determines whether forward progress has occurred during direct re-

claim, which would make it useful to retry the reclaim operation. This there-

fore forms part of the criteria of [should_reclaim_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4910).

Before we examine [should_reclaim_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4910) we see that, if it succeeds we

jump to the retry label (Listing 11-4), and if it fails and direct reclaim had

made forward progress, we apply the same logic to retrying compaction via

[should_compact_retry().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4535)

Compaction is out of scope for the book so we won’t examine that in

detail, but rather simply observe that this plays a role in the logic here.

We have therefore only [should_reclaim_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4910) to examine in detail here,

as shown in Listing 11-7 (eliding tracing hooks and some work queue con-

gestion logic).

 

4899 */\**

4900 *\* Checks whether it makes sense to retry the reclaim to make a forward*

*progress*

4901 *\* for the given allocation request.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4902 *\**

4903 *\* We give up when we either have tried MAX_RECLAIM_RETRIES in a row* 4904 *\* without success, or when we couldn't even meet the watermark if we* 4905 *\* reclaimed all remaining pages on the LRU lists.* 4906 *\**

4907 *\* Returns true if a retry is viable or false to enter the oom path.* 4908 *\*/*

4909 **static inline bool**

4910 **should_reclaim_retry**(**gfp_t** gfp_mask, **unsigned** order, 4911 **struct** alloc_context \*ac, **int** alloc_flags, 4912 **bool** did_some_progress, **int** \***no_progress_loops**) 4913 {

4914 **struct** zone \*zone; 4915 **struct** zoneref \*z; 4916 **bool** ret = **false**; 4917

4918 */\**

4919 *\* Costly allocations might have made a progress but this doesn't mean*

4920 *\* their order will become available due to high fragmentation so*

4921 *\* always increment the no progress counter for them* 4922 *\*/*

4923 **if** (did_some_progress && order \<= **PAGE_ALLOC_COSTLY_ORDER**) 4924 \***no_progress_loops** = 0; 4925 **else**

4926 (\***no_progress_loops**)++; 4927

4928 */\**

4929 *\* Make sure we converge to OOM if we cannot make any progress* 4930 *\* several times in the row.* 4931 *\*/*

4932 **if** (\***no_progress_loops** \> **MAX_RECLAIM_RETRIES**) { 4933 */\* Before OOM, exhaust highatomic_reserve \*/* 4934 **return unreserve_highatomic_pageblock**(ac, **true**); 4935 }

4936

4937 */\**

4938 *\* Keep reclaiming pages while there is a chance this will lead* 4939 *\* somewhere. If none of the target zones can satisfy our allocation*

4940 *\* request even if all reclaimable pages are considered then we are*

4941 *\* screwed and have to go OOM.* 4942 *\*/*

4943 **for_each_zone_zonelist_nodemask**(zone, z, ac-\>zonelist, 4944 ac-\>highest_zoneidx, ac-\>nodemask) { 4945 **unsigned long** available; 4946 **unsigned long** reclaimable; 4947 **unsigned long** min_wmark = **min_wmark_pages**(zone); 4948 **bool** wmark;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4949

4950 available = reclaimable = **zone_reclaimable_pages**(zone); 4951 available += **zone_page_state_snapshot**(zone, **NR_FREE_PAGES**); 4952

4953 */\**

4954 *\* Would the allocation succeed if we reclaimed all* 4955 *\* reclaimable pages?* 4956 *\*/*

4957 wmark = **\_\_zone_watermark_ok**(zone, order, min_wmark, 4958 ac-\>highest_zoneidx, alloc_flags, available);

. . .

4961 **if** (wmark) { 4962 ret = **true**; 4963 **break**; 4964 }

4965 }

. . .

4978 **return** ret;

4979 }

 

*Listing 11-7:* mm/page_alloc.c: [*should_reclaim_retry()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4910)

 

This function is passed a pointer to the [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015)’s

no_progress_loops counter, which keeps tracks how many loops through the

retry logic have occurred without progress, allowing us to eventually abort

retries when it makes sense to.

We start by resetting this counter if both some progress was made and

this was not a costly order allocation. Some sort of progress being made

does not guarantee costly allocations will succeed, so we do not consider

that progress has been made in this case. Otherwise, we increment the

no_progress_loops counter.

We then check to see if this count exceeds [MAX_RECLAIM_RETRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n170) (hard-

coded to 16 loops of no progress being permitting). If so, we see whether we

can utilise reserved high atomic memory via [unreserve_highatomic_pageblock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2915).

This reserve is intended for atomic allocations at higher orders (atomic

meaning that the thread cannot sleep for the allocation and thus more in-

volved forms of reclaim cannot be performed), however in this instance we

permit the use of this reserve to avoid the out of memory killer.

Next we manually iterate through each zone in which the allocation

could be performed, and calculate how many folios could be reclaimed and

use this to determine if it is at all feasible for a retry to succeed at the min-

imum water level if indeed all of these folios were reclaimed (this is deter-

mined via the [zone_reclaimable_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n571) function).

If absolutely no reclaim is possible, then we abort retries, otherwise we

attempt retries up to [MAX_RECLAIM_RETRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n170) loops without progress.

This allows for a sensible mechanism which tries its absolute best to ser-

vice requests even under very extreme memory pressure resorting to the out

of memory killer if absolutely necessary.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Finally, if retry is not feasible, we are in a place where we consider an out

of memory condition, which we examine in Listing 11-8.

 

5224 */\* Reclaim has failed us, start killing things \*/* 5225 page = **\_\_alloc_pages_may_oom**(gfp_mask, order, ac, &did_some_progress); 5226 **if** (page)

5227 **goto got_pg**; 5228

5229 */\* Avoid allocations with no watermarks from looping endlessly \*/*

5230 **if** (**tsk_is_oom_victim**(current) && 5231 (alloc_flags & **ALLOC_OOM** \|\| 5232 (gfp_mask & **\_\_GFP_NOMEMALLOC**))) 5233 **goto nopage**; 5234

5235 */\* Retry as long as the OOM killer is making progress \*/* 5236 **if** (did_some_progress) { 5237 no_progress_loops = 0; 5238 **goto retry**; 5239 }

 

*Listing 11-8:* mm/page_alloc.c: [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) *OOM*

 

We perform the actual allocation in this instance via

[\_\_alloc_pages_may_oom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4381), which we explore in Chapter 13, in Section

13.4.1 and Listing 13-2.

If this results in a folio immediately becoming available to fulfil the allo-

cation then we return this, otherwise we examine the edge case of the run-

ning thread being the OOM victim (checked via [tsk_is_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n75)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n75) and ei-

ther using all available reserves (as specified by the [ALLOC_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n771) flag) or by no

emergency reserves being available at all because [\_\_GFP_NOMEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n141) is set, then we risk looping despite the fact we are about to be killed, so in this instance we simply defer to the no page handling.

Otherwise, if the OOM killer made some progress, we reset the

no_progress_loops counter and retry.

If we did not, or one of the many other parts of the logic that revert to

jumping to the no page handling logic are invoked, we end up at the point

of dealing with an allocation failure, a case we examine in Listing 11-9.

 

5039 **nopage**:

5040 */\**

5041 *\* Deal with possible cpuset update races or zonelist updates to avoid*

5042 *\* a unnecessary OOM kill.* 5043 *\*/*

5044 **if** (**check_retry_cpuset**(cpuset_mems_cookie, ac) \|\| 5045 **check_retry_zonelist**(zonelist_iter_cookie)) 5046 **goto restart**; 5047

5048 */\**

5049 *\* Make sure that \_\_GFP_NOFAIL request doesn't leak out and make sure*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

5050 *\* we always retry* 5051 *\*/*

5052 **if** (gfp_mask & **\_\_GFP_NOFAIL**) { 5053 */\**

5054 *\* All existing users of the \_\_GFP_NOFAIL are blockable, so*

*warn*

5055 *\* of any new users that actually require GFP_NOWAIT* 5056 *\*/*

5057 **if** (**WARN_ON_ONCE_GFP**(!can_direct_reclaim, gfp_mask)) 5058 **goto fail**;

. . .

5075 */\**

5076 *\* Help non-failing allocations by giving them access to*

*memory*

5077 *\* reserves but do not use ALLOC_NO_WATERMARKS because this*

5078 *\* could deplete whole memory reserves which would just make*

5079 *\* the situation worse* 5080 *\*/*

5081 page = **\_\_alloc_pages_cpuset_fallback**(gfp_mask, order,

**ALLOC_HARDER**, ac);

5082 **if** (page) 5083 **goto got_pg**;

. . .

5086 **goto retry**; 5087 }

5088 **fail**:

5089 **warn_alloc**(gfp_mask, ac-\>nodemask, 5090 "page allocation failure: order:%u", order); 5091 **got_pg**:

5092 **return** page;

5093 }

 

*Listing 11-9:* mm/page_alloc.c: [*\_\_alloc_pages_slowpath()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) *Allocation Failure*

 

All of the checks are performed when the [\_\_GFP_NOFAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n220) flag is set—in this

scenario we are simply not permitted to fail so must keep on retrying regard-

less. Otherwise, we simply go ahead and fail the request, writing a warning

to the kernel circular buffer via [warn_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4335) (if [\_\_GFP_NOWARN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n247) flag was not set).

Otherwise, we check for the edge case of [\_\_GFP_NOFAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n220) being set but

[\_\_GFP_DIRECT_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n216) not having been set, in which case we assume the

[\_\_GFP_NOFAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n220) flag was set in error and abort the allocation.

After this we invoke [\_\_alloc_pages_cpuset_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4361), which attempts a last-

gasp allocation, setting [ALLOC_HARDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n776) to access to even more emergency mem-

ory reserves.

If this succeeds we return the resultant folio, otherwise we simply uncon-

ditionally retry.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**11.2 LRU Vectors**

 

In order to most efficiently make use of memory installed in the system the kernel tries to use as much of it as it can to cache data from disk in memory (see the page cache chapter for more details on the precise details of this).

While the kernel is aggressive in caching files in memory, it also needs to

be aggressive in freeing them again (termed reclaim) when memory pressure arises, i.e. zones reaching their low or minimum watermark level (see the physical memory chapter for more on this). To do this we need to prioritise folios in such a way as to ensure we maintain useful folios and eliminate less useful ones.

The kernel aspires to implement the Least Recently Used (LRU) cache

replacement policy – conceptually this works as its name suggests – always evicting the least recently used folio. In idealised form:-

 

Folio **allocated**

 

Folio **touched**

 

Folio **evicted**

 

Least recently used Most recently used

 

*Figure 11-5: Idealised LRU*

 

I say aspire to this, as unfortunately this approach is not practical—it

would introduce significant latency to capture every single folio access in order to move them around in the LRU list, so the kernel implements an approximation to this approach.

Rather than moving folios around in an LRU on each access the ker-

nel in essence samples whether the last folio was accessed on each occa-sion we contemplate reclaim – this is possible because hardware sets the

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

\_PAGE_ACCESSED page table flag when each base page is accessed. This is also

referred to as the ‘young’ flag, i.e. the one tested by [pte_young()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n132)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n132)

This is x86-64 specific and precise means of determining page ac-

cess varies by architecture. In x86-64 this is ultimately performed by

[ptep_test_and_clear_young()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n541) which is called by [ptep_clear_flush_young()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n578) and

[ptep_clear_flush_young_notify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmu_notifier.h?h=v6.0#n540) in turn.

This flag is ‘sticky’, meaning that it is set by hardware and stays set un-

til the kernel clears it. Therefore when reclaim is performed this flag can

be checked to see whether the folio has been active since the last check and

cleared for next time. This is done via [folio_referenced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n900) which performs an

rmap walk from the folio to each PTE which maps it.

If we maintain a single LRU list we run into a big problem – we are not

moving folios in the LRU each time they are accessed, so whichever hap-

pens to be at the rear of the list (and subject to possible reclaim) might be

either regularly accessed folios or rarely accessed ones, we don’t know until

we check. This can result in a lot of time spent checking folios that won’t be

reclaimable and slow things down significantly.

The solution is simple – maintain separate active and inactive LRU lists.

By only trying to reclaim from the inactive list and ‘promoting’ folios that

are found to be recently used there to the active one we significantly increase

our chances of actually reclaiming memory.

In addition, we can choose when to scan the active list in order to deter-

mine which folios should be demoted to the inactive list at our leisure – un-

der severe memory pressure we can focus on the inactive list and almost cer-

tainly free memory, otherwise we can also check the active list to ensure the

two are balanced appropriately.

‘Eviction’ has an entirely different meaning for file-backed and anony-

mous folios – the former, when clean (i.e. with no changes pending to be

written back to disk), can simply be dropped from the page cache (and re-

read if needed again). Anonymous pages will need to be swapped out, a far

more expensive operation.

It is therefore sensible to maintain separate LRUs for file-backed folios

and anonymous ones in order that we can have precise control over how we

handle evictions of each and can batch up the appropriate operation in ei-

ther case.

Finally, pages which cannot be evicted at all (typically memory that has

been [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)ed) are not maintained on any of these lists. This leaves us with

ostensibly 5 LRU lists overall – however note that unevictable pages do not

actually get placed on any list in practice.

We explore the actual underlying mechanism in detail in Section 11.5. LRU lists are kept in a per-memcg (i.e. memory cgroup, though cgroups

are out of scope for the book), per-node [struct lruvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) data structure. We

visualise this in Figure 11-6.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Folio **allocated**

Folio **swapped out**

Touched folio **kept**

 

**Inactive Anon**

 

Folio **deactivated**

 

Referenced folio **activated**

 

**Active Anon**

 

Folio **mapped**

Folio **evicted**

Touched folio **kept**

 

**Inactive File**

 

Folio **deactivated**

 

Referenced folio **activated**

 

**Active File**

 

Touched, executable folio **kept**

 

Least recently used Most recently used

 

*Figure 11-6: LRU lists*

 

This requires some additional explanation – each time a folio reaches

near the end of the inactive list (and this is part of the batch of folios under consideration for reclaim), we check whether the page table accessed bit is set for any underlying PTE – it being set is necessary, but insufficient for the folio to be ‘activated’.

Let’s examine a simplified version of the function which performs this

check, [folio_check_references()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433) in Listing 11-10 (note we examine the full

thing in Listing 11-70 and Section 11.5.10).

 

1433 **static enum** page_references **folio_check_references**(**struct** folio \*folio, 1434 **struct** scan_control \*sc) 1435 {

1436 **int** referenced_ptes, referenced_folio;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1437 **unsigned long** vm_flags; 1438

1439 referenced_ptes = **folio_referenced**(folio, 1, sc-\>target_mem_cgroup, 1440 &vm_flags); 1441 referenced_folio = **folio_test_clear_referenced**(folio);

. . .

1454 **if** (referenced_ptes) { 1455 */\**

1456 *\* All mapped folios start out with page table* 1457 *\* references from the instantiating fault, so we need* 1458 *\* to look twice if a mapped file/anon folio is used more* 1459 *\* than once.* 1460 *\**

1461 *\* Mark it and spare it for another trip around the* 1462 *\* inactive list. Another page table reference will* 1463 *\* lead to its activation.* 1464 *\**

1465 *\* Note: the mark is set for activated folios as well* 1466 *\* so that recently deactivated but used folios are* 1467 *\* quickly recovered.* 1468 *\*/*

1469 **folio_set_referenced**(folio); 1470

1471 **if** (referenced_folio \|\| referenced_ptes \> 1) 1472 **return PAGEREF_ACTIVATE**;

. . .

1480 **return PAGEREF_KEEP**; 1481 }

. . .

1487 **return PAGEREF_RECLAIM**; 1488 }

 

*Listing 11-10:* mm/vmscan.c: *Simplified [folio_check_references()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433)*

 

Note – We elide a number of edge cases here. We will examine the func-

tion in full detail in Section 11.5.

This lays out the details of an additional ‘referenced’ check in

the inactive LRU list only. When reclaim is performed in this list via

[shrink_page_list() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)this determines how to proceed -PAGEREF_ACTIVATE in-

dicates that the folio should be placed on the active list, PAGEREF_KEEP indi-

cates that it should be placed at the front of the inactive list for another go-

around, and PAGEREF_RECLAIM indicates that reclaim should occur.

The logic is as follows (again, importantly, we ignore some edge case de-

tails here – see Section 11.5 for a full analysis):-

 

1. Determine how many PTEs (or higher page table levels if huge) which

map this folio are marked ‘young’ (i.e. whether \_PAGE_ACCESSED is set for

x86-64) via [folio_referenced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n900), simultaneously clearing this flag ready for the next check.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2. Check and clear the folio’s [PG_referenced](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n102) flag.

3. If no PTEs mapping this folio were accessed since the last check, we go

ahead and reclaim.

4. Otherwise, we set the PG_referenced flag to indicate that the folio is

young.

5. If it had the referenced flag set prior to this, or if more than 1 PTE ref-

erence the folio, then we activate the folio. Note that the folio will retain its PG_referenced flag, and thus when deactivated will get an extra cycle around the inactive list.

6. Otherwise, we keep the folio, i.e. place it at the front of the inactive list

for another go-around.

 

For the active LRU the logic is different – for anonymous pages we sim-

ply allow folios to become deactivated after they have gone through the list. For file folios we add an edge case for those which back executable ranges (i.e. ones which contain code) and, if touched, we maintain them in the active

list. See [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) in Listing 11-56 for more details.

When an event occurs that causes a folio to be accessed such a file be-

ing read from or written to or a folio being swapped in then it is manually

marked accessed via [folio_mark_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441) (more on this function later). Ex-amining how these states vary:-

 

Reclaim

Evicted Inactive Inactive Active

Unreferenced Referenced Referenced

 

folio_mark_accessed() folio_mark_accessed()

 

Active

Unreferenced

 

*Figure 11-7: Folio active/referenced states*

 

Note that solid lines denote folio promotion, dotted lines de-

note folio demotion and that [folio_mark_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441) will promote from inactive, referenced to active, unreferenced while reclaim will promote to active, referenced , i.e. retaining the PG_referenced folio flag. Additionally, the promotion from active, unreferenced to active, referenced will only be performed by folio_mark_accessed().

Examining folio_mark_accessed():-

 

431 */\**

432 *\* Mark a page as having seen activity.* 433 *\**

434 *\* inactive,unreferenced* *-\>* *inactive,referenced* 435 *\* inactive,referenced* *-\>* *active,unreferenced* 436 *\* active,unreferenced* *-\>* *active,referenced*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

437 *\**

438 *\* When a newly allocated page is not yet visible, so safe for non-atomic ops,*

439 *\* \_\_SetPageReferenced(page) may be substituted for mark_page_accessed(page).*

440 *\*/*

441 **void folio_mark_accessed**(**struct** folio \*folio) 442 {

443 **if** (!**folio_test_referenced**(folio)) { 444 **folio_set_referenced**(folio); 445 } **else if** (**folio_test_unevictable**(folio)) { 446 */\**

447 *\* Unevictable pages are on the "LRU_UNEVICTABLE" list. But,*

448 *\* this list is never rotated or maintained, so marking an*

449 *\* unevictable page accessed has no effect.* 450 *\*/*

451 } **else if** (!**folio_test_active**(folio)) { 452 */\**

453 *\* If the folio is on the LRU, queue it for activation via*

454 *\* cpu_fbatches.activate. Otherwise, assume the folio is in a*

455 *\* folio_batch, mark it active and it'll be moved to the*

*active*

456 *\* LRU on the next drain.* 457 *\*/*

458 **if** (**folio_test_lru**(folio)) 459 **folio_activate**(folio); 460 **else**

461 **\_\_lru_cache_activate_folio**(folio); 462 **folio_clear_referenced**(folio); 463 **workingset_activation**(folio); 464 }

465 **if** (**folio_test_idle**(folio)) 466 **folio_clear_idle**(folio); 467 }

 

*Listing 11-11:* mm/swap.c: [*folio_mark_accessed()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441)

This follows the logic described above, activating the folio via

[folio_activate(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n388)or if it is on a batch, via [\_\_lru_cache_activate_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n401) which

goes through each entry on the appropriate lruvec and tries to find the folio

there to activate (both discussed later in section 11.7.6).

Finally, working set activation is noted (though out of scope for the

book), and if the folio was marked idle, we clear that flag.

 

***11.2.1 struct lruvec***

The data structure which encapsulates all of this is [struct lruvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317). A folio’s

lruvec can be obtained via [folio_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n763)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n763) which obtains a folio’s memcg via

[folio_memcg()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n451) (ultimately determined from either the memcg_data field of the

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) if it sits in a specific memcg, or the [root_mem_cgroup](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memcontrol.c?h=v6.0#n79) global if none

is set). This ultimately invokes [mem_cgroup_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n730) which looks up the node-

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

specific lruvec (the node having been obtained via [folio_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1436) which ul-

timately invokes [page_to_nid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1244) extracting the node ID from the folio’s flags field).

Examining the data structure:-

 

317 **struct** lruvec {

318 **struct** list_head lists\[**NR_LRU_LISTS**\]; 319 */\* per lruvec lru_lock for memcg \*/* 320 **spinlock_t** lru_lock; 321 */\**

322 *\* These track the cost of reclaiming one LRU - file or anon -*323 *\* over the other. As the observed cost of reclaiming one LRU* 324 *\* increases, the reclaim scan balance tips toward the other.* 325 *\*/*

326 **unsigned long** anon_cost; 327 **unsigned long** file_cost; 328 */\* Non-resident age, driven by LRU movement \*/* 329 **atomic_long_t** nonresident_age; 330 */\* Refaults at the time of last reclaim cycle \*/* 331 **unsigned long** refaults\[**ANON_AND_FILE**\]; 332 */\* Various lruvec state flags (enum lruvec_flags) \*/* 333 **unsigned long** flags; 334 **\#ifdef CONFIG_MEMCG**

335 **struct** pglist_data \*pgdat; 336 **\#endif**

337 };

 

*Listing 11-12:* include/linux/mmzone.h: [*struct lruvec*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317)

 

Examining each field individually:-

 

• lists\[\] – This contains the head of each of the aforementioned LRU

lists, with each index in the array defined in [enum lru_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n278)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n278)

**–** LRU_INACTIVE_ANON – The inactive anonymous folio LRU list. **–** LRU_ACTIVE_ANON – The active anonymous folio LRU list. **–** LRU_INACTIVE_FILE – The inactive file folio LRU list. **–** LRU_ACTIVE_FILE – The active file folio LRU list. **–** LRU_UNEVICTABLE – A placeholder for unevictable folios, however there

is no actual list associated with these. The list head is poisoned to

avoid inappropriate access in [lruvec_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmzone.c?h=v6.0#n75).

• lru_lock – Lock which protects fields in the struct lru_vec object,

typically locked via [folio_lruvec_lock_irqsave()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memcontrol.c?h=v6.0#n1269) and unlocked via

[unlock_page_lruvec_irqrestore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n1604).

• anon_cost – Used to track the cost of reclaiming the anon LRU over the

file LRU. This allows the reclaim scan to maintain balance between the

two. Set via [lru_note_cost()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n298) and [lru_note_cost_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n338). See Section 11.5 for details.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

• file_cost – Used to track the cost of reclaiming the file LRU over the

anon LRU. Again, see Section 11.5 for more details.

• nonresident_age – A counter of inactive evictions and activations used by

the working set logic, which is out of scope of the book. Incremented by

[workingset_age_nonresident()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/workingset.c?h=v6.0#n229).

• refaults\[\] – Keeps track of the number of refaults, i.e. times folios have

been evicted then faulted back in. Used as part of the working set logic.

• flags – Contains flags relevant to the lruvec as defined in

[enum lruvec_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n312). Currently only one flag is specified – [LRUVEC_CONGESTED.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n312) This is used by reclaim to note a situation where there are a large num-ber of dirty file folios which are deemed to have become congested (dirty meaning file-back folios which have been modified but not yet written back to disk).

• pgdat – Reference to this node’s [pg_data_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) metadata object. This is typi-

cally retrieved via [lruvec_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1060)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1060)

 

***11.2.2 lruvec Operations***

We now have a picture of what lruvec lists are and how folios move around

in them, but how are they added to, removed from and moved between LRU

lists?

Folios are ultimately added to an lruvec by either [lruvec_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98) or

[lruvec_add_folio_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n115) and removed by [lruvec_del_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n132) (with the very spe-

cial exception of reclaim’s [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138), discussed later):-

 

97 **static \_\_always_inline**

98 **void lruvec_add_folio**(**struct** lruvec \*lruvec, **struct** folio \*folio)

99 {

100 **enum** lru_list lru = **folio_lru_list**(folio);

101

102 **update_lru_size**(lruvec, lru, **folio_zonenum**(folio), 103 **folio_nr_pages**(folio)); 104 **if** (lru != **LRU_UNEVICTABLE**) 105 **list_add**(&folio-\>lru, &lruvec-\>lists\[lru\]); 106 }

 

*Listing 11-13:* include/linux/mm_inline.h: [*lruvec_add_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98)

 

114 **static \_\_always_inline**

115 **void lruvec_add_folio_tail**(**struct** lruvec \*lruvec, **struct** folio \*folio) 116 {

117 **enum** lru_list lru = **folio_lru_list**(folio);

118

119 **update_lru_size**(lruvec, lru, **folio_zonenum**(folio), 120 **folio_nr_pages**(folio)); 121 */\* This is not expected to be used on LRU_UNEVICTABLE \*/* 122 **list_add_tail**(&folio-\>lru, &lruvec-\>lists\[lru\]);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

123 }

 

*Listing 11-14:* include/linux/mm_inline.h: [*lruvec_add_folio_tail()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n115)

 

131 **static \_\_always_inline**

132 **void lruvec_del_folio**(**struct** lruvec \*lruvec, **struct** folio \*folio) 133 {

134 **enum** lru_list lru = **folio_lru_list**(folio); 135

136 **if** (lru != **LRU_UNEVICTABLE**) 137 **list_del**(&folio-\>lru); 138 **update_lru_size**(lruvec, lru, **folio_zonenum**(folio), 139 -**folio_nr_pages**(folio)); 140 }

 

*Listing 11-15:* include/linux/mm_inline.h: [*lruvec_del_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n132)

 

Each of these use [folio_lru_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n81) to determine which LRU list a particu-

lar folio should be assigned to:-

 

74 */\*\**

75 *\* folio_lru_list - Which LRU list should a folio be on?* 76 *\* @folio: The folio to test.* 77 *\**

78 *\* Return: The LRU list a folio should be on, as an index* 79 *\* into the array of LRU lists.* 80 *\*/*

81 **static \_\_always_inline enum** lru_list **folio_lru_list**(**struct** folio \*folio) 82 {

83 **enum** lru_list lru; 84

85 **VM_BUG_ON_FOLIO**(**folio_test_active**(folio) && **folio_test_unevictable**(

folio), folio);

86

87 **if** (**folio_test_unevictable**(folio)) 88 **return LRU_UNEVICTABLE**; 89

90 lru = **folio_is_file_lru**(folio) ? **LRU_INACTIVE_FILE** : **LRU_INACTIVE_ANON**

;

91 **if** (**folio_test_active**(folio)) 92 lru += **LRU_ACTIVE**; 93

94 **return** lru;

95 }

 

*Listing 11-16:* include/linux/mm_inline.h: [*folio_lru_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n81)

 

Everything is predicated on [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) flags, tested via folio_test_xxx()

(see chapter 2 on physical memory for details on how these function):-

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

• folio_test_active() – Testing whether the PG_active flag is set – When

folios ought to be activated (or remain activated) this folio flag is set. If unset then the folio should exist on an inactive list. It is an error if both this and the PG_unevictable flag is set.

• folio_test_unevictable() – Testing whether the PG_unevictable flag is set

– If a LRU-inhabiting user-mapped folio that should never be evicted

then this folio flag is set, e.g. when mlocking folios in [\_\_mlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n61) or

[\_\_mlock_new_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n103) or if the folio has the PG_mlocked flag set or otherwise

has its mapping marked unevictable as tested by [folio_evictable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n130).

• [folio_is_file_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n27) – Testing whether the PG_swapbacked flag is not set –

This function determines whether the folio should be placed on a file LRU or not. If the PG_swapbacked folio flag is set, indicating that there is a swap backing cache available for the folio (and thus it could be swapped out) then it is considered anonymous, otherwise it is considered a file mapping and should be placed on a file LRU.

 

Note that the [enum lru_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n278) type is designed such that you can shift be-

tween inactive and active LRUs by simply adding [LRU_ACTIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n275) to the value.

When folios are moved between lists they are removed from one and

added to another using these fundamental functions, except for the special

case of [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) which performs the move directly (see below for

more).

What invokes these functions? The principal interface is via folio batches

(otherwise known as pagevecs), which batch up folios for placing on or re-

moving from the LRU lists. As this is an important topic in of itself, we will

discuss them in detail in the following section.

Meanwhile, let’s examine the non-folio batch functions which interact

with [lruvec_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98) [lruvec_add_folio_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n115) and [lruvec_del_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n132)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n132)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Compaction Function

 

[isolate_migratepages_block()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n788)

 

Isolation Functions

 

[del_page_from_lru_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n142) [isolate_lru_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n132)

 

[lruvec_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98) [lruvec_del_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n132) [folio_isolate_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2254)

 

[move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323) [check_move_unevictable_folios()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4881) [release_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n934) [\_\_page_cache_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n80)

 

Folio Free Functions

[isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138)

 

Reclaim Functions

 

*Figure 11-8: Non-batched LRU functions*

 

Note that lruvec_add_folio_tail() is not referenced by a non-batch

method at all.

There are two legacy non-folio functions [add_page_to_lru_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n108) and

[del_page_from_lru_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n142) which simply wrap the relevant folio functions lruvec_add_folio() and lruvec_del_folio() respectively. Importantly, both of these assume lru_lock is held (only lruvec_del_folio() is used for non-batched LRU operations).

Examining each of the different groups of functions by type:-

 

• compaction functions – [isolate_migratepages_block()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n788) works similarly to the

isolation functions, however specifically targeting a page block of folios and isolating all of those contained within which are migrate-able. See the below discussion of the isolation function for more on what isolation means in this context, and the compaction chapter for more on com-paction generally.

• reclaim functions – The key outlier of these functions is

[isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) because it interacts with lruvec lists directly. This is special in that it is a key hot path for reclaim and the principal func-tion for moving folios from lruvecs to internal reclaim lists, which are then used to perform the reclaim operations, invoked by both

[shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402) and [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509). It is assumed the lruvec is held when it is called. The other reclaim functions which interact with

lruvecs are [move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323) and [check_move_unevictable_folios()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4881) which both use the core lruvec\_\*\_folio() functions to perform their actions.

• folio free functions – When folios are physically released (at the point

their reference count reaches zero, tested via [put_page_testzero()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n721) they need to be removed from the lruvec if they are on one. This

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

is achieved via either [release_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n934) or [\_\_page_cache_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n80)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n80) This will either occur on the folio batch/pagevec code path (ultimately

by [folio_batch_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n133) or [pagevec_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n68) which ultimately invoke

release_pages(), or via the [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122) or [put_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1167) code path which ulti-mately invoke \_\_page_cache_release(). See chapter 2 on physical memory and figure 2.24 for more details.

• isolation functions – A fairly typical approach when operating on

lruvec folios is to first isolate them from the lruvec before performing

the required operations. This is achieved via [folio_isolate_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2254) or

[isolate_lru_page() . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n132)They ultimately invoke [lruvec_del_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n132) to pull the folio from its lruvec.

 

Note that the majority of operations discussed above remove folios from

lruvecs. The reclaim operations when ‘adding’ folios to a list are actually sim-

ply updating stats on unevictable folios. Isolation and folio freeing are all

about removing folios and at best reclaim might move folios from one list to

another, when not removing on reclaim.

The majority of operations where folios are added to lruvecs are per-

formed using folio batches, discussed in Section 11.7.

 

**11.3 Direct Reclaim**

 

Direct reclaim arises when the minimum watermark is breached for all zones

an allocation could arise in. At this point the process blocks until reclaim

frees sufficient pages in order that the minimum watermark of the zone into

which we wish to allocate is no longer breached.

As [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) loops while progress is being made through-

out direct reclaim, we simply have to try to make some reasonable progress

on each invocation of [\_\_alloc_pages_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763) (see Listing 11-17).

We examine the direct reclaim call stack in Figure 11-9.

 

[\_\_alloc_pages_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763) [kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4469)

 

[\_\_perform_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4737) [balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146)

 

[try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3801) [kswapd_shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4066)

 

[do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3583)

 

[shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3463)

 

[shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)

 

*Figure 11-9: Direct Reclaim Code Path*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

As shown in Figure 11-9, direct reclaim is invoked via the

[\_\_alloc_pages_direct_reclaim(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763)called from [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) as shown

in Listing 11-1 and Section 11.1.

We examine [\_\_alloc_pages_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763) in Listing 11-17 (eliding out of

scope PSI memory pressure tracking).

 

4761 */\* The really slow allocator path where we enter direct reclaim \*/* 4762 **static inline struct** page \* 4763 **\_\_alloc_pages_direct_reclaim**(**gfp_t** gfp_mask, **unsigned int** order, 4764 **unsigned int** alloc_flags, **const struct** alloc_context \*ac, 4765 **unsigned long** \*did_some_progress) 4766 {

4767 **struct** page \*page = **NULL**;

. . .

4769 **bool** drained = **false**;

. . .

4772 \*did_some_progress = **\_\_perform_reclaim**(gfp_mask, order, ac); 4773 **if** (**unlikely**(!(\*did_some_progress))) 4774 **goto out**; 4775

4776 **retry**:

4777 page = **get_page_from_freelist**(gfp_mask, order, alloc_flags, ac); 4778

4779 */\**

4780 *\* If an allocation failed after direct reclaim, it could be because*

4781 *\* pages are pinned on the per-cpu lists or in high alloc reserves.*

4782 *\* Shrink them and try again* 4783 *\*/*

4784 **if** (!page && !drained) { 4785 **unreserve_highatomic_pageblock**(ac, **false**); 4786 **drain_all_pages**(**NULL**); 4787 drained = **true**; 4788 **goto retry**; 4789 }

4790 **out**:

. . .

4793 **return** page;

4794 }

 

*Listing 11-17:* mm/page_alloc.c: [*\_\_alloc_pages_direct_reclaim()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763)

 

We start [\_\_alloc_pages_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763) by deferring the actual reclaim

to [\_\_perform_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4737) (see Listing 11-18), a function which returns a value indicating whether progress was made. If none was, we simply exit returning NULL .

Otherwise, we try to complete the allocation—if this succeeds, we return

this page via [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) (see Listing 2-55 in Section 2.8.2 and

## Chapter 2).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

If this fails, we try to unreserve the reserved high atomic page block. This

is a page block (i.e. a physically contiguous folio of size [pageblock_order](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n44) re-

served to assist with higher-order allocations in atomic context, which is a

context in which a kernel process cannot sleep).

If we need to take this action, then we subsequently invoke

[drain_all_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3315) to also ensure that all Per-CPU Pages are drained to free

lists (see Section 2.7.3 in Chapter 2 for more details on these).

At this point we have done all we can, so we try this only once before

retrying the [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) operation. If this fails, we exit report-

ing failure.

Having deferred the heavy lifting of the operation to [\_\_perform_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4737)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4737)

we now examine this in Listing 11-18 (eliding out of scope CPU set, lockdep

and realtime scheduler logic).

 

4735 */\* Perform direct synchronous page reclaim \*/* 4736 **static unsigned long**

4737 **\_\_perform_reclaim**(**gfp_t** gfp_mask, **unsigned int** order, 4738 **const struct** alloc_context \*ac) 4739 {

4740 **unsigned int** noreclaim_flag; 4741 **unsigned long** progress;

. . .

4745 */\* We now go into synchronous reclaim \*/*

. . .

4748 noreclaim_flag = **memalloc_noreclaim_save**(); 4749

4750 progress = **try_to_free_pages**(ac-\>zonelist, order, gfp_mask, 4751 ac-\>nodemask);

4752

4753 **memalloc_noreclaim_restore**(noreclaim_flag);

. . .

4758 **return** progress;

4759 }

 

*Listing 11-18:* mm/page_alloc.c: [*\_\_perform_reclaim()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4737)

 

The [\_\_perform_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4737) function ultimately wraps [try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3801),

but in addition it invokes [memalloc_noreclaim_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n339) and

[memalloc_noreclaim_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n346) which set (and clear if not previously set)

the [PF_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713) flag in the current thread’s [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)-\>flags field.

See Section 2.6.7 in Chapter 2 for more on memalloc flags, but broadly

these are per-task (i.e. from userland’s perspective, per-thread) flags which

affect memory allocation globally until unset.

The [PF_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713) flag avoids recursive reclaim occurring when allocating

memory as part of performing reclaim (which could otherwise have resulted

in races or reclaim becoming stuck), as checked in [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015)

and [\_\_need_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4656).

It also results in all watermarks being ignored in the process of providing

any allocations reclaim needs as checked by [\_\_gfp_pfmemalloc_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4876)..

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We wrap the [try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3801) function here, which we examine in List-

ing 11-19 (eliding build bug checks and trace hooks).

 

3801 **unsigned long try_to_free_pages**(**struct** zonelist \*zonelist, **int** order, 3802 **gfp_t** gfp_mask, **nodemask_t** \*nodemask) 3803 {

3804 **unsigned long** nr_reclaimed; 3805 **struct** scan_control sc = { 3806 .nr_to_reclaim = **SWAP_CLUSTER_MAX**, 3807 .gfp_mask = **current_gfp_context**(gfp_mask), 3808 .reclaim_idx = **gfp_zone**(gfp_mask), 3809 .order = order, 3810 .nodemask = nodemask, 3811 .priority = **DEF_PRIORITY**, 3812 .may_writepage = !**laptop_mode**, 3813 .may_unmap = 1, 3814 .may_swap = 1, 3815 };

. . .

3825 */\**

3826 *\* Do not enter reclaim if fatal signal was delivered while throttled.*

3827 *\* 1 is returned so that the page allocator does not OOM kill at this*

3828 *\* point.*

3829 *\*/*

3830 **if** (**throttle_direct_reclaim**(sc.gfp_mask, zonelist, nodemask)) 3831 **return** 1; 3832

3833 **set_task_reclaim_state**(current, &sc.reclaim_state);

. . .

3836 nr_reclaimed = **do_try_to_free_pages**(zonelist, &sc);

. . .

3839 **set_task_reclaim_state**(current, **NULL**); 3840

3841 **return** nr_reclaimed; 3842 }

 

*Listing 11-19:* mm/vmscan.c: [*try_to_free_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3801)

 

We start by establishing a [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) object which we thread

through the reclaim operation. We examine this in Listing 11-36 and Sec-

tion 11.5.

Here we set the number of pages to reclaim equal to [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214)

which is equal to the batch size of pages written to a file-system swap file, and thus forms a natural batch size across reclaim operations (see Section

12.2.3 and Chapter 12 to see how swap write to disk functions).

We indicate that we may unmap memory and swap when reclaiming, and

whether or not we may write out dirty folios to disk is dictated by whether “laptop mode” is enabled. In this mode, reclaim attempts to avoid writing to

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

disk as much as possible in order to avoid power-hungry rotational disk spin

up (less relevant in the modern era of SSDs).

Therefore, if laptop mode is enabled, we prefer not to write to disk other-

wise we do not try to reduce this.

In addition we set the “priority” of the operation to [DEF_PRIORITY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838) This

value determines how much of the LRU vectors should be examined (see

Section 11.2), expressed as a shift value, and defaulting to 12.

 

**N O T E** The priority value specifies how much the queue length should be right-shifted, so if

it is equal to *12* to instance, this implies that the queue will be bit-shifted by 12 bits

to the right. This is equivalent to dividing by *4,096*, meaning we scan one-*4,096*th of

the LRU vectors for folios to free. As this reduces, we scan more of the lists.

 

We maintain a priority so reclaim does as little work as possible in order

to effect reclaim, only reluctantly scanning more pages if lower priorities

(that is, higher priority values resulting in fewer pages scanned) fail to pro-

vide us with sufficient reclaim.

We determine if we should throttle direct reclaim via the

[throttle_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3721) function, which we examine in Listing 11-77. If so,

we exit, returning one indicating that forward progress has been made and

[\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) is permitted to loop around and try the allocation

again, engaging in direct reclaim if necessary.

Otherwise, we assign a pointer to a state object describing reclaim state

to the current thread via [set_task_reclaim_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n183) before performing the op-

eration via [do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3583) which we examine in Listing 11-20 (elid-

ing out of scope delay accounting, cgroup logic, and working set logic and a

statistic update).

 

3567 */\**

3568 *\* This is the main entry point to direct page reclaim.* 3569 *\**

3570 *\* If a full scan of the inactive list fails to free enough memory then we*

3571 *\* are "out of memory" and something needs to be killed.* 3572 *\**

3573 *\* If the caller is !\_\_GFP_FS then the probability of a failure is reasonably*

3574 *\* high - the zone may be full of dirty or under-writeback pages, which this*

3575 *\* caller can't do much about. We kick the writeback threads and take*

*explicit*

3576 *\* naps in the hope that some of these pages can be written. But if the* 3577 *\* allocating task holds filesystem locks which prevent writeout this might*

*not*

3578 *\* work, and the allocation attempt will fail.* 3579 *\**

3580 *\* returns:* *0, if no pages reclaimed* 3581 *\** *else, the number of pages reclaimed* 3582 *\*/*

3583 **static unsigned long do_try_to_free_pages**(**struct** zonelist \*zonelist, 3584 **struct** scan_control \*sc)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3585 {

3586 **int** initial_priority = sc-\>priority;

. . .

3588 **struct** zoneref \*z; 3589 **struct** zone \*zone; 3590 **retry**:

. . .

3596 **do** {

. . .

3600 sc-\>nr_scanned = 0; 3601 **shrink_zones**(zonelist, sc); 3602

3603 **if** (sc-\>nr_reclaimed \>= sc-\>nr_to_reclaim) 3604 **break**; 3605

3606 **if** (sc-\>compaction_ready) 3607 **break**; 3608

3609 */\**

3610 *\* If we're getting trouble reclaiming, start doing* 3611 *\* writepage even in laptop mode.* 3612 *\*/*

3613 **if** (sc-\>priority \< **DEF_PRIORITY**- 2) 3614 sc-\>may_writepage = 1; 3615 } **while** (--sc-\>priority \>= 0); 3616

3617 last_pgdat = **NULL**; 3618 **for_each_zone_zonelist_nodemask**(zone, z, zonelist, sc-\>reclaim_idx, 3619 sc-\>nodemask) { 3620 **if** (zone-\>zone_pgdat == last_pgdat) 3621 **continue**; 3622 last_pgdat = zone-\>zone_pgdat; 3623

3624 **snapshot_refaults**(sc-\>target_mem_cgroup, zone-\>zone_pgdat);

. . .

3633 }

3634

3635 **if** (sc-\>nr_reclaimed) 3636 **return** sc-\>nr_reclaimed; 3637

3638 */\* Aborted reclaim to try compaction? don't OOM, then \*/* 3639 **if** (sc-\>compaction_ready) 3640 **return** 1; 3641

3642 */\**

3643 *\* We make inactive:active ratio decisions based on the node's* 3644 *\* composition of memory, but a restrictive reclaim_idx or a*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3645 *\* memory.low cgroup setting can exempt large amounts of* 3646 *\* memory from reclaim. Neither of which are very common, so* 3647 *\* instead of doing costly eligibility calculations of the* 3648 *\* entire cgroup subtree up front, we assume the estimates are* 3649 *\* good, and retry with forcible deactivation if that fails.* 3650 *\*/*

3651 **if** (sc-\>skipped_deactivate) { 3652 sc-\>priority = initial_priority; 3653 sc-\>force_deactivate = 1; 3654 sc-\>skipped_deactivate = 0; 3655 **goto retry**; 3656 }

. . .

3669 **return** 0;

3670 }

 

*Listing 11-20:* mm/vmscan.c: [*do_try_to_free_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3801)

 

In [do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3583) we repeatedly try to free [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214) pages

as we iterate downwards through priority (See the discussion around List-

ing 11-19 for a definition of reclaim priority), deferring to [shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3601) to

perform the actual reclaim operation on each occasion (see Listing 11-21).

If the number of folios reclaimed is equal to or exceeds the number re-

quested to be reclaimed (that is, [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214)), then we have successfully

completed reclaim, and exit the loop.

Otherwise, if the [struct scan_control-\>compaction_ready](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) field is set by

[shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3601), this indicates that we ought to abort reclaim to attempt to

compact memory.

See Listing 11-36 and Section 11.5 for a detailed examination of the

[struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) type.

Compaction is out of scope for the book, but broadly it obtains more

higher order folios by moving folios such that adjacent lower order folios

can be coalesced.

If we loop sufficient times that [struct scan_control-\>priority](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) drops three

or more levels below [DEF_PRIORITY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838) then this indicates we are having trouble

reclaiming memory, and thus we should permit dirty folio writeback even if

laptop mode is enabled.

After the loop is completed, we iterate through each node from which

we could allocate, and for each invoke [snapshot_refaults()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3556) (see Listing 11-38)

which stores the current statistics for “refaults” for this node. See Section

11.5.2 and the discussion around Listing 11-41 for an explanation as to how

this is used.

Then we check to see if any pages were reclaimed, returning if any were—

at this point we have tried to reclaim as much as we possibly can so however

many pages we have managed has to suffice.

Otherwise, we repeat our compaction check to ensure we don’t incor-

rectly indicate that reclaim failed when we are simply aborting it to try com-

paction.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

After this, we consider one more case, where we skipped deactivating

active folios (that is, moving them from the active LRU vector to the inactive one). If so, given reclaim has yielded nothing, it is worth forcing the matter and trying this regardless and retrying the operation on that basis.

We examine the key [shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3463) function which [do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3583)

invokes in Listing 11-21 (eliding out of scope cgroup and 32-bit architecture-specific logic).

 

3455 */\**

3456 *\* This is the direct reclaim path, for page-allocating processes. We only*

3457 *\* try to reclaim pages from zones which will satisfy the caller's allocation*

3458 *\* request.*

3459 *\**

3460 *\* If a zone is deemed to be full of pinned pages then just give it a light*

3461 *\* scan then give up on it.* 3462 *\*/*

3463 **static void shrink_zones**(**struct** zonelist \*zonelist, **struct** scan_control \*sc) 3464 {

3465 **struct** zoneref \*z; 3466 **struct** zone \*zone; 3467 **unsigned long** nr_soft_reclaimed; 3468 **unsigned long** nr_soft_scanned;

. . .

3470 **pg_data_t** \*last_pgdat = **NULL**; 3471 **pg_data_t** \*first_pgdat = **NULL**;

. . .

3484 **for_each_zone_zonelist_nodemask**(zone, z, zonelist, 3485 sc-\>reclaim_idx, sc-\>nodemask) {

. . .

3495 */\** 3496 *\* If we already have plenty of memory free for* 3497 *\* compaction in this zone, don't free any more.* 3498 *\* Even though compaction is invoked for any* 3499 *\* non-zero order, only frequent costly order* 3500 *\* reclamation is disruptive enough to become a* 3501 *\* noticeable problem, like transparent huge* 3502 *\* page allocations.* 3503 *\*/* 3504 **if** (**IS_ENABLED**(**CONFIG_COMPACTION**) && 3505 sc-\>order \> **PAGE_ALLOC_COSTLY_ORDER** && 3506 **compaction_ready**(zone, sc)) { 3507 sc-\>**compaction_ready** = **true**; 3508 **continue**; 3509 } 3510

3511 */\** 3512 *\* Shrink each node in the zonelist once. If the*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3513 *\* zonelist is ordered by zone (not the default) then*

*a*

3514 *\* node may be shrunk multiple times but in that case*

3515 *\* the user prefers lower zones being preserved.* 3516 *\*/* 3517 **if** (zone-\>zone_pgdat == last_pgdat) 3518 **continue**;

. . .

3545 **if** (!first_pgdat) 3546 first_pgdat = zone-\>zone_pgdat;

. . .

3551 last_pgdat = zone-\>zone_pgdat; 3552 **shrink_node**(zone-\>zone_pgdat, sc); 3553 }

. . .

3555 **if** (first_pgdat)

3556 **consider_reclaim_throttle**(first_pgdat, sc);

. . .

3553 }

 

*Listing 11-21:* mm/vmscan.c: [*shrink_zones()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3463)

 

In [shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3463) we iterate through each zone that we could al-

locate from, checking to see whether we are able to compact in in-

stances where the order of the folio being allocated could benefit from

this (i.e. greater than [PAGE_ALLOC_COSTLY_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40)), before marking the

[struct scan_control-\>compaction_ready](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) field to indicate to calling functions that

compaction should be attempted in lieu of reclaim, continuing the loop to

examine the next zone.

We actually perform the reclaim per-node, so when we find a zone which

is eligible for reclaim, we will only instigate reclaim if it is a node different

from the previous.

As the comment alludes to, the zone list ordering means this will usu-

ally result in each node being considered once, though if the zonelist order-

ing has changed, this could result in nodes being shrunk multiple times—

however if the zonelist has been thus altered, this should align with user re-

quirements (see Section 2.4 for more on nodes, zones and zonelists).

We ultimately invoke [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) to perform the reclaim. This is the

core reclaim path shared by both direct and indirect reclaim and thus we

examine this in Section 11.5 and Listing 11-40.

For the first node we encounter in each iteration, we also

determine whether reclaim throttle should be performed via

[consider_reclaim_throttle() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3425)a subject we address in Section 11.6, examining

this function in Listing 11-74.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**11.4 Indirect Reclaim**

 

Indirect reclaim is reclaim that is performed as a background task and is im-plemented using a per-node kernel thread which waits to be woken when the need arises (for instance, when an allocation causes a zone to drop below the

low water mark in [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) see the portion of this function

described in Listing 11-2).

These indirect reclaim processes are also known as kswapd, and are named

accordingly, suffixed by the number of the node which they perform re-claim for (for instance if a kswapd thread reclaims on node 0, it will appear as \[kswapd0\]).

We can see the code path through which indirect reclaim operates in Fig-

ure 11-10, which starts in the [kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4469) function (see Listing 11-26) executed

in a kernel thread as described in Section 11.4.2.

We will examine how this kernel thread is initialised and executed in Sec-

tion 11.4.1.

 

[\_\_alloc_pages_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4763) [kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4469)

 

[\_\_perform_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4737) [balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146)

 

[try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3801) [kswapd_shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4066)

 

[do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3583)

 

[shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3463)

 

[shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)

 

*Figure 11-10: Indirect Reclaim Code Path*

 

***11.4.1 Initialisation***

The kernel threads are initialised in [kswapd_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4672)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4672) which we examine in List-

ing 11-22.

 

4672 **static int \_\_init kswapd_init**(**void**) 4673 {

4674 **int** nid;

4675

4676 **swap_setup**();

4677 **for_each_node_state**(nid, **N_MEMORY**) 4678 **kswapd_run**(nid); 4679 **return** 0;

4680 }

 

*Listing 11-22:* mm/vmscan.c: [*kswapd_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4672)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

The [kswapd_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4672) function initialises the swap via [swap_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n1071) (see Listing

12-46 in Section 12.3.4 and Chapter 12) and then iterates through all nodes

which have memory attached, running [kswapd_run()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4642) against each, which we

examine in Listing 11-23.

 

4642 **void kswapd_run**(**int** nid)

4643 {

4644 **pg_data_t** \*pgdat = **NODE_DATA**(nid); 4645

4646 **if** (pgdat-\>**kswapd**) 4647 **return**;

4648

4649 pgdat-\>**kswapd** = **kthread_run**(**kswapd**, pgdat, "**kswapd**%d", nid); 4650 **if** (**IS_ERR**(pgdat-\>**kswapd**)) { 4651 */\* failure at boot is fatal \*/* 4652 **BUG_ON**(**system_state** \< **SYSTEM_RUNNING**); 4653 **pr_err**("Failed to start **kswapd** on node %d\n", nid); 4654 pgdat-\>**kswapd** = **NULL**; 4655 }

4656 }

 

*Listing 11-23:* mm/vmscan.c: [*kswapd_run()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4642)

 

The [kswapd_run()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4642) function causes [kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4469) to be invoked as a kernel

thread, placing the kernel thread task of type [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) in the node’s

[struct pglist_data-\>kswapd](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) field.

If this fails at boot when this is initialises then we cause a kernel oops,

which will lead to the kernel failing to boot altogether. This function might

also be invoked during a hot plugging operation, but discussion of this is out

of scope for the book.

Typically the kswapd process is woken by the [wake_all_kswapds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4796) function,

and this is what [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) (see Listing 11-2) invokes to wake

indirect reclaim when a zone drops below the low watermark. We examine

this function in Listing 11-24.

 

4796 **static void wake_all_kswapds**(**unsigned int** order, **gfp_t** gfp_mask, 4797 **const struct** alloc_context \*ac) 4798 {

4799 **struct** zoneref \*z; 4800 **struct** zone \*zone; 4801 **pg_data_t** \*last_pgdat = **NULL**; 4802 **enum** zone_type highest_zoneidx = ac-\>highest_zoneidx; 4803

4804 **for_each_zone_zonelist_nodemask**(zone, z, ac-\>zonelist, highest_zoneidx

,

4805 ac-\>nodemask) { 4806 **if** (!**managed_zone**(zone)) 4807 **continue**; 4808 **if** (last_pgdat != zone-\>zone_pgdat) {

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4809 **wakeup_kswapd**(zone, gfp_mask, order, highest_zoneidx); 4810 last_pgdat = zone-\>zone_pgdat; 4811 }

4812 }

4813 }

 

*Listing 11-24:* mm/page_alloc.c: [*wake_all_kswapds()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4796)

 

We iterate through each zone which the allocation could make use of,

using [managed_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1098) to ensure that each has pages within its ranged managed

by the buddy allocator, and calling [wakeup_kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4555) for each of these node.

We examine this function in Listing 11-25 (eliding out of scope cgroup logic and tracing hooks).

 

4555 **void wakeup_kswapd**(**struct** zone \*zone, **gfp_t** gfp_flags, **int** order, 4556 **enum** zone_type highest_zoneidx) 4557 {

4558 **pg_data_t** \*pgdat; 4559 **enum** zone_type curr_idx; 4560

4561 **if** (!**managed_zone**(zone)) 4562 **return**;

. . .

4567 pgdat = zone-\>zone_pgdat; 4568 curr_idx = **READ_ONCE**(pgdat-\>kswapd_highest_zoneidx); 4569

4570 **if** (curr_idx == **MAX_NR_ZONES** \|\| curr_idx \< highest_zoneidx) 4571 **WRITE_ONCE**(pgdat-\>kswapd_highest_zoneidx, highest_zoneidx); 4572

4573 **if** (**READ_ONCE**(pgdat-\>kswapd_order) \< order) 4574 **WRITE_ONCE**(pgdat-\>kswapd_order, order); 4575

4576 **if** (!**waitqueue_active**(&pgdat-\>kswapd_wait)) 4577 **return**;

4578

4579 */\* Hopeless node, leave it to direct reclaim if possible \*/* 4580 **if** (pgdat-\>kswapd_failures \>= **MAX_RECLAIM_RETRIES** \|\| 4581 (**pgdat_balanced**(pgdat, order, highest_zoneidx) && 4582 !**pgdat_watermark_boosted**(pgdat, highest_zoneidx))) { 4583 */\**

4584 *\* There may be plenty of free memory available, but it's too*

4585 *\* fragmented for high-order allocations. Wake up kcompactd*

4586 *\* and rely on compaction_suitable() to determine if it's* 4587 *\* needed. If it fails, it will defer subsequent attempts to*

4588 *\* ratelimit its work.* 4589 *\*/*

4590 **if** (!(gfp_flags & **\_\_GFP_DIRECT_RECLAIM**)) 4591 **wakeup_kcompactd**(pgdat, order, highest_zoneidx); 4592 **return**;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4593 }

. . .

4597 **wake_up_interruptible**(&pgdat-\>kswapd_wait); 4598 }

 

*Listing 11-25:* mm/vmscan.c: [*wakeup_kswapd()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4555)

The [wakeup_kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4555) function starts by asserting again that the zone spans

buddy allocator-managed pages (see Section 2.4 in Chapter 2 for more on

nodes and zones) via [managed_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1098)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1098)

It then updates various node statistics in the [struct pglist_data](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) metadata

object describing the node (type aliased as [pg_data_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1015)).

We store the highest zone in terms of zone index we have submitted to

indirect reclaim in [struct pglist_data-\>kswapd_highest_zoneidx](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) and the highest

order in [struct pglist_data-\>order](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905).

We then check to see if the [struct pglist_data-\>kswapd_wait](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) wait queue is

currently active, i.e. whether kswapd is sleeping waiting to be woken up. If

not, then we have no capacity to wake the indirect reclaim thread so abort.

Wait queues are a means by which the kernel allows for threads to wait

for certain events to occur, in this instance kswapd waits to be woken up.

We then consider an edge case—we keep track of the number of times

kswapd has failed to reclaim memory in [struct pglist_data-\>kswapd_failures](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905).

Once this reaches or exceeds [MAX_RECLAIM_RETRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n170) (hard-coded to 16 at-

tempts), then further attempts at indirect reclaim are likely to fruitless and

we need to leave the node to direct reclaim rather than indirect.

In addition we consider the case where a node is balanced, i.e. has

reached or exceeded its high water mark and in addition is not subject to

a zone boost (see Section 2.4 in Chapter 2 for more on nodes, zone and zone

boost).

In this case, we should not be in a position where kswapd was invoked. If

we still were, either the wakeup was spurious, or indirect reclaim is unable to

resolve the issue, so we must abort the indirect reclaim attempt.

If direct reclaim is not permitted for this allocation, as indicated by the

lack of [\_\_GFP_DIRECT_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n216) flag in the specified Get Free Pages (GFP) flag

mask (see Section 2.6 in Chapter 2 for more on GFP flags), then we attempt

to wake up the compaction process, kcompactd to perform compaction.

Compaction is a process by which the kernel moves memory around to

allow for the coalescence of lower order folios in to higher order folios in

order to provide higher order folios for allocation. This topic is out of scope

for the book.

Finally, if nothing is preventing indirect reclaim from commencing, we

wake it up.

 

***11.4.2 kswapd Thread***

The [kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4469) function (see Listing 11-26) implements the indirect reclaim

implementation, this is what the kswapd kernel thread runs for each node.

We can see in Figure 11-10 how this triggers reclaim, ultimately invoking the

core reclaim function [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40 in Section 11.5).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We examine the indirect reclaim kernel thread function [kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4469) in List-

ing 11-26 (eliding out of scope task freezing logic and trace hooks).

 

4456 */\**

4457 *\* The background pageout daemon, started as a kernel thread* 4458 *\* from the init process.* 4459 *\**

4460 *\* This basically trickles out pages so that we have \_some\_* 4461 *\* free memory available even if there is no other activity* 4462 *\* that frees anything up. This is needed for things like routing* 4463 *\* etc, where we otherwise might have all activity going on in* 4464 *\* asynchronous contexts that cannot page things out.* 4465 *\**

4466 *\* If there are applications that are active memory-allocators* 4467 *\* (most normal use), this basically shouldn't matter.* 4468 *\*/*

4469 **static int kswapd**(**void** \*p) 4470 {

4471 **unsigned int** alloc_order, reclaim_order; 4472 **unsigned int** highest_zoneidx = **MAX_NR_ZONES**- 1; 4473 **pg_data_t** \*pgdat = (**pg_data_t** \*)p; 4474 **struct** task_struct \*tsk = current; 4475 **const struct** cpumask \*cpumask = **cpumask_of_node**(pgdat-\>node_id); 4476

4477 **if** (!**cpumask_empty**(cpumask)) 4478 **set_cpus_allowed_ptr**(tsk, cpumask); 4479

4480 */\**

4481 *\* Tell the memory management that we're a "memory allocator",* 4482 *\* and that if we need more memory we should get access to it* 4483 *\* regardless (see "\_\_alloc_pages()"). "kswapd" should* 4484 *\* never get caught in the normal page freeing logic.* 4485 *\**

4486 *\* (Kswapd normally doesn't need memory anyway, but sometimes* 4487 *\* you need a small amount of memory in order to be able to* 4488 *\* page out something else, and this flag essentially protects* 4489 *\* us from recursively trying to free more memory as we're* 4490 *\* trying to free the first piece of memory in the first place).*

4491 *\*/*

4492 tsk-\>flags \|= **PF_MEMALLOC** \| **PF_KSWAPD**;

. . .

4495 **WRITE_ONCE**(pgdat-\>kswapd_order, 0); 4496 **WRITE_ONCE**(pgdat-\>**kswapd_highest_zoneidx**, **MAX_NR_ZONES**); 4497 **atomic_set**(&pgdat-\>nr_writeback_throttled, 0); 4498 **for** ( ; ; ) {

4499 **bool** ret; 4500

4501 alloc_order = reclaim_order = **READ_ONCE**(pgdat-\>kswapd_order);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4502 highest_zoneidx = **kswapd_highest_zoneidx**(pgdat, 4503 highest_zoneidx); 4504

4505 **kswapd_try_sleep**:

4506 **kswapd_try_to_sleep**(pgdat, alloc_order, reclaim_order, 4507 highest_zoneidx); 4508

4509 */\* Read the new order and highest_zoneidx \*/* 4510 alloc_order = **READ_ONCE**(pgdat-\>kswapd_order); 4511 highest_zoneidx = **kswapd_highest_zoneidx**(pgdat, 4512 highest_zoneidx); 4513 **WRITE_ONCE**(pgdat-\>kswapd_order, 0); 4514 **WRITE_ONCE**(pgdat-\>**kswapd_highest_zoneidx**, **MAX_NR_ZONES**);

. . .

4517 **if** (**kthread_should_stop**()) 4518 **break**;

. . .

4527 */\**

4528 *\* Reclaim begins at the requested order but if a high-order*

4529 *\* reclaim fails then kswapd falls back to reclaiming for* 4530 *\* order-0. If that happens, kswapd will consider sleeping*

4531 *\* for the order it finished reclaiming at (reclaim_order)*

4532 *\* but kcompactd is woken to compact for the original* 4533 *\* request (alloc_order).* 4534 *\*/*

. . .

4537 reclaim_order = **balance_pgdat**(pgdat, alloc_order, 4538 highest_zoneidx); 4539 **if** (reclaim_order \< alloc_order) 4540 **goto kswapd_try_sleep**; 4541 }

4542

4543 tsk-\>flags &= ~(**PF_MEMALLOC** \| **PF_KSWAPD**); 4544

4545 **return** 0;

4546 }

 

*Listing 11-26:* mm/vmscan.c: [*kswapd()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4469)

 

We start by setting various initial local variables and restricting the

kswapd thread to the same CPUs that the node is restricted to (if any such

restrictions apply). Note in particular that we default to the highest possible

zone to start allocating from.

We then apply some task-specific memory allocation f[lags—](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713)[PF_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713)

and [PF_KSWAPD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1718)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1718) The former prevents reclaim being entered and allows use of

all memory reserves. The latter flags this process as the kswapd process, as

checked for by [current_is_kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n37) in various places.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We then reset various node fields relating to kswapd,

[struct pglist_data-\>kswapd_order](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) which stores the order of the allocation which triggered the current indirect reclaim,

[struct pglist_data-\>kswapd_highest_zoneidx](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) which stores the highest zone index (we set it to an invalid value here, we will discuss why shortly) and

[struct pglist_data-\>nr_writeback_throttled](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) which tracks how often writeback throttling has occurred.

We then enter the main loop—this starts by reading the last allocation

order which triggered the kswapd order, and the highest zone index which we

determine via [kswapd_highest_zoneidx()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4364) which we examine in Listing 11-27.

 

4357 */\**

4358 *\* The pgdat-\>kswapd_highest_zoneidx is used to pass the highest zone index to*

4359 *\* be reclaimed by kswapd from the waker. If the value is MAX_NR_ZONES which*

*is*

4360 *\* not a valid index then either kswapd runs for first time or kswapd couldn't*

4361 *\* sleep after previous reclaim attempt (node is still unbalanced). In that*

4362 *\* case return the zone index of the previous kswapd reclaim cycle.* 4363 *\*/*

4364 **static enum** zone_type **kswapd_highest_zoneidx**(**pg_data_t** \*pgdat, 4365 **enum** zone_type prev_highest_zoneidx

)

4366 {

4367 **enum** zone_type curr_idx = **READ_ONCE**(pgdat-\>**kswapd_highest_zoneidx**); 4368

4369 **return** curr_idx == **MAX_NR_ZONES** ? prev_highest_zoneidx : curr_idx; 4370 }

 

*Listing 11-27:* mm/vmscan.c: [*kswapd_highest_zoneidx()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4364)

 

The key thing to note about [kswapd_highest_zoneidx()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4364) is that, if the

[struct pglist_data-\>kswapd_highest_zoneidx](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) field is set to MAX_NR_ZONES, then

we reset it to the previous highest zone index, which in [kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4469) for the first invocation is set to the maximum valid zone, i.e. MAX_NR_ZONES - 1.

We then invoke [kswapd_try_to_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372) which waits for kswapd to be woken

up for reclaim. We examine this in Listing 11-28 shortly.

We read these fields, and then immediately reset them. We then

check whether the kernel thread should terminate via the standard

[kthread_should_stop()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/kthread.c?h=v6.0#n155) function, before performing the actual reclaim via the

[balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4537) function, which we examine in Listing 11-32.

As per the comment, [balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4537) returns the order that reclaim fin-

ished reclaiming at (which might have been reset to a lower value such as order-0). If it did, then we do not simply loop around and reset the allo-

cation order, but instead jump directly to invoking [kswapd_try_to_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372) which will both cause compaction to be performed at the original alloca-tion order, and, if the reclaim order we last finished reclaiming for is higher than that just set, consider reclaiming at the higher order (see the logic in

[kswapd_try_to_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372) and Listing 11-28 to see how this is determined).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Finally, if the loop does terminate, we clear the task’s [PF_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713) and

[PF_KSWAPD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1718) flags as the thread is no longer being used for kswapd purposes and

is about to be terminated.

 

***11.4.3 kswapd Sleeping***

A key part of the indirect reclaim operation is sleeping until we have work to

do. We wait using [kswapd_try_to_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372) which we examine in Listing 11-28

(eliding tracing hooks).

 

4372 **static void kswapd_try_to_sleep**(**pg_data_t** \*pgdat, **int** alloc_order, **int**

reclaim_order,

4373 **unsigned int** highest_zoneidx) 4374 {

4375 **long** remaining = 0; 4376 **DEFINE_WAIT**(wait); 4377

4378 **if** (**freezing**(current) \|\| **kthread_should_stop**()) 4379 **return**;

4380

4381 **prepare_to_wait**(&pgdat-\>kswapd_wait, &wait, **TASK_INTERRUPTIBLE**); 4382

4383 */\**

4384 *\* Try to sleep for a short interval. Note that kcompactd will only be*

4385 *\* woken if it is possible to sleep for a short interval. This is* 4386 *\* deliberate on the assumption that if reclaim cannot keep an* 4387 *\* eligible zone balanced that it's also unlikely that compaction will*

4388 *\* succeed.*

4389 *\*/*

4390 **if** (**prepare_kswapd_sleep**(pgdat, reclaim_order, highest_zoneidx)) { 4391 */\**

4392 *\* Compaction records what page blocks it recently failed to*

4393 *\* isolate pages from and skips them in the future scanning.*

4394 *\* When kswapd is going to sleep, it is reasonable to assume*

4395 *\* that pages and compaction may succeed so reset the cache.*

4396 *\*/*

4397 **reset_isolation_suitable**(pgdat); 4398

4399 */\**

4400 *\* We have freed the memory, now we should compact it to make*

4401 *\* allocation of the requested order possible.* 4402 *\*/*

4403 **wakeup_kcompactd**(pgdat, alloc_order, highest_zoneidx); 4404

4405 remaining = **schedule_timeout**(HZ/10); 4406

4407 */\**

4408 *\* If woken prematurely then reset kswapd_highest_zoneidx and*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4409 *\* order. The values will either be from a wakeup request or*

4410 *\* the previous request that slept prematurely.* 4411 *\*/*

4412 **if** (remaining) { 4413 **WRITE_ONCE**(pgdat-\>**kswapd_highest_zoneidx**, 4414 **kswapd_highest_zoneidx**(pgdat, 4415 highest_zoneidx));

4416

4417 **if** (**READ_ONCE**(pgdat-\>kswapd_order) \< reclaim_order) 4418 **WRITE_ONCE**(pgdat-\>kswapd_order, reclaim_order)

;

4419 }

4420

4421 **finish_wait**(&pgdat-\>kswapd_wait, &wait); 4422 **prepare_to_wait**(&pgdat-\>kswapd_wait, &wait, **TASK_INTERRUPTIBLE**

);

4423 }

 

*Listing 11-28:* mm/vmscan.c: [*kswapd_try_to_sleep()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372) *Short sleep*

 

We start [kswapd_try_to_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372) by declaring a wait queue en-

try via [DEFINE_WAIT()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/wait.h?h=v6.0#n1180)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/wait.h?h=v6.0#n1180) This is what we will add to our wait queue

[struct pglist_data-\>kswapd_wait](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) in order to be woken when there is reclaim to perform.

Discussion of wait queues is out of the scope of the book, but are broadly

a means by which threads can wait for an event to occur, sleeping in the meantime.

We then check if the task is being frozen (discussion of which is outside

of the scope of the book), or the kernel thread should be terminated, in both cases we must exit early.

We then add the wait wait queue entry to the

[struct pglist_data-\>kswapd_wait](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) wait queue via [prepare_to_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n260), which also sets the current thread’s status to interruptible sleep. When the task is scheduled, it will enter into this state until the wait queue wakes it.

We determine whether we need to sleep via [prepare_kswapd_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4027) which

we examine in Listing 11-30 shortly.

If we do need to sleep, then we then proceed by trying to perform a brief

sleep first, in order that we can detect whether we were woken up quickly.

If we do need to sleep then firstly, we reset compaction state via

[reset_isolation_suitable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n4397) which frees some memory and try waking up the compaction kernel thread, kcompactd, in order to potentially free some addi-tional memory.

We sleep via [schedule_timeout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/time/timer.c?h=v6.0#n1896)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/time/timer.c?h=v6.0#n1896) specifying that we sleep for 0.1 seconds

(specified in units of jiffies, an internal kernel measure of time).

Using this function means we specify a timeout and thus we can detect if

this timeout was reached or not.

If so, then this might indicate that we slept prematurely after a failed

higher order reclaim attempt, and therefore we most be careful to not pre-

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

maturely reduce the order of the folios we attempt to reclaim. We there-

fore reset the highest zone we examine, in case it was reset to MAX_NR_ZONES

via [kswapd_highest_zoneidx()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4364) (see Listing 11-27), and choose the maximum of

the prior reclaim order and the newly established one.

After we have performed this initial attempt at a sleep, we remove the

wait entry from the wait queue via [finish_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n387)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n387) and reset it ready to sleep

again via [prepare_to_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n260).

We then consider a longer sleep, explored in Listing 11-29.

 

4425 */\**

4426 *\* After a short sleep, check if it was a premature sleep. If not,*

*then*

4427 *\* go fully to sleep until explicitly woken up.* 4428 *\*/*

4429 **if** (!remaining && 4430 **prepare_kswapd_sleep**(pgdat, reclaim_order, highest_zoneidx)) {

. . .

4433 */\**

4434 *\* vmstat counters are not perfectly accurate and the*

*estimated*

4435 *\* value for counters such as NR_FREE_PAGES can deviate from*

*the*

4436 *\* true value by nr_online_cpus \* threshold. To avoid the zone*

4437 *\* watermarks being breached while under pressure, we reduce*

*the*

4438 *\* per-cpu vmstat threshold while kswapd is awake and restore*

4439 *\* them before going back to sleep.* 4440 *\*/*

4441 **set_pgdat_percpu_threshold**(pgdat, calculate_normal_threshold); 4442

4443 **if** (!**kthread_should_stop**()) 4444 **schedule**(); 4445

4446 **set_pgdat_percpu_threshold**(pgdat, calculate_pressure_threshold

);

4447 } **else** {

4448 **if** (remaining) 4449 **count_vm_event**(**KSWAPD_LOW_WMARK_HIT_QUICKLY**); 4450 **else**

4451 **count_vm_event**(**KSWAPD_HIGH_WMARK_HIT_QUICKLY**); 4452 }

4453 **finish_wait**(&pgdat-\>kswapd_wait, &wait); 4454 }

 

*Listing 11-29:* mm/vmscan.c: [*kswapd_try_to_sleep()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372) *Long Sleep*

 

We examine the portion of [kswapd_try_to_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372) which considers per-

forming a long-term sleep in Listing 11-29.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We only perform a longer sleep if the prior attempt at a short sleep did

not result in an early wake up, as indicated by remaining being equal to zero, i.e. the previously scheduling attempting having timed out. We also check

[prepare_kswapd_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4027) once again (see Listing 11-30) before immediately sleeping.

Note that, as per the comment, we update the thresholds for the

[NR_FREE_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n154) zone statistic we use to assess reclaim decisions for this node.

This is because, for scaling purposes, we batch up statistics in per-CPU

lists and flush them on a regular basis. In this circumstance however, it be-comes critical that we make this more accurate to avoid accidentally breach-ing watermarks while kswapd sleeps.

The details of this are out of scope for the book so we don’t examine

them in detail.

The [schedule()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/core.c?h=v6.0#n6563) function causes the scheduler to apply the

[TASK_INTERRUPTIBLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n85) state set by [prepare_to_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n260)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n260) i.e. to enter an interruptible sleep indefinitely until woken from that sleep via the wait queue.

This therefore indicates that kswapd enters an indefinite sleep until some-

thing wakes it, which is the desired behaviour.

Once woken, the statistical thresholds for the node are restored, and the

wait queue is cleared via [finish_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n387)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n387)

At this point, the sleep logic is concluded and any relevant kswapd sleep-

ing will have occurred.

We now examine the key [prepare_kswapd_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4027) function in Listing 11-30.

 

4021 */\**

4022 *\* Prepare kswapd for sleeping. This verifies that there are no processes*

4023 *\* waiting in throttle_direct_reclaim() and that watermarks have been met.*

4024 *\**

4025 *\* Returns true if kswapd is ready to sleep* 4026 *\*/*

4027 **static bool prepare_kswapd_sleep**(**pg_data_t** \*pgdat, **int** order, 4028 **int** highest_zoneidx) 4029 {

4030 */\**

4031 *\* The throttled processes are normally woken up in balance_pgdat() as*

4032 *\* soon as allow_direct_reclaim() is true. But there is a potential*

4033 *\* race between when kswapd checks the watermarks and a process gets*

4034 *\* throttled. There is also a potential race if processes get* 4035 *\* throttled, kswapd wakes, a large process exits thereby balancing*

*the*

4036 *\* zones, which causes kswapd to exit balance_pgdat() before reaching*

4037 *\* the wake up checks. If kswapd is going to sleep, no process should*

4038 *\* be sleeping on pfmemalloc_wait, so wake them now if necessary. If*

4039 *\* the wake up is premature, processes will wake kswapd and get* 4040 *\* throttled again. The difference from wake ups in balance_pgdat() is*

4041 *\* that here we are under prepare_to_wait().* 4042 *\*/*

4043 **if** (**waitqueue_active**(&pgdat-\>pfmemalloc_wait))

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4044 **wake_up_all**(&pgdat-\>pfmemalloc_wait); 4045

4046 */\* Hopeless node, leave it to direct reclaim \*/* 4047 **if** (pgdat-\>kswapd_failures \>= **MAX_RECLAIM_RETRIES**) 4048 **return true**; 4049

4050 **if** (**pgdat_balanced**(pgdat, order, highest_zoneidx)) { 4051 **clear_pgdat_congested**(pgdat); 4052 **return true**; 4053 }

4054

4055 **return false**;

4056 }

 

*Listing 11-30:* mm/vmscan.c: [*prepare_kswapd_sleep()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4027)

The [prepare_kswapd_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4027) function is tasked with determining whether

either kswapd has nothing to do, or if it is unable to help with the memory

pressure.

It starts by ensuring no direct reclaim is sleeping, waiting for kswapd to

improve the situation as, since we are likely about to sleep, we are not going

to.

Even if we don’t currently sleep, then the worst that this will accomplish

is causing direct reclaim to get throttled again and attempt to wake kswapd

once more.

See Section 11.6.2 for more on direct reclaim throttling. After this we check to see whether the nodes count of failed kswapd at-

tempts, [struct pglist_data](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905)-\>kswapd_failures equals or exceeds the maximum

of [MAX_RECLAIM_RETRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n170) (hard-coded to 16 attempts).

If so, then kswapd can do nothing to help, so we may as well sleep, leaving

the work to direct reclaim.

Otherwise, we determine whether the node is “balanced” via the

[pgdat_balanced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3976) function which we examine in Listing 11-31 in Section

11.4.4.

See the explanation in Section 11.4.4 as to what a balanced node

means, but ultimately we take that to indicate that kswapd has no work to

do and in that case we ought to sleep, additionally we clear the flag indi-

cating that there is significant congestion in reclaim around this node via

[clear_pgdat_congested()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4012), as it being balanced and thus not requiring reclaim

implies that it cannot be congested.

If the node is not balanced, then we indicate that no sleep should occur

and thus indirect reclaim should commence.

 

***11.4.4 Node Balancing***

The ultimate purpose of indirect reclaim is to balance the node to which it is

being performed.

A node being balanced simply means that at least one of the zones that

could have been allocated from at the requested order (taking into account

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

the low memory reserve, see Section 2.4.1 for details of this) equals or ex-ceeds the high watermark.

This is checked in [pgdat_balanced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3976), which we examine in Listing 11-31

(eliding out of scope NUMA balancing logic).

 

3972 */\**

3973 *\* Returns true if there is an eligible zone balanced for the request order*

3974 *\* and highest_zoneidx*

3975 *\*/*

3976 **static bool pgdat_balanced**(**pg_data_t** \*pgdat, **int** order, **int** highest_zoneidx) 3977 {

3978 **int** i;

3979 **unsigned long** mark = -1; 3980 **struct** zone \*zone; 3981

3982 */\**

3983 *\* Check watermarks bottom-up as lower zones are more likely to* 3984 *\* meet watermarks.* 3985 *\*/*

3986 **for** (i = 0; i \<= highest_zoneidx; i++) { 3987 zone = pgdat-\>node_zones + i; 3988

3989 **if** (!**managed_zone**(zone)) 3990 **continue**;

. . .

3995 mark = **high_wmark_pages**(zone); 3996 **if** (**zone_watermark_ok_safe**(zone, order, mark, highest_zoneidx)

)

3997 **return true**; 3998 }

3999

4000 */\**

4001 *\* If a node has no managed zone within highest_zoneidx, it does not*

4002 *\* need balancing by definition. This can happen if a zone-restricted*

4003 *\* allocation tries to wake a remote kswapd.* 4004 *\*/*

4005 **if** (mark == -1)

4006 **return true**; 4007

4008 **return false**;

4009 }

 

*Listing 11-31:* mm/vmscan.c: [*pgdat_balanced()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3976)

 

The [pgdat_balanced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3976) function iterates through zones in the node,

bottom-up, checking that at least one zone has free pages equal to or exceed-ing the high watermark.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We skip any that don’t manage any buddy page allocator controlled

pages, as tested by [managed_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1098), then obtain the high watermark value for

the zone via [high_wmark_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n380).

This is checked against the zone for the specified order via

[zone_watermark_ok_safe() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4083)a function which ultimately invokes

[\_\_zone_watermark_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3968) (see Listing 2-59 in Section 2.8.2 and Chapter 2).

If no zone could be checked, then we trivially succeed, otherwise if no

zone had sufficient free pages, we indicate failure.

Now we have examined how we determine whether a node is balanced,

we can go ahead and examine the next stage in indirect reclaim (as indicated

by Figure 11-10), the balancing of a node via [balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) which we ex-

amine starting in Listing 11-32 (eliding out of scope PSI memory pressure

hooks, lockdep hooks, cgroup, process freezing, working set and buffer head

overrun logic).

 

4133 */\**

4134 *\* For kswapd, balance_pgdat() will reclaim pages across a node from zones*

4135 *\* that are eligible for use by the caller until at least one zone is* 4136 *\* balanced.*

4137 *\**

4138 *\* Returns the order kswapd finished reclaiming at.* 4139 *\**

4140 *\* kswapd scans the zones in the highmem-\>normal-\>dma direction. It skips*

4141 *\* zones which have free_pages \> high_wmark_pages(zone), but once a zone is*

4142 *\* found to have free_pages \<= high_wmark_pages(zone), any page in that zone*

4143 *\* or lower is eligible for reclaim until at least one usable zone is* 4144 *\* balanced.*

4145 *\*/*

4146 **static int balance_pgdat**(**pg_data_t** \*pgdat, **int** order, **int** highest_zoneidx) 4147 {

4148 **int** i;

4149 **unsigned long** nr_soft_reclaimed;

. . .

4152 **unsigned long** nr_boost_reclaim; 4153 **unsigned long** zone_boosts\[**MAX_NR_ZONES**\] = { 0, }; 4154 **bool** boosted;

4155 **struct** zone \*zone; 4156 **struct** scan_control sc = { 4157 .gfp_mask = **GFP_KERNEL**, 4158 .order = order, 4159 .may_unmap = 1, 4160 };

4161

4162 **set_task_reclaim_state**(**current**, &sc.reclaim_state);

. . .

4166 **count_vm_event**(**PAGEOUTRUN**); 4167

4168 */\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4169 *\* Account for the reclaim boost. Note that the zone boost is left in*

4170 *\* place so that parallel allocations that are near the watermark will*

4171 *\* stall or direct reclaim until kswapd is finished.* 4172 *\*/*

4173 nr_boost_reclaim = 0; 4174 **for** (i = 0; i \<= highest_zoneidx; i++) { 4175 zone = pgdat-\>node_zones + i; 4176 **if** (!**managed_zone**(zone)) 4177 **continue**; 4178

4179 nr_boost_reclaim += zone-\>watermark_boost; 4180 zone_boosts\[i\] = zone-\>watermark_boost; 4181 }

4182 boosted = nr_boost_reclaim;

 

*Listing 11-32:* mm/vmscan.c: [*balance_pgdat()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) *Zone Boost*

 

We start [balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) by initialising state and setting the

[struct task_struct-\>rs](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) field to a pointer to the [struct reclaim_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n163) object

newly initialised in the [struct scan_control.reclaim_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) field.

The [struct reclaim_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n163) field is currently used to track the amount of re-

claim performed by slab. Kernel slab allocation is out of scope for the book, but broadly it is the means by which the kernel permits efficient sub-page sized allocations, i.e. a malloc() in the kernel.

Objects that are allocated by the slab can also be maintained in caches

for efficiency, and those caches can be shrunk during reclaim to free up memory, and that is what is measured here.

Next, we register that indirect reclaim is occurring via the [PAGEOUTRUN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vm_event_item.h?h=v6.0#n57)

event value.

We then measure zones within the node which have boosted, aggre-

gating the number of boosted pages in nr_boost_reclaim and the per-zone boosted in the local zone_boosts array.

Zone boosting is performed when migrate type fragmentation occurs,

and adds a set factor to each watermark.

We discuss migrate types in Section 2.5 and Chapter 2, however broadly

this is an attribute of physical memory pages which determines whether the memory will be moveable or not, such that we can maintain movable mem-ory separate from unmovable (that is, memory used for kernel allocations) so we do not cause fragmentation and thus an inability to free higher order folios by having movable memory interleaved with unmovable.

However, under circumstances where we cannot find memory of the re-

quired migrate type we “steal” memory from other migrate type page blocks

(again covered in Chapter 2, but broadly page blocks are physically contigu-

ous blocks of memory of order [pageblock_order](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n36)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n36) which is order-9 on x86-64).

This is performed in [steal_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2756) (see Listing 2-68 and Sec-

tion 2.8.6 in Chapter 2). If this occurs, we want to ensure that the fragmenta-tion is remedied as soon as possible, and do so by increasing each watermark

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

by a set number of pages in [boost_watermark()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2711)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2711) up to a maximum of a page

block size on each occasion.

When we do so, we proactively wake up kswapd for the node on physical

page allocation in [rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3821) (see Listing 2-60 in Section 2.8.3 and Chapter 2).

We do so in order to prevent further contamination of migrate type page

blocks and thus reduce fragmentation as a result.

If the node is balanced and thus reclaim would otherwise not be re-

quired, we use the information we gathered throughout this process to de-

termine whether we should perform indirect reclaim to free up memory

specifically to avoid further migrate type stealing.

If the node is not balanced, then we ignore zone boosting and reclaim as

normal.

With this state established, we proceed with performing reclaim as ex-

plored in Listing 11-33.

 

4184 **restart**:

4185 **set_reclaim_active**(pgdat, highest_zoneidx); 4186 sc.priority = **DEF_PRIORITY**; 4187 **do** {

4188 **unsigned long** nr_reclaimed = sc.nr_reclaimed; 4189 **bool** raise_priority = **true**; 4190 **bool** balanced; 4191 **bool** ret; 4192

4193 sc.reclaim_idx = highest_zoneidx;

. . .

4216 */\**

4217 *\* If the pgdat is imbalanced then ignore boosting and*

*preserve*

4218 *\* the watermarks for a later time and restart. Note that the*

4219 *\* zone watermarks will be still reset at the end of balancing*

4220 *\* on the grounds that the normal reclaim should be enough to*

4221 *\* re-evaluate if boosting is required when kswapd next wakes.*

4222 *\*/*

4223 balanced = **pgdat_balanced**(pgdat, sc.order, highest_zoneidx); 4224 **if** (!balanced && nr_boost_reclaim) { 4225 nr_boost_reclaim = 0; 4226 **goto restart**; 4227 }

4228

4229 */\**

4230 *\* If boosting is not active then only reclaim if there are no*

4231 *\* eligible zones. Note that sc.reclaim_idx is not used as*

4232 *\* buffer_heads_over_limit may have adjusted it.* 4233 *\*/*

4234 **if** (!nr_boost_reclaim && balanced) 4235 **goto out**; 4236

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4237 */\* Limit the priority of boosting to avoid reclaim writeback*

*\*/*

4238 **if** (nr_boost_reclaim && sc.priority == **DEF_PRIORITY**- 2) 4239 raise_priority = **false**; 4240

4241 */\**

4242 *\* Do not writeback or swap pages for boosted reclaim. The*

4243 *\* intent is to relieve pressure not issue sub-optimal IO*

4244 *\* from reclaim context. If no pages are reclaimed, the* 4245 *\* reclaim will be aborted.* 4246 *\*/*

4247 sc.may_writepage = !**laptop_mode** && !nr_boost_reclaim; 4248 sc.may_swap = !nr_boost_reclaim; 4249

4250 */\**

4251 *\* Do some background aging of the anon list, to give* 4252 *\* pages a chance to be referenced before reclaiming. All*

4253 *\* pages are rotated regardless of classzone as this is* 4254 *\* about consistent aging.* 4255 *\*/*

4256 **age_active_anon**(pgdat, &sc); 4257

4258 */\**

4259 *\* If we're getting trouble reclaiming, start doing writepage*

4260 *\* even in laptop mode.* 4261 *\*/*

4262 **if** (sc.priority \< **DEF_PRIORITY**- 2) 4263 sc.may_writepage = 1;

. . .

4272 */\**

4273 *\* There should be no need to raise the scanning priority if*

4274 *\* enough pages are already being scanned that that high*

4275 *\* watermark would be met at 100% efficiency.* 4276 *\*/*

4277 **if** (**kswapd_shrink_node**(pgdat, &sc)) 4278 raise_priority = **false**; 4279

4280 */\**

4281 *\* If the low watermark is met there is no need for processes*

4282 *\* to be throttled on pfmemalloc_wait as they should not be*

4283 *\* able to safely make forward progress. Wake them* 4284 *\*/*

4285 **if** (**waitqueue_active**(&pgdat-\>pfmemalloc_wait) && 4286 **allow_direct_reclaim**(pgdat)) 4287 **wake_up_all**(&pgdat-\>pfmemalloc_wait); 4288

4289 */\* Check if kswapd should be suspending \*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

. . .

4293 **if** (ret \|\| **kthread_should_stop**()) 4294 **break**; 4295

4296 */\**

4297 *\* Raise priority if scanning rate is too low or there was no*

4298 *\* progress in reclaiming pages* 4299 *\*/*

4300 nr_reclaimed = sc.nr_reclaimed - nr_reclaimed; 4301 nr_boost_reclaim -= **min**(nr_boost_reclaim, nr_reclaimed); 4302

4303 */\**

4304 *\* If reclaim made no progress for a boost, stop reclaim as*

4305 *\* IO cannot be queued and it could be an infinite loop in*

4306 *\* extreme circumstances.* 4307 *\*/*

4308 **if** (nr_boost_reclaim && !nr_reclaimed) 4309 **break**; 4310

4311 **if** (raise_priority \|\| !nr_reclaimed) 4312 sc.priority--; 4313 } **while** (sc.priority \>= 1);

 

*Listing 11-33:* mm/vmscan.c: [*balance_pgdat()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) *Core Reclaim*

 

We start by marking all zones up to and including the highest from which

we can allocate with the [ZONE_RECLAIM_ACTIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n700) flag via [set_reclaim_active()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4122)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4122)

This records for each zone from which we might allocate that indirect

reclaim is taking place so that we can track this in other parts of the kernel.

We set the [struct scan_control-\>priority](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) field to [DEF_PRIORITY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838) This indi-

cates how much of the LRU vectors we should examine when performing

reclaim (expressed as a shift value, so [DEF_PRIORITY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838), hard-coded to 12, implies

we should examine lru_vec_size \>\> 12 folios).

We then enter the core reclaim loop. We repeatedly attempt reclaim on

the node, gradually increasing priority if either no pages were reclaimed or

if raise_priority is cleared (this is reset back to true on each loop, and only

cleared if reclaim clears pages sufficient that we should soon exit the loop or

if zone boosting reclaim is persisting through too many priority levels. We

will examine both cases as we come to them.

We start by assessing whether the node is balanced via [pgdat_balanced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3976)

(see Listing 11-31).

As mentioned in the discussion beneath Listing 11-32, we treat zone

boosting in effect as a separate indirect reclaim mode—we only perform zone

boost-specific logic if the node is already balanced, resetting nr_boost_reclaim

to zero and restarting the loop if so.

On the other hand, if [pgdat_balanced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3976) indicates that the node is balanced

and there is no zone boost to consider, then we have achieved our aim and

exit the loop.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

The remainder of the logic in the loop applies whether either the node

isn’t balanced, or if the zone boost case is being considered.

In the case of us being in zone boost indirect reclaim mode, we en-

sure we do not proceed below a priority of [DEF_PRIORITY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838) - 2 (keeping in mind that lower priority values implies we consider more folios), so in this instance we disable the raising of priorities (i.e. the decrementing of

[struct scan_control-\>priority](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) on each loop).

We determine whether we ought to permit the writeback of dirty pages

on reclaim, as set in [struct scan_control-\>may_writepage](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66), on us both not being in laptop mode (that explicitly avoids spinning up rotational media by avoid-ing writeback on reclaim) and us not being in zone boosting mode where such actions would only delay us quickly freeing memory in order to avoid page block fragmentation.

In a similar vein, we avoid swapping out to disk if we are in zone boost

mode by clearing [struct scan_control-\>may_swap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) in this instance.

We then rotate up to [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214) anonymous pages (hard-coded to

32) via [age_active_anon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3926)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3926) where we “age” folios on the active list, moving

them to the inactive one if [inactive_is_low()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2705) indicates the inactive anony-

mous list is too small (see Listing 11-42 and Section 11.5.3).

This aging is ultimately performed by [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) which we ex-

amine in detail in Listing 11-56 and Section **??**.

 

**N O T E** We take extra care to perform background aging of the active anonymous LRU vec-

tor in order that we ensure we maintain sufficient folios in the list such that anony-mous folios get a chance to be referenced before being evicted. Additionally, we are generally less inclined to evict anonymous folios than file-backed (consider cachet rim mode), and additionally thus must ensure consistent aging takes place of anonymous folios.

 

Next, as in direct reclaim (see Section 11.3), if we are having trouble

achieving reclaim, as indicated by us reaching the third priority loop or lower, we should override laptop mode and permit the writing back of dirty pages on reclaim (note this doesn’t affect zone boost mode as we already explicitly prevented the priority from being raised beyond this level in this case).

With all of this state put in place, we are ready to actually perform the

reclaim, which we do via [kswapd_shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4066), which we examine shortly in

Listing 11-35.

The return value of this function indicates whether we at least scanned

the number of pages requested—if so then the priority does not need to be raised (and we should simply exit on the next check of the node being bal-anced), otherwise it ought to be.

Of course allocating processes might result in the node becoming unbal-

anced immediately after the reclaim, however given we had good results by reclaiming at this priority, it is sensible to simply try again rather than tra-verse more folios than would otherwise be required.

Next, we consider those threads currently undergoing direct

reclaim throttling (see Section 11.6.2). These are waiting on the

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[struct pglist_data-\>pfmemalloc_wait](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) wait queue, so we check to see if there

are waiters, and then whether sufficient memory has been freed to provide

enough reserve memory for lagging direct reclaim to be woken, as checked

by [allow_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3672) (see Listing 11-79 in Section 11.6.2).

If this is so, then we wake all of the sleeping threads so they may resume

direct reclaim.

At this point, check whether the kernel thread has been terminated in

some fashion via [kthread_should_stop()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/kthread.c?h=v6.0#n155) and act appropriately.

We then calculate the delta between the number of reclaimed pages, as

ultimately set by the reclaim mechanism invoked by [kswapd_shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4066) (see

Listing 11-35) in [struct scan_control-\>nr_reclaimed](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) and the last count of re-

claimed pages as stored in nr_reclaimed at the start of the loop.

In zone boosting mode, we aim to reclaim at least the number of pages

equal to the total number of boost pages, therefore we deduct those pages

reclaimed from the nr_boost_reclaim value used to determine if this mode

should continue.

If this reaches zero and the node is otherwise balanced, we’ll exit indirect

reclaim on the next iteration.

If we are in zone boosting mode and we reclaim zero pages, we simply

abort, as at this stage I/O is probably required, but we are disallowing it, so

we may end up looping forever otherwise.

Next, as mentioned at the start of the discussion, we decrement the pri-

ority if raise_priority was not cleared (it is reset to true at the start of each

loop) or if no pages were reclaimed, which indicates no progress is being

made so upping the priority makes sense in this case.

Note that we loop while [struct scan_control-\>priority](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) is equal to or

greater than one, meaning we scan at most one half of the available folios.

After this loop is complete, we proceed with some housekeeping tasks, as

explored in Listing 11-34.

 

4315 **if** (!sc.nr_reclaimed) 4316 pgdat-\>kswapd_failures++; 4317

4318 **out**:

4319 **clear_reclaim_active**(pgdat, highest_zoneidx); 4320

4321 */\* If reclaim was boosted, account for the reclaim done in this pass*

*\*/*

4322 **if** (boosted) {

4323 **unsigned long** flags; 4324

4325 **for** (i = 0; i \<= highest_zoneidx; i++) { 4326 **if** (!zone_boosts\[i\]) 4327 **continue**; 4328

4329 */\* Increments are under the zone lock \*/* 4330 zone = pgdat-\>node_zones + i; 4331 **spin_lock_irqsave**(&zone-\>lock, flags);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4332 zone-\>watermark_boost -= **min**(zone-\>watermark_boost,

zone_boosts\[i\]);

4333 **spin_unlock_irqrestore**(&zone-\>lock, flags); 4334 }

4335

4336 */\**

4337 *\* As there is now likely space, wakeup kcompact to defragment*

4338 *\* pageblocks.* 4339 *\*/*

4340 **wakeup_kcompactd**(pgdat, pageblock_order, highest_zoneidx); 4341 }

. . .

4343 **snapshot_refaults**(**NULL**, pgdat);

. . .

4346 **set_task_reclaim_state**(**current**, **NULL**); 4347

4348 */\**

4349 *\* Return the order kswapd stopped reclaiming at as* 4350 *\* prepare_kswapd_sleep() takes it into account. If another caller*

4351 *\* entered the allocator slow path while kswapd was awake, order will*

4352 *\* remain at the higher level.* 4353 *\*/*

4354 **return** sc.order;

4355 }

 

*Listing 11-34:* mm/vmscan.c: [*balance_pgdat()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) *Post-Reclaim Housekeeping*

 

After the main reclaim loop is complete, we perform some final house

keeping tasks as shown in Listing 11-34.

We start by determining whether any pages were reclaimed as stored in

[struct scan_control-\>nr_reclaimed](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66). If none were, then no forward progress has been made and the kswapd invocation was a waste and failed—we therefore

increment the [struct pglist_data-\>kswapd_failures](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) counter.

This helps us catch helpless cases where indirect reclaim is simply doing

nothing to help the situation.

After we check this we clear the [ZONE_RECLAIM_ACTIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n700) flag from all

zones up to and including the highest from which we can allocate via

[clear_reclaim_active().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4128)

This indicates that indirect reclaim is no longer active in these zones. Next, if a zone boosting pass took place, we clear the watermark boost

from each zone that possessed one up to a maximum of its initial boost level (but ensuring we do not reduce it below zero).

This is whether or not we were able to make progress, so the boosting

only lasts as long as an indirect reclaim pass.

Equally, we take the time to wake the kcompactd compacting kernel thread

to defragment memory through compaction, as this is more likely to now yield results as an effort at this point. Discussion of this is out of scope for the book.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

After considering the boosted case, we invoke [snapshot_refaults()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3556) (see

Listing 11-38) which stores the current statistics for “refaults” for this node.

See Section 11.5.2 and the discussion around Listing 11-41 for an explana-

tion as to how this is used.

After this, we clear the [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) reclaim state field and return

the order at which kswapd stopped reclaim in order that [kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4469) (see Listing

11-26) can take it into account.

The reclaim is ultimately performed by [kswapd_shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4066)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4066) which we

explore in Listing 11-35.

 

4058 */\**

4059 *\* kswapd shrinks a node of pages that are at or below the highest usable* 4060 *\* zone that is currently unbalanced.* 4061 *\**

4062 *\* Returns true if kswapd scanned at least the requested number of pages to*

4063 *\* reclaim or if the lack of progress was due to pages under writeback.* 4064 *\* This is used to determine if the scanning priority needs to be raised.* 4065 *\*/*

4066 **static bool kswapd_shrink_node**(**pg_data_t** \*pgdat, 4067 **struct** scan_control \*sc) 4068 {

4069 **struct** zone \*zone; 4070 **int** z;

4071

4072 */\* Reclaim a number of pages proportional to the number of zones \*/*

4073 sc-\>nr_to_reclaim = 0; 4074 **for** (z = 0; z \<= sc-\>reclaim_idx; z++) { 4075 zone = pgdat-\>node_zones + z; 4076 **if** (!**managed_zone**(zone)) 4077 **continue**; 4078

4079 sc-\>nr_to_reclaim += **max**(**high_wmark_pages**(zone),

**SWAP_CLUSTER_MAX**);

4080 }

4081

4082 */\**

4083 *\* Historically care was taken to put equal pressure on all zones but*

4084 *\* now pressure is applied based on node LRU order.* 4085 *\*/*

4086 **shrink_node**(pgdat, sc); 4087

4088 */\**

4089 *\* Fragmentation may mean that the system cannot be rebalanced for*

4090 *\* high-order allocations. If twice the allocation size has been* 4091 *\* reclaimed then recheck watermarks only at order-0 to prevent* 4092 *\* excessive reclaim. Assume that a process requested a high-order*

4093 *\* can direct reclaim/compact.* 4094 *\*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

4095 **if** (sc-\>order && sc-\>nr_reclaimed \>= **compact_gap**(sc-\>order)) 4096 sc-\>order = 0; 4097

4098 **return** sc-\>nr_scanned \>= sc-\>nr_to_reclaim; 4099 }

 

*Listing 11-35:* mm/vmscan.c: [*kswapd_shrink_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4066)

 

The [kswapd_shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4066) function starts with the important task of deter-

mining how many pages should be attempted to be reclaimed in aggregate.

It conservatively opts to reclaim pages equal to the high water mark

for each zone from which we might be able to allocate, as determined by

[struct scan_control-\>reclaim_idx](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66).

In each instance, we use [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214) as a low bar on the number of

pages to attempt to reclaim, in keeping with this acting as the minimum granularity for actions taken within reclaim as a whole.

Finally, we perform the actual reclaim via the entrypoint to the core re-

claim mechanism, [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) which we explore in Listing 11-40 in Section

11.5.

After this has been performed, we are careful about continuing to at-

tempt reclaim at a higher order, which is more likely to fail than attempts to reclaim at lower order.

We therefore estimate what compaction might be able free via the

[compact_gap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/compaction.h?h=v6.0#n65) function—this is equal to double the number of pages in the folio order—if we have reclaimed at least this number of pages then we con-sider it safe to reset to order zero reclaim.

Finally we return a boolean value indicating whether we scanned at least

the number of pages we were requested to reclaim in order to determine

whether [balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) ought to increase priority (as shown in Listing 11-

33).

 

**11.5 The Reclaim Mechanism**

 

[shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)

 

[shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136) [shrink_slab()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n964)

 

[shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2950)

 

[shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)

 

[shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)

 

[shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)

 

*Figure 11-11: Core Reclaim Mechanism Code Path*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**N O T E** Some of the functions referenced by Figure 11-11 may be invoked by other code paths,

however the one shown is the typical means by which reclaim operates.

 

While the logic surrounding direct reclaim (see Section 11.3) and indi-

rect reclaim (see Section 11.4) determine how reclaim is invoked, how many

times and at what priority, the “reclaim mechanism” is the core machinery

that actually performs this reclaim.

As with much kernel functionality, it is abstracted into gradually more

specific functions. At each stage the reclaim operation is framed as “shrink-

ing” memory, at ever finer granularity.

We start by shrinking an entire node via [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40).

We examine this in Section 11.5.3.

Next, we shrink the LRU vectors contained within the node (see Section

11.2 for more on LRU vectors), via [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2950) (see Listing 11-51). We

examine this in Section 11.5.5.

We shrink each individual LRU vector via [shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663) (see Listing 11-

55). We examine this in Section 11.5.6.

When we do so, we may be shrinking the active list (i.e. deactivating fo-

lios) via [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) (see Listing 11-56) or we may be shrinking the

inactive list via [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402) (see Listing 11-61), which ultimately

invokes [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1582) (see Listing 11-63), which performs actual folio

reclaim.

We explore shrinking of the active LRU vectors (deactivating folios)

in Section 11.5.7, and shrinking of inactive LRU vectors in Section 11.5.9,

which performs the actual reclaim.

We start by examining the [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) (see Listing 11-36) object

which is threaded through the reclaim code) in Section 11.5.1.

 

***11.5.1 The Scan Control Object***

As mentioned in Sections 11.4 and 11.3, the reclaim mechanism is config-

ured by the [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) object.

This data structure has a great many flags within it (defined as bit fields),

so for clarity we separate its data and flag fields, starting by examining its

data fields in Listing 11-36 (eliding out of scope cgroup fields).

 

66 **struct** scan_control {

67 */\* How many pages shrink_list() should reclaim \*/*

68 **unsigned long** nr_to_reclaim;

69

70 */\**

71 *\* Nodemask of nodes allowed by the caller. If NULL, all nodes*

72 *\* are scanned.*

73 *\*/*

74 **nodemask_t** \*nodemask;

. . .

82 */\**

83 *\* Scan pressure balancing between anon and file LRUs*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

84 *\*/*

85 **unsigned long** anon_cost; 86 **unsigned long** file_cost;

. . .

132 */\* Allocation order \*/* 133 **s8** order;

134

135 */\* Scan (total_size \>\> priority) pages at once \*/* 136 **s8** priority;

137

138 */\* The highest zone to isolate pages for reclaim from \*/* 139 **s8** reclaim_idx;

140

141 */\* This context's GFP mask \*/* 142 **gfp_t** gfp_mask;

143

144 */\* Incremented by the number of inactive pages that were scanned \*/*

145 **unsigned long** nr_scanned; 146

147 */\* Number of pages freed so far during a call to shrink_zones() \*/*

148 **unsigned long** nr_reclaimed; 149

150 **struct** {

151 **unsigned int** dirty; 152 **unsigned int** unqueued_dirty; 153 **unsigned int** congested; 154 **unsigned int** writeback; 155 **unsigned int** immediate; 156 **unsigned int** file_taken; 157 **unsigned int** taken; 158 } nr;

159

160 */\* for recording the reclaimed slab by now \*/* 161 **struct** reclaim_state reclaim_state; 162 };

 

*Listing 11-36:* mm/vmscan.c: [*struct scan_control*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) *Data Fields*

 

Examining each of the fields shown in Listing 11-36:

 

**nr_to_reclaim** User-defined—Specifies the number of base pages to attempt

to reclaim.

**nodemask** User-defined—Specifies the nodes which we can consider for re-

claim.

**anon_cost** Set in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40)—Indicates the relative cost

of reclaiming anonymous folios as opposed to file-backed folios, as de-termined by working set logic which examines when folios which have previously been reclaimed are rapidly “refaulted”. A detailed discus-

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

sion of this is out of scope for the book, but both anonymous and file-

backed folio costs are maintained in [struct lruvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) fields, calculated in

[lru_note_cost()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n298) and [lru_note_cost_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n3388) which calls it, which is triggered

by the working set logic in [workingset_refault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/workingset.c?h=v6.0#n285). [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) simply sets

both anon_cost and file_cost fields based on the [struct lruvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) values. See

Section 11.5.2 for more on this.

**file_cost** Set in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40)—Indicates the relative cost

of reclaiming file-backed folios as opposed to anonymous folios. See anon_cost entry.

**order** User-defined—Specifies the order of the allocation which caused re-

claim to trigger.

**priority** User-defined—Specifies the number of pages we ought to consider

in this reclaim pass. Expressed in the form of a right shift value, typically

starting at [DEF_PRIORITY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838) (hard-coded to 12). A shift right of 12 bits for in-stance implies that we consider 1/4096th of the contents of LRU vectors

(see Section 11.2 for more on these).

**reclaim_idx** User-defined—Specifies the index of the maximum zone from

which the failing allocation can be performed.

**gfp_mask** User-defined—Specifies the Get Free Pages (GFP) mask of the fail-

ing allocation and thus the restrictions placed on the allocation.

**nr_scanned** Set by reclaim—A count of the number of base pages scanned (i.e.

examined) by reclaim.

**nr_reclaimed** Set by reclaim—A count of the number of base pages reclaimed

and thus freed by reclaim.

**nr.dirty** Set by reclaim—Aggregate of [struct reclaim_state-\>nr_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.h?h=v6.0#n24) counts—

The number of scanned folios (expressed in base pages) which are ei-

ther dirty (have the [PG_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n104) flag set) or undergoing writeback (have the

[PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag set).

**nr.unqueued_dirty** Set by reclaim—Aggregate of

[struct reclaim_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.h?h=v6.0#n24)-\>nr_unqueued_dirty counts—The number of scanned folios (expressed in base pages) which are dirty (have the

[PG_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n104) flag set) and have not yet been subject to writeback (does not

have the [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag set).

**nr.congested** Set by reclaim—Aggregate of [struct reclaim_state-\>nr_congested](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.h?h=v6.0#n24)

counts—The number of scanned folios (expressed in base pages) which

have both the [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) and [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) flags set, indicating this num-ber of pages have cycled through reclaim at least one more time with-out having completed writeback, indicating writeback congestion of re-claimed folios.

**nr.writeback** Set by reclaim—Aggregate of [struct reclaim_state-\>nr_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.h?h=v6.0#n24)

counts—The number of scanned folios (expressed in base pages) which

are undergoing writeback (have the [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag set) at the time of reclaim (and are not marked as immediate, as described in nr.immediate).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**nr.immediate** Set by reclaim—Aggregate of [struct reclaim_state-\>nr_immediate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.h?h=v6.0#n24)

counts—The number of file-backed folios (expressed in base pages)

which are undergoing writeback (have the [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag set), are be-

ing scanned by kswapd but are also marked with the [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) flag, indi-cating they are cycling through reclaim, after which we had determined that excess writeback was happening, as indicated by the node having

the [PGDAT_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n690) flag set (see the discussion around the portion of

[shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) examined in Listing 11-44 for details).

**nr.file_taken** Set by reclaim—The number of file-backed folios (expressed in

base pages) which have been isolated from LRUs for reclaim (isolation is

performed by [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) which we examine in Listing 11-57).

**nr.taken** Set by reclaim—The number of folios in total (expressed in base

pages) which have been isolated from LRUs for reclaim (isolation is per-

formed by [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) which we examine in Listing 11-57).

**reclaim_state** Set by reclaim—Slab-specific state updated after the slab alloca-

tor is able to free memory.

 

We examine the flag-specific fields of [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) in Listing 11-

37 (eliding out of scope cgroup, power management and NUMA demotion flags).

 

66 **struct** scan_control {

. . .

88 */\* Can active pages be deactivated as part of reclaim? \*/* 89 **\#define DEACTIVATE_ANON** 1 90 **\#define DEACTIVATE_FILE** 2 91 **unsigned int** may_deactivate:2; 92 **unsigned int** force_deactivate:1; 93 **unsigned int** skipped_deactivate:1; 94

95 */\* Writepage batching in laptop mode; RECLAIM_WRITE \*/* 96 **unsigned int** may_writepage:1; 97

98 */\* Can mapped pages be reclaimed? \*/* 99 **unsigned int** may_unmap:1;

100

101 */\* Can pages be swapped as part of reclaim? \*/* 102 **unsigned int** may_swap:1;

. . .

121 */\* One of the zones is ready for compaction \*/* 122 **unsigned int** compaction_ready:1; 123

124 */\* There is easily reclaimable cold cache in the current node \*/* 125 **unsigned int** cache_trim_mode:1; 126

127 */\* The file pages on the current node are dangerously low \*/* 128 **unsigned int** file_is_tiny:1;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

. . .

162 };

 

*Listing 11-37:* mm/vmscan.c: [*struct scan_control*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) *Flag Fields*

 

Each of these use the C bitfield syntax, where the number suffixing the

comma delimiter defines the number of bits each field occupies.

Examining each of the fields shown in Listing 11-37:

 

**may_deactivate** Set in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40)— Determines whether

reclaim can be permitted to interact with the active LRU vectors (see

Section 11.2 for more on active and inactive LRU vectors), i.e. whether

[shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663) (see Listing 11-55) can invoke [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) (see List-

ing 11-56). There are separate flags for anonymous and file-backed fo-

lios, defined as [DEACTIVATE_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n89) and [DEACTIVATE_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n90).

**force_deactivate** Set in [do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3583) (see Listing 11-20) as part of di-

rect reclaim—Forces deactivation of both file-backed and anonymous fo-lios. Set after an instance where deactivation is skipped to ensure these modes of reclaim are performed.

**skipped_deactivate** Set in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40)—Indicates that

force_deactivate was set so [shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663) (see Listing 11-55) did not in-

voke [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) (see Listing 11-56).

**may_writepage** User-defined—Specifies whether dirty folios can be written

back to disk as part of reclaim Checked in the core [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) function.

**may_swap** User-defined—Specifies whether we can swap out folios to disk as

part of the reclaim process.

**compaction_ready** Used by direct reclaim—Indicates that compaction is pre-

ferred over reclaim. Set in [shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3463) (see Listing 11-21), having been

determined to be applicable by [compaction_ready()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3398) and checked for in

[do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3583) (see Listing 11-20) which aborts the reclaim at-tempt deferring to compaction if this is set.

**cache_trim_mode** Set in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40)—Indicates that only

file-backed folios should be considered for reclaim in an instance where both deactivation of file-backed folios is prohibited and a large number of inactive file-backed folios are present in the LRU vector.

**file_is_tiny** Set in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40)—Indicates that a situa-

tion exists where there is a large number of anonymous folios subject to reclaim, deactivation of anonymous folios is prohibited and, even if all file-backed folios were freed, this would not fulfill indirect reclaim, that is, the sum of base pages for file-backed folios subject to reclaim and free file-backed folios is less than the aggregated high watermark across zones in a node. In this instance, we limit scanning to anonymous folios only.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

The reclaim process which [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) governs and which is in-

voked by both direct and indirect reclaim begins in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing

11-40) and proceeds through the code path as shown in Figure 11-11.

 

***11.5.2 A Brief Overview of the Working Set***

While a more detailed description of the working set functionality within the kernel is out of scope for the book, the data it provides forms a key part of the decision making in reclaim, so it is important to provide an overview of what it is and how the data it provides is determined.

The working set of a process is the range of memory that is required for

the process to function at any given point in time, i.e. the folios that the pro-cess is using.

We can expand this definition to the system as the memory in use by all

processes at a given point in time, and from the point of view of reclaim the working set matters in so far as—are we “thrashing” folios within the working set?

Thrashing in this context means we are repeatedly using folios but they

are being repeatedly reclaimed, i.e. faulting again (termed “refaulting”) shortly after reclaim.

The “refault distance”, equal to the number of folios scanned in the inac-

tive list between a folio being evicted and refaulted, is really critical here. We

examine this concept in Figure 11-12

 

Inactive Active

 

*Figure 11-12: Refault Distance Example*

 

In Figure 11-12, we consider the reclaim of the left-most folio (which sits

at the tail of the inactive list).

If the refault distance is less than the combined number of folios in the

inactive and active lists, then had the folio been activated, it would never have been reclaimed and thus never refaulted. This is illustrated by the solid arrow.

However, if the refault distance is greater than the sum of both inactive

and active list, which represents the entire reclaim cache, then nothing could have been done to prevent the thrashing—the user is attempting to use more memory than exists on the system (illustrated by the dashed line).

This is where this information becomes critically useful—if we are thrash-

ing in the former case, the working set logic activates the refaulting folio, so it will get referenced in time for it to avoid being reclaimed.

However this being the case implies that perhaps other folios on the

active list are being kept there longer than necessary, and in any case we should demote folios from the active list to make way for the newly pro-moted one.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

If we wrongly demote a folio that goes on to refault, then this mechanism

will correct the situation, so this is a safe thing to do.

Overall we can use this information to inform the balance between de-

moting from the active list and reclaiming from the inactive list—something

we examine in the discussion around Listing 11-41.

Examining how this is done in practice, we note that in both direct re-

claim in [do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3801) (see Listing 11-20) and indirect reclaim in

[balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) (see Listing 11-34), the [snapshot_refaults()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3556) function is called

after the reclaim is complete.

This takes a snapshot of the number of both refaulting anonymous folios

and refaulting file-backed folios that have been activated. We can then use

this snapshot data to determine whether we have refaulted more folios since

the last time we checked and therefore shrink the active list in this case.

The snapshot is performed by [snapshot_refaults()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3556) which we examine in

Listing 11-38.

 

3555 **static void snapshot_refaults**(**struct** mem_cgroup \*target_memcg, **pg_data_t** \*

pgdat)

3556 {

3557 **struct** lruvec \*target_lruvec; 3558 **unsigned long** refaults; 3559

3560 target_lruvec = **mem_cgroup_lruvec**(target_memcg, pgdat); 3561 refaults = **lruvec_page_state**(target_lruvec, **WORKINGSET_ACTIVATE_ANON**); 3562 target_lruvec-\>refaults\[0\] = refaults; 3563 refaults = **lruvec_page_state**(target_lruvec, **WORKINGSET_ACTIVATE_FILE**); 3564 target_lruvec-\>refaults\[1\] = refaults; 3565 }

 

*Listing 11-38:* mm/vmscan.c: [*snapshot_refaults()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3556)

 

The [snapshot_refaults()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3556) function updates the [struct lruvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) (see Section

11.2 for more on this type) which is associated with the specified node (ex-

cept under cgroup, the discussion of which is out of scope for the book).

This places the current anonymous folio refault and activate count (clas-

sified under [WORKINGSET_ACTIVATE_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n187)) in [struct lruvec-\>refaults\[0\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317), and

the current file-backed folio refault and activate count (classified under

[WORKINGSET_ACTIVATE_FILE ) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n188)in [struct lruvec-\>refaults\[1\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317).

 

**11.5.2.1 Anonymous and File-Backed Refault Costing**

It’s important to note that refaults can occur both when working sets

change, and when known active folios within the working set end up being

starved out of the active list and need to be reinstated.

In order to differentiate between the two, the [PG_workingset](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n107) flag is set by

[shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) (see Listing 11-56) and maintained throughout its life-

time to indicate that it was at least at one time part of the active LRU.

The [workingset_refault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/workingset.c?h=v6.0#n285) function, which is invoked when a refault oc-

curs, notes the presence of this flag and uses it to calculate a relative cost

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

between anonymous and file-backed folios, stored in [struct lruvec-\>anon_cost](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317)

and [struct lruvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317)-\>file_cost.

If we are experiencing a large amount of refaulting, that is thrashing of

anonymous folios compared to file-backed ones then we ought to prefer file-backed, and vice-versa.

This is calculated in [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2734) which we explore in Listing 11-47

and Section 11.5.4.

Therefore, on each occasion a folio which has previously been active is

refaulted, we account for its costs ultimately using [lru_note_cost()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n298)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n298) which we

explore in Listing 11-39.

In addition, if a dirty folio (whether file-backed or an anonymous folio

being swapped out) is successfully paged out to disk, we assume that this implies it was part of the working set and account accordingly.

 

298 **void lru_note_cost**(**struct** lruvec \*lruvec, **bool** file, **unsigned int** nr_pages) 299 {

300 **do** {

301 **unsigned long** lrusize; 302

303 */\**

304 *\* Hold lruvec-\>lru_lock is safe here, since* 305 *\* 1) The pinned lruvec in reclaim, or* 306 *\* 2) From a pre-LRU page during refault (which also holds the*

307 *\** *rcu lock, so would be safe even if the page was on the*

*LRU*

308 *\** *and could move simultaneously to a new lruvec).* 309 *\*/*

310 **spin_lock_irq**(&lruvec-\>lru_lock); 311 */\* Record cost event \*/* 312 **if** (file) 313 lruvec-\>file_cost += nr_pages; 314 **else**

315 lruvec-\>anon_cost += nr_pages; 316

317 */\**

318 *\* Decay previous events* 319 *\**

320 *\* Because workloads change over time (and to avoid* 321 *\* overflow) we keep these statistics as a floating* 322 *\* average, which ends up weighing recent refaults* 323 *\* more than old ones.* 324 *\*/*

325 lrusize = lruvec_page_state(lruvec, **NR_INACTIVE_ANON**) + 326 lruvec_page_state(lruvec, **NR_ACTIVE_ANON**) + 327 lruvec_page_state(lruvec, **NR_INACTIVE_FILE**) + 328 lruvec_page_state(lruvec, **NR_ACTIVE_FILE**); 329

330 **if** (lruvec-\>file_cost + lruvec-\>anon_cost \> lrusize / 4) {

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

331 lruvec-\>file_cost /= 2; 332 lruvec-\>anon_cost /= 2; 333 }

334 **spin_unlock_irq**(&lruvec-\>lru_lock); 335 } **while** ((lruvec = **parent_lruvec**(lruvec))); 336 }

 

*Listing 11-39:* mm/swap.c: [*lru_note_cost()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n298)

 

Since we do not consider the cgroup case in the book, we will not exam-

ine this outer loop in [lru_note_cost()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n298).

We start by simply accumulating the file and anonymous costs expressed

in base pages passed to this function. We then decay the values by half if

they, in aggregate, exceed one quarter of the size of the total number of base

LRU pages.

This has the effect of both ensuring we do not overflow and making

more recent refaults more meaningful than older ones.

This is later set to the [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>anon_cost and

[struct scan_control-\>file_cost](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) fields in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) as shown in Listing 11-

40 and Section 11.5.3.

 

***11.5.3 Shrinking the Node***

 

[shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)

 

[shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136)

 

[shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2950)

 

[shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)

 

[shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)

 

[shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)

 

*Figure 11-13: Reclaim Mechanism: Shrinking the Node Code Path*

 

The core reclaim logic, shared between all invocations of reclaim begins in

[shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) which we examine starting in Listing 11-40 (eliding any cgroup

logic that is entirely out of scope, and power management handling which

certainly is).

We examine the logic of this function in Figure 11-14.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Reset [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)

statistics in nr field.

 

Force deactivate?

Yes No

 

Set file-backed & anonymous Determine whether file-backed

pages in active LRU lists and/or anonymous pages are

to both be deactivated. thrashing, if so permit deactivation.

 

**Cache Trim Mode**

If we are able to reclaim file pages and they aren’t thrashing, enable

“cache trim mode”—this causes only file-backed pages to be reclaimed.

 

**Tiny File Mode**

If we are able to reclaim anonymous pages, they aren’t thrashing, and reclaim-

ing all file-backed pages wouldn’t stop kswapd—enable “tiny file mode” which

overrides cache trim mode and causes only anonymous pages to be reclaimed.

 

Perform reclaim via

[shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n)

 

When direct reclaiming, if

If all isolated pages are writing back,

[LRUVEC_CONGESTED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n312) set (meaning

mark node with [PGDAT_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n690) Yes No

Is kswapd? [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) and [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) were

so next time we reclaim them,

set for kswapd reclaim), throttle

we writeback immediately.

reclaim until written back.

 

If all isolated pages are dirty,

force reclaim to writeback

directly via [PGDAT_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n686).

If all isolated dirty pages have

both [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) and [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119)

If we see [PGDAT_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n690) pages are set, that is, we marked

If compaction could be done

a second time, these will be them for reclaim but they were

but we must free more

marked for immediate writeback, not written back before being

lower-order pages, loop.

throttle until written back. reclaimed again, these are

“congested” so set [LRUVEC_CONGESTED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n312)

Yes

and let direct reclaim throttle. Loop?

 

No

 

Done.

 

*Figure 11-14:* [*shrink_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) *Logic*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We start to examine [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) in Listing 11-40.

 

3194 **static void shrink_node**(**pg_data_t** \*pgdat, **struct** scan_control \*sc) 3195 {

3196 **struct** reclaim_state \*reclaim_state = **current**-\>reclaim_state; 3197 **unsigned long** nr_reclaimed, nr_scanned; 3198 **struct** lruvec \*target_lruvec; 3199 **bool** reclaimable = **false**; 3200 **unsigned long** file; 3201

3202 target_lruvec = **mem_cgroup_lruvec**(sc-\>target_mem_cgroup, pgdat); 3203

3204 **again**:

. . .

3211 **memset**(&sc-\>nr, 0, **sizeof**(sc-\>nr)); 3212

3213 nr_reclaimed = sc-\>nr_reclaimed; 3214 nr_scanned = sc-\>nr_scanned; 3215

3216 */\**

3217 *\* Determine the scan balance between anon and file LRUs.* 3218 *\*/*

3219 **spin_lock_irq**(&target_lruvec-\>lru_lock); 3220 sc-\>anon_cost = target_lruvec-\>anon_cost; 3221 sc-\>file_cost = target_lruvec-\>file_cost; 3222 **spin_unlock_irq**(&target_lruvec-\>lru_lock);

 

*Listing 11-40:* mm/vmscan.c: [*shrink_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) *Preface*

 

We start [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) by establishing some local state, including deter-

mining the [struct lruvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) which pertains to this cgroup or node.

Discussion of cgroups is out of the scope of the book, however this is

an instance where the function, while referencing cgroup state, performs

double-duty and in the case where cgroups are disabled, the [struct lruvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317)

(see Section 11.2 for more on this) is associated with the node and the

[mem_cgroup_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n730) function handles both cases.

We zero the [struct scan_control-\>nr](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) statistics object, then keep local

copies of the numbers of base pages scanned and reclaimed so far.

Finally, we retrieve the anonymous and file costs associated with anony-

mous and file folio reclaim (see Section 11.5.2 for details of how these are

calculated). We will examine how these values are used in the functions

which reference them.

Once this initialisation is complete, we proceed with determining

whether deactivation of anonymous and file-backed folios ought to proceed,

which we explore in Listing 11-41.

 

3224 */\**

3225 *\* Target desirable inactive:active list ratios for the anon* 3226 *\* and file LRU lists.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3227 *\*/*

3228 **if** (!sc-\>force_deactivate) { 3229 **unsigned long** refaults; 3230

3231 refaults = **lruvec_page_state**(target_lruvec, 3232 **WORKINGSET_ACTIVATE_ANON**); 3233 **if** (refaults != target_lruvec-\>refaults\[0\] \|\| 3234 **inactive_is_low**(target_lruvec, **LRU_INACTIVE_ANON**)) 3235 sc-\>may_deactivate \|= **DEACTIVATE_ANON**; 3236 **else**

3237 sc-\>may_deactivate &= ~**DEACTIVATE_ANON**; 3238

3239 */\**

3240 *\* When refaults are being observed, it means a new* 3241 *\* workingset is being established. Deactivate to get* 3242 *\* rid of any stale active pages quickly.* 3243 *\*/*

3244 refaults = **lruvec_page_state**(target_lruvec, 3245 **WORKINGSET_ACTIVATE_FILE**); 3246 **if** (refaults != target_lruvec-\>refaults\[1\] \|\| 3247 **inactive_is_low**(target_lruvec, **LRU_INACTIVE_FILE**)) 3248 sc-\>may_deactivate \|= **DEACTIVATE_FILE**; 3249 **else**

3250 sc-\>may_deactivate &= ~**DEACTIVATE_FILE**; 3251 } **else**

3252 sc-\>may_deactivate = **DEACTIVATE_ANON** \| **DEACTIVATE_FILE**;

 

*Listing 11-41:* mm/vmscan.c: [*shrink_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) *Active/Inactive Ratio Logic*

 

The active/inactive ratio logic portion of [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (ex-

plored in Listing 11-41) starts by simply checking whether

[struct scan_control-\>force_deactivate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) has been set—this is set in

[do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3583) as part of direct reclaim if previously deactivation had been skipped.

Otherwise, we determine whether further refaulting has occurred by

checking whether the current number of activated refaulted anonymous and

file-backed folios differs from the last snapshotted values. See Section 11.5.2 for a discussion of this logic.

If so, we permit deactivation of folios from the anonymous and/or file-

backed LRU lists accordingly, by setting [DEACTIVATE_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n89) and [DEACTIVATE_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n90)

flags in [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>may_deactivate.

We also do so if the inactive LRU list is considered to be too small, as

checked by [inactive_is_low()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2705), which we examine in Listing 11-42.

 

2677 */\**

2678 *\* The inactive anon list should be small enough that the VM never has* 2679 *\* to do too much work.*

2680 *\**

2681 *\* The inactive file list should be small enough to leave most memory*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2682 *\* to the established workingset on the scan-resistant active list,* 2683 *\* but large enough to avoid thrashing the aggregate readahead window.* 2684 *\**

2685 *\* Both inactive lists should also be large enough that each inactive* 2686 *\* page has a chance to be referenced again before it is reclaimed.* 2687 *\**

2688 *\* If that fails and refaulting is observed, the inactive list grows.* 2689 *\**

2690 *\* The inactive_ratio is the target ratio of ACTIVE to INACTIVE pages* 2691 *\* on this LRU, maintained by the pageout code. An inactive_ratio* 2692 *\* of 3 means 3:1 or 25% of the pages are kept on the inactive list.* 2693 *\**

2694 *\* total* *target* *max* 2695 *\* memory* *ratio* *inactive* 2696 *\* -------------------------------------*2697 *\** *10MB* *1* *5MB* 2698 *\* 100MB* *1* *50MB* 2699 *\** *1GB* *3* *250MB* 2700 *\** *10GB* *10* *0.9GB* 2701 *\* 100GB* *31* *3GB* 2702 *\** *1TB* *101* *10GB* 2703 *\** *10TB* *320* *32GB* 2704 *\*/*

2705 **static bool inactive_is_low**(**struct** lruvec \*lruvec, **enum** lru_list inactive_lru) 2706 {

2707 **enum** lru_list active_lru = inactive_lru + **LRU_ACTIVE**; 2708 **unsigned long** inactive, active; 2709 **unsigned long** inactive_ratio; 2710 **unsigned long** gb; 2711

2712 inactive = **lruvec_page_state**(lruvec, **NR_LRU_BASE** + inactive_lru); 2713 active = **lruvec_page_state**(lruvec, **NR_LRU_BASE** + active_lru); 2714

2715 gb = (inactive + active) \>\> (30 -**PAGE_SHIFT**); 2716 **if** (gb)

2717 inactive_ratio = **int_sqrt**(10 \* gb); 2718 **else**

2719 inactive_ratio = 1; 2720

2721 **return** inactive \* inactive_ratio \< active; 2722 }

 

*Listing 11-42:* mm/vmscan.c: [*inactive_is_low()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2705)

 

We can see in [inactive_is_low()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2705) that we try to maintain a balance between

active and inactive lists which is heavily weighted towards the active list in

order that we avoid reclaiming as much as we can, reducing the amount of

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

work reclaim needs to do and giving folios the maximum chance to avoid reclaim.

The refaulting logic previously described accounts for situations where

folios ought to deactivated so the combination of the two combines a well-tuned heuristic with a mechanism for avoiding thrashing under heavy mem-ory pressure.

With the balance between active and inactive LRU lists accounted for, we

proceed with further configuration of the [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) object prior to

executing reclaim, which we explore in Listing 11-43.

 

3254 */\**

3255 *\* If we have plenty of inactive file pages that aren't* 3256 *\* thrashing, try to reclaim those first before touching* 3257 *\* anonymous pages.* 3258 *\*/*

3259 file = **lruvec_page_state**(target_lruvec, **NR_INACTIVE_FILE**); 3260 **if** (file \>\> sc-\>priority && !(sc-\>may_deactivate & **DEACTIVATE_FILE**)) 3261 sc-\>cache_trim_mode = 1; 3262 **else**

3263 sc-\>cache_trim_mode = 0; 3264

3265 */\**

3266 *\* Prevent the reclaimer from falling into the cache trap: as* 3267 *\* cache pages start out inactive, every cache fault will tip* 3268 *\* the scan balance towards the file LRU. And as the file LRU* 3269 *\* shrinks, so does the window for rotation from references.* 3270 *\* This means we have a runaway feedback loop where a tiny* 3271 *\* thrashing file LRU becomes infinitely more attractive than* 3272 *\* anon pages. Try to detect this based on file LRU size.* 3273 *\*/*

. . .

3275 **unsigned long** total_high_wmark = 0; 3276 **unsigned long** free, anon; 3277 **int** z;

3278

3279 free = **sum_zone_node_page_state**(pgdat-\>node_id, **NR_FREE_PAGES**)

;

3280 file = **node_page_state**(pgdat, **NR_ACTIVE_FILE**) + 3281 **node_page_state**(pgdat, **NR_INACTIVE_FILE**); 3282

3283 **for** (z = 0; z \< **MAX_NR_ZONES**; z++) { 3284 **struct** zone \*zone = &pgdat-\>node_zones\[z\]; 3285 **if** (!**managed_zone**(zone)) 3286 **continue**; 3287

3288 total_high_wmark += **high_wmark_pages**(zone); 3289 }

3290

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3291 */\**

3292 *\* Consider anon: if that's low too, this isn't a* 3293 *\* runaway file reclaim problem, but rather just* 3294 *\* extreme pressure. Reclaim as per usual then.* 3295 *\*/*

3296 anon = **node_page_state**(pgdat, **NR_INACTIVE_ANON**); 3297

3298 sc-\>file_is_tiny = 3299 file + free \<= total_high_wmark && 3300 !(sc-\>may_deactivate & **DEACTIVATE_ANON**) && 3301 anon \>\> sc-\>priority;

 

*Listing 11-43:* mm/vmscan.c: [*shrink_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) *Further Reclaim Configuration*

 

Examining the portion of [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) which performs addi-

tional reclaim configuration as shown in Listing 11-43, we start by

determining whether we enable the cache trim mode specified in

[struct scan_control-\>cache_trim_mode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66).

In this mode, we prefer to only examine file folios (as determined by

[get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) which we examine later in Listing 11-47 and Section 11.5.4).

We do so if there are sufficient file folios that they will be scanned at this

priority level and there’s no indication that they are thrashing (if they were

thrashing then [struct scan_control-\>may_deactivate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) will have [DEACTIVATE_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n90)

set.

This clearly demonstrates that there is a preference for reclaiming file-

backed folios if this is possible, before trying to reclaim anonymous folios, as

the latter is likely to be more of an expensive operation than the former.

Having said this, we then must be cautious to avoid a degenerate sce-

nario where we simply never reclaim anonymous folios because we prefer

to reclaim file-backed folios, which could cause a small number of file folios

to dominate reclaim while ignoring a larger set of anonymous folios.

We detect this by first determining whether the sum of all free base

pages and inactive and active file LRU base pages is less than or equal to

the sum of zone high water marks—this means freeing file folios alone will

not allow kswapd to sleep and thus reclaim will continue running potentially

indefinitely.

We also make sure that the anonymous LRU is not thrashing (that anony-

mous folios are not permitted to deactivate) which otherwise would indicate

that focusing on the file folios would not be problematic.

Finally we make sure that the number of inactive anonymous folios is suf-

ficiently large that we could perform anonymous folio reclaim at this priority

level, if this was not the case then it just indicates that we are under severe

memory pressure generally.

If these conditions are met, we set [struct scan_control-\>file_is_tiny](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)

which overrides [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>cache_trim_mode and causes only anony-

mous folios to be scanned, as set in [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) (see Listing 11-47 and

Section 11.5.4).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

With the [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) object set up, we are ready to perform the

actual reclaim and tasks after reclaim has been executed, we examine this

portion of [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) in Listing 11-44.

 

3304 **shrink_node_memcgs**(pgdat, sc); 3305

3306 **if** (reclaim_state) { 3307 sc-\>nr_reclaimed += reclaim_state-\>reclaimed_slab; 3308 reclaim_state-\>reclaimed_slab = 0; 3309 }

. . .

3317 **if** (sc-\>nr_reclaimed - nr_reclaimed) 3318 reclaimable = **true**; 3319

3320 **if** (**current_is_kswapd**()) { 3321 */\**

3322 *\* If reclaim is isolating dirty pages under writeback,*

3323 *\* it implies that the long-lived page allocation rate* 3324 *\* is exceeding the page laundering rate. Either the* 3325 *\* global limits are not being effective at throttling* 3326 *\* processes due to the page distribution throughout* 3327 *\* zones or there is heavy usage of a slow backing* 3328 *\* device. The only option is to throttle from reclaim* 3329 *\* context which is not ideal as there is no guarantee* 3330 *\* the dirtying process is throttled in the same way* 3331 *\* balance_dirty_pages() manages.* 3332 *\**

3333 *\* Once a node is flagged PGDAT_WRITEBACK, kswapd will* 3334 *\* count the number of pages under pages flagged for* 3335 *\* immediate reclaim and stall if any are encountered* 3336 *\* in the nr_immediate check below.* 3337 *\*/*

3338 **if** (sc-\>nr.writeback && sc-\>nr.writeback == sc-\>nr.taken) 3339 **set_bit**(**PGDAT_WRITEBACK**, &pgdat-\>flags); 3340

3341 */\* Allow kswapd to start writing pages during reclaim.\*/*

3342 **if** (sc-\>nr.unqueued_dirty == sc-\>nr.file_taken) 3343 **set_bit**(**PGDAT_DIRTY**, &pgdat-\>flags); 3344

3345 */\**

3346 *\* If kswapd scans pages marked for immediate* 3347 *\* reclaim and under writeback (nr_immediate), it* 3348 *\* implies that pages are cycling through the LRU* 3349 *\* faster than they are written so forcibly stall* 3350 *\* until some pages complete writeback.* 3351 *\*/*

3352 **if** (sc-\>nr.immediate) 3353 **reclaim_throttle**(pgdat, **VMSCAN_THROTTLE_WRITEBACK**);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3354 }

3355

3356 */\**

3357 *\* Tag a node/memcg as congested if all the dirty pages were marked*

3358 *\* for writeback and immediate reclaim (counted in nr.congested).*

. . .

3362 *\*/*

3363 **if** ((**current_is_kswapd**() \|\| 3364 (**cgroup_reclaim**(sc) && **writeback_throttling_sane**(sc))) && 3365 sc-\>nr.dirty && sc-\>nr.dirty == sc-\>nr.congested) 3366 **set_bit**(**LRUVEC_CONGESTED**, &target_lruvec-\>flags); 3367

3368 */\**

3369 *\* Stall direct reclaim for IO completions if the lruvec is* 3370 *\* node is congested. Allow kswapd to continue until it* 3371 *\* starts encountering unqueued dirty pages or cycling through* 3372 *\* the LRU too quickly.* 3373 *\*/*

3374 **if** (!**current_is_kswapd**() && **current_may_throttle**() &&

. . .

3376 **test_bit**(**LRUVEC_CONGESTED**, &target_lruvec-\>flags)) 3377 **reclaim_throttle**(pgdat, **VMSCAN_THROTTLE_CONGESTED**); 3378

3379 **if** (**should_continue_reclaim**(pgdat, sc-\>nr_reclaimed - nr_reclaimed, 3380 sc)) 3381 **goto again**; 3382

3383 */\**

3384 *\* Kswapd gives up on balancing particular nodes after too* 3385 *\* many failures to reclaim anything from them and goes to* 3386 *\* sleep. On reclaim progress, reset the failure counter. A* 3387 *\* successful direct reclaim run will revive a dormant kswapd.* 3388 *\*/*

3389 **if** (reclaimable)

3390 pgdat-\>kswapd_failures = 0; 3391 }

 

*Listing 11-44:* mm/vmscan.c: [*shrink_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) *Reclaim and Post-processing*

 

We perform the actual reclaim via [shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136) which we examine

in Listing 11-50 and Section 11.5.5.

After this is done, we first check to see whether we need to update the

[struct scan_control-\>reclaim_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) to store statistics about memory freed by

the slab freeing mechanism.

Then we determine if we made any progress, i.e. whether we actually

reclaimed any folios, which we store in the boolean reclaimable variable.

We then consider indirect reclaim-specific logic, predicated on the

[current_is_kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n37) function.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Firstly, we compare the number of pages which are undergoing

writeback (i.e. have the [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag set) in this scan, (stored in

[struct scan_control-\>nr.writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)) to the number of pages which we have “iso-

lated” (stored in [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>nr.taken).

Isolated pages are those which have been removed from LRU lists in

preparation for being reclaimed, as performed by [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) which

we examine in Listing 11-57 later in the chapter.

If the two are equal, then this suggests that we are not throttling dirty

pages fast enough to avoid having to write them back (see Section 10.14

in Chapter 10 for details about the dirty page balance throttle mechanism

on writeback) or reclaim is not being throttled (see Section 11.6 for details about reclaim throttle).

In this case we set the [PGDAT_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n690) node flag, which causes the core

reclaim function [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) (see Listing 11-63 in Section 11.5.9), when performing kswapd reclaim, to mark these pages for immediate reclaim

by ultimately incrementing [struct scan_control-\>nr.immediate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) rather than

[struct scan_control-\>nr.writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66). This ultimately results in reclaim throttling (we discuss this case momentarily).

Next we examine the number of unqueued dirty pages — these are pages

belonging to folios which are dirty but do not yet have the [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag set. If these are equal to the number of file pages isolated for reclaim this indicates that we have a very large number of dirty pages and thus set the

[PGDAT_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n686) flag on the node.

The [PGDAT_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n686) flag causes [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) (see Listing 11-63 in Sec-

tion 11.5.9), for indirect reclaim (that is kswapd) to write back file-backed fo-lios directly rather than waiting for the ordinary write back process to com-

plete (see Chapter 10).

Next we check to see if any [PGDAT_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n690) pages were flagged for

immediate reclaim (again in the case that indirect reclaim is being per-

formed), in which case we throttle reclaim via [reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104) setting the

[VMSCAN_THROTTLE_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n288) flag (see Listing 11-75 in Section 11.6 for details).

Next we consider the case, in indirect reclaim (tested via

[current_is_kswapd(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n37)note that the cgroup and sanity test on line 3364 are out of scope for the book but evaluate to false if cgroup is disabled) where

there are dirty or writeback pages (as stored in [struct scan_control-\>nr.dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)) and these are equal to the number of “congested” pages stored in

[struct scan_control-\>nr.congested](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66).

The congested count is equal to the number of pages which are in write-

back and have the [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) flag set, meaning they have looped around the inactive LRU vector again and have yet to be written back.

If this count is equal to the number of writeback pages, then this

means we are cycling through reclaim unable to make forward progress for file-backed pages. This implies heavy congestion, and so we set the

[LRUVEC_CONGESTED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n312) flag for the LRU vector to indicate this fact.

In the very next predicate we examine whether this is set for the di-

rect reclaim case. We do not do so for indirect reclaim, throttling in this

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

case only when all of the scanned folios are undergoing writeback as in the

[VMSCAN_THROTTLE_CONGESTED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n291) throttle case previously mentioned.

We invoke [current_may_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2392) to determine if the current thread can

throttle, this is only not the case in peculiar edge cases.

In this case we invoke the throttling via [reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104) setting the

[VMSCAN_THROTTLE_CONGESTED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n291) flag (see Listing 11-75 in Section 11.6 for details).

Having examined all these throttle cases, we determine whether we

should repeat the reclaim attempt via [should_continue_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n). We exam-

ine this in Listing 11-45 shortly.

Otherwise, if we performed at least some reclaim, we reset the

[struct pglist_data-\>kswapd_failures](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) counter. This is because we’ve made

progress, and we don’t want to give up on reclaim as a result.

If we did not do this, then kswapd could spin uselessly rather than going

to sleep after [MAX_RECLAIM_RETRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n170) attempts with no progress (hard-coded to

sixteen).

 

3076 */\**

3077 *\* Reclaim/compaction is used for high-order allocation requests. It reclaims*

3078 *\* order-0 pages before compacting the zone. should_continue_reclaim() returns*

3079 *\* true if more pages should be reclaimed such that when the page allocator*

3080 *\* calls try_to_compact_pages() that it will have enough free pages to succeed*

*.*

3081 *\* It will give up earlier than that if there is difficulty reclaiming pages.*

3082 *\*/*

3083 **static inline bool should_continue_reclaim**(**struct** pglist_data \*pgdat, 3084 **unsigned long** nr_reclaimed, 3085 **struct** scan_control \*sc) 3086 {

3087 **unsigned long** pages_for_compaction; 3088 **unsigned long** inactive_lru_pages; 3089 **int** z;

3090

3091 */\* If not in reclaim/compaction mode, stop \*/* 3092 **if** (!**in_reclaim_compaction**(sc)) 3093 **return false**; 3094

3095 */\**

3096 *\* Stop if we failed to reclaim any pages from the last*

*SWAP_CLUSTER_MAX*

3097 *\* number of pages that were scanned. This will return to the caller*

3098 *\* with the risk reclaim/compaction and the resulting allocation*

*attempt*

3099 *\* fails. In the past we have tried harder for \_\_GFP_RETRY_MAYFAIL*

3100 *\* allocations through requiring that the full LRU list has been*

*scanned*

3101 *\* first, by assuming that zero delta of sc-\>nr_scanned means full LRU*

3102 *\* scan, but that approximation was wrong, and there were corner cases*

3103 *\* where always a non-zero amount of pages were scanned.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3104 *\*/*

3105 **if** (!nr_reclaimed) 3106 **return false**; 3107

3108 */\* If compaction would go ahead or the allocation would succeed, stop*

*\*/*

3109 **for** (z = 0; z \<= sc-\>reclaim_idx; z++) { 3110 **struct** zone \*zone = &pgdat-\>node_zones\[z\]; 3111 **if** (!**managed_zone**(zone)) 3112 **continue**; 3113

3114 **switch** (**compaction_suitable**(zone, sc-\>order, 0, sc-\>

reclaim_idx)) {

3115 **case COMPACT_SUCCESS**: 3116 **case COMPACT_CONTINUE**: 3117 **return false**; 3118 **default**:

3119 */\* check next zone \*/* 3120 ; 3121 }

3122 }

3123

3124 */\**

3125 *\* If we have not reclaimed enough pages for compaction and the* 3126 *\* inactive lists are large enough, continue reclaiming* 3127 *\*/*

3128 pages_for_compaction = **compact_gap**(sc-\>order); 3129 inactive_lru_pages = **node_page_state**(pgdat, **NR_INACTIVE_FILE**); 3130 **if** (**can_reclaim_anon_pages**(**NULL**, pgdat-\>node_id, sc)) 3131 inactive_lru_pages += **node_page_state**(pgdat, **NR_INACTIVE_ANON**)

;

3132

3133 **return** inactive_lru_pages \> pages_for_compaction; 3134 }

 

*Listing 11-45:* mm/vmscan.c: [*should_continue_reclaim()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3083)

 

The [should_continue_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3083) is only relevant for allocations of higher

order folios for which we intend to invoke compaction. As previously men-tioned, compaction is out of scope for the book, but is the process through which the kernel migrates movable folios (those with a movable migrate

type, see Section 2.5 in Chapter 2 for details), i.e. moves them in physical memory such that adjacent free folios of lower order can be coalesced into a higher order free folio.

Even though this is out of scope, it is a key part of how reclaim performs,

so like working set logic, it is important to examine how it interfaces with re-claim, even if we don’t go into the details of how compaction itself proceeds.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

The [should_continue_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3083) function returns true if we need to per-

form more reclaim to free up sufficient pages for compaction to suc-

ceed. Note that we wake up the kernel compaction thread kcompactd in

[kswapd_try_to_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4372) as shown in Listing 11-28 and Section 11.4.3.

We start by determining whether this is reclaim subject to compaction

via [in_reclaim_compaction()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3066) which we examine in Listing 11-46.

 

3065 */\* Use reclaim/compaction for costly allocs or under memory pressure \*/* 3066 **static bool in_reclaim_compaction**(**struct** scan_control \*sc) 3067 {

3068 **if** (**IS_ENABLED**(**CONFIG_COMPACTION**) && sc-\>order && 3069 (sc-\>order \> **PAGE_ALLOC_COSTLY_ORDER** \|\| 3070 sc-\>priority \< **DEF_PRIORITY**- 2)) 3071 **return true**; 3072

3073 **return false**;

3074 }

 

*Listing 11-46:* mm/vmscan.c: [*in_reclaim_compaction()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3066)

 

The [in_reclaim_compaction()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3066) function checks that firstly compaction is en-

abled, that an allocation of an order-4 or greater folio caused the reclaim

(since [PAGE_ALLOC_COSTLY_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40) is hard-coded to three), or an allocation of an

order-1 or greater folio and we on the fourth iteration or more of reclaim

due to [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>priority being less than [DEF_PRIORITY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838) minus two.

Returning to [should_continue_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3083) in Listing 11-45, we see that we

don’t consider continuing to reclaim if [in_reclaim_compaction()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3066) indicates the

allocation is not suited to compaction. Equally, we abort if no folios were

reclaimed at all.

Then we check to see if any zone from which we could allocate are in a

state suitable for compaction via [compaction_suitable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2221)—if any are then we

exit indicating that reclaim should not continue.

Finally, we check to ensure there are sufficient inactive folios (expressed

in base pages) such that we could reclaim enough to perform compaction

and use this to determine whether reclaim should continue.

We determine the number of pages we ought to have available via

[compact_gap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/compaction.h?h=v6.0#n65) which is equal to double the number of base pages of the order

which failed allocation, and is considered a good heuristic for the number of

free pages we require to succeed at compaction.

We then retrieve a count of inactive folios (expressed in base pages), in-

cluding anonymous folios only if [can_reclaim_anon_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n541), which first checks

that there are at least some swap pages we could swap out to, and if not

whether NUMA demotion is available (a topic out of scope for the book).

If the total of these inactive pages exceeds the number of base pages we

require for compaction, then continuing reclaim is worthwhile, otherwise it

is not.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

***11.5.4 Determining Scan Balance***

As per Figure 11-11, the next substantive layer of reclaim, performed after

the [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) is configured, is [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) (see Listing 11-51 and

Section 11.5.5).

A key function which [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) invokes is [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) which

determines the scanning split between file-backed and anonymous folios.

We examine this in Listing 11-47 (eliding out of scope cgroup logic where doing so wouldn’t confuse the logic).

 

2731 */\**

2732 *\* Determine how aggressively the anon and file LRU lists should be* 2733 *\* scanned.*

2734 *\**

2735 *\* nr\[0\] = anon inactive pages to scan; nr\[1\] = anon active pages to scan* 2736 *\* nr\[2\] = file inactive pages to scan; nr\[3\] = file active pages to scan* 2737 *\*/*

2738 **static void get_scan_count**(**struct** lruvec \*lruvec, **struct** scan_control \*sc, 2739 **unsigned long** \*nr) 2740 {

2741 **struct** pglist_data \*pgdat = **lruvec_pgdat**(lruvec); 2742 **struct** mem_cgroup \*memcg = **lruvec_memcg**(lruvec); 2743 **unsigned long** anon_cost, file_cost, total_cost; 2744 **int** swappiness = **mem_cgroup_swappiness**(memcg); 2745 **u64** fraction\[**ANON_AND_FILE**\]; 2746 **u64** denominator = 0; */\* gcc \*/* 2747 **enum** scan_balance scan_balance; 2748 **unsigned long** ap, fp; 2749 **enum** lru_list lru; 2750

2751 */\* If we have no swap space, do not bother scanning anon pages. \*/*

2752 **if** (!sc-\>may_swap \|\| !**can_reclaim_anon_pages**(memcg, pgdat-\>node_id, sc

)) {

2753 scan_balance = **SCAN_FILE**; 2754 **goto out**; 2755 }

. . .

2769 */\**

2770 *\* Do not apply any pressure balancing cleverness when the* 2771 *\* system is close to OOM, scan both anon and file equally* 2772 *\* (unless the swappiness setting disagrees with swapping).* 2773 *\*/*

2774 **if** (!sc-\>priority && swappiness) { 2775 scan_balance = **SCAN_EQUAL**; 2776 **goto out**; 2777 }

2778

2779 */\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2780 *\* If the system is almost out of file pages, force-scan anon.* 2781 *\*/*

2782 **if** (sc-\>file_is_tiny) { 2783 scan_balance = **SCAN_ANON**; 2784 **goto out**; 2785 }

2786

2787 */\**

2788 *\* If there is enough inactive page cache, we do not reclaim* 2789 *\* anything from the anonymous working right now.* 2790 *\*/*

2791 **if** (sc-\>cache_trim_mode) { 2792 scan_balance = **SCAN_FILE**; 2793 **goto out**; 2794 }

 

*Listing 11-47:* mm/vmscan.c: [*get_scan_count()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) *Initialisation & Edge Cases*

 

The [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) function maintains a [enum_scan_balance](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2724) value, which

indicates how to proceed in the latter part of the function—[SCAN_EQUAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2725) in-

dicates that each list should be scanned according to the priority-adjusted

number of pages in each list, i.e. we should not adjust the number of pages

available to scan.

[SCAN_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2727) indicates that only anonymous folios should be scanned and

[SCAN_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2728) indicates that only file-backed folios should be scanned.

Finally, [SCAN_FRACT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2726) is the typical mode in which [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) operates,

which distributes base pages to scan based on a heuristically determined

fraction.

The nr output parameter, which points to an unsigned long array of size

four, defines how many base pages should be scanned for anonymous inac-

tive, active, file-backed inactive and active LRUs respectively, and is set in all

cases.

We start by examining initialisation and the edge cases in Listing 11-47,

before examining the [SCAN_FRACT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2726) case in Listing 11-48.

The logic starts with initialisation, most notably invoking

[mem_cgroup_swappiness()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n618). This, in the non-cgroup case, returns the system-

wide “swappiness” value which is an integer value indicating the degree to

which the system has a preference for swapping out to disk. It is expressed

in a range from 0 to 200, with 0 indicating a complete aversion to swapping

and 200 indicating a preference for only swapping, with 100 an equal spread

between the two.

The global swappiness value is stored in the [vm_swappiness](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n181) variable, which

defaults to 60.

We then consider a series of edge cases—if the swap is either disallowed

or no swap entries exist, we set [SCAN_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2728).

If we have reached zero priority and are thus scanning everything, and

swappiness is non-zero, then at this point where we are close to an Out Of

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Memory (OOM) condition, we do not adjust the number of pages to scan in

each LRU, setting the mode to [SCAN_EQUAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2725).

If the [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>file_is_tiny predicate is set, indicating that we

are running low on file-backed folios, then we prefer anonymous folios and

set the scan mode to [SCAN_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2727) (see discussion of [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) around Listing

11-43 where this is set for details).

Finally, if cache trim mode is enabled, set in

[struct scan_control-\>cache_trim_mode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66), then this indicates we have suffi-cient file-backed folios to free and we are not thrashing them, so we prefer

to free file folios, and thus return [SCAN_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2728) (see discussion of [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)

around Listing 11-43 where this is set for details).

 

**N O T E** Cache trim mode is a key feature of the page cache—the kernel will happily fill up the

memory with as much on-disk data as is accessed and keep hold of it, however it’ll equally discard it just as quickly. As soon as we reach data that is thrashing or if the inactive file LRU runs low, we attempt to balance reclaim.

 

We examine the [SCAN_FRACT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2726) case in Listing 11-48.

 

2796 scan_balance = **SCAN_FRACT**; 2797 */\**

2798 *\* Calculate the pressure balance between anon and file pages.* 2799 *\**

2800 *\* The amount of pressure we put on each LRU is inversely* 2801 *\* proportional to the cost of reclaiming each list, as* 2802 *\* determined by the share of pages that are refaulting, times* 2803 *\* the relative IO cost of bringing back a swapped out* 2804 *\* anonymous page vs reloading a filesystem page (swappiness).* 2805 *\**

2806 *\* Although we limit that influence to ensure no list gets* 2807 *\* left behind completely: at least a third of the pressure is* 2808 *\* applied, before swappiness.* 2809 *\**

2810 *\* With swappiness at 100, anon and file have equal IO cost.* 2811 *\*/*

2812 total_cost = sc-\>anon_cost + sc-\>file_cost; 2813 anon_cost = total_cost + sc-\>anon_cost; 2814 file_cost = total_cost + sc-\>file_cost; 2815 total_cost = anon_cost + file_cost; 2816

2817 ap = swappiness \* (total_cost + 1); 2818 ap /= anon_cost + 1; 2819

2820 fp = (200 - swappiness) \* (total_cost + 1); 2821 fp /= file_cost + 1; 2822

2823 fraction\[0\] = ap; 2824 fraction\[1\] = fp;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2825 denominator = ap + fp;

 

*Listing 11-48:* mm/vmscan.c: [*get_scan_count()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) *Fractional Case*

 

In the portion of [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) that calculates the division of pages to

scan in the [SCAN_FRACT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2726) mode shown in Listing 11-48 we determine nomina-

tor values for anonymous and file-backed pages in the fraction array of size

[ANON_AND_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n309) which is hard-coded to two, and the denominator of the fraction.

Here we make use of the refault statistics [struct scan_control-\>anon_cost](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)

and [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>file_cost, combined with the swappiness statistic

(see Section 11.5.2 for a brief explanation of these).

The calculation here is rather fiddly so let’s take it step by step. We start

by combining these values into a total cost, then defining anonymous page

cost and file cost each equal to the sum of the total cost and the respective

cost to which the value refers.

We then redefine the total cost to be the sum of these two values. This is very confusing, so let’s denote the anonymous page cost as *a*,

the file-backed page cost as *f* , the newly-calculated anonymous cost (i.e.

anon_cost) as *A*, the newly-calculated file-backed cost (i.e. file_cost) as *F* , the

original total cost (total_cost) as *t* and the redefined total cost as *T* and ex-

amine what this looks like:

*t* = *a* + *f*

*A* = *t* + *a* = (*a* + *f* ) + *a* = 2*a* + *f*

*F* = *t* + *f* = (*a* + *f* ) + *f* = *a* + 2*f*

*T* = *A* + *F* = 2*a* + *f* + *a* + 2*f* = 3*a* + 3*f*

From here we use *T* , *A*, *F* and the swappiness parameter (we denote this as

*S* ) to calculate anonymous and file-backed fractions.

Note that we add one to values here in order to avoid divide-by zero or

zeroed multipliers when performing integer arithmetic, something the ker-

nel has to be very careful of as it is not permitted to perform floating point

arithmetic within the kernel.

For the purposes of simplifying this calculation, we will ignore these off-

sets.

Therefore, denoting the anonymous page numerator as *ap* as in the

code, and the file-backed page denominator as *f p*:

 

*ap* *ST* (200 *−* *S*)*T* = *f p* = *A* *F*

The denominator (as named in the code) is equal to the some of the two.

We denote this *D*:

 

*D* *ST* (200 *−* *S*)*T* = + *A* *F*

We can now calculate the fraction of anonymous pages (denoted as *F r**a* ) and

the fraction of file-backed pages (denoted as *F r**f* ):

*ST*

 

*F r* *A* *a* = *ST* (200 *−* *S*)*T* +

*A* *F*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

(200 *−* *S*)*T*

 

*F r* *F* *f* = *ST* (200 *−* *S*)*T* +

*A* *F*

Dividing numerator and denominator by *T* yields:

*S*

 

*F r* *A* *a* = *S* 200 *−* *S* +

*A* *F*

200 *−* *S*

 

*F r* *F* *f* = *S* 200 *−* *S* +

*A* *F*

Multiplying numerator and denominator by *AF* simplifies:

 

*F r* *SF* (200 *−* *S*)*A* = *a* , *F r* *f* = *SF* + (200 *−* *S* ) *A* *SF* + (200 *−* *S*)*A*

Since the purpose of the denominator is solely to divide each fraction by the sum of the nominators, i.e. to determine the relative proportion of anony-mous and file-backed pages, let’s redefine *D* to the new denominator and

express the equations in terms of the [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>anon_cost and

[struct scan_control-\>file_cost](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) values, *a* and *f* respectively:

*SF* *S*(*a* + 2*f* )

*F r**a* = =

*D* *D*

 

*F r* (200 *−* *S*)*A* (200 *−* *S*)(2*a* + *f* ) = *f* = *D* *D*

 

**N O T E** Having removed the offset-by-1 cases for simplicity, we note that here we can treat

there being no refaults as equivalent to there being an equal number of refaults, that is if *a* and *f* are equal to zero, consider this equivalent to them both being equal to one.

 

The fraction of anonymous pages is proportional to swappiness multi-

plied by the sum of anonymous refaults and double the file-backed refaults, or in other words—up to a maximum of two-thirds file-backed refaults.

The fraction of file-backed pages is proportional to the complement of

swappiness (recalling that it ranges from zero to two hundred, spanning a desire to not swap at all to swapping at expense of all file-backed reclaim) multiplied by the sum of double anonymous refaults and file-backed refaults or in other words—up to a maximum of two-thirds anonymous refaults.

Scanning of anonymous pages is therefore proportional to file-backed

thrashing up to a maximum of two-thirds of the scan, and scanning of file-backed pages is proportional to anonymous thrashing up to a maximum of two-thirds of the scan.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This renders anonymous scanning inversely proportional to anonymous

thrashing, and file-backed scanning equally inversely proportional to file-

backed thrashing.

This capping at two-thirds is quite subtle, though the comment hints at

it—we do not allow a list to fall completely behind, always providing at least

one third of the pressure no matter the thrashing.

The swappiness is always an overriding parameter and anonymous scan-

ning is proportional to this and file-backed scanning is proportional to the

complement of this.

For instance, if swappiness is equal to 50 then scanning is performed over

25% of anonymous pages and 75% of file-backed pages, if it’s equal to 150 then

scanning is performed over 75% of anonymous pages and 25% of file-backed

pages.

If we examine reclaim pressure on file-backed folios as anonymous re-

faults climb in Figure 11-15, we see that swappiness is always linearly applied,

existing file refaults cause an initial dip in the climbing pressure (as this is

proportional to the ratio between the two) and that we’re always capped off.

 

Swappiness=0, File Refaults=x

100%

 

90%

 

Swappiness=60, File Refaults=0

80%

Swappiness=60, File Refaults=5

70%

e Swappiness=100, File Refaults=0

 

essur 60%

Pr Swappiness=100, File Refaults=5

LRU

50%

ked Swappiness=140, File Refaults=0

40%

ile-Bac

F Swappiness=140, File Refaults=5

 

30%

 

20%

 

10%

 

Swappiness=200, File Refaults=x

0%

0 1 2 3 4 5 6 7 8 9 10

Anonymous Refaults

 

*Figure 11-15: Example File-Backed Reclaim Pressure Split*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Note that Figure 11-15 we see that in the case of 100 swappiness, we al-

ways end up capping at two-thirds of the file-backed pressure.

At other swappiness levels, we need to consider the equations when

anonymous refaults significantly outstrip file-backed, i.e. to determine what the file-backed LRU pressure tends to in the limit.

Let’s expand out the equation:

 

*F r* (200 *−* *S*)(2*a* + *f* ) = *f* *S* ( *f* + 2 *a* ) + (200 *−* *S* )(2*a* + *f* )

If we assume that *f* is greatly exceeded by *a* then we can eliminate this term:

 

*M ax* 2*a*(200 *−* *S*) ( *F r* *f* ) = 2 *aS* + 2 *a* (200 *−* *S*)

Eliminating *a* and expanding this out leaves us with:

 

*M ax* 200 *−* *S* ( *F r* *f* ) = 200 *−* *S/*2

Which we can observe in Figure 11-15.

We consider the equivalent anonymous LRU case in Figure 11-16.

 

Swappiness=200, Anon Refaults=x

100%

 

90%

 

Swappiness=140, Anon Refaults=0

80%

Swappiness=140, Anon Refaults=5

70%

e Swappiness=100, Anon Refaults=0

 

essur 60% Pr Swappiness=100, Anon Refaults=5

LRU

50%

Swappiness=60, Anon Refaults=0

ymous

40%

Anon Swappiness=60, Anon Refaults=5

30%

 

20%

 

10%

 

Swappiness=0, Anon Refaults=x

0%

0 1 2 3 4 5 6 7 8 9 10

File-Backed Refaults

*Figure 11-16: Example Anonymous Reclaim Pressure Split*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

In Figure 11-16 we observe that the same pattern emerges, only with

swappiness inverted by subtracting from 200.

Performing the same task as we did with the file-backed case, we observe

that in the limit we obtain the maximum anonymous LRU pressure as fol-

lows:

*S*(*a* + 2*f* )

*M ax*(*F r**a*) = *S*(*a* + 2*f* ) + (200 *−* *S*)(2*a* + *f* )

Again, in the limit, the file-backed refaults are large, meaning we can disre-

gard the anonymous refault count and obtain:

2*f S*

*M ax*(*F r**a* ) = 2*f S* + *f* (200 *−* *S*)

Eliminating *f* and expanding this out leaves us with:

2*S*

*M ax*(*F r**a*) =

200 + *S*

Which we can observe in Figure 11-16.

Now that we’ve determined how to proceed, we return to

[get_scan_count(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738)we examine in Listing 11-49 the code that actually applies

this to the nr output array.

 

2826 **out**:

2827 **for_each_evictable_lru**(lru) { 2828 **int** file = **is_file_lru**(lru); 2829 **unsigned long** lruvec_size; 2830 **unsigned long** low, **min**; 2831 **unsigned long** scan; 2832

2833 lruvec_size = **lruvec_lru_size**(lruvec, lru, sc-\>reclaim_idx);

. . .

2891 scan = lruvec_size;

. . .

2894 scan \>\>= sc-\>priority;

. . .

2903 **switch** (scan_balance) { 2904 **case SCAN_EQUAL**: 2905 */\* Scan lists relative to size \*/* 2906 **break**; 2907 **case SCAN_FRACT**: 2908 */\** 2909 *\* Scan types proportional to swappiness and* 2910 *\* their relative recent reclaim efficiency.* 2911 *\* Make sure we don't miss the last page on* 2912 *\* the offlined memory cgroups because of a* 2913 *\* round-off error.* 2914 *\*/* 2915 scan = **mem_cgroup_online**(memcg) ? 2916 **div64_u64**(scan \* fraction\[file\], denominator) :

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2917 **DIV64_U64_ROUND_UP**(scan \* fraction\[file\], 2918 denominator); 2919 **break**; 2920 **case SCAN_FILE**: 2921 **case SCAN_ANON**: 2922 */\* Scan one type exclusively \*/* 2923 **if** ((scan_balance == **SCAN_FILE**) != file) 2924 scan = 0; 2925 **break**; 2926 **default**:

2927 */\* Look ma, no brain \*/* 2928 **BUG**(); 2929 }

2930

2931 nr\[lru\] = scan; 2932 }

2933 }

 

*Listing 11-49:* mm/vmscan.c: [*get_scan_count()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) *Calculating Scan Balance*

 

The portion of [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) that we examine in Listing 11-49 popu-

lates the output nr array with the count of pages to scan in each LRU.

This uses the [for_each_evictable_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n297) macro to iterate through the in-

active anonymous, active anonymous, inactive file-backed and active file-backed LRUs respectively, setting the lru variable to each of this of type

[enum lru_list.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n278)

We calculate the size each LRU list via [lruvec_lru_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n590), in the non-

cgroup case simply setting the base number of pages to scan for each LRU at this count shifted by the priority level.

For each scan mode we see whether we need to adjust the scan count.

For [SCAN_EQUAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2725) we by definition do not need to, as this implies we simply scan each list according to the number of priority-adjusted pages.

In order to determine if we are examining a file-backed LRU, at the start

of each loop we define the file boolean which uses [is_file_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n299) to deter-mine this. That way we can handle cases which differ between anonymous and file-backed folios correctly.

For [SCAN_FRACT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2726) we apply the previously calculated fraction to the num-

ber of pages we need to scan. Note that [mem_cgroup_online()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n902) defaults to true if cgroups are disabled.

The [div64_u64()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/math64.h?h=v6.0#n67) permits for safe unsigned 64-bit division even on 32-bit

architectures.

Finally for [SCAN_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2728) and [SCAN_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2727) modes we assign all of the pages to

scan to either anonymous or file-backed pages.

With this function explored, we are ready to see it put to use in

[shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) which we examine in Listing 11-51 and Section 11.5.5.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

***11.5.5 Shrinking LRU Vectors***

 

[shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)

 

[shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136)

 

[shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2950)

 

[shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)

 

[shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)

 

[shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)

 

*Figure 11-17: Reclaim Mechanism: Shrinking LRU Vectors Code Path*

 

Looking at Figure 11-17, we can see that after [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40

and Section 11.5.3 for details) we next invoke [shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136), which we

examine in Listing 11-50 (eliding out of scope cgroup and real-time schedul-

ing logic).

 

3136 **static void shrink_node_memcgs**(pg_data_t \*pgdat, **struct** scan_control \*sc) 3137 {

. . .

3180 **shrink_lruvec**(lruvec, sc); 3181

3182 **shrink_slab**(sc-\>gfp_mask, pgdat-\>node_id, memcg, 3183 sc-\>priority);

. . .

3192 }

 

*Listing 11-50:* mm/vmscan.c: [*shrink_node_memcgs()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136)

 

The majority of the [shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136) function is concerned with

cgroup logic which is out of scope for the book, however whether cgroups

are enabled or not, [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) is invoked to effect the reclaim for the

node configured by the specified [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) object, which we exam-

ine in Listing 11-51.

 

**N O T E** We also invoke [*shrink_slab()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n964) which causes slab memory to free up unused cache

memory. However, discussion of this is entirely out of the scope of the book.

 

We examine the logic of [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) in Figure 11-18.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Determine target scan split between

LRU vectors via [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738)

 

If direct reclaiming and at default

priority ([DEF_PRIORITY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838)), enable

“adjusted scan mode”—this ignores

[struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>nr_to_reclaim

and reclaims pages up to the target.

 

We are done if target inactive anony-

mous and inactive/active file-backed

pages were scanned (we ignore the

active anonymous page target).

 

Yes

Done?

No

Reclaim at most [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214)

from each LRU vec-

tor via [shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)

 

Yes

Adjusted mode?

 

No

 

No

Reclaimed nr_to_reclaim?

 

Yes

If we’ve scanned all of the

Enable adjusted

file-backed, or all of the

scan mode.

anonymous pages, stop.

If inactive anonymous pages are

low, shrink [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214) pages Yes

Stop?

from the active anonymous LRU

vector via No Adjust inactive and active scan [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) [.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509)

Adjust nr targets so we only targets for the lesser-scanned LRU

reclaim whichever of file-backed vectors to what the ratios should

or anonymous pages that have be—equal to 100% minus the

Done.

more pages yet to scan in total percentage of pages not yet scanned

in active and inactive LRU in total in the greater-scanned

vectors (the lesser-scanned lists). lists—minus the number of pages

already scanned, capped to zero.

 

*Figure 11-18:* [*shrink_lruvec()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) *Logic*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**N O T E** In Figure 11-18 when we refer to greater-scanned and lesser-scanned, we mean as

a proportion of the target number of pages to scan, so even if we scanned exactly

the same number of pages for file-backed and anonymous LRU vectors, it is the one

which has fewer pages to scan that is considered greater-scanned, and the one which

has more pages to scan that is considered lesser-scanned.

 

We examine [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) starting in Listing 11-51 (eliding out of scope

cgroup, real-time scheduling and block plugging logic).

 

2950 **static void shrink_lruvec**(**struct** lruvec \*lruvec, **struct** scan_control \*sc) 2951 {

2952 **unsigned long** nr\[**NR_LRU_LISTS**\]; 2953 **unsigned long** targets\[**NR_LRU_LISTS**\]; 2954 **unsigned long** nr_to_scan; 2955 **enum** lru_list lru; 2956 **unsigned long** nr_reclaimed = 0; 2957 **unsigned long** nr_to_reclaim = sc-\>nr_to_reclaim;

. . .

2959 **bool** scan_adjusted; 2960

2961 **get_scan_count**(lruvec, sc, nr); 2962

2963 */\* Record the original scan target for proportional adjustments later*

*\*/*

2964 **memcpy**(targets, nr, **sizeof**(nr)); 2965

2966 */\**

2967 *\* Global reclaiming within direct reclaim at DEF_PRIORITY is a normal*

2968 *\* event that can occur when there is little memory pressure e.g.* 2969 *\* multiple streaming readers/writers. Hence, we do not abort scanning*

2970 *\* when the requested number of pages are reclaimed when scanning at*

2971 *\* DEF_PRIORITY on the assumption that the fact we are direct* 2972 *\* reclaiming implies that kswapd is not keeping up and it is best to*

2973 *\* do a batch of work at once. For memcg reclaim one check is made to*

2974 *\* abort proportional reclaim if either the file or anon lru has*

*already*

2975 *\* dropped to zero at the first pass.* 2976 *\*/*

2977 scan_adjusted = (!**cgroup_reclaim**(sc) && !**current_is_kswapd**() && 2978 sc-\>priority == **DEF_PRIORITY**);

 

*Listing 11-51:* mm/vmscan.c: [*shrink_lruvec()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) *Preface*

 

The beginning of [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) shown in Listing 11-51 starts by invok-

ing [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) (see Listing 11-47 and Section 11.5.4) to determine the

number of pages to scan in the file-backed and anonymous inactive and ac-

tive LRU vectors, all stored in the local nr array.

These values are then copied into the target array so we can modify the

nr array as we proceed but retain the original targets.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We then determine whether we are direct reclaiming and we are at the

default priority level, which enables an “adjusted” scan (we do not consider

the cgroup case, note that [cgroup_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n485) returns false if cgroup is not en-abled).

In this mode we ignore the [struct scan_control-\>nr_to_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) target and

instead simply loop around until we have scanned all of the pages specified by nr.

The justification for this, as per the comment, is that we are not under

significant memory pressure yet (as we are at the default priority), and the fact direct reclaim has been invoked suggests that the target that has oth-erwise been set is insufficient to keep up with what little memory pressure there is.

The default priority, [DEF_PRIORITY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n838) (hard-coded to 12), results in 1/4096 of

the LRU lists being scanned, so this should be relatively safe under ordinary circumstances.

Having established state and determined whether adjusted scan mode is

required, we then start the core reclaim loop as shown in Listing 11-52.

 

2981 **while** (nr\[**LRU_INACTIVE_ANON**\] \|\| nr\[**LRU_ACTIVE_FILE**\] \|\| 2982 nr\[**LRU_INACTIVE_FILE**\]) { 2983 **unsigned long** nr_anon, nr_file, percentage; 2984 **unsigned long** nr_scanned; 2985

2986 **for_each_evictable_lru**(lru) { 2987 **if** (nr\[lru\]) { 2988 nr_to_scan = **min**(nr\[lru\], **SWAP_CLUSTER_MAX**); 2989 nr\[lru\] -= nr_to_scan; 2990

2991 nr_reclaimed += **shrink_list**(lru, nr_to_scan, 2992 lruvec, sc); 2993 } 2994 }

. . .

2998 **if** (nr_reclaimed \< nr_to_reclaim \|\| scan_adjusted) 2999 **continue**;

 

*Listing 11-52:* mm/vmscan.c: [*shrink_lruvec()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) *Main Reclaim Loop*

 

We loop while inactive anonymous, active file-backed and inactive file-

backed pages are still to be scanned (if only active anonymous pages remain, these are handled separately).

We iterate through each LRU list (including active anonymous pages),

reclaiming in batches of up to [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214), which is decremented from nr immediately, whether reclaimed or not. We skip LRU vectors which have zero pages to scan.

The actual reclaim is performed via [shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663) which we explore

later in Listing 11-55, which returns the number of actually reclaimed pages which we accumulate into nr_reclaimed.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

After this initial pass of reclaim has been performed, we check to see if

either we have not scanned all the required pages or if adjusted scan mode

is enabled—in either case we repeat the loop until we have scanned all but

active anonymous pages counted in nr.

With this done we perform post-reclaim logic as explored in Listing 11-

53.

 

3001 */\**

3002 *\* For kswapd and memcg, reclaim at least the number of pages*

3003 *\* requested. Ensure that the anon and file LRUs are scanned*

3004 *\* proportionally what was requested by get_scan_count(). We*

3005 *\* stop reclaiming one LRU and reduce the amount scanning* 3006 *\* proportional to the original scan target.* 3007 *\*/*

3008 nr_file = nr\[**LRU_INACTIVE_FILE**\] + nr\[**LRU_ACTIVE_FILE**\]; 3009 nr_anon = nr\[**LRU_INACTIVE_ANON**\] + nr\[**LRU_ACTIVE_ANON**\]; 3010

3011 */\**

3012 *\* It's just vindictive to attack the larger once the smaller*

3013 *\* has gone to zero. And given the way we stop scanning the*

3014 *\* smaller below, this makes sure that we only make one nudge*

3015 *\* towards proportionality once we've got nr_to_reclaim.* 3016 *\*/*

3017 **if** (!nr_file \|\| !nr_anon) 3018 **break**; 3019

3020 **if** (nr_file \> nr_anon) { 3021 **unsigned long** scan_target = targets\[**LRU_INACTIVE_ANON**\]

\+

3022 targets\[**LRU_ACTIVE_ANON**\] + 1; 3023 lru = **LRU_BASE**; 3024 percentage = nr_anon \* 100 / scan_target; 3025 } **else** {

3026 **unsigned long** scan_target = targets\[**LRU_INACTIVE_FILE**\]

\+

3027 targets\[**LRU_ACTIVE_FILE**\] + 1; 3028 lru = **LRU_FILE**; 3029 percentage = nr_file \* 100 / scan_target; 3030 }

3031

3032 */\* Stop scanning the smaller of the LRU \*/* 3033 nr\[lru\] = 0; 3034 nr\[lru + **LRU_ACTIVE**\] = 0; 3035

3036 */\**

3037 *\* Recalculate the other LRU scan count based on its original*

3038 *\* scan target and the percentage scanning already complete*

3039 *\*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3040 lru = (lru == **LRU_FILE**) ? **LRU_BASE** : **LRU_FILE**; 3041 nr_scanned = targets\[lru\] - nr\[lru\]; 3042 nr\[lru\] = targets\[lru\] \* (100 - percentage) / 100; 3043 nr\[lru\] -= **min**(nr\[lru\], nr_scanned); 3044

3045 lru += **LRU_ACTIVE**; 3046 nr_scanned = targets\[lru\] - nr\[lru\]; 3047 nr\[lru\] = targets\[lru\] \* (100 - percentage) / 100; 3048 nr\[lru\] -= **min**(nr\[lru\], nr_scanned); 3049

3050 scan_adjusted = **true**; 3051 }

 

*Listing 11-53:* mm/vmscan.c: [*shrink_lruvec()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) *Reclaim Loop Post-Processing*

 

The portion of [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) we examine in Listing 11-54 is concerned

with ensuring that we maintain the proportions between LRU vectors ex-

pressed by [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) (see Listing 11-47 and Section 11.5.4).

Since we batch a maximum of [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214) pages at a time (hard-

coded to 32 pages), we may end up in the unfortunate position of reaching or exceeding our reclaim target while not maintaining the proportionality between file-backed and anonymous pages asserted by swappiness at all.

The logic that exists here attempts to correct for this by first halting scan-

ning altogether on the lists which have been scanned most (after all, we can’t unscan already scanned pages, so we can only adjust proportionality based on the scanning more, and this is most effectively done on the least-scanned list).

We start by firstly determining how many pages we have yet to scan in ag-

gregate across inactive and active lists for file-backed and anonymous pages separately.

If either of these are zero, we abort, as we might then end up reducing

the other lists to zero, causing unnecessary reclaim stalls.

Otherwise, we proceed, determining which of file-backed or anonymous

pages have the most number of pages yet to scan (that is, the lesser-scanned lists), as stored in nr_file and nr_anon respectively.

Whichever has more, we clear the target for the other so the greater-

scanned list is the only one we reclaim from, and we store the percentage of pages remaining to be scanned of the greater-scanned lists.

The intent here is to use this percentage in order to ensure that the

lesser-scanned lists has a complementary percentage of pages scanned.

The output of [get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) (see Listing 11-47) is such that the propor-

tion of file-backed or anonymous pages is always equal to the complement of the other—so for instance, if we are to scan 20% of file-backed pages, we scan 80% of anonymous pages, that is, one has a proportion of pages scanned equal to 100% minus the percentage of pages scanned of the other (having

already truncated the scan count by the reclaim priority). See Section 11.5.4 for more details.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

To recover proportionality, we apply the same logic here—we know what

proportion of target pages were scanned for the greater-scanned lists, so we

simply target the complement, or 100% minus this percentage of the lesser-

scanned lists.

We additionally subtract the number of pages already scanned so we do

not exceed the target, capping this result at zero.

Finally, we set the adjusted scan mode so this logic is only performed

once and that we ensure that we do scan pages up to the target amount. We

then loop around to perform the adjusted scan as shown in Figure 11-18.

It’s easier to understand this with a worked example. Consider a

case where the [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)-\>nr_to_reclaim field is set to 128, and

[get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) (see Listing 11-47) sets anonymous page targets to 128 pages

in total split evenly, and file-backed page targets to 256 pages in total, split

evenly.

We start with page reclaim targets as shown in Table 11-1.

 

Table 11-1: Proportionality Example Part 1

LRU Target Scan Target% Anonymous Inactive 64 10% Anonymous Active 64 10% File-backed Inactive 256 40% File-backed Active 256 40%

 

Note that this implies an 80%/20% split in favour of file-backed pages. After a single loop through each LRU vector, assuming all pages are re-

claimed, we achieve our target [struct scan_control-\>nr_to_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) value.

However, this has not resulted in a proportional scan at all, in fact we

have simply scanned all lists evenly, as shown in Table 11-2.

 

Table 11-2: Proportionality Example Part 2

LRU Remaining Scan Scanned Scanned% Scanned/Target% Anonymous Inactive 32 32 25% 50% Anonymous Active 32 32 25% 50% File-backed Inactive 224 32 25% 12.5% File-backed Active 224 32 25% 12.5%

 

Table 11-2 perfectly demonstrates the issue. We have hit our reclaim tar-

get but the proportions scanned have absolutely nothing to do with what

[get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) (see Listing 11-47) has specified.

In addition, we can very clearly see that we have little room to ma-

noeuvre from the point of view of anonymous pages—one more batch of

[SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214) pages and we will have exhausted the anonymous LRU vec-

tors which would simply be perverse, as our intent is to scan significantly

more file-backed pages.

Therefore the wisdom of simply only scanning those lesser-scanned

pages, that is, those with the greater number of pages remaining to be

scanned, becomes apparent.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We have 448 file-backed pages which we can scan, and only 64 anony-

mous ones, and we are therefore far better able to correct the situation by scanning more file-backed ones.

In this instance we see the percentage we use in the algorithm shown in

Listing 11-53 is equal to 32 divided by a target of 64, that is 50%.

This results in a target of 50% of 256, that is 128 for each of the inactive

and active file-backed LRU vectors, less the already scanned 32 pages, leaving us with a target of 96 each or 192 pages in total which to scan file-backed LRU vectors only in adjusted scan mode.

Assuming we successfully scan in these proportions, we are left with the

final aggregate results as shown in Table 11-3.

 

Table 11-3: Proportionality Example Part 3

LRU Scanned Scanned% Scanned/Target% Anonymous Inactive 32 10% 50% Anonymous Active 32 10% 50% File-backed Inactive 128 40% 50% File-backed Active 128 40% 50%

 

We can see in Table 11-3 the final scan counts for each LRU vector, the

original 32 pages scanned from anonymous page lists, and file-backed vectors with the original 32 plus the added 96 pages.

We will have scanned (and potentially reclaimed) 320 pages, which is two

and half times the target number to reclaim, but we will have maintained the required proportions.

 

**N O T E** We hit 50% of the [*get_scan_count()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) (see Listing 11-47) targets, but in indirect re-

claim or direct reclaim below the default priority level, we do not intend to hit these targets, rather at or above the requested number of pages to reclaim.

 

With this logic complete or on early exit as discussed, we perform post-

loop logic as shown in Listing 11-54.

 

3053 sc-\>nr_reclaimed += nr_reclaimed; 3054

3055 */\**

3056 *\* Even if we did not try to evict anon pages at all, we want to* 3057 *\* rebalance the anon lru active/inactive ratio.* 3058 *\*/*

3059 **if** (**can_age_anon_pages**(**lruvec_pgdat**(lruvec), sc) && 3060 **inactive_is_low**(lruvec, **LRU_INACTIVE_ANON**)) 3061 **shrink_active_list**(**SWAP_CLUSTER_MAX**, lruvec, 3062 sc, **LRU_ACTIVE_ANON**); 3063 }

 

*Listing 11-54:* mm/vmscan.c: [*shrink_lruvec()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) *Suffix*

 

At the end of [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2946) as shown in Listing 11-54, we perform a

direct check as to whether we can age anonymous pages, that is whether

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[can_age_anon_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2939) returns true. Other than in the case of NUMA demo-

tion, this simply checks to see whether we have at least 1 swap page available.

We then check to see if the inactive anonymous LRU vector is propor-

tionally small, which we check via [inactive_is_low()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2705) (see Listing 11-42 and

Section 11.5.3).

If so, then we shrink the active list via [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) (see Listing

11-56 and Section 11.5.7).

 

**N O T E** Having noted in Section 11.4.4 on indirect reclaim about consistent aging of active

anonymous folios, we pay special attention to maintaining a sufficient large inactive

anonymous folio LRU list on indirect reclaim, as [*get_scan_count()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) might very well

indicate anonymous active folios should not be reclaimed (for instance in cache trim

mode). See Section 11.5.7 for more.

 

***11.5.6 Shrinking an Individual LRU List***

 

[shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)

 

[shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136)

 

[shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2950)

 

[shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)

 

[shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)

 

[shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)

 

*Figure 11-19: Reclaim Mechanism: Shrinking an Individual LRU List Code Path*

 

We are now at the level of granularity of an individual LRU vector, whether

file-backed or anonymous, inactive or active, which is shrunk by the

[shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663) function, which we examine in Listing 11-55. This is invoked

in [shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2950) (see Listing 11-51), as discussed in Section 11.5.5.

 

2663 **static unsigned long shrink_list**(**enum** lru_list lru, **unsigned long** nr_to_scan, 2664 **struct** lruvec \*lruvec, **struct** scan_control \*

sc)

2665 {

2666 **if** (**is_active_lru**(lru)) { 2667 **if** (sc-\>may_deactivate & (1 \<\< **is_file_lru**(lru))) 2668 **shrink_active_list**(nr_to_scan, lruvec, sc, lru); 2669 **else**

2670 sc-\>skipped_deactivate = 1; 2671 **return** 0; 2672 }

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2673

2674 **return shrink_inactive_list**(nr_to_scan, lruvec, sc, lru); 2675 }

 

*Listing 11-55:* mm/vmscan.c: [*shrink_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)

 

The [shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663) function is rather straightforward—if the LRU is an ac-

tive one, whether file-backed or anonymous (as checked by [is_active_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n304)) then we check whether we are permitted to perform folio deactivation via

the [struct scan_control-\>may_deactivate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) field, offsetting to [DEACTIVATE_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n90) or

[DEACTIVATE_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n91) appropriately using [is_file_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n299) to determine if this LRU is file-backed or not.

If so, then we shrink the active list, i.e. deactivate folios within the LRU

vector, via [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) (see Listing 11-56) as discussed in Section

11.5.7.

If we are not permitted to do so, we set the

[struct scan_control-\>skipped_deactivate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) field so, if direct reclaim invoked this

reclaim, the [do_try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3577) function (see Listing 11-20 and Section

11.3) can choose to force deactivation as required.

If this is an inactive LRU, then we perform inactive list shrinking, in

other words reclaim via [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402) (see Listing 11-61) which we

explore in Section 11.5.9.

 

***11.5.7 Shrinking the Active List***

 

Indirect Reclaim

[balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)

 

[age_active_anon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3926) [shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136)

 

If anon. pages

[shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2950)

If anon. pages inactive is low inactive is low If may deactivate

[shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)

pages

 

[shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)

 

[shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)

 

*Figure 11-20: Reclaim Mechanism: Shrinking the Active List Code Path*

 

As described in Section 11.2, and in more detail in Section 11.5.9 there is an active LRU list and an inactive LRU list. Folios typically start in the inactive list, then on reclaim they are checked to see if they’ve been touched since we last checked (via the hardware-implemented but software resettable accessed page table flag). If so, then they are marked referenced and when encoun-tered again, if accessed once more, promoted to the active list.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Demotion from the active list typically occurs when either thrashing is

occurring or the inactive list becomes small enough that it makes sense to

transfer from the active list to the inactive one.

In general reclaim is more inclined to consistently scan file-

backed folios, and thus invoke [shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663) (see Listing 11-55) with

[struct scan_control-\>may_deactivate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) having the [DEACTIVATE_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n91) flag set.

However anonymous folios might not be so consistently processed, so

we must make extra effort to ensure we consistently deactivate folios, so we

proactively move folios from the active anonymous list to inactive, that is de-

activate them on indirect reclaim (see Section 11.4.4) and when performing

LRU vector shrinking (see Section 11.5.5).

In all cases, this deactivation only occurs if thrashing is occurring or if

the inactive list is too small to maintain the desired balance between inac-

tive and active lists as determined by [inactive_is_low()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2705) (see Listing 11-42 and

Section 11.5.3).

The function which moves folios from the active list to the inactive one is

[shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509), which we explore in Listing 11-56 (eliding out of scope

statistical updates, realtime kernel scheduling logic, buffer head handling,

cgroup handling, and tracing hooks).

 

2492 */\**

2493 *\* shrink_active_list() moves folios from the active LRU to the inactive LRU.*

2494 *\**

2495 *\* We move them the other way if the folio is referenced by one or more* 2496 *\* processes.*

2497 *\**

2498 *\* If the folios are mostly unmapped, the processing is fast and it is* 2499 *\* appropriate to hold lru_lock across the whole operation. But if* 2500 *\* the folios are mapped, the processing is slow (folio_referenced()), so* 2501 *\* we should drop lru_lock around each folio. It's impossible to balance* 2502 *\* this, so instead we remove the folios from the LRU while processing them.*

2503 *\* It is safe to rely on the active flag against the non-LRU folios in here*

2504 *\* because nobody will play with that bit on a non-LRU folio.* 2505 *\**

2506 *\* The downside is that we have to touch folio-\>\_refcount against each folio.*

2507 *\* But we had to alter folio-\>flags anyway.* 2508 *\*/*

2509 **static void shrink_active_list**(**unsigned long** nr_to_scan, 2510 **struct** lruvec \*lruvec, 2511 **struct** scan_control \*sc, 2512 **enum** lru_list lru) 2513 {

2514 **unsigned long** nr_taken; 2515 **unsigned long** nr_scanned; 2516 **unsigned long** vm_flags; 2517 **LIST_HEAD**(l_hold); */\* The folios which were snipped off \*/* 2518 **LIST_HEAD**(l_active); 2519 **LIST_HEAD**(l_inactive);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2520 **unsigned** nr_deactivate, nr_activate; 2521 **unsigned** nr_rotated = 0; 2522 **int** file = **is_file_lru**(lru); 2523 **struct** pglist_data \*pgdat = **lruvec_pgdat**(lruvec); 2524

2525 **lru_add_drain**();

2526

2527 **spin_lock_irq**(&lruvec-\>lru_lock); 2528

2529 nr_taken = **isolate_lru_pages**(nr_to_scan, lruvec, &l_hold, 2530 &nr_scanned, sc, lru);

. . .

2538 **spin_unlock_irq**(&lruvec-\>lru_lock); 2539

2540 **while** (!**list_empty**(&l_hold)) { 2541 **struct** folio \*folio;

. . .

2544 folio = **lru_to_folio**(&l_hold); 2545 **list_del**(&folio-\>lru); 2546

2547 **if** (**unlikely**(!**folio_evictable**(folio))) { 2548 **folio_putback_lru**(folio); 2549 **continue**; 2550 }

. . .

2560 */\* Referenced or rmap lock contention: rotate \*/* 2561 **if** (**folio_referenced**(folio, 0, sc-\>target_mem_cgroup, 2562 &vm_flags) != 0) { 2563 */\** 2564 *\* Identify referenced, file-backed active folios and*

2565 *\* give them one more trip around the active list. So*

2566 *\* that executable code get better chances to stay in*

2567 *\* memory under moderate memory pressure. Anon folios*

2568 *\* are not likely to be evicted by use-once streaming*

2569 *\* IO, plus JVM can create lots of anon VM_EXEC folios*

*,*

2570 *\* so we ignore them here.* 2571 *\*/* 2572 **if** ((vm_flags & **VM_EXEC**) && **folio_is_file_lru**(folio))

{

2573 nr_rotated += **folio_nr_pages**(folio); 2574 **list_add**(&folio-\>lru, &l_active); 2575 **continue**; 2576 } 2577 }

2578

2579 **folio_clear_active**(folio); */\* we are de-activating \*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2580 **folio_set_workingset**(folio); 2581 **list_add**(&folio-\>lru, &l_inactive); 2582 }

2583

2584 */\**

2585 *\* Move folios back to the lru list.* 2586 *\*/*

2587 **spin_lock_irq**(&lruvec-\>lru_lock); 2588

2589 nr_activate = **move_pages_to_lru**(lruvec, &l_active); 2590 nr_deactivate = **move_pages_to_lru**(lruvec, &l_inactive); 2591 */\* Keep all free folios in l_active list \*/* 2592 **list_splice**(&l_inactive, &l_active);

. . .

2598 **spin_unlock_irq**(&lruvec-\>lru_lock);

. . .

2601 **free_unref_page_list**(&l_active);

. . .

2604 }

 

*Listing 11-56:* mm/vmscan.c: [*shrink_active_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509)

 

The [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) function maintains three lists—l_hold which con-

tains folios we have isolated from their LRU list, l_active which contains fo-

lios we intend to put back on to the active list and l_inactive which contains

folios we intend to deactivate by placing at the end of the inactive list.

We start by draining any batched folios which have been cached to be

placed into LRU vectors when each batch becomes full (see Section 11.7 for

more on folio batches) via [lru_add_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727) (See Listing 11-110 and Section

11.7.12).

After this we acquire the lock around [struct lruvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) This data structure

is, when cgroups aren’t in effect, a per-node one which contains each indi-

vidual LRU vector. See Section 11.2.1 for more on this data structure.

 

**N O T E** The [*struct lruvec-\>lru_lock*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) lock is very heavily contended, so the kernel goes to

great lengths to try to minimise the time over which this lock is held.

 

With the LRU lock acquired, we isolated LRU folios from the list and

place them into the l_hold list, attempting to scan nr_to_scan pages, placing

the actual number scanned into nr_scanned.

We do this via [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) which we examine in Listing 11-57 and

Section 11.5.8. This also increments each isolated folio’s reference count,

pinning it in memory.

The function returns the number of base pages contained within the iso-

lated folios, which we store in nr_taken.

With the folios isolated we very quickly release the lock and traverse the

l_hold list.

We iterate through the list backwards as does reclaim itself, by looking at

the tail of the list and obtaining that folio via [lru_to_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n232).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Each folio that was added to the isolated folio list will have its

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>lru list node field reference its position within l_hold.

We therefore remove the folio from this list via [list_del()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n146)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n146) ready to place

it into whichever list we deem appropriate.

We then take care to check that the folio is not [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)[ed](https://man7.org/linux/man-pages/man2/mlock.2.html) or otherwise

marked as unevictable. If so, we abort the operation and place the folio back

on the appropriate LRU list via [folio_putback_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1420) (this ultimately invokes

[folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479), see Listing 11-88 and Section 11.7.5, it also drops the folio’s raised reference count).

We consider an edge case—if a folio has been accessed since we last

checked in any mapping, as determined by the hardware page table accessed flag (hardware set, software cleared), determined by the reverse mapping

function [folio_referenced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n900) (see Chapter 7), and the folio is file-backed and maps executable code, we simply maintain it in the active list indefinitely, add this folio to the l_active list.

In all other cases, we clear the [PG_active](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n106) flag, set the [PG_workingset](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n107) flag

to indicate that this folio was once active (see Section 11.5.2 for a brief overview of the working set), and add the folio to the l_inactive list.

With the loop complete, we again acquire the [struct lruvec-\>lru_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) lock

as we modify the LRU vectors, moving each folio to the appropriate list via

[move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323) (see Listing 11-60 and Section 11.5.8 for an exploration of this). We do this separately for both inactive and active folios.

We then handle an odd wrinkle in the way that [move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323)

operates—if, when dropping a folio’s reference count that isolation provided, we find we should now free the folio, we batch this up, with

[move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323) placing folios to be freed in the input list that it is pro-vided.

We combine these two lists together via [list_splice()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n461) into l_active, which

we then submit to [free_unref_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510) to free the folios to the physical allo-

cator (see Chapter 2 for details on the physical memory allocator).

 

**N O T E** Importantly, we see that folios are simply taken from the active list into the inactive

one without prejudice (aside from the [*VM_EXEC*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n268) edge case), there is no decision making performed—once the active list is to be cleared down, those folios are placed into the inactive one and subject to potential reclaim.

 

***11.5.8 Isolating LRU Folios***

We divide the operation of shrinking an LRU list into isolating folios from the list, taking care to ensure that they are stable and have not changed be-neath us as we do so, and actually shrinking them.

The isolation of LRU folios is performed by [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) which we

examine starting in Listing 11-57 (eliding out of scope data prefetch logic, trace hooks, and statistic recording).

This function assumes that the [struct lruvec-\>lru_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) is held.

 

2117 */\**

2118 *\* Isolating page from the lruvec to fill in @dst list by nr_to_scan times.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2119 *\**

2120 *\* lruvec-\>lru_lock is heavily contended. Some of the functions that* 2121 *\* shrink the lists perform better by taking out a batch of pages* 2122 *\* and working on them outside the LRU lock.* 2123 *\**

2124 *\* For pagecache intensive workloads, this function is the hottest* 2125 *\* spot in the kernel (apart from copy\_\*\_user functions).* 2126 *\**

2127 *\* Lru_lock must be held before calling this function.* 2128 *\**

2129 *\* @nr_to_scan: The number of eligible pages to look through on the list.* 2130 *\* @lruvec:* *The LRU vector to pull pages from.* 2131 *\* @dst:* *The temp list to put pages on to.* 2132 *\* @nr_scanned: The number of pages that were scanned.* 2133 *\* @sc:* *The scan_control struct for this reclaim session* 2134 *\* @lru:* *LRU list id for isolating* 2135 *\**

2136 *\* returns how many pages were moved onto \*@dst.* 2137 *\*/*

2138 **static unsigned long isolate_lru_pages**(**unsigned long** nr_to_scan, 2139 **struct** lruvec \*lruvec, **struct** list_head \*dst, 2140 **unsigned long** \*nr_scanned, **struct** scan_control \*sc, 2141 **enum** lru_list lru) 2142 {

2143 **struct** list_head \*src = &lruvec-\>lists\[lru\]; 2144 **unsigned long** nr_taken = 0;

. . .

2148 **unsigned long** scan, total_scan, nr_pages; 2149 **LIST_HEAD**(folios_skipped); 2150

2151 total_scan = 0;

2152 scan = 0;

 

*Listing 11-57:* mm/vmscan.c: [*isolate_lru_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) *Preface*

 

We start [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) by establishing local variables, including the

folios_skipped list which stores folios which we choose to skip for various rea-

sons.

We set the src list to the lru vector from which we are isolating as de-

termined by the input [enum lru_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n278) which specifies whether this is the

[struct lruvec’s ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317)inactive anonymous, active anonymous, inactive file-backed

or active file-backed LRU list.

With this done, we loop over folios contained in this list, as explored in

Listing 11-58.

 

2153 **while** (scan \< nr_to_scan && !**list_empty**(src)) { 2154 **struct** list_head \*move_to = src; 2155 **struct** folio \*folio; 2156

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2157 folio = **lru_to_folio**(src);

. . .

2160 nr_pages = **folio_nr_pages**(folio); 2161 total_scan += nr_pages; 2162

2163 **if** (**folio_zonenum**(folio) \> sc-\>reclaim_idx) {

. . .

2165 move_to = &folios_skipped; 2166 **goto move**; 2167 }

2168

2169 */\**

2170 *\* Do not count skipped folios because that makes the function*

2171 *\* return with no isolated folios if the LRU mostly contains*

2172 *\* ineligible folios. This causes the VM to not reclaim any*

2173 *\* folios, triggering a premature OOM.* 2174 *\* Account all pages in a folio.* 2175 *\*/*

2176 scan += nr_pages; 2177

2178 **if** (!**folio_test_lru**(folio)) 2179 **goto move**; 2180 **if** (!sc-\>may_unmap && **folio_mapped**(folio)) 2181 **goto move**; 2182

2183 */\**

2184 *\* Be careful not to clear the lru flag until after we're*

2185 *\* sure the folio is not being freed elsewhere -- the* 2186 *\* folio release code relies on it.* 2187 *\*/*

2188 **if** (**unlikely**(!**folio_try_get**(folio))) 2189 **goto move**; 2190

2191 **if** (!**folio_test_clear_lru**(folio)) { 2192 */\* Another thread is already isolating this folio \*/*

2193 **folio_put**(folio); 2194 **goto move**; 2195 }

2196

2197 nr_taken += nr_pages;

. . .

2199 move_to = dst; 2200 **move**:

2201 **list_move**(&folio-\>lru, move_to); 2202 }

 

*Listing 11-58:* mm/vmscan.c: [*isolate_lru_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) *Main Loop*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

In the portion of [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) explored in Listing 11-58 we iter-

ate over folios in the input LRU vector, extracting the tail item in the list via

[lru_to_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n232).

 

**N O T E** As a reminder—folios are added to LRU linked lists at the head of the list, and read

(by reclaim) from the tail. Therefore, when we read the folio from the tail of the LRU

list as we isolate this is in line with how these lists are expected to function.

 

We have not yet extracted the folio from the LRU list, and go about this

carefully. Firstly we determine the number of base pages contained within

the folio via [folio_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1598), which we add to the running total of scanned

folios, total_scan.

Note that we maintain scan as a count of non-skipped folios, and it is this

we compare to nr_to_scan within the loop, so that we do not end up scanning

ineligible folios only to isolate nothing.

Where each folio ends up depends on the move_to variable, which we ini-

tialise to src, i.e. simply placing the folio back onto its original list.

A folio is skipped if the folio exists in a greater than the maximum

zone from which the failing allocation which triggered reclaim can allocate

from (See Section 2.4 and Chapter 2 for a detailed discussion of nodes and

zones), as stored in [struct scan_control-\>reclaim_idx](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66).

Other instances of us scanning but failing to isolate a folio do not consti-

tute that folio being skipped, so in these instances we account these folios as

having been scanned but not isolated.

If we find the folio has for whatever reason already been taken from an

LRU, i.e. the [PG_lru](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n105) flag is not set, we move the folio back to the head of the

input list via [list_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n215).

 

**N O T E** These list operations are safe as it is assumed within this function that we hold the

[*struct lruvec-\>lru_lock*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317).

 

Equally if we are unable to unmap the folio, as determined by

[struct scan_control-\>may_unmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66), and the folio has an elevated map count as

determined by [folio_mapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n758), then we equally move it back to the source list.

With these edge cases considered, we try to increment the folio’s refer-

ence count via [folio_try_get()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n261)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n261) If there is contention on the folio lock we do

not wait for it, instead we do not isolate it.

Finally, if after the folio’s reference count has been incremented we find

it is no longer marked as being on an LRU (via the [PG_lru](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n105) flag) as we attempt

to clear it, then we assume another thread is isolating this folio, drop the

reference count and abort, placing the folio back on its original LRU list.

With these cases ruled out, we increment nr_taken which maintainsa

count of isolated folios for us to return to caller, and sets move_to to the

caller-specified destination list.

We examine what we do after this loop in Listing 11-59.

 

2204 */\**

2205 *\* Splice any skipped folios to the start of the LRU list. Note that*

2206 *\* this disrupts the LRU order when reclaiming for lower zones but*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2207 *\* we cannot splice to the tail. If we did then the SWAP_CLUSTER_MAX*

2208 *\* scanning would soon rescan the same folios to skip and waste lots*

2209 *\* of cpu cycles.* 2210 *\*/*

2211 **if** (!**list_empty**(&folios_skipped)) {

. . .

2214 **list_splice**(&folios_skipped, src);

. . .

2222 }

2223 \*nr_scanned = total_scan;

. . .

2228 **return** nr_taken;

2229 }

 

*Listing 11-59:* mm/vmscan.c: [*isolate_lru_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) *Suffix*

 

The portion of [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) examined in Listing 11-59 first places

the folios_skipped folios back onto the source list, putting them to the back of the queue (by placing them at the head of the list), in order that we don’t repeatedly scan the same skipped folios while iterating through

[SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214) batches of folios.

Finally we output the total number of pages scanned (including those

skipped) to the output parameter nr_scanned and return the number of iso-lated pages.

When isolating folios, these are maintained in a local list, and later need

to be put back to whichever list they ought to be on. This is performed by

[move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323) which we examine in Listing 11-60 (eliding debug checks and out of scope working set hooks and huge page handling).

This function also assumes that [struct lruvec-\>lru_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) is held.

 

2317 */\**

2318 *\* move_pages_to_lru() moves folios from private @list to appropriate LRU list*

*.*

2319 *\* On return, @list is reused as a list of folios to be freed by the caller.*

2320 *\**

2321 *\* Returns the number of pages moved to the given lruvec.* 2322 *\*/*

2323 **static unsigned int move_pages_to_lru**(**struct** lruvec \*lruvec, 2324 **struct** list_head \*list) 2325 {

2326 **int** nr_pages, nr_moved = 0; 2327 **LIST_HEAD**(folios_to_free); 2328

2329 **while** (!**list_empty**(list)) { 2330 **struct** folio \*folio = **lru_to_folio**(list);

. . .

2333 **list_del**(&folio-\>lru); 2334 **if** (**unlikely**(!**folio_evictable**(folio))) { 2335 **spin_unlock_irq**(&lruvec-\>lru_lock);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2336 **folio_putback_lru**(folio); 2337 **spin_lock_irq**(&lruvec-\>lru_lock); 2338 **continue**; 2339 }

2340

2341 */\**

2342 *\* The folio_set_lru needs to be kept here for list integrity.*

2343 *\* Otherwise:* 2344 *\** *\#0 move_pages_to_lru* *\#1 release_pages* 2345 *\** *if (!folio_put_testzero())* 2346 *\** *if (folio_put_testzero()*

*)*

2347 *\** *!lru //skip lru_lock* 2348 *\** *folio_set_lru()* 2349 *\** *list_add(&folio-\>lru,)* 2350 *\** *list_add(&folio-\>lru*

*,)*

2351 *\*/*

2352 **folio_set_lru**(folio); 2353

2354 **if** (**unlikely**(**folio_put_testzero**(folio))) { 2355 **\_\_folio_clear_lru_flags**(folio);

. . .

2362 **list_add**(&folio-\>lru, &folios_to_free); 2363

2364 **continue**; 2365 }

. . .

2372 **lruvec_add_folio**(lruvec, folio); 2373 nr_pages = **folio_nr_pages**(folio); 2374 nr_moved += nr_pages;

. . .

2377 }

2378

2379 */\**

2380 *\* To save our caller's stack, now use input list for pages to free.*

2381 *\*/*

2382 **list_splice**(&folios_to_free, list); 2383

2384 **return** nr_moved;

2385 }

 

*Listing 11-60:* mm/vmscan.c: [*move_pages_to_lru()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323)

 

The [move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323) function iterates through the list from the tail,

extracting the folio in each instance via [lru_to_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n232) and deleting the folio

from the input list via [list_del()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n146)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n146)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

As in [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) we check to ensure the folio is not [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)ed

or otherwise marked as unevictable via [folio_evictable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n119), if it is, we place the

folio back on the appropriate LRU list via [folio_putback_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1420) (this ultimately

invokes [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479) see Listing 11-88 and Section 11.7.5, it also drops the folio’s raised reference count).

With this check performed, we set the [PG_lru](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n105) flag (note the nuanced tim-

ing in how we do this as described in the comment), before dropping the isolated folio’s reference count.

We now account for the case where the elevated reference count from

the folio being isolated was the last remaining reference count. We want to try to batch cases like this so we can delete them all in one go rather than one at a time, and thus add these folios to the folios_to_free list, having

cleared its LRU-specific [PG_lru](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n105)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n105) [PG_active](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n106) and [PG_unevictable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n121) folio flags before skipping to the next folio.

Otherwise, we add the folio to the designated LRU list via

[lruvec_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98) (see Listing 11-13 and Section 11.2.2).

We then count the base pages we have moved via [folio_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1598) which

we accumulate in nr_moved.

Finally, we place all of the folios to be freed on the input list for the caller

to free (done this way for efficiency), before returning the count of base pages of folios moved.

 

***11.5.9 Shrinking the Inactive List***

 

[shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)

 

[shrink_node_memcgs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3136)

 

[shrink_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2950)

 

[shrink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2663)

 

[shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509) [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)

 

[shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)

 

*Figure 11-21: Reclaim Mechanism: Shrinking the Inactive List*

 

Shrinking the inactive LRU list is where actual reclaim is performed within the kernel, and all of the remainder of the reclaim logic is simply designed to control how this proceeds.

This occurs in [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402) which we examine in Listing 11-61

(eliding out of scope cgroup logic, statistical updates and trace hooks).

 

2401 **static unsigned long**

2402 **shrink_inactive_list**(**unsigned long** nr_to_scan, **struct** lruvec \*lruvec,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2403 **struct** scan_control \*sc, **enum** lru_list lru) 2404 {

2405 **LIST_HEAD**(page_list); 2406 **unsigned long** nr_scanned; 2407 **unsigned int** nr_reclaimed = 0; 2408 **unsigned long** nr_taken; 2409 **struct** reclaim_stat stat; 2410 **bool** file = **is_file_lru**(lru); 2411 **enum** vm_event_item item; 2412 **struct** pglist_data \*pgdat = **lruvec_pgdat**(lruvec); 2413 **bool** stalled = **false**; 2414

2415 **while** (**unlikely**(**too_many_isolated**(pgdat, file, sc))) { 2416 **if** (stalled) 2417 **return** 0; 2418

2419 */\* wait a bit for the reclaimer. \*/* 2420 stalled = **true**; 2421 **reclaim_throttle**(pgdat, **VMSCAN_THROTTLE_ISOLATED**); 2422

2423 */\* We are about to die and free our memory. Return now. \*/*

2424 **if** (**fatal_signal_pending**(current)) 2425 **return SWAP_CLUSTER_MAX**; 2426 }

2427

2428 **lru_add_drain**();

2429

2430 **spin_lock_irq**(&lruvec-\>lru_lock); 2431

2432 nr_taken = **isolate_lru_pages**(nr_to_scan, lruvec, &page_list, 2433 &nr_scanned, sc, lru);

. . .

2442 **spin_unlock_irq**(&lruvec-\>lru_lock); 2443

2444 **if** (nr_taken == 0) 2445 **return** 0; 2446

2447 nr_reclaimed = **shrink_page_list**(&page_list, pgdat, sc, &stat, **false**); 2448

2449 **spin_lock_irq**(&lruvec-\>lru_lock); 2450 **move_pages_to_lru**(lruvec, &page_list);

. . .

2458 **spin_unlock_irq**(&lruvec-\>lru_lock); 2459

2460 **lru_note_cost**(lruvec, file, stat.nr_pageout);

. . .

2461 **free_unref_page_list**(&page_list);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2462

2463 */\**

2464 *\* If dirty pages are scanned that are not queued for IO, it* 2465 *\* implies that flushers are not doing their job. This can* 2466 *\* happen when memory pressure pushes dirty pages to the end of* 2467 *\* the LRU before the dirty limits are breached and the dirty* 2468 *\* data has expired. It can also happen when the proportion of* 2469 *\* dirty pages grows not through writes but through memory* 2470 *\* pressure reclaiming all the clean cache. And in some cases,* 2471 *\* the flushers simply cannot keep up with the allocation* 2472 *\* rate. Nudge the flusher threads in case they are asleep.* 2473 *\*/*

2474 **if** (stat.nr_unqueued_dirty == nr_taken) 2475 **wakeup_flusher_threads**(**WB_REASON_VMSCAN**); 2476

2477 sc-\>nr.dirty += stat.nr_dirty; 2478 sc-\>nr.congested += stat.nr_congested; 2479 sc-\>nr.unqueued_dirty += stat.nr_unqueued_dirty; 2480 sc-\>nr.writeback += stat.nr_writeback; 2481 sc-\>nr.immediate += stat.nr_immediate; 2482 sc-\>nr.taken += nr_taken; 2483 **if** (file)

2484 sc-\>nr.file_taken += nr_taken;

. . .

2489 **return** nr_reclaimed; 2490 }

 

*Listing 11-61:* mm/vmscan.c: [*shrink_inactive_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)

 

We start [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402) by initialising a number of local variables

including page_list which we use to store isolated folios we wish to consider for reclaim.

We then check to see whether we need to throttle reclaim—if we are

in a state where a large number of tasks are trying to allocate under heavy memory pressure, each isolating a great many folios to consider for reclaim, which could result in the LRU being shrunk to too small a size to be effec-tively scanned.

In this instance, we perform reclaim throttling (see Section 11.6). We de-

termine whether this is necessary via [too_many_isolated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2280) which we examine

in Listing 11-62 (eliding out of scope cgroup logic).

 

2273 */\**

2274 *\* A direct reclaimer may isolate SWAP_CLUSTER_MAX pages from the LRU list and*

2275 *\* then get rescheduled. When there are massive number of tasks doing page*

2276 *\* allocation, such sleeping direct reclaimers may keep piling up on each CPU,*

2277 *\* the LRU list will go small and be scanned faster than necessary, leading to*

2278 *\* unnecessary swapping, thrashing and OOM.* 2279 *\*/*

2280 **static int too_many_isolated**(**struct** pglist_data \*pgdat, **int** file,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2281 **struct** scan_control \*sc) 2282 {

2283 **unsigned long** inactive, isolated; 2284 **bool** too_many;

2285

2286 **if** (**current_is_kswapd**()) 2287 **return** 0;

. . .

2292 **if** (file) {

2293 inactive = **node_page_state**(pgdat, **NR_INACTIVE_FILE**); 2294 isolated = **node_page_state**(pgdat, **NR_ISOLATED_FILE**); 2295 } **else** {

2296 inactive = **node_page_state**(pgdat, **NR_INACTIVE_ANON**); 2297 isolated = **node_page_state**(pgdat, **NR_ISOLATED_ANON**); 2298 }

2299

2300 */\**

2301 *\* GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so*

*they*

2302 *\* won't get blocked by normal direct-reclaimers, forming a circular*

2303 *\* deadlock.*

2304 *\*/*

2305 **if** ((sc-\>gfp_mask & (**\_\_GFP_IO** \| **\_\_GFP_FS**)) == (**\_\_GFP_IO** \| **\_\_GFP_FS**)) 2306 inactive \>\>= 3; 2307

2308 too_many = isolated \> inactive; 2309

2310 */\* Wake up tasks throttled due to too_many_isolated. \*/* 2311 **if** (!too_many)

2312 **wake_throttle_isolated**(pgdat); 2313

2314 **return** too_many;

2315 }

 

*Listing 11-62:* mm/vmscan.c: [*too_many_isolated()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2280)

 

The [too_many_isolated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2280) function only considers direct reclaim cases, as

background reclaim can’t scale in a pathological way like direct reclaim can.

We count how many inactive pages exist in LRUs and compare this to the

number of total isolated pages. If isolated pages exceeds one-eighth of the

number of inactive pages, then we indicate that there are too many isolated

pages.

 

**N O T E** In the case of [*GFP_NOIO*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n336) or [*GFP_NOFS*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n337) allocations where I/O or filesystem access are not

permitted in the failing allocation which triggered reclaim, we allow isolated pages to

grow all the way to the size of the number of inactive ones to avoid deadlock.

 

If we determine that we do not have too many isolated pages we wake any

threads that were throttled on this via [wake_throttle_isolated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n73)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n73)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Returning to [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402) and Listing 11-61, we see that in

the case of [too_many_isolated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2280) indicating we do have too many isolated

folios, we engage in reclaim throttle via [reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104) setting the

[VMSCAN_THROTTLE_ISOLATED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n289) flag (see Listing 11-75 in Section 11.6).

We exit early if a fatal signal emerged in the time we spent sleeping, oth-

erwise we check again, exiting the function indicating failure if this recurs.

With this checked, we ensure that any folio batches containing folios

that ought to be on an LRU but are not flushed to them yet are immedi-

ately drained to the LRUs via [lru_add_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727) (See Listing 11-110 and Section

11.7.12).

We acquire the [struct lruvec-\>lru_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317) and isolate LRU folios for us to ex-

amine via [isolate_lru_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2138) (see Listing 11-57 and Section 11.5.8), releasing the lock afterwards, exiting indicating failure if this fails to isolate any folios.

With folios isolated and knowing we are able to proceed with reclaim,

we do so by invoking [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589), which is the heart of the reclaim

mechanism, and which we examine in Listing 11-63 shortly.

This function returns the number of base pages which were reclaimed

storing this in nr_reclaimed.

Any folios which were not reclaimed will remain on page_list, so we

then need to move these to the appropriate LRU lists, which we do, under

[struct lruvec-\>lru_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n317), via [move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323) (see Listing 11-60 and Section

11.5.8).

After this is done we invoke [lru_note_cost()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n298) to account for any dirty folios

successfully paged out to disk. See Listing 11-39 and Section 11.5.2.1 for more details on this.

With this complete, we free any folios that [move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323) indicated

should be freed (again see Listing 11-60 and Section 11.5.8 for details) via

[free_unref_page_list().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510)

With this complete, we wake up writeback flusher threads if it

seems too many dirty folios are not being subject to writeback via

[wakeup_flusher_threads()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2269) (see Listing 10-35 and Section 10.11 for details on

this in Chapter 10), and update [struct scan_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) statistics before returning the number of reclaimed base pages.

We examine the logic of the key [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) function in Figure 11-

22.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

No

Folio left in list? To Post-Loop

To Keep

Yes

If this is kswapd and this is the

No If folio lock is contended,

second time we’ve seen this folio

unevictable or it is mapped and

Can consider? and we are saturated with writeback

[struct scan_control-\>may_unmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) is

folios [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n690)[PGDAT_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n690) is set), we

false, we cannot consider the folio.

mark for immediate writeback.

Yes

 

Yes

Folio in Writeback? Immediate Writeback?

To activate No

Yes No Yes

Check if folio was accessed by any Set [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) flag.

Mapped [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282)? mapping since we last checked Set for immediate Will reclaim as

via [folio_check_references()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433) writeback. soon as writeback

No is complete.

 

Accessed since last check? [PG_referenced](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n102) prev. set/refs\>1? Yes

To activate

Yes No Yes

No

No Set [PG_referenced](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n102) flag. [VM_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n268) file folio? To keep

 

Yes

No

Yes

Swap-backed, not in swap cache? No I/O alloc or maybe pinned? Success?

No Yes

No [add_to_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n174)

Mapped?

Yes

No [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812) Still mapped? Yes To activate

No

Dirty?

Yes

If folio previously had [PG_referenced](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n102) set, or if can’t enter

No

File folio? file system or [struct scan_control-\>may_writepage](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66)

No

Lazy-free? is false, we can’t page out/swap out.

Yes

 

Yes Yes No kswapd Only can Yes

Freeze? page out file folios, Can page out?

 

Remove from No only if previously File page out? No To keep To keep flagged [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) , and Yes [PAGE_KEEP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1202) No Fails saturated with dirty [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) Set [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) folios [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n686) [PGDAT_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n686) set).

page cache entry [PAGE_ACTIVATE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1204) [PAGE_SUCCESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1206) or swap cache via To activate Yes

[\_\_remove_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289) WB/dirty? [PAGE_CLEAN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1208)

No

To Yes No free pages Lock folio?

 

*Figure 11-22:* [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Main Loop Logic*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We examine [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) in Listing 11-63 (eliding out of scope real-

time scheduling hooks, cgroup logic, debug asserts, huge page logic, NUMA demotion, statistical updates, buffer head freeing and hot plugging sup-port).

 

1589 **static unsigned int shrink_page_list**(**struct** list_head \*page_list, 1590 **struct** pglist_data \*pgdat, 1591 **struct** scan_control \*sc, 1592 **struct** reclaim_stat \*stat, 1593 **bool** ignore_references) 1594 {

1595 **LIST_HEAD**(ret_pages); 1596 **LIST_HEAD**(free_pages);

. . .

1598 **unsigned int** nr_reclaimed = 0;

. . .

1603 **memset**(stat, 0, **sizeof**(\*stat));

. . .

1607 **retry**:

1608 **while** (!**list_empty**(page_list)) { 1609 **struct** address_space \*mapping; 1610 **struct** folio \*folio; 1611 **enum** page_references references = **PAGEREF_RECLAIM**; 1612 **bool** dirty, writeback; 1613 **unsigned int** nr_pages;

. . .

1617 folio = **lru_to_folio**(page_list); 1618 **list_del**(&folio-\>lru); 1619

1620 **if** (!**folio_trylock**(folio)) 1621 **goto keep**;

. . .

1625 nr_pages = **folio_nr_pages**(folio); 1626

1627 */\* Account the number of base pages \*/* 1628 sc-\>nr_scanned += nr_pages; 1629

1630 **if** (**unlikely**(!**folio_evictable**(folio))) 1631 **goto activate_locked**; 1632

1633 **if** (!sc-\>may_unmap && **folio_mapped**(folio)) 1634 **goto keep_locked**;

 

*Listing 11-63:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Preface & Loop Start*

 

We start by initialising local state, including the lists ret_pages which are

the folios we will return in page_list for the caller to place into their appro-priate LRU list should we not reclaim them and free_pages for those folios we

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

were able to reclaim and thus are ready to be freed, which we bulk free at the

end of the operation.

Within the loop we read a folio from the tail of the input list of isolated

folios via [lru_to_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n232) and delete the folio from the input list via [list_del()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n146)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n146)

 

**N O T E** We later append (that is splice) the empty input list at the end of the iteration with

folios that were not reclaimed that need to be returned to the caller to put back on the

appropriate LRUs.

 

On each iteration we optimistically try to lock the folio—we don’t want to

block when we have other folios we can consider for reclaim. If we can’t lock

we keep the folio rotating it to the back of the list (we examine each of these

labels in Listing 11-69).

If the folio can’t be evicted ([mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)ed or otherwise marked as unevictable

as checked by [folio_evictable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n119)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n119) then we activate it so it gets out of the way

of folios that can be reclaimed.

Finally if the folio is mapped by userland but

[struct scan_control-\>may_unmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) is false then we are not permitted to un-

map, and so cannot reclaim it and thus keep it rotating it to the back of the

list.

After ensuring that we can proceed, we examine writeback folios, which

we examine in Listing 11-64.

 

1636 */\**

1637 *\* The number of dirty pages determines if a node is marked*

1638 *\* reclaim_congested. kswapd will stall and start writing* 1639 *\* folios if the tail of the LRU is all dirty unqueued folios.*

1640 *\*/*

1641 **folio_check_dirty_writeback**(folio, &dirty, &writeback); 1642 **if** (dirty \|\| writeback) 1643 stat-\>nr_dirty += nr_pages; 1644

1645 **if** (dirty && !writeback) 1646 stat-\>nr_unqueued_dirty += nr_pages; 1647

1648 */\**

1649 *\* Treat this folio as congested if folios are cycling* 1650 *\* through the LRU so quickly that the folios marked* 1651 *\* for immediate reclaim are making it to the end of* 1652 *\* the LRU a second time.* 1653 *\*/*

1654 **if** (writeback && **folio_test_reclaim**(folio)) 1655 stat-\>nr_congested += nr_pages;

. . .

1701 **if** (**folio_test_writeback**(folio)) {

. . .

1703 **if** (**current_is_kswapd**() && 1704 **folio_test_reclaim**(folio) &&

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1705 **test_bit**(**PGDAT_WRITEBACK**, &pgdat-\>flags)) { 1706 stat-\>nr_immediate += nr_pages; 1707 **goto activate_locked**;

. . .

1710 } **else if** (**writeback_throttling_sane**(sc) \|\|

. . .

1713 */\** 1714 *\* This is slightly racy -*1715 *\* folio_end_writeback() might have* 1716 *\* just cleared the reclaim flag, then* 1717 *\* setting the reclaim flag here ends up* 1718 *\* interpreted as the readahead flag - but*

1719 *\* that does not matter enough to care.* 1720 *\* What we do want is for this folio to* 1721 *\* have the reclaim flag set next time* 1722 *\* memcg reclaim reaches the tests above,* 1723 *\* so it will then wait for writeback to* 1724 *\* avoid OOM; and it's also appropriate* 1725 *\* in global reclaim.* 1726 *\*/* 1727 **folio_set_reclaim**(folio); 1728 stat-\>nr_writeback += nr_pages; 1729 **goto activate_locked**;

. . .

1738 } 1739 }

 

*Listing 11-64:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Writeback Handling*

 

We start the portion of [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) explored in Listing 11-64 by

determining whether the folio is file-backed and either dirty or in a state of

writeback via [folio_check_dirty_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1491)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1491)

If the file-system supports it, [folio_check_dirty_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1491) exposes a hook

to allow for custom handling of this. We then populate the output in dirty and writeback.

When a folio is under writeback and we want to reclaim it, we typically

set the [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) this is seen in the branch starting at line 1710.

 

**N O T E** The source is unfortunately cropped rather awkwardly here—

[*writeback_throttling_sane()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n453) is a cgroup-specific check, which if cgroups are not enabled returns *true*. Therefore from the purpose of what is in scope here in the book, view this as an *else* branch.

 

This is what we do in the majority of cases, as when writeback completes,

[folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599) is invoked, which tests for [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) and if set, clears

this flag and invokes [folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n283) (see Listing 11-92 and Sec-

tion 11.7.7)).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This function places the folio at the tail of the inactive LRU, so it will be

considered for reclaim as soon as there is memory pressure, and is therefore

reclaimed right away.

However, if this is indirect reclaim (as checked for by [current_is_kswapd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n37)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n37)

the [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) has already been set but the folio has not been written back

yet and we previously determined that all of the isolated folios were in write-

back at once (checked in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) see Listing 11-40 and Section 11.5.3),

having set the node flag [PGDAT_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n690)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n690) then we increment the nr_immediate

field in the [struct reclaim_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.h?h=v6.0#n24) field.

When [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) (see Listing 11-40) sees that

[struct reclaim_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.h?h=v6.0#n24)-\>nr_immediate is non-zero, then it causes reclaim

throttling to allow for the writeback to complete.

In this instance we also activate the folio to get it out of the way, which

allows [folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n283) (see Listing 11-92) to move it to the front of

the inactive LRU.

When [folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n283) performs rotation it places the folio into

a folio batch (see Section 11.7 for more on folio batches) so we can move

folios in batches at a time for efficiency (note that reclaim drains these non-

LRU batches so nothing gets missed).

The [lru_move_tail_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n266) function is eventually invoked which clears the

[PG_active](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n106) flag before moving the folio to the tail of the inactive LRU vector.

With writeback folios handled, we examine how we deal with detecting

whether folios have been utilised, that is referenced by user space, which we

examine in Listing 11-65.

 

1741 **if** (!ignore_references) 1742 references = **folio_check_references**(folio, sc); 1743

1744 **switch** (references) { 1745 **case PAGEREF_ACTIVATE**: 1746 **goto activate_locked**; 1747 **case PAGEREF_KEEP**: 1748 stat-\>nr_ref_keep += nr_pages; 1749 **goto keep_locked**; 1750 **case PAGEREF_RECLAIM**: 1751 **case PAGEREF_RECLAIM_CLEAN**: 1752 ; */\* try to reclaim the folio below \*/* 1753 }

 

*Listing 11-65:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Reference Handling*

 

The portion of [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) explored in Listing 11-65 we note that

we entirely abstract folio reference handling in [folio_check_references()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433)

which we examine in detail in Listing 11-70 and Section 11.5.10.

We only do so if ignore_references is not set—this is not set on ordinary re-

claim so we can disregard this. But if it was set, note that references defaults

to [PAGEREF_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1427).

This function returns an [enum page_references](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1426) value indicating how to

proceed, with [PAGEREF_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1427) indicating we can proceed with reclaim,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[PAGEREF_RECLAIM_CLEAN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1428) indicating that we can proceed with reclaim but not

if the folio is dirty, [PAGEREF_KEEP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1429) indicating the the folio should be rotated to

the end of the list it is currently on and [PAGEREF_ACTIVATE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1429) indicating the folio should be added to the active LRU vector, i.e. activated.

We handle each of the cases in the switch statement invoked after the

invocation of [folio_check_references()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433)

With this complete, we handle swap and mapping logic shown in Listing

11-66.

Again, see Section 11.5.10 for a detailed exploration of what folio refer-

ences entail and how they are determined.

 

1766 */\**

1767 *\* Anonymous process memory has backing store?* 1768 *\* Try to allocate it some swap space here.* 1769 *\* Lazyfree folio could be freed directly* 1770 *\*/*

1771 **if** (**folio_test_anon**(folio) && **folio_test_swapbacked**(folio)) { 1772 **if** (!**folio_test_swapcache**(folio)) { 1773 **if** (!(sc-\>gfp_mask & **\_\_GFP_IO**)) 1774 **goto keep_locked**; 1775 **if** (**folio_maybe_dma_pinned**(folio)) 1776 **goto keep_locked**;

. . .

1791 **if** (!**add_to_swap**(folio)) {

. . .

1793 **goto activate_locked_split**;

. . .

1803 } 1804 }

. . .

1810 }

. . .

1822 */\**

1823 *\* The folio is mapped into the page tables of one or more*

1824 *\* processes. Try to unmap it here.* 1825 *\*/*

1826 **if** (**folio_mapped**(folio)) { 1827 **enum** ttu_flags flags = **TTU_BATCH_FLUSH**; 1828 **bool** was_swapbacked = **folio_test_swapbacked**(folio);

. . .

1833 **try_to_unmap**(folio, flags); 1834 **if** (**folio_mapped**(folio)) { 1835 stat-\>nr_unmap_fail += nr_pages; 1836 **if** (!was_swapbacked && 1837 **folio_test_swapbacked**(folio)) 1838 stat-\>nr_lazyfree_fail += nr_pages;

1839 **goto activate_locked**; 1840 }

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1841 }

 

*Listing 11-66:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Add to Swap & Mappings*

 

Importantly, we start the portion of [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) explored in Listing

11-66 by checking to see whether we need to perform swap-out.

We explore this case in detail in the dedicated chapter on Swap (Chapter

12) in Section 12.2, however we’ll reiterate the details here.

A folio is considered for swap out if it is both anonymous and has the

[PG_swapbacked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n120) flag set. If a folio is anonymous without the [PG_swapbacked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n120) flag,

this means it is a lazy-free folio, i.e. memory freed using [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) with the

MADV_FREE flag, a case we examine in Listing 11-68.

If the folio is not already in the swap cache, as indicated by the

[PG_swapcache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n120) flag, we consider it for adding to the swap cache.

We do not consider a folio for this if the fault which caused reclaim is

unable to perform I/O, in which case we simply rotate the folio, equally so

if the folio is pinned by the kernel via the Get User Pages (GUP) mechanism

(see Section 8.1.2 and Chapter 8 for more on GUP).

We check for the GUP case via [folio_maybe_dma_pinned()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1498) (see Listing 8-14

and Section 8.1.3 in Chapter 8), if this is so we simply rotate the folio.

Finally if can proceed with placing the folio in the swap cache, we do so

via [add_to_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n174) (see Listing 12-20 and Section 12-20).

If this fails (for instance if there is no swap space left) we activate the fo-

lio, as we need to get it out of the way of folios we can reclaim, otherwise

we are good to proceed forward. Note that ultimately a folio designated for

swap out is marked dirty in order that it can be written back to disk. We ex-

amine dirty folio handling in Listing **??**.

Next, if the folio is mapped in any userland mapping, then we need to

unmap it entirely before performing reclaim.

We test for this via [folio_mapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n758), and utilise the reverse mapping func-

tion [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812) (see Listing 12-23 and Section **??** in Chapter 12) to do the

leg work of iterating through all [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) objects which

map the folio (see Chapter 7 for details on the reverse mapping), unmap-

ping it from them.

A nuance of this is with swap cache entries—the underlying function in-

voked by the reverse mapping iteration, [try_to_unmap_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476) has special han-

dling for swap cache entries, replacing them with swap entries rather than

clearing them altogether.

See Listing 12-24 and Section **??** in Chapter 12 for details on how this is

performed.

For file-backed folios, we simply clear the mapping—if the folio is refer-

enced again, a fault will occur and the file-backed folio will be read back into

memory from disk.

If, after invoking [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812), the folio is still mapped, this mean the

effort failed, and we update statistics accordingly and activate the folio to get

it out of the way of reclaim.

With this complete, we examine dirty folio handling in Listing 11-67.

 

1843 mapping = **folio_mapping**(folio);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1844 **if** (**folio_test_dirty**(folio)) { 1845 */\** 1846 *\* Only kswapd can writeback filesystem folios* 1847 *\* to avoid risk of stack overflow. But avoid* 1848 *\* injecting inefficient single-folio I/O into* 1849 *\* flusher writeback as much as possible: only* 1850 *\* write folios when we've encountered many* 1851 *\* dirty folios, and when we've already scanned*

1852 *\* the rest of the LRU for clean folios and see*

1853 *\* the same dirty folios again (with the reclaim*

1854 *\* flag set).* 1855 *\*/* 1856 **if** (**folio_is_file_lru**(folio) && 1857 (!**current_is_kswapd**() \|\| 1858 !**folio_test_reclaim**(folio) \|\| 1859 !**test_bit**(**PGDAT_DIRTY**, &pgdat-\>flags))) {

. . .

1868 **folio_set_reclaim**(folio); 1869

1870 **goto activate_locked**; 1871 } 1872

1873 **if** (references == **PAGEREF_RECLAIM_CLEAN**) 1874 **goto keep_locked**; 1875 **if** (!**may_enter_fs**(folio, sc-\>gfp_mask)) 1876 **goto keep_locked**; 1877 **if** (!sc-\>may_writepage) 1878 **goto keep_locked**; 1879

1880 */\** 1881 *\* Folio is dirty. Flush the TLB if a writable entry*

1882 *\* potentially exists to avoid CPU writes after I/O*

1883 *\* starts and then write it out here.* 1884 *\*/* 1885 **try_to_unmap_flush_dirty**(); 1886 **switch** (**pageout**(folio, mapping, &plug)) { 1887 **case PAGE_KEEP**: 1888 **goto keep_locked**; 1889 **case PAGE_ACTIVATE**: 1890 **goto activate_locked**; 1891 **case PAGE_SUCCESS**: 1892 stat-\>nr_pageout += nr_pages; 1893

1894 **if** (**folio_test_writeback**(folio)) 1895 **goto keep**; 1896 **if** (**folio_test_dirty**(folio)) 1897 **goto keep**;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1898

1899 */\** 1900 *\* A synchronous write - probably a ramdisk.*

*Go*

1901 *\* ahead and try to reclaim the folio.* 1902 *\*/* 1903 **if** (!**folio_trylock**(folio)) 1904 **goto keep**; 1905 **if** (**folio_test_dirty**(folio) \|\| 1906 **folio_test_writeback**(folio)) 1907 **goto keep_locked**; 1908 mapping = **folio_mapping**(folio); 1909 **fallthrough**; 1910 **case PAGE_CLEAN**: 1911 ; */\* try to free the folio below \*/* 1912 } 1913 }

 

*Listing 11-67:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Dirty Folio Handling*

 

The portion of [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) examined in Listing 11-67 handles dirty

folios undergoing reclaim.

Only indirect reclaim handles dirty file-backed folios, to avoid kernel

stacks getting too deep resulting in stack overflow, which in a kernel context

is a fatal error and results in a kernel panic and the system halting.

This is because we cannot be sure the size of the kernel stack when direct

reclaiming as a result of a page allocation, whereas the kswapd kernel process

has well defined structure.

In addition, we only writeback dirty file-backed folios if it has not already

been marked with [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) (we did not previously skip the folio before)

and the [PGDAT_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n686) node flag has been set, indicating that all the folios ex-

amined were dirty and none had begun writeback.

Otherwise a file-backed folio has [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) set, ensuring that

upon writeback it will be immediately scheduled for reclaim via

[folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n283) (see Listing 11-92 and Section 11.7.7)) which is

invoked on writeback termination in [folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599) (see Chapter 10

for more on writeback as a whole).

This folio is then activated, in order to give it a chance to be written back

before being considered for reclaim once again.

Next we check to see whether [folio_check_references()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433) (see Listing 11-70

and Section 11.5.10) indicated that the reclaim should be only if the folio is

clean—that is, it was previously referenced. In this instance we keep the folio,

rotating it to the back of the LRU vector.

If we can’t enter the file system due to the Get Free Pages (GFP) flags

associated with the allocation which triggered reclaim (see Section 2.6 in

## Chapter 2 for more on GFP flags), as checked by [may_enter_fs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1570), or if the

[struct scan_control-\>may_writepage](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n66) flag is cleared, then clearly writeback can-

not proceed so we also rotate the folio in these cases.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We invoke [try_to_unmap_flush_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n630) to ensure the TLB is flushed as nec-

essary before we start trying to write I/O which might unnecessarily re-dirty the folio.

See Section 7.1 in Chapter 7 for more details on how folios are freed and

the TLB is maintained within the kernel.

Next we go ahead and try to start writeback on the dirty folio. If it is an

anonymous, swap-backed folio then this begins the process of writing the

folio’s data into the swap (see Section 12.2.3 in Chapter 12 for more on this).

We perform this paging out via [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) which we examine in Listing

11-71 and Section 11.5.11 where we explore this function.

This function returns a [pageout_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1209) enumeration value indicating how to

proceed—[PAGE_KEEP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1202) indicates that the folio should be rotated to the back of the current LRU vector as the writeback is not complete yet (it remains

locked), [PAGE_ACTIVATE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1204) indicates that it should be moved to the active LRU

vector, that is activated (it remains locked), [PAGE_SUCCESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1206) indicates that the folio has been immediately written to disk and is now unlocked and finally

[PAGE_CLEAN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1208) indicates the folio was found to be clean and didn’t require page out (it remains locked).

In the case of [PAGE_KEEP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1202) we move to rotate the folio immediately, other-

wise if [PAGE_ACTIVATE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1204) is returned we move to activate it. [PAGE_CLEAN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1208) indicates that the folio was in fact not dirty, and so we immediately move directly to

the next part of [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) in Listing 11-68.

In the case of [PAGE_SUCCESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1206) (indicating that the folio has been submitted

for writeback, most likely asynchronously) there is a little more to do. We

check again that [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) and [PG_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n104) are cleared, before attempting to lock and checking again under the lock. If the folio is dirty, under writeback or we cannot lock it, then we rotate the folio.

We typically expect the folio here to be under writeback as it will be asyn-

chronously proceeding through writeback, so likely the folio will be rotated here waiting for writeback to complete.

With this done, we proceed to the next part of [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589), con-

cerned with handling the lazy-free case and removal of the folio from its

owning mapping. We explore this in Listing 11-68.

 

1959 **if** (**folio_test_anon**(folio) && !**folio_test_swapbacked**(folio)) { 1960 */\* follow \_\_remove_mapping for reference \*/* 1961 **if** (!**folio_ref_freeze**(folio, 1)) 1962 **goto keep_locked**; 1963 */\** 1964 *\* The folio has only one reference left, which is*

1965 *\* from the isolation. After the caller puts the* 1966 *\* folio back on the lru and drops the reference, the*

1967 *\* folio will be freed anyway. It doesn't matter* 1968 *\* which lru it goes on. So we don't bother checking*

1969 *\* the dirty flag here.* 1970 *\*/*

. . .

1973 } **else if** (!mapping \|\| !**\_\_remove_mapping**(mapping, folio, **true**,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1974 sc-\>target_mem_cgroup

))

1975 **goto keep_locked**;

 

*Listing 11-68:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Lazy Free and Mapping Removal*

 

In the portion of [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) explored in Listing 11-68, we first

consider the lazy-free case—this is an instance where a user has freed a range

of memory using [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) with the MADV_FREE flag. These folios are marked

as anonymous but without the [PG_swapbacked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n120) flag being set.

In this instance, we just immediately freeze the folio, that is atomically

swap its expected reference count of one with zero, so that when we move

to free the folio later (in Listing 11-69) it is immediately freed without any

further action being required.

Otherwise we check whether the folio has a mapping (rather poorly

named unfortunately), that is, a page cache or swap cache entry that refers

to it. If so, we remove the folio from this mapping via [\_\_remove_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289) (see

Listing 11-73), as described in detail in Section 11.5.12.

If this fails, or the lazy-free freezing fails, we simply keep and rotate the

folio.

Next we examine the final part of [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) in Listing 11-69.

 

1978 **folio_unlock**(folio);

. . .

1980 */\**

1981 *\* Folio may get swapped out as a whole, need to account* 1982 *\* all pages in it.* 1983 *\*/*

1984 nr_reclaimed += nr_pages;

. . .

1992 **list_add**(&folio-\>lru, &free_pages); 1993 **continue**; 1994

1995 **activate_locked_split**:

. . .

2004 **activate_locked**:

2005 */\* Not a candidate for swapping, so reclaim swap space. \*/*

2006 **if** (**folio_test_swapcache**(folio) && 2007 (**mem_cgroup_swap_full**(&folio-\>page) \|\| 2008 **folio_test_mlocked**(folio))) 2009 **try_to_free_swap**(&folio-\>page);

. . .

2011 **if** (!**folio_test_mlocked**(folio)) { 2012 **int** type = **folio_is_file_lru**(folio); 2013 **folio_set_active**(folio); 2014 stat-\>nr_activate\[type\] += nr_pages;

. . .

2016 }

2017 **keep_locked**:

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2018 **folio_unlock**(folio); 2019 **keep**:

2020 **list_add**(&folio-\>lru, &ret_pages);

. . .

2023 }

2024 */\* 'page_list' is always empty here \*/*

. . .

2039 **try_to_unmap_flush**(); 2040 **free_unref_page_list**(&free_pages); 2041

2042 **list_splice**(&ret_pages, page_list);

. . .

2047 **return** nr_reclaimed; 2048 }

 

*Listing 11-69:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Suffix*

 

The portion of [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) explored in Listing 11-69 firstly handles

the successful case where the folio has reached the point of being ready to be freed due to reclaim. It is unlocked, we increment the nr_reclaimed count we return to the caller, and we add the folio to the free_list for bulk freeing, before looping around to the next folio.

We then consider each of the labels we have been jumping to for activa-

tion and keeping (that is rotation) of folios.

On activation we check to see whether the folio is in the swap cache

and the swap cache is full (checked via [mem_cgroup_swap_full()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memcontrol.c?h=v6.0#n7379), a function which correctly identifies whether available swap resource is full even in the

non-cgroup case) or if the folio is [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)[ed](https://man7.org/linux/man-pages/man2/mlock.2.html) and thus not eligible for swap-ping out, in which case we try to free up the relevant swap cache space via

[try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1590) (see Listing 12-31 and Section 12.2.4 in Chapter 12 for de-tails).

We check again to ensure the folio is not [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)ed (for instance it be-

came so during a period it was not locked), in which case activation is not especially meaningful.

If not, then we set the [PG_active](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n106) flag, which, when the folio is placed

back into an LRU will cause it to be placed into the active LRU whether it is anonymous or file-backed.

Whether we are keeping or activating a locked folio, we unlock it before

we proceed, and whether activating or keeping a folio in general, we add it to the ret_pages list.

At this stage we reach the end of the loop, at which point the input

page_list will be empty.

We invoke [try_to_unmap_flush](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n617) to perform a batched TLB flush before we

try to free the folios, especially as we wish to avoid any writes occurring on file-backed folios that might cause them to be unnecessarily re-dirtied.

See Section 7.1 in Chapter 7 for more details on how folios are freed and

the TLB is maintained within the kernel.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We then go ahead and free successfully reclaimed folios on the free_list

via [free_unref_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510) to the physical allocator (see Chapter 2 for details

on the physical memory allocator).

With this done, we place any folios that are to be kept (that is rotated) or

activated which we stored in ret_pages to the input page_list so the caller can

place these back into the appropriate LRU vectors.

Finally, we return the number of base pages we reclaimed during the op-

eration.

 

***11.5.10 Reclaim Folio Reference Checking***

A key part of reclaim and the Last Recently Used (LRU) algorithm is being

able to determine whether data has been accessed or not. As described in

Section 11.2, we maintain active and inactive LRU lists in order to practically

approximate a true LRU algorithm in an efficient manner.

We do this by examining folios in the inactive LRU vector when memory

pressure arises and only then checking whether the folio has been accessed

since we last checked.

We achieve this through a useful feature provided by hardware which

is the accessed or “young” page table flag—for instance in x86-64 this is

checked via [pte_young()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n132) which checks for the [\_PAGE_ACCESSED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n46) flag.

The useful quality of this flag is that it can be cleared by software but is

set by hardware when that mapping is accessed.

The function which performs this check and applies the LRU vector logic

around folio references is [folio_check_references()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433), which we examine in List-

ing 11-70.

 

1433 **static enum** page_references **folio_check_references**(**struct** folio \*folio, 1434 **struct** scan_control \*sc) 1435 {

1436 **int** referenced_ptes, referenced_folio; 1437 **unsigned long** vm_flags; 1438

1439 referenced_ptes = **folio_referenced**(folio, 1, sc-\>target_mem_cgroup, 1440 &vm_flags); 1441 referenced_folio = **folio_test_clear_referenced**(folio); 1442

1443 */\**

1444 *\* The supposedly reclaimable folio was found to be in a VM_LOCKED vma*

*.*

1445 *\* Let the folio, now marked Mlocked, be moved to the unevictable list*

*.*

1446 *\*/*

1447 **if** (vm_flags & **VM_LOCKED**) 1448 **return PAGEREF_ACTIVATE**; 1449

1450 */\* rmap lock contention: rotate \*/* 1451 **if** (referenced_ptes == -1)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1452 **return PAGEREF_KEEP**; 1453

1454 **if** (referenced_ptes) { 1455 */\**

1456 *\* All mapped folios start out with page table* 1457 *\* references from the instantiating fault, so we need* 1458 *\* to look twice if a mapped file/anon folio is used more*

1459 *\* than once.* 1460 *\**

1461 *\* Mark it and spare it for another trip around the* 1462 *\* inactive list. Another page table reference will* 1463 *\* lead to its activation.* 1464 *\**

1465 *\* Note: the mark is set for activated folios as well* 1466 *\* so that recently deactivated but used folios are* 1467 *\* quickly recovered.* 1468 *\*/*

1469 **folio_set_referenced**(folio); 1470

1471

1472

1473 **if** (referenced_folio \|\| referenced_ptes \> 1) 1474 **return PAGEREF_ACTIVATE**; 1475

1476 */\**

1477 *\* Activate file-backed executable folios after first usage.*

1478 *\*/*

1479 **if** ((vm_flags & **VM_EXEC**) && **folio_is_file_lru**(folio)) 1480 **return PAGEREF_ACTIVATE**; 1481

1482 **return PAGEREF_KEEP**; 1483 }

1484

1485 */\* Reclaim if clean, defer dirty folios to writeback \*/* 1486 **if** (referenced_folio && **folio_is_file_lru**(folio)) 1487 **return PAGEREF_RECLAIM_CLEAN**; 1488

1489 **return PAGEREF_RECLAIM**; 1490 }

 

*Listing 11-70:* mm/vmscan.c: [*folio_check_references()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433)

 

The [folio_check_references()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1433) function first uses [folio_referenced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n900) to walk

the reverse-mapping of the folio and first detect all [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) objects which map the folio, before walking each of their page tables until we reach the PTE level at which point we check for the accessed page table flag, and atomically clear it at the same time.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Each VMA is examined by this reverse mapping functionality using the

[folio_referenced_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n816) function which performs this operation.

The [folio_referenced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n900) function also retrieves a set of all the flags of

VMAs which reference the folio which gets returned to the caller. This func-

tion returns the number of references found.

See Chapter 3 for more on page tables, Chapter 4 for more on VMAs

and process memory and Chapter 7 for more on the reverse mapping.

After retrieving this information, we test for, then clear the folio’s

[PG_referenced](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n102) flag.

This flag is used to indicate that a folio was found to be referenced the

last time we checked. We clear it each time so it will only be set if the folio

was referenced again since we last checked it.

Before performing the reference handling however, we check for two

edge cases—if the folio is from a virtual range that is [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)ed, as indicated

by the [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) flag, then it can’t be reclaimed, so we activate it to get it out

the way of reclaim.

Equally if we had some lock contention when trying to determine folio

references, indicated by [folio_referenced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n900) returning-1, we simply rotate the

folio.

Finally we perform the core check—if any mappings did indeed reference

this folio since we last checked, we set the [PG_referenced](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n102) flag.

We then determine whether this happened on the last check two, or if

there was a reference from more than one mapping—in either case this indi-

cates that this folio is likely part of the working set, most certainly in use at

this time, and thus should be activated.

Otherwise we consider a special case—if the folio was referenced but did

not previously have the [PG_referenced](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n102) flag set, but is file-backed and maps

executable code (as indicated by the [VM_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n268) VMA flag), we skip the double

reference check and simply indicate that we should activate it right away as

indicated by [PAGEREF_ACTIVATE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1429)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1429)

 

**N O T E** The kernel makes a special effort to quickly activate executable code mappings, as

reclaiming these can be costly in terms of latency of executing code.

 

If the folio was referenced but not previously, we rotate it to the back of

the current list indicated by [PAGEREF_KEEP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1429).

If the folio was not referenced since last we checked it, this indicates it is

eligible for reclaim. If the folio is file-backed we return [PAGEREF_RECLAIM_CLEAN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1428)

indicating that we should reclaim only if clean, leaving writeback to handle

the dirty data.

Otherwise, we return [PAGEREF_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1427) indicating the folio is simply avail-

able for reclaim.

 

***11.5.11 Reclaim Page Out***

When we need to write back dirty folios to disk, whether swap-backed folios

in the swap cache being written out to the swap on disk or dirty file-backed

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

folios, we do this via [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215), which we examine in Listing 11-71 (eliding out of scope buffer handling, trace hooks and statistical updates).

 

1211 */\**

1212 *\* pageout is called by shrink_page_list() for each dirty page.* 1213 *\* Calls -\>writepage().*

1214 *\*/*

1215 **static** pageout_t **pageout**(**struct** folio \*folio, **struct** address_space \*mapping, 1216 **struct** swap_iocb \*\*plug) 1217 {

1218 */\**

1219 *\* If the folio is dirty, only perform writeback if that write* 1220 *\* will be non-blocking. To prevent this allocation from being* 1221 *\* stalled by pagecache activity. But note that there may be* 1222 *\* stalls if we need to run get_block(). We could test* 1223 *\* PagePrivate for that.* 1224 *\**

1225 *\* If this process is currently in \_\_generic_file_write_iter() against*

1226 *\* this folio's queue, we can perform writeback even if that* 1227 *\* will block.*

1228 *\**

1229 *\* If the folio is swapcache, write it back even if that would* 1230 *\* block, for some throttling. This happens by accident, because* 1231 *\* swap_backing_dev_info is bust: it doesn't reflect the* 1232 *\* congestion state of the swapdevs. Easy to fix, if needed.* 1233 *\*/*

1234 **if** (!**is_page_cache_freeable**(folio)) 1235 **return PAGE_KEEP**; 1236 **if** (!mapping) {

. . .

1248 **return PAGE_KEEP**; 1249 }

1250 **if** (mapping-\>a_ops-\>**writepage** == **NULL**) 1251 **return PAGE_ACTIVATE**; 1252

1253 **if** (**folio_clear_dirty_for_io**(folio)) { 1254 **int** res;

1255 **struct** writeback_control wbc = { 1256 .sync_mode = **WB_SYNC_NONE**, 1257 .nr_to_write = **SWAP_CLUSTER_MAX**, 1258 .range_start = 0, 1259 .range_end = **LLONG_MAX**, 1260 .for_reclaim = 1, 1261 .swap_plug = plug, 1262 };

1263

1264 **folio_set_reclaim**(folio); 1265 res = mapping-\>a_ops-\>**writepage**(&folio-\>page, &wbc);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1266 **if** (res \< 0) 1267 **handle_write_error**(mapping, folio, res); 1268 **if** (res == **AOP_WRITEPAGE_ACTIVATE**) { 1269 **folio_clear_reclaim**(folio); 1270 **return PAGE_ACTIVATE**; 1271 }

1272

1273 **if** (!**folio_test_writeback**(folio)) { 1274 */\* synchronous write or broken a_ops? \*/* 1275 **folio_clear_reclaim**(folio); 1276 }

. . .

1279 **return PAGE_SUCCESS**; 1280 }

1281

1282 **return PAGE_CLEAN**; 1283 }

 

*Listing 11-71:* mm/vmscan.c: [*pageout()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215)

 

We start [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) by performing the checking whether the associated

page cache (or swap) entry is freeable, via [is_page_cache_freeable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1039) which we

examine in Listing 11-72.

 

1039 **static inline int is_page_cache_freeable**(**struct** folio \*folio) 1040 {

1041 */\**

1042 *\* A freeable page cache page is referenced only by the caller* 1043 *\* that isolated the page, the page cache and optional buffer* 1044 *\* heads at page-\>private.* 1045 *\*/*

1046 **return folio_ref_count**(folio) -**folio_test_private**(folio) == 1047 1 + **folio_nr_pages**(folio); 1048 }

 

*Listing 11-72:* mm/vmscan.c: [*is_page_cache_freeable*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1039)

 

[is_page_cache_freeable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1039) importantly ensures that we do not attempt to re-

claim a folio that has been pinned beyond the references that we expect.

Returning to [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) in Listing 11-71, we see that we indicate that the

folio should be rotated if it is not currently freeable, equally if no mapping

was specified (indicating an anonymous folio without swap cache for in-

stance), then we do the same.

We then check to see whether we have a virtual file system hook to be

able to write the individual folio out via a [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356)

hook in [struct address_space-\>a_ops-\>writepage](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424).

If not we cannot write the page out, but since it’s dirty, we should get it

out of the way of reclaim and thus indicate to activate it.

Finally we are ready to proceed with writeback. We start by invoking

[folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826), which checks to ensure that we can writeback

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

and resets the dirty flag, marking the folio clean (and associated mappings, though in this instance mappings should be cleared).

See Listing 10-30 in Section 10.10 and Chapter 10 for a detailed explo-

ration of this.

If we are able to writeback, we write back [SWAP_CLUSTER_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214) pages, setting

the [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) flag so when writeback ends the folio is immediately put to the

front of the queue for reclaim via [folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n283) (see Listing 11-

92 and Section 11.7.7)). This function is invoked when writeback is complete

in [folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599) (see Chapter 10 for more on writeback as a whole).

We handle any write errors, and the file system indicating that the fo-

lio should instead be activated, also we check to see if synchronous I/O oc-

curred, i.e. whether the folio’s [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag has been cleared. If so we

clear [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) as we know for a fact writeback is now complete.

In this case we return indicating that we succeeded in paging out, other-

wise if [folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826) failed, this indicates that the folio was not in fact dirty at the point we attempted to invoke this and thus we return indi-cating the folio is clean.

See Section 12.2.4 in Chapter 12 for a detailed swap-specific analysis of

this logic.

 

***11.5.12 Reclaim Mapping Removal***

When a folio undergoes reclaim and is about to be freed, we must remove it from the “mapping” which contains it, that is whatever is returned by the

[folio_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799) function.

In the case of a file-backed folio, this will be the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) ob-

ject describing the page cache entry (see Chapter 9 for more on the page

cache), for an anonymous folio this will be the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object describing the swapper address space describing the swap cache which con-tains the folio, or NULL if there is no such entry (that is, the folio is not in the swap cache).

 

**N O T E** Mapping is a poor name for what this entity represents, that is the aggregate ab-

straction which the folio finds itself a part of. It is easily confused with a folio’s ref-erences (the number of times it has been accessed since we last checked) or whether it’s mapped (determined by folio map counts).

 

For those instances where there is a mapping, reclaim invokes

[\_\_remove_mapping() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289)which we examine in Listing 11-73 (eliding bug checks, some larger comments, out of scope working set and cgroup logic, and map-ping shrinking logic).

 

1289 **static int \_\_remove_mapping**(**struct** address_space \*mapping, **struct** folio \*folio

,

1290 **bool** reclaimed, **struct** mem_cgroup \*target_memcg) 1291 {

1292 **int** refcount;

. . .

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1298 **if** (!**folio_test_swapcache**(folio)) 1299 **spin_lock**(&mapping-\>host-\>i_lock); 1300 **xa_lock_irq**(&mapping-\>i_pages);

. . .

1326 refcount = 1 + **folio_nr_pages**(folio); 1327 **if** (!**folio_ref_freeze**(folio, refcount)) 1328 **goto cannot_free**; 1329 */\* note: atomic_cmpxchg in page_ref_freeze provides the smp_rmb \*/*

1330 **if** (**unlikely**(**folio_test_dirty**(folio))) { 1331 **folio_ref_unfreeze**(folio, refcount); 1332 **goto cannot_free**; 1333 }

1334

1335 **if** (**folio_test_swapcache**(folio)) { 1336 **swp_entry_t** swap = **folio_swap_entry**(folio);

. . .

1340 **\_\_delete_from_swap_cache**(folio, swap, shadow); 1341 **xa_unlock_irq**(&mapping-\>i_pages); 1342 **put_swap_page**(&folio-\>page, swap); 1343 } **else** {

1344 **void** (\***free_folio**)(**struct** folio \*); 1345

1346 **free_folio** = mapping-\>a_ops-\>**free_folio**;

. . .

1366 **\_\_filemap_remove_folio**(folio, shadow); 1367 **xa_unlock_irq**(&mapping-\>i_pages);

. . .

1370 **spin_unlock**(&mapping-\>host-\>i_lock); 1371

1372 **if** (**free_folio**) 1373 **free_folio**(folio); 1374 }

1375

1376 **return** 1;

1377

1378 **cannot_free**:

1379 **xa_unlock_irq**(&mapping-\>i_pages); 1380 **if** (!**folio_test_swapcache**(folio)) 1381 **spin_unlock**(&mapping-\>host-\>i_lock); 1382 **return** 0;

1383 }

 

*Listing 11-73:* mm/vmscan.c: [*\_\_remove_mapping()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289)

 

The [\_\_remove_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289) function starts by acquiring the appropriate locks

to be able to remove the folio from its mapping.

After this we perform a vital reference count check—we must avoid re-

claiming folios which are pinned by kernel tasks, and at this stage we expect

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

the page cache or swap cache to hold a reference in addition to the isolation we have applied to the folio pages.

We invoke [folio_ref_freeze()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n325) which attempts to atomically swap the ex-

isting reference count with zero. If this fails we simply exit, as we cannot re-move the folio from its mapping and thus cannot go on to free it.

We then double-check the folio is not dirty, unfreezing the folio and

aborting if so.

Next we consider the swap case—in this instance we delete the folio from

the swap cache. See Section 12.2.4 in Chapter 12 for a detailed analysis.

Otherwise, we remove the folio from the xarray containing it within its

containing [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object via [\_\_filemap_remove_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n217)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n217) which we

examine in detail in Listing 9-89 and Section 9.9.1 in Chapter 9.

If the file system provides a free_folio()hook

in its [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) hook in

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>a_ops-\>free_folio then we invoke it.

We then return indicating the operation succeeded.

 

**11.6 Reclaim Throttling**

 

***11.6.1 General Reclaim Throttling***

There are a number of circumstances in which we must suspend reclaim for a period of time as reclaim is not making progress for one reason or an-

other. This is performed in [reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104) which we examine shortly in

Listing 11-75.

We examine the callers of this function in Figure 11-23.

 

Direct Reclaim

[shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3463)

 

Reclaim Mechanism Reclaim Mechanism Writeback

[consider_reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3425) [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194) [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402) [do_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457)

 

If no progress If writeback needed If too many Sync-all write cannot alloc or congested folios isolated

[reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104)

If too many

folios isolated

[isolate_migratepages_block()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n788)

Compaction

 

*Figure 11-23: Callers of* [*reclaim_throttle()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104)

 

In the case of direct reclaim, we have specific direct reclaim throt-

tling designed for instances where something like a very slow backing store causes writeback to be very slow. This specific case is handled in

[throttle_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3721) (see Listing 11-77), as discussed in Section 11.6.2.

Additionally, we consider the case where direct reclaim is stuck making

no progress, where it would be appropriate to simply sleep for a while. This

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

is invoked by [shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3463) (see Listing 11-21 and Section 11.3), which in

turn calls [consider_reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3425) which we examine in Listing 11-74.

 

3425 **static void consider_reclaim_throttle**(pg_data_t \*pgdat, **struct** scan_control \*

sc)

3426 {

3427 */\**

3428 *\* If reclaim is making progress greater than 12% efficiency then* 3429 *\* wake all the NOPROGRESS throttled tasks.* 3430 *\*/*

3431 **if** (sc-\>nr_reclaimed \> (sc-\>nr_scanned \>\> 3)) { 3432 **wait_queue_head_t** \*wqh; 3433

3434 wqh = &pgdat-\>reclaim_wait\[**VMSCAN_THROTTLE_NOPROGRESS**\]; 3435 **if** (**waitqueue_active**(wqh)) 3436 **wake_up**(wqh); 3437

3438 **return**;

3439 }

3440

3441 */\**

3442 *\* Do not throttle kswapd or cgroup reclaim on NOPROGRESS as it will*

3443 *\* throttle on VMSCAN_THROTTLE_WRITEBACK if there are too many pages*

3444 *\* under writeback and marked for immediate reclaim at the tail of the*

3445 *\* LRU.*

3446 *\*/*

3447 **if** (**current_is_kswapd**() \|\| **cgroup_reclaim**(sc)) 3448 **return**;

3449

3450 */\* Throttle if making no progress at high prioities. \*/* 3451 **if** (sc-\>priority == 1 && !sc-\>nr_reclaimed) 3452 **reclaim_throttle**(pgdat, **VMSCAN_THROTTLE_NOPROGRESS**); 3453 }

 

*Listing 11-74:* mm/vmscan.c: [*consider_reclaim_throttle()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3425)

 

The reclaim throttle mechanism operates using the

[struct pglist_data-\>reclaim_wait](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) array which contains wait queues for

each category of reclaim throttling.

 

**N O T E** As mentioned elsewhere in the book wait queues are a means within the kernel for

threads to wait on a certain event to occur, sleeping as they do so. In the instance of

reclaim throttling, we establish a wait queue entry when the throttling occurs, then

sleep, however we expose the wait queues so that the threads can be woken up.

 

The [consider_reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3425) function shown in Listing 11-74 is in-

voked by [shrink_zones()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3463) as part of direct reclaim for the first node from

which an allocation could be made.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

In this function, we are concerned with the determining whether direct

reclaim is making sufficient progress—we in essence have a high water mark, at which point we wake all throttled processes, that is if the number of re-claimed pages exceeds 3 2 or 1*/*8 that is 12.5% of scanned pages.

Otherwise, if no reclaim has taken place at all and we are at the lowest

priority level (one, that is the case in which we scan the entire inactive and active lists), this suggest we are failing to make progress at all, and therefore

we should throttle this process via [reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104) (see Listing 11-75).

In this instance we specify this case via the [enum vmscan_throttle_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n287)

value [VMSCAN_THROTTLE_NOPROGRESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n290).

We examine the [reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104) function in Listing 11-75 (eliding real-

time kernel scheduling logic and trace hooks).

 

1104 **void reclaim_throttle**(**pg_data_t** \*pgdat, **enum** vmscan_throttle_state reason) 1105 {

1106 **wait_queue_head_t** \*wqh = &pgdat-\>reclaim_wait\[reason\]; 1107 **long** timeout, ret; 1108 **DEFINE_WAIT**(wait); 1109

1110 */\**

1111 *\* Do not throttle IO workers, kthreads other than kswapd or* 1112 *\* workqueues. They may be required for reclaim to make* 1113 *\* forward progress (e.g. journalling workqueues or kthreads).* 1114 *\*/*

1115 **if** (!**current_is_kswapd**() && 1116 current-\>flags & (**PF_IO_WORKER**\|**PF_KTHREAD**)) {

. . .

1118 **return**;

1119 }

1120

1121 */\**

1122 *\* These figures are pulled out of thin air.* 1123 *\* VMSCAN_THROTTLE_ISOLATED is a transient condition based on too many*

1124 *\* parallel reclaimers which is a short-lived event so the timeout is*

1125 *\* short. Failing to make progress or waiting on writeback are* 1126 *\* potentially long-lived events so use a longer timeout. This is*

*shaky*

1127 *\* logic as a failure to make progress could be due to anything from*

1128 *\* writeback to a slow device to excessive references pages at the*

*tail*

1129 *\* of the inactive LRU.* 1130 *\*/*

1131 **switch**(reason) {

1132 **case VMSCAN_THROTTLE_WRITEBACK**: 1133 timeout = **HZ**/10; 1134

1135 **if** (**atomic_inc_return**(&pgdat-\>nr_writeback_throttled) == 1) { 1136 **WRITE_ONCE**(pgdat-\>nr_reclaim_start,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1137 **node_page_state**(pgdat, **NR_THROTTLED_WRITTEN**)); 1138 }

1139

1140 **break**;

1141 **case VMSCAN_THROTTLE_CONGESTED**: 1142 **fallthrough**; 1143 **case VMSCAN_THROTTLE_NOPROGRESS**: 1144 **if** (**skip_throttle_noprogress**(pgdat)) {

. . .

1146 **return**; 1147 }

1148

1149 timeout = 1; 1150

1151 **break**;

1152 **case VMSCAN_THROTTLE_ISOLATED**: 1153 timeout = **HZ**/50; 1154 **break**;

1155 **default**:

1156 **WARN_ON_ONCE**(1); 1157 timeout = **HZ**; 1158 **break**;

1159 }

1160

1161 **prepare_to_wait**(wqh, &wait, **TASK_UNINTERRUPTIBLE**); 1162 ret = **schedule_timeout**(timeout); 1163 **finish_wait**(wqh, &wait); 1164

1165 **if** (reason == **VMSCAN_THROTTLE_WRITEBACK**) 1166 **atomic_dec**(&pgdat-\>nr_writeback_throttled);

. . .

1171 }

 

*Listing 11-75:* mm/vmscan.c: [*reclaim_throttle()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104)

 

In [reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104) we handle four different cases:

 

[**VMSCAN_THROTTLE_WRITEBACK**](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n288) Folios under writeback saturated reclaim and still

have not been written back to disk, so we must throttle reclaim to give

them a chance to do so. See Section 11.5.3 for more on how this arises.

[**VMSCAN_THROTTLE_ISOLATED**](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n289) A situation can arise where many direct reclaimers

are sleeping having isolated batches of folios (see Section 11.5.8 for more on folio isolation), resulting in the number of isolated folios grow-ing too far and causing the LRU lists to grow smaller than they should be. In this instance we throttle. This is invoked by both reclaim logic and compaction both of which isolate folios.

[**VMSCAN_THROTTLE_NOPROGRESS**](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n290) Invoked by [consider_reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3425) (see Listing

11-74) when direct reclaim has made no progress.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[**VMSCAN_THROTTLE_CONGESTED**](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n291) Folios marked for writeback and immediate re-

claim have cycled through the list without being written back (and thus reclaimed) yet, so we throttle reclaim in order to give these folios

a chance to be written back. See Section 11.5.3 for more on how this arises.

 

The [reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104) function shown in Listing 11-75 starts by skipping

throttling for non-kswapd kernel threads or I/O workers in order to avoid stopping forward progress required for reclaim to succeed.

We then determine a series of arbitrary timeouts based on the throttle

modes, in the case of [VMSCAN_THROTTLE_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n288) keeping track of writeback

throttling occurring in [struct pglist_data](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905)-\>nr_writeback_throttled, also set-

ting the [struct pglist_data-\>nr_reclaim_start](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) field each time this is first incre-mented, i.e. when writeback throttling first starts, tracking the number of base pages written when throttled.

We throttle 1/10th of a second in the [VMSCAN_THROTTLE_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n288) case, in

the case of [VMSCAN_THROTTLE_CONGESTED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n291) and [VMSCAN_THROTTLE_NOPROGRESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n290) we wait

the minimum time possible, unless [skip_throttle_noprogress()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1071) indicates we

should not (we explore this in Listing 11-76 shortly).

Finally in [VMSCAN_THROTTLE_ISOLATED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n289) mode we wait 1/50th of a second.

We then perform the sleep via [prepare_to_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n260)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n260) [schedule_timeout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/time/timer.c?h=v6.0#n1896) and

[finish_wait(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n387)See the discussion around Listing 11-29 for a discussion of these.

Note that we can be woken up early during this process.

Finally, in the [VMSCAN_THROTTLE_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n288) case we decrement

[struct pglist_data-\>nr_writeback_throttled](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) since the throttling is completed.

We examine [skip_throttle_noprogress()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1071) in Listing 11-76.

 

1071 **static bool skip_throttle_noprogress**(**pg_data_t** \*pgdat) 1072 {

1073 **int** reclaimable = 0, write_pending = 0; 1074 **int** i;

1075

1076 */\**

1077 *\* If kswapd is disabled, reschedule if necessary but do not* 1078 *\* throttle as the system is likely near OOM.* 1079 *\*/*

1080 **if** (pgdat-\>kswapd_failures \>= **MAX_RECLAIM_RETRIES**) 1081 **return true**; 1082

1083 */\**

1084 *\* If there are a lot of dirty/writeback pages then do not* 1085 *\* throttle as throttling will occur when the pages cycle* 1086 *\* towards the end of the LRU if still under writeback.* 1087 *\*/*

1088 **for** (i = 0; i \< **MAX_NR_ZONES**; i++) { 1089 **struct** zone \*zone = pgdat-\>node_zones + i; 1090

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1091 **if** (!**managed_zone**(zone)) 1092 **continue**; 1093

1094 reclaimable += **zone_reclaimable_pages**(zone); 1095 write_pending += **zone_page_state_snapshot**(zone, 1096 **NR_ZONE_WRITE_PENDING**); 1097 }

1098 **if** (2 \* write_pending \<= reclaimable) 1099 **return true**; 1100

1101 **return false**;

1102 }

 

*Listing 11-76:* mm/vmscan.c: [*skip_throttle_noprogress()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1071)

 

In [skip_throttle_noprogress()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1071) we start by indicating that we should skip

throttling if indirect reclaim has failed (we have failed to reclaim folios

[MAX_RECLAIM_RETRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n170) times (hard-coded to sixteen) and this node’s kswapd ker-

nel thread is now halted.

Then we determine if the write pending page count (a sum of dirty,

writeback, or otherwise unstable pages) is less than or equal to half of all re-

claimable pages (the sum of the sizes of all of the LRU vectors), if so we skip

throttling.

If it is more, then we do not skip throttling. Therefore we must see a lot

of dirty/writeback pages before throttling occurs.

All of these kind of consideration are heuristics based on real workloads

and tweak reclaim behaviour accordingly.

 

***11.6.2 Direct Reclaim Throttling***

When performing direct reclaim, the [PF_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713) flag is set in the current

thread’s [struct task_struct-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) field in [\_\_perform_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4737) (see Listing 11-

18).

This causes [\_\_gfp_pfmemalloc_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4876) (see Listing 11-5 in Section 11.1) to

permit watermarks to be ignored (via [ALLOC_NO_WATERMARKS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n760)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n760)

This is something of a risk if, for some reason, reclaim performs slowly,

then we may end up reaching dangerously low levels of memory reserve. To

avoid this, we check whether reserves are running low and throttle direct

reclaim if so.

This is performed by [throttle_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3721)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3721) as shown in Listing 11-77.

 

3712 */\**

3713 *\* Throttle direct reclaimers if backing storage is backed by the network* 3714 *\* and the PFMEMALLOC reserve for the preferred node is getting dangerously*

3715 *\* depleted. kswapd will continue to make progress and wake the processes* 3716 *\* when the low watermark is reached.* 3717 *\**

3718 *\* Returns true if a fatal signal was delivered during throttling. If this*

3719 *\* happens, the page allocator should not consider triggering the OOM killer.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3720 *\*/*

3721 **static bool throttle_direct_reclaim**(**gfp_t** gfp_mask, **struct** zonelist \*zonelist, 3722 **nodemask_t** \*nodemask) 3723 {

3724 **struct** zoneref \*z; 3725 **struct** zone \*zone; 3726 pg_data_t \*pgdat = **NULL**; 3727

3728 */\**

3729 *\* Kernel threads should not be throttled as they may be indirectly*

3730 *\* responsible for cleaning pages necessary for reclaim to make*

*forward*

3731 *\* progress. kjournald for example may enter direct reclaim while*

3732 *\* committing a transaction where throttling it could forcing other*

3733 *\* processes to block on log_wait_commit().* 3734 *\*/*

3735 **if** (**current**-\>flags & **PF_KTHREAD**) 3736 **goto out**; 3737

3738 */\**

3739 *\* If a fatal signal is pending, this process should not throttle.*

3740 *\* It should return quickly so it can exit and free its memory* 3741 *\*/*

3742 **if** (**fatal_signal_pending**(**current**)) 3743 **goto out**; 3744

3745 */\**

3746 *\* Check if the pfmemalloc reserves are ok by finding the first node*

3747 *\* with a usable ZONE_NORMAL or lower zone. The expectation is that*

3748 *\* GFP_KERNEL will be required for allocating network buffers when*

3749 *\* swapping over the network so ZONE_HIGHMEM is unusable.* 3750 *\**

3751 *\* Throttling is based on the first usable node and throttled*

*processes*

3752 *\* wait on a queue until kswapd makes progress and wakes them. There*

3753 *\* is an affinity then between processes waking up and where reclaim*

3754 *\* progress has been made assuming the process wakes on the same node.*

3755 *\* More importantly, processes running on remote nodes will not*

*compete*

3756 *\* for remote pfmemalloc reserves and processes on different nodes*

3757 *\* should make reasonable progress.* 3758 *\*/*

3759 **for_each_zone_zonelist_nodemask**(zone, z, zonelist, 3760 **gfp_zone**(gfp_mask), nodemask) { 3761 **if** (zone_idx(zone) \> **ZONE_NORMAL**) 3762 **continue**; 3763

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3764 */\* Throttle based on the first usable node \*/* 3765 pgdat = zone-\>zone_pgdat; 3766 **if** (**allow_direct_reclaim**(pgdat)) 3767 **goto out**; 3768 **break**;

3769 }

3770

3771 */\* If no zone was usable by the allocation flags then do not throttle*

*\*/*

3772 **if** (!pgdat)

3773 **goto out**;

 

*Listing 11-77:* mm/vmscan.c: [*throttle_direct_reclaim()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3721) *Initial Checks*

 

The purpose of [throttle_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3721) is to consider a scenario where

the direct reclaim ought to be throttled due to memory reserves getting low

due to reclaim being performed slowly (due to, for instance, the backing

store for swap or the page cache existing on a network mount).

As with much of the kernel, this is rather heuristic and considers a num-

ber of different edge cases. Note that if the function returns true, then direct

reclaim does not occur and the calling [try_to_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3801) function will re-

turn ultimately to [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) indicating that progress has been

made (despite none having actually been made), meaning we will not reach

for the OOM killer but instead will loop around and try again.

We only do so in one particular case after having throttled which we will

examine shortly, generally this function returns false (which is also the be-

haviour when code jumps to the out label). When this is returned, direct re-

claim proceeds as normal.

We start by excluding kernel threads from consideration, as throttling

reclaim for those might cause other things which depend on them to stall.

Next, if a fatal signal is pending, we ought not to throttle as doing so

would only delay the tear down of the process, and we need to make sure

that we free sufficient memory to do so before then immediately releasing

all process memory.

Next we loop through each zone in which we might be able to allocate

(See Section 2.4 in Chapter 2 for more on nodes, zones, zonelists and re-

lated).

We consider only ordinary zones (those of [ZONE_NORMAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n442) or below it nu-

merically, so in practice this excludes special zones like [ZONE_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n503) and

[ZONE_DEVICE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n505)), and simply check whether each node a zone resides in is per-

missible for direct reclaim, i.e. do not exhibit signs of depleted memory re-

serves.

We check whether a node is eligible for direct reclaim via

[allow_direct_reclaim(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3672)which we examine in Listing 11-79 shortly.

Finally, if we find no zone at [ZONE_NORMAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n442) or below, we simply choose not

to throttle at all as are unable to assess these zones.

We examine the throttling logic in Listing 11-78.

 

3775 */\* Account for the throttling \*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3776 **count_vm_event**(**PGSCAN_DIRECT_THROTTLE**); 3777

3778 */\**

3779 *\* If the caller cannot enter the filesystem, it's possible that it*

3780 *\* is due to the caller holding an FS lock or performing a journal*

3781 *\* transaction in the case of a filesystem like ext\[3\|4\]. In this case*

*,*

3782 *\* it is not safe to block on pfmemalloc_wait as kswapd could be* 3783 *\* blocked waiting on the same lock. Instead, throttle for up to a*

3784 *\* second before continuing.* 3785 *\*/*

3786 **if** (!(gfp_mask & **\_\_GFP_FS**)) 3787 **wait_event_interruptible_timeout**(pgdat-\>pfmemalloc_wait, 3788 **allow_direct_reclaim**(pgdat), **HZ**); 3789 **else**

3790 */\* Throttle until kswapd wakes the process \*/* 3791 **wait_event_killable**(zone-\>zone_pgdat-\>pfmemalloc_wait, 3792 **allow_direct_reclaim**(pgdat)); 3793

3794 **if** (**fatal_signal_pending**(**current**)) 3795 **return true**; 3796

3797 **out**:

3798 **return false**;

3799 }

 

*Listing 11-78:* mm/vmscan.c: [*throttle_direct_reclaim()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3721) *Throttling*

 

The portion of [throttle_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3721) which we examine in Listing 11-

78 performs the actual throttling, suspending the process until kswapd, i.e. the kernel thread which performs indirect reclaim frees enough memory to permit direct reclaim to proceed (noting that by this stage we will have triggered indirect reclaim before trying the direct form of it).

If [\_\_GFP_FS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n215) has not been set in the Get Free Pages (GFP) flag mask, this

indicates that access to the filesystem is prohibited (for more on GFP flags

see Section 2.6 in Chapter 2).

In this instance, we introduce a timeout to avoid a deadlock between di-

rect and indirect reclaim waiting on the same thing.

If this is not the case, we simply wait as long as it takes for indirect re-

claim to establish sufficient memory reserves that we can proceed and for it to notify us that this is the case.

Finally, after throttling, we check gain whether a fatal signal is pending,

if so in this case we actually do abort direct reclaim as we will now be in a position where indirect reclaim would have done all that is necessary for us to simply exit the reclaim mechanism and handle the fatal signal correctly.

Otherwise, we simply continue with direct reclaim.

We are waiting on [struct pglist_data](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905)-\>pfmemalloc_wait, a wait queue

specifically used to control throttling of direct reclaim.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This wait queue is woken up when indirect reclaim has made

progress in [balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) (see Listing 11-32 in Section 11.4.4), where

[allow_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3672) (see Listing 11-79) is tested again and if it returns true,

[struct pglist_data-\>pfmemalloc_wait](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) is woken.

It is also woken in [prepare_kswapd_sleep()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4027) (see Listing 11-30 in Section

11.4.3) right before the indirect reclaim process is put to sleep, in order to

prevent races that might leave direct reclaim stalled.

We examine [allow_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3672) in Listing 11-79.

 

3672 **static bool allow_direct_reclaim**(pg_data_t \*pgdat) 3673 {

3674 **struct** zone \*zone; 3675 **unsigned long** pfmemalloc_reserve = 0; 3676 **unsigned long** free_pages = 0; 3677 **int** i;

3678 **bool** wmark_ok;

3679

3680 **if** (pgdat-\>kswapd_failures \>= **MAX_RECLAIM_RETRIES**) 3681 **return true**; 3682

3683 **for** (i = 0; i \<= **ZONE_NORMAL**; i++) { 3684 zone = &pgdat-\>node_zones\[i\]; 3685 **if** (!**managed_zone**(zone)) 3686 **continue**; 3687

3688 **if** (!**zone_reclaimable_pages**(zone)) 3689 **continue**; 3690

3691 pfmemalloc_reserve += **min_wmark_pages**(zone); 3692 free_pages += **zone_page_state**(zone, **NR_FREE_PAGES**); 3693 }

3694

3695 */\* If there are no reserves (unexpected config) then do not throttle*

*\*/*

3696 **if** (!pfmemalloc_reserve) 3697 **return true**; 3698

3699 wmark_ok = free_pages \> pfmemalloc_reserve / 2; 3700

3701 */\* kswapd must be awake if processes are being throttled \*/* 3702 **if** (!wmark_ok && **waitqueue_active**(&pgdat-\>kswapd_wait)) { 3703 **if** (**READ_ONCE**(pgdat-\>kswapd_highest_zoneidx) \> **ZONE_NORMAL**) 3704 **WRITE_ONCE**(pgdat-\>kswapd_highest_zoneidx, **ZONE_NORMAL**)

;

3705

3706 **wake_up_interruptible**(&pgdat-\>kswapd_wait); 3707 }

3708

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3709 **return** wmark_ok;

3710 }

 

*Listing 11-79:* mm/vmscan.c: [*allow_direct_reclaim()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3672)

We start [allow_direct_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3672) by determining whether the node has un-

dergone more than the permitted number of indirect reclaim attempts (as

defined in [MAX_RECLAIM_RETRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n170), hard-coded to 16). If so, then indirect reclaim is of no use to us, and so we have only direct reclaim to work with and so it should be permitted.

Otherwise, we loop through all the zones of the specified node, skipping

zones if they are not managed (as determined by [managed_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1098)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1098) i.e. ones where the buddy allocator does not manage a single page there (see Chapter

2 for more on this).

We also skip zones if they simply do not contain any pages which we can

reclaim, as determined by [zone_reclaimable_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n571).

Finally we accumulate all of the reserves that are put in place to allow for

allocations using the [PF_MEMALLOC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1713) task flag, i.e. the minimum water mark for each zone, and additionally accumulate the number of free pages for each zone.

If we find ourselves in the unusual situation of there simply being no

reserves set at all, we exit and permit direct reclaim, as we can not violate memory reserves that don’t exist. This would be an odd configuration but one we nevertheless must account for.

Finally we determine if direct reclaim can proceed by checking to ensure

that accumulated free pages across zones exceed at least half of accumulated memory reserves across zones.

This indicates that reclaim is functioning sensibly enough that direct re-

claim can continue without throttling.

Finally, if we are about to indicate that throttling should take place, we

ensure that indirect swap is woken and we also reset it to ensure that it re-

claims from [ZONE_NORMAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n442) or below to ensure we obtain pages that contribute to memory reserves across allocatable zones.

 

**11.7 Folio Batches**

 

As each lruvec possesses a heavily-contended lru_lock, it is often more ef-ficient to perform lruvec operations in batches over which the lock is held rather than acquiring/releasing the lock one folio at a time. Note that we do not batch compound folios.

These batches are represented by [struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83) objects (byte-for-byte

identical to the legacy [struct pagevec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n22) objects):-

 

74 */\*\**

75 *\* struct folio_batch - A collection of folios.* 76 *\**

77 *\* The folio_batch is used to amortise the cost of retrieving and* 78 *\* operating on a set of folios. The order of folios in the batch may be*

79 *\* significant (eg delete_from_page_cache_batch()). Some users of the*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

80 *\* folio_batch store "exceptional" entries in it which can be removed*

81 *\* by calling folio_batch_remove_exceptionals().*

82 *\*/*

83 **struct** folio_batch {

84 **unsigned char** nr;

85 **bool** percpu_pvec_drained;

86 **struct** folio \*folios\[**PAGEVEC_SIZE**\];

87 };

 

*Listing 11-80:* include/linux/pagevec.h: [*struct folio_batch*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83)

 

There are a maximum of [PAGEVEC_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15) entries in each batch (this is hard-

coded to 15 which, given struct alignment rules, mean that we end up with

each batch equal to 16 system words, 128 bytes for 64-bit systems or 2 cache

lines per batch).

Examining each field:-

 

• nr – Indicates the number of folios present in the batch.

• percpu_pvec_drained – This is a flag indicating whether a drain has been

initiated – this is when folios in the batch are placed back, or drained, back to the appropriate lruvec lists.

• folios – An array of PAGEVEC_SIZE folios.

 

While folio batches can be used independently, core ones are maintained

in a series of per-CPU global objects, separated by the operation which is to

be performed on folios contained in each batch:-

 

***11.7.1 CPU Folio Batches***

Each of the remaining folio batches are declared in [struct cpu_fbatches](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n62) and

instantiated in [cpu_fbatches](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n72)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n72)

 

58 */\**

59 *\* The following folio batches are grouped together because they are protected*

60 *\* by disabling preemption (and interrupts remain enabled).*

61 *\*/*

62 **struct** cpu_fbatches {

63 **local_lock_t** lock;

64 **struct** folio_batch lru_add;

65 **struct** folio_batch lru_deactivate_file;

66 **struct** folio_batch lru_deactivate;

67 **struct** folio_batch lru_lazyfree;

68 **\#ifdef CONFIG_SMP**

69 **struct** folio_batch activate;

70 **\#endif**

71 };

72 **static DEFINE_PER_CPU**(**struct** cpu_fbatches, cpu_fbatches) = {

73 .lock = **INIT_LOCAL_LOCK**(lock),

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

74 };

 

*Listing 11-81:* mm/swap.c: [*struct cpu_fbatches*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n62) *and [cpu_fbatches](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n72)*

 

These maintain a local lock while being access which disables preemp-

tion while the lock is held.

 

***11.7.2 LRU Rotation***

A folio batch is maintained for LRU rotation. This operation places fo-lios at the tail of the inactive list in order that they get reclaimed next (we will discuss this operation in detail shortly below). This is used by

[folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n283) at the end of writeback (when a dirty file folio’s

data is written back to disk, see Chapter 10 for more on writeback). This re-quires IRQs to be disabled so is therefore kept separate from other batches

in a local [struct lru_rotate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n50) object and instantiated as [lru_rotate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n54):-

 

49 */\* Protecting only lru_rotate.fbatch which requires disabling interrupts \*/* 50 **struct** lru_rotate {

51 **local_lock_t** lock; 52 **struct** folio_batch fbatch; 53 };

54 **static DEFINE_PER_CPU**(**struct** lru_rotate, lru_rotate) = { 55 .lock = **INIT_LOCAL_LOCK**(lock), 56 };

 

*Listing 11-82:* mm/swap.c: [*struct lru_rotate*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n50) *and [lru_rotate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n54)*

 

These maintain a local lock while being accessed, which will disable pre-

emption and mask interrupts while the lock is held.

 

***11.7.3 mlock***

Finally, there is a separate [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) folio list for folios which have been mlocked, i.e. made unevictable:-

 

31 **struct** mlock_pvec {

32 **local_lock_t** lock; 33 **struct** pagevec vec; 34 };

35

36 **static DEFINE_PER_CPU**(**struct** mlock_pvec, mlock_pvec) = { 37 .lock = **INIT_LOCAL_LOCK**(lock), 38 };

 

*Listing 11-83:* mm/mlock.c: [*struct mlock_pvec*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n31) *and [mlock_pvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n36)*

 

This maintains a local lock while being access which disables preemption

while the lock is held.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Note that this folio batch is maintained separately from the rest – while

the folios on it are batched, they do not use the same call back mechanisms

described below.

 

***11.7.4 Folio Operations***

Previously we excluded the operations that use folio batches while looking

at lruvec operations. These are implemented as callback functions which

perform the actual operation required. Let’s examine them now:-

 

[lru_deactivate_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n576)

 

[folio_activate_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n344)

 

[lru_lazyfree_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n592) [lru_move_tail_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n266)

 

[lruvec_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98) [lruvec_del_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n132) [lruvec_add_folio_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n115)

 

[lru_add_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n192) [lru_deactivate_file_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n535)

 

*Figure 11-24:* *lruvec* *folio batch drain callbacks*

 

These are the functions which actually add and remove folios from

lruvecs, invoked as a [move_fn_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n190) callback when each folio batch is drained. This

occurs both when the folios reach their maximum size [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15)[PAGEVEC_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15) and

also when a drain is manually invoked.

The [folio_batch_move_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n232) function performs the actual drain of each

batch:-

 

232 **static void folio_batch_move_lru**(**struct** folio_batch \*fbatch, **move_fn_t move_fn**

)

233 {

234 **int** i;

235 **struct** lruvec \*lruvec = **NULL**; 236 **unsigned long** flags = 0;

237

238 **for** (i = 0; i \< **folio_batch_count**(fbatch); i++) { 239 **struct** folio \*folio = fbatch-\>folios\[i\];

240

241 */\* block memcg migration while the folio moves between lru \*/*

242 **if** (**move_fn** != **lru_add_fn** && !**folio_test_clear_lru**(folio)) 243 **continue**;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

244

245 lruvec = **folio_lruvec_relock_irqsave**(folio, lruvec, &flags); 246 **move_fn**(lruvec, folio); 247

248 **folio_set_lru**(folio); 249 }

250

251 **if** (lruvec)

252 **unlock_page_lruvec_irqrestore**(lruvec, flags); 253 **folios_put**(fbatch-\>folios, **folio_batch_count**(fbatch)); 254 **folio_batch_init**(fbatch); 255 }

 

*Listing 11-84:* mm/swap.c: [*folio_batch_move_lru()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n232)

The logic is as follows:-

 

1. For each entry in the folio batch (the count taken from the nr field, ac-

cessed via [folio_batch_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n106)):-(a) Clear the folio LRU flag, if it is set, and determine if it was previ-

ously set, via folio_test_clear_lru().

(b) If the specified callback is not [lru_add_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n192) and the folio is non-LRU,

i.e. not currently present on an LRU, then we skip it – the only sit-uation where we expect non-LRU folios to be operated on here is when they are added via lru_add_fn().

(c) Using [folio_lruvec_relock_irqsave()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n1633), determine the lruvec the folio

is present on (via [folio_lruvec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n763)), compare it against the last lruvec we locked – if they are the same, we perform no action, otherwise

we release the previous lock via [unlock_page_lruvec_irqrestore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n1604) and

acquire a lock on the new lruvec via [folio_lruvec_lock_irqsave()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memcontrol.c?h=v6.0#n1269)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memcontrol.c?h=v6.0#n1269) We always disable interrupts while holding the lruvec lock.

(d) Invoke the specified callback, move_fn. Note that each callback incre-

ments the folio’s reference count before performing its operation

via [folio_get()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1087) to ensure it is not freed underneath us.

(e) Set the folio LRU flag via folio_set_lru().

2. Unlock the lruvec via unlock_page_lruvec_irqrestore().

3. Decrement each folio’s reference count, which was incremented during

the folio operation, using [folios_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1162)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1162)

4. Finally, reset the folio via [folio_batch_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n100) – this resets the nr field to 0

and also sets percpu_pvec_drained to false. Note that a local lock will have been acquired before invoking this so it is safe to modify the batch.

 

[folio_batch_move_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n232) is only directly invoked by functions which perform

drain. Otherwise, [folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257) is used which adds to a batch and if either the batch is full, or an edge case condition occurs, it drains the batch via folio_batch_move_lru():-

 

257 **static void folio_batch_add_and_move**(**struct** folio_batch \*fbatch, 258 **struct** folio \*folio, move_fn_t move_fn)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

259 {

260 **if** (**folio_batch_add**(fbatch, folio) && !**folio_test_large**(folio) && 261 !**lru_cache_disabled**()) 262 **return**;

263 **folio_batch_move_lru**(fbatch, move_fn); 264 }

 

*Listing 11-85:* mm/swap.c: [*folio_batch_add_and_move()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257)

 

The edge cases in which we always perform drain are – pages being com-

pound (checked via [folio_test_large()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n801)) or the LRU cache being disabled al-

together (checked via [lru_cache_disabled()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n388)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n388) In the former case, it makes less

sense to batch operations when underlying base pages are already large.

Folios are added to each batch via [folio_batch_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n126) which returns the

number of still-available slots in the batch. This is, of course, invoked with

any local locks applicable to the batch held:-

 

116 */\*\**

117 *\* folio_batch_add() - Add a folio to a batch.* 118 *\* @fbatch: The folio batch.* 119 *\* @folio: The folio to add.* 120 *\**

121 *\* The folio is added to the end of the batch.* 122 *\* The batch must have previously been initialised using folio_batch_init().*

123 *\**

124 *\* Return: The number of slots still available.* 125 *\*/*

126 **static inline unsigned folio_batch_add**(**struct** folio_batch \*fbatch, 127 **struct** folio \*folio) 128 {

129 fbatch-\>folios\[fbatch-\>nr++\] = folio; 130 **return fbatch_space**(fbatch); 131 }

 

*Listing 11-86:* include/linux/pagevec.h: [*folio_batch_add()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n126)

 

This determines how much folio batch space is available via

[fbatch_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n111):-

 

111 **static inline unsigned int fbatch_space**(**struct** folio_batch \*fbatch) 112 {

113 **return PAGEVEC_SIZE**- fbatch-\>nr; 114 }

 

*Listing 11-87:* include/linux/pagevec.h: [*fbatch_space()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n111)

 

This simply subtracts the current folio count in the batch from the folio

batch size, [PAGEVEC_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15). This operation is safe as the batches are per-CPU

and preemption will be disabled due to the local lock.

Examining each function which invokes [folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257) which

are all the functions which manipulate folios in batches other than draining

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

them, i.e. the usual means by which all user space folios are manipulated in lruvecs:-

 

[deactivate_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n687) [mark_page_lazyfree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n710) [deactivate_file_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n664)

 

[lru_deactivate_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n576) [lru_lazyfree_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n592) [lru_deactivate_file_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n535)

 

[folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257)

 

[folio_activate_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n344) [lru_add_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n192) [lru_move_tail_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n266)

 

[folio_activate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n388) [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479) [folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n283)

 

*Figure 11-25: Non-drain folio batch operations*

 

All of these other than [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479) move folios between lists

[(mark_page_lazyfree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n710) simply moves a folio to the inactive list), whereas folio_add_lru() is uniquely the means by which folios are first added to an LRU. Let’s examine this first:-

 

***11.7.5 Adding Folios to a Batch***

We add folios to a batch using [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479) which we examine in Listing

11-88.

 

470 */\*\**

471 *\* folio_add_lru - Add a folio to an LRU list.* 472 *\* @folio: The folio to be added to the LRU.* 473 *\**

474 *\* Queue the folio for addition to the LRU. The decision on whether* 475 *\* to add the page to the \[in\]active \[file\|anon\] list is deferred until the*

476 *\* folio_batch is drained. This gives a chance for the caller of folio_add_lru*

*()*

477 *\* have the folio added to the active list using folio_mark_accessed().* 478 *\*/*

479 **void folio_add_lru**(**struct** folio \*folio) 480 {

481 **struct** folio_batch \*fbatch; 482

483 **VM_BUG_ON_FOLIO**(**folio_test_active**(folio) && 484 **folio_test_unevictable**(folio), folio); 485 **VM_BUG_ON_FOLIO**(**folio_test_lru**(folio), folio);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

486

487 **folio_get**(folio); 488 **local_lock**(&cpu_fbatches.lock); 489 fbatch = **this_cpu_ptr**(&cpu_fbatches.lru_add); 490 **folio_batch_add_and_move**(fbatch, folio, **lru_add_fn**); 491 **local_unlock**(&cpu_fbatches.lock); 492 }

 

*Listing 11-88:* mm/swap.c: [*folio_add_lru()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479)

 

The logic here is straightforward – after making some sanity assertions,

we increment the reference count for the folio so it isn’t freed beneath us,

acquire the local lock from the [cpu_fbatches](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n72) object (disabling preemption),

obtain the batch for this CPU from the cpu_fbatches.lru_add batch, then in-

voke [folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257) to perform the batch add before releasing the

local lock.

[folio_add_lru(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479)as the means by which folios are added to an LRU, sits

at the heart of all evictable user memory folio allocations (as, in order to be

evictable, the folios must be placed on an LRU).

It is informative then to examine what calls this function as this gives

us a broader picture of the interactions between LRUs and the rest of the

kernel. We examine anonymous folio and file-backed folio invocations of

folio_add_lru() overleaf.

For anonymous invocations we note which non-core subsystem callers in-

voke certain functions which have also been excluded for brevity. The intent

has been to highlight the core callers only.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Fork Functions

 

[dup_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580)

 

[copy_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1272)

 

[copy_p4d_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1216)

 

[copy_pud_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1179)

Page Fault Functions

 

[handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) [copy_pmd_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1142)

 

[wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090) [\_\_handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5157) [copy_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1018)

 

[do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360) [handle_pte_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860) [copy_present_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n942)

 

[do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031) [copy_present_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n905)

 

[lru_cache_add_inactive_or_unevictable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n503)

 

Used by swap, THP, FUSE,

[lru_cache_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n85)

shmem Functions shmem, migrate, userfaultfd

Reclaim Functions

[shmem_getpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n147) [shmem_getpage_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n1834) [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479) [shrink_active_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2509)

 

[shmem_read_mapping_page_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4264) [shmem_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n3956) [folio_putback_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1420) [move_pages_to_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323)

 

Used by THP, DAMON,

[putback_lru_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n139) [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)

madvise, cgroup, migrate

 

[reclaim_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2606)

 

*Figure 11-26: Anonymous Folio Invocations of* [*folio_add_lru()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479)

 

Key:

 

Denotes the key functions which ultimately trigger a folio being

•

added to an LRU.

 

• Denotes folio_add_lru() .

 

Denotes a function that has specific file system and in some cases

•

shmem or secretmem callers which we elide for brevity.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Page Fault Functions

 

[handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)

 

[\_\_handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5157) [do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360)

 

[handle_pte_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860) [wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090)

 

[do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4617)

 

[do_read_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4509) [do_cow_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4535) [do_shared_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4574)

 

[finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345)

 

[do_set_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4290)

 

[lru_cache_add_inactive_or_unevictable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n503)

File Map Functions

[lru_cache_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n85) [read_mapping_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n759)

 

[add_to_page_cache_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n91) [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479) [read_cache_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3548)

 

[readahead_expand()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n781) [filemap_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n926) [do_read_cache_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3472)

 

[ra_alloc_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n528) [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) [filemap_create_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2573)

 

[page_cache_ra_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n490) [do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) [pagecache_get_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n99) [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2660)

 

[ondemand_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556) [page_cache_sync_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n675) [filemap_lock_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n544) [filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626)

 

[page_cache_async_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n703) [page_cache_sync_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1210) [filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n526) [generic_file_read_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2756)

 

[filemap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2534) [do_async_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037) [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084)

 

[page_cache_async_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1233)

 

Readahead functions File Map Functions

 

*Figure 11-27: File-Backed Folio Invocations of* [*folio_add_lru()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479)

 

Examining [lru_add_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n192):-

 

192 **static void lru_add_fn**(**struct** lruvec \*lruvec, **struct** folio \*folio)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

193 {

194 **int** was_unevictable = **folio_test_clear_unevictable**(folio); 195 **long** nr_pages = **folio_nr_pages**(folio); 196

197 **VM_BUG_ON_FOLIO**(**folio_test_lru**(folio), folio); 198

199 */\**

200 *\* Is an smp_mb\_\_after_atomic() still required here, before* 201 *\* folio_evictable() tests the mlocked flag, to rule out the*

*possibility*

202 *\* of stranding an evictable folio on an unevictable LRU? I think*

203 *\* not, because \_\_munlock_page() only clears the mlocked flag* 204 *\* while the LRU lock is held.* 205 *\**

206 *\* (That is not true of \_\_page_cache_release(), and not necessarily*

207 *\* true of release_pages(): but those only clear the mlocked flag*

*after*

208 *\* folio_put_testzero() has excluded any other users of the folio.)*

209 *\*/*

210 **if** (**folio_evictable**(folio)) { 211 **if** (was_unevictable) 212 **\_\_count_vm_events**(**UNEVICTABLE_PGRESCUED**, nr_pages); 213 } **else** {

214 **folio_clear_active**(folio); 215 **folio_set_unevictable**(folio); 216 */\**

217 *\* folio-\>mlock_count = !!folio_test_mlocked(folio)?* 218 *\* But that leaves \_\_mlock_page() in doubt whether another*

219 *\* actor has already counted the mlock or not. Err on the*

220 *\* safe side, underestimate, let page reclaim fix it, rather*

221 *\* than leaving a page on the unevictable LRU indefinitely.*

222 *\*/*

223 folio-\>mlock_count = 0; 224 **if** (!was_unevictable) 225 **\_\_count_vm_events**(**UNEVICTABLE_PGCULLED**, nr_pages); 226 }

227

228 **lruvec_add_folio**(lruvec, folio); 229 **trace_mm_lru_insertion**(folio); 230 }

 

*Listing 11-89:* mm/swap.c: [*lru_add_fn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n192)

 

The logic is as follows:-

 

1. Test and clear the PG_unevictable folio flag via

folio_test_clear_unevictable(). This is done as the folio may have been unevictable before but has become evictable (its PG_mlocked flag has been cleared and/or its mapping has had its unevictable status cleared).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2. Asserts that the folio is not on an LRU already via folio_test_lru(), as if

this were the case we will have encountered a serious kernel bug.

3. Determines whether the folio is evictable via [folio_evictable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n130)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n130) which

ensures the folio does not have its mapping field marked unevictable nor has been marked mlocked.

4. If the folio is not evictable, we clear the active folio flag, set the

PG_unevictable folio flag reset the mlock_count and update statistics.

5. Finally, we perform the actual task of adding the folio to an LRU list via

[lruvec_add_folio() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98)

 

***11.7.6 Folio Activation***

Examining [folio_activate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n369):-

 

369 **static void folio_activate**(**struct** folio \*folio) 370 {

371 **if** (**folio_test_lru**(folio) && !**folio_test_active**(folio) && 372 !**folio_test_unevictable**(folio)) { 373 **struct** folio_batch \*fbatch;

374

375 **folio_get**(folio); 376 **local_lock**(&cpu_fbatches.lock); 377 fbatch = **this_cpu_ptr**(&cpu_fbatches.activate); 378 **folio_batch_add_and_move**(fbatch, folio, **folio_activate_fn**); 379 **local_unlock**(&cpu_fbatches.lock); 380 }

381 }

 

*Listing 11-90:* mm/swap.c: [*folio_activate()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n369)

 

This function is called when a folio needs to be proactively activated,

i.e. placed on the active LRU list in this folio’s lruvec. The logic is straight-

forward – if the folio is marked LRU, is not already activated and is not un-

evictable, then increment its reference number (to be decremented on drain

by [folio_batch_move_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n232)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n232) and invoke [folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257) to add the

folio to the activation batch under a local lock.

Examining [folio_activate_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n344)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n344) the function invoked when the batch is

drained:-

 

344 **static void folio_activate_fn**(**struct** lruvec \*lruvec, **struct** folio \*folio) 345 {

346 **if** (!**folio_test_active**(folio) && !**folio_test_unevictable**(folio)) { 347 **long** nr_pages = **folio_nr_pages**(folio);

348

349 **lruvec_del_folio**(lruvec, folio); 350 **folio_set_active**(folio); 351 **lruvec_add_folio**(lruvec, folio);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

352 **trace_mm_lru_activate**(folio); 353

354 **\_\_count_vm_events**(**PGACTIVATE**, nr_pages); 355 **\_\_count_memcg_events**(**lruvec_memcg**(lruvec), **PGACTIVATE**, 356 nr_pages); 357 }

358 }

 

*Listing 11-91:* mm/swap.c: [*folio_activate_fn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n344)

 

We start by checking again whether the folio is active and evictable, this

is run under a local lock thus with preemption disabled and so we should not encounter this changing underneath us.

We then simply remove the folio from its current LRU list via

[lruvec_del_folio() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n132)mark the folio’s active flag via folio_set_active(), before

adding it back to the active LRU list via [lruvec_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98).

We additionally mark the event in [**tracefs**](https://kernel.org/doc/html/v6.0/trace/ftrace.html) via trace_mm_lru_activate() and

update statistics.

[folio_activate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n344) is invoked only by [folio_mark_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441), which is a key

function used by the kernel to manually cycle folios through the inactive,

inactive/referenced, active/unreferenced states (see figure 11-7 and listing 11-

11).

 

***11.7.7 Folio Rotation***

We examine [folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n283) in Listing 11-92.

 

276 */\**

277 *\* Writeback is about to end against a folio which has been marked for* 278 *\* immediate reclaim. If it still appears to be reclaimable, move it* 279 *\* to the tail of the inactive list.* 280 *\**

281 *\* folio_rotate_reclaimable() must disable IRQs, to prevent nasty races.* 282 *\*/*

283 **void folio_rotate_reclaimable**(**struct** folio \*folio) 284 {

285 **if** (!**folio_test_locked**(folio) && !**folio_test_dirty**(folio) && 286 !**folio_test_unevictable**(folio) && **folio_test_lru**(folio)) { 287 **struct** folio_batch \*fbatch; 288 **unsigned long** flags; 289

290 **folio_get**(folio); 291 **local_lock_irqsave**(&lru_rotate.lock, flags); 292 fbatch = **this_cpu_ptr**(&lru_rotate.fbatch); 293 **folio_batch_add_and_move**(fbatch, folio, **lru_move_tail_fn**); 294 **local_unlock_irqrestore**(&lru_rotate.lock, flags); 295 }

296 }

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

*Listing 11-92:* mm/swap.c: [*folio_rotate_reclaimable()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n283)

 

This function is called in [folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599) when writeback is about

to end, i.e. when data in a dirty folio (one with data which has changed rel-

ative to the file backing it on-disk) has been written back, if and only if the

folio has also been marked with the reclaim flag, i.e. it is currently subject to

reclaim and thus about to be evicted:-

 

1599 **void folio_end_writeback**(**struct** folio \*folio) 1600 {

1601 */\**

1602 *\* folio_test_clear_reclaim() could be used here but it is an* 1603 *\* atomic operation and overkill in this particular case. Failing* 1604 *\* to shuffle a folio marked for immediate reclaim is too mild* 1605 *\* a gain to justify taking an atomic operation penalty at the* 1606 *\* end of every folio writeback.* 1607 *\*/*

1608 **if** (**folio_test_reclaim**(folio)) { 1609 **folio_clear_reclaim**(folio); 1610 **folio_rotate_reclaimable**(folio); 1611 }

. . .

1627 }

 

*Listing 11-93:* mm/filemap.c: *Excerpt of [folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599)*

 

The folio may not currently be present at the end of the inactive list (i.e.

liable for reclaim) as reclaim may have been blocked on writeback, so this

function ensures that, once writeback has been completed, the folio is made

immediately available for reclaim.

Note that [folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n283) asserts that the folio must be un-

locked, clean (i.e. no further writeback is to be performed), evictable and

currently present on an LRU. We invoke [folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257) with both

preemption disabled and interrupts disabled to avoid unfortunate race con-

ditions.

It, as usual, increments a reference count in the folio (to be decremented

on drain by [folio_batch_move_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n232)), and invoke [folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257) to

add the folio to the activation batch under a local lock.

Examining [lru_move_tail_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n266)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n266)

 

266 **static void lru_move_tail_fn**(**struct** lruvec \*lruvec, **struct** folio \*folio) 267 {

268 **if** (!**folio_test_unevictable**(folio)) { 269 **lruvec_del_folio**(lruvec, folio); 270 **folio_clear_active**(folio); 271 **lruvec_add_folio_tail**(lruvec, folio); 272 **\_\_count_vm_events**(**PGROTATED**, **folio_nr_pages**(folio)); 273 }

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

274 }

 

*Listing 11-94:* mm/swap.c: [*lru_move_tail_fn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n266)

 

We reassert the unevictable test to ensure that the folio hasn’t since been

made unevictable, remove the folio from its current LRU, deactivate it and

add it to the tail of the inactive LRU list as shown in listing 11-14.

 

***11.7.8 Folio Deactivation***

Examining [deactivate_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n687)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n687)

 

679 */\**

680 *\* deactivate_page - deactivate a page* 681 *\* @page: page to deactivate* 682 *\**

683 *\* deactivate_page() moves @page to the inactive list if @page was on the*

*active*

684 *\* list and was not an unevictable page. This is done to accelerate the*

*reclaim*

685 *\* of @page.*

686 *\*/*

687 **void deactivate_page**(**struct** page \*page) 688 {

689 **struct** folio \*folio = **page_folio**(page); 690

691 **if** (**folio_test_lru**(folio) && **folio_test_active**(folio) && 692 !**folio_test_unevictable**(folio)) { 693 **struct** folio_batch \*fbatch; 694

695 **folio_get**(folio); 696 **local_lock**(&cpu_fbatches.lock); 697 fbatch = **this_cpu_ptr**(&cpu_fbatches.lru_deactivate); 698 **folio_batch_add_and_move**(fbatch, folio, **lru_deactivate_fn**); 699 **local_unlock**(&cpu_fbatches.lock); 700 }

701 }

 

*Listing 11-95:* mm/swap.c: [*deactivate_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n687)

 

This asserts that the folio is on an LRU, active and evictable, then per-

forms the usual reference count increment, local lock acquisition (preemp-

tion disabled only in this case), before invoking [folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257) to

perform batch population (and draining with [lru_deactivate_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n576)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n576)

Examining lru_deactivate_fn():-

 

576 **static void lru_deactivate_fn**(**struct** lruvec \*lruvec, **struct** folio \*folio) 577 {

578 **if** (**folio_test_active**(folio) && !**folio_test_unevictable**(folio)) {

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

579 **long** nr_pages = **folio_nr_pages**(folio);

580

581 **lruvec_del_folio**(lruvec, folio); 582 **folio_clear_active**(folio); 583 **folio_clear_referenced**(folio); 584 **lruvec_add_folio**(lruvec, folio);

585

586 **\_\_count_vm_events**(**PGDEACTIVATE**, nr_pages); 587 **\_\_count_memcg_events**(**lruvec_memcg**(lruvec), **PGDEACTIVATE**, 588 nr_pages); 589 }

590 }

 

*Listing 11-96:* mm/swap.c: [*lru_deactivate_fn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n576)

 

This asserts that the folio is still active, and is not unevictable. The LRU

then has its active and referenced flags cleared before being added to the in-

active list.

This is used by the DAMON monitoring tool (see later chapter on this

mechanism) invoked in [damon_pa_deactivate_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/damon/paddr.c?h=v6.0#n252)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/damon/paddr.c?h=v6.0#n252) or in the [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html)

function [madvise_cold_or_pageout_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n323) invoked when the MADV_COLD or

MADV_PAGEOUT madvise options are used.

 

***11.7.9 File Folio Deactivation***

Examining [deactivate_file_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n664)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n664)

 

654 */\*\**

655 *\* deactivate_file_folio() - Deactivate a file folio.* 656 *\* @folio: Folio to deactivate.* 657 *\**

658 *\* This function hints to the VM that @folio is a good reclaim candidate,* 659 *\* for example if its invalidation fails due to the folio being dirty* 660 *\* or under writeback.*

661 *\**

662 *\* Context: Caller holds a reference on the folio.* 663 *\*/*

664 **void deactivate_file_folio**(**struct** folio \*folio) 665 {

666 **struct** folio_batch \*fbatch;

667

668 */\* Deactivating an unevictable folio will not accelerate reclaim \*/*

669 **if** (**folio_test_unevictable**(folio)) 670 **return**;

671

672 **folio_get**(folio); 673 **local_lock**(&cpu_fbatches.lock); 674 fbatch = **this_cpu_ptr**(&cpu_fbatches.lru_deactivate_file);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

675 **folio_batch_add_and_move**(fbatch, folio, lru_deactivate_file_fn); 676 **local_unlock**(&cpu_fbatches.lock); 677 }

 

*Listing 11-97:* mm/swap.c: [*deactivate_file_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n664)

 

Note that we do not make assertions about the state of the fo-

lio here other than ensuring it is is evictable, unlike other LRU op-erations, we merely disable preemption via a local lock and invoke

[folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257) as usual.

Examining [lru_deactivate_file_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n535)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n535)

 

514 */\**

515 *\* If the folio cannot be invalidated, it is moved to the* 516 *\* inactive list to speed up its reclaim. It is moved to the* 517 *\* head of the list, rather than the tail, to give the flusher* 518 *\* threads some time to write it out, as this is much more* 519 *\* effective than the single-page writeout from reclaim.* 520 *\**

521 *\* If the folio isn't mapped and dirty/writeback, the folio* 522 *\* could be reclaimed asap using the reclaim flag.* 523 *\**

524 *\* 1. active, mapped folio -\> none* 525 *\* 2. active, dirty/writeback folio -\> inactive, head, reclaim* 526 *\* 3. inactive, mapped folio -\> none* 527 *\* 4. inactive, dirty/writeback folio -\> inactive, head, reclaim* 528 *\* 5. inactive, clean -\> inactive, tail* 529 *\* 6. Others -\> none*

530 *\**

531 *\* In 4, it moves to the head of the inactive list so the folio is* 532 *\* written out by flusher threads as this is much more efficient* 533 *\* than the single-page writeout from reclaim.* 534 *\*/*

535 **static void lru_deactivate_file_fn**(**struct** lruvec \*lruvec, **struct** folio \*folio) 536 {

537 **bool** active = **folio_test_active**(folio); 538 **long** nr_pages = **folio_nr_pages**(folio); 539

540 **if** (**folio_test_unevictable**(folio)) 541 **return**;

542

543 */\* Some processes are using the folio \*/* 544 **if** (**folio_mapped**(folio)) 545 **return**;

546

547 **lruvec_del_folio**(lruvec, folio); 548 **folio_clear_active**(folio); 549 **folio_clear_referenced**(folio); 550

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

551 **if** (**folio_test_writeback**(folio) \|\| **folio_test_dirty**(folio)) { 552 */\**

553 *\* Setting the reclaim flag could race with* 554 *\* folio_end_writeback() and confuse readahead. But the* 555 *\* race window is \_really\_ small and it's not a critical* 556 *\* problem.* 557 *\*/*

558 **lruvec_add_folio**(lruvec, folio); 559 **folio_set_reclaim**(folio); 560 } **else** {

561 */\**

562 *\* The folio's writeback ended while it was in the batch.* 563 *\* We move that folio to the tail of the inactive list.* 564 *\*/*

565 **lruvec_add_folio_tail**(lruvec, folio); 566 **\_\_count_vm_events**(**PGROTATED**, nr_pages); 567 }

568

569 **if** (active) {

570 **\_\_count_vm_events**(**PGDEACTIVATE**, nr_pages); 571 **\_\_count_memcg_events**(**lruvec_memcg**(lruvec), **PGDEACTIVATE**, 572 nr_pages); 573 }

574 }

 

*Listing 11-98:* mm/swap.c: [*lru_deactivate_file_fn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n535)

 

This function is fairly meaty, taking into account the fact that file-backed

folios involve more logic to account for file system operations. We begin by

ensuring the folio is neither unevictable (via folio_test_unevictable()) nor

mapped (via the useful function [folio_mapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n758) which determines whether

a folio is mapped into userspace). we cannot touch unevictable folios nor

should we try to deactivate a folio which is currently mapped into userspace.

We then remove the folio from the folio batch LRU list, clear its active

and referenced flags and either mark it for reclaim via folio_set_reclaim() if

the folio is undergoing writeback (i.e. it was dirtied and is being written back

to disk) or is dirty (i.e. has changes to it not yet written back to disk), or if

neither of these are the case put immediately to the tail end of the inactive

LRU list indicating that the folio will be reclaimed next.

The only function which invokes [deactivate_file_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n664) is

[invalidate_mapping_pagevec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n502) which is called when an inode needs to have all

its mappings invalidated including those on folio batches.

 

***11.7.10 Folio Lazy Free***

Examining [mark_page_lazyfree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n710)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n710)

 

703 */\*\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

704 *\* mark_page_lazyfree - make an anon page lazyfree* 705 *\* @page: page to deactivate* 706 *\**

707 *\* mark_page_lazyfree() moves @page to the inactive file list.* 708 *\* This is done to accelerate the reclaim of @page.* 709 *\*/*

710 **void mark_page_lazyfree**(**struct** page \*page) 711 {

712 **struct** folio \*folio = **page_folio**(page); 713

714 **if** (**folio_test_lru**(folio) && **folio_test_anon**(folio) && 715 **folio_test_swapbacked**(folio) && !**folio_test_swapcache**(folio) && 716 !**folio_test_unevictable**(folio)) { 717 **struct** folio_batch \*fbatch; 718

719 **folio_get**(folio); 720 **local_lock**(&cpu_fbatches.lock); 721 fbatch = **this_cpu_ptr**(&cpu_fbatches.lru_lazyfree); 722 **folio_batch_add_and_move**(fbatch, folio, **lru_lazyfree_fn**); 723 **local_unlock**(&cpu_fbatches.lock); 724 }

725 }

 

*Listing 11-99:* mm/swap.c: [*mark_page_lazyfree()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n710)

 

This performs a great number of tests, ensuring that the folio in question

is on an LRU, anonymous, swap-backed (anonymous folios are always swap-backed except when being lazy freed), not on the swap cache (more on what the swap cache is in the swap chapter) and not unevictable. It then performs the usual folio reference count increment and disabling of preemption by applying a local lock.

This function is used, as the name implies, to lazily free fo-

lios. It is used by the [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) system call when memory is flagged

MADV_DONTNEED via [madvise_dontneed_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n818) and [madvise_free_single_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n734)

and [madvise_free_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n594) in turn (via [walk_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pagewalk.c?h=v6.0#n427) using the

[madvise_free_walk_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n730) callbacks). It is also used for huge page cases in

[madvise_free_huge_pmd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/huge_memory.c?h=v6.0#n1551).

Examining [lru_lazyfree_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n592):-

 

592 **static void lru_lazyfree_fn**(**struct** lruvec \*lruvec, **struct** folio \*folio) 593 {

594 **if** (**folio_test_anon**(folio) && **folio_test_swapbacked**(folio) && 595 !**folio_test_swapcache**(folio) && !**folio_test_unevictable**(folio)) { 596 **long** nr_pages = **folio_nr_pages**(folio); 597

598 **lruvec_del_folio**(lruvec, folio); 599 **folio_clear_active**(folio); 600 **folio_clear_referenced**(folio); 601 */\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

602 *\* Lazyfree folios are clean anonymous folios. They have* 603 *\* the swapbacked flag cleared, to distinguish them from*

*normal*

604 *\* anonymous folios* 605 *\*/*

606 **folio_clear_swapbacked**(folio); 607 **lruvec_add_folio**(lruvec, folio);

608

609 **\_\_count_vm_events**(**PGLAZYFREE**, nr_pages); 610 **\_\_count_memcg_events**(**lruvec_memcg**(lruvec), **PGLAZYFREE**, 611 nr_pages); 612 }

613 }

 

*Listing 11-100:* mm/swap.c: [*lru_lazyfree_fn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n592)

 

This reasserts, under lruvec lock, that the folio is anonymous, swap-

backed, not swap cache and evictable.

The folio is then removed from its current LRU list, deactivated, deref-

erenced, then uniquely they have their swapbacked status cleared before

being added back to an LRU list, which in this case will be the inactive file

LRU list as [folio_lru_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n81) will identify them as such when being added via

[lruvec_add_folio() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98)

The lazy free folios are checked explicitly in reclaim in [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)

(see Listing 11-63).

 

***11.7.11 mlock Folio Batch***

The [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) logic maintains a separate folio batch used for moving folios to

the unevictable LRU list (in fact no such LRU list exists, but the folios will be

marked unevictable at any rate and removed from all LRU lists).

Note that this logic uses the legacy naming scheme for folio batches –

page vectors or pagevecs. These are exactly equivalent to folio batches, so

substitute ‘folio batch’ for ‘pagevec’ whenever you see it.

The functions [\_\_mlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n61), [\_\_mlock_new_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n103) and [\_\_munlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n122)

all interact with LRU lists directly via [add_page_to_lru_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n108) and

[del_page_from_lru_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n142) (each of which ultimately invoke [lruvec_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98)

and [lruvec_del_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n132) respectively).

These perform the actual lruvec operations and are invoked when the

folio batch is drained, either when the batch is full or a drain is triggered

directly:-

 

61 **static struct** lruvec \***\_\_mlock_page**(**struct** page \*page, **struct** lruvec \*lruvec)

62 {

63 */\* There is nothing more we can do while it's off LRU \*/*

64 **if** (!**TestClearPageLRU**(page))

65 **return** lruvec;

66

67 lruvec = **folio_lruvec_relock_irq**(**page_folio**(page), lruvec);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

68

69 **if** (**unlikely**(**page_evictable**(page))) { 70 */\**

71 *\* This is a little surprising, but quite possible:* 72 *\* PageMlocked must have got cleared already by another CPU.*

73 *\* Could this page be on the Unevictable LRU? I'm not sure,*

74 *\* but move it now if so.* 75 *\*/*

76 **if** (**PageUnevictable**(page)) { 77 **del_page_from_lru_list**(page, lruvec); 78 **ClearPageUnevictable**(page); 79 **add_page_to_lru_list**(page, lruvec); 80 **\_\_count_vm_events**(**UNEVICTABLE_PGRESCUED**, 81 **thp_nr_pages**(page)); 82 }

83 **goto** out; 84 }

85

86 **if** (**PageUnevictable**(page)) { 87 **if** (**PageMlocked**(page)) 88 page-\>mlock_count++; 89 **goto** out; 90 }

91

92 **del_page_from_lru_list**(page, lruvec); 93 **ClearPageActive**(page); 94 **SetPageUnevictable**(page); 95 page-\>mlock_count = !!**PageMlocked**(page); 96 **add_page_to_lru_list**(page, lruvec); 97 **\_\_count_vm_events**(**UNEVICTABLE_PGCULLED**, **thp_nr_pages**(page)); 98 out:

99 **SetPageLRU**(page);

100 **return** lruvec;

101 }

 

*Listing 11-101:* mm/mlock.c: [*\_\_mlock_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n61)

 

The logic is:-

 

1. Assert that the folio is on an LRU and atomically mark it non-LRU,

abort if it was already non-LRU.

2. Obtain the lruvec for the folio if we do not already have it, and lock it if

not already locked, via [folio_lruvec_relock_irq()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n1619)

3. Check whether the page is evictable via [page_evictable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n142) which checks

both the PG_mlocked folio lock as well as the unevictable flag in the folio mapping field (see the section on mlock() for more details on this). At this stage, the folio should at least be flagged as mlocked, so we do not expect this to be the case. We then exit early.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

(a) We handle an edge case here – if the PG_mlocked flag has been cleared

by another core racing this operation, we ‘rescue’ the folio by clear-

ing the unevictable folio flag (remember that [lruvec_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n98) uses

[folio_lru_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n81) to determine which LRU list to place the folio on – with the unevictable folio flag set, it will not place on an active/inac-tive LRU list, with it cleared it will).

4. If the page was already marked unevictable and mlocked, we increment

the folio’s mlock_count field and exit early.

5. We hit the normal case – we extract the folio from its current LRU list,

clear its active folio flag and mark it unevictable, setting the mlock_count count depending on whether the folio flag is currently set, and invoke

[add_page_to_lru_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n108) which will simply update statistics.

6. Finally, we set the LRU folio flag to mark that the folio is now on the

virtual unevictable LRU list.

 

[\_\_mlock_new_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n103) is invoked for newly allocated folios and thus is signifi-

cantly simpler:-

 

103 **static struct** lruvec \***\_\_mlock_new_page**(**struct** page \*page, **struct** lruvec \*

lruvec)

104 {

105 **VM_BUG_ON_PAGE**(**PageLRU**(page), page);

106

107 lruvec = **folio_lruvec_relock_irq**(**page_folio**(page), lruvec);

108

109 */\* As above, this is a little surprising, but possible \*/* 110 **if** (**unlikely**(**page_evictable**(page))) 111 **goto out**;

112

113 **SetPageUnevictable**(page); 114 page-\>mlock_count = !!**PageMlocked**(page); 115 **\_\_count_vm_events**(**UNEVICTABLE_PGCULLED**, **thp_nr_pages**(page)); 116 **out**:

117 **add_page_to_lru_list**(page, lruvec); 118 **SetPageLRU**(page); 119 **return** lruvec;

120 }

 

*Listing 11-102:* mm/mlock.c: [*\_\_mlock_new_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n103)

 

Finally, [\_\_munlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n122) performs the same operations as [\_\_mlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n61)

in reverse.

These functions all interact with the [mlock_pvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n36) folio batch dedicated to

mlock() operations. The central drain function invokes the specific drain

function is [mlock_pagevec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n186)[:-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n186)

 

179 */\**

180 *\* mlock_pagevec() is derived from pagevec_lru_move_fn():*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

181 *\* perhaps that can make use of such page pointer flags in future,* 182 *\* but for now just keep it for mlock. We could use three separate* 183 *\* pagevecs instead, but one feels better (munlocking a full pagevec* 184 *\* does not need to drain mlocking pagevecs first).* 185 *\*/*

186 **static void mlock_pagevec**(**struct** pagevec \*pvec) 187 {

188 **struct** lruvec \*lruvec = **NULL**; 189 **unsigned long** mlock; 190 **struct** page \*page; 191 **int** i;

192

193 **for** (i = 0; i \< **pagevec_count**(pvec); i++) { 194 page = pvec-\>pages\[i\]; 195 mlock = (**unsigned long**)page & (**LRU_PAGE** \| **NEW_PAGE**); 196 page = (**struct** page \*)((**unsigned long**)page - mlock); 197 pvec-\>pages\[i\] = page; 198

199 **if** (mlock & **LRU_PAGE**) 200 lruvec = **\_\_mlock_page**(page, lruvec); 201 **else if** (mlock & **NEW_PAGE**) 202 lruvec = **\_\_mlock_new_page**(page, lruvec); 203 **else**

204 lruvec = **\_\_munlock_page**(page, lruvec); 205 }

206

207 **if** (lruvec)

208 **unlock_page_lruvec_irq**(lruvec); 209 **release_pages**(pvec-\>pages, pvec-\>nr); 210 **pagevec_reinit**(pvec); 211 }

 

*Listing 11-103:* mm/mlock.c: [*mlock_pagevec()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n186)

 

The lower two bits of each folio in the folio batch are used to indi-

cate whether the folio is intended to invoke [\_\_mlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n61) ([LRU_PAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n167) is set),

[\_\_mlock_new_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n103) [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n168)[NEW_PAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n168) is set), or [\_\_munlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n122) (no lower bit flags are set).

This function invokes the individual drain functions as necessary, re-

leases any lruvec lock that is held via [unlock_page_lruvec_irq()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memcontrol.h?h=v6.0#n1599), decrements

the folio reference count via [release_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n934), and clears the folio batch ready

for use via [pagevec_reinit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n44).

The functions which ultimately invoke mlock_pagevec() when the folio

batch is full are as follows:-

 

239 */\*\**

240 *\* mlock_folio - mlock a folio already on (or temporarily off) LRU* 241 *\* @folio: folio to be mlocked.* 242 *\*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

243 **void mlock_folio**(**struct** folio \*folio) 244 {

245 **struct** pagevec \*pvec;

246

247 **local_lock**(&mlock_pvec.lock); 248 pvec = **this_cpu_ptr**(&mlock_pvec.vec);

249

250 **if** (!**folio_test_set_mlocked**(folio)) { 251 **int** nr_pages = **folio_nr_pages**(folio);

252

253 **zone_stat_mod_folio**(folio, **NR_MLOCK**, nr_pages); 254 **\_\_count_vm_events**(**UNEVICTABLE_PGMLOCKED**, nr_pages); 255 }

256

257 **folio_get**(folio); 258 **if** (!**pagevec_add**(pvec, **mlock_lru**(&folio-\>page)) \|\| 259 **folio_test_large**(folio) \|\| **lru_cache_disabled**()) 260 **mlock_pagevec**(pvec); 261 **local_unlock**(&mlock_pvec.lock); 262 }

 

*Listing 11-104:* mm/mlock.c: [*mlock_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n243)

 

264 */\*\**

265 *\* mlock_new_page - mlock a newly allocated page not yet on LRU* 266 *\* @page: page to be mlocked, either a normal page or a THP head.* 267 *\*/*

268 **void mlock_new_page**(**struct** page \*page) 269 {

270 **struct** pagevec \*pvec; 271 **int** nr_pages = **thp_nr_pages**(page);

272

273 **local_lock**(&mlock_pvec.lock); 274 pvec = **this_cpu_ptr**(&mlock_pvec.vec); 275 **SetPageMlocked**(page); 276 **mod_zone_page_state**(**page_zone**(page), **NR_MLOCK**, nr_pages); 277 **\_\_count_vm_events**(**UNEVICTABLE_PGMLOCKED**, nr_pages);

278

279 **get_page**(page);

280 **if** (!**pagevec_add**(pvec, **mlock_new**(page)) \|\| 281 **PageHead**(page) \|\| **lru_cache_disabled**()) 282 **mlock_pagevec**(pvec); 283 **local_unlock**(&mlock_pvec.lock); 284 }

 

*Listing 11-105:* mm/mlock.c: [*mlock_new_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n268)

 

286 */\*\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

287 *\* munlock_page - munlock a page* 288 *\* @page: page to be munlocked, either a normal page or a THP head.* 289 *\*/*

290 **void munlock_page**(**struct** page \*page) 291 {

292 **struct** pagevec \*pvec; 293

294 **local_lock**(&mlock_pvec.lock); 295 pvec = **this_cpu_ptr**(&mlock_pvec.vec); 296 */\**

297 *\* TestClearPageMlocked(page) must be left to \_\_munlock_page(),* 298 *\* which will check whether the page is multiply mlocked.* 299 *\*/*

300

301 **get_page**(page);

302 **if** (!**pagevec_add**(pvec, page) \|\| 303 **PageHead**(page) \|\| **lru_cache_disabled**()) 304 **mlock_pagevec**(pvec); 305 **local_unlock**(&mlock_pvec.lock); 306 }

 

*Listing 11-106:* mm/mlock.c: [*munlock_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n290)

 

Each of these functions perform similar operations – they acquire the

folio batch local lock to disable preemption, set or clear the PG_mlocked folio

flag, update statistics, increment the folio reference count via [folio_get()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1087)

or the legacy equivalent [get_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1093), before trying to add the folio to the per-

CPU lruvec via [pagevec_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n62) (exactly equivalent to [folio_batch_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n126)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n126) forego-

ing the batch if the folio is compound (tested via [folio_test_large()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n801)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n801) or the LRU cache is disabled altogether (discussed below). Finally the local lock is released.

One thing that differs here is setting a flag to indicate which operation

each folio in the folio batch should have applied to it – [mlock_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n169) to assign

LRU_PAGE and [mlock_new()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n174) to assign LRU_NEW.

 

***11.7.12 Folio Batch Drain***

When folio batches are ‘drained’ they have their drain callback functions invoked and the operation they are batched up for is performed.

Drains can occur individually when a batch is full via

[folio_batch_add_and_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n257), invoking [folio_batch_move_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n232) on the ap-propriate callback, as well as when a per-CPU global drain is performed under certain circumstances.

The key function for performing per-CPU global drain is

[lru_add_drain_cpu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n620) (it assumes preemption has been disabled, typically via a local lock being applied):-

 

615 */\**

616 *\* Drain pages out of the cpu's folio_batch.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

617 *\* Either "cpu" is the current CPU, and preemption has already been* 618 *\* disabled; or "cpu" is being hot-unplugged, and is already dead.* 619 *\*/*

620 **void lru_add_drain_cpu**(**int** cpu) 621 {

622 **struct** cpu_fbatches \*fbatches = &**per_cpu**(cpu_fbatches, cpu); 623 **struct** folio_batch \*fbatch = &fbatches-\>lru_add;

624

625 **if** (**folio_batch_count**(fbatch)) 626 **folio_batch_move_lru**(fbatch, **lru_add_fn**);

627

628 fbatch = &**per_cpu**(lru_rotate.fbatch, cpu); 629 */\* Disabling interrupts below acts as a compiler barrier. \*/* 630 **if** (**data_race**(**folio_batch_count**(fbatch))) { 631 **unsigned long** flags;

632

633 */\* No harm done if a racing interrupt already did this \*/* 634 **local_lock_irqsave**(&lru_rotate.lock, flags); 635 **folio_batch_move_lru**(fbatch, **lru_move_tail_fn**); 636 **local_unlock_irqrestore**(&lru_rotate.lock, flags); 637 }

638

639 fbatch = &fbatches-\>lru_deactivate_file; 640 **if** (**folio_batch_count**(fbatch)) 641 **folio_batch_move_lru**(fbatch, **lru_deactivate_file_fn**);

642

643 fbatch = &fbatches-\>lru_deactivate; 644 **if** (**folio_batch_count**(fbatch)) 645 **folio_batch_move_lru**(fbatch, **lru_deactivate_fn**);

646

647 fbatch = &fbatches-\>lru_lazyfree; 648 **if** (**folio_batch_count**(fbatch)) 649 **folio_batch_move_lru**(fbatch, **lru_lazyfree_fn**);

650

651 **folio_activate_drain**(cpu); 652 }

 

*Listing 11-107:* mm/swap.c: [*lru_add_drain_cpu()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n620)

 

Note that [data_race()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/compiler.h?h=v6.0#n196) is used to denote that a data race is expected and

can be forgiven, explicitly disabling KCSAN checks for this (a topic out of

scope for this section).

This invokes folio_batch_move_lru() for each callback in turn:-

 

**Folio addition** via [lru_add_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n192)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n192)

**Folio reclaimable rotation** via [lru_move_tail_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n266).

**Folio file deactivation** via [lru_deactivate_file_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n535).

**Folio deactivation** via [lru_deactivate_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n576)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n576)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**Folio lazy free** via [lru_lazyfree_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n592).

**Folio activation** via [folio_activate_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n361) and [folio_activate_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n344).

 

[mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) folios are drained separately in [mlock_page_drain_local()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n213) and

[mlock_page_drain_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n224) which perform a similar role, only explicitly tak-

ing the [mlock_pvec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n31) local lock in the local case, and explicitly checking that the CPU is offline and thus no lock required in the remote one:-

 

213 **void mlock_page_drain_local**(**void**) 214 {

215 **struct** pagevec \*pvec; 216

217 **local_lock**(&mlock_pvec.lock); 218 pvec = **this_cpu_ptr**(&mlock_pvec.vec); 219 **if** (**pagevec_count**(pvec)) 220 **mlock_pagevec**(pvec); 221 **local_unlock**(&mlock_pvec.lock); 222 }

 

*Listing 11-108:* mm/mlock.c: [*mlock_page_drain_local()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n213)

 

224 **void mlock_page_drain_remote**(**int** cpu) 225 {

226 **struct** pagevec \*pvec; 227

228 **WARN_ON_ONCE**(**cpu_online**(cpu)); 229 pvec = &**per_cpu**(mlock_pvec.vec, cpu); 230 **if** (**pagevec_count**(pvec)) 231 **mlock_pagevec**(pvec); 232 }

 

*Listing 11-109:* mm/mlock.c: [*mlock_page_drain_remote()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n224)

 

Both of these invoke [mlock_pagevec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n186) as described in section 11.7.11. Both the core folio and the mlock batch drain functions are invoked

from a number of call sites:-

 

727 **void lru_add_drain**(**void**)

728 {

729 **local_lock**(&cpu_fbatches.lock); 730 **lru_add_drain_cpu**(smp_processor_id()); 731 **local_unlock**(&cpu_fbatches.lock); 732 **mlock_page_drain_local**(); 733 }

 

*Listing 11-110:* mm/swap.c: [*lru_add_drain()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727)

 

This is the key drain function. It applies a local lock before invoking

[lru_add_drain_cpu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n620) then invoking [mlock_page_drain_local()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n213) to take care of mlock folios.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

The function [lru_add_and_bh_lrus_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n741) does the same thing only it also

invokes invalidation of buffer head LRU lists via [invalidate_bh_lrus_cpu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1431).

This is out of scope for this section:-

 

735 */\**

736 *\* It's called from per-cpu workqueue context in SMP case so* 737 *\* lru_add_drain_cpu and invalidate_bh_lrus_cpu should run on* 738 *\* the same cpu. It shouldn't be a problem in !SMP case since* 739 *\* the core is only one and the locks will disable preemption.* 740 *\*/*

741 **static void lru_add_and_bh_lrus_drain**(**void**) 742 {

743 **local_lock**(&cpu_fbatches.lock); 744 **lru_add_drain_cpu**(smp_processor_id()); 745 **local_unlock**(&cpu_fbatches.lock); 746 **invalidate_bh_lrus_cpu**(); 747 **mlock_page_drain_local**(); 748 }

 

*Listing 11-111:* mm/swap.c: [*lru_add_and_bh_lrus_drain()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n741)

 

This function is invoked by [lru_add_drain_per_cpu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n763)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n763) which is invoked in

turn by [\_\_lru_add_drain_all()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n790) (see below for more details on this).

Finally, there is [lru_add_drain_cpu_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n750) which is invoked by compaction

in [compact_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2292) (see the compaction chapter for more details on this):-

 

750 **void lru_add_drain_cpu_zone**(**struct** zone \*zone) 751 {

752 **local_lock**(&cpu_fbatches.lock); 753 **lru_add_drain_cpu**(smp_processor_id()); 754 **drain_local_pages**(zone); 755 **local_unlock**(&cpu_fbatches.lock); 756 **mlock_page_drain_local**(); 757 }

 