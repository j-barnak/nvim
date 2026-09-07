**Index**



ACPI 3, 60, 67, 68, 69, 78, 105, 108, 117, 179, – optimized 13, 38, 241, 247, 255

197, 247, 258, 261, 266, 271, 272, 278, – EFI Boot Services Table 115, 118

279 – target 216, 227, 240, 244, 254, 271 Allocate Buffer 144, 146 – variables 11, 16, 193 API 21, 48, 59, 62, 69, 89, 107, 109, 154, 166, Boot Device Selection (BOS) ix, 106, 112, 127,

230, 276, 279 138, 184, 194 Applications 15, 24, 25, 47, 74, 107, 127, 131, – phase 183

132, 160, 185, 235, 254, 262, 271, 278, 285 Boot Firmware Volume (BFV) 197, 206, 213

Architectural Protocols (APs) 3, 102, 112, 116, – Processor Abstraction Layer (PAL) 67, 220,

124, 132, 136 272 – CPU Architectural Protocol 116, 133 – UEFI PI architecture 258 – Driver Execution Environment (DXE) viii, 3, Boot Mode

10, 30, 97, 111, 122, 132, 166, 180, 195, – sleep state 197, 221

209, 222, 240, 248 Bus – Metronome Architectural Protocol 116, 118 – driver 22, 25, 31, 38, 139, 147, 180 – Real Time Clock Architectural Protocol 117,

119, 135 Cache-as-RAM (CAR) 222 – Reset Architectural Protocol 117, 119, 134, Central Processing Unit (CPU) 15, 97

136 Configuration Access Protocol 153, 156 – Security Architectural Protocol 116, 118, 124 Configuration Table 56, 69, 117 – Timer Architectural Protocol 102, 116, 118, Console

135, 138 – devices 38, 53, 83, 94, 117, 126 – Variable Architectural Protocol 116, 119, – services 60, 81, 88, 94, 104

138 Consumer Electronics (CE) Device – Watchdog Timer Architectural Protocol 116, – firmware 259, 286

118, 138 Controlled Data Items (CDis) 180 ASCII 81, 85, 89, 190 Controllers Attributes – Host Bus Controllers 33, 140 – Firmware Boot Manager 76, 185 Coreboot 108, 222 – Authenticode 47, 170 CPU Architectural Protocol 116, 133, 135

CRC 135, 138, 299

BIOS 271, 278, 283, 286

– evolution vi, 3, 12, 21, 48, 67, 75, 107, 160 Dependency Expression 113, 124, 128, 138, Block I/0 Protocol 36, 107, 129, 147 214 Boolean Expression 276 Device Drivers 25, 31, 144, 154, 254, 271 Boot Device Handle 22, 32, 57, 140, 155 – Devices 161, 257 Device Path Protocol 25, 34, 43, 56, 143 – Firmware 198, 203, 209, 253 Distributed Management Task Force (DMTF) – flow 2, 10, 157, 167, 195, 211, 248, 264 271, 285 – Loader 26, 48, 125, 184, 255 Driver Binding Protocol 24, 31, 39, 52, 127 – manager 26, 38, 48, 76, 169, 183 Driver Execution Environment (DXE) viii, 111, – mode 196, 203, 215, 223 211 – network booting 175, 193 – components 107, 121, 221 – performance 237, 241, 244, 247, 250 – core 111, 127, 179 – boot media 193, 244 – dispatcher 112, 116, 119, 128 – marketing requirements 237, 243, 246 – drivers 3, 97, 106, 112, 124, 136, 203, 222 **302** \| Index



– Foundation 102, 133, 138, 210 Hand-Off Block (HOB) 114 – handoff with Pre-EFI Initialization (PEI) 214 Handle 16, 32, 40, 56, 83, 113, 135, 208, 234, – initial program load (IPL) 218, 253, 258, 270, 289

266 – driver image 22, 32 – phase 111, 125, 167, 199, 210, 216 Handle Database 25, 114, 125 – services table 116, 119 Hand-Off Block (HOB) 112, 115, 214 Drivers 3, 98, 106, 114, 124, 138, 203, 222 – list 114, 133, 147, 184, 190, 208, 255, 290 – DXE 3, 125 Host-Bus Adapter (HBA) viii, 11, 23, 47, 173 – PCI 3, 22, 34, 47, 98, 105, 139, 223, 247, Host Bus Controllers 31, 140

260 Hot Plug Events 31, 38, 140 – UEFI 26, 53

DXE Foundation 102, 133, 221 Image Handle 22, 32 Dynamic RAM (DRAM) 100, 223, 261 Input/Output (1/0) 104

– text 1/0 83, 89, 94

EFI Runtime Services Table 16, 69, 115, 136 Intel® Active Management Technology (Intel Elevation of Privilege 180 AMT) 277, 283 Embedded Operating Systems 13, 268 – System on a Chip (SoC) 108, 254 – errors 269, 272, 274, 280, 286, App B Imel® Core iT"M processor 120, 123 – UEFI Not Ready error 85 Intelligent Platform Management Interface Event and Timer Services 85, 118 (IPMI) 90, 270, 281 Events Internet Small Computer Systems Interface

