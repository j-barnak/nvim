## 4 BUILDING A BINARY LOADER USING LIBBFD

Now that you have a solid understanding of how binaries work from the previous chapters, you’re ready to start building your own analysis tools. Throughout this book, you’ll frequently build your own tools that manipulate binaries. Because nearly all of these tools will need to parse and (statically) load binary files, it makes sense to have a common framework that provides this ability. In this chapter, let’s use `libbfd` to design and implement such a framework to reinforce what you’ve learned so far about binary formats.

You’ll see the binary loading framework again in Part III of this book, which covers advanced techniques for building your own binary analysis tools. Before designing the framework, I’ll briefly introduce `libbfd`.

### 4.1 What Is libbfd?

The Binary File Descriptor library^(1) (`libbfd`) provides a common interface for reading and parsing all popular binary formats, compiled for a wide variety of architectures. This includes ELF and PE files for x86 and x86-64 machines. By basing your binary loader on `libbfd`, you can automatically support all these formats without having to implement any format-specific support.

The BFD library is part of the GNU project and is used by many applications in the `binutils` suite, including `objdump`, `readelf`, and `gdb`. It provides generic abstractions for all common components used in binary formats, such as headers describing the binary’s target and properties, lists of sections, sets of relocations, symbol tables, and so on. On Ubuntu, `libbfd` is part of the `binutils-dev` package.

You can find the core `libbfd` API in */usr/include/bfd.h*.^(2) Unfortunately, `libbfd` can be a bit unwieldy to use, so instead of trying to explain the API here, let’s dive straight in and explore the API while implementing the binary-loading framework.

### 4.2 A Simple Binary-Loading Interface

Before implementing the binary loader, let’s design an easy-to-use interface. After all, the whole point of the binary loader is to make the process of loading binaries as easy as possible for all the binary analysis tools that you’ll implement later in this book. It’s intended for use in static analysis tools. Note that this is completely different from the dynamic loader provided by the OS, whose job it is to load binaries into memory to execute them, as discussed in Chapter 1.

Let’s make the binary-loading interface agnostic of the underlying implementation, which means it won’t expose any `libbfd` functions or data structures. For simplicity, let’s also keep the interface as basic as possible, exposing only those parts of the binary that you’ll use frequently in later chapters. For example, the interface will omit components such as relocations, which aren’t usually relevant for your binary analysis tools.

Listing 4-1 shows the C++ header file describing the basic API that the binary loader will expose. Note that it is located in the *inc* directory on the VM, rather than in the *chapter4* directory that contains the other code for this chapter. That’s because the loader is shared among all chapters in this book.

*Listing 4-1:* inc/loader.h

```
   #ifndef LOADER_H
   #define LOADER_H

   #include <stdint.h>
   #include <string>
   #include <vector>

   class Binary;
   class Section;
   class Symbol;

➊ class Symbol {
   public:
     enum SymbolType {
       SYM_TYPE_UKN = 0,
       SYM_TYPE_FUNC = 1
     };

     Symbol() : type(SYM_TYPE_UKN), name(), addr(0) {}

     SymbolType type;
     std::string name;
     uint64_t    addr;
   };

➋ class Section {
   public:
     enum SectionType {
       SEC_TYPE_NONE = 0,
       SEC_TYPE_CODE = 1,
       SEC_TYPE_DATA = 2
     };

     Section() : binary(NULL), type(SEC_TYPE_NONE),
                 vma(0), size(0), bytes(NULL) {}

     bool contains(uint64_t addr) { return (addr >= vma) && (addr-vma < size); }

     Binary         *binary;
     std::string     name;
     SectionType     type;
     uint64_t        vma;
     uint64_t        size;
     uint8_t         *bytes;
   };

➌ class Binary {
   public:
     enum BinaryType {
       BIN_TYPE_AUTO = 0,
       BIN_TYPE_ELF  = 1,
       BIN_TYPE_PE   = 2
     };
     enum BinaryArch {
       ARCH_NONE = 0,
       ARCH_X86 = 1
     };

     Binary() : type(BIN_TYPE_AUTO), arch(ARCH_NONE), bits(0), entry(0) {}

     Section *get_text_section()
       { for(auto &s : sections) if(s.name == ".text") return &s; return NULL; }

     std::string            filename;
     BinaryType             type;
     std::string            type_str;
     BinaryArch             arch;
     std::string            arch_str;
     unsigned               bits;
     uint64_t               entry;
     std::vector<Section>   sections;
     std::vector<Symbol>    symbols;
   };

➍ int load_binary(std::string &fname, Binary *bin, Binary::BinaryType type);
➎ void unload_binary(Binary *bin);

 #endif /* LOADER_H */
```

