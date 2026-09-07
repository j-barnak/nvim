## B IMPLEMENTING PT_NOTE OVERWRITING USING LIBELF

In Chapter 7, you learned how to inject a code section by overwriting the `PT_NOTE` segment at a high level. Here, you’ll see how the `elfinject` tool you’ll find on the virtual machine implements this technique. In the process of describing the `elfinject` source, you’ll also learn about `libelf`, a popular open source library for manipulating the contents of ELF binaries.

I’ll focus on the parts of the code that implement the steps from Figure 7-2 (page 170) using `libelf`, leaving out some parts of the code that are straightforward and don’t involve `libelf`. To learn more, you can find the rest of the `elfinject` source on the virtual machine located in the code directory for Chapter 7.

Be sure to read Section 7.3.2 before reading this appendix, as knowing the inputs and outputs that `elfinject` expects will make the code easier to follow.

In this discussion, I’ll use only the parts of the `libelf` API that `elfinject` uses to give you a good working understanding of the essentials of `libelf`. For more details, refer to the excellent `libelf` documentation or to “`libelf` by Example” by Joseph Koshy.^(1)

### B.1 Required Headers

To parse ELF files, `elfinject` uses the popular open source library `libelf`, which is preinstalled on the virtual machine and is available as a package for most Linux distributions. To use `libelf`, you need to include a few header files, as shown in Listing B-1. You also need to link against `libelf` by providing the `-lelf` option to the linker.

*Listing B-1:* elfinject.c*:* libelf *headers*

```
➊ #include <libelf.h>
➋ #include <gelf.h>
```

For brevity, Listing B-1 doesn’t show all the standard C/C++ headers `elfinject` uses, but only two related to `libelf`. The main one is *libelf.h* ➊, which provides access to all of `libelf`’s data structures and API functions. The other is *gelf.h* ➋, which provides access to `GElf`, a supporting API that provides easier access to some of `libelf`’s functionality. `GElf` allows you to access ELF files in a way that’s transparent to the ELF class and bit width (32-bit versus 64-bit) of the file. The benefit of this will become clear as you see more of the `elfinject` code.

### B.2 Data Structures Used in elfinject

Listing B-2 shows two data structures that are central to `elfinject`. The rest of the code uses these data structures to manipulate the ELF file and the code to inject.

*Listing B-2:* elfinject.c*:* elfinject *data structures*

```
➊ typedef struct {
     int fd;          /* file descriptor */
     Elf *e;          /* main elf descriptor */
     int bits;        /* 32-bit or 64-bit */
     GElf_Ehdr ehdr;  /* executable header */
   } elf_data_t;

➋ typedef struct {
     size_t pidx;     /* index of program header to overwrite */
     GElf_Phdr phdr;  /* program header to overwrite */
     size_t sidx;     /* index of section header to overwrite */
     Elf_Scn *scn;    /* section to overwrite */
     GElf_Shdr shdr;  /* section header to overwrite */
     off_t shstroff;  /* offset to section name to overwrite */
     char *code;      /* code to inject */
     size_t len;      /* number of code bytes */
     long entry;      /* code buffer offset to entry point (-1 for none) */
     off_t off;       /* file offset to injected code */
     size_t secaddr;  /* section address for injected code */
     char *secname;   /* section name for injected code */
   } inject_data_t;
```

The first data structure `elf_data_t` ➊ keeps track of data needed to manipulate the ELF binary in which the new code section is to be injected. It contains a file descriptor for the ELF file (`fd`), a `libelf` handle to the file, an integer denoting the binary’s bit width (`bits`), and a `GElf` handle to the binary’s executable header. I’ll omit the standard C code that opens `fd`, so from this point on, consider `fd` to be opened for reading and writing. I will show the code that opens the `libelf` and `GElf` handles shortly.

The `inject_data_t` structure ➋ tracks information about the code to inject and where and how to inject it in the binary. First, it contains data on which parts of the binary need to be modified to inject the new code. This data includes the index (`pidx`) and `GElf` handle (`phdr`) of the `PT_NOTE` program header to overwrite with the injected header. It also includes the index (`sidx`) and `libelf` and `GElf` handles (`scn` and `shdr`, respectively) of the section to overwrite as well as the file offset to the section name in the string table (`shstroff`) to change to a new name, like `.injected`.

Then comes the actual code to inject in the form of a buffer (`code`) and an integer describing the length of that buffer (`len`). This code is given by the `elfinject` user, so let’s consider `code` and `len` to be set from this point on. The `entry` field is an offset within the `code` buffer, pointing to the code location that should become the new entry point for the binary. If there’s no new entry point, then `entry` is set to `-1` to indicate this.

The `off` field is the file offset in the binary where the new code should be injected. This will point to the end of the binary because that’s where `elfinject` places the new code, as shown in Figure 7-2. Finally, `secaddr` is the load address for the new code section, and `secname` is the name of the injected section. You can consider all the fields from `entry` to `secname` to be set as well, as they’re all user specified except for `off`, which `elfinject` computes when it loads the binary.

### B.3 Initializing libelf

