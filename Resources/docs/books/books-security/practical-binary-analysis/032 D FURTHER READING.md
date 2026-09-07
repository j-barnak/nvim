## D FURTHER READING

This appendix contains a list of references and suggestions for further reading on binary analysis. I’ve grouped these suggestions into standards and references, papers and articles, and books. Although this list is by no means exhaustive, it should serve as a good first step for delving further into the world of binary analysis.

### D.1 Standards and References

• *DWARF Debugging Information Format Version 4*. Available at *<http://www.dwarfstd.org/doc/DWARF4.pdf>*.

The DWARF v4 debugging format specification.

• *Executable and Linkable Format (ELF)*. Available at *<http://www.skyfree.org/linux/references/ELF_Format.pdf>*.

The ELF binary format specification.

• *Intel 64 and IA-32 Architectures Software Developer Manuals*. Available at *<https://software.intel.com/en-us/articles/intel-sdm>*.

The Intel x86/x64 manual. Contains in-depth descriptions of the entire instruction set.

• *The PDB File Format*. Available at *<https://llvm.org/docs/PDB/index.html>*.

Unofficial documentation of the PDB debugging format by the LLVM project (based on information released by Microsoft at *<https://github.com/Microsoft/microsoft-pdb>*).

• *PE Format Specification*. Available at *<https://msdn.microsoft.com/en-us/library/windows/desktop/ms680547(v=vs.85).aspx>*.

A specification of the PE format on MSDN.

• *System V Application Binary Interface*. Available at *<https://software.intel.com/sites/default/files/article/402129/mpx-linux64-abi.pdf>*.

Specification of the x64 System V ABI.

### D.2 Papers and Articles

• Baldoni, R., Coppa, E., D’Elia, D. C., Demetrescu, C., and Finocchi, I. (2017). A Survey of Symbolic Execution Techniques. Available at *<https://arxiv.org/pdf/1610.00502.pdf>*.

A survey paper on symbolic execution techniques.

• Barrett, C., Sebastiani, R., Seshia, S. A., and Tinelli, C. (2008). Satisfiability modulo theories. In *Handbook of Satisfiability*, chapter 12. IOS Press. Available at *<https://people.eecs.berkeley.edu/~sseshia/pubdir/SMT-BookChapter.pdf>*.

A book chapter on Satisfiability Modulo Theories (SMT).

• Cha, S. K., Avgerinos, T., Rebert, A., and Brumley, D. (2012). Unleashing Mayhem on Binary Code. In *Proceedings of the IEEE Symposium on Security and Privacy*, SP’12. Available at *<https://users.ece.cmu.edu/~dbrumley/pdf/Cha%20et%20al._2012_Unleashing%20Mayhem%20on%20Binary%20Code.pdf>*.

Automatic exploit generation for stripped binaries using symbolic execution.

• Dullien, T. and Porst, S. (2009). REIL: A Platform-Independent Intermediate Representation of Disassembled Code for Static Code Analysis. In *Proceedings of CanSecWest*. Available at *<https://www.researchgate.net/publication/228958277>*.

A paper on the REIL intermediate language.

• Kemerlis, V. P., Portokalidis, G., Jee, K., and Keromytis, A. D. (2012). libdft: Practical Dynamic Data Flow Tracking for Commodity Systems. In *Proceedings of the Conference on Virtual Execution Environments*, VEE’12. Available at *<http://nsl.cs.columbia.edu/papers/2012/libdft.vee12.pdf>*.

The original paper on the `libdft` dynamic taint analysis library.

• Kolsek, M. (2017). Did Microsoft Just Manually Patch Their Equation Editor Executable? Why Yes, Yes They Did. (CVE-2017-11882). Available at *<https://blog.0patch.com/2017/11/did-microsoft-just-manually-patch-their.html>*.

An article describing how Microsoft fixed a software vulnerability with a likely handwritten binary patch.

• Link Time Optimization (`gcc` wiki entry). Available at *<https://gcc.gnu.org/wiki/LinkTimeOptimization>*.

An article about link-time optimization (LTO) on the `gcc` wiki. Contains links to other relevant articles on LTO.

• LLVM Link Time Optimization: Design and Implementation. Available at *<https://llvm.org/docs/LinkTimeOptimization.html>*.

An article about LTO in the LLVM project.

• Luk, C.-K., Cohn, R., Muth, R., Patil, H., Klauser, A., Lowney, G., Wallace, S., Reddi, V. J., and Hazelwood, K. (2005). Pin: Building Customized Program Analysis Tools with Dynamic Instrumentation. In *Proceedings of the Conference on Programming Language Design and Implementation*, PLDI’05. Available at *<http://gram.eng.uci.edu/students/swallace/papers_wallace/pdf/PLDI-05-Pin.pdf>*.

The original paper on Intel Pin.

• Pietrek, M. (1994). Peering Inside the PE: A Tour of the Win32 Portable Executable File Format. Available at *<https://msdn.microsoft.com/en-us/library/ms809762.aspx>*.

A detailed (albeit dated) article on the intricacies of the PE format.

• Rolles, R. (2016). Synesthesia: A Modern Approach to Shellcode Generation. Available at *<http://www.msreverseengineering.com/blog/2016/11/8/synesthesia-modern-shellcode-synthesis-ekoparty-2016-talk/>*.

A symbolic execution–based approach for automatically generating shellcode.

• Schwartz, E. J., Avgerinos, T., and Brumley, D. (2010). All You Ever Wanted to Know About Dynamic Taint Analysis and Forward Symbolic Execution (But Might Have Been Afraid to Ask). In *Proceedings of the IEEE Symposium on Security and Privacy*, SP’10. Available at *<https://users.ece.cmu.edu/~aavgerin/papers/Oakland10.pdf>*.

An in-depth paper on the implementation details and pitfalls of dynamic taint analysis and symbolic execution.

• Slowinska, A., Stancescu, T., and Bos, H. (2011). Howard: A Dynamic Excavator for Reverse Engineering Data Structures. In *Proceedings of the Network and Distributed Systems Security Symposium*, NDSS’11. Available at *<https://www.isoc.org/isoc/conferences/ndss/11/pdf/5_1.pdf>*.

A paper describing an approach to automatic reverse engineering of data structures.

• Yason, M. V. (2007). The art of unpacking. In *BlackHat USA*. Available at *<https://www.blackhat.com/presentations/bh-usa-07/Yason/Whitepaper/bh-usa-07-yason-WP.pdf>*.

An introduction to binary unpacking techniques.

### D.3 Books

• Collberg, C. and Nagra, J. (2009). *Surreptitious Software: Obfuscation, Watermarking, and Tamperproofing for Software Protection*. Addison-Wesley Professional.

A thorough overview of software (de)obfuscation, watermarking, and tamperproofing techniques.

• Eagle, C. (2011). *The IDA Pro Book: The Unofficial Guide to the World’s Most Popular Disassembler (2nd edition)*. No Starch Press.

A complete book dedicated to disassembling binaries with IDA Pro.

• Eilam, E. (2005). *Reversing: Secrets of Reverse Engineering*. John Wiley & Sons, Inc.

An introduction to manually reversing binaries (focusing on Windows).

• Sikorski, M. and Honig, A. (2012). *Practical Malware Analysis: The Hands-On Guide to Dissecting Malicious Software*. No Starch Press.

A comprehensive introduction to malware analysis.