As you can see, the API exposes a number of classes representing different components of a binary. The `Binary` class is the “root” class, representing an abstraction of the entire binary ➌. Among other things, it contains a `vector` of `Section` objects and a `vector` of `Symbol` objects. The `Section` class ➋ and `Symbol` class ➊ represent the sections and symbols contained in the binary, respectively.

At its core, the whole API centers around only two functions. The first of these is the `load_binary` function ➍, which takes the name of a binary file to load (`fname`), a pointer to a `Binary` object to contain the loaded binary (`bin`), and a descriptor of the binary type (`type`). It loads the requested binary into the `bin` parameter and returns an integer value of 0 if the loading process was successful or a value less than 0 if it was not successful. The second function is `unload_binary` ➎, which simply takes a pointer to a previously loaded `Binary` object and unloads it.

Now that you’re familiar with the binary loader API, let’s take a look at how it’s implemented. I’ll start by discussing the implementation of the `Binary` class.

#### *4.2.1 The Binary Class*

As the name implies, the `Binary` class is an abstraction of a complete binary. It contains the binary’s filename, type, architecture, bit width, entry point address, and sections and symbols. The binary type has a dual representation: the `type` member contains a numeric type identifier, while `type_str` contains a string representation of the binary type. The same kind of dual representation is used for the architecture.

Valid binary types are enumerated in `enum BinaryType` and include ELF (`BIN_TYPE_ELF`) and PE (`BIN_TYPE_PE`). There’s also a `BIN_TYPE_AUTO`, which you can pass to the `load_binary` function to ask it to automatically determine whether the binary is an ELF or PE file. Similarly, valid architectures are enumerated in `enum BinaryArch`. For these purposes, the only valid architecture is `ARCH_X86`. This includes both x86 and x86-64; the distinction between the two is made by the `bits` member of the `Binary` class, which is set to 32 bits for x86 and to 64 bits for x86-64.

Normally, you access sections and symbols in the `Binary` class by iterating over the `sections` and `symbols` vectors, respectively. Because binary analysis often focuses on the code in the `.text` section, there is also a convenience function called `get_text_section` that, as the name implies, automatically looks up and returns this section for you.

#### *4.2.2 The Section Class*

Sections are represented by objects of type `Section`. The `Section` class is a simple wrapper around the main properties of a section, including the section’s name, type, starting address (the `vma` member), size (in bytes), and raw bytes contained in the section. For convenience, there is also a pointer back to the `Binary` that contains the `Section` object. The section type is denoted by an `enum SectionType` value, which tells you whether the section contains code (`SEC_TYPE_CODE`) or data (`SEC_TYPE_DATA`).

During your analyses, you’ll often want to check to which section a particular instruction or piece of data belongs. For this reason, the `Section` class has a function called `contains`, which takes a code or data address and returns a `bool` indicating whether the address is part of the section.

#### *4.2.3 The Symbol Class*

As you now know, binaries contain symbols for many types of components, including local and global variables, functions, relocation expressions, objects, and more. To keep things simple, the loader interface exposes only one kind of symbol: function symbols. These are especially useful because they enable you to easily implement function-level binary analysis tools when function symbols are available.

The loader represents symbols using the `Symbol` class. It contains a symbol type, represented as an `enum SymbolType`, for which the only valid value is `SYM_TYPE_FUNC`. In addition, the class contains the symbolic name and the start address of the function described by the symbol.

### 4.3 Implementing the Binary Loader

Now that the binary loader has a well-defined interface, let’s implement it! This is where `libbfd` gets involved. Because the code for the complete loader is a bit lengthy, I’ll split it up into chunks, which I’ll discuss one by one. In the following code, you can recognize the `libbfd` API functions because they all start with `bfd_` (there are also some functions that end with `_bfd`, but they are functions defined by the loader).

First, you must of course include all the header files you need. I won’t mention all of the standard C/C++ headers that the loader uses since they’re not of interest here (if you really want, you can look them up in the loader’s source on the VM). What is important to mention is that all programs that use `libbfd` must include *bfd.h*, as shown in Listing 4-2, and link against `libbfd` by specifying the linker flag `-lbfd`. In addition to *bfd.h*, the loader includes the header file that contains the interface created in the previous section.

*Listing 4-2:* inc/loader.cc

```
#include <bfd.h>
#include "loader.h"
```

With that out of the way, the next logical parts of the code to look at are `load_binary` and `unload_binary`, the two entry point functions exposed by the loader interface. Listing 4-3 shows how these functions are implemented.

*Listing 4-3:* inc/loader.cc *(continued)*