– Hot Plug 21, 32, 40, 46 (iSCSI) 49, 90 Extensible Firmware Interface (EFI) 1, 5, 14, Itanium 3, 23, 97, 107, 197, 204, 220, 223,

31, 53, 157 370, 278, 287, App A – Driver Execution Environment (DXE) viii,

111, 209 Key/Value Pairs 92 – system table 16, 53, 60, 73, 82, 93, 113, 215

Lakeport 123

FFS 115, 213

Firmware 1, 9, 26, 48, 73, 84, 99, 142, 157, Map 28, 54, 61, 73, 97, 118, 133, 144, 167,

169, 197, 221, 249, 261, 287 254, App A Firmware Boot Manager 76, 185 Miscellaneous Services 78 Firmware Volume (FV) 105, 122, 171, 198, 249 Module Development Environment (MOE) 223 Flush 134, 145, 300 MPS tables 69, 114 Function Prototype 69, 73 Multiprocessor 3, 27, 220, 260 Functions

– Allocate Buffer 1, 144, 146 Network Console 93 – Close 42, 58, 94, 118, 152, 231 Networking – Flush 134, 145, 300 UEFI drivers 9, 16, 23, 48, 52, 132, 179, 188, – Get Timer Period 136, 139 222 – Map 180, 183 Network Interface Controller 94 – Media 186 NT32 Platform 102, 114, 228 – Mem 28, 55, 61, 97, 122, 145, 161, 227, 252, emulation 81, 97, 227, 236

299 limitations 3, 227 – Set Variable 180, 278 WinNtThunk capability 290, 294, 295

NULL Interface Pointer 135, 138

Global Coherency Domain Services 120

GUID 4, 16, 39, 69, 113, 187, 207, 276, 296 Open Firmware 5, 114

Original Equipment Manufacturers (OEMs) 31

Index \| **303**



OS Kernel 55, 60, 186, 272 Preboot eXecution Environment (PXE) BIOS OS Loader 10, 21, 55, 61, 74, 82, 166, 179, 193

193, 248, 266 Pre-EFI Initialization (PEI) viii, 111, 209 OS Partition 55, 185 – Dispatcher 112, 202, 221 Output Devices viii, 76, 82, 189 – Foundation 3, 102, 133, 196, 213

– Hand-Off Block (HOB) list 114

Partition viii, 3, 11, 47, 147, 171, 187, 255 – PEI-to DXE handoff 217 PC 3, 12, 89, 99, 129, 161, 166, 187, 253, 258, – modules (PEIMs) 99, 210

268, 285 – operation 2, 24, 48, 68, 101, 145, 168, 200, PCI. See Peripheral Component Interconnect 257

(PCI) 22, 33, 47, 105, 131, 139, 223, 247, PEIM-to-PEIM interface (PPI) 100, 207

260, 273 – phase 112, 167, 196, 226, 257 PCI Protocols 132, 140, 146 Pre-operating system (pre-OS) agents 15 PCI Host Bridge Resource Allocation Protocol Priori File 113, 123, 128

140 Protocols Peripheral Component Interconnect (PCI) 31, – Device Path Protocol 25, 34, 44, 59, 144

142 – Driver Binding Protocol 25, 33, 40, 127 – bus drivers 25, 31 Pseudo code 41 – buses 3, 20, 32, 52, 139, 164, 202, 208

– base address registers 145 Real Time Clock – host bus controllers 31, 139 – architectural protocols (APs) 102 – host buses 33, 143 – services 1, 16, 41, 57, 84, 152, 210, 264 – memory space 120, 133, 141, 146 Repudiation 180 – n host bridges 174 Reset – root bridges 25, 139, 144 – architectural protocols (APs) 102 – segments 142, 253, 257, 283

Platform components 4, 38, 111, 278 Samples Platform Controller Hub (PCH) 100 – application 11, 22, 55, 128, 153, 201, 235, Platform Driver Override Protocol 38 254, 287 Platform Error Reporting – OS loader 10, 21, 55, 74, 166, 266 – in-band errors 270, 286 System configuration 16, 56, 118, 275 – intelligent platform management interface Scan Codes 81, 84, 90

(IPMI) 270, 281 Security ix, 8, 47, 105, 119, 158, 178, 210, 254 – out-of-band errors 270, 282, 286 – User Identity (UID) infrastructure 47, 299 Platform Firmware 13, 38, 53, 60, 77, 82, 97, Simple File System Protocol 132, 150, 191

160, 184, 194, 207, 238, 274 Smart phone 97, 254 – initialization 1, 16, 30, 71, 83, 100, 127, 154, SMBIOS 3, 60, 69, 117, 286, 243, 179

186, 210, 238, 259, 297 S-State Boot Path 199 Platform Initialization (PI) 1, 30, 97, 157, 209 Status Code architectural protocols (APs) 102 – Specification ix, 111 System Address Map 97 – Unified Extensible Firmware Interface (UEFI) System Management Bus (SMBUS) 100, 223,

