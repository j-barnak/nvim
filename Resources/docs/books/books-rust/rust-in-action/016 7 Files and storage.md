***Files and storage***

Table 7.1

The internals of four digital versions of William Shakespeare’s ***Much Ado About Nothing***

produced by Project Gutenberg. ***(continued)***

The HTML file contains a high proportion of whitespace

characters. These are indicated by white pixels. Markup

languages like HTML tend to add whitespace to aid read-

ability.

***7.2***

***Creating your own file formats for data storage***

When working with data that needs to be stored over a long time, the proper thing to do is to use a battle-tested database. Despite this, many systems use plain text files for data storage. Configuration files, for example, are commonly designed to be both human-readable and machine-readable. The Rust ecosystem has excellent support for converting data to many on-disk formats.

***7.2.1***

***Writing data to disk with serde and the bincode format***

The serde crate *ser* ializes and *de* serializes Rust values to and from many formats. Each format has its own strengths: many are human-readable, while others prefer to be compact so that they can be speedily sent across the network.

Using serde takes surprisingly little ceremony. As an example, let’s use statistics about the Nigerian city of Calabar and store those in multiple output formats. To start, let’s assume that our code contains a City struct. The serde crate provides the Serialize and Deserialize traits, and most code implements these with this derived annotation:

\#\[derive(Serialize)\]

**Provides the tooling**

struct City {

**to enable external**

name: String,

**formats to interact**

population: usize,

**with Rust code**

latitude: f64,

longitude: f64,

}

Populating that struct with data about Calabar is straightforward. This code snippet shows the implementation:

let calabar = City {

name: String::from("Calabar"),

population: 470_000,

latitude: 4.95,

longitude: 8.33,

};

***Creating your own file formats for data storage***

**215**

Now to convert that calabar variable to JSON-encoded String. Performing the conversion is one line of code:

let as_json = to_json(&calabar).unwrap();

serde understands many more formats than JSON. The code in listing 7.2 (shown later in this section) also provides similar examples for two lesser-known formats: CBOR and bincode. CBOR and bincode are more compact than JSON but at the expense of being machine-readable only.

The following shows the output, formatted for the page, that’s produced by listing 7.2. It provides a view of the bytes of the calabar variable in several encodings: **\$ cargo run**

Compiling ch7-serde-eg v0.1.0 (/rust-in-action/code/ch7/ch7-serde-eg) Finished dev \[unoptimized + debuginfo\] target(s) in 0.27s

