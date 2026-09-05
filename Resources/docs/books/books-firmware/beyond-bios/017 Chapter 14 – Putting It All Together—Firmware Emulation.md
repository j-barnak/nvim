## **Chapter 14 – Putting It All Together—Firmware** 

 

**Emulation**

 

An expert is a man who has made all the mistakes which can be made in a very narrow field.

 

—Niels Bohr

 

In the preceding chapters, various stages of the firmware initialization process were described. In addition, various possible usage models have been described that can

be implemented on a target hardware platform. By now it should have become evi-

dent that many of the UEFI firmware interfaces do not in and of themselves talk di-rectly to hardware; instead they actually talk to underlying components that are re-sponsible for talking to hardware. Traditionally, firmware development has not been

an activity that could be performed without an in-circuit emulator (ICE) or other hard-ware debug facility. Taking into consideration UEFI’s design and the fact that very

few components in the firmware actually have direct interaction with hardware de-vices, it is possible to introduce a mechanism that allows the emulation of vast

amounts of the firmware in a standard deployment operation system environment.

In the UEFI sample implementation, a new target platform was introduced called

NT32. This environment features the ability to run much of the firmware code as an application running from the operating system, and provides the ability to establish

a robust development and debug environment. Much of the firmware codebase was developed initially using the emulation environment with off-the-shell compilers and

debuggers, and without the need of a real hardware debugger. Of course, this emula-tion has its limitations, since some components of the firmware must talk to hard-

ware. It is much more difficult to emulate such components, though later in this chap-ter, some possibilities are discussed to alleviate some of this issue. Figure 14.1 shows

an example of a firmware emulation environment running the UEFI shell within an operating system context.

 

DOI 10.1515/9781501505690-016

**228** \| Chapter 14 – Putting It All Together—Firmware Emulation

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-247_1.png)

 

**Figure 14.1:** An Emulation Environment Contained within an Operating System Environment

 

**Virtual Platform**

 

This NT32 platform can be described as a hardware-agnostic platform in that it uses operating system APIs for its primary hardware abstractions. Figure 14.2 shows how the firmware emulation environment gets launched. It is part of a normal boot pro-

cess, and will essentially launch a firmware emulation environment as an application running from the operating system. For most developers, this simply means launch-

ing a standard platform, loading an operating system, and then building and execut-ing the NT32 emulation environment as a native operating system application. This

application effectively executes the firmware that was built, and emulates the launch of a new system.

Virtual Platform \| **229**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-248_1.png)

 

**Figure 14.2:** The Normal Boot Process Launching an Operating System that Will Launch the Emula-tion Environment

 

In Figure 14.3, the timeline is actually intended to illustrate the emulated firmware

timeline. It has the capability of processing all of the firmware evolution stages, yet of course certain operations are emulated due to lack of direct hardware initialization.

An example would be the direct initialization of memory, which would be somewhat different in this environment, whereas in a real platform, this process would be much

more involved.

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-248_2.png)

 

**Figure 14.3:** The Firmware Emulation Environment Itself

**230** \| Chapter 14 – Putting It All Together—Firmware Emulation

 

**Emulation Firmware Phases**

 

It should be noted that the emulation environment has several distinct phases:

■ Establishing a WinNtThunk capability for the emulation environment. ■ This phase constructs a means by which firmware components can make refer-

ence to some “hardware” components. This is done by associating firmware-vis-

ible constructs that will then be associated with operating system native API

calls.

■ Figure 14.4 is an example where several firmware constructs are being associated

with operating system native APIs. For example, to create a file, we establish a

firmware calling mechanism (such as WinNtCreateFile) to call an operating sys-

tem API known as CreateFile. The following examples illustrate a mechanism of

associating firmware calls to Windows APIs, but this could just as easily happen

for any underlying operation system.

 

