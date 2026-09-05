## **Chapter 6 – UEFI Console Services** 

 

Never test for an error condition you don’t know how to handle.

—Steinbach’s Guideline for Systems Programming

 

This chapter describes how UEFI extends the traditional boundaries of console sup-

port in the pre-boot phase and provides a series of software layering approaches that are commonly used in UEFI-compliant platforms. Most platforms, at minimum,

would have a text-based console for a user to either locally or remotely interact with the system. A variety of mechanisms can accomplish this communication in UEFI.

Whether it is through a remote interface, through a local keyboard and monitor, or even a remote network connection, each has a common root that can be thought of as

the basic UEFI console support. This support is used to handle input and output of text-based information intended for the system user during the operation of code in

the UEFI boot services environment. These console definitions are split into three types of console devices: one for input, and one each for normal output and errors.

These interfaces are specified by function call definitions to allow maximum flex-ibility in implementation. For example, a compliant system is not required to have a

keyboard or screen directly connected to the system. As long as the semantics of the functions are preserved, implementations may direct information using these inter-

faces in any way that succeeds in passing the information to the system user.

The UEFI console is built out of two primary protocols: UEFI Simple Text Input

and UEFI Simple Text Output. These two protocols implement a basic text-based con-sole that allows platform firmware, UEFI applications, and UEFI OS loaders to present

information to and receive input from a system administrator. The UEFI console con-sists of 16-bit Unicode characters, a simple set of input control characters known as

scan codes, and a set of output-oriented programmatic interfaces that give function-ality equivalent to an intelligent terminal. In the UEFI 2.1 specification, an extension

to the Simple Text Input protocol was introduced (now referred to as Simple Text In-put Ex), which greatly expanded the supportable keys as well as state information

that can be retrieved from the keyboard. This text-based set of interfaces does not inherently support pointing devices on input or bitmaps on output.

To ensure greatest interoperability, the UEFI Simple Text Output protocol is rec-ommended to support at least the printable basic Latin Unicode character set to ena-

ble standard terminal emulation software to be used with a UEFI console. The basic Latin Unicode character set implements a superset of ASCII that has been extended

to 16-bit characters. This provides the maximum interoperability with external termi-nal emulations that might otherwise require the conversion of text encoding to be

down-converted to a set of ASCII equivalents.

 

DOI 10.1515/9781501505690-008

**82** \| Chapter 6 – UEFI Console Services

 

UEFI has a variety of system-wide references to consoles. The UEFI System Table contains six console-related entries:

■ ConsoleInHandle – The handle for the active console input device. This han-

dle must support the UEFI Simple Text Input protocol and the UEFI Simple Text

Input Ex protocol.

■ ConIn – A pointer to the UEFI Simple Text Input protocol interface that is asso-

ciated with ConsoleInHandle. ■ ConsoleOutHandle – The handle for the active console output device. This

handle must support the UEFI Simple Text Output protocol.

■ ConOut – A pointer to the UEFI Simple Text Output protocol interface that is

associated with ConsoleOutHandle. ■ StandardErrorHandle – The handle for the active standard error console

device. This handle must support the UEFI Simple Text Output protocol. ■ StdErr – A pointer to the UEFI Simple Text Output protocol interface that is

associated with StandardErrorHandle.

 

Other system-wide references to consoles in UEFI are contained within the global var-iable definitions. Some of the pertinent global variable definitions in UEFI are:

■ ConIn – The UEFI global variable that contains the device path of the default

input console.

■ ConInDev – The UEFI global variable that contains the device path of all possi-

ble console input devices.

■ ConOut – The UEFI global variable that contains the device path of the default

output console.

■ ConOutDev – The UEFI global variable that contains the device path of all pos-

sible console output devices.

■ ErrOut – The UEFI global variable that contains the device path of the default

error console.

■ ErrOutDev – The UEFI global variable that contains the device path of all pos-

sible console output devices.

 

Figure 6.1 illustrates the software layering discussed so far. An UEFI application or

driver that wants to communicate through a text interface can use the active console

shown in the UEFI System Table to call the interface that supports the appropriate text input or text output protocol. During initialization, the system table is passed to the launched UEFI application or driver, and this component can then immediately

start using the console in question.

Simple Text Input Protocol \| **83**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-102_1.png)

 

**Figure 6.1:** Initial Software Layering

 

To further describe these interactions, it is necessary to delve a bit deeper into what these text I/O interfaces really look like and what they are effectively responsible for.

 

**Simple Text Input Protocol**

 

The Simple Text Input Protocol defines the minimum input required to support a spe-cific ConIn device. This interface provides two basic functions for the caller:

