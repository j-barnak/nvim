*index*

Symbols

\#\[cfg(not(...))\] 227

Arc 354

\#\[cfg(target_os ! 227

Arc\<Mutex\<\_\>\> 363

! type 79–90

\#\[derive(…)\] block 152

Arc\<Mutex\<T\>\> 133, 354

? operator 275

\#\[derive(Debug)\] 98, 272–273

Arc\<T\> 133, 185

'static lifetime 62

arena::Arena 201

() type 79–90

A

arena::TypedArena 201

\*const fn() -\> () type 406

arrays, making lists with 64–65

\*const i8 413

abort() function 373

Artist struct 344–345

\*const T 183

abort exception 391

as keyword 39

\*mut i32 183

absolute time 296

asm! macro 395

\*mut i8 411–413

abstract classes 40

AsMut\<T\> 189

\*mut T 183

ActionKV 228, 231

as operator 39

\*mut u32 376

actionkv

AsRef\<str\> 189

\*mut u8 376

conditional compilation

AsRef\<T\> 189

&'static str 189

226–228

associative arrays 242

&dyn Rng 259

front-end code 224–228

asynchronous interrupts 392

&dyn Trait 256

full code listing 237–241

asynchronous programming 362

&mut dyn Trait 256

libactionkv crate 228–249

atomic operations 411

&mut T 119

overview 222–223

atomic reference counter 133

&Rng 260

ActionKV::load(). open() 228

avatar generator 341–360

&str type 61, 189, 222, 242, 292, ActionKV::open() 228–229

render-hex 342–349

387

activation frames 188

generating SVGs 346

&T 119

address space 177

input parsing 344

&Trait 256

add_with_lifetimes() 57

interpreting

&\[u8\] 292, 387

akv_mem executable 223

instructions 344–346

\#\![allow(unused_variables)\]

aliasing 91

running 342

attribute 78

alloc::raw_vec::RawVec type 187

source code 346–349

\#\![core_intrinsics\] attribute 373

alloc() 194, 201

spawning a thread per logical

\#\![no_main\] attribute 374

allocation records 188

task 351–353

\#\![no_mangle\] attribute 373,

allocator 194

functional programming

389

alloc module 187

style 351–352

\#\![no_std\] attribute 373–374,

always on mode 314

parallel iterators 352–353

389

Amazon Web Services (AWS) 2

thread pools 353–360

\#\![repr(u8\]) 389

anonymous functions 9, 199, channels 356

\#\[cfg(all(...))\] 227

329–330

implementing task

\#\[cfg(any(...))\] 227

application-level protocol 254

queues 358–360



INDEX

avatar generator *(continued)*

byteorder::ReadBytesExt

clap::App type 301

one-way communication

trait 232

clap::Arg type 301

354–356

byteorder::WriteBytesExt

class keyword 84

two-way communication

trait 232

clear intent 221

356–358

byteorder crate 232

Clock::set(t) 313

AWS (Amazon Web Services) 2

ByteString type 228

clock command 302

ByteStr type 228

Clock struct 300, 306

B

clock synchronization 314

C

.clone() method 129–130, 153

back pressure 354

Clone trait 129–131, 153

base 2 (binary) notation 37–38

cache-friendly data

close() method 87

base 8 (octal) notation 37–38

structures 19

closures 9

base 16 (hexadecimal)

capitals 244

functions vs. 340–341

notation 37–38

capitals\["Tonga"\] 245

overview 330–331

b as i32 type cast 39

capitals.index("Tonga") 245

collect() method 351–352

basic_hash 243

captures 330

collection 47

big endian format 143

cargo add command 45

Color type 382

BigEndian type 232

cargo-binutils crate 366–367

Command::Noop 360

\[\[bin\]\] entry 247

cargo bootimage command 374

command-line arguments,

bincode format 214–216

cargo build command 371

supporting 70–72

bin section 223

cargo build --release flag 192

command-line utilities 23–24

bit endianness 143

cargo build utility 18, 192

Common control flow

bit numbering 143

cargo commands 11

mechanisms 8

bit patterns and types 137–139

cargo doc --no-deps flag 106

compilers 33

bool 87

cargo doc utility 18

compiler target 226, 369

boot image 367

cargo-edit crate 45

compile time 11

bootimage crate 366–367

cargo init command 34

compiling 10

bootloader 377

cargo new command 6, 18

complex numbers 43–45

borrow checker 107

cargo run command 6, 8, 10, 18,

compound data types

borrowed type 62

34, 44, 54, 90, 265

adding methods to struct with

bounded queues 354

cargo test 154

impl 84–87

bounds checking 47

cargo tool

enum

Box::new(T) 192

compiling projects with 33–34

defining 95–96

Box\<dyn Error\> 271–272

creating projects with 6, 18

using to manage internal

Box\<dynstd::error::Error\>

rendering docs with 104–106

state 96–98

type 255

testing projects with 154

inline documentation 103–106

Box\<dyn Trait\> 256

cargo xbuild 371

rendering docs for crates

Box\<T\> 187, 191

carry flag 165

and dependencies

Box\<Trait\> 256

c_char type 182

104–106

break keyword 50, 80

Cell\<T\> 185

rendering docs for single

breaking from nested

cfg annotation 326

source file 104

loops 49

cfg attribute 226, 250

modeling files with struct

overview 48–49

--cfg ATTRIBUTE command-line

80–83

BTreeMap

argument 227

plain functions 78–80

deciding between 245–246

ch6-particles 200

protecting private data 102

keys and values 241–243

char type 62

returning errors 87–94

retrieving values from

check_status() function 109,

modifying known global

244–245

111–112, 115–116

variables 87–91

buffered I/O 73

check_status(sat_a) 112

Result return type 92–94

buffer overflow 13

checksums, validating I/O

simplifying object

buffers 21

errors with 234–236

creation 84–87

BufReader. BufReader 72

CHIP-8 specification 165

traits 98–102

bug 22

choose() method 257

creating Read traits 98–99

build-command 371

chrono::Local 299

implementing

byteorder::LittleEndian 232

chunks() option 219

std::fmt::Display 99–102



computer architecture 206

coroutines 361

CPU 4 173

concurrency 328

CPU emulation 158–173

CPU RIA/1 (Adder) 159–

anonymous functions 329–330

CPU 4 173

163

avatar generator 341–360

CPU RIA/1 (Adder) 159–163

CPU RIA/2

render-hex 342–349

defining CPU 159

(Multiplier) 164–167

spawning a thread per logi-

emulator's main loop

CPU RIA/3 (Caller)

cal task 351–353

160–161

167–173

thread pools 353–360

full code listing 163–164

fixed-point number

closures vs. functions 340–341

interpreting opcodes

formats 152–157

task virtualization and 360–363

161–163

floating-point numbers

containers 363

loading values into

144–152

context switches 362

registers 159–160

dissecting 150–152

processes 363

terminology 159

inner workings of f32

reasons for using operating

CPU RIA/2 (Multiplier)