typedef struct {

UINT64 Signature;

 

//

// Win32 Process APIs

//

WinNtGetProcAddress GetProcAddress; WinNtGetTickCount GetTickCount; WinNtLoadLibraryEx LoadLibraryEx; WinNtFreeLibrary FreeLibrary;

WinNtSetPriorityClass SetPriorityClass; WinNtSetThreadPriority SetThreadPriority; WinNtSleep Sleep;

WinNtSuspendThread SuspendThread; WinNtGetCurrentThread GetCurrentThread; WinNtGetCurrentThreadId GetCurrentThreadId; WinNtGetCurrentProcess GetCurrentProcess; WinNtCreateThread CreateThread; WinNtTerminateThread TerminateThread; WinNtSendMessage SendMessage;

WinNtExitThread ExitThread;

WinNtResumeThread ResumeThread; WinNtDuplicateHandle DuplicateHandle;

 

//

// Wint32 Mutex primitive

//

WinNtInitializeCriticalSection InitializeCriticalSection; WinNtEnterCriticalSection EnterCriticalSection; WinNtLeaveCriticalSection LeaveCriticalSection; WinNtDeleteCriticalSection DeleteCriticalSection; WinNtTlsAlloc TlsAlloc;

Virtual Platform \| **231**

 

WinNtTlsFree TlsFree;

WinNtTlsSetValue TlsSetValue;

WinNtTlsGetValue TlsGetValue;

WinNtCreateSemaphore CreateSemaphore; WinNtWaitForSingleObject WaitForSingleObject; WinNtReleaseSemaphore ReleaseSemaphore;

 

//

// Win32 Console APIs

//

WinNtCreateConsoleScreenBuffer CreateConsoleScreenBuffer; WinNtFillConsoleOutputAttribute FillConsoleOutputAttribute; WinNtFillConsoleOutputCharacter FillConsoleOutputCharacter; WinNtGetConsoleCursorInfo GetConsoleCursorInfo; WinNtGetNumberOfConsoleInputEvents GetNumberOfConsoleInputEvents; WinNtPeekConsoleInput PeekConsoleInput; WinNtScrollConsoleScreenBuffer ScrollConsoleScreenBuffer; WinNtReadConsoleInput ReadConsoleInput; WinNtSetConsoleActiveScreenBuffer SetConsoleActiveScreenBuffer; WinNtSetConsoleCursorInfo SetConsoleCursorInfo; WinNtSetConsoleCursorPosition SetConsoleCursorPosition; WinNtSetConsoleScreenBufferSize SetConsoleScreenBufferSize; WinNtSetConsoleTitleW SetConsoleTitleW; WinNtWriteConsoleInput WriteConsoleInput; WinNtWriteConsoleOutput WriteConsoleOutput;

 

//

// Win32 File APIs

//

WinNtCreateFile CreateFile;

WinNtDeviceIoControl DeviceIoControl; WinNtCreateDirectory CreateDirectory; WinNtRemoveDirectory RemoveDirectory; WinNtGetFileAttributes GetFileAttributes; WinNtSetFileAttributes SetFileAttributes; WinNtCreateFileMapping CreateFileMapping; WinNtCloseHandle CloseHandle;

WinNtDeleteFile DeleteFile;

WinNtFindFirstFile FindFirstFile; WinNtFindNextFile FindNextFile; WinNtFindClose FindClose;

WinNtFlushFileBuffers FlushFileBuffers; WinNtGetEnvironmentVariable GetEnvironmentVariable; WinNtGetLastError GetLastError; WinNtSetErrorMode SetErrorMode; WinNtGetStdHandle GetStdHandle; WinNtMapViewOfFileEx MapViewOfFileEx; WinNtReadFile ReadFile;

WinNtSetEndOfFile SetEndOfFile; WinNtSetFilePointer SetFilePointer; WinNtWriteFile WriteFile;

WinNtGetFileInformationByHandle GetFileInformationByHandle; WinNtGetDiskFreeSpace GetDiskFreeSpace;

**232** \| Chapter 14 – Putting It All Together—Firmware Emulation

 

WinNtGetDiskFreeSpaceEx GetDiskFreeSpaceEx; WinNtMoveFile MoveFile;

WinNtSetFileTime SetFileTime;

WinNtSystemTimeToFileTime SystemTimeToFileTime;

 

//

// Win32 Time APIs

//

WinNtFileTimeToLocalFileTime FileTimeToLocalFileTime; WinNtFileTimeToSystemTime FileTimeToSystemTime; WinNtGetSystemTime GetSystemTime; WinNtSetSystemTime SetSystemTime; WinNtGetLocalTime GetLocalTime; WinNtSetLocalTime SetLocalTime; WinNtGetTimeZoneInformation GetTimeZoneInformation; WinNtSetTimeZoneInformation SetTimeZoneInformation; WinNttimeSetEvent timeSetEvent; WinNttimeKillEvent timeKillEvent;

 

//

// Win32 Serial APIs

//

WinNtClearCommError ClearCommError; WinNtEscapeCommFunction EscapeCommFunction; WinNtGetCommModemStatus GetCommModemStatus; WinNtGetCommState GetCommState; WinNtSetCommState SetCommState; WinNtPurgeComm PurgeComm;

WinNtSetCommTimeouts SetCommTimeouts;

 

WinNtExitProcess ExitProcess;

WinNtSprintf SPrintf;

WinNtGetDesktopWindow GetDesktopWindow; WinNtGetForegroundWindow GetForegroundWindow; WinNtCreateWindowEx CreateWindowEx; WinNtShowWindow ShowWindow;

WinNtUpdateWindow UpdateWindow; WinNtDestroyWindow DestroyWindow; WinNtInvalidateRect InvalidateRect; WinNtGetWindowDC GetWindowDC;

WinNtGetClientRect GetClientRect; WinNtAdjustWindowRect AdjustWindowRect; WinNtSetDIBitsToDevice SetDIBitsToDevice; WinNtBitBlt BitBlt;

WinNtGetDC GetDC;

WinNtReleaseDC ReleaseDC;

WinNtRegisterClassEx RegisterClassEx; WinNtUnregisterClass UnregisterClass;

 

WinNtBeginPaint BeginPaint;

WinNtEndPaint EndPaint;

WinNtPostQuitMessage PostQuitMessage; WinNtDefWindowProc DefWindowProc;

Virtual Platform \| **233**

 

WinNtLoadIcon LoadIcon;

WinNtLoadCursor LoadCursor;

WinNtGetStockObject GetStockObject; WinNtSetViewportOrgEx SetViewportOrgEx; WinNtSetWindowOrgEx SetWindowOrgEx; WinNtMoveWindow MoveWindow;

WinNtGetWindowRect GetWindowRect; WinNtGetMessage GetMessage;

WinNtTranslateMessage TranslateMessage; WinNtDispatchMessage DispatchMessage; WinNtGetProcessHeap GetProcessHeap; WinNtHeapAlloc HeapAlloc;

WinNtHeapFree HeapFree;

} EFI_WIN_NT_THUNK_PROTOCOL;

 