At this point, let’s skip past the `elfinject` initialization code and assume that all initialization succeeded: the user arguments are parsed, a file descriptor to the host binary is opened, and the inject file is loaded into the code buffer in a `struct inject_data_t`. All of this initialization stuff takes place in the `main` function of `elfinject`.

After that, `main` passes control to a function called `inject_code`, which is the starting point for the actual code injection. Let’s take a look at Listing B-3, which shows the part of `inject_code` that opens the given ELF binary in `libelf`. Keep in mind that function names starting with `elf_` are `libelf` functions and names starting with `gelf_` are `GElf` functions.

*Listing B-3:* elfinject.c*:* inject_code *function*

```
   int
   inject_code(int fd, inject_data_t *inject)
   {
➊  elf_data_t elf;
    int ret;
    size_t n;

    elf.fd = fd;
    elf.e = NULL;

➋   if(elf_version(EV_CURRENT) == EV_NONE) {
      fprintf(stderr, "Failed to initialize libelf\n");
      goto fail;
    }

     /* Use libelf to read the file, but do writes manually */
➌   elf.e = elf_begin(elf.fd, ELF_C_READ, NULL);
     if(!elf.e) {
       fprintf(stderr, "Failed to open ELF file\n");
       goto fail;
     }

➍   if(elf_kind(elf.e) != ELF_K_ELF) {
        fprintf(stderr, "Not an ELF executable\n");
        goto fail;
     }

➎   ret = gelf_getclass(elf.e);
     switch(ret) {
     case ELFCLASSNONE:
       fprintf(stderr, "Unknown ELF class\n");
       goto fail;
     case ELFCLASS32:
       elf.bits = 32;
       break;
     default:
       elf.bits = 64;
       break;
     }

   ...
```

An important local variable in the `inject_code` function, `elf` ➊ is an instance of the `elf_data_t` struct type defined previously, and it’s used to store all the important information about the loaded ELF binary to pass to other functions.

Before using any other `libelf` API functions, you must call `elf_version` ➋, which takes the version number of the ELF specification you want to use as its only parameter. If the version is not supported, `libelf` will complain by returning the constant `EV_NONE`, in which case `inject_code` gives up and reports an error initializing `libelf`. If `libelf` doesn’t complain, it means the ELF version requested is supported, and it’s safe to make other `libelf` calls to load and parse the binary.

At the moment, all standard ELF binaries are formatted according to major version 1 of the specification, so this is the only legal value you can pass to `elf_version`. By convention, instead of passing a literal “1” to `elf_version`, you pass the constant value `EV_CURRENT`. Both `EV_NONE` and `EV_CURRENT` are specified in *elf.h*, which is the header that contains all the constants and data structures related to the ELF format, not *libelf.h*. If there’s a major revision of the ELF format, `EV_CURRENT` will be incremented to the next version on systems that use the new ELF version.

After `elf_version` returns successfully, it’s safe to start loading and parsing the binary to inject the new code into. The first step is to call `elf_begin` ➌, which opens the ELF file and returns a handle to it of type `Elf*`. You can pass this handle to other `libelf` functions to perform operations on the ELF file.

The `elf_begin` function takes three parameters: an open file descriptor for the ELF file, a constant that indicates whether to open the file for reading or writing, and a pointer to an `Elf` handle. In this case, the file descriptor is `fd`, and `inject_code` passes the constant `ELF_C_READ` to indicate that it’s interested only in using `libelf` to read the ELF binary. For the final parameter (the `Elf` handle), `inject_code` passes `NULL` so that `libelf` automatically allocates and returns a handle.

Instead of `ELF_C_READ`, you can also pass `ELF_C_WRITE` or `ELF_C_RDWR` to indicate that you want to use `libelf` to write modifications to an ELF binary, or for a combination of read and write operations. For simplicity, `elfinject` only uses `libelf` to parse the ELF file. To write back any modifications, it circumvents `libelf` and simply uses the file descriptor `fd` directly.

After opening an ELF with `libelf`, you’ll typically pass the opened `Elf` handle to `elf_kind` to figure out what kind of ELF you’re dealing with ➍. In this case, `inject_code` compares `elf_kind`’s return value to the constant `ELF_K_ELF` to verify that the ELF file is an executable. The other possible return values are `ELF_K_AR` for ELF archives or `ELF_K_NULL` if an error occurred. In both cases, `inject_code` cannot perform the code injection, so it returns with an error.

Next, `inject_code` uses a `GElf` function called `gelf_getclass` to find out the “class” of the ELF binary ➎. This indicates whether the ELF is 32-bit (`ELFCLASS32`) or 64-bit (`ELFCLASS64`). In case of error, `gelf_getclass` returns `ELFCLASSNONE`. The `ELFCLASS*` constants are defined in *elf.h*. For now, `inject_code` just stores the bit width of the binary (32 or 64) in the `bits` field of the `elf` structure. Knowing the bit width is necessary when parsing the ELF binary.

That covers initializing `libelf` and retrieving basic information about the binary. Now let’s consider the rest of the `inject_code` function, shown in Listing B-4.

*Listing B-4:* elfinject.c*:* inject_code *function (continued)*