type 144–145

systems 363

164–167

isolating exponent 146–147

threads 362

expanding CPU to support

isolating mantissa 148–150

WebAssembly 363

memory 164–165

isolating sign bit 146

threads 330–340

full code listing 166–167

representing decimals

closures 330–331

handling integer

143–144

effect of spawning many

overflow 165

generating random probabili-

threads 333

reading opcodes from

ties from random

effect of spawning some

memory 165

bytes 157–158

threads 331–332

CPU RIA/3 (Caller) 167–173

integers

reproducing results

defining functions and

endianness 142–143

335–338

loading into

integer overflow 139–143

shared variables 338–340

memory 168–169

data-oriented programming 19

spawning threads 331

expanding CPU to include

data processing 24

thread::yield_now()

stack support 167–168

data races 13

method 338

full code listing 170–173

DateTime\<FixedOffset\> 306

conditional branching 49–51

implementing CALL and

debug_assertions attribute 228

conditional compilation 9, 226

RETURN opcodes

debugging 221

constellation 108

169–170

Debug trait 99, 153, 272–273

const keyword 88, 91

cpu.position_in_memory

declaration statements 51

const USAGE 226

variable 170

decode_f32_parts() 150

const values 381, 405

cpu.run() 170

deconstruct_f32() 150

containers 363

CPU struct 164

DELETE case 95

container variable 45

CRC32 (cyclic redundancy

delete \<key\> 224

context switches 362

check returning 32

\[dependencies\] section 44,

contiguous layout 194

bits) 235

353

continue keyword 8, 47

create() method 219

dereference operator 53, 192

convert() function 345–346

cryptographic hash

dereferencing a pointer 183

copy semantics 113, 153

function 235

deserialization 249

Copy trait 111–112, 114, 129–

CubeSat 108, 111, 115, 119–120

Deserialize trait 214

131, 153

CubeSat. CubeSat.mailbox 118

desktop applications 25

core::fmt::Write trait 385–386

CubeSat.messages vector 120

Display trait 99–102, 272–274

implementing 386–387

current_instruction field 164

dive() 408

reimplementing panic()

Cursor.print() 383

dns.rs 283

385–386

Cursor struct 382–383

domain_name 264

core::intrinsics::abort() 385

domain name resolution 261

core::ptr::Shared type 187

D

Drop 115, 132

core::ptr::Unique,

drop(&mut self) 115

core::ptr::Shared type 185

dangling pointers 12

Dwarf struct 257

core::ptr::Unique type 187

data

dynamically-sized types 65, 190, core::write! macro 385

bit patterns and types 137–139

256

core module 187

CPU emulation 158–173

dynamic dispatch 256



dynamic memory allocation

std::convert::From trait

file operations 219–222

194

276

opening files and controlling

defined 194–199

std::error::Error trait 274

file mode 219–220

impact of 199–201

std::fmt::Display trait

std::fs::Path trait 220–222

dynamic typing 65

273–274

hexdump clones 217–219

dyn keyword 260

Error trait 274

key-value stores 222–223

ethernet.rs 283

actionkv 222–223

E

exceptions 391

key-value model 222

defined 391–393

FileState subtype 100

Elf struct 257

handling 379–380, 411

File struct 81

else blocks 49–51

revising 417

FILETIME 308

enchant() method 257, 259

executable 361

File type 81, 96, 100

encoding 138

\_exit() function 377

fixed-point number

endianness 137, 142–143

.expect() method 219, 228, 264, formats 152–157

entry point 377

277, 292

FledgeOS 365–368

enumerate() method 63

exponents, isolating 146–147

compilation instructions 370

enums 51, 77, 84, 109

expression statement 51

development environment

annotating with

extending applications 24

setting up 366–367

\#\[derive(Debug)\] 273

extern "C" 374, 411

verifying 367–368

controlling in-memory repre-

exception handling 379–380

sentation of 382

F

first boot 368–369

defining 95–98

loops 377–379

defining enums that include

f1_length 81

panic handling 374–375,

upstream errors as

f1_name 81

385–387

variants 273

f32::EPSILON 42

core::fmt::Write trait

reasons for using 382

f32_from_parts() method

385–387

using to manage internal

150

reporting error to user 385

state 96–98

f32—i32 139

source code 370–374, 378–

EOF (end of file) 230

f32 type 38, 41, 144, 150,

380, 383, 387

epochs 296

154–155, 232

\_start() function 377

eprintln! 10

f4 variable 92

text output 381–383

Eq trait 152–153

f64::EPSILON 42

creating type that can print

Err 219

f64 type 38, 41, 155

to VGA frame

Err(E) 10

fast clocks 297

buffer 382–383

Err(err) 270

faults 391–392

enums 382

Err(String) 92

fearless concurrency 27

printing to screen 383

errno 87, 91

fields variable 10

writing colored text to

error handling 268–277

File::create method 220

screen 381

clock project 313

File::open method 220, 271

writing to screen with VGA-

inability to return multiple

\<file\> command 33

compatible text

error types 269–271

file descriptor 87

mode 375–377

returning errors 87–94

File object 84

floating-point numbers 36–37, modifying known global

files and storage

144–152

variables 87–91

actionkv

dissecting 150–152

Result return type 92–94

conditional

inner workings of f32

unwrap() and expect() 277

compilation 226–228

type 144–145

wrapping downstream

front-end code 224–228

isolating exponent 146–147

errors 272–276

libactionkv crate 228–249

isolating mantissa 148–150

annotating with

overview 222–223

isolating sign bit 146

\#\[derive(Debug)\]

file formats

representing decimals 143–144

273

creating 214–216

flow control 45–52

defining enums that

defined 213–214

break keyword

include the upstream

writing data to disk with

breaking from nested

errors as variants 273

serde and bincode

loops 49

map_err() 274–276

format 214–216

overview 48–49



flow control *(continued)*

G

high nibble 161

continue keyword 47

high resolution 297

else blocks 49–51

GC (garbage collection) 131

hlt x86 instruction 378

for loop

generate_svg() 346

hostnames, converting to IP

anonymous loops 46

generic functions 58–60

addresses 261–268

index variable 46–47

generic type 58

HTTP

overview 45–46

.get() method 245

HTTP GET requests, generat-

if else blocks 49–51

git clone --depth 90

ing with reqwest

if keyword 49–51

global variables

library 254–256

loop keyword 48

signal handling with custom

raw 283–292

match keyword 51–52

actions 401–402

http-equiv attribute 254

while loop

using to indicate that shut-

http.rs file 283

endless looping 48

down has been

overview 47

initiated 402–405

I

stopping iteration once a

goto fail 22

duration is reached

goto fail; bug 22–23

i16 type 38, 232

47–48

goto keyword 49

i32 type 38, 183

fmt::Result 100

grep-lite 60–63

i64 type 38

.fmt() method 100

grep-lite --help 72

i8 type 38

fn keyword 35, 404–405, 417

ground station, definition 108

if else blocks 49–51