■ Reset – This function resets the input device hardware. As part of the initializa-

tion process, the firmware/device makes a quick but reasonable attempt to verify

that the device is functioning. This hardware verification process is implementa-

tion-specific and is left up to the firmware and/or UEFI driver to implement.

■ ReadKeyStroke – This function reads the next keystroke from the input de-

vice. If no keystroke is pending, the function returns a UEFI Not Ready error. If a

keystroke is pending, a UEFI key is returned. A UEFI key is composed of a scan

code as well as a Unicode character. The Unicode character is the actual printable

character or is zero if the key is not represented by a printable character, such as

the control key or a function key.

**84** \| Chapter 6 – UEFI Console Services

 

When reading a key from the ReadKeyStroke() function, an UEFI Input Key is retrieved. In traditional firmware, all PS/2 keys had a hardware specific scan code,

which was the sole item firmware dealt with. In UEFI, things have been changed a bit

to facilitate the reasonable transaction of this data both with local and remote users. The data sent back has two primary components:

■ Unicode Character – The Simple Text Input protocol defines an input stream that

contains Unicode characters. This value represents the Unicode-encoded 16-bit

value that corresponds to the key that was pressed by the user. A few Unicode

characters have special meaning and are thus defined as supported Unicode con-

trol characters, as described in Table 6.1.

 

**Table 6.1:** UEFI-supported Unicode Control Characters

 

**Mnemonic Unicode Description**

 

Null U+0000 Null character ignored when received.

 

BS U+0008 Backspace. Moves cursor left one column. If the cursor is

at the left margin, no action is taken.

 

TAB U+0x0009 Tab.

 

LF U+000A Linefeed. Moves cursor to the next line.

 

CR U+000D Carriage Return. Moves cursor to left margin of the current

line.

 

■ Scan Code - The input stream supports UEFI scan codes in addition to Unicode

characters. If the scan code is set to 0x00 then the Unicode character is valid and

should be used. If the UEFI scan code is set to a value other than 0x00, it repre-

sents a special key as defined in Table 6.2.

 

**Table 6.2:** UEFI-supported Scan Codes

 

**UEFI Scan Code** **Description**

 

0x00 Null scan code.

 

0x01 Move cursor up 1 row.

 

0x02 Move cursor down 1 row.

 

0x03 Move cursor right 1 column.

 

0x04 Move cursor left 1 column.

Simple Text Input Protocol \| **85**

 

**UEFI Scan Code** **Description**

 

0x05 Home.

 

0x06 End.

 

0x07 Insert.

 

0x08 Delete.

 

0x09 Page Up.

 

0x0a Page Down.

 

0x0b Function 1.

 

0x0c Function 2.

 

0x0d Function 3.

 

0x0e Function 4.

 

0x0f Function 5.

 

0x10 Function 6.

 

0x11 Function 7.

 

0x12 Function 8.

 

0x13 Function 9.

 

0x14 Function 10.

 

0x17 Escape.

 

The ReadKeyStroke function provides the additional capability to signal an UEFI event when a key has been received. To leverage this capability, one must use either the WaitForEvent or CheckEvent services. The event to pass into these services

is the following:

■ WaitForKey – The event to use when calling WaitForEvent() to wait for a

key to be available.

 

The activity being handled by the Simple Text Input protocol is very similar to the INT 16h services that were available in legacy firmware. Some of the primary differences

are that the legacy firmware service returned only the ASCII equivalent 8-bit value for

the key that was pressed along with the hardware-specific (such as PS/2) scan codes.

**86** \| Chapter 6 – UEFI Console Services

 

**Simple Text Input Ex Protocol**

 

The Simple Text Input Ex protocol provides the same functionality that the Simple Text Input protocol produced and adds a series of additional capabilities. This inter-

face provides a few new basic functions for the caller:

■ ReadKeyStrokeEx – This function reads the next keystroke from the input de-

vice. It operates in a fashion similar to the ReadKeyStroke from the Simple

Text Input protocol, except it has the ability to extract a series of extended key-

strokes that were not previously possible (See Table 6.3 and Table 6.4). This in-

cludes both shift state (for example, Left Control key pressed, Right Shift pressed,

and so on), and toggle information (for example, Caps Lock is turned on). If no

keystroke is pending, the function returns an EFI Not Ready error. If a keystroke

is pending, a UEFI key is returned.

■ Key Registration Capabilities – This set of functions provides for the ability to reg-

ister and unregister a set of keystrokes so that when a user hits the same key-

stroke, a notification function is called. This is useful in the case where there is a