```
   ...
   
➊  if(!gelf_getehdr(elf.e, &elf.ehdr)) {
      fprintf(stderr, "Failed to get executable header\n");
      goto fail;
   }
   
   /* Find a rewritable program header */
➋  if(find_rewritable_segment(&elf, inject) < 0) {
     goto fail;
   }
   
   /* Write the injected code to the binary */
➌  if(write_code(&elf, inject) < 0) {
     goto fail;
   }
   
   /* Align code address so it's congruent to the file offset modulo 4096 */
➍  n = (inject->off % 4096) - (inject->secaddr % 4096);
   inject->secaddr += n;
   
   /* Rewrite a section for the injected code */
➎  if((rewrite_code_section(&elf, inject) < 0)
        || ➏(rewrite_section_name(&elf, inject) < 0)) {
       goto fail;
   }
   
   /* Rewrite a segment for the added code section */
➐  if(rewrite_code_segment(&elf, inject) < 0) {
       goto fail;
   }
   
   /* Rewrite entry point if requested */
➑  if((inject->entry >= 0) && (rewrite_entry_point(&elf, inject) < 0)) {
     goto fail;
   }
   
   ret = 0;
   goto cleanup;
   fail:
     ret = -1;
   
   cleanup:
     if(elf.e) {
➒      elf_end(elf.e);
     }
   
     return ret;
   }
```

As you can see, the remainder of the `inject_code` function consists of several major steps, which correspond to the steps outlined in Figure 7-2 as well as some extra low-level steps not shown in the figure:

• Retrieve the binary’s executable header ➊, needed for adjusting the entry point later.

• Find the `PT_NOTE` segment ➋ to overwrite and fail if there is no suitable segment.

• Write the injected code to the end of the binary ➌.

• Adjust the injected section’s load address to meet alignment requirements ➍.

• Overwrite the `.note.ABI-tag` section header ➎ with a header for the new injected section.

• Update the name of the section whose header was overwritten ➏.

• Overwrite the `PT_NOTE` program header ➐.

• Adjust the binary entry point if requested by the user ➑.

• Clean up the `Elf` handle by calling `elf_end` ➒.

I’ll go over these steps in more detail next.

### B.4 Getting the Executable Header

In step ➊ in Listing B-4, `elfinject` gets the binary’s executable header. Recall from Chapter 2 that the executable header contains the file offsets and sizes of these tables. The executable header also contains the binary’s entry point address, which `elfinject` modifies if requested by the user.

To get the ELF executable header, `elfinject` uses the `gelf_getehdr` function. This is a `GElf` function that returns an ELF class-agnostic representation of the executable header. The format of the executable header differs slightly between 32-bit and 64-bit binaries, but `GElf` hides these differences so that you don’t have to worry about them. It’s also possible to get the executable header using only pure `libelf`, without `GElf`. However, in that case, you have to manually call `elf32_getehdr` or `elf64_getehdr` depending on the ELF class.

The `gelf_getehdr` function takes two parameters: the `Elf` handle and a pointer to a `GElf_Ehdr` structure where `GElf` can store the executable header. If all is well, `gelf_getehdr` returns a nonzero value. If there’s an error, it returns 0 and sets `elf_errno`, an error code that you can read by calling `libelf`’s `elf_errno` function. This behavior is standard for all `GElf` functions.

To convert `elf_errno` to a human-readable error message, you can use the `elf_errmsg` function, but `elfinject` doesn’t do this. The `elf_errmsg` function takes the return value of `elf_errno` as input and returns a `const char*` pointing to the appropriate error string.

### B.5 Finding the PT_NOTE Segment

After getting the executable header, `elfinject` loops over all the program headers in the binary to check whether the binary has a `PT_NOTE` segment that’s safe to overwrite (step ➋ in Listing B-4). All of this functionality is implemented in a separate function called `find_rewritable_segment`, shown in Listing B-5.

*Listing B-5:* elfinject.c*: finding the* PT_NOTE *program header*

```
   int
   find_rewritable_segment(elf_data_t *elf, inject_data_t *inject)
   {
     int ret;
     size_t i, n;

➊  ret = elf_getphdrnum(elf->e, &n);
    if(ret != 0) {
       fprintf(stderr, "Cannot find any program headers\n");
       return -1;
   }

➋  for(i = 0; i < n; i++) {
➌    if(!gelf_getphdr(elf->e, i, &inject->phdr)) {
        fprintf(stderr, "Failed to get program header\n");
        return -1;
    }

➍  switch(inject->phdr.p_type) {
    case ➎PT_NOTE:
      ➏inject->pidx = i;
      return 0;
    default:
      break;
    }
   }
➐ fprintf(stderr, "Cannot find segment to rewrite\n");
   return -1;
  }
```

As Listing B-5 shows, `find_rewritable_segment` takes two arguments: an `elf_data_t*` called `elf` and an `inject_data_t*` called `inject`. Recall that these are custom data types, defined in Listing B-2, which contain all the relevant information about the ELF binary and the inject.

To find the `PT_NOTE` segment, `elfinject` first looks up the number of program headers that the binary contains ➊. This is done using a `libelf` function called `elf_getphdrnum`, which takes two arguments: the `Elf` handle and a pointer to a `size_t` integer where the number of program headers will be stored. If the return value is nonzero, it means an error occurred, and `elfinject` gives up because it cannot access the program header table. If there were no errors, `elf_getphdrnum` will have stored the number of program headers in the `size_t` called `n` in Listing B-5.