fn noop() 406

GroundStation type 119–120, if keyword 49–51

fn x(a: String) type

123

if let construct 10

signature 189

if let Ok(T) 10

fn x\<T: AsRef\<str\>\> (a: T) type

H

impl blocks 78, 84, 130, 274,

signature 189

276

for item in collection 47

handlers 338

adding methods to struct

for loop

handlers.pop() 336

with 84–87

anonymous loops 46

handlers vector 336

simplifying object creation by

index variable 46–47

handle_signals() function 402

implementing 84–87

overview 45–46

handle_sigterm() 404

impl keyword 98

format! macro 99

handle_sigterm as usize 405

INDEX_KEY value 247

frame buffer 374, 376

handle_sigusr1() 404

Index trait 245

frames 279

hardware interrupts 391, 395

infix notation 36

f.read(buffer) function 84

hash collision 243

inline assembly 379

f.read_exact() method 219

hashes 241

inline documentation 103–106

free() 194, 201

HashMap

rendering docs for crates and

freestanding applications 363

creating and populating with

dependencies 104–106

from() method 220, 276, 318

values 243–244

rendering docs for single

From\<f64\> implementation 154

deciding between 245–246

source file 104

From trait 154, 276, 318–319

keys and values 241–243

insert \<key\> \<value\> 224

function pointers 341, 405–406

retrieving values from

integers

functions 56–60

244–245

base 2, base 8, and base 16

anonymous functions 329–330

hash map 242

notation 37–38

calling 35–36

hash table 241–242

endianness 142–143

closures vs. 340–341

haystack 53

integer overflow 139–143

defining 52

heading 344

overview 36–37

explicit lifetime

heap 18, 190–192

interior mutability 132–133,

annotations 56–58

HeapAlloc() call 194

185

generic functions 58–60

HeapFree() 194

interrupts

intrinsic functions

Heartbleed 21–22

defined 391–393

defined 411

“Hello, world!” 5–8

effect on applications

setting up 409–412

hexdump clones 217–219

393–395

using plain functions to exper-

high accuracy 297

hardware interrupts 395

iment with APIs 78–80

high byte 161

signals vs. 391–393

fview 217–218

higher-order programming 9

software interrupts 395



.into() method 318

.keys() method 245

linear memory 363

intrinsic functions 373

.keys_mut() variant 245

link_name attribute 411

defined 411

key-value stores 222–223

lists 63–67

setting up 409–412

actionkv 222–223

arrays 64–65

intrinsics::abort() 375, 389

key-value model 222

slices 65

IP addresses, converting host-

kill command 398–399

vectors 66–67

names to 261–268

little endian format 143

ip tuntap list subcommand

L

LLVM 411–412

283

llvm.eh.sjlj.setjmp 411

.is_finite() method 43

lambda functions 9, 199, 329

llvm-tools-preview

isize type 38

language items 380

component 367

.is_nan() method 43

Last In, First Out (LIFO) 188

llvm-tools-preview toolchain

ISO 8601 standard 299–305

let keyword 91

component 368

is_strong 189

letters variable 16

load() 236

.iter() method 245

lexical scopes 35

long int 298

iterator invalidation 13

libactionkv::ActionKV 228

longjmp 408–409, 412, 414,

.iter_mut() variant 245

libactionkv crate 228–249

417

it object 257

adding database index to

loop keyword 48, 80, 281

actionkv 246–249

loops

J

BTreeMap

break keyword

deciding between 245–246

breaking from nested

jmp_buf type 413

keys and values 241–243

loops 49

join() function 331, 336

retrieving values from

overview 48–49

244–245

continue keyword 47

K

HashMap

FledgeOS 377–379

creating and populating

interacting with CPU

kernel 365–368

with values 243–244

directly 377–378

compilation instructions 370

deciding between 245–246

source code 378–379

development environment

keys and values 241–243

for loop

setting up 366–367

retrieving values from

anonymous loops 46

verifying 367–368

244–245

index variable 46–47

exception handling 379–380

initializing ActionKV

overview 45–46

first boot 368–369

struct 228–230

loop keyword 48

loops 377–379

inserting new key-value pairs

while loop

panic handling 374–375,

into existing

endless looping 48

385–387

database 236–237

overview 47

core::fmt::Write trait

processing individual

stopping iteration once a

385–387

records 230–232

duration is reached

reporting error to user

validating I/O errors with

47–48

385

checksums 234–236

low byte 161

source code 378–380, 383,

writing multi-byte binary data

low-level programming 2

387

to disk in a guaranteed

low nibble 161

source code listings 370–374

byte order 232–233

\_start() function 377

libc::SIG_IGN 407

M

text output 381–383

libc::signal() 404, 407

creating type that can print

libc::timeval 308

MAC addresses 277–281

to VGA frame

libc library

macros 36

buffer 382–383

non-Windows clock

main.rs file 283

enums 382

code 307–308

Mandelbrot set 54–56

printing to screen 383

setting the time 306–308

mantissa 144, 148–150

writing colored text to

type naming

map() method 351–352

screen 381

conventions 306–307

map_err() method 272,

writing to screen with VGA-

lifetime 110–112

274–276

compatible text

lifetime elision 57

match keyword 51–52, 281

mode 375–377

LIFO (Last In, First Out) 188

mem::transmute 157



memory

NAN (Not a Number)

full code listing 319–321

pointers 178–187

values 148

sending requests and inter-

overview 176–178

NativeEndian type 232

preting responses

pointer ecosystem 185–186

n_bits 149

314–316

raw pointers 183–185

networking

NTPResult 316

smart pointer building

error handling 268–277

null pointer 177

blocks 186–187

inability to return multiple

num::complex::Complex

providing programs

error types 269–271

type 44

with 187–201

unwrap() and expect() 277

numbers 36–45

dynamic memory

wrapping downstream

comparing

allocation 194–201

errors 272–276

different types 39–43

heap 190–192

generating HTTP GET

operators for 38–43

stack 188–190

requests with

complex numbers 43–45

virtual memory 202–211

reqwest 254–256

decimal (floating-point)

having processes scan their

implementing state machines

numbers 36–37

own memory 203–205

with enums 281–282

integers

overview 202–203

MAC addresses 277–281

base 2, base 8, and base 16

reading from and writing to

overview 252–254

notation 37–38

process memory 211

raw HTTP 283–292

overview 36–37

scanning address

TCP 260–268

rational numbers 43–45

spaces 208–210

converting hostnames to IP

translating virtual addresses

addresses 261–268

O

to physical

port numbers 261

addresses 205–207

raw 282

offset() method 376–377, 389

memory fragmentation 206

trait objects 256–260

Ok state 92

memory management unit

defined 256

one_at_bit_i 149

(MMU) 203, 206

function of 256

OpCode enum 264

message ID 263

rpg project 257–260

opcodes

messages.push() 120

virtual networking

implementing CALL and

Message struct 263

devices 282–283

RETURN opcodes

MessageType 264