desire to have a particular hot-key registered and then associated with a particu-

lar piece of software. This capability is often associated with the *KEY####* UEFI

global variable, which associated a key sequence with a particular *BOOT####*

variable target.

■ SetState – This function allows the settings of certain state data for a given

input device. This data often encompasses information such as whether or not

Caps Lock, Num Lock, or Scroll Lock are active.

 

**Table 6.3:** Simple Text Input Ex Keyboard Shift States

 

**Key Shift State Mask Value** **Description**

 

0x80000000 If high bit is on, then the state value is valid. For devices that are

not capable of producing shift state values, this value will be off.

 

0x01 Right Shift key is pressed

 

0x02 Left Shift key is pressed

 

0x04 Right Control key is pressed

 

0x08 Left Control key is pressed

 

0x10 Right Alt key is pressed

 

0x20 Left Alt key is pressed

 

0x40 Right logo key is pressed

 

0x80 Left logo key is pressed

Simple Text Output Protocol \| **87**

 

**Key Shift State Mask Value** **Description**

 

0x100 Menu key is pressed

 

0x200 System Request (SysReq) key is pressed

 

**Table 6.4:** Simple Text Input Ex Keyboard Toggle States

 

**Keyboard Toggle** **Description**

**State Mask Value**

 

0x80 If high bit is on, then the state value is valid. For devices that are not capa-

ble of representing toggle state values, this value will be off.

 

0x01 Scroll Lock is active

 

0x02 Num Lock is active

 

0x04 Caps Lock is active

 

**Simple Text Output Protocol**

 

The Simple Text Output protocol is used to control text-based output devices. It is the

minimum required protocol for any handle supplied as the ConOut or StdOut device. In addition, the minimum supported text mode of such devices is at least 80  25 char-

acters.

A video device that supports only graphics mode is required to emulate text mode

functionality. Output strings themselves are not allowed to contain any control codes other than those defined in Table 6.1. Positional cursor placement is done only via the

SetCursorPosition() function. It is highly recommended that text output to the StdErr device be limited to sequential string outputs. That is, it is not recom-

mended to use ClearScreen() or SetCursorPosition() on output mes-sages to StdErr, so that this data can be clearly captured or viewed.

The Simple Text Output protocol also has a pointer to some mode data, as shown in Figure 6.2. This mode data is used to determine what the current text settings are

for the given device. Much of this information is used to determine what the current cursor position is as well as the given foreground and background color. In addition,

one can stipulate whether a cursor should be visible or not.

**88** \| Chapter 6 – UEFI Console Services

 

typedef struct {

INT32 MaxMode;

// current settings

INT32 Mode;

INT32 Attribute;

INT32 CursorColumn;

INT32 CursorRow;

BOOLEAN CursorVisible; } SIMPLE_TEXT_OUTPUT_MODE;

 

**Figure 6.2:** Mode Structure for UEFI Simple Text Output Protocol

 

The Simple Text Output protocol also has a variety of text output related functions;

however, this chapter focuses on some of the most commonly used ones: ■ OutputString – Provides the ability to write a NULL-terminated Unicode

string to the output device and have it displayed. All output devices must also

support some of the basic Unicode drawing characters listed in the *UEFI 2.1 Spec-*

*ification*. This is the most basic output mechanism on an output device. The string

is displayed at the current cursor location on the output device(s) and the cursor

is advanced according to the rules listed in Table 6.3.

 

**Table 6.5:** Cursor Advancement Rules

 

**Mnemonic Unicode Description**

 

Null U+0000 Ignore the character, and do not move the cursor.

 

BS U+0008 If the cursor is not at the left edge of the display, then move the cur-

sor left one column.

 

LF U+000A If the cursor is at the bottom of the display, then scroll the display

one row, and do not update the cursor position. Otherwise, move the cursor down one row.

 

CR U+000D Move the cursor to the beginning of the current row.

 

Other U+XXXX Print the character at the current cursor position and move the cursor

right one column. If this moves the cursor past the right edge of the display, then the line should wrap to the beginning of the next line. This is equivalent to inserting a CR and an LF. Note that if the cursor is at the bottom of the display, and the line wraps, then the display will be scrolled one line.

 

By providing an abstraction that allows a console device, such as a video driver, to produce a text interface, this can be compared to legacy firmware support for INT 10h.

The producer of the Simple Text Output interface is responsible for converting the Remote Console Support \| **89**

 

Unicode text characters into the appropriate glyphs for that device. In the case where an unrecognized Unicode character has been sent to the OutputString() API, the