Now that `elfinject` knows the number of program headers `n`, it loops over each program header to find one of type `PT_NOTE` ➋. To access each program header, `elfinject` uses the `gelf_getphdr` function ➌, which allows you to access program headers in an ELF class-agnostic way. Its arguments are the `Elf` handle, the index number `i` of the program header to get, and a pointer to a `GElf_Phdr` struct (`inject->phdr` in this case) to store the program header in. As is usual for `GElf`, a nonzero return value indicates success, while return value 0 indicates failure.

After this step completes, `inject->phdr` contains the `i`-th program header. All that remains is to inspect the program header’s `p_type` field ➍ and check whether the type is `PT_NOTE` ➎. If it is, `elfinject` stores the program header index in the `inject->pidx` field ➏, and the `find_rewritable_segment` function returns successfully.

If, after looping over all program headers, `elfinject` failed to find a header of type `PT_NOTE`, it reports an error ➐ and exits without modifying the binary.

### B.6 Injecting the Code Bytes

After locating the overwritable `PT_NOTE` segment, it’s time to append the injected code to the binary (step ➌ in Listing B-4). Let’s look at the function that performs the actual inject, which is called `write_code`, as shown in Listing B-6.

*Listing B-6:* elfinject.c*: appending the injected code to the binary*

```
   int
   write_code(elf_data_t *elf, inject_data_t *inject)
   {
     off_t off;
     size_t n;
➊   off = lseek(elf->fd, 0, SEEK_END);
     if(off < 0) {
       fprintf(stderr, "lseek failed\n");
       return -1;
   }

➋  n = write(elf->fd, inject->code, inject->len);
    if(n != inject->len) {
      fprintf(stderr, "Failed to inject code bytes\n");
      return -1;
   }
➌  inject->off = off;

    return 0;
  }
```

Like the `find_rewritable_segment` function you saw in the previous section, `write_code` takes the `elf_data_t*` called `elf` and the `inject_data_t*` called `inject` as its arguments. The `write_code` function doesn’t involve `libelf`; it only uses standard C file operations on `elf->fd`, the file descriptor of the opened ELF binary.

First, `write_code` seeks to the end of the binary ➊. It then appends the injected code bytes there ➋ and saves the byte offset where the code bytes were written into the `inject->off` field of the `inject` data structure ➌.

Now that the code injection is done, all that remains is to update a section and program header (and optionally the binary entry point) to describe the new injected code section and ensure it gets loaded when the binary executes.

### B.7 Aligning the Load Address for the Injected Section

With the injected code bytes appended to the end of the binary, it’s almost time to overwrite a section header to point to those injected bytes. The ELF specification places certain requirements on the addresses of loadable segments and, by extension, the sections they contain. Specifically, the ELF standard requires that for each loadable segment, `p_vaddr` is congruent to `p_offset` modulo the page size, which is 4,096 bytes. The following equation summarizes this requirement:

(*p*\_*vaddr* mod 4096) =  (*p*\_*offset* mod 4096)

Similarly, the ELF standard requires that `p_vaddr` be congruent to `p_offset` modulo `p_align`. Therefore, before overwriting the section header, `elfinject` adjusts the user-specified memory address for the injected section so that it meets these requirements. Listing B-7 shows the code that aligns the address, which is the same code shown in step ➍ in Listing B-4.

*Listing B-7:* elfinject.c*: aligning the load address for the injected section*

```
    /* Align code address so it's congruent to the file offset modulo 4096 */
➊  n = (inject->off % 4096) - (inject->secaddr % 4096);
➋  inject->secaddr += n;
```

The alignment code in Listing B-7 consists of two steps. First, it computes the difference `n` between the injected code’s file offset modulo 4096 and the section address modulo 4096 ➊. The ELF specification requires that the offset and address are congruent modulo 4096 in which case `n` will be zero. To ensure correct alignment, `elfinject` adds `n` to the section address so that the difference with the file offset becomes zero modulo 4096 if it wasn’t already ➋.

### B.8 Overwriting the .note.ABI-tag Section Header

Now that the address for the injected section is known, `elfinject` moves on to overwriting the section header. Recall that it overwrites the `.note.ABI-tag` section header that’s part of the `PT_NOTE` segment. Listing B-8 shows the function that handles the overwrite, called `rewrite_code_section`. It’s called in step ➎ in Listing B-4.

*Listing B-8:* elfinject.c*: overwriting the* .note.ABI-tag *section header*