Network Time Protocol. *See* NTP

169–170

message type 263

(Network Time Protocol)

interpreting 161–163

\<meta\> HTML tag 254

Never type 79

reading from memory 165

mkdir \<project\> 34

new() method 44–45, 84–87

open() method 87, 92, 219

MMU (memory management

newtype pattern 81

--open cargo doc 105

unit) 203, 206

nibbles 161

Operation enum 344

mobile applications 25

nightly toolchain 367

operator overloading 36

mock CubeSat ground station

nnn variable 161

Option\<&V\> 245

lifetime issue 110–112

non-blocking I/O 362

Option\<T\> type 177

special behavior of primitive

None variant 177

Option type 52, 250, 263

types 112–114

nonlocal control transfer 408

-O rustc 141

mock_rand() 158

noop() function 406

ownership 115

mod keyword 156

No Rust 2.0 27

mock CubeSat ground

most significant bit 143

Not a Number (NAN)

station 108–114

most significant byte 143

values 148

lifetime issue 110–112

move keyword 330, 340

Notify opcodes 264

special behavior of primi-

move semantics 113, 153

nth() method 219

tive types 112–114

multicast mode 279

NTP (Network Time

overview 115

Mutex 354

Protocol) 293, 314–321

resolving issues with 118–133

adjusting local time

duplicating values 128–131

N

316–318

using fewer long-lived

converting between time rep-

values 123–126

NaiveTime 298

resentations that use dif-

using references where full

name mangling 373

ferent precisions and

ownership is not

namespaces 363

epochs 318–319

required 119–122



ownership *(continued)*

port numbers 261

Rc\<T\> 131–133, 185

wrapping data within spe-

position_in_memory 164–165, Rc\<T\>. Rc\<T\> 131

cialty types 131–133

167, 173

RDTSC instruction 296

shifting 115–117

predicates 47

read(f, buffer) method 84

prelude 353

read function 78

P

primitive types, special behavior

.read_opcode() method 165

of 112–114

ReadProcessMemory() 211

\[package.metadata.bootimage\]

print() method 386

Read trait 98–99, 219

371

println! 10, 36–37, 98–99, 139, real memory 202

page fault 202

153, 250

real-time clock 294, 296

pages, memory 202, 206

processes 361, 363

Receiver 354

page table 202

process ID (PID) 398

Receiver\<i32\> 356

.panic() method 385–386

process_record() function 231

Receiver\<T\> 356

panic handling 385–387

process_vm_readv() 211

.recv() method 120, 354

core::fmt::Write trait

process_vm_writev() 211

recv(rx) -\> 356

implementing 386–387

program counter 165

recv_from() 268

reimplementing

Programmable Interrupt Con-

refactoring 128

panic() 385–386

troller (PIC) 395

RefCell\<T\> 185

reporting error to user 385

programs 361

reference counting 18, 91, 131

PanicInfo struct 375

promotion 39

reference operator 53

parallelism 328

pub(crate) 157

references 53–54, 119–122

parallel iterators 352–353

pub(in path) 157

References type 178

.par_bytes() method 353

pub(self) 157

registers 164

.par_iter() method 351, 353

pub(super) 157

register_signal_handler()

parity_bit() function 235

pub keyword 157

function 403

parity bit checking 235–236

push() method 360

register_signal_handlers()

parity checking 235

function 402

parse::\<f32\>() annotation 10

Q

regular expressions, adding sup-

parse::\<Ipv6Addr\>() 271

port for 68–69

parse() function 10, 351, 358

Q7 154

release build 11

.parse() method 10, 345

-q cargo 11

--release cargo 11, 192

PartialEq trait 99, 152–153

QEMU 366–367

.remove() method 245

partial equivalence relation 41

Q format 152

render-hex

Particle struct 195

quantizing the model 152

running 342

password argument 189

queries 263

single-threaded 342–349

password variable 190

Query opcodes 264

generating SVGs 346

\<path\> tag 346

Query struct 263

input parsing 344

PathBuf value 220

interpreting

Path trait 220–222

R

instructions 344–346

Path value 220–221

source code 346–349

pause variable 338

radix 144

repeat expression 64

PIC (Programmable Interrupt

rand::random() 401

report() function 79

Controller) 395

rand::rngs::ThreadRng

ReportingAllocator struct 195

PID (process ID) 398

struct 259

repr attribute 382

pointers 178–187

rand::Rng trait 259

request::get(url) method 292

function pointers 405–406

rand::seq::SliceRandom

request/response mode 314

overview 176–178

trait 257

reqwest::get() 255

pointer ecosystem 185–186

random bytes, generating ran-

reqwest library, generating

raw pointers 183–185

dom probabilities

HTTP GET requests

smart pointer building

from 157–158

with 254–256

blocks 186–187

rational numbers 43–45

resource-constrained

Pointers type 178

raw pointers 183–185

environments 24–25

polymorphism 256

Raw pointers type 178

resource record type 263

pop() 336

Rc::new() 131

response 314

portability 221

Rc\<RefCell\<T\>\> 132–133, 185

response.text() method 255



response variable 255

conditional branching

rustc 33, 141, 412

Result 35, 40, 94, 228, 255, 272

49–51

rustc --codegen opt-level 192

Result\<File, String\> function 92

continue keyword 47

rustc compiler, compiling single

Result return type 92–94

for loop 45–47

files with 33

Result\<T, E\> 269

loop keyword 48

rustc \<file\> command 33

Result type 268, 313

match keyword 51–52

rustdoc tool, rendering docs

ret() method 170

while loop 47–48

for single source file

RETURN_HERE mutable

functions 52, 56–60

104

static 413

explicit lifetime

rust-src component 367

return keyword 9, 50

annotations 56–58

rust-strip 367

RETURN opcode 167, 169–170

generic functions 58–60

rustup default stable

RFC 3339 301

goals of

command 367

Rng trait 259

control 18–19

rustup doc 70

RPC 2822 301

productivity 16–18

rustup install nightly 414

rpg (role playing game)

safety 12–16

rustup target list 369

project 257–260

grep-lite 60–63

rustup tool, managing tool-

run() method 160

lists 63–67

chains with 70

run_command 371

arrays 64–65

Rust

slices 65

S

"Hello, world!" 5–8

vectors 66–67

advocating for at work 3–4

Mandelbrot set 54–56

-s argument to resolve 262

command-line arguments

numbers 36–45

sat_id 111

70–72

base 2, base 8, and base 16

save scum 362

compiling source code into

notation 37–38

segmentation fault 203–204

running programs 33–34

comparing 38–43

segments 203

compiling projects with

complex numbers 43–45

select! macro 356

cargo 33–34

floating-point numbers

self.messages collection 126

compiling single files with

36–37

semantic versioning 27

rustc 33

integers 36–38

send() method 120, 354

deployments 23–26

rational 43–45

Sender 354

command-line utilities

reading

Sender\<i32\> 356

23–24

from files 72–75

Sender\<T\> 356

data processing 24