```
  int
➊ load_binary(std::string &fname, Binary *bin, Binary::BinaryType type)
  {
    return ➋load_binary_bfd(fname, bin, type);
  }
  
  void
➌ unload_binary(Binary *bin)
  {
    size_t i;
    Section *sec;

➍ for(i = 0; i < bin->sections.size(); i++) {
     sec = &bin->sections[i];
     if(sec->bytes) {
➎      free(sec->bytes);
     }
    }
   }
```

The job of `load_binary` ➊ is to parse a binary file specified by filename and load it into the `Binary` object given to it. This is a bit of a tedious process, so `load_binary` wisely defers the work to another function, called `load_binary_bfd` ➋. I’ll discuss this function shortly.

First, let’s look at `unload_binary` ➌. As with so many things, destroying a `Binary` object is a lot easier than creating one. To unload a `Binary` object, the loader must release (with `free`) all of the `Binary`’s dynamically allocated components. Luckily, there aren’t many of those: only the `bytes` member of each `Section` is allocated dynamically (using `malloc`). Thus, `unload_binary` simply iterates over all `Section` objects ➍ and deallocates the `bytes` array for each of them ➎. Now that you’ve seen how unloading a binary works, let’s take a more detailed look at how the loading process is implemented using `libbfd`.

#### *4.3.1 Initializing libbfd and Opening a Binary*

In the previous section, I promised to show you `load_binary_bfd`, the function that uses `libbfd` to take care of all the work involved in loading the binary. Before I do that, I have to get one more prerequisite out of the way. That is, to parse and load a binary, you must first open it. The code to open a binary is implemented in a function called `open_bfd`, shown in Listing 4-4.

*Listing 4-4:* inc/loader.cc *(continued)*

```
   static bfd*
   open_bfd(std::string &fname)
   {
     static int bfd_inited = 0;
     bfd *bfd_h;

     if(!bfd_inited) {
➊      bfd_init();
        bfd_inited = 1;
     }

➋   bfd_h = bfd_openr(fname.c_str(), NULL);
     if(!bfd_h) {
       fprintf(stderr, "failed to open binary '%s' (%s)\n",
               fname.c_str(), ➌bfd_errmsg(bfd_get_error()));
       return NULL;
     }
➍   if(!bfd_check_format(bfd_h, bfd_object)) {
       fprintf(stderr, "file '%s' does not look like an executable (%s)\n",
               fname.c_str(), bfd_errmsg(bfd_get_error()));
       return NULL;
     }

     /* Some versions of bfd_check_format pessimistically set a wrong_format
     * error before detecting the format and then neglect to unset it once
     * the format has been detected. We unset it manually to prevent problems.
     */
➎  bfd_set_error(bfd_error_no_error);

➏  if(bfd_get_flavour(bfd_h) == bfd_target_unknown_flavour) {
      fprintf(stderr, "unrecognized format for binary '%s' (%s)\n",
             fname.c_str(), bfd_errmsg(bfd_get_error()));
      return NULL;
    }
   
    return bfd_h;
  }
```

The `open_bfd` function uses `libbfd` to determine the properties of the binary specified by the filename (the `fname` parameter), open it, and then return a handle to the binary. Before you can use `libbfd`, you must call `bfd_init` ➊ to initialize `libbfd`’s internal state (or, as the documentation puts it, to “initialize magical internal data structures”). Since this needs to be done only once, `open_bfd` uses a static variable to keep track of whether the initialization has been done already.

After initializing `libbfd`, you call the `bfd_openr` function to open the binary by filename ➋. The second parameter of `bfd_openr` allows you to specify a target (the type of the binary), but in this case, I’ve left it to `NULL` so that `libbfd` will automatically determine the binary type. The return value of `bfd_openr` is a pointer to a file handle of type `bfd`; this is `libbfd`’s root data structure, which you can pass to all other functions in `libbfd` to perform operations on the binary. In case of error, `bfd_openr` returns `NULL`.

In general, whenever an error occurs, you can find the type of the most recent error by calling `bfd_get_error`. This returns an object of the type `bfd_error_type`, which you can compare against predefined error identifiers such as `bfd_error_no_memory` or `bfd_error_invalid_target` to figure out how to handle the error. Often, you’ll just want to exit with an error message. To accommodate this, the `bfd_errmsg` function can translate a `bfd_error_type` into a string describing the error, which you can print to the screen ➌.

After getting a handle to the binary, you should check the format of the binary using the `bfd_check_format` function ➍. This function takes a `bfd` handle and a `bfd_format` value, which can be set to `bfd_object`, `bfd_archive`, or `bfd_core`. In this case, the loader sets it to `bfd_object` to verify whether the opened file is indeed an object, which in `libbfd` terminology means an executable, a relocatable object, or a shared library.

