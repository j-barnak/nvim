**Appendix B – Status Codes**



Most UEFI interfaces return an EFI_STATUS code. Table B.1 lists the status code ranges. Tables B.2, B.3, and B.4 list these codes for success, errors, and warnings, respec-

tively. Error codes also have their highest bit set, so all error codes have negative val-ues. The range of status codes that have the highest bit set and the next to highest bit

clear are reserved for use by UEFI. The range of status codes that have both the high-est bit set and the next to highest bit set are reserved for use by OEMs. Success and

warning codes have their highest bit clear, so all success and warning codes have positive values. The range of status codes that have both the highest bit clear and the

next to highest bit clear are reserved for use by UEFI. The range of status code that have the highest bit clear and the next to highest bit set are reserved for use by OEMs.



**Table B.1:** EFI_STATUS Code Ranges



**IA-32 Range** **Intel® Itanium® Architecture** **Description**

**Range**



0x00000000 0x0000000000000000- Success and warning codes reserved for

- 0x1fffffffffffffff use by UEFI main specification. See Tables 0x1fffffff B.2 and B.4 for valid values in this range.



0x20000000 0x2000000000000000- Success and warning codes reserved for - 0x3fffffffffffffff use by the Platform Initialization Architec-0x3fffffff ture Specification.



0x40000000 0x4000000000000000- Success and warning codes reserved for

- 0x7fffffffffffffff use by OEMs. 0x7fffffff



0x80000000 0x8000000000000000- Error codes reserved for use by the UEFI

- 0x9fffffffffffffff main specification. See Table B.3 for valid 0x9fffffff values for this range.



0xa0000000 0xafffffffffffffff- Error codes reserved for use by the Plat-- 0xbfffffffffffffff form Initialization Architecture Specifica-0xbfffffff tion.



0xc0000000 0xc000000000000000- Error codes reserved for use by OEMs.- 0xffffffffffffffff 0xffffffff



DOI 10.1515/9781501505690-021

**298** \| Appendix B – Status Codes



**Table B.2:** EFI_STATUS Success Codes (High Bit Clear)



**Mnemonic** **Value Description**



EFI_SUCCESS 0 The operation completed successfully.



**Table B.3:** EFI_STATUS Error Codes (High Bit Set)



**Mnemonic** **Value Description**



EFI_LOAD_ERROR 1 The image failed to load.



EFI_INVALID_PARAMETER 2 A parameter was incorrect.



EFI_UNSUPPORTED 3 The operation is not supported.



EFI_BAD_BUFFER_SIZE 4 The buffer was not the proper size for the request



EFI_BUFFER_TOO_SMALL 5 The buffer is not large enough to hold the re-

quested data. The required buffer size is re-

turned in the appropriate parameter when this

error occurs.



EFI_NOT_READY 6 There is no data pending upon return.



EFI_DEVICE_ERROR 7 The physical device reported an error while at-

tempting the operation.



EFI_WRITE_PROTECTED 8 The device cannot be written to.



EFI_OUT_OF_RESOURCES 9 A resource has run out.



EFI_VOLUME_CORRUPTED 10 An inconsistency was detected on the file system

causing the operation to fail.



EFI_VOLUME_FULL 11 The file system has no more space.



EFI_NO_MEDIA 12 The device does not contain any medium to per-

form the operation.



EFI_MEDIA_CHANGED 13 The medium in the device has changed since the

last access.



EFI_NOT_FOUND 14 The item was not found.



EFI_ACCESS_DENIED 15 Access was denied.



EFI_NO_RESPONSE 16 The server was not found or did not respond to

the request.

**Fehler! Kein Text mit angegebener Formatvorlage im Dokument.** \| **299**



**Mnemonic** **Value Description**



EFI_NO_MAPPING 17 A mapping to a device does not exist.



EFI_TIMEOUT 18 The timeout time expired.



EFI_NOT_STARTED 19 The protocol has not been started.



EFI_ALREADY_STARTED 20 The protocol has already been started.



EFI_ABORTED 21 The operation was aborted.



EFI_ICMP_ERROR 22 An ICMP error occurred during the network oper-

ation.



EFI_TFTP_ERROR 23 A TFTP error occurred during the network opera-

tion.



EFI_PROTOCOL_ERROR 24 A protocol error occurred during the network op-

eration.



EFI_INCOMPATIBLE_VERSION 25 The function encountered an internal version

that was incompatible with a version requested

by the caller.



EFI_SECURITY_VIOLATION 26 The function was not performed due to a security

violation.



EFI_CRC_ERROR 27 A CRC error was detected.



EFI_END_OF_MEDIA 28 Beginning or end of media was reached.



EFI_END_OF_FILE 31 The end of the file was reached.



EFI_INVALID_LANGUAGE 32 The language specified was invalid.

**300** \| Appendix B – Status Codes



**Table B.4:** EFI_STATUS Warning Codes (High Bit Clear)



**Mnemonic** **Value Description**



EFI_WARN_UNKNOWN_GLYPH 1 The Unicode string contained one or more

characters that the device could not render

and were skipped.



EFI_WARN_DELETE_FAILURE 2 The handle was closed, but the file was not

deleted.



EFI_WARN_WRITE_FAILURE 3 The handle was closed, but the data to the

file was not flushed properly.



EFI_WARN_BUFFER_TOO_SMALL 4 The resulting buffer was too small, and the

data was truncated to the buffer size.