from stdin 74

serde crate 214–216

desktop applications 25

references 53–54

serialization 249

extending applications 24

syntax

Serialize trait 214

mobile applications 25

defining variables and

server-side applications 25

resource-constrained

calling functions

set() type 300

environments 24–25

35–36

SetConsoleCtrlHandler handler

server-side applications 25

overview 34–36

function 417

systems programming 26

technology leaders and start-

set_extension() method 221

web browsers 26

ups that use 2–3

setjmp 408–409, 412, 417

downloading source code 8

terminology 26–27

setjmp/longjmp 411

downsides of 20–21

text processing 8–11

SetSystemTime() 313

compile times 20–21

third-party code 67–70

settimeofday function 306–308,

cyclic data structures 20

adding support for regular

313

hype 21

expressions 68–69

shared ownership 185

size of language 21

generating the third-party

shared variables 338–340

strictness 21

crate documentation

SHUT_DOWN value 401

features of 11–12, 19–20

locally 69–70

SIGCONT signal 397, 399–400,

community 26

managing toolchains with

417

concurrency 20

rustup 70

SIG_DFL 407

memory efficiency 20

TLS security case studies

SIGHUP signal 399

performance 19–20

21–23

SIGINT signal 396, 399

flow control 45–52

goto fail 22–23

SIGKILL signal 396, 398, 400,

break keyword 48–49

Heartbleed 21–22

407



signals 407–408

\_start() function 374, 377, 383

std::net::TcpStream 260

application-defined

static binaries 24

std::ops::Add 59

signals 405–406

static dispatch 256

std::ops::Fn 341, 364

applying techniques to plat-

static keyword 401

std::ops::FnMut 341

forms without signals 417

static memory 62

std::ops::FnOnce 340

defined 391–393

static methods 44, 84

std::os:raw module 182

handling 395–400

static mut 88, 401

std::path::Path 62, 220

default behavior 395–396

static values 405

std::path::PathBuf 220

listing all signals supported

static variable 405

std::path::PathBuf type 250

by OS 399–400

StatusMessage 112

std::path::Path string 221

suspending and resuming

Status opcodes 264

std::path::Path type 250

program

std::arc::Weak type 187

std::prelude module 40

operation 397–399

std::cell::RefCell type 187

std::rc::Rc\<T\> 129

with custom actions 400–405

std::cell::UnsafeCell type 187

std::rc::Weak type 185, 187

interrupts vs. 391–393

std::clone::Clone 128–129

std::String string 221

sjlj project 409

std::cmp::Eq 41

std::sync::Arc 354

casting pointers to another

std::cmp::PartialEq 38

std::sync::atomic::spin_loop

type 412–413

std::cmp::PartialOrd 38

\_hint() 338

compiling 413–414

std::collections::BTreeMap 246

std::sync::mpsc module 354

setting up intrinsics 409–412

std::collections::HashMap 224,

std::sync::Mutex 354

source code 414–415

246

std::thread::spawn() 330

sign bit, isolating 146

std::convert::From 153, 174, std::thread::yield_now() 338

significand 144

270, 272, 276, 318

std:rc::Rc. std:rc::Rc wrapper

signs 144

std::convert::TryFrom 154, 174

type 131

SIGQUIT signal 400

std::convert::TryInto 40

std:rc::Rc type 91

SIGSTOP signal 397–398, 400,

std::env::args 219, 301

std:sync::Arc type 91

407, 417

std::error::Error 274

stdin, reading from 74

SIGTERM signal 396, 399

std::error:Error 255, 292

steady clock 297

SIGTSTP signal 400

std::ffi::OsStr 221

steps variable 352

SIGUSR1 405

std::ffi::OSString 62

String 61, 81–82, 118, 183, 189–

SIGUSR2 405

std::ffi::OsString 221

190, 215, 255

Sized 188

std::fmt::Binary 139

String::from() 81

sjlj project 409

std::fmt::Debug 139

struct blocks 84

casting pointers to another

std::fmt::Display 99–102, 139, structs

type 412–413

273–274

adding methods to with

compiling 413–414

std::fs::File type 219

impl 84–87

setting up intrinsics 409–412

std::fs::OpenOptions 220

modeling files with 80–83

source code 414–415

std::fs::Path 220–222

simplifying object creation

slices, making lists with 65

std::fs::PathBuf 221

by implementing new()

smart pointers 185–187

std::io::Error 271–272

84–87

software interrupts 391, 395

std::io::Error::last_os_error() 313

str value 61, 229

Some(T) variant 177

std::io::ErrorKind::Unexpect-

suseconds_t 307

specialty types, wrapping data

edEof type 230

SVGs, generating 346

within 131–133

std::io::File 232

swapping 202

spin_loop_hint()

std::io::prelude 217

switch keyword 51

instruction 338

std::io::Read 217, 232

synchronous interrupts 391–392

src/main.rs 54

std::io::Write 232

system clock 296

SSLVerifySignedServerKey-

std::io trait 217

systems programming 2, 26

Exchange function 22

std::iter::Iterator 353, 364

SYSTEMTIME 308–309

stack 18

std::marker::Copy 129

system time 294

defined 188–190

std::marker::Copy. Copy 128

expanding CPU emulation to

std::mem::drop 192

T

include stack

std::mem::transmute()

support 167–168

function 139

target_arch attribute 227

stack frames 188

std::net::AddrParseError 271

target_endian attribute 227



target_env attribute 227

thread pools 353–360

for operating systems that

target_family attribute 227

channels 356

use libc 306–308

target_has_atomic attribute 227

implementing task

full code listing 310

target_os attribute 227

queues 358–360

on Windows 308–309

target platform 369

one-way communication

sources of time 296

target_pointer_width

354–356

teaching apps to tell

attribute 227

two-way communication

time 298–299

target_vendor attribute 228

356–358

timestamp 301

task queues,

ThreadRng 259

time_t 298

implementing 358–360

threads 330–340, 361

TimeVal 306

tasks 361

closures 330–331

timeval 306

task virtualization 360–363

effect of spawning many

time zones 298

containers 363

threads 333

TLB (translated addresses) 203

context switches 362

effect of spawning some

TLS (Transport Layer

processes 363

threads 331–332

Security) 21–23, 254

reasons for using operating

reproducing results 335–338

goto fail 22–23

systems 363

shared variables 338–340

Heartbleed 21–22

threads 362

spawning a thread per logical

to_bytes() method 387

WebAssembly 363

task 351–353

todo!() 300

TCP (Transmission Control

functional programming

toolchains 70

Protocol) 260–268

style 351–352

trait keyword 98

converting hostnames to IP

parallel iterators 352–353

trait objects 190, 256–260

addresses 261–268

spawning threads 331

defined 256

port numbers 261

task virtualization 362

function of 256

raw 282

thread::yield_now()

rpg project 257–260

TcpStream::connect() 261

method 338

traits 98–102

TcpStream type 232

time and keeping

Clone trait 130–131

Terminated 403