```
  int
  rewrite_code_section(elf_data_t *elf, inject_data_t *inject)
  {
    Elf_Scn *scn;
    GElf_Shdr shdr;
    char *s;
    size_t shstrndx;

➊   if(elf_getshdrstrndx(elf->e, &shstrndx) < 0) {
      fprintf(stderr, "Failed to get string table section index\n");
      return -1;
    }

    scn = NULL;
➋   while((scn = elf_nextscn(elf->e, scn))) {
➌     if(!gelf_getshdr(scn, &shdr)) {
        fprintf(stderr, "Failed to get section header\n");
        return -1;
       }
➍     s = elf_strptr(elf->e, shstrndx, shdr.sh_name);
      if(!s) {
        fprintf(stderr, "Failed to get section name\n");
        return -1;
      }
➎     if(!strcmp(s, ".note.ABI-tag")) {
➏       shdr.sh_name      = shdr.sh_name;              /* offset into string table */
        shdr.sh_type      = SHT_PROGBITS;               /* type */
        shdr.sh_flags     = SHF_ALLOC | SHF_EXECINSTR;  /* flags */
        shdr.sh_addr      = inject->secaddr;            /* address to load section at */
        shdr.sh_offset    = inject->off;                /* file offset to start of section */
        shdr.sh_size      = inject->len;                /* size in bytes */
        shdr.sh_link      = 0;                          /* not used for code section */
        shdr.sh_info      = 0;                          /* not used for code section */
        shdr.sh_addralign = 16;                         /* memory alignment */
        shdr.sh_entsize   = 0                           /* not used for code section */

➐       inject->sidx = elf_ndxscn(scn);
        inject->scn = scn;
        memcpy(&inject->shdr, &shdr, sizeof(shdr));

➑       if(write_shdr(elf, scn, &shdr, elf_ndxscn(scn)) < 0) {
             return -1;
        }

➒       if(reorder_shdrs(elf, inject) < 0) {
             return -1;
        }

        break;
      }
    }
➓   if(!scn) {
      fprintf(stderr, "Cannot find section to rewrite\n");
      return -1;
     }

     return 0;
   }
```

To find the `.note.ABI-tag` section header to overwrite, `rewrite_code _section` loops over all section headers and inspects the section names. Recall from Chapter 2 that section names are stored in a special section called `.shstrtab`. To read the section names, `rewrite_code_section` first needs the index number of the section header describing the `.shstrtab` section. To get this index, you can read the `e_shstrndx` field of the executable header, or you can use the the function `elf_getshdrstrndx` provided by `libelf`. Listing B-8 uses the latter option ➊.

The `elf_getshdrstrndx` function takes two parameters: an `Elf` handle and a pointer to a `size_t` integer to store the section index in. The function returns 0 on success or sets `elf_errno` and returns −1 on failure.

After getting the index of `.shstrtab`, `rewrite_code_section` loops over all section headers, inspecting each one as it goes along. To loop over the section headers, it uses the `elf_nextscn` function ➋, which takes an `Elf` handle (`elf->e`) and `Elf_Scn*` (`scn`) as input. `Elf_Scn` is a struct defined by `libelf` that describes an ELF section. Initially, `scn` is `NULL`, causing `elf_nextscn` to return a pointer to the first section header at index 1 in the section header table.^(2) This pointer becomes the new value of `scn` and is handled in the loop body. In the next loop iteration, `elf_nextscn` takes the existing `scn` and returns a pointer to the section at index 2, and so on. In this way, you can use `elf_nextscn` to iterate over all sections until it returns `NULL`, indicating that there is no next section.

The loop body handles each section `scn` returned by `elf_nextscn`. The first thing that’s done for each section is to get an ELF class-agnostic representation of the section’s header, using the `gelf_getshdr` function ➌. It works just like `gelf_getphdr`, which you learned about in Section B.5, except that `gelf_getshdr` takes an `Elf_Scn*` and a `GElf_Shdr*` as input. If all goes well, `gelf_getshdr` populates the given `GElf_Shdr` with the section header of the given `Elf_Scn` and returns a pointer to the header. If something goes wrong, it will return `NULL`.

Using the `Elf` handle stored in `elf->e`, the index `shstrndx` of the `.shstrtab` section, and the index `shdr.sh_name` of the current section’s name in the string table, `elfinject` now gets a pointer to the string describing the name of the current section. To that end, it passes all the required information to the `elf_strptr` function ➍, which returns the pointer, or `NULL` in case of error.

Next, `elfinject` compares the just-obtained section name to the string `".note.ABI-tag"` ➎. If it matches, it means the current section is the `.note.ABI-tag` section, and `elfinject` overwrites it as described next and then breaks out of the loop and returns successfully from `rewrite_code_section`. If the section name doesn’t match, the loop moves on to its next iteration to see whether the next section matches.

If the name of the current section is `.note.ABI-tag`, `rewrite_code_section` overwrites the fields in the section header to turn it into a header describing the injected section ➏. As mentioned previously in the high-level overview in Figure 7-2, this involves setting the section type to `SHT_PROGBITS`; marking the section as executable; and filling in the appropriate section address, file offset, size, and alignment.

Next, `rewrite_code_section` saves the index of the overwritten section header, the pointer to the `Elf_Scn` structure, and a copy of the `GElf_Shdr` in the `inject` structure ➐. To get the section’s index, it uses the `elf_ndxscn` function, which takes an `Elf_Scn*` as input and returns the index of that section.

Once the header modifications are complete, `rewrite_code_section` writes the modified section header back into the ELF binary file using another `elfinject` function called `write_shdr` ➑ and then reorders the section headers by section address ➒. I’ll discuss the `write_shdr` function next, skipping the description of `reorder_shdrs`, the function that orders the sections, since it’s not central to understanding the `PT_NOTE` overwriting technique.