After confirming that it’s dealing with a `bfd_object`, the loader manually sets `libbfd`’s error state to `bfd_error_no_error` ➎. This is a work-around for an issue in some versions of `libbfd`, which set a `bfd_error_wrong_format` error before detecting the format and leave the error state set even if the format detection shows no problems.

Finally, the loader checks that the binary has a known “flavor” by using the `bfd_get_flavour` function ➏. This function returns a `bfd_flavour` object, which simply indicates the kind of binary (ELF, PE, and so on). Valid `bfd_flavour` values include `bfd_target_msdos_flavour`, `bfd_target_coff_flavour`, and `bfd_target_elf_flavour`. If the binary format is unknown or there was an error, then `get_bfd_flavour` returns `bfd_target_unknown_flavour`, in which case `open_bfd` prints an error and returns `NULL`.

If all checks pass, it means that you have successfully opened a valid binary and are ready to start loading its contents! The `open_bfd` function returns the `bfd` handle it opened so you can use it later in other `libbfd` API calls, as shown in the next few listings.

#### *4.3.2 Parsing Basic Binary Properties*

Now that you’ve seen the necessary code to open a binary, it’s time to take a look at the `load_binary_bfd` function, shown in Listing 4-5. Recall that this is the function that handles all the actual parsing and loading work on behalf of the `load_binary` function. In this section, the aim is to load all of the interesting details about the binary into the `Binary` object pointed to by the `bin` parameter.

*Listing 4-5:* inc/loader.cc *(continued)*

```
   static int
   load_binary_bfd(std::string &fname, Binary *bin, Binary::BinaryType type)
   {
     int ret;
     bfd *bfd_h;
     const bfd_arch_info_type *bfd_info;

     bfd_h = NULL;
➊   bfd_h = open_bfd(fname);
     if(!bfd_h) {
       goto fail;
     }

     bin->filename = std::string(fname);
➋   bin->entry    = bfd_get_start_address(bfd_h);

➌   bin->type_str = std::string(bfd_h->xvec->name);
➍   switch(bfd_h->xvec->flavour) {
     case bfd_target_elf_flavour:
       bin->type = Binary::BIN_TYPE_ELF;
       break;
    case bfd_target_coff_flavour:
      bin->type = Binary::BIN_TYPE_PE;
      break;
    case bfd_target_unknown_flavour:
    default:
      fprintf(stderr, "unsupported binary type (%s)\n", bfd_h->xvec->name);
      goto fail;
    }

➎     bfd_info = bfd_get_arch_info(bfd_h);
➏     bin->arch_str = std::string(bfd_info->printable_name);
➐     switch(bfd_info->mach) {
      case bfd_mach_i386_i386:
        bin->arch = Binary::ARCH_X86;
        bin->bits = 32;
        break;
      case bfd_mach_x86_64:
        bin->arch = Binary::ARCH_X86;
        bin->bits = 64;
        break;
      default:
        fprintf(stderr, "unsupported architecture (%s)\n",
                bfd_info->printable_name);
        goto fail;
      }

      /* Symbol handling is best-effort only (they may not even be present) */
➑    load_symbols_bfd(bfd_h, bin);
➒    load_dynsym_bfd(bfd_h, bin);

      if(load_sections_bfd(bfd_h, bin) < 0) goto fail;

      ret = 0;
      goto cleanup;

    fail:
      ret = -1;

    cleanup:
➓    if(bfd_h) bfd_close(bfd_h);

      return ret;
   }
```

The `load_binary_bfd` function begins by using the just implemented `open_bfd` function to open the binary specified in the `fname` parameter and get a `bfd` handle to this binary ➊. Then, `load_binary_bfd` sets some of `bin`’s basic properties. It starts by copying the name of the binary file and using `libbfd` to find and copy the entry point address ➋.

To get the entry point address of a binary, you use `bfd_get_start_address`, which simply returns the value of the `start_address` field of the `bfd` object. The start address is a `bfd_vma`, which is really nothing more than a 64-bit unsigned integer.

Next, the loader collects information about the binary type: is it an ELF, a PE, or some other, unsupported type of binary? You can find this information in the `bfd_target` structure maintained by `libbfd`. To get a pointer to this data structure, you just need to access the `xvec` field in the `bfd` handle. In other words, `bfd_h->xvec` gives you a pointer to a `bfd_target` structure.

Among other things, this structure provides a string containing the name of the target type. The loader copies this string into the `Binary` object ➌. Next, it inspects the `bfd_h->xvec->flavour` field using a switch and sets the type of the `Binary` accordingly ➍. The loader supports only ELF and PE, so it emits an error if `bfd_h->xvec->flavour` indicates any other type of binary.