definitions 296–297

Copy trait 129–131

test attribute 228

encoding time 297–298

Display trait 99–102, 273–274

text output 381–383

error handling 313

Error trait 274

creating type that can print

formatting timestamps

From trait 276

to VGA frame buffer

299–305

Path trait 220–222

382–383

formatting time 301

Read trait 98–99

enums

full command-line

Write trait

controlling in-memory rep-

interface 301–303

implementing 386–387

resentation of 382

full project 303–305

reimplementing

reasons for using 382

refactoring clock code to

panic() 385–386

printing to screen 383

support a wider

translated addresses (TLB) 203

writing colored text to

architecture 300

translation lookaside buffer 206

screen 381

overview 294–295

Transmission Control Protocol.

text processing 8–11

representing time zones 298

*See* TCP

thetime_t 307

resolving differences with

Transport Layer Security. *See* TLS

Thing type 257

NTP 314–321

traps 391

third-party code 67–70

adjusting local time 316–

tree command 6

adding support for regular

318

tree map 242

expressions 68–69

converting between time

trust-dns crate 268

generating the third-party

representations that use

try! macro 270

crate documentation

different precisions and

try_into() method 40

locally 69–70

epochs 318–319

T type 59, 65, 153, 183, 189

managing toolchains with

full code listing 319–321

turtle variable 345

rustup 70

sending requests and inter-

Type annotations 9

thread::spawn() 14

preting responses

type classes 40

thread::yield_now()

314–316

type erasure 272

method 338

setting time 305–310

type keyword 81

thread of execution 361

common behavior 306

type safety 110



U

using fewer long-lived

scanning address spaces

123–126

208–210

\[u8\] type 62, 222, 232, 356

.values() method 245

translating virtual addresses

u8 type 38, 80, 382

.values_mut() variant 245

to physical addresses

u16 type 38–39

variable bindings 35

205–207

u32 type 38, 139, 146

variables

void function pointer 404

UDP (User Datagram

defining 35–36

V type 245

Protocol) 262

global variables

unbounded queues 354

signal handling with custom

W

unicast 279

actions 401–402

unikernel 363

using to indicate that shut-

wall clock time 393

unimplemented!() macro 300

down has been

Wasm (WebAssembly) 363

unit type 79

initiated 402–405

web browsers 26

UNIX timestamp 301

modifying known global

while loop 173, 336

unsafe() method 40

variables 87–91

endless looping 48

unsafe blocks 115, 139, 184, shared variables 338–340

overview 47

204, 294, 306, 401, 410, 413, Vec::new() 81

stopping iteration once a

417

Vec\<Cereal\> 13

duration is reached

unsafe keyword 88, 139, 417

Vec\<Command\> 345–346,

47–48

unsigned long int 298

360

window.draw_2d() 199

unwinding 379

Vec\<Message\> 119

Windows 308–309

.unwrap() method 94, 292

Vec\<Message\> message

API integer types 308

unwrap() method 40, 92, 219, store 125

clock code 309

264, 277

Vec\<Operation\> 345

representing time in 308

UPDATE case 95

Vec\<Result\> 354

words 202

update \<key\> \<value\> 224

Vec\<String\> 301

WORD type 308

Update opcodes 264

Vec\<T\> 190, 243, 256, 351–352, World struct 195

UpstreamError enum 275

373

wrapping data within specialty

use crate:: 364

Vec\<T\> fields 263

types 131–133

use keyword 40, 44, 157

Vec\<T\> vector 66

WriteProcessMemory() 211

--use-standard timestamp flag 299

Vec\<Task\> 354

write_str() 386

usize integers 413

vectors 63–64, 66–67

Write trait

usize type 38, 65, 165, 177, 185,

Vec\<u8\> type 62, 80, 267

implementing 386–387

406

Vec\<Vec\<(usize, String)\>\>

reimplementing panic()

usize value 404–405

66–67

385–386

U type 153

version flag 367

write_volatile() method

virtual addresses 204

376

V

virtual memory 202–211

having processes scan

Z

values

their own memory

duplicating 128–131

203–205

zero-cost abstractions 27, 98

using Clone and Copy

overview 202–203

ZST (zero-sized type) 300,

130–131

reading from and writing to

326

using Copy 129–130

process memory 211

![](media/index-457_1.png)

![](media/index-457_2.png)

![](media/index-457_3.png)

PROGRAMMING/RUST

Rust

“Th is well-written book will

IN ACTION

help you make the most of

what Rust has to off er.

Timothy Samuel McNamara

—Ramnivas Laddad ”

Rust is the perfect language for systems programming. It

author of *AspectJ in Action*

delivers the low-level power of C along with rock-solid

safety features that let you code fearlessly. Ideal for

applications requiring concurrency, Rust programs are com-

“Engaging writing style and

pact, readable, and blazingly fast. Best of all, Rust’s famously crisp, easy-to-grasp examples

smart compiler helps you avoid even subtle coding errors.

help the reader get off the

ground in no time.

Rust in Action is a hands-on guide to systems programming

”

—Sumant Tambe, Linkedin

with Rust. Written for inquisitive programmers, it presents

real-world use cases that go far beyond syntax and structure.

You’ll explore Rust implementations for fi le manipulation,

r “*Rust in Action* is

networking, and kernel-level programming and discover

emarkably polished!

—Christopher Haupt, S

”

awesome techniques for parallelism and concurrency. Along

woogo

the way, you’ll master Rust’s unique borrow checker model

for memory management without a garbage collector.

“Makes it easy to explore

the language and get

What’s Inside

going with it.

—Federico H

”

● Elementary to advanced Rust programming

ernandez

● Practical examples from systems programming

Meltwater

● Command-line, graphical and networked applications

“I highly recommend this

For intermediate programmers. No previous experience with

book to those who want

Rust required.

to learn Rust.”

—Afshin Mehrabani, Etsy

Tim McNamara uses Rust to build data processing pipelines and

generative art. He is an expert in natural language processing

and data engineering.

See first page

Register this print book to get free access to all ebook formats.

Visit https://www.manning.com/freebook

ISBN: 978-1-61729-455-6

M A N N I N G

\$59.99 / Can \$79.99 \[INCLUDING eBOOK\]

# Document Outline

- Rust in Action
- contents
- preface
- acknowledgments
- about this book
  - Who should read this book
  - How this book is organized: A roadmap
  - About the code
  - liveBook discussion forum
  - Other online resources