As mentioned previously, if `elfinject` succeeds in finding and overwriting the `.note.ABI-tag` section header, it breaks from the main loop iterating over all the section headers and returns successfully. If, on the other hand, the loop completes without finding a header to overwrite, then the inject cannot continue, and `rewrite_code_section` returns with an error ➓.

Listing B-9 shows the code for `write_shdr`, the function responsible for writing the modified section header back to the ELF file.

*Listing B-9:* elfinject.c*: writing the modified section header back to the binary*

```
  int
  write_shdr(elf_data_t *elf, Elf_Scn *scn, GElf_Shdr *shdr, size_t sidx)
  {
    off_t off;
    size_t n, shdr_size;
    void *shdr_buf;

➊   if(!gelf_update_shdr(scn, shdr)) {
      fprintf(stderr, "Failed to update section header\n");
      return -1;
    }

➋   if(elf->bits == 32) {
➌     shdr_buf = elf32_getshdr(scn);
       shdr_size = sizeof(Elf32_Shdr);
    } else {
➍     shdr_buf = elf64_getshdr(scn);
      shdr_size = sizeof(Elf64_Shdr);
    }

    if(!shdr_buf) {
      fprintf(stderr, "Failed to get section header\n");
      return -1;
    }

➎   off = lseek(elf->fd, elf->ehdr.e_shoff + sidx*elf->ehdr.e_shentsize, SEEK_SET);
    if(off < 0) {
      fprintf(stderr, "lseek failed\n");
      return -1;
    }

➏   n = write(elf->fd, shdr_buf, shdr_size);
    if(n != shdr_size) {
      fprintf(stderr, "Failed to write section header\n");
      return -1;
    }

    return 0;
  }
```

The `write_shdr` function takes three parameters: the `elf_data_t` structure called `elf` that stores all the important information needed to read and write the ELF binary, an `Elf_Scn*` (`scn`) and a `GElf_Shdr*` (`shdr`) corresponding to the section to overwrite, and the index (`sidx`) of that section in the section header table.

First, `write_shdr` calls `gelf_update_shdr` ➊. Recall that `shdr` contains new, overwritten values in all the header fields. Because `shdr` is an ELF class-agnostic `GElf_Shdr` structure, which is part of the `GElf` API, writing to it doesn’t automatically update the underlying ELF data structures, `Elf32_Shdr` or `Elf64_Shdr`, depending on the ELF class. Yet those underlying data structures are the ones `elfinject` writes to the ELF binary, so it’s important that they’re updated. The `gelf_update_shdr` function takes an `Elf_Scn*` and a `GElf_Shdr*` as input and writes any changes made to the `GElf_Shdr` back to the underlying data structures, which are part of the `Elf_Scn` structure. The reason `elfinject` writes the underlying data structures to file, and not the `GElf` ones, is that the `GElf` data structures internally use a memory layout that doesn’t match the layout of the data structures in the file, so writing the `GElf` data structures would corrupt the ELF.

Now that `GElf` has written all pending updates back to the underlying native ELF data structures, `write_shdr` gets the native representation of the updated section header and writes it to the ELF file, overwriting the old `.note.ABI-tag` section header. First, `write_shdr` checks the bit width of the binary ➋. If it’s 32 bits, then `write_shdr` calls `libelf`’s `elf32_getshdr` function (passing `scn` to it) to get a pointer to the `Elf32_Shdr` representation of the modified header ➌. For 64-bit binaries, it uses `elf64_getshdr` ➍ instead of `elf32_getshdr`.

Next, `write_shdr` seeks the ELF file descriptor (`elf->fd`) to the offset in the ELF file where the updated header is to be written ➎. Keep in mind that the `e_shoff` field in the executable header contains the file offset where the section header table starts, `sidx` is the index of the header to overwrite, and the `e_shentsize` field contains the size in bytes of each entry in the section header table. Thus, the following formula computes the file offset at which to write the updated section header:

*e*\_*shoff* + *sidx* × *e*\_*shentsize*

After seeking to this file offset, `write_shdr` writes the updated section header to the ELF file ➏, overwriting the old `.note.ABI-tag` header with the new one describing the injected section. By this point, the new code bytes have been injected at the end of the ELF binary and there’s a new code section that contains those bytes, but this section doesn’t yet have a meaningful name in the string table. The next section explains how `elfinject` updates the section name.

### B.9 Setting the Name of the Injected Section

Listing B-10 shows the function that changes the name of the overwritten section, `.note.ABI-tag`, to something more meaningful, such as `.injected`. This is step ➏ in Listing B-4.

*Listing B-10:* elfinject.c*: setting the name of the injected section*