Now you know whether the binary is an ELF or PE, but you don’t yet know the architecture. To find this out, you use `libbfd`’s `bfd_get_arch_info` function ➎. As the name implies, this function returns a pointer to a data structure that provides information about the binary architecture. This data structure is called `bfd_arch_info_type`. It provides a convenient printable string describing the architecture, which the loader copies into the `Binary` object ➏.

The `bfd_arch_info_type` data structure also contains a field called `mach` ➐, which is just an integer identifier for the architecture (called the *machine* in `libbfd` terminology). This integer representation of the architecture allows for a convenient `switch` to implement architecture-specific handling. If `mach` is equal to `bfd_mach_i386_i386`, then it’s a 32-bit x86 binary, and the loader sets the fields in the `Binary` accordingly. If `mach` is `bfd_mach_x86_64`, then it’s an x86-64 binary, and the loader again sets the appropriate fields. Any other type is unsupported and results in an error.

Now that you’ve seen how to parse basic information about the binary type and architecture, it’s time to get to the real work: loading the symbols and sections contained in the binary. As you might imagine, this is not as simple as what you’ve seen so far, so the loader defers the necessary work to specialized functions, described in the next sections. The two functions the loader uses to load symbols are called `load_symbols_bfd` and `load_dynsym_bfd` ➑. As described in the next section, they load symbols from the static and dynamic symbol tables, respectively. The loader also implements `load_sections_bfd`, a specialized function to load the binary’s sections ➒. I’ll discuss it shortly, in Section 4.3.4.

After loading the symbols and sections, you’ll have copied all the information that you’re interested in to your own `Binary` object, which means you’re done using `libbfd`. Because the `bfd` handle is no longer needed, the loader closes it using `bfd_close` ➓. It also closes the handle if any error happens before it’s fully done loading the binary.

#### *4.3.3 Loading Symbols*

Listing 4-6 shows the code for `load_symbols_bfd`, the function to load the static symbol table.

*Listing 4-6:* inc/loader.cc *(continued)*

```
   static int
   load_symbols_bfd(bfd *bfd_h, Binary *bin)
   {
     int ret;
     long n, nsyms, i;
➊   asymbol **bfd_symtab;
     Symbol *sym;
   
     bfd_symtab = NULL;
   
➋    n = bfd_get_symtab_upper_bound(bfd_h);
     if(n < 0) {
       fprintf(stderr, "failed to read symtab (%s)\n",
               bfd_errmsg(bfd_get_error()));
       goto fail;
     } else if(n) {
➌      bfd_symtab = (asymbol**)malloc(n);
       if(!bfd_symtab) {
         fprintf(stderr, "out of memory\n");
        goto fail;
       }
➍     nsyms = bfd_canonicalize_symtab(bfd_h, bfd_symtab);
       if(nsyms < 0) {
         fprintf(stderr, "failed to read symtab (%s)\n",
                bfd_errmsg(bfd_get_error()));
         goto fail;
       }
➎     for(i = 0; i < nsyms; i++) {
➏       if(bfd_symtab[i]->flags & BSF_FUNCTION) {
           bin->symbols.push_back(Symbol());
           sym = &bin->symbols.back();
➐         sym->type = Symbol::SYM_TYPE_FUNC;
➑         sym->name = std::string(bfd_symtab[i]->name);
➒         sym->addr = bfd_asymbol_value(bfd_symtab[i]);
         }
       }
     }
     ret = 0;
     goto cleanup;

   fail:
     ret = -1;

   cleanup:
➓   if(bfd_symtab) free(bfd_symtab);

     return ret;

  }
```

In `libbfd`, symbols are represented by the `asymbol` structure, which is just a short name for `struct bfd_symbol`. In turn, a symbol table is just an `asymbol**`, meaning an array of pointers to symbols. Thus, the job of `load_symbols_bfd` is to populate the array of `asymbol` pointers declared at ➊ and then to copy the interesting information to the `Binary` object.

The input parameters to `load_symbols_bfd` are a `bfd` handle and the `Binary` object in which to store the symbolic information. Before you can load any symbol pointers, you need to allocate enough space to store all of them in. The `bfd_get_symtab_upper_bound` function ➋ tells you how many bytes to allocate for this purpose. The number of bytes is negative in case of an error, and it can also be zero, meaning that there is no symbol table. If there’s no symbol table, `load_symbols_bfd` is done and simply returns.

