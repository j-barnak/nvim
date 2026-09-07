**Appendix A – Data Types**



Table A.1 contains the set of base types that are used in all UEFI applications and EFI drivers. Use these base types to build more complex unions and structures. The file

EFIBIND.H in the UDK 2010 located on www.tianocore.org contains the code re-quired to map compiler-specific data types to the UEFI data types. If you are using a

new compiler, update only this one file; all other EFI related sources should compile unmodified. Table A.2 contains the modifiers you can use in conjunction with the

UEFI data types.



**Table A.1:** Common EFI Data Types



**Mnemonic Description**



BOOLEAN Logical Boolean. 1-byte value containing a 0 for FALSE or a 1 for TRUE. Other

values are undefined.



INTN Signed value of native width. (4 bytes on IA-32, 8 bytes on Itanium®-based

operations)



UINTN Unsigned value of native width. (4 bytes on IA-32, 8 bytes on Itanium®-based

operations)



INT8 1-byte signed value.



UINT8 1-byte unsigned value.



INT16 2-byte signed value.



UINT16 2-byte unsigned value.



INT32 4-byte signed value.



UINT32 4-byte unsigned value.



INT64 8-byte signed value.



UINT64 8-byte unsigned value.



CHAR8 1-byte Character.



CHAR16 2-byte Character. Unless otherwise specified all strings are stored in the UTF-

16 encoding format as defined by Unicode 2.1 and ISO/IEC 10646 standards.



VOID Undeclared type.



EFI_GUID 128-bit buffer containing a unique identifier value. Unless otherwise speci-

fied, aligned on a 64-bit boundary.



EFI_STATUS Status code. Type INTN.



DOI 10.1515/9781501505690-020

**296** \| Appendix A – Data Types



**Mnemonic Description**



EFI_HANDLE A collection of related interfaces. Type VOID \*.



EFI_EVENT Handle to an event structure. Type VOID \*.



EFI_LBA Logical block address. Type UINT64.



EFI_TPL Task priority level. Type UINTN.



EFI_MAC_ADDRESS 32-byte buffer containing a network Media Access Control address.



EFI_IPv4_ADDRESS 4-byte buffer. An IPv4 Internet protocol address.



EFI_IPv6_ADDRESS 16-byte buffer. An IPv6 Internet protocol address.



EFI_IP_ADDRESS 16-byte buffer aligned on a 4-byte boundary. An IPv4 or IPv6 Internet protocol

address.



\<Enumerated Type\> Element of an enumeration. Type INTN.



sizeof (VOID \*) 4 bytes on supported 32-bit processor instructions.

8 bytes on supported 64-bit processor instructions.



**Table A.2:** Modifiers for Common EFI Data Types



**Mnemonic Description**



IN Datum is passed to the function.



OUT Datum is returned from the function.



OPTIONAL Datum is passed to the function is optional, and a NULL may be passed if

the value is not supplied.



STATIC The function has local scope. This replaces the standard C static key word,

so it can be overloaded for debugging.



VOLATILE Declare a variable to be volatile and thus exempt from optimization to re-

move redundant or unneeded accesses. Any variable that represents a hardware device should be declared as VOLATILE.



CONST Declare a variable to be of type const. This is a hint to the compiler to ena-

ble optimization and stronger type checking at compile time.



EFIAPI Defines the calling convention for EFI interfaces. All EFI intrinsic services

and any member function of a protocol must use this modifier in the func-tion definition.