```
  int
  rewrite_section_name(elf_data_t *elf, inject_data_t *inject)
  {
    Elf_Scn *scn;
    GElf_Shdr shdr;
    char *s;
    size_t shstrndx, stroff, strbase;
  
➊   if(strlen(inject->secname) > strlen(".note.ABI-tag")) {
       fprintf(stderr, "Section name too long\n");
       return -1;
    }
  
➋   if(elf_getshdrstrndx(elf->e, &shstrndx) < 0) {
       fprintf(stderr, "Failed to get string table section index\n");
       return -1;
    }
  
    stroff = 0;
    strbase = 0;
    scn = NULL;
➌   while((scn = elf_nextscn(elf->e, scn))) {
➍     if(!gelf_getshdr(scn, &shdr)) {
         fprintf(stderr, "Failed to get section header\n");
         return -1;
      }
➎     s = elf_strptr(elf->e, shstrndx, shdr.sh_name);
       if(!s) {
         fprintf(stderr, "Failed to get section name\n");
         return -1;
      }
  
➏     if(!strcmp(s, ".note.ABI-tag")) {
         stroff = shdr.sh_name;    /* offset into shstrtab */
➐      } else if(!strcmp(s, ".shstrtab")) {
         strbase = shdr.sh_offset; /* offset to start of shstrtab */
       }
    }

➑   if(stroff == 0) {
      fprintf(stderr, "Cannot find shstrtab entry for injected section\n");
      return -1;
    } else if(strbase == 0) {
      fprintf(stderr, "Cannot find shstrtab\n");
      return -1;
    }
  
➒   inject->shstroff = strbase + stroff;
  
➓   if(write_secname(elf, inject) < 0) {
       return -1;
    }
  
    return 0;
  }
```

The function that overwrites the section name is called `rewrite_section _name`. The new name for this injected section cannot be longer than the old name, `.note.ABI-tag`, because all the strings in the string table are packed tightly together with no room for extra added characters. Therefore, the first thing `rewrite_section_name` does is check that the new section name, stored in the `inject->secname` field, will fit ➊. If not, `rewrite_section_name` returns with an error.

The next steps are identical to the corresponding steps in the `rewrite _code_section` function I discussed previously, in Listing B-8: get the index of the string table section ➋ and then loop over all sections ➌ and inspect each section’s header ➍, using the `sh_name` field in the header to obtain a string pointer to the section’s name ➎. For details of these steps, refer to Section B.8.

Overwriting the old `.note.ABI-tag` section name requires two pieces of information: the file offset to the start of the `.shstrtab` section (the string table) and the offset to the `.note.ABI-tag` section’s name within the string table. Given these two offsets, `rewrite_section_name` knows where in the file to write the new section name string. The offset within the string table to the `.note.ABI-tag` section name is stored in the `sh_name` field of the `.note.ABI-tag` section header ➏. Similarly, the `sh_offset` field in the section header contains the start of the `.shstrtab` section ➐.

If all goes well, the loop locates both required offsets ➑. If not, `rewrite _section_name` reports the error and gives up.

Finally, `rewrite_section_name` computes the file offset at which to write the new section name, saving it in the `inject->shstroff` field ➒. It then calls another function, called `write_secname`, to write the new section name to the ELF binary at the just-computed offset ➓. Writing the section name to file is straightforward and requires only standard C file I/O functions, so I omit a description of the `write_secname` function here.

To recap, the ELF binary now contains the injected code, an overwritten section header, and a proper name for the injected section. The next step is to overwrite a `PT_NOTE` program header, creating a loadable segment that contains the injected section.

### B.10 Overwriting the PT_NOTE Program Header

As you may remember, Listing B-5 showed the code that locates and saves the `PT_NOTE` program header to overwrite. All that’s left to do is to overwrite the relevant program header fields and save the updated program header to file. Listing B-11 shows `rewrite_code_segment`, the function that updates and saves the program header. This was called in step ➐ from Listing B-4.

*Listing B-11:* elfinject.c*: overwriting the* PT_NOTE *program header*

```
  int
  rewrite_code_segment(elf_data_t *elf, inject_data_t *inject)
  {
➊   inject->phdr.p_type   = PT_LOAD;          /* type */
➋   inject->phdr.p_offset = inject->off;      /* file offset to start of segment */
    inject->phdr.p_vaddr   = inject->secaddr;  /* virtual address to load segment at */
    inject->phdr.p_paddr   = inject->secaddr;  /* physical address to load segment at */
    inject->phdr.p_filesz  = inject->len;      /* byte size in file */
    inject->phdr.p_memsz   = inject->len;      /* byte size in memory */
➌   inject->phdr.p_flags  = PF_R | PF_X;      /* flags */
➍   inject->phdr.p_align  = 0x1000;           /* alignment in memory and file */

➎   if(write_phdr(elf, inject) < 0) {
       return -1;
    }

    return 0;
  }
```

Recall that the previously located `PT_NOTE` program header is stored in the `inject->phdr` field. Thus, `rewrite_code_segment` starts by updating the necessary fields in this program header: making it loadable by setting `p_type` to `PT_LOAD` ➊; setting the file offset, memory addresses, and size of the injected code segment ➋; making the segment readable and executable ➌; and setting the proper alignment ➍. These are the same modifications shown in the high-level overview in Figure 7-2.

After making the necessary modifications, `rewrite_code_segment` calls another function called `write_phdr` to write the modified program header back to the ELF binary ➎. Listing B-12 shows the code of `write_phdr`. The code is similar to the `write_shdr` function that writes a modified section header to file, which you already saw in Listing B-9, so I’ll focus on the important differences between `write_phdr` and `write_shdr`.