If all is well and the symbol table contains a positive number of bytes, you allocate enough space to keep all the `asymbol` pointers in ➌. If the `malloc` succeeds, you’re finally ready to ask `libbfd` to populate your symbol table! You do this using the `bfd_canonicalize_symtab` function ➍, which takes as input your `bfd` handle and the symbol table that you want to populate (your `asymbol**`). As requested, `libbfd` duly populates your symbol table and returns the number of symbols it placed in the table (again, if that number is negative, you know something went wrong).

Now that you have a populated symbol table, you can loop over all the symbols it contains ➎. Recall that for the binary loader, you are interested only in function symbols. Thus, for each symbol, you check whether the `BSF_FUNCTION` flag is set, which indicates that it is a function symbol ➏. If this is the case, you reserve room for a `Symbol` (recall that this is the loader’s own class to store symbols in) in the `Binary` object by adding an entry to the `vector` that contains all the loaded symbols. You mark the newly created `Symbol` as a function symbol ➐, copy the symbolic name ➑, and set the `Symbol`’s address ➒. To get a function symbol’s value, which is the function’s start address, you use the `bfd_asymbol_value` function provided by `libbfd`.

Now that all of the interesting symbols have been copied into `Symbol` objects, the loader no longer needs `libbfd`’s representation. Therefore, when `load_symbols_bfd` finishes, it deallocates any space reserved to store `libbfd` symbols ➓. After that, it returns, and the symbol-loading process is complete.

So, that’s how you load symbols from the static symbol table with `libbfd`. But how is it done for the dynamic symbol table? Luckily, the process is almost completely identical, as you can see in Listing 4-7.

*Listing 4-7:* inc/loader.cc *(continued)*

```
   static int
   load_dynsym_bfd(bfd *bfd_h, Binary *bin)
   {
     int ret;
     long n, nsyms, i;
➊   asymbol **bfd_dynsym;
     Symbol *sym;
   
     bfd_dynsym = NULL;
   
➋   n = bfd_get_dynamic_symtab_upper_bound(bfd_h);
     if(n < 0) {
       fprintf(stderr, "failed to read dynamic symtab (%s)\n",
               bfd_errmsg(bfd_get_error()));
       goto fail;
     } else if(n) {
       bfd_dynsym = (asymbol**)malloc(n);
       if(!bfd_dynsym) {
         fprintf(stderr, "out of memory\n");
         goto fail;
      }
➌    nsyms = bfd_canonicalize_dynamic_symtab(bfd_h, bfd_dynsym);
      if(nsyms < 0) {
        fprintf(stderr, "failed to read dynamic symtab (%s)\n",
                bfd_errmsg(bfd_get_error()));
       goto fail;
     }
     for(i = 0; i < nsyms; i++) {
       if(bfd_dynsym[i]->flags & BSF_FUNCTION) {
         bin->symbols.push_back(Symbol());
         sym = &bin->symbols.back();
         sym->type = Symbol::SYM_TYPE_FUNC;
         sym->name = std::string(bfd_dynsym[i]->name);
         sym->addr = bfd_asymbol_value(bfd_dynsym[i]);
       }
      }
     }
    
     ret = 0;
     goto cleanup;
   
   fail:
     ret = -1;
     
   cleanup:
     if(bfd_dynsym) free(bfd_dynsym);
    
     return ret;
   }
```

The function shown in Listing 4-7 to load symbols from the dynamic symbol table is aptly called `load_dynsym_bfd`. As you can see, `libbfd` uses the same data structure (`asymbol`) to represent both static and dynamic symbols ➊. The only differences with the previously shown `load_symbols_bfd` function are the following. First, to find the number of bytes you need to reserve for symbol pointers, you call `bfd_get_dynamic_symtab_upper_bound` ➋ instead of `bfd_get_symtab_upper_bound`. Second, to populate the symbol table, you use `bfd_canonicalize_dynamic_symtab` ➌ instead of `bfd_canonicalize_symtab`. That’s it! The rest of the dynamic symbol-loading process is the same as for static symbols.

#### *4.3.4 Loading Sections*

After loading the symbols, only one thing remains to be done, though it’s arguably the most important step: loading the binary’s sections. Listing 4-8 shows how `load_sections_bfd` implements the functionality to do this.

*Listing 4-8:* inc/loader.cc *(continued)*