Running \`target/debug/ch7-serde-eg\`

json:

{"name":"Calabar","population":470000,"latitude":4.95,"longitude":8.33}

cbor:

\[164, 100, 110, 97, 109, 101, 103, 67, 97, 108, 97, 98, 97, 114, 106, 112, 111, 112, 117, 108, 97, 116, 105, 111, 110, 26, 0, 7, 43, 240, 104, 108, 97, 116, 105, 116, 117, 100, 101, 251, 64, 19, 204, 204, 204, 204, 204, 205, 105, 108, 111, 110, 103, 105, 116, 117, 100, 101, 251, 64, 32, 168, 245, 194, 143, 92, 41\]

bincode:

\[7, 0, 0, 0, 0, 0, 0, 0, 67, 97, 108, 97, 98, 97, 114, 240, 43, 7, 0, 0, 0, 0, 0, 205, 204, 204, 204, 204, 204, 19, 64, 41, 92, 143, 194, 245, 168, 32, 64\]

json (as UTF-8):

{"name":"Calabar","population":470000,"latitude":4.95,"longitude":8.33}

cbor (as UTF-8):

�dnamegCalabarjpopulation+�hlatitude�@������ilongitude�@ ��\\

bincode (as UTF-8):

Calabar�+������@)\\��� @

To download the project, enter these commands in the console:

**\$ git clone https://github.com/rust-in-action/code rust-in-action** **\$ cd rust-in-action/ch7/ch7-serde-eg**

To create the project manually, create a directory structure that resembles the following snippet and populate its contents with the code in listings 7.1 and 7.2 from the ch7/ch7-serde-eg directory:

ch7-serde-eg

├── src

**216**


***Files and storage***

│

└── main.rs

**See listing 7.2.**

└── Cargo.toml

**See listing 7.1.**

Listing 7.1

Declaring dependencies and setting metadata for listing 7.2

\[package\]

name = "ch7-serde-eg"

version = "0.1.0"

authors = \["Tim McNamara \<author@rustinaction.com\>"\]

edition = "2018"

\[dependencies\]

bincode = "1"

serde = "1"

serde_cbor = "0.8"

serde_derive = "1"

serde_json = "1"

Listing 7.2

Serialize a Rust struct to multiple formats

1 use bincode::serialize as to_bincode;

**These functions are**

2 use serde_cbor::to_vec as to_cbor;

**renamed to shorten**

3 use serde_json::to_string as to_json;

**lines where used.**

4 use serde_derive::{Serialize};

5

6 \#\[derive(Serialize)\]

**Instructs the serde_derive**

7 struct City {

**crate to write the necessary**

8 name: String,

**code to carry out the**

9 population: usize,

**conversion from an in-memory**

10 latitude: f64,

**City to on-disk City**

11 longitude: f64,

12 }

13

14 fn main() {

15 let calabar = City {

16 name: String::from("Calabar"),

17 population: 470_000,

18 latitude: 4.95,

19 longitude: 8.33,

20 };

21

22 let as_json = to_json(&calabar).unwrap();

**Serializes**

23 let as_cbor = to_cbor(&calabar).unwrap();

**into different**

24 let as_bincode = to_bincode(&calabar).unwrap();

**formats**

25

26 println!("json:\n{}\n", &as_json);

27 println!("cbor:\n{:?}\n", &as_cbor);

28 println!("bincode:\n{:?}\n", &as_bincode);

29 println!("json (as UTF-8):\n{}\n",

30 String::from_utf8_lossy(as_json.as_bytes())

31 );

32 println!("cbor (as UTF-8):\n{:?}\n",

33 String::from_utf8_lossy(&as_cbor)

***Implementing a hexdump clone***

**217**

34 );

35 println!("bincode (as UTF-8):\n{:?}\n",

36 String::from_utf8_lossy(&as_bincode)

37 );

38 }

***7.3***

***Implementing a hexdump clone***

A handy utility for inspecting a file’s contents is hexdump, which takes a stream of bytes, often from a file, and then outputs those bytes in pairs of hexadecimal numbers.

Table 7.2 provides an example. As you know from previous chapters, two hexadecimal numbers can represent all digits from 0 to 255, which is the number of bit patterns representable within a single byte. We’ll call our clone fview (short for file view).

Table 7.2

**fview** in operation

fview input

fn main() {

println!("Hello, world!");

}

fview output

\[0x00000000\] 0a 66 6e 20 6d 61 69 6e 28 29 20 7b 0a 20 20 20

\[0x00000010\] 20 70 72 69 6e 74 6c 6e 21 28 22 48 65 6c 6c 6f

\[0x00000020\] 2c 20 77 6f 72 6c 64 21 22 29 3b 0a 7d

Unless you’re familiar with hexadecimal notation, the output from fview can be fairly opaque. If you’re experienced at looking at similar output, you may notice that there are no bytes above 0x7e (127). There are also few bytes less than 0x21 (33), with the exception of 0x0a (10). Ox0a represents the newline character (\n). These byte patterns are markers for a plain text input source.

Listing 7.4 provides the source code that builds the complete fview. But because a few new features of Rust need to be introduced, we’ll take a few steps to get to the full program.

We’ll start with listing 7.3, which uses a string literal as input and produces the output in table 7.2. It demonstrates the use of multiline string literals, importing the std::io traits via std::io::prelude. This enables &\[u8\] types to be read as files via the std::io::Read trait. The source for this listing is in ch7/ch7-fview-str/src/main.rs.

Listing 7.3

A hexdump clone with hard-coded input that mocks file I/O

1 use std::io::prelude::\*;

**prelude imports heavily used traits such as**

2

**Read and Write in I/O operations. It’s possible**

3 const BYTES_PER_LINE: usize = 16;

**to include the traits manually, but they’re so**

4 const INPUT: &'static \[u8\] = br#"

**common that the standard library provides this**

5 fn main() {

**convenience line to help keep your code compact.**

6 println!("Hello, world!");

7 }"#;

**Multiline string literals don’t need double quotes**

8

**escaped when built with raw string literals (the**

9 fn main() -\> std::io::Result\<()\> {

**r prefix and the \# delimiters). The additional b**

**prefix indicates that this should be treated as**

**bytes (&\[u8\]) not as UTF-8 text (&str).**

**218**


***Files and storage***

10 let mut buffer: Vec\<u8\> = vec!();

**Makes space for the**

11 INPUT.read_to_end(&mut buffer)?;

**program’s input with**

12

**an internal buffer**

13 let mut position_in_input = 0;

14 for line in buffer.chunks(BYTES_PER_LINE) {

**Reads our input and**

15 print!("\[0x{:08x}\] ", position_in_input);

**inserts it into our**

16 for byte in line {

**internal buffer**

17 print!("{:02x} ", byte);

18 }

**Writes the current**

19 println!();

**position with up to 8**

20 position_in_input += BYTES_PER_LINE;

**left-padded zeros**

21 }

22

**Shortcut for printing**

23 Ok(())

**a newline to stdout**

24 }

Now that we have seen the intended operation of fview, let’s extend its capabilities to read real files. The following listing provides a basic hexdump clone that demonstrates how to open a file in Rust and iterate through its contents. You’ll find this source in ch7/ch7-fview/src/main.rs.

Listing 7.4

Opening a file in Rust and iterating through its contents

1 use std::fs::File;

2 use std::io::prelude::\*;

3 use std::env;

**Changing this constant**

**changes the program’s**

4

**output.**

5 const BYTES_PER_LINE: usize = 16;

6

7 fn main() {

8 let arg1 = env::args().nth(1);

9

10 let fname = arg1.expect("usage: fview FILENAME"); 11

12 let mut f = File::open(&fname).expect("Unable to open file."); 13 let mut pos = 0;

14 let mut buffer = \[0; BYTES_PER_LINE\];

15

16 while let Ok(\_) = f.read_exact(&mut buffer) {

17 print!("\[0x{:08x}\] ", pos);

18 for byte in &buffer {

19 match \*byte {

20 0x00 =\> print!(". "),

21 0xff =\> print!("## "),

22 \_ =\> print!("{:02x} ", byte),

23 }

24 }

25

26 println!("");

27 pos += BYTES_PER_LINE;

28 }

29 }

***File operations in Rust***

**219**

Listing 7.4 introduces some new Rust. Let’s look at some of those constructs now:

 while let Ok(\_) { … }— With this control-flow structure, the program continues to loop until f.read_exact() returns Err, which occurs when it has run out of bytes to read.

 f.read_exact()—This method from the Read trait transfers data from the source (in our case, f) to the buffer provided as an argument. It stops when that buffer is full.

f.read_exact() provides greater control to you as a programmer for managing memory than the chunks() option used in listing 7.3, but it comes with some quirks.

If the buffer is longer than the number of available bytes to read, the file returns an error, and the state of the buffer is undefined. Listing 7.4 also includes some stylistic additions:

 *To handle command-line arguments without using third-party libraries, we make use of* *std::env::args().* It returns an iterator over the arguments provided to the program. Iterators have an nth() method, which extracts the element at the *n* th position.

 *Every iterator’s nth() method returns an Option.* When *n* is larger than the length of the iterator, None is returned. To handle these Option values, we use calls to expect().

 *The expect() method is considered a friendlier version of unwrap().* expect() takes an error message as an argument, whereas unwrap() simply panics abruptly.

Using std::env::args() directly means that input is not validated. That’s a problem in our simple example, but is something to consider for larger programs.

***7.4***

***File operations in Rust***

So far in this chapter, we have invested a lot of time considering how data is translated into sequences of bytes. Let’s spend some time considering another level of abstraction—the file. Previous chapters have covered basic operations like opening and reading from a file. This section contains some other helpful techniques, which provide more granular control.

***7.4.1***

***Opening a file in Rust and controlling its file mode***

Files are an abstraction that’s maintained by the operating system (OS). It presents a façade of names and hierarchy above a nest of raw bytes.

Files also provide a layer of security. These have attached permissions that the OS

enforces. This (in principle, at least) is what prevents a web server running under its own user account from reading files owned by others.

std::fs::File is the primary type for interacting with the filesystem. There are two methods available for creating a file: open() and create(). Use open() when you know the file already exists. Table 7.3 explains more of their differences.

**220**


***Files and storage***

Table 7.3

Creating **File** values in Rust and the effects on the underlying filesystem Return value when the

Effect on the

Return value when

Method

file already exists

underlying file

no file exists

File::open

Ok(File)\*

Opened as is in read-only mode.

Err

File::create

Ok(File)\*

All existing bytes are truncated, and

Ok(File)\*

the file is opened at the beginning

of the new file.

\* Assuming the user account has sufficient permission.

When you require more control, std::fs::OpenOptions is available. It provides the necessary knobs to turn for any intended application. Listing 7.16 provides a good example of a case where an append mode is requested. The application requires a writeable file that is also readable, and if it doesn’t already exist, it’s created. The following shows an excerpt from listing 7.16 that demonstrates the use of std::fs:OpenOptions to create a writeable file. The file is not truncated when it’s opened.

Listing 7.5

Using **std::fs:OpenOptions** to create a writeable file

**An example of the Builder pattern where**

**each method returns a new instance of the**

**Opens the file**

**OpenOptions struct with the relevant option set**

**for reading**

let f = OpenOptions::new()

**Enables writing. This line**

**isn’t strictly necessary;**

.read(true)

**it’s implied by append.**

.write(true)

.create(true)

**Creates a file at path if**

**it doesn’t already exist**

.append(true)

.open(path)?;

**Doesn’t delete content that’s**

**already written to disk**

**Opens the file at path after**

**unwrapping the intermediate Result**

***7.4.2***

***Interacting with the filesystem in a type-safe manner with***

***std::fs::Path***

Rust provides type-safe variants of str and String in its standard library: std::path:: Path and std::path::PathBuf. You can use these variants to unambiguously work with path separators in a cross-platform way. Path can address files, directories, and related abstractions, such as symbolic links. Path and PathBuf values often start their lives as plain string types, which can be converted with the from() static method: let hello = PathBuf::from("/tmp/hello.txt")

From there, interacting with these variants reveals methods that are specific to paths: hello.extension()

**Returns Some("txt")**

***File operations in Rust***

**221**

The full API is straightforward for anyone who has used code to manipulate paths before, so it won’t be fleshed out here. Still, it may be worth discussing why it’s included within the language because many languages omit this.

NOTE

As an implementation detail, std::fs::Path and std::fs::PathBuf are implemented on top of std::ffi::OsStr and std::ffi::OsString, respectively. This means that Path and PathBuf are *not* guaranteed to be UTF-8

compliant.

Why use Path rather than manipulating strings directly? Here are some good reasons for using Path:

 *Clear intent*—Path provides useful methods like set_extension() that describe the intended outcome. This can assist programmers who later read the code.

Manipulating strings doesn’t provide that level of self-documentation.

 *Portability*—Some operating systems treat filesystem paths as case-insensitive.

Others don’t. Using one operating system’s conventions can result in issues later, when users expect their host system’s conventions to be followed. Additionally, path separators are specific to operating systems and, thus, can differ.

This means that using raw strings can lead to portability issues. Comparisons require exact matches.

 *Easier debugging*—If you’re attempting to extract /tmp from the path /tmp/

hello.txt, doing it manually can introduce subtle bugs that may only appear at runtime. Further, miscounting the correct number of index values after splitting the string on / introduces a bug that can’t be caught at compile time.

To illustrate the subtle errors, consider the case of separators. Slashes are common in today’s operating systems, but those conventions took some time to become established:

 \\ is commonly used on MS Windows.

 / is the convention for UNIX-like operating systems.

 : was the path separator for the classic Mac OS.

 \> is used in the Stratus VOS operating system.

Table 7.4 compares the two strings: std::String and std::path::Path.

Table 7.4

Using **std::String** and **std::path::Path** to extract a file’s parent directory fn main() {

use std::path::PathBuf;

let hello = String::from("/tmp/

hello.txt");

fn main() {

let tmp_dir = hello.split("/").nth(0);

let mut hello = PathBuf::from("/tmp/

println!("{:?}", tmp_dir);

hello.txt");

**Truncates hello in place**

}

hello.pop();

**Mistake!**

println!("{:?}", hello.display());

**Splits hello at its backslashes,**

**Prints**

}

**then takes the 0th element of**

**Some("").**

**Success! Prints "/tmp".**

**the resulting Vec\<String\>**

**222**


***Files and storage***

Table 7.4

Using **std::String** and **std::path::Path** to extract a file’s parent directory ***(continued)***

The plain String code lets you use familiar methods,

Using path::Path doesn’t make your code immune to

but it can introduce subtle bugs that are difficult to detect

subtle errors, but it can certainly help to minimize their

at compile time. In this instance, we’ve used the wrong

likelihood. Path provides dedicated methods for com-

index number to access the parent directory (/tmp).

mon operations such as setting a file’s extension.

***7.5***

***Implementing a key-value store with a log-structured,***

***append-only storage architecture***

It’s time to tackle something larger. Let’s begin to lift the lid on database technology.

Along the way, we’ll learn the internal architecture of a family of database systems using a *log-structured, append-only* model.

Log-structured, append-only database systems are significant as case studies because these are designed to be extremely resilient while offering optimal read performance.

Despite storing data on fickle media like flash storage or a spinning hard disk drive, databases using this model are able to guarantee that data will never be lost and that backed up data files will never be corrupted.

***7.5.1***

***The key-value model***

The key-value store implemented in this chapter, actionkv, stores and retrieves sequences of bytes (\[u8\]) of arbitrary length. Each sequence has two parts: the first is a key and the second is a value. Because the &str type is represented as \[u8\] internally, table 7.5

shows the plain text notation rather than the binary equivalent.

Table 7.5

Illustrating keys and values by matching countries with their capital cities Key

Value

"Cook Islands"

"Avarua"

"Fiji"

"Suva"

"Kiribati"

"South Tarawa"

"Niue"

"Alofi"

The key-value model enables simple queries such as “What is the capital city of Fiji?”

But it doesn’t support asking broader queries such as “What is the list of capital cities for all Pacific Island states?”

***7.5.2***

***Introducing actionkv v1: An in-memory key-value store with a***

***command-line interface***

The first version of our key-value store, actionkv, exposes us to the API that we’ll use throughout the rest of the chapter and also introduces the main library code. The library code will not change as the subsequent two systems are built on top of it. Before we get to that code, though, there are some prerequisites that need to be covered.

***Implementing a key-value store with a log-structured, append-only storage architecture***

**223**

Unlike other projects in this book, this one uses the library template to start with (cargo new --lib actionkv). It has the following structure:

actionkv

├── src

│ ├── akv_mem.rs

│ └── lib.rs

└── Cargo.toml

Using a library crate allows programmers to build reusable abstractions within their projects. For our purposes, we’ll use the same lib.rs file for multiple executables. To avoid future ambiguity, we need to describe the executable binaries the actionkv project produces.

To do so, provide a bin section within two square bracket pairs (\[\[bin\]\]) to the project’s Cargo.toml file. See lines 14–16 of the following listing. Two square brackets indicate that the section can be repeated. The source for this listing is in ch7/ch7-actionkv/Cargo.toml.

Listing 7.6

Defining dependencies and other metadata

1 \[package\]

2 name = "actionkv"

3 version = "1.0.0"

4 authors = \["Tim McNamara \<author@rustinaction.com\>"\]

5 edition = "2018"

6

**Extends Rust types with extra traits to write**

**those to disk, then reads those back into a**

7 \[dependencies\]

**program in a repeatable, easy-to-use way**

8 byteorder = "1.2"

9 crc = "1.7"

**Provides the checksum functionality that we want to include**

10

11 \[lib\]

**This section of Cargo.toml lets you define a**

12 name = "libactionkv"

**name for the library you’re building. Note**

13 path = "src/lib.rs"

**that a crate can only have one library.**

14

15 \[\[bin\]\]

**A \[\[bin\]\] section, of which there can be many, defines an**

16 name = "akv_mem"

**executable file that’s built from this crate. The double square** 17 path = "src/akv_mem.rs"

**bracket syntax is required because it unambiguously**

**describes bin as having one or more elements.**

Our actionkv project will end up with several files. Figure 7.1 illustrates the relationships and how these work together to build the akv_mem executable, referred to within the \[\[bin\]\] section of the project’s Cargo.toml file.

**224**


***Files and storage***

Cargo.toml

src/lib.rs

src/akv_mem.rs

Describes

Compiles as

Compiles as

byteorder

crc

Imported by

libactionkv

Imported by

avk_mem\[.exe\]

**External**

**crates**

**Final build**

**artefact**

Figure 7.1

An outline of how the different files and their dependencies work together in the actionkv project. The project’s Cargo.toml coordinates lots of activity that ultimately results in an executable.

***7.6***

***Actionkv v1: The front-end code***

The public API of actionkv is comprised of four operations: get, delete, insert, and update. Table 7.6 describes these operations.

Table 7.6

Operations supported by actionkv v1

Command

Description

get \<key\>

Retrieves the value at key from the store

insert \<key\> \<value\>

Adds a key-value pair to the store

delete \<key\>

Removes a key-value pair from the store

update \<key\> \<value\>

Replaces an old value with a new one

Naming is difficult

To access stored key-value pairs, should the API provide a get, retrieve, or, perhaps, fetch? Should setting values be insert, store, or set? actionkv attempts to stay neutral by deferring these decisions to the API provided by std::collections:: HashMap.

The following listing, an excerpt from listing 7.8, shows the naming considerations mentioned in the preceding sidebar. For our project, we use Rust’s matching facilities to efficiently work with the command-line arguments and to dispatch to the correct internal function.

***Actionkv v1: The front-end code***

**225**

Listing 7.7

Demonstrating the public API

32 match action {

**The action command-line**

33 "get" =\> match store.get(key).unwrap() {

**argument has the type &str.**

34 None =\> eprintln!("{:?} not found", key),

35 Some(value) =\> println!("{:?}", value),

**println! needs to use the Debug**

36 },

**syntax ({:?}) because \[u8\]**

37

**contains arbitrary bytes and**

38 "delete" =\> store.delete(key).unwrap(),

**doesn’t implement Display.**

39

40 "insert" =\> {

41 let value = maybe_value.expect(&USAGE).as_ref();

**A future update that**

42 store.insert(key, value).unwrap()

**can be added for**

43 }

**compatibility with**

44

**Rust’s HashMap,**

45 "update" =\> {

**where insert**

46 let value = maybe_value.expect(&USAGE).as_ref();

**returns the old**

47 store.update(key, value).unwrap()

**value if it exists.**

48 }

49

50 \_ =\> eprintln!("{}", &USAGE),

51 }

In full, listing 7.8 presents the code for actionkv v1. Notice that the heavy lifting of interacting with the filesystem is delegated to an instance of ActionKV called store.

How ActionKV operates is explained in section 7.7. The source for this listing is in ch7/ch7-actionkv1/src/akv_mem.rs.

Listing 7.8

In-memory key-value store command-line application

1 use libactionkv::ActionKV;

**Although src/lib.rs exists within our**

2

**project, it’s treated the same as any**

3 \#\[cfg(target_os = "windows")\]

**other crate within the src/bin.rs file.**

4 const USAGE: &str = "

5 Usage:

**The cfg attribute allows Windows users**

6 akv_mem.exe FILE get KEY

**to see the correct file extension in their**

7 akv_mem.exe FILE delete KEY

**help documentation. This attribute is**

8 akv_mem.exe FILE insert KEY VALUE

**explained in the next section.**

9 akv_mem.exe FILE update KEY VALUE

10 ";

11

12 \#\[cfg(not(target_os = "windows"))\]

13 const USAGE: &str = "

14 Usage:

15 akv_mem FILE get KEY

16 akv_mem FILE delete KEY

17 akv_mem FILE insert KEY VALUE

18 akv_mem FILE update KEY VALUE

19 ";

20

21 fn main() {

22 let args: Vec\<String\> = std::env::args().collect();

23 let fname = args.get(1).expect(&USAGE);

**226**


***Files and storage***

24 let action = args.get(2).expect(&USAGE).as_ref();

25 let key = args.get(3).expect(&USAGE).as_ref();

26 let maybe_value = args.get(4);

27

28 let path = std::path::Path::new(&fname);

29 let mut store = ActionKV::open(path).expect("unable to open file"); 30 store.load().expect("unable to load data");

31

32 match action {

33 "get" =\> match store.get(key).unwrap() {

34 None =\> eprintln!("{:?} not found", key),

35 Some(value) =\> println!("{:?}", value),

36 },

37

38 "delete" =\> store.delete(key).unwrap(),

39

40 "insert" =\> {

41 let value = maybe_value.expect(&USAGE).as_ref();

42 store.insert(key, value).unwrap()

43 }

44

45 "update" =\> {

46 let value = maybe_value.expect(&USAGE).as_ref();

47 store.update(key, value).unwrap()

48 }

49

50 \_ =\> eprintln!("{}", &USAGE),

51 }

52 }

***7.6.1***

***Tailoring what is compiled with conditional compilation***

Rust provides excellent facilities for altering what is compiled depending on the *compiler target architecture*. Generally, this is the target’s OS but can be facilities provided by its CPU. Changing what is compiled depending on some compile-time condition is known as *conditional compilation*.

To add conditional compilation to your project, annotate your source code with cfg attributes. cfg works in conjunction with the target parameter provided to rustc during compilation.

Listing 7.8 provides a usage string common as quick documentation for command-line utilities for multiple operating systems. It’s replicated in the following listing, which uses conditional compilation to provide two definitions of const USAGE in the code.

When the project is built for Windows, the usage string contains a .exe file extension.

The resulting binary files include only the data that is relevant for their target.

Listing 7.9

Demonstrating the use of conditional compilation

3 \#\[cfg(target_os = "windows")\]

4 const USAGE: &str = "

5 Usage:

6 akv_mem.exe FILE get KEY

***Actionkv v1: The front-end code***

**227**

7 akv_mem.exe FILE delete KEY

8 akv_mem.exe FILE insert KEY VALUE

9 akv_mem.exe FILE update KEY VALUE

10 ";

11

12 \#\[cfg(not(target_os = "windows"))\]

13 const USAGE: &str = "

14 Usage:

15 akv_mem FILE get KEY

16 akv_mem FILE delete KEY

17 akv_mem FILE insert KEY VALUE

18 akv_mem FILE update KEY VALUE

19 ";

There is no negation operator for these matches. That is, \#\[cfg(target_os != "windows")\] does not work. Instead, there is a function-like syntax for specifying matches.

Use \#\[cfg(not(...))\] for negation. \#\[cfg(all(...))\] and \#\[cfg(any(...))\] are also available to match elements of a list. Lastly, it’s possible to tweak cfg attributes when invoking cargo or rustc via the --cfg ATTRIBUTE command-line argument.

The list of conditions that can trigger compilation changes is extensive. Table 7.7

outlines several of these.

Table 7.7

Options available to match against with **cfg** attributes

Attribute

Valid options

Notes

target_arch

aarch64, arm, mips, powerpc,

Not an exclusive list.

powerpc64, x86, x86_64

target_os

android, bitrig, dragonfly,

Not an exclusive list.

freebsd, haiku, ios, linux,

macos, netbsd, redox,

openbsd, windows

target_family

unix, windows

target_env

"", gnu, msvc, musl

This is often an empty string ("").

target_endian

big, little

target_pointer_width

32, 64

The size (in bits) of the target archi-

tecture’s pointer. Used for isize,

usize, \* const, and \* mut

types.

target_has_atomic

8, 16, 32, 64, ptr

Integer sizes that have support for

atomic operations. During atomic

operations, the CPU takes respon-

sibility for preventing race condi-

tions with shared data at the

expense of performance. The word

*atomic* is used in the sense of indi-

visible.

**228**


***Files and storage***

Table 7.7

Options available to match against with **cfg** attributes ***(continued)***

Attribute

Valid options

Notes

target_vendor

apple, pc, unknown

test

No available options; just uses a

simple Boolean check.

debug_assertions

No available options; just uses a

simple Boolean check. This attri-

bute is present for non-optimized

builds and supports the

debug_assert! macro.

***7.7***

***Understanding the core of actionkv:***

end user

***The libactionkv crate***

Interacts with

The command-line application built in section 7.6 dis-

patches its work to

akv_mem\[.exe\]

libactionkv::ActionKV. The responsi-

bilities of the ActionKV struct are to manage interactions Compiles from

with the filesystem and to encode and decode data from

src/bin.rs

the on-disk format. Figure 7.2 depicts the relationships.

Imports

***7.7.1***

***Initializing the ActionKV struct***

libactionkv

Listing 7.10, an excerpt from listing 7.8, shows the initial-

Compiles from

ization process of libactionkv::ActionKV. To create an

src/lib.rs

instance of libactionkv::ActionKV, we need to do the

following:

Figure 7.2

Relationship

1

Point to the file where the data is stored

between **libactionkv**

and other components of

2

Load an in-memory index from the data within the

the actionkv project

file

Listing 7.10

Initializing **libactionkv::ActionKV**

30 let mut store = ActionKV::open(path)

**Opens the file at path**

31 .expect("unable to open file");

32

**Creates an in-memory index by**

33 store.load().expect("unable to load data");

**loading the data from path**

Both steps return Result, which is why the calls to .expect() are also present. Let’s now look inside the code of ActionKV::open() and ActionKV::load(). open() opens the file from disk, and load() loads the offsets of any pre-existing data into an in-memory index. The code uses two type aliases, ByteStr and ByteString: type ByteStr = \[u8\];

***Understanding the core of actionkv: The libactionkv crate***

**229**

We’ll use the ByteStr type alias for data that tends to be used as a string but happens to be in a binary (raw bytes) form. Its text-based peer is the built-in str. Unlike str, ByteStr is not guaranteed to contain valid UTF-8 text.

Both str and \[u8\] (or its alias ByteStr) are seen in the wild as &str and &\[u8\] (or

&ByteStr). These are both called *slices*.

type ByteString = Vec\<u8\>;

The alias ByteString will be the workhorse when we want to use a type that behaves like a String. It’s also one that can contain arbitrary binary data. The following listing, an excerpt from listing 7.16, demonstrates the use of ActionKV::open().

Listing 7.11

Using **ActionKV::open()**

12 type ByteString = Vec\<u8\>;

**This code processes lots of Vec\<u8\> data.**

13

**Because that’s used in the same way as String**

14 type ByteStr = \[u8\];

**ByteStr is to**

**tends to be used, ByteString is a useful alias.**

15

**&str what**

16 \#\[derive(Debug, Serialize, Deserialize)\]

**ByteString**

**Instructs the compiler to generate**

17 pub struct KeyValuePair {

**is to**

**serialized code to enable writing**

18 pub key: ByteString,

**Vec\<u8\>.**

**KeyValuePair data to disk. Serialize**

19 pub value: ByteString,

**and Deserialize are explained in**

20 }

**section 7.2.1.**

21

22 \#\[derive(Debug)\]

23 pub struct ActionKV {

24 f: File,

**Maintains a mapping**

25 pub index: HashMap\<ByteString, u64\>,

**between keys and**

26 }

**file locations**

27

28 impl ActionKV {

29 pub fn open(path: &Path) -\> io::Result\<Self\> {

30 let f = OpenOptions::new()

31 .read(true)

32 .write(true)

33 .create(true)

34 .append(true)

35 .open(path)?;

36 let index = HashMap::new();

37 Ok(ActionKV { f, index })

38 }

**ActionKV::load() populates the**

**index of the ActionKV struct,**

**mapping keys to file positions.**

79 pub fn load(&mut self) -\> io::Result\<()\> {

80

81 let mut f = BufReader::new(&mut self.f);

**File::seek() returns the**

82

**number of bytes from the**

83 loop {

**start of the file. This becomes**

84 let position = f.seek(SeekFrom::Current(0))?;

**the value of the index.**

85

86 let maybe_kv = ActionKV::process_record(&mut f);

87

**ActionKV::process_record() reads a record**

88 let kv = match maybe_kv {

**in the file at its current position.**

**230**


***Files and storage***

89 Ok(kv) =\> kv,

90 Err(err) =\> {

91 match err.kind() {

92 io::ErrorKind::UnexpectedEof =\> {

**Unexpected is relative. The**

93 break;

**application might not have**

94 }

**expected to encounter the**

95 \_ =\> return Err(err),

**end of the file, but we expect**

96 }

**files to be finite, so we’ll deal**

97 }

**with that eventuality.**

98 };

99

100 self.index.insert(kv.key, position);

101 }

102

103 Ok(())

}

What is EOF?

File operations in Rust might return an error of type std::io::ErrorKind:: UnexpectedEof, but what is Eof? The end of file (EOF) is a convention that operating systems provide to applications. There is no special marker or delimiter at the end of a file within the file itself.

EOF is a zero byte (0u8). When reading from a file, the OS tells the application how many bytes were successfully read from storage. If no bytes were successfully read from disk, yet no error condition was detected, then the OS and, therefore, the application assume that EOF has been reached.

This works because the OS has the responsibility for interacting with physical devices. When a file is read by an application, the application notifies the OS that it would like to access the disk.

***7.7.2***

***Processing an individual record***

actionkv uses a published standard for its on-disk representation. It is an implementation of the Bitcask storage backend that was developed for the original implementation of the Riak database. Bitcask belongs to a family of file formats known in the literature as *Log-Structured Hash Tables*.

What is Riak?

Riak, a NoSQL database, was developed during the height of the NoSQL movement and competed against similar systems such as MongoDB, Apache CouchDB, and Tokyo Tyrant. It distinguished itself with its emphasis on resilience to failure.

Although it was slower than its peers, it guaranteed that it never lost data. That guarantee was enabled in part because of its smart choice of a data format.

***Understanding the core of actionkv: The libactionkv crate***

**231**

Bitcask lays every record in a prescribed manner. Figure 7.3 illustrates a single record in the Bitcask file format.

Fixed-width header

Variable-width key

Variable-width value

Role

Variable

name

**checksum**

**key_len**

**value_len**

**key**

**value**

Layout

Data type

u32

u32

u32

\[u8; key_len\]

\[u8; value_len\]

**Specifying an array’s type with a variable**

**is not legal Rust but is added here to**

**demonstrate the relationship between**

**the header and the body of each record.**

Figure 7.3

A single record in the Bitcask file format. To parse a record, read the header information, then use that information to read the body. Lastly, verify the body’s contents with the checksum provided in the header.

Every key-value pair is prefixed by 12 bytes. Those bytes describe its length (key_len +

val_len) and its content (checksum).

The process_record() function does the processing for this within ActionKV. It begins by reading 12 bytes that represent three integers: a checksum, the length of the key, and the length of the value. Those values are then used to read the rest of the data from disk and verify what’s intended. The following listing, an extract from listing 7.16, shows the code for this process.

Listing 7.12

Focusing on the **ActionKV::process_record()** method

43 fn process_record\<R: Read\>(

**f may be any type that implements Read, such as**

44 f: &mut R

**a type that reads files, but can also be &\[u8\].**

45 ) -\> io::Result\<KeyValuePair\> {

46 let saved_checksum =

**The byteorder crate allows**

47 f.read_u32::\<LittleEndian\>()?;

**on-disk integers to be read**

48 let key_len =

**in a deterministic manner**

49 f.read_u32::\<LittleEndian\>()?;

**as discussed in the**

50 let val_len =

**following section.**

51 f.read_u32::\<LittleEndian\>()?;

52 let data_len = key_len + val_len;

53

54 let mut data = ByteString::with_capacity(data_len as usize); 55

56 {

57 f.by_ref()

**f.by_ref() is required because take(n)**

58 .take(data_len as u64)

**creates a new Read value. Using a**

59 .read_to_end(&mut data)?;

**reference within this short-lived**

60 }

**block sidesteps ownership issues.**

**232**


***Files and storage***

61 debug_assert_eq!(data.len(), data_len as usize);

**debug_assert! tests**

62

**are disabled in**

63 let checksum = crc32::checksum_ieee(&data);

**optimized builds,**

64 if checksum != saved_checksum {

**enabling debug**

65 panic!(

**builds to have more**

66 "data corruption encountered ({:08x} != {:08x})", **runtime checks.**

67 checksum, saved_checksum

68 );

69 }

70

71 let value = data.split_off(key_len as usize);

**The split_off(n)**

72 let key = data;

**method splits a**

73

**Vec\<T\> in two**

74 Ok( KeyValuePair { key, value } )

**at n.**

75 }

**A checksum (a number) verifies that the bytes read from disk are the** **same as what was intended. This process is discussed in section 7.7.4.**

***7.7.3***

***Writing multi-byte binary data to disk in a guaranteed byte order***

One challenge that our code faces is that it needs to be able to store multi-byte data to disk in a deterministic way. This sounds easy, but computing platforms differ as to how numbers are read. Some read the 4 bytes of an i32 from left to right; others read from right to left. That could potentially be a problem if the program is designed to be written by one computer and loaded by another.

The Rust ecosystem provides some support here. The byteorder crate can extend types that implement the standard library’s std::io::Read and std::io::Write traits.

std::io::Read and std::io::Write are commonly associated with std::io::File but are also implemented by other types such as \[u8\] and TcpStream. The extensions can guarantee how multi-byte sequences are interpreted, either as little endian or big endian.

To follow what’s going on with our key-value store, it will help to have an understanding of how byteorder works. Listing 7.14 is a toy application that demonstrates the core functionality. Lines 11–23 show how to write to a file and lines 28–35 show how to read from one. The two key lines are

use byteorder::{LittleEndian};

use byteorder::{ReadBytesExt, WriteBytesExt};

byteorder::LittleEndian and its peers BigEndian and NativeEndian (not used in listing 7.14) are types that declare how multi-byte data is written to and read from disk. byteorder::ReadBytesExt and byteorder::WriteBytesExt are traits. In some sense, these are invisible within the code.

These extend methods to primitive types such as f32 and i16 without further ceremony. Bringing those into scope with a use statement immediately adds powers to the types that are implemented within the source of byteorder (in practice, that means primitive types). Rust, as a statically-typed language, makes this transformation at

***Understanding the core of actionkv: The libactionkv crate***

**233**

compile time. From the running program’s point of view, integers always have the ability to write themselves to disk in a predefined order.

When executed, listing 7.14 produces a visualization of the byte patterns that are created by writing 1_u32, 2_i8, and 3.0_f32 in little-endian order. Here’s the output:

\[1, 0, 0, 0\]

\[1, 0, 0, 0, 2\]

\[1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 8, 64\]

The following listing shows the metadata for the project in listing 7.14. You’ll find the source code for the following listing in ch7/ch7-write123/Cargo.toml. The source code for listing 7.14 is in ch7/ch7-write123/src/main.rs.

Listing 7.13

Metadata for listing 7.14

\[package\]

name = "write123"

version = "0.1.0"

authors = \["Tim McNamara \<author@rustinaction.com\>"\]

edition = "2018"

\[dependencies\]

byteorder = "1.2"

Listing 7.14

Writing integers to disk

**As files support the ability to seek(), moving backward and**

**forward to different positions, something is necessary to**

**Used as a type argument for a**

**enable a Vec\<T\> to mock being a file. io::Cursor plays**

**program’s various read\_\*()**

**that role, enabling an in-memory Vec\<T\> to be file-like.**

**and write\_\*() methods**

1 use std::io::Cursor;

2 use byteorder::{LittleEndian};

**Traits that provide**

**read\_\*() and write\_\*()**

3 use byteorder::{ReadBytesExt, WriteBytesExt};

4

5 fn write_numbers_to_file() -\> (u32, i8, f64) {

6 let mut w = vec\![\];

**The variable w**

7

**stands for writer.**

8 let one: u32 = 1;

9 let two: i8 = 2;

10 let three: f64 = 3.0;

11

12 w.write_u32::\<LittleEndian\>(one).unwrap();

**Writes values to disk. These**

13 println!("{:?}", &w);

**Single byte types i8**

**methods return io::Result, which**

14

**and u8 don’t take**

**we swallow here as these won’t**

15 w.write_i8(two).unwrap();

**an endianness**

**fail unless something is seriously**

16 println!("{:?}", &w);

**parameter.**

**wrong with the computer that’s**

17

**running the program.**

18 w.write_f64::\<LittleEndian\>(three).unwrap();

19 println!("{:?}", &w);

20

21 (one, two, three)

**234**


***Files and storage***

22 }

23

24 fn read_numbers_from_file() -\> (u32, i8, f64) {

25 let mut r = Cursor::new(vec\![1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 8, 64\]); 26 let one\_ = r.read_u32::\<LittleEndian\>().unwrap();

27 let two\_ = r.read_i8().unwrap();

28 let three\_ = r.read_f64::\<LittleEndian\>().unwrap();

29

30 (one\_, two\_, three\_)

31 }

32

33 fn main() {

34 let (one, two, three) = write_numbers_to_file();

35 let (one\_, two\_, three\_) = read_numbers_from_file();

36

37 assert_eq!(one, one\_);

38 assert_eq!(two, two\_);

39 assert_eq!(three, three\_);

40 }

***7.7.4***

***Validating I/O errors with checksums***

actionkv v1 has no method of validating that what it has read from disk is what was written to disk. What if something is interrupted during the original write? We may not be able to recover the original data if this is the case, but if we could recognize the issue, then we would be in a position to alert the user.

A well-worn path to overcome this problem is to use a technique called a *checksum*.

Here’s how it works:

 *Saving to disk*—Before data is written to disk, a checking function (there are many options as to which function) is applied to those bytes. The result of the checking function (the checksum) is written alongside the original data.

No checksum is calculated for the bytes of the checksum. If something breaks while writing the checksum’s own bytes to disk, this will be noticed later as an error.

 *Reading from disk*—Read the data and the saved checksum, applying the checking function to the data. Then compare the results of the two checking functions. If the two results do not match, an error has occurred, and the data should be considered corrupted.

Which checking function should you use? Like many things in computer science, it depends. An ideal checksum function would

 Return the same result for the same input

 Always return a different result for different inputs

 Be fast

 Be easy to implement

***Understanding the core of actionkv: The libactionkv crate***

**235**

Table 7.8 compares the different checksum approaches. To summarize

 The parity bit is easy and fast, but it is somewhat prone to error.

 CRC32 (cyclic redundancy check returning 32 bits) is much more complex, but its results are more trustworthy.

 Cryptographic hash functions are more complex still. Although being significantly slower, they provide high levels of assurance.

Table 7.8

A simplistic evaluation of different checksum functions

Checksum technique

Size of result

Simplicity

Speed

Reliability

Parity bit

1 bit

★★★★★

★★★★★

★★☆☆☆

CRC32

32 bits

★★★☆☆

★★★★☆

★★★☆☆

Cryptographic hash function

128–512 bits (or more)

★☆☆☆☆

★★☆☆☆

★★★★★

Functions that you might see in the wild depend on your application domain. More traditional areas might see the use of simpler systems, such as a parity bit or CRC32.

IMPLEMENTING PARITY BIT CHECKING

This section describes one of the simpler checksum schemes: *parity checking*. Parity checks count the number of 1s within a bitstream. These store a bit that indicates whether the count was even or odd.

Parity bits are traditionally used for error detection within noisy communication systems, such as transmitting data over analog systems such as radio waves. For example, the ASCII encoding of text has a particular property that makes it quite convenient for this scheme. Its 128 characters only require 7 bits of storage (128 = 27). That leaves 1 spare bit in every byte.

Systems can also include parity bits in larger streams of bytes. Listing 7.15 presents an (overly chatty) implementation. The parity_bit() function in lines 1–10 takes an arbitrary stream of bytes and returns a u8, indicating whether the count of the input’s bits was even or odd. When executed, listing 7.15 produces the following output: input: \[97, 98, 99\]

**input: \[97, 98, 99\] represents**

97 (0b01100001) has 3 one bits

**b"abc" as seen by the internals**

98 (0b01100010) has 3 one bits

**of the Rust compiler.**

99 (0b01100011) has 4 one bits

output: 00000001

input: \[97, 98, 99, 100\]

**input: \[97, 98, 99,**

97 (0b01100001) has 3 one bits

**100\] represents**

98 (0b01100010) has 3 one bits

**b"abcd".**

99 (0b01100011) has 4 one bits

100 (0b01100100) has 3 one bits

result: 00000000

NOTE

The code for the following listing is in ch7/ch7-paritybit/src/main.rs.

**236**


***Files and storage***

Listing 7.15

Implementing parity bit checking

**All of Rust’s integer types come equipped with**

**Takes a byte slice as the bytes**

**count_ones() and count_zeros() methods.**

**argument and returns a single**

**byte as output. This function could**

1 fn parity_bit(bytes: &\[u8\]) -\> u8 {

**have easily returned a bool value,**

2 let mut n_ones: u32 = 0;

**but returning u8 allows the result**

3

**to bit shift into some future**

4 for byte in bytes {

**desired position.**

5 let ones = byte.count_ones();

6 n_ones += ones;

7 println!("{} (0b{:08b}) has {} one bits", byte, byte, ones); 8 }

9 (n_ones % 2 == 0) as u8

**There are plenty of methods to optimize this**

10 }

**function. One fairly simple approach is to hard**

11

**code a const \[u8; 256\] array of 0s and 1s,**

12 fn main() {

**corresponding to the intended result, then**

13 let abc = b"abc";

**index that array with each byte.**

14 println!("input: {:?}", abc);

15 println!("output: {:08x}", parity_bit(abc));

16 println!();

17 let abcd = b"abcd";

18 println!("input: {:?}", abcd);

19 println!("result: {:08x}", parity_bit(abcd))

20 }

***7.7.5***

***Inserting a new key-value pair into an existing database***

As discussed in section 7.6, there are four operations that our code needs to support: insert, get, update, and delete. Because we’re using an append-only design, this means that the last two operations can be implemented as variants of insert.

You may have noticed that during load(), the inner loop continues until the end of the file. This allows more recent updates to overwrite stale data, including dele-tions. Inserting a new record is almost the inverse of process_record(), described in section 7.7.2. For example

164 pub fn insert(

165 &mut self,

166 key: &ByteStr,

167 value: &ByteStr

168 ) -\> io::Result\<()\> {

169 let position = self.insert_but_ignore_index(key, value)?;

170

171 self.index.insert(key.to_vec(), position);

**key.to_vec() converts the**

172 Ok(())

**&ByteStr to a ByteString.**

173 }

174

175 pub fn insert_but_ignore_index(

**The std::io::BufWriter type batches**

176 &mut self,

**multiple short write() calls into**

177 key: &ByteStr,

**fewer actual disk operations,**

178 value: &ByteStr

**resulting in a single one. This**

179 ) -\> io::Result\<u64\> {

**increases throughput while keeping**

**the application code neater.**

180 let mut f = BufWriter::new(&mut self.f);

181

***Understanding the core of actionkv: The libactionkv crate***

**237**

182 let key_len = key.len();

183 let val_len = value.len();

184 let mut tmp = ByteString::with_capacity(key_len + val_len); 185

186 for byte in key {

187 tmp.push(\*byte);

**Iterating through one**

188 }

**collection to populate another**

189

**is slightly awkward, but gets**

190 for byte in value {

**the job done.**

191 tmp.push(\*byte);

192 }

193

194 let checksum = crc32::checksum_ieee(&tmp);

195

196 let next_byte = SeekFrom::End(0);

197 let current_position = f.seek(SeekFrom::Current(0))?;

198 f.seek(next_byte)?;

199 f.write_u32::\<LittleEndian\>(checksum)?;

200 f.write_u32::\<LittleEndian\>(key_len as u32)?;

201 f.write_u32::\<LittleEndian\>(val_len as u32)?;

202 f.write_all(&mut tmp)?;

203

204 Ok(current_position)

205 }

***7.7.6***

***The full code listing for actionkv***

libactionkv performs the heavy lifting in our key-value stores. You have already explored much of the actionkv project throughout section 7.7. The following listing, which you’ll find in the file ch7/ch7-actionkv1/src/lib.rs, presents the project code in full.

Listing 7.16

The actionkv project (full code)

1 use std::collections::HashMap;

2 use std::fs::{File, OpenOptions};

3 use std::io;

4 use std::io::prelude::\*;

5 use std::io::{BufReader, BufWriter, SeekFrom};

6 use std::path::Path;

7

8 use byteorder::{LittleEndian, ReadBytesExt, WriteBytesExt};

9 use crc::crc32;

10 use serde_derive::{Deserialize, Serialize};

11

12 type ByteString = Vec\<u8\>;

13 type ByteStr = \[u8\];

14

15 \#\[derive(Debug, Serialize, Deserialize)\]

16 pub struct KeyValuePair {

17 pub key: ByteString,

18 pub value: ByteString,

19 }

20

**238**


***Files and storage***

21 \#\[derive(Debug)\]

22 pub struct ActionKV {

23 f: File,

24 pub index: HashMap\<ByteString, u64\>,

25 }

26

27 impl ActionKV {

28 pub fn open(

29 path: &Path

30 ) -\> io::Result\<Self\> {

31 let f = OpenOptions::new()

32 .read(true)

33 .write(true)

34 .create(true)

35 .append(true)

36 .open(path)?;

37 let index = HashMap::new();

38 Ok(ActionKV { f, index })

39 }

**process_record() assumes**

**that f is already at the right**

40

**place in the file.**

41 fn process_record\<R: Read\>(

42 f: &mut R

43 ) -\> io::Result\<KeyValuePair\> {

44 let saved_checksum =

45 f.read_u32::\<LittleEndian\>()?;

46 let key_len =

47 f.read_u32::\<LittleEndian\>()?;

48 let val_len =

49 f.read_u32::\<LittleEndian\>()?;

50 let data_len = key_len + val_len;

51

52 let mut data = ByteString::with_capacity(data_len as usize); 53

**f.by_ref() is required because .take(n)**

54 {

**creates a new Read instance. Using a**

55 f.by_ref()

**reference within this block allows us to**

56 .take(data_len as u64)

**sidestep ownership issues.**

57 .read_to_end(&mut data)?;

58 }

59 debug_assert_eq!(data.len(), data_len as usize);

60

61 let checksum = crc32::checksum_ieee(&data);

62 if checksum != saved_checksum {

63 panic!(

64 "data corruption encountered ({:08x} != {:08x})", 65 checksum, saved_checksum

66 );

67 }

68

69 let value = data.split_off(key_len as usize);

70 let key = data;

71

72 Ok(KeyValuePair { key, value })

73 }

74

75 pub fn seek_to_end(&mut self) -\> io::Result\<u64\> {

***Understanding the core of actionkv: The libactionkv crate***

**239**

76 self.f.seek(SeekFrom::End(0))

77 }

78

79 pub fn load(&mut self) -\> io::Result\<()\> {

80 let mut f = BufReader::new(&mut self.f);

81

82 loop {

83 let current_position = f.seek(SeekFrom::Current(0))?;

84

85 let maybe_kv = ActionKV::process_record(&mut f);

86 let kv = match maybe_kv {

87 Ok(kv) =\> kv,

88 Err(err) =\> {

89 match err.kind() {

90 io::ErrorKind::UnexpectedEof =\> {

**"Unexpected" is relative.**

91 break;

**The application may not**

92 }

**have expected it, but we**

93 \_ =\> return Err(err),

**expect files to be finite.**

94 }

95 }

96 };

97

98 self.index.insert(kv.key, current_position);

99 }

100

101 Ok(())

102 }

103

104 pub fn get(

105 &mut self,

106 key: &ByteStr

107 ) -\> io::Result\<Option\<ByteString\>\> {

**Wraps Option within**

108 let position = match self.index.get(key) {

**Result to allow for the**

109 None =\> return Ok(None),

**possibility of an I/O error**

110 Some(position) =\> \*position,

**as well as tolerating**

111 };

**missing values**

112

113 let kv = self.get_at(position)?;

114

115 Ok(Some(kv.value))

116 }

117

118 pub fn get_at(

119 &mut self,

120 position: u64

121 ) -\> io::Result\<KeyValuePair\> {

122 let mut f = BufReader::new(&mut self.f);

123 f.seek(SeekFrom::Start(position))?;

124 let kv = ActionKV::process_record(&mut f)?;

125

126 Ok(kv)

127 }

128

129 pub fn find(

130 &mut self,

**240**


***Files and storage***

131 target: &ByteStr

132 ) -\> io::Result\<Option\<(u64, ByteString)\>\> {

133 let mut f = BufReader::new(&mut self.f);

134

135 let mut found: Option\<(u64, ByteString)\> = None;

136

137 loop {

138 let position = f.seek(SeekFrom::Current(0))?;

139

140 let maybe_kv = ActionKV::process_record(&mut f);

141 let kv = match maybe_kv {

142 Ok(kv) =\> kv,

143 Err(err) =\> {

144 match err.kind() {

145 io::ErrorKind::UnexpectedEof =\> {

**"Unexpected" is relative.**

146 break;

**The application may not**

147 }

**have expected it, but we**

148 \_ =\> return Err(err),

**expect files to be finite.**

149 }

150 }

151 };

152

153 if kv.key == target {

154 found = Some((position, kv.value));

155 }

156

157 // important to keep looping until the end of the file, 158 // in case the key has been overwritten

159 }

160

161 Ok(found)

162 }

163

164 pub fn insert(

165 &mut self,

166 key: &ByteStr,

167 value: &ByteStr

168 ) -\> io::Result\<()\> {

169 let position = self.insert_but_ignore_index(key, value)?; 170

171 self.index.insert(key.to_vec(), position);

172 Ok(())

173 }

174

175 pub fn insert_but_ignore_index(

176 &mut self,

177 key: &ByteStr,

178 value: &ByteStr

179 ) -\> io::Result\<u64\> {

180 let mut f = BufWriter::new(&mut self.f);

181

182 let key_len = key.len();

183 let val_len = value.len();

184 let mut tmp = ByteString::with_capacity(key_len + val_len); 185

***Understanding the core of actionkv: The libactionkv crate***

**241**

186 for byte in key {

187 tmp.push(\*byte);

188 }

189

190 for byte in value {

191 tmp.push(\*byte);

192 }

193

194 let checksum = crc32::checksum_ieee(&tmp);

195

196 let next_byte = SeekFrom::End(0);

197 let current_position = f.seek(SeekFrom::Current(0))?;

198 f.seek(next_byte)?;

199 f.write_u32::\<LittleEndian\>(checksum)?;

200 f.write_u32::\<LittleEndian\>(key_len as u32)?;

201 f.write_u32::\<LittleEndian\>(val_len as u32)?;

202 f.write_all(&tmp)?;

203

204 Ok(current_position)

205 }

206

207 \#\[inline\]

208 pub fn update(

209 &mut self,

210 key: &ByteStr,

211 value: &ByteStr

212 ) -\> io::Result\<()\> {

213 self.insert(key, value)

214 }

215

216 \#\[inline\]

217 pub fn delete(

218 &mut self,

219 key: &ByteStr

220 ) -\> io::Result\<()\> {

221 self.insert(key, b"")

222 }

223 }

If you’ve made it this far, you should congratulate yourself. You’ve implemented a key-value store that will happily store and retrieve whatever you have to throw at it.

***7.7.7***

***Working with keys and values with HashMap and BTreeMap***

Working with key-value pairs happens in almost every programming language. For the tremendous benefit of learners everywhere, this task and the data structures that support it have many names:

 You might encounter someone with a computer science background who prefers to use the term *hash table*.

 Perl and Ruby call these *hashes*.

 Lua does the opposite and uses the term *table*.

**242**


***Files and storage***

 Many communities name the structure after a metaphor such as a *dictionary* or a *map*.

 Other communities prefer naming based on the role that the structure plays.

 PHP describes these as *associative arrays*.

 JavaScript’s objects tend to be implemented as a key-value pair collection and so the generic term *object* suffices.

 Static languages tend to name these according to how they are implemented.

 C++ and Java distinguish between a *hash map* and a *tree map*.

Rust uses the terms HashMap and BTreeMap to define two implementations of the same abstract data type. Rust is closest to C++ and Java in this regard. In this book, the terms *collection of key-value pairs* and *associative array* refer to the abstract data type. *Hash table* refers to associative arrays implemented with a hash table, and a HashMap refers to Rust’s implementation of hash tables.

What is a hash? What is hashing?

If you’ve ever been confused by the term *hash*, it may help to understand that this relates to an implementation decision made to enable non-integer keys to map to values. Hopefully, the following definitions will clarify the term:

 *A HashMap is implemented with a hash function.* Computer scientists will understand that this implies a certain behavior pattern in common cases. A hash map has a constant time lookup in general, formally denoted as O(1) in big O

notation. (Although a hash map’s performance can suffer when its underlying hash function encounters some pathological cases as we’ll see shortly.)

 *A hash function maps between values of variable-length to fixed-length.* In practice, the return value of a hash function is an integer. That fixed-width value can then be used to build an efficient lookup table. This internal lookup table is known as a *hash table*.

The following example shows a basic hash function for &str that simply interprets the first character of a string as an unsigned integer. It, therefore, uses the first character of the string as an hash value:

**The .chars() iterator converts**

**the string into a series of char**

fn basic_hash(key: &str) -\> u32 {

**values, each 4 bytes long.**

let first = key.chars()

**Returns an Option that’s**

.next()

**either Some(char) or None**

.unwrap_or('\0'); **for empty strings**

unsafe {

**Interprets the memory**

std::mem::transmute::\<char, u32\>(first)

**of first as an u32, even**

}

**though its type is char**

}

**If an empty string, provides NULL as the default.**

**unwrap_or() behaves as unwrap() but provides a value**

**rather than panicking when it encounters None.**

***Understanding the core of actionkv: The libactionkv crate***

**243**

basic_hash can take any string as input—an infinite set of possible inputs—and return a fixed-width result for all of those in a deterministic manner. That’s great! But, although basic_hash is fast, it has some significant faults.

If multiple inputs start with the same character (for example, *Tonga* and *Tuvalu*), these result in the same output. This happens in every instance when an infinite input space is mapped into a finite space, but it’s particularly bad here. Natural language text is not uniformly distributed.

Hash tables, including Rust’s HashMap, deal with this phenomenon, which is called a *hash collision*. These provide a backup location for keys with the same hash value.

That secondary storage is typically a Vec\<T\> that we’ll call the *collision store*. When collisions occur, the collision store is scanned from front to back when it is accessed.

That linear scan takes longer and longer to run as the store’s size increases. Attack-ers can make use of this characteristic to overload the computer that is performing the hash function.

In general terms, faster hash functions do less work to avoid being attacked. These will also perform best when their inputs are within a defined range.

Fully understanding the internals of how hash tables are implemented is too much detail for this sidebar. But it’s a fascinating topic for programmers who want to extract optimum performance and memory usage from their programs.

***7.7.8***

***Creating a HashMap and populating it with values***

The next listing provides a collection of key-value pairs encoded as JSON. It uses some Polynesian island nations and their capital cities to show the use of an associative array.

Listing 7.17

Demonstrating the use of an associative array in JSON notation

{

"Cook Islands": "Avarua",

"Fiji": "Suva",

"Kiribati": "South Tarawa",

"Niue": "Alofi",

"Tonga": "Nuku'alofa",

"Tuvalu": "Funafuti"

}

Rust does not provide a literal syntax for HashMap within the standard library. To insert items and get them out again, follow the example provided in listing 7.18, whose source is available in ch7/ch7-pacific-basic/src/main.rs. When executed, listing 7.18

produces the following line in the console:

Capital of Tonga is: Nuku'alofa

Listing 7.18

An example of the basic operations of **HashMap**

1 use std::collections::HashMap;

2

3 fn main() {

**244**


***Files and storage***

4 let mut capitals = HashMap::new();

**Type declarations of keys and**

5

**values are not required here**

6 capitals.insert("Cook Islands", "Avarua"); **as these are inferred by the**

7 capitals.insert("Fiji", "Suva");

**Rust compiler.**

8 capitals.insert("Kiribati", "South Tarawa"); 9 capitals.insert("Niue", "Alofi");

10 capitals.insert("Tonga", "Nuku'alofa"); **HashMap implements Index,**

11 capitals.insert("Tuvalu", "Funafuti");

**which allows for values to**

12

**be retrieved via the square**

13 let tongan_capital = capitals\["Tonga"\];

**bracket indexing style.**

14

15 println!("Capital of Tonga is: {}", tongan_capital); 16 }

Writing everything out as method calls can feel needlessly verbose at times. With some support from the wider Rust ecosystem, it’s possible to inject JSON string literals into Rust code. It’s best that the conversion is done at compile time, meaning no loss of runtime performance. The output of listing 7.19 is also a single line: **Uses double quotes because the json!**

Capital of Tonga is: "Nuku'alofa"

**macro returns a wrapper around**

**String, its default representation**

The next listing uses a serde-json crate to include JSON literals within your Rust source code. Its source code is in the ch7/ch7-pacific-json/src/main.rs file.

Listing 7.19

Including JSON literals with serde-json

1 \#\[macro_use\]

**Incorporates the serde_json crate**

2 extern crate serde_json;

**and makes use of its macros, bringing**

3

**the json! macro into scope**

4 fn main() {

5 let capitals = json!({

**json! takes a JSON literal and some**

6 "Cook Islands": "Avarua",

**Rust expressions to implement String**

7 "Fiji": "Suva",

**values. It converts these into a Rust**

8 "Kiribati": "South Tarawa",

**value of type serde_json::Value, an**

9 "Niue": "Alofi",

**enum that can represent every type**

10 "Tonga": "Nuku'alofa",

**within the JSON specification.**

11 "Tuvalu": "Funafuti"

12 });

13

14 println!("Capital of Tonga is: {}", capitals\["Tonga"\]) 15 }

***7.7.9***

***Retrieving values from HashMap and BTreeMap***

The main advantage that a key-value store provides is the ability to access its values.

There are two ways to achieve this. To demonstrate, let’s assume that we have initialized capitals from listing 7.19. The approach (already demonstrated) is to access values via square brackets:

capitals\["Tonga"\]

**Returns "Nuku’alofa"**

***Understanding the core of actionkv: The libactionkv crate***

**245**

This approach returns a read-only reference to the value, which is deceptive when dealing with examples containing string literals because their status as references is somewhat disguised. In the syntax used by Rust’s documentation, this is described as

&V, where & denotes a read-only reference and V is the type of the value. If the key is not present, the program will panic.

NOTE

Index notation is supported by all types that implement the Index trait.

Accessing capitals\["Tonga"\] is syntactic sugar for capitals.index("Tonga").

It’s also possible to use the .get() method on HashMap. This returns an Option\<&V\>, providing the opportunity to recover from cases where values are missing. For example capitals.get("Tonga")

**Returns Some("Nuku’alofa")**

Other important operations supported by HashMap include

 Deleting key-value pairs with the .remove() method

 Iterating over keys, values, and key-value pairs with the .keys(), .values(), and

.iter() methods, respectively, as well as their read-write variants, .keys_mut(),

.values_mut(), and .iter_mut()

There is no method for iterating through a subset of the data. For that, we need to use BTreeMap.

***7.7.10***

***How to decide between HashMap and BTreeMap***

If you’re wondering about which backing data structure to choose, here is a simple guideline: use HashMap unless you have a good reason to use BTreeMap. BTreeMap is faster when there is a natural ordering between the keys, and your application makes use of that arrangement. Table 7.9 highlights the differences.

Let’s demonstrate these two use cases with a small example from Europe. The Dutch East India Company, known as VOC after the initials of its Dutch name, Ver-eenigde Oostindische Compagnie, was an extremely powerful economic and political force at its peak. For two centuries, VOC was a dominant trader between Asia and Europe. It had its own navy and currency, and established its own colonies (called trading posts). It was also the first company to issue bonds. In the beginning, investors from six business chambers (kamers) provided capital for the business.

Let’s use these investments as key-value pairs. When listing 7.20 is compiled, it produces an executable that generates the following output:

**\$ cargo run -q**

Rotterdam invested 173000

Hoorn invested 266868

Delft invested 469400

Enkhuizen invested 540000

Middelburg invested 1300405

Amsterdam invested 3697915

smaller chambers: Rotterdam Hoorn Delft

**246**


***Files and storage***

Listing 7.20

Demonstrating range queries and ordered iteration of **BTreeMap** 1 use std::collections::BTreeMap;

2

3 fn main() {

4 let mut voc = BTreeMap::new();

5

6 voc.insert(3_697_915, "Amsterdam");

7 voc.insert(1_300_405, "Middelburg");

8 voc.insert( 540_000, "Enkhuizen");

9 voc.insert( 469_400, "Delft");

10 voc.insert( 266_868, "Hoorn");

11 voc.insert( 173_000, "Rotterdam");

12

13 for (guilders, kamer) in &voc {

**BTreeMap lets you**

14 println!("{} invested {}", kamer, guilders);

**select a portion of**

15 }

**the keys that are**

**Prints in**

16

**iterated through**

**sorted**

17 print!("smaller chambers: ");

**with the range**

**order**

18 for (\_guilders, kamer) in voc.range(0..500_000) {

**syntax.**

19 print!("{} ", kamer);

20 }

21 println!("");

}

Table 7.9

Deciding on which implementation to use to map keys to values

std::collections::HashMap with a

Cryptographically secure and resistant to denial

default hash function (known as SipHash

of service attacks but slower than alternative hash

in the literature)

functions

std::collections::BTreeMap

Useful for keys with an inherent ordering, where

cache coherence can provide a boost in speed

***7.7.11***

***Adding a database index to actionkv v2.0***

Databases and filesystems are much larger pieces of software than single files. There is a large design space involved with storage and retrieval systems, which is why new ones are always being developed. Common to all of those systems, however, is a component that is the real smarts behind the database.

Built in section 7.5.2, actionkv v1 contains a major issue that prevents it from having a decent startup time. Every time it’s run, it needs to rebuild its index of where keys are stored. Let’s add the ability for actionkv to store its own data that indexes *within* the same file that’s used to store its application data. It will be easier than it sounds. No changes to libactionkv are necessary. And the front-end code only requires minor additions. The project folder now has a new structure with an extra file (shown in the following listing).

***Understanding the core of actionkv: The libactionkv crate***

**247**

Listing 7.21

The updated project structure for actionkv v2.0

actionkv

**New file included**

├── src

**in the project**

│ ├── akv_disk.rs

│ ├── akv_mem.rs

**Two updates that add a new**

│

**binary and dependencies**

└── lib.rs

└──

**are required in Cargo.toml.**

Cargo.toml

The project’s Cargo.toml adds some new dependencies along with a second \[\[bin\]\]

entry, as the last three lines of the following listing show. The source for this listing is in ch7/ch7-actionkv2/Cargo.toml.

Listing 7.22

Updating the Cargo.toml file for actionkv v2.0

\[package\]

name = "actionkv"

version = "2.0.0"

authors = \["Tim McNamara \<author@rustinaction.com\>"\]

edition = "2018"

\[dependencies\]

bincode = "1"

byteorder = "1"

**New dependencies to**

crc = "1"

**assist with writing**

serde = "1"

**the index to disk**

serde_derive = "1"

\[lib\]

name = "libactionkv"

path = "src/lib.rs"

\[\[bin\]\]

name = "akv_mem"

path = "src/akv_mem.rs"

\[\[bin\]\]

name = "akv_disk"

**New executable**

path = "src/akv_disk.rs"

**definition**

When a key is accessed with the get operation, to find its location on disk, we first need to load the index from disk and convert it to its in-memory form. The following listing is an excerpt from listing 7.24. The on-disk implementation of actionkv includes a hidden INDEX_KEY value that allows it to quickly access other records in the file.

Listing 7.23

Highlighting the main change from listing 7.8

**INDEX_KEY is an internal hidden name**

48 match action {

**Two unwrap() calls are required**

**of the index within the database.**

49 "get" =\> {

**because a.index is a HashMap**

50 let index_as_bytes = a.get(&INDEX_KEY)

**that returns Option, and values**

51 .unwrap()

**themselves are stored within an**

52 .unwrap();

**Option to facilitate possible**

**future deletes.**

**248**


***Files and storage***

53

54 let index_decoded = bincode::deserialize(&index_as_bytes); 55

56 let index: HashMap\<ByteString, u64\> = index_decoded.unwrap(); 57

58 match index.get(key) {

**Retrieving a value**

59 None =\> eprintln!("{:?} not found", key),

**now involves fetching**

60 **Some(&i) =\> {**

**the index first, then**

61 **let kv = a.get_at(i).unwrap();**

**identifying the correct**

62 **println!("{:?}", kv.value)**

**location on disk.**

63 }

64 }

65 }

The following listing shows a key-value store that persists its index data between runs.

The source for this listing is in ch7/ch7-actionkv2/src/akv_disk.rs.

Listing 7.24

Persisting index data between runs

1 use libactionkv::ActionKV;

2 use std::collections::HashMap;

3

4 \#\[cfg(target_os = "windows")\]

5 const USAGE: &str = "

6 Usage:

7 akv_disk.exe FILE get KEY

8 akv_disk.exe FILE delete KEY

9 akv_disk.exe FILE insert KEY VALUE

10 akv_disk.exe FILE update KEY VALUE

11 ";

12

13 \#\[cfg(not(target_os = "windows"))\]

14 const USAGE: &str = "

15 Usage:

16 akv_disk FILE get KEY

17 akv_disk FILE delete KEY

18 akv_disk FILE insert KEY VALUE

19 akv_disk FILE update KEY VALUE

20 ";

21

22 type ByteStr = \[u8\];

23 type ByteString = Vec\<u8\>;

24

25 fn store_index_on_disk(a: &mut ActionKV, index_key: &ByteStr) {

26 a.index.remove(index_key);

27 let index_as_bytes = bincode::serialize(&a.index).unwrap(); 28 a.index = std::collections::HashMap::new();

29 a.insert(index_key, &index_as_bytes).unwrap();

30 }

31

32 fn main() {

33 const INDEX_KEY: &ByteStr = b"+index";

34

35 let args: Vec\<String\> = std::env::args().collect();

***Summary***

**249**

36 let fname = args.get(1).expect(&USAGE);

37 let action = args.get(2).expect(&USAGE).as_ref();

38 let key = args.get(3).expect(&USAGE).as_ref();

39 let maybe_value = args.get(4);

40

41 let path = std::path::Path::new(&fname);

42 let mut a = ActionKV::open(path).expect("unable to open file"); 43

44 a.load().expect("unable to load data");

45

46 match action {

47 "get" =\> {

48 let index_as_bytes = a.get(&INDEX_KEY)

49 .unwrap()

50 .unwrap();

51

52 let index_decoded = bincode::deserialize(&index_as_bytes); 53

54 let index: HashMap\<ByteString, u64\> = index_decoded.unwrap(); 55

56 match index.get(key) {

57 None =\> eprintln!("{:?} not found", key), 58 Some(&i) =\> {

59 let kv = a.get_at(i).unwrap();

60 println!("{:?}", kv.value)

**To print values, we need to**

61 }

**use Debug as an \[u8\] value**

62 }

**contains arbitrary bytes.**

63 }

64

65 "delete" =\> a.delete(key).unwrap(),

66

67 "insert" =\> {

68 let value = maybe_value.expect(&USAGE).as_ref();

69 a.insert(key, value).unwrap();

70 store_index_on_disk(&mut a, INDEX_KEY);

71 }

**The index must**

72

**also be updated**

73 "update" =\> {

**whenever the**

74 let value = maybe_value.expect(&USAGE).as_ref();

**data changes.**

75 a.update(key, value).unwrap();

76 store_index_on_disk(&mut a, INDEX_KEY);

77 }

78 \_ =\> eprintln!("{}", &USAGE),

79 }

80 }

***Summary***

 Converting between in-memory data structures and raw byte streams to be stored in files or sent over the network is known as *serialization* and *deserialization*. In Rust, serde is the most popular choice for these two tasks.

 Interacting with the filesystem almost always implies handling std::io::Result

. Result is used for errors that are not part of normal control flow.

**250**


***Files and storage***

 Filesystem paths have their own types: std::path::Path and std::path:: PathBuf. While it adds to the learning burden, implementing these allows you to avoid common mistakes that can occur by treating paths directly as strings.

 To mitigate the risk of data corruption during transit and storage, use checksums and parity bits.

 Using a library crate makes it easier to manage complex software projects. Libraries can be shared between projects, and you can make these more modular.

 There are two primary data structures for handling key-value pairs within the Rust standard library: HashMap and BTreeMap. Use HashMap unless you know that you want to make use of the features offered by BTreeMap.

 The cfg attribute and cfg! macro allow you to compile platform-specific code.

 To print to standard error (stderr), use the eprintln! macro. Its API is identical to the println! macro that is used to print to standard output (stdout).

 The Option type is used to indicate when values may be missing, such as asking for an item from an empty list.

*Networking*

***This chapter covers***

 Implementing a networking stack

 Handling multiple error types within local scope

 When to use trait objects

 Implementing state machines in Rust

This chapter describes how to make HTTP requests multiple times, stripping away a layer of abstraction each time. We start by using a user-friendly library, then boil that away until we’re left with manipulating raw TCP packets. When we’re finished, you’ll be able to distinguish an IP address from a MAC address. And you’ll learn why we went straight from IPv4 to IPv6.

You’ll also learn lots of Rust in this chapter, most of it related to advanced error handling techniques that become essential for incorporating upstream crates. Several pages are devoted to error handling. This includes a thorough introduction to trait objects.

Networking is a difficult subject to cover in a single chapter. Each layer is a fractal of complexity. Networking experts will hopefully overlook my lack of depth in treating such a diverse topic.

**251**

**252**

CHAPTER 8