- about the author
- about the cover illustration
- 1 Introducing Rust
  - 1.1 Where is Rust used?
  - 1.2 Advocating for Rust at work
  - 1.3 A taste of the language
    - 1.3.1 Cheating your way to “Hello, world!”
    - 1.3.2 Your first Rust program
  - 1.4 Downloading the book’s source code
  - 1.5 What does Rust look and feel like?
  - 1.6 What is Rust?
    - 1.6.1 Goal of Rust: Safety
    - 1.6.2 Goal of Rust: Productivity
    - 1.6.3 Goal of Rust: Control
  - 1.7 Rust’s big features
    - 1.7.1 Performance
    - 1.7.2 Concurrency
    - 1.7.3 Memory efficiency
  - 1.8 Downsides of Rust
    - 1.8.1 Cyclic data structures
    - 1.8.2 Compile times
    - 1.8.3 Strictness
    - 1.8.4 Size of the language
    - 1.8.5 Hype
  - 1.9 TLS security case studies
    - 1.9.1 Heartbleed
    - 1.9.2 Goto fail;
  - 1.10 Where does Rust fit best?
    - 1.10.1 Command-line utilities
    - 1.10.2 Data processing
    - 1.10.3 Extending applications
    - 1.10.4 Resource-constrained environments
    - 1.10.5 Server-side applications
    - 1.10.6 Desktop applications
    - 1.10.7 Desktop
    - 1.10.8 Mobile
    - 1.10.9 Web
    - 1.10.10 Systems programming
  - 1.11 Rust’s hidden feature: Its community
  - 1.12 Rust phrase book
  - Summary
- Part 1—Rust language distinctives
  - 2 Language foundations
    - 2.1 Creating a running program
      - 2.1.1 Compiling single files with rustc
      - 2.1.2 Compiling Rust projects with cargo
    - 2.2 A glance at Rust’s syntax
      - 2.2.1 Defining variables and calling functions
    - 2.3 Numbers
      - 2.3.1 Integers and decimal (floating-point) numbers
      - 2.3.2 Integers with base 2, base 8, and base 16 notation
      - 2.3.3 Comparing numbers
      - 2.3.4 Rational, complex numbers, and other numeric types
    - 2.4 Flow control
      - 2.4.1 For: The central pillar of iteration
      - 2.4.2 Continue: Skipping the rest of the current iteration
      - 2.4.3 While: Looping until a condition changes its state
      - 2.4.4 Loop: The basis for Rust’s looping constructs
      - 2.4.5 Break: Aborting a loop
      - 2.4.6 If, if else, and else: Conditional branching
      - 2.4.7 Match: Type-aware pattern matching
    - 2.5 Defining functions
    - 2.6 Using references
    - 2.7 Project: Rendering the Mandelbrot set
    - 2.8 Advanced function definitions
      - 2.8.1 Explicit lifetime annotations
      - 2.8.2 Generic functions
    - 2.9 Creating grep-lite
    - 2.10 Making lists of things with arrays, slices, and vectors
      - 2.10.1 Arrays
      - 2.10.2 Slices
      - 2.10.3 Vectors
    - 2.11 Including third-party code
      - 2.11.1 Adding support for regular expressions
      - 2.11.2 Generating the third-party crate documentation locally
      - 2.11.3 Managing Rust toolchains with rustup
    - 2.12 Supporting command-line arguments
    - 2.13 Reading from files
    - 2.14 Reading from stdin
    - Summary
  - 3 Compound data types
    - 3.1 Using plain functions to experiment with an API
    - 3.2 Modeling files with struct
    - 3.3 Adding methods to a struct with impl
      - 3.3.1 Simplifying object creation by implementing new()
    - 3.4 Returning errors
      - 3.4.1 Modifying a known global variable
      - 3.4.2 Making use of the Result return type
    - 3.5 Defining and making use of an enum
      - 3.5.1 Using an enum to manage internal state
    - 3.6 Defining common behavior with traits
      - 3.6.1 Creating a Read trait
      - 3.6.2 Implementing std::fmt::Display for your own types
    - 3.7 Exposing your types to the world
      - 3.7.1 Protecting private data
    - 3.8 Creating inline documentation for your projects
      - 3.8.1 Using rustdoc to render docs for a single source file
      - 3.8.2 Using cargo to render docs for a crate and its dependencies
    - Summary
  - 4 Lifetimes, ownership, and borrowing
    - 4.1 Implementing a mock CubeSat ground station
      - 4.1.1 Encountering our first lifetime issue
      - 4.1.2 Special behavior of primitive types
    - 4.2 Guide to the figures in this chapter
    - 4.3 What is an owner? Does it have any responsibilities?
    - 4.4 How ownership moves
    - 4.5 Resolving ownership issues
      - 4.5.1 Use references where full ownership is not required
      - 4.5.2 Use fewer long-lived values
      - 4.5.3 Duplicate the value
      - 4.5.4 Wrap data within specialty types
    - Summary