```
  static int
  load_sections_bfd(bfd *bfd_h, Binary *bin)
  {
    int bfd_flags;
    uint64_t vma, size;
    const char *secname;
➊  asection* bfd_sec;
    Section *sec;
    Section::SectionType sectype;
  
➋  for(bfd_sec = bfd_h->sections; bfd_sec; bfd_sec = bfd_sec->next) {
➌    bfd_flags = bfd_get_section_flags(bfd_h, bfd_sec);

      sectype = Section::SEC_TYPE_NONE;
➍    if(bfd_flags & SEC_CODE) {
        sectype = Section::SEC_TYPE_CODE;
      } else if(bfd_flags & SEC_DATA) {
        sectype = Section::SEC_TYPE_DATA;
      } else {
        continue;
      }
➎    vma     = bfd_section_vma(bfd_h, bfd_sec);
➏    size    = bfd_section_size(bfd_h, bfd_sec);
➐    secname = bfd_section_name(bfd_h, bfd_sec);
     if(!secname) secname = "<unnamed>";
  
➑    bin->sections.push_back(Section());
      sec = &bin->sections.back();
  
      sec->binary = bin;
      sec->name   = std::string(secname);
      sec->type   = sectype;
      sec->vma    = vma;
      sec->size   = size;
➒    sec->bytes  = (uint8_t*)malloc(size);
      if(!sec->bytes) {
        fprintf(stderr, "out of memory\n");
        return -1;
     }
    
➓   if(!bfd_get_section_contents(bfd_h, bfd_sec, sec->bytes, 0, size)) {
       fprintf(stderr, "failed to read section '%s' (%s)\n",
              secname, bfd_errmsg(bfd_get_error()));
       return -1;
     }
   }

   return 0;
 }
```

To store sections, `libbfd` uses a data structure called `asection`, also known as `struct bfd_section`. Internally, `libbfd` keeps a linked list of `asection` structures to represent all sections. The loader reserves an `asection*` to iterate over this list ➊.

To iterate over all the sections, you start at the first one (pointed to by `bfd_h->sections`, the head of `libbfd`’s section list) and then follow the `next` pointer contained in each `asection` object ➋. When the `next` pointer is `NULL`, you’ve reached the end of the list.

For each section, the loader first checks whether it should be loaded at all. Since the loader only loads code and data sections, it starts by getting the section flags to check what the type of the section is. To get the flags, it uses `bfd_get_section_flags` ➌. Then, it checks whether either the `SEC_CODE` or `SEC_DATA` flag is set ➍. If not, then it skips this section and moves on to the next. If either of the flags *is* set, then the loader sets the section type for the corresponding `Section` object and continues loading the section.

In addition to the section type, the loader copies the virtual address, size (in bytes), name, and raw bytes of each code or data section. To find the virtual base address of a `libbfd` section, you use `bfd_section_vma` ➎. Similarly, you use `bfd_section_size`➏ and `bfd_section_name` ➐ to get the size and name of the section, respectively. It’s possible that the section has no name, in which case `bfd_section_name` will return `NULL`.

The loader now copies the actual contents of the section into a `Section` object. To accomplish that, it reserves a `Section` in the `Binary` ➑ and copies all the fields it just read. Then, it allocates enough space in the `bytes` member of the `Section` to contain all of the bytes in the section ➒. If the `malloc` succeeds, it copies all the section bytes from the `libbfd` section object into the `Section`, using the `bfd_get_section_contents` function ➓. The arguments it takes are a `bfd` handle, a pointer to the `asection` object of interest, a destination array to contain the section contents, the offset at which to start copying, and the number of bytes to copy into the destination array. To copy all the bytes, the start offset is 0 and the number of bytes to copy is equal to the section size. If the copy succeeds, `bfd_get_section_contents` returns `true`; otherwise, it returns `false`. If all went well, the loading process is now complete!

### 4.4 Testing the Binary Loader

Let’s create a simple program to test the new binary loader. The program will take the name of a binary as input, use the loader to load that binary, and then display some diagnostics about what it loaded. Listing 4-9 shows the code for the test program.

*Listing 4-9:* loader_demo.cc

```
     #include <stdio.h>
     #include <stdint.h>
     #include <string>
     #include "../inc/loader.h"

     int
     main(int argc, char *argv[])
     {
       size_t i;
       Binary bin;
       Section *sec;
       Symbol *sym;
       std::string fname;

       if(argc < 2) {
         printf("Usage: %s <binary>\n", argv[0]);
         return 1;
     }

     fname.assign(argv[1]);
➊   if(load_binary(fname, &bin, Binary::BIN_TYPE_AUTO) < 0) {
       return 1;
     }

➋   printf("loaded binary '%s' %s/%s (%u bits) entry@0x%016jx\n",
           bin.filename.c_str(),
           bin.type_str.c_str(), bin.arch_str.c_str(),
           bin.bits, bin.entry);

➌   for(i = 0; i < bin.sections.size(); i++) {
       sec = &bin.sections[i];
       printf(" 0x%016jx %-8ju %-20s %s\n",
              sec->vma, sec->size, sec->name.c_str(),
              sec->type == Section::SEC_TYPE_CODE ? "CODE" : "DATA");
     }

➍   if(bin.symbols.size() > 0) {
       printf("scanned symbol tables\n");
       for(i = 0; i < bin.symbols.size(); i++) {
         sym = &bin.symbols[i];
         printf(" %-40s 0x%016jx %s\n",
                sym->name.c_str(), sym->addr,
                (sym->type & Symbol::SYM_TYPE_FUNC) ? "FUNC" : "");
       }
     }

➎   unload_binary(&bin);

     return 0;
    }
```