result is typically a warning that indicates that these characters were skipped.

■ SetAttribute – This function sets the background and foreground colors for

both the OutputString() and ClearScreen() functions. A variety of fore-

ground and background colors are defined by the *UEFI 2.1 Specification*. The color

mask can be set even if the device is in an invalid text mode. Devices that support

a different number of text colors must emulate the specified colors to the best of

the device’s capabilities.

■ ClearScreen – This function clears the output device(s) display to the cur-

rently selected background color. The cursor position is set to (0,0). ■ SetCursorPosition – This function sets the current coordinates of the cur-

sor position. The upper left corner of the screen is defined as coordinate (0,0).

 

**Remote Console Support**

 

The previous sections of this chapter described some of the text input and output pro-

tocols, and used some examples that were generated through local devices. UEFI also

supports many types of remote console. This support leverages the pre-existing local interfaces but enables the routing of this data to and from devices outside of the plat-form being executed.

When a remote console is instantiated, it typically results from UEFI constructing an I/O abstraction that a console driver latches onto. In this case, the discussion ini-

tially concerns serial interface consoles. A variety of console transport protocols, such as PC ANSI, VT-100, and so on, describe the format of the data that is sent to and from

the machine.

The console driver responsible for producing the Text I/O interfaces acts as a filter

for the I/O. For example, when a remote key is pressed, this might require a variety of pieces of data to be constructed and sent from the remote device and upon receipt,

the console driver needs to interpret this information and convert it into the corre-sponding UEFI semantics such as the UEFI scan code and Unicode character. The

same is true for any application running on the local machine that prints a message. This message is received by the console driver and translated to the remote terminal

type semantics.

Table 6.6 gives examples of how an UEFI scan code can be mapped to ANSI X3.64

terminal, PC-ANSI terminal, or an AT 101/102 keyboard. PC ANSI terminals support an escape sequence that begins with the ASCII character 0x1b and is followed by the