274, 278 226 Platform Manufacturer (PM) 11, 158, 178, 266 System Management Mode (SMM) 3, 179 Platform Security 158, 176, 265 System Memory descriptors 61, 73, 115, 147 – architecture viii, 5, 16, 30, 99, 159, 192, 254 System Table 15, 53, 74, 82, 113 Portable Executable/Common File Format (PE/ Extensible Firmware Interface (EFI) 5, 14, 32,

COFF) 32, 160, 222 54, 157 – Driver Execution Environment (DXE) drivers

47

**304** \| Index



Tablet 97 Unified Extensible Firmware Interface (UEFI)

Tampering 227 applications 10, 16, 24, 62, 94, 184, 222,

Telnet 94, 129 295 Terse Executable 222 architecture 13, 20, 30, 247 Text Interface 82, 89 – BIOS 258, 270 Thunk Protocol 233 – boot manager 33, 38, 184, 189 Timer Architectural Protocol 102, 116, 136 – boot services 16, 55, 63, 82, 116, 147, 158, – architectural protocols (APs) 3, 101, 114, 193

127, 210 – components 23, 73, 103, 130 Translation Look-up Blocks (TLB) 27 – configuration infrastructure 7, 149, 289 Trusted Building Block (TBB) 162, 168 – configuration table 69, 73 Trusted Computing Group (TCG) 21, 160 – driver model viii, 25, 32, 44, 126, 154 Trusted Platform Module (T PM) 21, 106, 160, – drivers 9, 15, 26, 47, 105, 131, 179, 188, 222

167, 181, 265 – firmware 16, 69, 171, 185, 193, 228, 238 – CRTM 163, 181, 265 – root-of-trust-for-verification (RTV) 170 – DRTM 163, 177 – GUID 4, 16, 30, 40, 69, 73, 113, 125, 150, – measured boot 12, 160, 257, 264 187, 207, 276, 287 – PCR 164, 266 – memory 15, 32, 66, 80, 98, 133, 190, 219, – platform configuration registers (PCRs) 241, 260, 278

164, 168 – Platform Initialization (PI) ix, 1, 30, 71, 126, – RTM 163, 167 157, 209, 238, App B – SRTM 163, 177 – Components 3, 13, 32, 73, 84, 94, 129, 139, – UEFI Apis 3, 55, 166, 175 168, 181, 199, 223, 234, 247, 264, 270 – layering 8, 52, 82, 91, 105, 148, 291 – flash file system 212, 221

– pre-operating system (pre-OS) agents 1, 16,

UCST - UEFI Configuration Sub-team 7 23, 48, 54, 81, 246, 257 UEFI API 3, 55, 108, 166, 234, 278, 291 – protocols 3, 16, 30, 52, 82, 89, 102, 127, UEFI Application Toolkit 20, 291 152, 159, 210, 267, 286 UEFI Boot Manager 33, 184, 189 – security 8, 47, 105, 116, 124, 159, 176, 210, UEFI Development Kit (UDK) 4 262, 284, 294 UEFI Error Format Standardization 272 – boot 16, 24, 38, 66, 82, 116, 148, 184, 194 – Windows Hardware Error Architecture (WHEA) – console 53, 82, 93

271, 277 – runtime 2, 16, 27, 63, 74, 179 UEFI Forum 3, 7 – specifications 164 UEFI Image 15, 22, 112, 166, 185, 192 – system table 15, 23, 53, 63, 73, 93, 115, 118 – types 9, 15, 21, 28, 39, 66, 79, 89, 98, 120, Universal Network Driver Interface (UN DI) 27,

152, 170, 256, 270 32, 96 UEFI OS loaders 67, 74, 82, 179

UEFI runtime services table 16, 69 Variable architectural 96, 116, 138 UEFI Secure Boot 17, 169, 181 – architectural protocols (APs) 3, 101, 115, UEFI Shell 7, 26, 54, 105, 234 118, 127, 210 UEFI Simple Text Input 81 – environment 2, 15, 30, 40, 55, 74, 80, 98, UEFI Simple Text Input Ex 82 118, 138, 150, 177, 186, 210, 229, 257, 263 UEFI Simple Text Output 81, 88 – firmware boot manager 76, 185 UEFI Specification 2, 8, 16, 71, 90, 164, 188, – load option 185

247, 276, 291 – nonvolatile 55, 74, 80, 138, 154, 190, 220 Unicode Characters 82, 86 – NVRAM 184

– services 1, 10, 25, 35, 48, 63, 75, 88, 103,

113, 152, 189, 210, 244, 264, 284

Index \| **305**



Variable Write 117, 138 Web Services Management Protocol 285 – architectural protocols (APs) 3, 101, 114, Windows Hardware Error Architecture (WHEA)

127, 138 271, 277 Virtual Address 27, 67, 73, 80, 118 WinNtThunk Capability 230 Virtual Memory Services 72, 118

VT-100 89, 129