This test program loads the binary given to it as its first argument ➊ and then displays some basic information about the binary such as the filename, type, architecture, and entry point ➋. It then prints the base address, size, name, and type of every section ➌ and finally displays all of the symbols that were found ➍. It then unloads the binary and returns ➎. Try running the `loader_demo` program in the VM! You should see output similar to Listing 4-10.

*Listing 4-10: Example output of the loader test program*

```
$ loader_demo /bin/ls

loaded binary '/bin/ls' elf64-x86-64/i386:x86-64 (64 bits) entry@0x4049a0
  0x0000000000400238 28     .interp                DATA
  0x0000000000400254 32     .note.ABI-tag          DATA
  0x0000000000400274 36     .note.gnu.build-id     DATA
  0x0000000000400298 192    .gnu.hash              DATA
  0x0000000000400358 3288   .dynsym                DATA
  0x0000000000401030 1500   .dynstr                DATA
  0x000000000040160c 274    .gnu.version           DATA
  0x0000000000401720 112    .gnu.version_r         DATA
  0x0000000000401790 168    .rela.dyn              DATA
  0x0000000000401838 2688   .rela.plt              DATA
  0x00000000004022b8 26     .init                  CODE
  0x00000000004022e0 1808   .plt                   CODE
  0x00000000004029f0 8      .plt.got               CODE
  0x0000000000402a00 70281  .text                  CODE
  0x0000000000413c8c 9      .fini                  CODE
  0x0000000000413ca0 27060  .rodata                DATA
  0x000000000041a654 2060   .eh_frame_hdr          DATA
  0x000000000041ae60 11396  .eh_frame              DATA
  0x000000000061de00 8      .init_array            DATA
  0x000000000061de08 8      .fini_array            DATA
  0x000000000061de10 8      .jcr                   DATA
  0x000000000061de18 480    .dynamic               DATA
  0x000000000061dff8 8      .got                   DATA
  0x000000000061e000 920    .got.plt               DATA
  0x000000000061e3a0 608    .data                  DATA
scanned symbol tables
...
  _fini                     0x0000000000413c8c     FUNC
  _init                     0x00000000004022b8     FUNC
  free                      0x0000000000402340     FUNC
  _obstack_memory_used      0x0000000000412960     FUNC
  _obstack_begin            0x0000000000412780     FUNC
  _obstack_free             0x00000000004128f0     FUNC
  localtime_r               0x00000000004023a0     FUNC
  _obstack_allocated_p      0x00000000004128c0     FUNC
  _obstack_begin_1          0x00000000004127a0     FUNC
  _obstack_newchunk         0x00000000004127c0     FUNC
  malloc                    0x0000000000402790     FUNC
```

### 4.5 Summary

In Chapters 1 through 3, you learned all about binary formats. In this chapter, you learned how to load these binaries to prepare them for subsequent binary analysis. In the process, you also learned about `libbfd`, a commonly used library for loading binaries. Now that you have a functioning binary loader, you’re ready to move on to techniques for analyzing binaries. After an introduction to fundamental binary analysis techniques in Part II of this book, you’ll use the loader in Part III to implement your own binary analysis tools.

Exercises

1\. Dumping Section Contents

For brevity, the current version of the `loader_demo` program doesn’t display section contents. Expand it with the ability to take a binary and the name of a section as input. Then dump the contents of that section to the screen in hexadecimal format.

2\. Overriding Weak Symbols

Some symbols are *weak*, which means that their value may be overridden by another symbol that isn’t weak. Currently, the binary loader doesn’t take this into account and simply stores all symbols. Expand the binary loader so that if a weak symbol is later overridden by another symbol, only the latest version is kept. Take a look at */usr/include/bfd.h* to figure out the flags to check for.

3\. Printing Data Symbols

Expand the binary loader and the `loader_demo` program so that they can handle local and global data symbols as well as function symbols. You’ll need to add handling for data symbols in the loader, add a new `SymbolType` in the `Symbol` class, and add code to the `loader_demo` program to print the data symbols to screen. Be sure to test your modifications on a nonstripped binary to ensure the presence of some data symbols. Note that data items are called *objects* in symbol terminology. If you’re unsure about the correctness of your output, use `readelf` to verify it.