ASCII character 0x5B, “\[“. ASCII characters that define the control sequence that should be taken follow the escape sequence. The escape sequence does not contain

spaces, but spaces are used in Table 6.6 for ease of reading. For additional infor-mation on UEFI terminal support, see the latest *UEFI Specification*.

**90** \| Chapter 6 – UEFI Console Services

 

**Table 6.6:** Sample Conversion Table for UEFI Scan Codes to other Terminal Formats

 

**EFI** **ANSI X3.64** **PC ANSI** **AT 101/102 Keyboard** **Scan Code** **Description** **Codes** **Codes** **Scan Codes**

 

0x00 Null scan code N/A N/A N/A

 

0x01 Move cursor up 1 row CSI A ESC \[ A 0xe0, 0x48

 

0x02 Move cursor down 1 row CSI B ESC \[ B 0xe0, 0x50

 

0x03 Move cursor right 1 column CSI C ESC \[ C 0xe0, 0x4d

 

0x04 Move cursor left 1 column CSI D ESC \[ D 0xe0, 0x4b

 

0x05 Home CSI H ESC \[ H 0xe0, 0x47

 

0x06 End CSI K ESC \[ K 0xe0, 0x4f

 

0x07 Insert CSI @ ESC \[ @ 0xe0, 0x52

 

0x08 Delete CSI P ESC \[ P 0xe0, 0x53

 

0x09 Page Up CSI ? ESC \[ ? 0xe0, 0x49

 

0x0a Page Down CSI / ESC \[ / 0xe0, 0x51

 

Table 6.7 shows some of the PC ANSI and ANSI X3.64 control sequences for adjusting

display/text display attributes for text displays.

 

**Table 6.7:** Example Control Sequences that Can Be Used in Console Drivers

 

**PC ANSI** **ANSI X3.64**

**Codes** **Codes** **Description**

 

ESC \[ 2 J CSI 2 J Clear Display Screen.

 

ESC \[ 0 m CSI 0 m Normal Text.

 

ESC \[ 1 m CSI 1 m Bright Text.

 

ESC \[ 7 m CSI 7 m Reversed Text.

 

ESC \[ 30 m CSI 30 m Black foreground, compliant with ISO Standard 6429.

 

ESC \[ 31 m CSI 31 m Red foreground, compliant with ISO Standard 6429.

 

ESC \[ 32 m CSI 32 m Green foreground, compliant with ISO Standard 6429.

 

ESC \[ 33 m CSI 33 m Yellow foreground, compliant with ISO Standard 6429.

 

ESC \[ 34 m CSI 34 m Blue foreground, compliant with ISO Standard 6429. Remote Console Support \| **91**

 

Figure 6.3 illustrates the software layering for a remote serial interface with Text I/O abstractions. The primary difference between this illustration and one that exhibits

the same Text I/O abstractions on local devices is that this one has one additional

layer of software drivers. In the former examples, the local device was discovered by an agent, launched, and it in turn would establish a set of Text I/O abstractions. In the remote case, the local device is a serial device, which has a console driver that is

layered onto it, and it in turn would establish a set of Text I/O abstractions.

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-110_1.png)

 

**Figure 6.3:** Remote Console Software Layering

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-110_2.png)

**92** \| Chapter 6 – UEFI Console Services

 

**Console Splitter**

 

The ability to describe a variety of console devices poses interesting new possibilities. In previous generations of firmware, one had a single means by which one could de-

scribe what the Text I/O sources and targets were. Now the UEFI variables that specify

the active consoles are specified by a device path. In this case, these device paths are multi-instance, meaning that more than one target device could be the active input or output. For instance, if one wanted to be able to have an application print text to

the local screen as well as to the screen of a remote terminal, it would be highly im-practical for anyone to customize their software to accommodate that particular sce-

nario. In the solution that UEFI provides with its console splitting/merging capability, an application can simply use the standard text interfaces that UEFI provides and the

console splitter routes the text requests to the appropriate target or targets. This works for both input as well as output streams.

This is how it works: when the UEFI-compliant platform initializes, the console splitter installs itself in the UEFI System Table as the primary active console. In doing

so, it can then proceed to monitor the platform as other UEFI text interfaces get in-stalled as protocols and the console splitter keeps a running tally of the user selected

devices for a given console variable, such as ConOut, ConIn, or ErrOut.

Figure 6.4 illustrates a scenario where an application is calling UEFI text inter-

faces, which in turn calls the UEFI System Table console interfaces. These interfaces belong to the console splitter, and the console splitter then sends the text I/O requests

from the application to the platform-configured consoles.

Network Consoles \| **93**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-112_1.png)

 

**Figure 6.4:** Software Layering Description of the UEFI Console Splitter

 

**Network Consoles**

 

UEFI also provides the ability to establish data connections with remote platforms

across a network. Given the appropriate installed drivers, one could also enable an UEFI-compliant platform to support a text I/O set of abstractions. Similar to previ-

ously discussed concepts where the hardware interface (for example, serial device, keyboard, video, network interface card) has an abstraction, other components build

on top of this hardware abstraction to provide a working software stack.

**94** \| Chapter 6 – UEFI Console Services

 

Some network components that UEFI might include are as follows: ■ Network Interface Identifier – This is an optional protocol that is produced by the

Universal Network Driver Interface (UNDI) and is used to produce the Simple Net-

work Protocol. This protocol is only required if the underlying network interface

is a 16-bit UNDI, 32/64-bit software UNDI, or hardware UNDI. It is used to obtain

type and revision information about the underlying network interface.

■ Simple Network Protocol – This protocol provides a packet level interface to a

network adapter. It additionally provides services to initialize a network inter-

face, transmit packets, receive packets, and close a network interface.

 

To illustrate what a common network console might look like, you could describe an initial hardware abstraction that talks directly to the network interface controller

(NIC) produced by an UNDI driver. This in turn has a Simple Network Protocol that layers on top of UNDI. It provides basic network abstraction interfaces such as Send

and Receive. On top of this, a transport protocol might be installed such as a TCP/IP stack. As with most systems, once an established transport mechanism is provided,

one can build all sorts of extensions into the platform such as a Telnet daemon to allow remote users to log into the system through a network connection. Ultimately,

this daemon would produce and be responsible for handling the normal Text I/O in-terfaces already described in this chapter.

Figure 6.5 illustrates an example where a remote machine is able to access the EFI-compliant platform through a network connection. Providing the top layer of the

software stack (EFI_SIMPLE_TEXT_IN and EFI_SIMPLE_TEXT_OUT) as the interoper-able surface area that applications talk to allows for all standard UEFI applications to

seamlessly leverage the console support in a platform. Couple this with console split-ting and merging as inherent capabilities and you have the ability to interact with the

platform in a much more robust manner without requiring a lot of specially tuned software to enable it.

Summary \| **95**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-114_1.png)

 

**Figure 6.5:** Example of Network Console Software Layering

 

**Summary**

 

In conclusion, UEFI provides a very robust means of describing the various possible

input and output console possibilities. It can also support console representations through a gamut of protocols such as terminal emulators (such as ANSI/VT100) as

well as remote network consoles leveraging wider variations of the underlying UEFI network stack.