*Listing B-12:* elfinject.c*: writing the overwritten program header back to the ELF file*

```
   int
   write_phdr(elf_data_t *elf, inject_data_t *inject)
   {
     off_t off;
     size_t n, phdr_size;
     Elf32_Phdr *phdr_list32;
     Elf64_Phdr *phdr_list64;
     void *phdr_buf;

➊   if(!gelf_update_phdr(elf->e, inject->pidx, &inject->phdr)) {
       fprintf(stderr, "Failed to update program header\n");
       return -1;
     }

     phdr_buf = NULL;
➋   if(elf->bits == 32) {
➌     phdr_list32 = elf32_getphdr(elf->e);
       if(phdr_list32) {
➍        phdr_buf = &phdr_list32[inject->pidx];
          phdr_size = sizeof(Elf32_Phdr);
       }
     } else {
       phdr_list64 = elf64_getphdr(elf->e);
       if(phdr_list64) {
         phdr_buf = &phdr_list64[inject->pidx];
         phdr_size = sizeof(Elf64_Phdr);
       }
     }
     if(!phdr_buf) {
       fprintf(stderr, "Failed to get program header\n");
       return -1;
     }

➎   off = lseek(elf->fd, elf->ehdr.e_phoff + inject->pidx*elf->ehdr.e_phentsize, SEEK_SET);
     if(off < 0) {
       fprintf(stderr, "lseek failed\n");
       return -1;
    }

➏  n = write(elf->fd, phdr_buf, phdr_size);
    if(n != phdr_size) {
      fprintf(stderr, "Failed to write program header\n");
      return -1;
    }

    return 0;
  }
```

As in the `write_shdr` function, `write_phdr` begins by making sure all modifications to the `GElf` representation of the program header are written back to the underlying native `Elf32_Phdr` or `Elf64_Phdr` data structure ➊. To this end, `write_phdr` calls the `gelf_update_phdr` function to flush the changes to the underlying data structures. This function takes an ELF handle, the index of the modified program header, and a pointer to the updated `GElf_Phdr` representation of the program header. As usual for `GElf` functions, it returns nonzero on success and 0 on failure.

Next, `write_phdr` gets a reference to the native representation of the program header in question (an `Elf32_Phdr` or `Elf64_Phdr` structure depending on the ELF class) to write it to file ➋. Again, this is similar to what you saw in the `write_shdr` function, except that `libelf` doesn’t allow you to directly get a pointer to a particular program header. Instead, you must first get a pointer to the start of the program header table ➌ and then index it to get a pointer to the updated program header itself ➍. To get a pointer to the program header table, you use the `elf32_getphdr` or `elf64_getphdr` function, depending on the ELF class. They both return the pointer on success or `NULL` on failure.

Given the native representation of the overwritten ELF program header, all that remains now is to seek to the correct file offset ➎ and write the updated program header there ➏. That completes all the mandatory steps for injecting a new code section into an ELF binary! The only remaining step is optional: modifying the ELF entry point to point into the injected code.

### B.11 Modifying the Entry Point

Listing B-13 shows the `rewrite_entry_point` function, which takes care of modifying the ELF entry point. It’s called only if requested by the user in step ➑ in Listing B-4.

*Listing B-13:* elfinject.c*: modifying the ELF entry point*

```
   int
   rewrite_entry_point(elf_data_t *elf, inject_data_t *inject)
   {
➊   elf->ehdr.e_entry = inject->phdr.p_vaddr + inject->entry;
➋   return write_ehdr(elf);
  }
```

Recall that `elfinject` allows the user to optionally specify a new entry point for the binary by giving a command line argument that contains an offset into the injected code. The offset specified by the user is saved in the `inject->entry` field. If the offset is negative, it means that the entry point should remain unchanged, in which case `rewrite_entry_point` is never called. Thus, if `rewrite_entry_point` *is* called, `inject->entry` is guaranteed to be nonnegative.

The first thing `rewrite_entry_point` does is update the `e_entry` field in the ELF executable header ➊, previously loaded into the `elf->ehdr` field. Next, it computes the new entry point address by adding the relative offset into the injected code (`inject->entry`) to the base address of the loadable segment that contains the injected code (`inject->phdr.p_vaddr`). Then, `rewrite_entry_point` calls the dedicated function `write_ehdr` ➋, which writes the modified executable header back to the ELF file.

The code of `write_ehdr` is analogous to the `write_shdr` function shown in Listing B-9. The only difference is that it uses `gelf_update_ehdr` instead of `gelf_update_shdr` and `elf32_getehdr`/`elf64_getehdr` instead of `elf32_getshdr`/`elf64_getshdr`.

You now know how to use `libelf` to inject code into a binary, overwrite a section and program header to accommodate the new code, and modify the ELF entry point to jump to the injected code when the binary is loaded! Modifying the entry point is optional, and you may not always want to use the injected code immediately when the binary starts. Sometimes, you’ll want to use the injected code for different reasons, such as substituting a replacement for an existing function. Section 7.4 discusses some techniques for transferring control to the injected code, other than modifying the ELF entry point.