**Figure 14.4:** Thunk Protocol that Associates Some Firmware Names with Operating System APIs

 

■ Construct an UEFI hardware API handler that will be specific to the emulation

platform.

■ In Figure 14.5, the EFI_SERIAL_IO_PROTOCOL interface is being seeded with a

variety of information associated with platform specific function data. In this

case, these platform-specific functions are tuned to the emulation environment.

 

SerialIo.Revision = SERIAL_IO_INTERFACE_REVISION; SerialIo.Reset = WinNtSerialIoReset; SerialIo.SetAttributes = WinNtSerialIoSetAttributes; SerialIo.SetControl = WinNtSerialIoSetControl; SerialIo.GetControl = WinNtSerialIoGetControl; SerialIo.Write = WinNtSerialIoWrite; SerialIo.Read = WinNtSerialIoRead;

SerialIo.Mode = SerialIoMode;

 

**Figure 14.5:** Establishing an UEFI API to Call Platform-Specific Operations

 

■ Platform-specific functions (such as emulation platform) that are handling the

calls to UEFI interfaces and in turn will call the established WinNtThunk APIs

that will end up making operating specific API calls.

 

Figure 14.6 features several calls that could occur from within an API handler to ac-complish several tasks.

**234** \| Chapter 14 – Putting It All Together—Firmware Emulation

 

//

// Example of reading from a file

//

Result = WinNtThunk-\>ReadFile (

NtHandle,

Buffer,

(DWORD)\*BufferSize,

&BytesRead,

NULL

);

 

//

// Example of resetting a serial device

//

WinNtThunk-\>PurgeComm (

NtHandle,

PURGE_TXCLEAR \| PURGE_RXCLEAR

);

//

// Example of getting local time components //

WinNtThunk-\>GetLocalTime (&SystemTime);

WinNtThunk-\>GetTimeZoneInformation (&TimeZone);

 

**Figure 14.6:** Example Calls to the WinNtThunk Protocol

 

In summary, Figure 14.7 shows the software logic contained within the operating sys-

tem, firmware emulation component, and their associated interaction logic. It should be noted that this logical software flow has three primary components:

■ Firmware component under development ■ Basic firmware codebase

■ Firmware-to-Operating System thunk code

Hardware Pass-Through \| **235**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-254_1.png)

 

**Figure 14.7:** Firmware Emulation Software Logic Flow

 

**Hardware Pass-Through**

 

As is evident through the previous examples, the underlying firmware can enable calling to several operating system APIs. However, since the firmware emulation en-

vironment is essentially an operating system application, certain functions are not

going to be available. This is true since most operating systems have the concept of separating a user space from a more privileged kernel space to prevent applications from inadvertently crashing the entire operating system. Using this type of separation

allows for the operating system to detect an error and simply kill the user session without perturbing the remaining portions of the operating system.

It is possible to introduce several extensions to what is currently defined in the sample implementations that enable even further capabilities. An operating system

kernel driver could be constructed to facilitate access to even more functions than would otherwise be available. This of course circumvents some of the inherent safety

of the operating system and can introduce inadvertent crashes when care is not taken. By constructing a kernel driver that can reserve certain hardware resources and is

able to advertise an interface that the emulation environment can call, the emulation environment can allow for an enhanced penetration into the hardware.

Figure 14.8 shows the logic flow associated with the various components and how they interact.

**236** \| Chapter 14 – Putting It All Together—Firmware Emulation

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-255_1.png)

 

**Figure 14.8:** Software Flow for Hardware Enhanced Firmware Emulation

 

**Summary**

 

This chapter illustrated how the majority of the UEFI code can be run in an em-ulated environment so that development can occur on some modules even in the absence of physical hardware that would otherwise have been necessary. This emu-

lation, which is publicly available, advances the accessibility of the overall UEFI programming infrastructure. It can also facilitate a wider distribution of its use due

to the relative simplicity of establishing such a development environment.