- Part 2—Demystifying systems programming
  - 5 Data in depth
    - 5.1 Bit patterns and types
    - 5.2 Life of an integer
      - 5.2.1 Understanding endianness
    - 5.3 Representing decimal numbers
    - 5.4 Floating-point numbers
      - 5.4.1 Looking inside an f32
      - 5.4.2 Isolating the sign bit
      - 5.4.3 Isolating the exponent
      - 5.4.4 Isolate the mantissa
      - 5.4.5 Dissecting a floating-point number
    - 5.5 Fixed-point number formats
    - 5.6 Generating random probabilities from random bytes
    - 5.7 Implementing a CPU to establish that functions are also data
      - 5.7.1 CPU RIA/1: The Adder
      - 5.7.2 Full code listing for CPU RIA/1: The Adder
      - 5.7.3 CPU RIA/2: The Multiplier
      - 5.7.4 CPU RIA/3: The Caller
      - 5.7.5 CPU 4: Adding the rest
    - Summary
  - 6 Memory
    - 6.1 Pointers
    - 6.2 Exploring Rust’s reference and pointer types
      - 6.2.1 Raw pointers in Rust
      - 6.2.2 Rust’s pointer ecosystem
      - 6.2.3 Smart pointer building blocks
    - 6.3 Providing programs with memory for their data
      - 6.3.1 The stack
      - 6.3.2 The heap
      - 6.3.3 What is dynamic memory allocation?
      - 6.3.4 Analyzing the impact of dynamic memory allocation
    - 6.4 Virtual memory
      - 6.4.1 Background
      - 6.4.2 Step 1: Having a process scan its own memory
      - 6.4.3 Translating virtual addresses to physical addresses
      - 6.4.4 Step 2: Working with the OS to scan an address space
      - 6.4.5 Step 3: Reading from and writing to process memory
    - Summary
  - 7 Files and storage
    - 7.1 What is a file format?
    - 7.2 Creating your own file formats for data storage
      - 7.2.1 Writing data to disk with serde and the bincode format
    - 7.3 Implementing a hexdump clone
    - 7.4 File operations in Rust
      - 7.4.1 Opening a file in Rust and controlling its file mode
      - 7.4.2 Interacting with the filesystem in a type-safe manner with std::fs::Path
    - 7.5 Implementing a key-value store with a log-structured, append-only storage architecture
      - 7.5.1 The key-value model
      - 7.5.2 Introducing actionkv v1: An in-memory key-value store with a command-line interface
    - 7.6 Actionkv v1: The front-end code
      - 7.6.1 Tailoring what is compiled with conditional compilation
    - 7.7 Understanding the core of actionkv: The libactionkv crate
      - 7.7.1 Initializing the ActionKV struct
      - 7.7.2 Processing an individual record
      - 7.7.3 Writing multi-byte binary data to disk in a guaranteed byte order
      - 7.7.4 Validating I/O errors with checksums
      - 7.7.5 Inserting a new key-value pair into an existing database
      - 7.7.6 The full code listing for actionkv
      - 7.7.7 Working with keys and values with HashMap and BTreeMap
      - 7.7.8 Creating a HashMap and populating it with values
      - 7.7.9 Retrieving values from HashMap and BTreeMap
      - 7.7.10 How to decide between HashMap and BTreeMap
      - 7.7.11 Adding a database index to actionkv v2.0
    - Summary
  - 8 Networking
    - 8.1 All of networking in seven paragraphs
    - 8.2 Generating an HTTP GET request with reqwest
    - 8.3 Trait objects
      - 8.3.1 What do trait objects enable?
      - 8.3.2 What is a trait object?
      - 8.3.3 Creating a tiny role-playing game: The rpg project
    - 8.4 TCP
      - 8.4.1 What is a port number?
      - 8.4.2 Converting a hostname to an IP address
    - 8.5 Ergonomic error handling for libraries
      - 8.5.1 Issue: Unable to return multiple error types
      - 8.5.2 Wrapping downstream errors by defining our own error type
      - 8.5.3 Cheating with unwrap() and expect()
    - 8.6 MAC addresses
      - 8.6.1 Generating MAC addresses
    - 8.7 Implementing state machines with Rust’s enums
    - 8.8 Raw TCP
    - 8.9 Creating a virtual networking device
    - 8.10 “Raw” HTTP
    - Summary
  - 9 Time and timekeeping
    - 9.1 Background
    - 9.2 Sources of time
    - 9.3 Definitions
    - 9.4 Encoding time
      - 9.4.1 Representing time zones
    - 9.5 clock v0.1.0: Teaching an application how to tell the time
    - 9.6 clock v0.1.1: Formatting timestamps to comply with ISO 8601 and email standards
      - 9.6.1 Refactoring the clock v0.1.0 code to support a wider architecture
      - 9.6.2 Formatting the time
      - 9.6.3 Providing a full command-line interface
      - 9.6.4 clock v0.1.1: Full project
    - 9.7 clock v0.1.2: Setting the time
      - 9.7.1 Common behavior
      - 9.7.2 Setting the time for operating systems that use libc
      - 9.7.3 Setting the time on MS Windows
      - 9.7.4 clock v0.1.2: The full code listing
    - 9.8 Improving error handling
    - 9.9 clock v0.1.3: Resolving differences between clocks with the Network Time Protocol (NTP)
      - 9.9.1 Sending NTP requests and interpreting responses
      - 9.9.2 Adjusting the local time as a result of the server’s response
      - 9.9.3 Converting between time representations that use different precisions and epochs
      - 9.9.4 clock v0.1.3: The full code listing
    - Summary
  - 10 Processes, threads, and containers
    - 10.1 Anonymous functions
    - 10.2 Spawning threads
      - 10.2.1 Introduction to closures
      - 10.2.2 Spawning a thread
      - 10.2.3 Effect of spawning a few threads
      - 10.2.4 Effect of spawning many threads
      - 10.2.5 Reproducing the results
      - 10.2.6 Shared variables
    - 10.3 Differences between closures and functions
    - 10.4 Procedurally generated avatars from a multithreaded parser and code generator
      - 10.4.1 How to run render-hex and its intended output
      - 10.4.2 Single-threaded render-hex overview
      - 10.4.3 Spawning a thread per logical task
      - 10.4.4 Using a thread pool and task queue
    - 10.5 Concurrency and task virtualization
      - 10.5.1 Threads
      - 10.5.2 What is a context switch?
      - 10.5.3 Processes
      - 10.5.4 WebAssembly
      - 10.5.5 Containers
      - 10.5.6 Why use an operating system (OS) at all?
    - Summary
  - 11 Kernel
    - 11.1 A fledgling operating system (FledgeOS)
      - 11.1.1 Setting up a development environment for developing an OS kernel
      - 11.1.2 Verifying the development environment
    - 11.2 Fledgeos-0: Getting something working
      - 11.2.1 First boot
      - 11.2.2 Compilation instructions
      - 11.2.3 Source code listings
      - 11.2.4 Panic handling
      - 11.2.5 Writing to the screen with VGA-compatible text mode
      - 11.2.6 \_start(): The main() function for FledgeOS
    - 11.3 fledgeos-1: Avoiding a busy loop
      - 11.3.1 Being power conscious by interacting with the CPU directly
      - 11.3.2 fledgeos-1 source code
    - 11.4 fledgeos-2: Custom exception handling
      - 11.4.1 Handling exceptions properly, almost
      - 11.4.2 fledgeos-2 source code
    - 11.5 fledgeos-3: Text output
      - 11.5.1 Writing colored text to the screen
      - 11.5.2 Controlling the in-memory representation of enums
      - 11.5.3 Why use enums?
      - 11.5.4 Creating a type that can print to the VGA frame buffer
      - 11.5.5 Printing to the screen
      - 11.5.6 fledgeos-3 source code
    - 11.6 fledgeos-4: Custom panic handling
      - 11.6.1 Implementing a panic handler that reports the error to the user
      - 11.6.2 Reimplementing panic() by making use of core::fmt::Write
      - 11.6.3 Implementing core::fmt::Write
      - 11.6.4 fledge-4 source code
    - Summary
  - 12 Signals, interrupts, and exceptions
    - 12.1 Glossary
      - 12.1.1 Signals vs. interrupts
    - 12.2 How interrupts affect applications
    - 12.3 Software interrupts
    - 12.4 Hardware interrupts
    - 12.5 Signal handling
      - 12.5.1 Default behavior
      - 12.5.2 Suspend and resume a program’s operation
      - 12.5.3 Listing all signals supported by the OS
    - 12.6 Handling signals with custom actions
      - 12.6.1 Global variables in Rust
      - 12.6.2 Using a global variable to indicate that shutdown has been initiated
    - 12.7 Sending application-defined signals
      - 12.7.1 Understanding function pointers and their syntax
    - 12.8 Ignoring signals
    - 12.9 Shutting down from deeply nested call stacks
      - 12.9.1 Introducing the sjlj project
      - 12.9.2 Setting up intrinsics in a program
      - 12.9.3 Casting a pointer to another type
      - 12.9.4 Compiling the sjlj project
      - 12.9.5 sjlj project source code
    - 12.10 A note on applying these techniques to platforms without signals
    - 12.11 Revising exceptions
    - Summary
- index
  - Symbol
  - A
  - B
  - C
  - D
  - E
  - F
  - G
  - H
  - I
  - J
  - K
  - L
  - M
  - N
  - O
  - P
  - Q
  - R
  - S
  - T
  - U
  - V
  - W
  - Z