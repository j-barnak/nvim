# index

***index***

Symbols

[!#acc routine directive 394](#filepos1584742)

A

[Accelerated Processing Unit (APU) 312, 368, 589](#filepos2293911)

[accelerator devices 24, 311](#filepos1290103)

[acc enter data create directive 473](#filepos1896667)

[acc exit data directive 473](#filepos1896800)

[acc keyword 373](#filepos1506323)

[adaptive mesh refinement (AMR) 133](#filepos560391)

[address generation units (AGUs) 118](#filepos508649)

[ADIOS (Adaptable Input/Output System) 568](#filepos2214358)

[Adios package 568](#filepos2213736)

[Advanced Vector Extensions (AVX) 117, 177](#filepos708800)

[affinity 491-527](#filepos2056864)

> [changing process affinities during run time 522-524](#filepos2048654)

> [controlling from command line 516-520](#filepos2028914)

> > [hwloc-bind 516-518](#filepos2022996)

> > [likwid-pin 518-520](#filepos2028903)

> [for MPI plus OpenMP 511-516](#filepos2016727)

> [importance of 492-493](#filepos1948729)

> [process affinity with MPI 503-511](#filepos2000496)

> > [binding processes to hardware components 511](#filepos1998651)

> > [default process placement with OpenMPI 504](#filepos1977573)

> > [mapping processes to processors or other locations 510](#filepos1994667)

> > [ordering of MPI ranks 510-511](#filepos1998463)

> > [specifying process placement in OpenMPI 504-509](#filepos1992221)

> [resources for 525-526](#filepos2052940)

> [setting affinities in executable 521-522](#filepos2039231)

> [thread affinity with OpenMP 495-503](#filepos1976518)

> [understanding architecture 493-494](#filepos1952057)

[AGUs (address generation units) 118](#filepos508649)

[AI (artificial intelligence) 3](#filepos169089)

[algorithmic complexity 125](#filepos528767)

[algorithms 4, 124-169](#filepos695361)

> [defined 130](#filepos550091)

> [future of research 167](#filepos685910)

> [hash functions, defined 131-132](#filepos558562)

> [overview 125-126](#filepos532388)

> [parallel global sum 161-166](#filepos685724)

> [performance models vs. algorithmic complexity 126-130](#filepos549903)

> [prefix sum pattern 157-161](#filepos656919)

> [redesigning for parallel 53](#filepos321046)

> [resources for 168](#filepos688601)

> [spatial hashing 132-157](#filepos647749)

> [task-based support algorithm 250-251](#filepos1016347)

[aliasing 183](#filepos729400)

[Allinea/ARM Map 248](#filepos1006624)

[ALUs (arithmetic logic units) 351](#filepos1435308)

[Amdahl’s Law 11-12](#filepos193812)

[AMR (adaptive mesh refinement) 133](#filepos560391)

[AoS (Array of Structures) 197](#filepos792066)

> [performance assessment 96](#filepos441436)

> [SoA vs. 94-100](#filepos455031)

[AoSoA (Array of Structures of Arrays) 100-101](#filepos459353)

[application/software model 25-29](#filepos235502)

> [process-based parallelization 26-27](#filepos229589)

> [stream processing through specialized processors 28-29](#filepos235491)

> [thread-based parallelization 27-28](#filepos232545)

> [vectorization 28](#filepos232760)

[APU (Accelerated Processing Unit) 312, 368, 589](#filepos2293911)

[ARB (Architecture Review Board) 371](#filepos1502549)

[Archer 600-601](#filepos2335224)

[arithmetic intensity 60](#filepos340718)

[arithmetic logic units (ALUs) 351](#filepos1435308)

[Array of Structures.](#filepos792066) See AoS

[artificial intelligence (AI) 3](#filepos169089)

[assembler instructions 195-196](#filepos789809)

[associativity, addressing with parallel global sum 161-166](#filepos685724)

[asymptotic notation 125](#filepos528869)

[asynchronous calls 261, 264](#filepos1061343)

[asynchronous operations, in OpenACC 394](#filepos1586115)

[atomic directive 412](#filepos1656666)

[Atomic Weapons Establishment (AWE) 593](#filepos2311662)

[auto-vectorization 179-183](#filepos730723)

[AVX (Advanced Vector Extensions) 117, 177](#filepos708800)

[AWE (Atomic Weapons Establishment) 593](#filepos2311662)

B

bandwidth

> [calculating machine balance between flops and 71](#filepos369039)

> [empirical measurement of 67-69](#filepos365629)

> GPUs

> > [achieved bandwidth 480](#filepos1909844)

> > [calculating theoretical peak 319-320](#filepos1332322)

> [PCI bus 326-329](#filepos1359564)

> > [maximum transfer rate 327-328](#filepos1358138)

> > [overhead rates 328](#filepos1358853)

> > [PCIe lanes 327](#filepos1350308)

> > [reference data for 329](#filepos1359405)

> [theoretical memory bandwidth 66-67](#filepos358836)

[Basic Linear Algebra System (BLAS) 179](#filepos714776)

[batch schedulers 528-546](#filepos2124075)

> [automatic restarts 539-542](#filepos2112088)

> [chaos of unmanaged systems 529-530](#filepos2062588)

> [common HPC pet peeves 531-532](#filepos2069889)

> [layout of batch system for busy clusters 530-531](#filepos2064017)

> [resources for 545](#filepos2119642)

> [specifying dependencies in batch scripts 543-544](#filepos2116611)

> [submitting batch scripts 532-536](#filepos2088937)

[BeeGFS 576](#filepos2247087)

[benchmarking 52, 62-71, 591](#filepos2301005)

> [benchmark application for PCI bus 329-332](#filepos1373936)

> [calculating machine balance between flops and bandwidth 71](#filepos369039)

> [calculating theoretical maximum flops 65](#filepos352577)

> [empirical measurement of bandwidth and flops 67-69](#filepos365629)

> [measuring GPU stream benchmark 321](#filepos1333468)

> [memory hierarchy and theoretical memory bandwidth 66-67](#filepos358836)

> [tools for gathering system characteristics 62-64](#filepos352002)

[binding 301, 491](#filepos1941694)

[bins 131](#filepos555737)

[BLAS (Basic Linear Algebra System) 179](#filepos714776)

[blocking 261](#filepos1050137)

[bottlenecks 585](#filepos2281992)

[branch miss 107](#filepos475550)

[branch penalty (Bp) 107](#filepos474827)

[branch prediction cost (Bc) 106](#filepos474450)

[bubble sort 130](#filepos553049)

[buckets 131](#filepos555723)

[build command 481](#filepos1911755)

[burst buffer 548](#filepos2129491)

C

[cache conflict 102](#filepos461882)

[cache line 61, 67, 102](#filepos460946)

[cache misses 101-105](#filepos470102)

[cache thrashing 102](#filepos463358)

[cache update storms 105](#filepos469958)

[cache used (Ucache) 61](#filepos342948)

[call graphs 72-78](#filepos386647)

[capacity misses 102](#filepos461938)

[Cartesian topology, support for in MPI 292-296](#filepos1242964)

[catastrophic cancellation 161](#filepos658307)

[C ceil function 358, 426](#filepos1713937)

[cell-centric compressed sparse storage 112-114](#filepos494569)

[centralized version control 38, 583](#filepos2273554)

[central processing unit (CPU) 7, 310](#filepos1284898)

[CEPH filesystem 576](#filepos2248877)

[checkpointing 532, 539, 547](#filepos2125615)

[CLAMR application 593](#filepos2310562)

[clang-archer command 600](#filepos2331993)

[clinfo command 439](#filepos1766144)

[clock_gettime function 585](#filepos2280454)

[clone command 582](#filepos2271019)

[close keyword 495](#filepos1952787)

cloud computing

> [cost reduction with GPUs 342](#filepos1404744)

> [GPU profiling 485-486](#filepos1930275)

[CloverLeaf mini-app 593](#filepos2311895)

CMake module

> [automatic testing with 41-45](#filepos291931)

> [setting compiler flags 200-201](#filepos811284)

[coalesced memory loads 359](#filepos1465980)

[coalescing 359](#filepos1465600)

[coarse-grained parallelism 228](#filepos916826)

[code modularity 53](#filepos320132)

[code portability, improving 50](#filepos311277)

[codesign process 592](#filepos2308360)

[CodeXL suite 478](#filepos1904838)

[coherency, defined 105](#filepos469755)

[cold cache 105, 226](#filepos907363)

[Collaborative Testing System (CTS) 48](#filepos302873)

[collective_buffering operation 555](#filepos2157685)

[collective file operation 552](#filepos2142699)

[collisions 132](#filepos557476)

[column major 90](#filepos420245)

[CoMD (molecular dynamics) mini-app 593](#filepos2312012)

[comm groups 302](#filepos1267696)

[commiting workflow step 55](#filepos326621)

[communicators 256](#filepos1030578)

compact hashing

> [face neighbor finding 152-153](#filepos630719)

> [neighbor finding 149-151](#filepos627282)

> [remaps 153-157](#filepos647727)

[comparative speedup 31-32](#filepos244834)

[compiler flags 198-201](#filepos811308)

[compiler hints 183-190](#filepos755188)

[compiler wrappers 256-257](#filepos1033931)

[Compressed Sparse Row (CSR) 105](#filepos471043)

[compressed sparse storage representations 112-116](#filepos503321)

> [cell-centric compressed sparse storage 112-114](#filepos494569)

> [material-centric compressed sparse storage 114-116](#filepos503311)

[computational kernel 36](#filepos255655)

[computational mesh 17](#filepos207120)

[compute device 314](#filepos1303949)

[compute directive 389](#filepos1565055)

[Compute Unified Device Architecture.](#filepos1288499) See CUDA

[compute units (CUs) 315, 479](#filepos1906738)

[concurrency 4](#filepos171251)

[Concurrent Versions System (CVS) 583](#filepos2273758)

[conflict misses 480](#filepos1909376)

cost reduction

> [in cloud computing with GPUs 342](#filepos1404744)

> [parallel computing and 10-11](#filepos190892)

[CPU (central processing unit) 7, 310](#filepos1284898)

[CPU RAM 310](#filepos1285160)

[Cray compiler 374](#filepos1510087)

[cross-node parallel method 22-23](#filepos218501)

[CSR (Compressed Sparse Row) 105](#filepos471043)

[CTest, automatic testing with 41-45](#filepos291931)

[CTS (Collaborative Testing System) 48](#filepos302873)

[CUB (CUDA UnBound) 435](#filepos1749050)

[CUDA (Compute Unified Device Architecture) 311](#filepos1288499)

> [GPU languages and 420-438](#filepos1763103)

> > [HIPifying code 435-438](#filepos1763092)

> > [reduction kernel 429-435](#filepos1749086)

> > [writing and building applications 421-429](#filepos1725786)

> [interoperability with OpenACC 395-396](#filepos1591046)

[cudaFree 427](#filepos1715582)

[CUDA-GDB 604](#filepos2343456)

[cudaHostMalloc function 429](#filepos1723158)

[CUDPP (CUDA Data Parallel Primitives Library) 161](#filepos656407)

[CUs (compute units) 315, 479](#filepos1906738)

[CVS (Concurrent Versions System) 583](#filepos2273758)

D

[DAOS (distributed application object storage) 576](#filepos2247496)

[Darshan libraries 605](#filepos2348890)

[data hazards 599](#filepos2330084)

[data-oriented design 88-101](#filepos459371)

> AoS

> > [performance assessment 96](#filepos441436)

> > [SoA vs. 94-100](#filepos455031)

> [AoSoA 100-101](#filepos459353)

> [multidimensional arrays 90-94](#filepos435281)

> [resources for 122-123](#filepos522828)

> SoA

> > [AoS vs. 94-100](#filepos455031)

> > [performance assessment 96-100](#filepos455021)

[data parallel approach 16-22](#filepos215571)

> [defining computational kernel or operation 17-18](#filepos210243)

> [discretizing problem 17](#filepos206768)

> [off-loading calculation to GPUs 21-22](#filepos215555)

> [processes 19-21](#filepos213344)

> [threads 19](#filepos211456)

> [vectorization 19](#filepos210457)

[Data Parallel C++ (DPCPP) compiler 449](#filepos1814898)

[data pragma 385](#filepos1550107)

[dataset 560](#filepos2178355)

[DataWarp 575](#filepos2244751)

[ddt command 602](#filepos2339278)

[.deb (Debian Package Manager) 607](#filepos2354642)

> [DDT 602](#filepos2338714)

> > [CUDA-GDB 604](#filepos2343456)

> > [ROCgdb 604](#filepos2344131)

> [Linux debuggers 603](#filepos2340433)

> [TotalView debugger 602](#filepos2337183)

[declare target directive 411](#filepos1654949)

[dedicated GPUs 313](#filepos1293507)

[dependency analysis, call graphs for 72-78](#filepos386647)

[dereferencing 99](#filepos452810)

[descriptive directives and clauses 414](#filepos1665938)

[differential discretized data 134](#filepos564517)

[dimensions, in OpenCL 357](#filepos1459763)

[DIMMs (dual in-line memory modules) 310](#filepos1285160)

[directive-based GPU programming 371-416](#filepos1674644)

> [OpenACC 374-396](#filepos1592322)

> > [advanced techniques 393-396](#filepos1592303)

> > [compiling code 375-377](#filepos1518248)

> > [optimizing kernels 387-393](#filepos1579573)

> > [parallel compute regions 377-383](#filepos1541067)

> > [summary of performance results for stream triad 393](#filepos1579778)

> > [using directives 383-387](#filepos1558768)

> [OpenMP 396-414](#filepos1666899)

> > [advanced techniques 411-414](#filepos1666889)

> > [compiling code 397-398](#filepos1599298)

> > [creating data regions 402-406](#filepos1629752)

> > [generating parallel work 398-402](#filepos1613179)

> > [optimizing 406-410](#filepos1651964)

> [process to apply directives and pragmas for GPU implementation 373-374](#filepos1508236)

> [resources for 414-415](#filepos1671471)

> > [OpenACC 415](#filepos1668349)

> > [OpenMP 415](#filepos1669937)

[directives 208](#filepos838467)

[direct-mapped cache 102](#filepos461091)

[discrete GPUs 313](#filepos1293627)

[discretizing problems 17](#filepos206768)

[distributed application object storage (DAOS) 576](#filepos2247488)

[distributed arrays 13](#filepos197977)

[distributed memory architecture 22-23](#filepos218501)

[distributed version control 38, 582-583](#filepos2273330)

[Docker containers 480-483](#filepos1919684)

[domain-boundary halos 278](#filepos1127596)

[dope vector 91](#filepos422269)

[double hashing 151](#filepos624457)

[DPCPP (Data Parallel C++ ) compiler 449](#filepos1814898)

[DRAM (Dynamic Random Access Memory) 22, 310](#filepos1285160)

[Draw_Line function 89](#filepos414864)

[Dr. Memory 595-597](#filepos2321665)

[dual in-line memory modules (DIMMs) 310](#filepos1285160)

[dynamic memory requirements 343](#filepos1407435)

[Dynamic Random Access Memory (DRAM) 22, 310](#filepos1285160)

[dynamic range 162](#filepos662947)

E

[ECM (Execution Cache Memory) 116](#filepos505508)

[edge compute 9](#filepos186984)

[empirical bandwidth (BE) 61, 67](#filepos359058)

[empirical machine balance (MBE) 71](#filepos369201)

energy efficiency

> [with GPUs 337-342](#filepos1404543)

> [with parallel computing 9-10](#filepos189794)

[enter/exit data directive 385](#filepos1549079)

[enter data directive 385](#filepos1549176)

[EpetraBenchmarkTest mini-app 593](#filepos2312142)

[EUs (execution units) 316](#filepos1306783)

[eviction 102](#filepos461729)

[ExaMiniMD 592](#filepos2306551)

[Exascale Project proxy apps 592-593](#filepos2308874)

[exclusive command 535](#filepos2082280)

[Execution Cache Memory (ECM) 116](#filepos505508)

[execution dependency 480](#filepos1908961)

[exit data directive 385](#filepos1548957)

[EZCL library 438](#filepos1765305)

F

[feeds 59](#filepos337751)

[FFT (Fast Fourier transform) 179](#filepos715175)

[field-programmable gate arrays (FPGAs) 314, 349, 438](#filepos1764628)

[file operations 547-578](#filepos2255856)

> [components of high-performance filesystem 548-549](#filepos2130927)

> [hardware interface 568-576](#filepos2249467)

> > [BeeGFS 576](#filepos2247087)

> > [CEPH filesystem 576](#filepos2248877)

> > [DataWarp 575](#filepos2244751)

> > [distributed application object storage 576](#filepos2247496)

> > [general hints 572-573](#filepos2236384)

> > [General Parallel File System 575](#filepos2243958)

> > [Lustre filesystem 574-575](#filepos2243389)

> > [network filesystem 576](#filepos2249261)

> > [OrangeFS 576](#filepos2246132)

> > [overview 568-570](#filepos2221380)

> > [Panasas 575-576](#filepos2245604)

> > [WekaIO 576](#filepos2248235)

> [HDF5 559-566](#filepos2212120)

> [MPI-IO 551-559](#filepos2171923)

> [parallel-to-serial interface 549-550](#filepos2135085)

> [profiling 604-607](#filepos2353312)

> [resources for 577-578](#filepos2253122)

[filled fraction (Ff) 109](#filepos481477)

[find_package command 437](#filepos1756003)

> [CUDA 422](#filepos1691997)

> [HDF5 567](#filepos2212697)

> [HIP 436-437](#filepos1756029)

> [Kokkos 453](#filepos1834568)

> [MPI 44, 258](#filepos1039233)

> [OpenACC 376](#filepos1516007)

> [OpenCL 440](#filepos1770483)

> [OpenMP 456, 600](#filepos2330690)

> [Raja 456](#filepos1847530)

> [Vector 200](#filepos806445)

[fine-grained parallelization 228](#filepos916793)

[first touch 209, 495](#filepos1952459)

[flops (floating-point operations) 59, 87](#filepos408711)

> [calculating machine balance between bandwidth and 71](#filepos369039)

> [calculating peak theoretical flops 316-318](#filepos1322121)

> [calculating theoretical maximum 65](#filepos352577)

> [empirical measurement of 67-69](#filepos365629)

[flow dependency 188](#filepos749059)

[flush operation 210](#filepos844389)

[Flynn’s Taxonomy 29](#filepos236401)

[FMA (fused multiply-add) 65, 118](#filepos508183)

[for pragma 238](#filepos962701)

[FPGAs (field-programmable gate arrays) 314, 349, 438](#filepos1764628)

[free function 427](#filepos1715655)

[full matrix data representations 109-111](#filepos489018)

> [full matrix cell-centric storage 109-110](#filepos486057)

> [full matrix material-centric storage 110-111](#filepos489002)

[function calls, MPI 256](#filepos1029902)

> [barrier 267](#filepos1073885)

> [broadcast 268-269](#filepos1085139)

> [gather 273-276](#filepos1120706)

> [reduction 269-273](#filepos1105055)

> [scatter 274-276](#filepos1120706)

[function-level OpenMP 229-231](#filepos934187)

[fused multiply-add (FMA) 65, 118](#filepos508183)

G

[gangs 387](#filepos1560311)

[gang scheduling 492](#filepos1944654)

[gather/scatter memory load operation 119](#filepos512771)

gather operations

> [putting order in debug printouts 273-274](#filepos1110038)

> [sending data out to processes for work 274-276](#filepos1120706)

[GCC (GNU Compiler Collection) 40, 42, 374](#filepos1509724)

[GCP (Google Cloud Platform) 485](#filepos1929238)

[gen (generation) 327](#filepos1352303)

[general heterogeneous parallel architecture model 24-25](#filepos225545)

[General Parallel File System (GPFS) 575](#filepos2243950)

[general-purpose graphics processing unit (GPGPU) 24, 311](#filepos1288257)

[get_global_id function 355](#filepos1451741)

> [in 2D mesh 277-285](#filepos1173710)

> [performance tests of variants 297](#filepos1249427)

[global information 357](#filepos1460047)

[global sum, using OpenMP threading 227](#filepos912716)

[global sum issue 162](#filepos661178)

[GNU Compiler Collection (GCC) 40, 42, 374](#filepos1509724)

[Google Cloud Platform (GCP) 485](#filepos1929238)

[GPFS (General Parallel File System) 575](#filepos2243958)

[GPGPU (general-purpose graphics processing unit) 24, 311](#filepos1288257)

[GPU (graphics processing unit) languages 417-459](#filepos1858582)

> [CUDA and 420-438](#filepos1763103)

> > [HIPifying code 435-438](#filepos1763092)

> > [reduction kernel 429-435](#filepos1749086)

> > [writing and building applications 421-429](#filepos1725786)

> [features of 419-420](#filepos1685924)

> [higher-level languages 452-457](#filepos1852260)

> > [Kokkos 452-455](#filepos1845491)

> > [RAJA 455-457](#filepos1852243)

> [OpenCL 438-449](#filepos1813988)

> > [reductions in 445-449](#filepos1813978)

> > [writing and building applications 439-445](#filepos1800815)

> [resources for 457-458](#filepos1856139)

> [SYCL 449-452](#filepos1830246)

[GPU (graphics processing unit) profiling and tools 460-487](#filepos1936080)

> [cloud options 485-486](#filepos1930275)

> [Docker containers 480-483](#filepos1919684)

> [metrics 479-480](#filepos1910498)

> > [achieved bandwidth 480](#filepos1909844)

> > [issue efficiency 480](#filepos1907877)

> > [occupancy 479](#filepos1906541)

> [overview 460-461](#filepos1861687)

> [profiling workflow 467-478](#filepos1905638)

> > [CodeXL suite 478](#filepos1904838)

> > [data movement directives 473-474](#filepos1898364)

> > [guided analysis 474-475](#filepos1902225)

> > [NVIDIA Nsight suite 476-477](#filepos1904263)

> > [OpenACC compute directives 471-473](#filepos1895219)

> > [profile CPU code 470](#filepos1884732)

> > [running application 467-469](#filepos1884529)

> [resources for 486-487](#filepos1933950)

> [selecting good workflow 462-463](#filepos1868981)

> [shallow water simulation example 463-467](#filepos1878039)

> [virtual machines 483-485](#filepos1928481)

[GPU (graphics processing unit) programming model 346-370](#filepos1501044)

> [asynchronous computing through queues 365-366](#filepos1485493)

> [code structure for 355-360](#filepos1469062)

> > [addressing memory resources 359-360](#filepos1469044)

> > [index sets 358](#filepos1461845)

> > [parallel kernel 356-357](#filepos1459065)

> > [thread indices 357-358](#filepos1461348)

> [developing plan to parallelize applications for 366-368](#filepos1491917)

> > [3D atmospheric simulation 367](#filepos1486540)

> > [unstructured mesh application 368](#filepos1490330)

> [directive-based GPU programming 371-416](#filepos1674644)

> > [OpenACC 374-396](#filepos1592322)

> > [OpenMP 396-414](#filepos1666899)

> > [process to apply directives and pragmas for GPU implementation 373-374](#filepos1508236)

> > [resources for 414-415](#filepos1671471)

> [GPU programming abstractions 354-355](#filepos1450854)

> [optimizing GPU resource usage 361-362](#filepos1478237)

> > [occupancy 362](#filepos1476478)

> > [registers used by kernel 361](#filepos1474704)

> [programming abstractions 348-355](#filepos1450866)

> > [inability to coordinate among tasks 349](#filepos1424541)

> > [massive parallelism 348](#filepos1422040)

> [reduction pattern 364-365](#filepos1482849)

> [resources for 369-370](#filepos1497959)

> [terminology 349](#filepos1424970)

> > [data decomposition into independent units of work 350-352](#filepos1443651)

> > [subgroups, warps, and wavefronts 353-354](#filepos1448627)

> > [work groups 353](#filepos1444321)

> > [work items 354](#filepos1448825)

[GPU RAM 310](#filepos1285525)

[GPUs (graphics processing units) 309-345](#filepos1415811)

> [as thread engine 313-318](#filepos1322121)

> > [calculating peak theoretical flops 316-318](#filepos1322121)

> > [compute unit 316](#filepos1306163)

> > [multiple data operations by each element 316](#filepos1307687)

> > [processing elements (PEs) 316](#filepos1306585)

> [characteristics of GPU memory spaces 318-326](#filepos1346465)

> > [calculating theoretical peak memory bandwidth 319-320](#filepos1332322)

> > [measuring GPU stream benchmark 321](#filepos1333468)

> > [roofline performance model for GPUs 322](#filepos1337506)

> > [using mixbench performance tool to choose best GPU for workload 324-326](#filepos1346451)

> [CPU-GPU system as accelerated computational platform 311-313](#filepos1294913)

> > [dedicated GPUs 313](#filepos1293507)

> > [integrated GPUs 312](#filepos1291733)

> > [CUDA-GDB 604](#filepos2343456)

> > [ROCgdb 604](#filepos2344131)

> [memory tools 599](#filepos2328907)

> [multi-GPU platforms and MPI 332-334](#filepos1379192)

> > [higher performance alternative to PCI bus 334](#filepos1378598)

> > [optimizing data movement between graphics processing units (GPUs) across network 333](#filepos1375910)

> [PCI bus 326-332](#filepos1373948)

> > [benchmark application for 329-332](#filepos1373936)

> > [theoretical bandwidth of 326-329](#filepos1359564)

> [potential benefits of GPU-accelerated platforms 334-342](#filepos1405801)

> > [cloud computing cost reduction 342](#filepos1404744)

> > [reducing energy use 337-342](#filepos1404543)

> > [reducing time-to-solution 335-336](#filepos1385811)

> [resources for 343-344](#filepos1409681)

> [when to use 343](#filepos1405973)

[graded mesh 136](#filepos571370)

[group information, in OpenCL 357](#filepos1460632)

[Gustafson-Barsis’s Law 12-15](#filepos199726)

H

[H5Dclose command 560](#filepos2179914)

[H5Dcreate2 command 560](#filepos2179282)

[H5Dopen2 command 560](#filepos2179608)

[H5Dread command 561](#filepos2180740)

[h5dump command 559](#filepos2173076)

[H5Dwrite command 561](#filepos2180327)

[H5Fclose command 560](#filepos2176162)

[H5Fcreate command 560](#filepos2175548)

[H5Fopen command 560](#filepos2175869)

[h5ls command 559](#filepos2173058)

[H5Pclose command 561](#filepos2182229)

[H5Pcreate command 561](#filepos2181936)

[H5Pset_all_coll_metadata_ops command 561](#filepos2183607)

[H5Pset_coll_metadata_write command 561](#filepos2182899)

[H5Pset_dxpl_mpio command 561](#filepos2182545)

[H5Pset_fapl_mpio command 561](#filepos2183240)

[H5Sclose command 560](#filepos2178067)

[H5Screate_simple command 560](#filepos2177424)

[H5Sselect_hyperslab command 560](#filepos2177775)

[halo cells 278](#filepos1127483)

[halo updates 278](#filepos1128545)

[hangs 261](#filepos1050515)

[hardware model 22-25](#filepos225561)

> [accelerator devices 24](#filepos222311)

> [distributed memory architecture 22-23](#filepos218501)

> [general heterogeneous parallel architecture model 24-25](#filepos225545)

> [shared memory architecture 23](#filepos218706)

> [vector units 23-24](#filepos221843)

hash functions

> [defined 131-132](#filepos558562)

> [prefix sum pattern 157-161](#filepos656919)

> > [for large arrays 160-161](#filepos656909)

> > [step-efficient parallel scan operation 158](#filepos650629)

> > [work-efficient parallel scan operation 159-160](#filepos654461)

> [spatial hashing 132-157](#filepos647749)

> > [compact hashing 149-157](#filepos647739)

> > [perfect hashing 135-148](#filepos618831)

[hash load factor 150](#filepos622028)

[hash sort 130](#filepos553320)

[hash sparsity 150](#filepos622392)

[HBM2 (High-Bandwidth Memory) 319](#filepos1324577)

[HC (Heterogeneous Compute) compiler 349](#filepos1430146)

[HDF (Hierarchical Data Format) 559](#filepos2172631)

[HDF5 (Hierarchical Data Format v5) 559-566](#filepos2212120)

[heaps 95](#filepos440635)

[Heterogeneous Compute (HC) compiler 349](#filepos1430146)

[Heterogeneous Interface for Portability (HIP) 349, 435](#filepos1749410)

[Hierarchical Data Format (HDF) 559](#filepos2172631)

[Hierarchical Data Format v5 (HDF5) 559-566](#filepos2212112)

[High-Bandwidth Memory (HBM2) 319](#filepos1324577)

[high-level OpenMP 218, 237](#filepos957355)

> [example of 234-237](#filepos957341)

> [implementing 232-234](#filepos942942)

> [improving parallel scalability with 231](#filepos934396)

[High Performance Computing (HPC) 10, 89](#filepos416690)

[High Performance Conjugate Gradient (HPCG) 52](#filepos318150)

[HIP (Heterogeneous Interface for Portability) 349, 435](#filepos1749410)

[HIP_ADD_EXECUTABLE command 437](#filepos1756136)

[host 355](#filepos1451229)

[host_data directive 395](#filepos1588698)

[host_data use_device(var) directive 396](#filepos1590199)

[hot-spot analysis, call graphs for 72-78](#filepos386647)

[HPC (High Performance Computing) 10, 89](#filepos416690)

[HPCG (High Performance Conjugate Gradient) 52](#filepos318150)

[hwloc-bind 516-518](#filepos2022996)

[hybrid threading 237-240](#filepos966796)

[hydrostatic pressure 465](#filepos1874430)

[hyperthreading 493](#filepos1947854)

I

[ICD (Installable Client Driver) 439](#filepos1767457)

[implementation workflow step 54](#filepos323647)

[include directive 598](#filepos2325837)

[independent file operation 552](#filepos2140412)

[index sets 358](#filepos1461845)

[inlining 89](#filepos414967)

[Installable Client Driver (ICD) 439](#filepos1767457)

[integrated GPUs 312](#filepos1291733)

[Intel Inspector 248-249, 600](#filepos2330585)

[inter-process communication (IPC) 27](#filepos230703)

[IPC (inter-process communication) 27](#filepos230703)

[irregular memory access 343](#filepos1406884)

J

[Kahan summation implementation 244](#filepos989150)

[kernels directive 381-382](#filepos1537654)

[kernels pragma 378-380](#filepos1531597)

[Kokkos 452-455](#filepos1845491)

L

[Laghos 592](#filepos2306689)

[lambda expressions 356](#filepos1454995)

[lanes (vector lanes) 23](#filepos221212)

[LAPACK (linear algebra package) 179](#filepos714892)

[latency 59](#filepos336480)

[Lawrence Livermore National Laboratory proxies 593](#filepos2309075)

[LD_LIBRARY_PATH 610](#filepos2366757)

[likwid (“Like I Knew What I’m Doing”) 518, 586](#filepos2285427)

[likwid-mpirun command 519](#filepos2027926)

[likwid-perfctr markers 78](#filepos387441)

[likwid-pin 518](#filepos2024743)

> [controlling affinity 518-520](#filepos2028903)

> [pinning MPI ranks 519-520](#filepos2028893)

> [pinning OpenMP threads 518-519](#filepos2027218)

[likwid-powermeter command 83](#filepos396655)

[linear algebra package (LAPACK) 179](#filepos714892)

[Linux debuggers 603](#filepos2340433)

[List under Mantevo suite 593-594](#filepos2313076)

[Lmod 612](#filepos2372364)

[load factor 132](#filepos557194)

[login nodes 530](#filepos2063634)

[loop cost (Lc) 107](#filepos475737)

[loop directive 382, 389, 413](#filepos1662890)

[loop-level OpenMP 217-228](#filepos917737)

> [performance of 226-227](#filepos912496)

> [potential issues with 227-228](#filepos917725)

> [reduction example of global sum using OpenMP threading 227](#filepos912716)

> [stencil example 224-226](#filepos907648)

> [stream triad example 222-224](#filepos901599)

> [vector addition example 220-222](#filepos896938)

[loop penalty (Lp) 107](#filepos475803)

[loop pragma 381](#filepos1532465)

[Los Alamos National Laboratory proxy applications 593](#filepos2310269)

[lscpu command 64, 494, 504, 506, 510](#filepos1997167)

[lspci command 64, 331](#filepos1370949)

[lstopo command 510, 516](#filepos2019038)

[Lustre filesystem 574-575](#filepos2243389)

M

[machine balance 60](#filepos340931)

[machine-specific registers (MSR) 76](#filepos384431)

[make test command 47](#filepos299750)

[-mapby ppr:N:socket:PE=N command 513](#filepos2007952)

[map directive 402](#filepos1612757)

[master keyword 496](#filepos1954794)

[material-centric compressed sparse storage 114-116](#filepos503311)

[Math Kernel Library (MKL) 179](#filepos715397)

[MDS (Metadata Servers) 575](#filepos2242054)

[MDT (Metadata Targets) 575](#filepos2242088)

[membytes 113](#filepos493739)

[memops (memory loads and stores) 106, 113](#filepos493720)

[memory bandwidth 67](#filepos360421)

[memory channels (Mc) 66](#filepos357546)

[memory dependency 480](#filepos1908810)

[memory error detection and repair 594-599](#filepos2329674)

> [commercial memory tools 597](#filepos2321952)

> [compiler-based memory tools 597](#filepos2322522)

> [Dr. Memory 595-597](#filepos2321665)

> [fence-post checkers 597-599](#filepos2328629)

> [GPU memory tools 599](#filepos2328907)

> [Valgrind Memcheck 594](#filepos2315058)

[memory handling 420](#filepos1685092)

[memory latency 67](#filepos359615)

[memory leaks 594](#filepos2314160)

[memory paging 429](#filepos1724251)

[memory pressure 361](#filepos1473266)

[memory throttle 480](#filepos1909250)

[memory transfer rate (MTR) 66](#filepos357088)

meshes

> [compact hashing for spatial mesh operations 149-157](#filepos647739)

> > [face neighbor finding 152-153](#filepos630719)

> > [neighbor finding 149-151](#filepos627282)

> > [remap calculations 153-157](#filepos647727)

> [defining computational kernel to conduct on each element of mesh 17-18](#filepos210243)

> [ghost cell exchanges in 2D mesh 277-285](#filepos1173710)

> [perfect hashing for spatial mesh operations 135-148](#filepos618831)

> > [neighbor finding 135-141](#filepos590493)

> > [remap calculations 142](#filepos590689)

> > [sorting mesh data 146-148](#filepos618819)

> > [table lookups 143](#filepos596008)

> > [table lookups using spatial perfect hash 145-146](#filepos610209)

> [unstructured mesh applications 368](#filepos1490330)

[message passing 26-27](#filepos229589)

[Message Passing Interface.](#filepos229351) See MPI

[Metadata Servers (MDS) 575](#filepos2242054)

[Metadata Targets (MDT) 575](#filepos2242088)

[MIMD (multiple instruction, multiple data) 29](#filepos236253)

[MiniAero app 593](#filepos2312275)

[miniAMR (adaptive mesh refinement) 592](#filepos2306937)

[mini-apps 52, 591-594](#filepos2313093)

> [Exascale Project proxy apps 592-593](#filepos2308874)

> [Lawrence Livermore National Laboratory proxies 593](#filepos2309075)

> [Los Alamos National Laboratory proxy applications 593](#filepos2310269)

> [Sandia National Laboratories Mantevo suite 593-594](#filepos2313076)

[miniFE app 593](#filepos2312431)

[miniGhost app 593](#filepos2312566)

[minimal perfect hash 131](#filepos556474)

[miniQMC (Quantum Monte Carlo) 592](#filepos2307058)

[miniSMAC2D app 593](#filepos2312709)

[miniXyce app 593](#filepos2312830)

[MISD (multiple instruction, single data) 29](#filepos237593)

[mixbench performance tool 324-326](#filepos1346451)

[MKL (Math Kernel Library) 179](#filepos715397)

[modularity 37](#filepos257761)

[module avail command 609](#filepos2363753)

[module list command 609](#filepos2364087)

[module purge command 609](#filepos2364436)

[modules 609-612](#filepos2372551)

> [Lmod 612](#filepos2372364)

> [TCL modules 612](#filepos2371615)

[module show command 610](#filepos2365574)

[module show \<module_name\> command 609](#filepos2364782)

[module swap \<module_name\> \<module_name\> command 610](#filepos2365491)

[module unload \<module_name\> command 610](#filepos2365136)

[molecular dynamics (CoMD) mini-app 593](#filepos2312012)

[motherboard 66](#filepos356623)

[MPI (Message Passing Interface) 27, 42, 254-304, 491](#filepos1941288)

> [advanced functionality 286-297](#filepos1251343)

> > [Cartesian topology support in 292-296](#filepos1242964)

> > [custom data types 287-291](#filepos1203714)

> > [performance tests of ghost cell exchange variants 297](#filepos1249427)

> [basics for minimal program 255-259](#filepos1043978)

> > [compiler wrappers 256-257](#filepos1033931)

> > [function calls 256](#filepos1029902)

> > [minimum working example 257-259](#filepos1043965)

> > [parallel startup commands 257](#filepos1034415)

> [collective communication 266-276](#filepos1120717)

> > [barrier 267](#filepos1073885)

> > [broadcast 268-269](#filepos1085139)

> > [gather 273-276](#filepos1120706)

> > [reduction 269-273](#filepos1105055)

> > [scatter 274-276](#filepos1120706)

> [data parallel examples 276-286](#filepos1180123)

> > [ghost cell exchanges in 2D mesh 277-285](#filepos1173710)

> > [ghost cell exchanges in 3D stencil calculation 285-286](#filepos1180113)

> > [stream triad to measure bandwidth on node 276](#filepos1121491)

> [file operations 551-559](#filepos2171923)

> [hybrid MPI plus OpenMP 299-302](#filepos1266726)

> > [benefits of 299-300](#filepos1257893)

> > [MPI plus OpenMP 300-302](#filepos1266715)

> [multi-GPU platforms and 332-334](#filepos1379192)

> > [higher performance alternative to PCI bus 334](#filepos1378598)

> > [optimizing data movement between GPUs across network 333](#filepos1375910)

> [plus OpenMP 218-219, 300-302, 511-516](#filepos2016727)

> [process affinity with 503-511](#filepos2000496)

> > [binding processes to hardware components 511](#filepos1998651)

> > [default process placement with OpenMPI 504](#filepos1977573)

> > [mapping processes to processors or other locations 510](#filepos1994667)

> > [ordering of MPI ranks 510-511](#filepos1998463)

> > [specifying process placement in OpenMPI 504-509](#filepos1992221)

> [resources for 303](#filepos1269572)

> [send and receive commands for process-to-process communication 259-266](#filepos1071296)

[MPI_Allreduce 270, 273](#filepos1104892)

[MPI_Barrier 267](#filepos1073954)

[MPI_Bcast 268-269](#filepos1084470)

[MPI_BYTE 265](#filepos1069313)

[MPI_Cart_coords 292](#filepos1214918)

[MPI_Cart_create 292](#filepos1214462)

[MPI_Cart_shift 292](#filepos1214991)

[mpicc command 256-257](#filepos1033270)

[MPICH (ROMIO) command 575](#filepos2244369)

[MPI_COMM_WORLD (MCW) 266, 269, 508](#filepos1991689)

[mpicxx command 257](#filepos1033294)

[MPI_Dims_create function 292](#filepos1214050)

[MPI_DOUBLE 285](#filepos1173543)

[mpiexec command 257](#filepos1034694)

[MPI_File 551](#filepos2136133)

[MPI_File_close command 551](#filepos2139111)

[MPI_File_delete command 551](#filepos2139800)

[MPI_File_open command 551](#filepos2138165)

[MPI_File_read_all command 552](#filepos2144242)

[MPI_File_read_at_all command 552](#filepos2144950)

[MPI_File_read_at command 552](#filepos2142136)

[MPI_File_read command 552](#filepos2141454)

[MPI_File_seek command 551](#filepos2138497)

[MPI_File_set_info command 551](#filepos2139466)

[MPI_File_set_size command 551](#filepos2138812)

[MPI_File_set_view command 552](#filepos2143884)

[MPI_File_set_view function 552](#filepos2142973)

[MPI_File_write_all command 552](#filepos2144602)

[MPI_File_write_at_all command 552](#filepos2145300)

[MPI_File_write_at command 552](#filepos2142485)

[MPI_File_write command 552](#filepos2141789)

[MPI_Finalize 271, 288](#filepos1185087)

[mpifort command 257](#filepos1033323)

[MPI_Gather 274](#filepos1109502)

[MPI_Info_set command 572](#filepos2230539)

[MPI_Init 300](#filepos1258210)

[MPI_Init_thread 300-301](#filepos1262889)

[MPI-IO (MPI file operations) 551-559](#filepos2171923)

[MPI-IO library 551, 568](#filepos2217023)

[MPI_Irecv 264, 285](#filepos1173456)

[MPI_Isend 264-265, 280, 285](#filepos1173486)

[MPI_Neighbor_alltoallw 295](#filepos1237365)

[MPI_PACK 265](#filepos1069590)

[MPI_Pack 278, 280, 285](#filepos1173615)

[MPI_PACKED 265](#filepos1069284)

[MPI_Probe 266](#filepos1071059)

[MPI_Recv function 261](#filepos1049356)

[MPI_Reduce 269](#filepos1086707)

[MPI_Request_free 265](#filepos1066997)

[mpirun command 257, 504, 508, 510, 515, 517, 573, 603](#filepos2340933)

[MPI_Scatter 274](#filepos1110635)

[MPI_Scatterv 274](#filepos1110668)

[MPI_Send function 261](#filepos1049327)

[MPI_Sendrecv function 263-264](#filepos1060643)

[MPI_Test 265](#filepos1067086)

[MPI_THREAD_FUNNELED 300](#filepos1259152)

[MPI_THREAD_MULTIPLE 300](#filepos1259493)

[MPI_THREAD_SERIALIZED 300](#filepos1259327)

[MPI_THREAD_SINGLE 300](#filepos1258984)

[MPI_Type_Commit 287](#filepos1184071)

[MPI_Type_contiguous function 287](#filepos1182018)

[MPI_Type_create_hindexed function 287](#filepos1182688)

[MPI_Type_create_struct function 287](#filepos1182929)

[MPI_Type_create_subarray 289](#filepos1193286)

[MPI_Type_create_subarray function 287](#filepos1182339)

[MPI_Type_Free 287](#filepos1184256)

[MPI_Type_indexed function 287](#filepos1182688)

[MPI_Type_vector function 287](#filepos1182173)

[MPI_Wait 265](#filepos1067055)

[MPI_Wtime function 267](#filepos1074291)

[MSR (machine-specific registers) 76](#filepos384431)

[MTR (memory transfer rate) 66](#filepos357088)

[multidimensional arrays 90-94](#filepos435281)

[multiple instruction, multiple data (MIMD) 29](#filepos236253)

[multiple instruction, single data (MISD) 29](#filepos237593)

N

[NDRange (N-dimensional range) 350-352](#filepos1443651)

neighbor finding

> [face neighbor finding for unstructured meshes 152-153](#filepos630719)

> [using spatial perfect hash 135-141](#filepos590493)

> [with write optimizations and compact hashing 149-151](#filepos627282)

[NEKbone 592](#filepos2307210)

[netloc command 62](#filepos348815)

[network interface card (NIC) 299](#filepos1256169)

[network messages 119-122](#filepos520065)

[new operator 96](#filepos440775)

[NFS (network filesystem) 576](#filepos2249261)

[NIC (network interface card) 299](#filepos1256169)

[nodes 19](#filepos212181)

[non-collective calls 551](#filepos2137194)

[non-contiguous bandwidth (Bnc) 61](#filepos342845)

[NUMA (Non-Uniform Memory Access) 24, 210, 218, 492](#filepos1945534)

[numactl command 222, 509](#filepos1992904)

[numastat command 222](#filepos895039)

[NuT 593](#filepos2310691)

[nvcc command 361](#filepos1474835)

[NVIDIA Nsight suite 461, 476-477](#filepos1904263)

[NVIDIA nvidia-smi 461](#filepos1862564)

[NVIDIA nvprof 461](#filepos1863030)

[NVIDIA NVVP 461](#filepos1863437)

[NVIDIA PGPROF 461](#filepos1864005)

[NVIDIA SMI (System Management Interface) 461](#filepos1862564)

[nvprof command 472](#filepos1893059)

[NVVP (NVIDIA Visual Profiler) 461](#filepos1863030)

[nvvp command 472](#filepos1893346)

[N-way set associative cache 102](#filepos461357)

O

[objdump command 195](#filepos786764)

[object-based filesystem 568](#filepos2216055)

[Object Storage Servers (OSSs) 575](#filepos2241575)

[Object Storage Targets (OSTs) 575](#filepos2241616)

[occupancy 362](#filepos1476994)

[ompi_info command 569](#filepos2218704)

[omp keyword 373](#filepos1506354)

[omp parallel do pragmas 232](#filepos938242)

[omp parallel pragma 216](#filepos868961)

[omp_set_num_threads() function 212](#filepos856743)

[omp target data directive 403](#filepos1617957)

[omp target enter data directive 403](#filepos1618008)

[omp target exit data directive 403](#filepos1618008)

[one-sided communication 303](#filepos1269406)

[on-node parallel method 23](#filepos218706)

OpenACC

> [compute directives 471-473](#filepos1895219)

> [directive-based GPU programming 374-396](#filepos1592322)

> > [advanced techniques 393-396](#filepos1592303)

> > [asynchronous operations 394](#filepos1586001)

> > [atomics 394](#filepos1584993)

> > [compiling code 375-377](#filepos1518248)

> > [interoperability with CUDA libraries or kernels 395-396](#filepos1591046)

> > [managing multiple devices 396](#filepos1591231)

> > [optimizing kernels 387-393](#filepos1579573)

> > [parallel compute regions 377-383](#filepos1541067)

> > [performance results 393](#filepos1579778)

> > [routine directive 394](#filepos1583846)

> > [unified memory 395](#filepos1587747)

> > [using directives 383-387](#filepos1558768)

> [resources for 415](#filepos1668349)

[open addressing 151](#filepos622808)

[OpenCL (Open Computing Language) 311, 438-449](#filepos1813988)

> [reductions in 445-449](#filepos1813978)

> [writing and building OpenCL applications 439-445](#filepos1800815)

[OpenMP (Open Multi-Processing) 207-253](#filepos1022907)

> [advanced examples 240-247](#filepos1004380)

> > [Kahan summation implementation OpenMP threading 244](#filepos989150)

> > [stencil example with separate pass for x and y directions 240-243](#filepos988253)

> > [threaded implementation of prefix scan algorithm 246-247](#filepos1004366)

> [concepts 208-211](#filepos845976)

> [directive-based GPU programming 396-414](#filepos1666899)

> > [accessing special memory spaces 412-413](#filepos1661909)

> > [advanced techniques 411-414](#filepos1666889)

> > [asynchronous operations 412](#filepos1657046)

> > [atomics 412](#filepos1656390)

> > [compiling code 397-398](#filepos1599298)

> > [controlling kernel parameters 411](#filepos1653427)

> > [creating data regions 402-406](#filepos1629752)

> > [declaring device function 411](#filepos1654757)

> > [deep copy support 413](#filepos1662129)

> > [generating parallel work 398-402](#filepos1613179)

> > [new loop directive 413-414](#filepos1666877)

> > [new scan reduction type 411](#filepos1655422)

> > [optimizing 406-410](#filepos1651964)

> [function-level OpenMP 229-231](#filepos934187)

> [high-level OpenMP 231-237](#filepos957355)

> > [example of 234-237](#filepos957341)

> > [implementing 232-234](#filepos942942)

> [hybrid MPI plus 299-302](#filepos1266726)

> [hybrid threading and vectorization with 237-240](#filepos966796)

> [loop-level OpenMP 219-228](#filepos917737)

> > [performance of 226-227](#filepos912496)

> > [potential issues with 227-228](#filepos917725)

> > [reduction example of global sum using OpenMP threading 227](#filepos912716)

> > [stencil example 224-226](#filepos907648)

> > [stream triad example 222-224](#filepos901599)

> > [vector addition example 220-222](#filepos896938)

> [MPI plus 218-219, 300-302, 511-516](#filepos2016727)

> [overview 208-217](#filepos874908)

> [resources for 251-252, 415](#filepos1669937)

> [SIMD directives 203-205](#filepos827781)

> [SIMD functions 205](#filepos826705)

> [simple program 211-217](#filepos874897)

> [task-based support algorithm 250-251](#filepos1016347)

> [thread affinity with 495-503](#filepos1976518)

> [threading tools 247-249](#filepos1009778)

> > [Allinea/ARM Map 248](#filepos1006624)

> > [Intel Inspector 248-249](#filepos1009766)

> [use cases 217-219](#filepos881141)

> > [high-level OpenMP 218](#filepos878010)

> > [loop-level OpenMP 217-218](#filepos877535)

> > [MPI plus OpenMP 218-219](#filepos881125)

> [variable scope 228-229](#filepos923341)

OpenMPI

> [default process placement with 504](#filepos1977573)

> [specifying process placement in 504-509](#filepos1992221)

[OpenSFS (Open Scalable File Systems) 575](#filepos2241403)

[Ops (operations) 59](#filepos336932)

[optimized libraries 179](#filepos714267)

[OrangeFS 576](#filepos2246132)

[OSSs (Object Storage Servers) 575](#filepos2241575)

[OSTs (Object Storage Targets) 575](#filepos2241616)

[out-of-bound errors 594](#filepos2313949)

[output dependency 188](#filepos749255)

[oversubscribe command 535](#filepos2082314)

P

[package managers 607-609](#filepos2361719)

> [for macOS 607](#filepos2354947)

> [for Windows 608](#filepos2356116)

> [Spack package manager 608-609](#filepos2361699)

[pageable memory 332, 428](#filepos1722610)

[Panasas 575-576](#filepos2245604)

[parallel algorithms 124-169](#filepos695361)

> [defined 130](#filepos550091)

> [future of research 167](#filepos685910)

> [hash functions, defined 131-132](#filepos558562)

> [overview 125-126](#filepos532388)

> [parallel global sum 161-166](#filepos685724)

> [performance models vs. algorithmic complexity 126-130](#filepos549903)

> [prefix sum pattern 157-161](#filepos656919)

> > [for large arrays 160-161](#filepos656909)

> > [step-efficient parallel scan operation 158](#filepos650629)

> > [work-efficient parallel scan operation 159-160](#filepos654461)

> [resources for 168](#filepos688601)

> [spatial hashing 132-157](#filepos647749)

> > [compact hashing 149-157](#filepos647739)

> > [perfect hashing 135-148](#filepos618831)

[parallel computing 3-34](#filepos251661)

> [application/software model for 25-29](#filepos235502)

> > [process-based parallelization 26-27](#filepos229589)

> > [stream processing through specialized processors 28-29](#filepos235491)

> > [thread-based parallelization 27-28](#filepos232545)

> > [vectorization 28](#filepos232760)

> [categorizing parallel approaches 29-30](#filepos238413)

> [cautions regarding 11](#filepos191091)

> [fundamental laws of 11-15](#filepos199744)

> > [Amdahl’s Law 11-12](#filepos193812)

> > [Gustafson-Barsis’s Law 12-15](#filepos199726)

> [hardware model for 22-25](#filepos225561)

> > [accelerator devices 24](#filepos222311)

> > [distributed memory architecture 22-23](#filepos218501)

> > [general heterogeneous parallel architecture model 24-25](#filepos225545)

> > [shared memory architecture 23](#filepos218706)

> > [vector units 23-24](#filepos221843)

> [overview of book 32-33](#filepos250476)

> [parallel speedup vs. comparative speedup 31-32](#filepos244834)

> [potential benefits of 8-11](#filepos190905)

> > [cost reduction 10-11](#filepos190892)

> > [energy efficiency 9-10](#filepos189794)

> > [faster run time with more compute cores 9](#filepos183900)

> > [larger problem sizes with more compute nodes 9](#filepos185014)

> [reasons for learning about 6-11](#filepos192278)

> [resources for 33](#filepos247641)

> [sample app 16-22](#filepos215571)

> > [defining computational kernel or operation 17-18](#filepos210243)

> > [discretizing problem 17](#filepos206768)

> > [off-loading calculation to GPUs 21-22](#filepos215555)

> > [processes 19-21](#filepos213344)

> > [threads 19](#filepos211456)

> > [vectorization 19](#filepos210457)

> [task parallelism 30](#filepos238585)

[Parallel Data Systems Workshop (PDSW) 577](#filepos2249813)

[parallel development workflow 35-57](#filepos334096)

> [commiting 55](#filepos326621)

> [implementation 54](#filepos323647)

> [planning 51-53](#filepos321757)

> > [algorithms 53](#filepos321046)

> > [benchmarks and mini-apps 52](#filepos317271)

> > [design of core data structures and code modularity 53](#filepos320132)

> [preparation 36-50](#filepos313454)

> > [finding and fixing memory issues 48-50](#filepos311099)

> > [improving code portability 50](#filepos311277)

> > [test suites 39-48](#filepos303589)

> > [version control 37-39](#filepos266694)

> [profiling 51](#filepos314393)

> [resources for 56](#filepos329150)

[parallel directive 233, 381, 496](#filepos1956062)

[parallel do directive 218](#filepos877307)

[parallel_for command 452](#filepos1829367)

[parallel_for pattern 455](#filepos1845306)

[parallel for pragma 218, 226](#filepos909242)

[parallel global sum 161-166](#filepos685724)

[parallelism, lack of 343](#filepos1406632)

[parallel kernel 356-357](#filepos1459065)

[parallel loop pragma 381-383](#filepos1541051)

[parallel patterns 157-161](#filepos656919)

> [for large arrays 160-161](#filepos656909)

> [step-efficient parallel scan operation 158](#filepos650629)

> [work-efficient parallel scan operation 159-160](#filepos654461)

[parallel pragma 381](#filepos1532578)

[parallel speedup (serial-to-parallel speedup) 31-32](#filepos244834)

[parallel-to-serial interface 549-550](#filepos2135085)

[Parallel Virtual File System (PVFS) 576](#filepos2246191)

[partial differential equations (PDEs) 18](#filepos208404)

[pattern rule 422](#filepos1692495)

[PBS (Portable Batch System) 529](#filepos2058835)

[PCI (Peripheral Component Interconnect) 24, 312](#filepos1291371)

> [benchmark application for 329-332](#filepos1373936)

> [higher performance alternative to 334](#filepos1378598)

> [theoretical bandwidth of 326-329](#filepos1359564)

> > [maximum transfer rate 327-328](#filepos1358138)

> > [overhead rates 328](#filepos1358853)

> > [PCIe lanes 327](#filepos1350308)

> > [reference data for 329](#filepos1359405)

[PCIe (Peripheral Component Interconnect Express) 310, 326](#filepos1347084)

[PCIe lanes 327](#filepos1350308)

[PCI SIG (PCI Special Interest Group) 327](#filepos1352179)

[PDEs (partial differential equations) 18](#filepos208404)

[PDF (portable document format) 606](#filepos2351716)

[PDSW (Parallel Data Systems Workshop) 577](#filepos2249813)

[Pennant app 593](#filepos2310824)

[perfect hashing 135-148](#filepos618831)

> [neighbor finding 135-141](#filepos590493)

> [remaps 142](#filepos590689)

> [sorting mesh data 146-148](#filepos618819)

> [table lookups 143-146](#filepos610209)

[performance limits 58-85](#filepos406620)

> [benchmarking 62-71](#filepos370383)

> > [calculating machine balance between flops and bandwidth 71](#filepos369039)

> > [calculating theoretical maximum flops 65](#filepos352577)

> > [empirical measurement of bandwidth and flops 67-69](#filepos365629)

> > [memory hierarchy and theoretical memory bandwidth 66-67](#filepos358836)

> > [tools for gathering system characteristics 62-64](#filepos352002)

> [knowing potential limits 59-61](#filepos344423)

> [profiling 71-84](#filepos401160)

> > [empirical measurement of processor clock frequency and energy consumption 82-83](#filepos398663)

> > [tools for 72-82](#filepos395293)

> > [tracking memory during run time 83-84](#filepos401148)

> [resources for 84](#filepos401677)

performance models

> [advanced 116-119](#filepos515256)

> [algorithmic complexity vs. 126-130](#filepos549903)

> [simple 105-116](#filepos503334)

> > [compressed sparse storage representations 112-116](#filepos503321)

> > [full matrix data representations 109-111](#filepos489018)

[Peripheral Component Interconnect (PCI) 24, 312](#filepos1291371)

[PEs (processing elements), OpenCL 316](#filepos1306664)

[pgaccelinfo command 353, 375, 388](#filepos1561541)

[PGI compiler 374](#filepos1509394)

[PICSARlite 592](#filepos2307338)

[pinned memory 332, 428](#filepos1722721)

[pinning 301, 491](#filepos1941694)

[pipeline busy 480](#filepos1909635)

[placement 491](#filepos1941840)

[planning workflow step 51-53](#filepos321757)

> [algorithms 53](#filepos321046)

> [benchmarks and mini-apps 52](#filepos317271)

> [design of core data structures and code modularity 53](#filepos320132)

[PnetCDF (Parallel Network Common Data Form) 568](#filepos2213719)

[Portable Batch System (PBS) 529](#filepos2058835)

[portable document format (PDF) 606](#filepos2351716)

[POSIX (Portable Operating System Interface) 585, 607](#filepos2352371)

[potential speedup 189](#filepos753829)

[power wall 23](#filepos220268)

[pragmas 183-190, 208](#filepos838407)

> [directive-based GPU programming 373-374](#filepos1508236)

> [kernels pragma 378-380](#filepos1531597)

> [parallel loop pragma 381-383](#filepos1541051)

[prefetch cost (Pc) 106](#filepos474546)

[prefix sum operations (scans) 157-161](#filepos656919)

> [for large arrays 160-161](#filepos656909)

> [step-efficient parallel scan operation 158](#filepos650629)

> [threaded implementation of 246-247](#filepos1004366)

> [work-efficient parallel scan operation 159-160](#filepos654461)

[preparation workflow step 36-50](#filepos313454)

> [finding and fixing memory issues 48-50](#filepos311099)

> [improving code portability 50](#filepos311277)

> [test suites 39-48](#filepos303589)

> > [automatic testing with CMake and CTest 41-45](#filepos291931)

> > [changes in results due to parallelism 40-41](#filepos273419)

> > [kinds of code tests 45-47](#filepos302333)

> > [requirements of ideal testing system 48](#filepos302533)

> [version control 37-39](#filepos266694)

[primary keyword 495](#filepos1952849)

[printf command 259](#filepos1043887)

[private directive 229](#filepos921929)

[process-based parallelization 26-27](#filepos229589)

[processes 19-21](#filepos213344)

[profilers 585-590](#filepos2300107)

> [detailed profilers 590](#filepos2297393)

> [high-level profilers 587](#filepos2288618)

> [medium-level profilers 588-589](#filepos2296756)

> [text-based profilers 586-587](#filepos2288391)

[profiling 71-84](#filepos401160)

> [empirical measurement of processor clock frequency and energy consumption 82-83](#filepos398663)

> [tools for 72-82](#filepos395293)

> > [call graphs 72-78](#filepos386647)

> > [likwid-perfctr markers 78](#filepos387303)

> > [roofline plots 78-82](#filepos395283)

> [tracking memory during run time 83-84](#filepos401148)

[profiling workflow step 51](#filepos314393)

[proxy mini-app 592](#filepos2305239)

[ps command 83](#filepos399805)

[PVFS (Parallel Virtual File System) 576](#filepos2246191)

Q

[qcachegrind command 73](#filepos376129)

[quadratic probing 151](#filepos624233)

[Quantum Monte Carlo (miniQMC) 592](#filepos2307058)

[queues (streams), asynchronous computing through 365-366](#filepos1485493)

[QUO library 520](#filepos2030905)

R

[R (replicated array) 13](#filepos197893)

[race conditions 209](#filepos840415)

[Radeon Open Compute platform (ROCm) 435](#filepos1749462)

[RAJA 455-457](#filepos1852243)

[ranks 26](#filepos227514)

[RAW (read-after-write) 188](#filepos749059)

[real cells 186](#filepos742879)

[receive keyword 261](#filepos1048786)

[recursive algorithms 343](#filepos1407769)

[Red Hat Package Manager (.rpm) 607](#filepos2354686)

[reduction operation 122, 162, 227](#filepos912862)

reduction pattern

> [getting single value from across all processes 269-273](#filepos1105055)

> [OpenCL 445-449](#filepos1813978)

> [synchronization across work groups 364-365](#filepos1482849)

[register pressure 361](#filepos1473294)

[relaxed memory model 209](#filepos840203)

[remapping operation 135](#filepos567119)

remaps

> [hierarchical hash technique for 156-157](#filepos647727)

> [using spatial perfect hash 142](#filepos590689)

> [with write optimizations and compact hashing 153-156](#filepos645248)

[remote procedure call (RPC) 27](#filepos230547)

[remove function 552](#filepos2139991)

[replicated array 13](#filepos197893)

[research mini-app 592](#filepos2305509)

[restarting 539](#filepos2096418)

[restrict keyword 179](#filepos716770)

[ROCgdb 604](#filepos2344131)

[ROCm (Radeon Open Compute platform) 435](#filepos1749462)

[ROMIO library 575](#filepos2241777)

[ROMIO MPI-IO library 576](#filepos2247969)

[roofline plots 78-82](#filepos395283)

[routine directive 394](#filepos1583954)

[row major 90](#filepos420069)

[RPC (remote procedure call) 27](#filepos230547)

[.rpm (Red Hat Package Manager) 607](#filepos2354686)

S

[salloc command 533](#filepos2072388)

[sbatch command 534-535](#filepos2082346)

[scalability 13](#filepos197468)

[SCALAPACK (scalable linear algebra package) 179](#filepos715020)

[scalar operation 23](#filepos220624)

[scatter operations 274-276](#filepos1120706)

[scp (secure copy) 463](#filepos1868019)

[SDE (Software Development Emulator) package 81](#filepos394380)

[send and receive commands 259-266](#filepos1071296)

[send keyword 261](#filepos1048750)

[serial directive 383](#filepos1540705)

[serial-to-parallel speedup (parallel speedup) 31-32](#filepos244826)

[shader processors 316](#filepos1306848)

shallow water simulation example

> [overview 463-467](#filepos1878039)

> [profiling workflow 467-478](#filepos1905638)

> > [CodeXL suite 478](#filepos1904838)

> > [data movement directives 473-474](#filepos1898364)

> > [guided analysis 474-475](#filepos1902225)

> > [NVIDIA Nsight suite 476-477](#filepos1904263)

> > [OpenACC compute directives 471-473](#filepos1895219)

> > [profile CPU code 470](#filepos1884732)

> > [running application 467-469](#filepos1884529)

[shared memory 23, 302](#filepos1268974)

SIMD (single instruction, multiple data) architecture

> [GPU programming model 354-355](#filepos1450854)

> [OpenMP SIMD directives 203-205](#filepos827781)

> [OpenMP SIMD functions 205](#filepos826705)

> [overview 176-177](#filepos708313)

[simd pragma 238](#filepos962755)

[Simple Linux Utility for Resource Management (Slurm) 529](#filepos2058901)

[SIMT (single instruction, multi-thread) 30, 314, 354](#filepos1447182)

[sleep command 542](#filepos2111566)

[slice operator 91](#filepos421689)

[Slurm (Simple Linux Utility for Resource Management) 529](#filepos2058901)

[SMs (streaming multiprocessors) 21, 24, 316, 479](#filepos1906941)

[SNAP (SN application proxy) 593](#filepos2310955)

[SoA (Structures of Arrays) 197](#filepos792066)

> [AoS vs. 94-100](#filepos455031)

> [performance assessment 96-100](#filepos455021)

[sockets, on motherboards 66](#filepos356687)

[Software Development Emulator (SDE) package 81](#filepos394380)

[solid-state drive (SSD) 548](#filepos2128494)

[spack find command 609](#filepos2361219)

[spack list command 609](#filepos2360570)

[spack load \<package_name\> command 609](#filepos2361553)

[Spack package manager 608-609](#filepos2361699)

[spatial hashing 132-157](#filepos647749)

> [compact hashing 149-157](#filepos647739)

> > [face neighbor finding 152-153](#filepos630719)

> > [neighbor finding 149-151](#filepos627282)

> > [remaps 153-157](#filepos647727)

> [perfect hashing 135-148](#filepos618831)

> > [neighbor finding 135-141](#filepos590493)

> > [remaps 142](#filepos590689)

> > [sorting mesh data 146-148](#filepos618819)

> > [table lookups 143-146](#filepos610209)

[spatial locality 105](#filepos468662)

[speeds 59](#filepos337560)

[speedup 9](#filepos183953)

[spinning disk 548](#filepos2129056)

[spread keyword 495](#filepos1952811)

[srun command 535](#filepos2082380)

[SSD (solid-state drive) 548](#filepos2128494)

[SSE2 (Streaming SIMD Extensions) 177](#filepos708047)

[statfs command 574](#filepos2237448)

stencil calculations

> [ghost cell exchanges in 3D stencil calculation 285-286](#filepos1180113)

> [loop-level OpenMP 224-226](#filepos907648)

> [with separate pass for x and y directions 240-243](#filepos988253)

[step-efficient parallel scan operation 158](#filepos650629)

[STL (Standard Template Library) 420](#filepos1683464)

[store operation 102](#filepos461965)

[STREAM Benchmark 67](#filepos360915)

[streaming kernels 119](#filepos514627)

[streaming multiprocessors (SMs) 21, 24, 316, 479](#filepos1906941)

[streaming store 119](#filepos513525)

[stream processing through specialized processors 28-29](#filepos235491)

[streams 420](#filepos1685628)

stream triad

> [loop-level OpenMP 222-224](#filepos901599)

> [measuring bandwidth on node 276](#filepos1121491)

> [performance results for 393](#filepos1579778)

[stride 91](#filepos422178)

[strong scaling 12](#filepos194586)

[subgroups 353-354](#filepos1448627)

[SVN (Subversion) 583](#filepos2273786)

[SW4lite 592](#filepos2307458)

[SWFFT 592](#filepos2307572)

[SYCL 449-452](#filepos1830246)

[Sycl function 451](#filepos1826035)

[synchronization 420, 480](#filepos1909104)

[sysctl command 64](#filepos350603)

[system_profiler command 64](#filepos350638)

T

[table lookups, using spatial perfect hash 143, 145-146](#filepos610209)

[tape 548](#filepos2129626)

[target directive 50](#filepos313471)

[task-based support algorithm 250-251](#filepos1016347)

[task parallelism 30](#filepos238585)

[taskset command 509](#filepos1992864)

[TCL modules 612](#filepos2371615)

[TDD (test-driven development) 46](#filepos295484)

[TDP (thermal design power) 337](#filepos1387301)

[TeaLeaf mini-app 593](#filepos2312987)

[teams directive 411](#filepos1653822)

[temporal locality 105](#filepos468662)

[test suites 39-48](#filepos303589)

> [automatic testing with CMake and CTest 41-45](#filepos291931)

> [changes in results due to parallelism 40-41](#filepos273419)

> [kinds of code tests 45-47](#filepos302333)

> [requirements of ideal testing system 48](#filepos302533)

[texture busy 480](#filepos1909505)

[theoretical machine balance (MBT) 71](#filepos369201)

[theoretical memory bandwidth (BT) 66](#filepos357995)

[Thornado-mini 592](#filepos2307720)

[thread divergence 149, 343](#filepos1407203)

threading

> [global sum using OpenMP threading 227](#filepos912716)

> [hybrid threading with OpenMP 237-240](#filepos966796)

> [Kahan summation implementation with OpenMP threading 244](#filepos989150)

> [sample app 19](#filepos211456)

> [thread-based parallelization 27-28](#filepos232545)

> [thread checkers 599-601](#filepos2335241)

> > [Archer 600-601](#filepos2335224)

> > [Intel Inspector 600](#filepos2330585)

> [threaded implementation of prefix scan algorithm 246-247](#filepos1004366)

> [thread engine, GPU as 313-318](#filepos1322121)

> > [calculating peak theoretical flops 316-318](#filepos1322121)

> > [compute unit 316](#filepos1306163)

> > [multiple data operations by each element 316](#filepos1307687)

> > [processing elements 316](#filepos1306585)

> [thread indices 357-358](#filepos1461348)

> [tools for 247-249](#filepos1009778)

> > [Allinea/ARM Map 248](#filepos1006624)

> > [Intel Inspector 248-249](#filepos1009766)

[threadprivate directive 230](#filepos924461)

[threads 16](#filepos205546)

[tightly-nested loops 390](#filepos1566157)

[time command 587](#filepos2287758)

[top command 83, 531](#filepos2064582)

[totalview command 602](#filepos2337571)

[TotalView debugger 602](#filepos2337183)

[TSan (ThreadSanitizer) 600](#filepos2331821)

U

[unified memory 429](#filepos1725162)

[uninitialized memory 594](#filepos2314579)

[unstructured data regions 403](#filepos1617302)

[unstructured mesh boundary communications 302](#filepos1268402)

V

[valgrind command 49](#filepos306468)

[Valgrind Memcheck 49-50, 594](#filepos2315058)

[variable scope 228-229](#filepos923341)

[vector intrinsics 190-194](#filepos783183)

[vectorization 175-206](#filepos833077)

> [compiler flags 198-201](#filepos811308)

> [methods for 178-196](#filepos789821)

> > [assembler instructions 195-196](#filepos789809)

> > [auto-vectorization 179-183](#filepos730723)

> > [compiler hints 183-190](#filepos755188)

> > [optimized libraries 179](#filepos714267)

> > [vector intrinsics 190-194](#filepos783183)

> [multiple operations with one instruction 28](#filepos232760)

> [OpenMP SIMD directives 203-205](#filepos827781)

> [OpenMP SIMD functions 205](#filepos826705)

> [overview 176-177](#filepos708313)

> [programming style for 196-198](#filepos794359)

> [resources for 206](#filepos830125)

> [sample app 19](#filepos210457)

> [with OpenMP 237-240](#filepos966796)

[vector lanes (lanes) 23](#filepos221212)

[vector length 23](#filepos221424)

[vector_length(x) directive 388](#filepos1561739)

[vector operation 19](#filepos210681)

[vector units 23-24](#filepos221843)

[version control 37-39, 582-583](#filepos2275224)

> [centralized version control 583](#filepos2273554)

> [distributed version control 582-583](#filepos2273330)

[VirtualBox 483-485](#filepos1928481)

[VMs (virtual machines) 483-485](#filepos1928481)

W

[WAR (write-after-read) 188](#filepos749255)

[warm cache 226](#filepos907427)

[warps 353-354](#filepos1448627)

[wavefronts 353-354](#filepos1448627)

[weak scaling 13](#filepos196542)

[WekaIO 576](#filepos2248235)

[Windows Subsytem Linux (WSL) 608](#filepos2356451)

[wmic command 64](#filepos350564)

[work-efficient parallel scan operation 159-160](#filepos654461)

[workers 387](#filepos1560463)

[work groups 353, 364-365](#filepos1482849)

[work items 354](#filepos1448825)

[work sharing 209](#filepos842803)

[write-allocate 118](#filepos508888)

[WSL (Windows Subsytem Linux) 608](#filepos2356451)

X

[XSBench 592](#filepos2307854)
