*Introducing Rust*

***This chapter covers***

 Introducing Rust’s features and goals

 Exposing Rust’s syntax

 Discussing where to use Rust and when to

avoid it

 Building your first Rust program

 Explaining how Rust compares to object-oriented

and wider languages

Welcome to Rust—the empowering programming language. Once you scratch its surface, you will not only find a programming language with unparalleled speed and safety, but one that is enjoyable enough to use every day.

When you begin to program in Rust, it’s likely that you will want to continue to do so. And this book, *Rust in Action*, will build your confidence as a Rust programmer. But it will not teach you how to program from the beginning. This book is intended to be read by people who are considering Rust as their next language and for those who enjoy implementing practical working examples. Here is a list of some of the larger examples this book includes:

 Mandelbrot set renderer

 A grep clone



CHAPTER 1

***Introducing Rust***

 CPU emulator

 Generative art

 A database

 HTTP, NTP, and hexdump clients

 LOGO language interpreter

 Operating system kernel

As you may gather from scanning through that list, reading this book will teach you more than just Rust. It also introduces you to *systems programming* and *low-level programming*. As you work through *Rust in Action*, you’ll learn about the role of an operating system (OS), how a CPU works, how computers keep time, what pointers are, and what a data type is. You will gain an understanding of how the computer’s internal systems interoperate. Learning more than syntax, you will also see why Rust was created and the challenges that it addresses.

***1.1***

***Where is Rust used?***

Rust has won the “most loved programming language” award in Stack Overflow’s annual developer survey every year in 2016-2020. Perhaps that’s why large technology leaders such as the following have adopted Rust:

 Amazon Web Services (AWS) has used Rust since 2017 for its serverless computing offerings, AWS Lambda and AWS Fargate. With that, Rust has gained further inroads. The company has written the Bottlerocket OS and the AWS Nitro System to deliver its Elastic Compute Cloud (EC2) service.1

 Cloudflare develops many of its services, including its public DNS, serverless computing, and packet inspection offerings with Rust.2

 Dropbox rebuilt its backend warehouse, which manages exabytes of storage, with Rust.3

 Google develops parts of Android, such as its Bluetooth module, with Rust. Rust is also used for the crosvm component of Chrome OS and plays an important role in Google’s new operating system, Fuchsia.4

 Facebook uses Rust to power Facebook’s web, mobile, and API services, as well as parts of HHVM, the HipHop virtual machine used by the Hack programming language.5

 Microsoft writes components of its Azure platform including a security daemon for its Internet of Things (IoT) service in Rust.6

1 See “How our AWS Rust team will contribute to Rust’s future [successes,” http://mng.bz/BR4J](http://mng.bz/BR4J).

2 See “Rust at Cloudflare,” [https://news.ycombinator.com/item?id=17077358.](https://news.ycombinator.com/item?id=17077358)

3 See “The Epic Story of Dropbox’s Exodus From the Amazon Cloud Empire,” [http://mng.bz/d45Q.](http://mng.bz/d45Q)

4 See “Google joins the Rust Foundation,” <http://mng.bz/ryOX>.

5 See “HHVM 4.20.0 and 4.20.1,” <https://hhvm.com/blog/2019/08/27/hhvm-4.20.0.html>.

6 S[ee https://github.com/Azure/iotedge/tree/master/edgelet.](https://github.com/Azure/iotedge/tree/master/edgelet)

***Advocating for Rust at work***


 Mozilla uses Rust to enhance the Firefox web browser, which contains 15 million lines of code. Mozilla’s first two Rust-in-Firefox projects, its MP4 metadata parser and text encoder/decoder, led to overall performance and stability improvements.

 GitHub’s npm, Inc., uses Rust to deliver “upwards of 1.3 billion package downloads per day.”7

 Oracle developed a container runtime with Rust to overcome problems with the Go reference implementation.8

 Samsung, via its subsidiary SmartThings, uses Rust in its *Hub*, which is the firmware backend for its Internet of Things (IoT) service.

Rust is also productive enough for fast-moving startups to deploy it. Here are a few examples:

 Sourcegraph uses Rust to serve syntax highlighting across all of its languages.9

 Figma employs Rust in the performance-critical components of its multi-player server.10

 Parity develops its client to the Ethereum blockchain with Rust.11

***1.2***

***Advocating for Rust at work***

What is it like to advocate for Rust at work? After overcoming the initial hurdle, it tends to go well. A 2017 discussion, reprinted below, provides a nice anecdote. One member of Google’s Chrome OS team discusses what it was like to introduce the language to the project:12

indy on Sept 27, 2017

Is Rust an officially sanctioned language at Google?

zaxcellent on Sept 27, 2017

Author here: Rust is not officially sanctioned at Google, but there are pockets of folks using it here. The trick with using Rust in this component was convincing my coworkers that no other language was right for job, which I believe to be the case in this instance.

That being said, there was a ton of work getting Rust to play nice within the Chrome OS build environment. The Rust folks have been super helpful in answering my questions though.

ekidd on Sept 27, 2017

\> The trick with using Rust in this component was convincing my 7

See “Rust Case Study: Community makes Rust an easy choice for npm,” <http://mng.bz/xm9B>.

8

See “Building a Container Runtime in Rust,” [http://mng.bz/d40Q.](http://mng.bz/d40Q)

9

See “HTTP code syntax highlighting server written in Rust,” [https://github.com/sourcegraph/syntect_server.](https://github.com/sourcegraph/syntect_server)

10 See “Rust in Production at Figma, [” https://www.figma.com/blog/rust-in-production-at-figma/.](https://www.figma.com/blog/rust-in-production-at-figma/)

11 See “The fast, light, and robust EVM and WASM clie[nt,” https://github.com/paritytech/parity-ethereum.](https://github.com/paritytech/parity-ethereum)

12 See “Chrome OS KVM—A component written in [Rust,” https://news.ycombinator.com/item?id=15346557](https://news.ycombinator.com/item?id=15346557).




\> coworkers that no other language was right for job, which I believe

\> to be the case in this instance.

I ran into a similar use case in one of my own projects—a vobsub subtitle decoder, which parses complicated binary data, and which I someday want to run as web service. So obviously, I want to ensure that there are no vulnerabilities in my code.

I wrote the code in Rust, and then I used 'cargo fuzz' to try and find vulnerabilities. After running a billion(!) fuzz iterations, I found 5 bugs (see the 'vobsub' section of the trophy case for a list https:/ /github.com/rust-fuzz/trophy-case).

Happily, not \_one\_ of those bugs could actually be escalated into an actual exploit. In each case, Rust's various runtime checks

successfully caught the problem and turned it into a controlled panic.

(In practice, this would restart the web server cleanly.)

So my takeaway from this was that whenever I want a language (1) with no GC, but (2) which I can trust in a security-critical context, Rust is an excellent choice. The fact that I can statically link Linux binaries (like with Go) is a nice plus.

Manishearth on Sept 27, 2017

\> Happily, not one of those bugs could actually be escalated into

\> an actual exploit. In each case, Rust's various runtime checks

\> successfully caught the problem and turned it into a controlled

\> panic.

This has been more or less our experience with fuzzing rust code in firefox too, fwiw. Fuzzing found a lot of panics (and debug

assertions / "safe" overflow assertions). In one case it actually found a bug that had been under the radar in the analogous Gecko code for around a decade.

From this excerpt, we can see that language adoption has been “bottom up” by engineers looking to overcome technical challenges in relatively small projects. Experience gained from these successes is then used as evidence to justify undertaking more ambitious work.

In the time since late 2017, Rust has continued to mature and strengthen. It has become an accepted part of Google’s technology landscape, and is now an officially sanctioned language within the Android and Fuchsia operating systems.

***1.3***

***A taste of the language***

This section gives you a chance to experience Rust firsthand. It demonstrates how to use the compiler and then moves on to writing a quick program. We tackle full projects in later chapters.

NOTE

To install Rust, use the official installers provided at <https://rustup.rs/>.



***1.3.1***

***Cheating your way to “Hello, world!”***

The first thing that most programmers do when they reach for a new programming language is to learn how to print “Hello, world!” to the console. You’ll do that too, but with flair. You’ll verify that everything is in working order *before* you encounter annoying syntax errors.

If you use Windows, open the Rust command prompt that is available in the Start menu after installing Rust. Then execute this command:

**C:\\\> cd %TMP%**

If you are running Linux or macOS, open a Terminal window. Once open, enter the following:

**\$ cd \$TMP**

From this point forward, the commands for all operating systems should be the same.

If you installed Rust correctly, the following three commands will display “Hello, world!” on the screen (as well as a bunch of other output):

**\$ cargo new hello**

**\$ cd hello**

**\$ cargo run**

Here is an example of what the entire session looks like when running cmd.exe on MS

Windows:

**C:\\\> cd %TMP%**

**C:\Users\Tim\AppData\Local\Temp\\\> cargo new hello**

Created binary (application) \`hellò project

**C:\Users\Tim\AppData\Local\Temp\\\> cd hello**

**C:\Users\Tim\AppData\Local\Temp\hello\\\> cargo run**

Compiling hello v0.1.0 (file:/ / /C:/Users/Tim/AppData/Local/Temp/hello) Finished dev \[unoptimized + debuginfo\] target(s) in 0.32s

Running \`target\debug\hello.exè

Hello, world!

And on Linux or macOS, your console would look like this:

**\$ cd \$TMP**

**\$ cargo new hello**

Created binary (application) \`hellò package

**\$ cd hello**

**\$ cargo run**

Compiling hello v0.1.0 (/tmp/hello)




Finished dev \[unoptimized + debuginfo\] target(s) in 0.26s

Running \`target/debug/hellò

Hello, world!

If you have made it this far, fantastic! You have run your first Rust code without needing to write any Rust. Let’s take a look at what just happened.

Rust’s cargo tool provides both a build system and a package manager. That means cargo knows how to convert your Rust code into executable binaries and also can manage the process of downloading and compiling the project’s dependencies.

cargo new creates a project for you that follows a standard template. The tree command can reveal the default project structure and the files that are created after issuing cargo new:

**\$ tree hello**

hello

├── Cargo.toml

└── src

└── main.rs

1 directory, 2 files

All Rust projects created with cargo have the same structure. In the base directory, a file called Cargo.toml describes the project’s metadata, such as the project’s name, its version, and its dependencies. Source code appears in the src directory. Rust source code files use the .rs filename extension. To view the files that cargo new creates, use the tree command.

The next command that you executed was cargo run. This line is much simpler to grasp, but cargo actually did much more work than you realized. You asked cargo to run the project. As there was nothing to actually run when you invoked the command, it decided to compile the code in debug mode on your behalf to provide maximal error information. As it happens, the src/main.rs file always includes a “Hello, world!”

stub. The result of that compilation was a file called hello (or hello.exe). The hello file was executed, and the result printed to your screen.

Executing cargo run has also added new files to the project. We now have a Cargo.lock file in the base of our project and a target/ directory. Both that file and the directory are managed by cargo. Because these are artifacts of the compilation process, we won’t need to touch these. Cargo.lock is a file that specifies the exact version numbers of all the dependencies so that future builds are reliably built the same way until Cargo.toml is modified.

Running tree again reveals the new structure created by invoking cargo run to compile the hello project:

**\$ tree --dirsfirst hello**

hello

├── src

│ └── main.rs



├── target

│ └── debug

│ ├── build

│ ├── deps

│ ├── examples

│ ├── native

│ └── hello

├── Cargo.lock

└── Cargo.toml

For getting things up and running, well done! Now that we’ve cheated our way to

“Hello, World!”, let’s get there via the long way.

***1.3.2***

***Your first Rust program***

For our first program, we want to write something that outputs the following text in multiple languages:

Hello, world!

Grüß Gott!

ハロー・ワールド

You have probably seen the first line in your travels. The other two are there to highlight a few of Rust’s features: easy iteration and built-in support for Unicode. For this program, we’ll use cargo to create it as before. Here are the steps to follow: 1

Open a console prompt.

2

Run cd %TMP% on MS Windows; otherwise cd \$TMP.

3

Run cargo new hello2 to create a new project.

4

Run cd hello2 to move into the project’s root directory.

5

Open the file src/main.rs in a text editor.

6

Replace the text in that file with the text in listing 1.1.

The code for the following listing is in the source code repository. Open ch1/ch1-hello2/src/hello2.rs.

Listing 1.1

“Hello World!” in three languages

**The exclamation mark indicates the use of**

**Assignment in Rust, more**

**a macro, which we’ll discuss shortly.**

**properly called variable**

**binding, uses the let keyword.**

1 fn greet_world() {

**Array**

2 println!("Hello, world!");

**literals**

3 let southern_germany = "Grüß Gott!";

**Unicode support is**

**use square**

4 let japan = "ハロー・ワールド";

**provided out of the box.**

**brackets.**

5 let regions = \[southern_germany, japan\];

**Many types can have an iter()**

6 for region in regions.iter() {

**method to return an iterator.**

7 println!("{}", &region);

8 }

**The ampersand “borrows”**

9 }

**region for read-only access.**




10

11 fn main() {

**Calls a function. Note**

12 greet_world();

**that parentheses follow**

13 }

**the function name.**

Now that src/main.rs is updated, execute cargo run from the hello2/ directory. You should see three greetings appear after some output generated from cargo itself: **\$ cargo run**

Compiling hello2 v0.1.0 (/path/to/ch1/ch1-hello2)

Finished dev \[unoptimized + debuginfo\] target(s) in 0.95s

Running \`target/debug/hello2\`

Hello, world!

Grüß Gott!

ハロー・ワールド

Let’s take a few moments to touch on some of the interesting elements of Rust from listing 1.2.

One of the first things that you are likely to notice is that strings in Rust are able to include a wide range of characters. Strings are guaranteed to be encoded as UTF-8.

This means that you can use non-English languages with relative ease.

The one character that might look out of place is the exclamation mark after println. If you have programmed in Ruby, you may be used to thinking that it is used to signal a destructive operation. In Rust, it signals the use of a *macro*. Macros can be thought of as fancy functions for now. These offer the ability to avoid boilerplate code.

In the case of println!, there is a lot of type detection going on under the hood so that arbitrary data types can be printed to the screen.

***1.4***

***Downloading the book’s source code***

In order to follow along with the examples in this book, you might want to access the source code for the listings. For your convenience, source code for every example is available from two sources:

[ https://manning.com/books/rust-in-action](https://manning.com/books/rust-in-action)

 <https://github.com/rust-in-action/code>

***1.5***

***What does Rust look and feel like?***

Rust is the programming language that allows Haskell and Java programmers to get along. Rust comes close to the high-level, expressive feel of dynamic languages like Haskell and Java while achieving low-level, bare-metal performance.

We looked at a few “Hello, world!” examples in section 1.3, so let’s try something slightly more complex to get a better feel for Rust’s features. Listing 1.2 provides a quick look at what Rust can do for basic text processing. The source code for this listing is in the ch1/ch1-penguins/src/main.rs file. Some features to notice include

***What does Rust look and feel like?***


 *Common control flow mechanisms* —This includes for loops and the continue keyword.

 *Method syntax*—Although Rust is not object-oriented as it does not support inheritance, it carries over this feature of object-oriented languages.

 *Higher-order programming*—Functions can both accept and return functions. For example, line 19 (.map(\|field\| field.trim())) includes a *closure*, also known as an *anonymous function* or *lambda* *function*.

 *Type annotations*—Although relatively rare, these are occasionally required as a hint to the compiler (for example, see line 27 beginning with if let Ok(length)).

 *Conditional compilation*—In the listing, lines 21–24 (if cfg!(…);) are not included in release builds of the program.

 *Implicit return*—Rust provides a return keyword, but it’s usually omitted. Rust is an *expression-based language*.

Listing 1.2

Example of Rust code showing some basic processing of CSV data

1 fn main() {

**Executable projects**

2 let penguin_data = "\\

**require a main()**

3 common name,length (cm)

**function.**

4 Little penguin,33

5 Yellow-eyed penguin,65

**Escapes the trailing**

6 Fiordland penguin,60

**newline character**

7 Invalid,data

8 ";

9

10 let records = penguin_data.lines();

11

**Skips header row**

**and lines with**

12 for (i, record) in records.enumerate() {

**only whitespace**

13 if i == 0 \|\| record.trim().len() == 0 {

14 continue;

15 }

**Starts with a**

**Splits**

16

**line of text**

**record**

17 let fields: Vec\<\_\> = record

**into fields**

18 .split(',')

**Trims whitespace**

19 .map(\|field\| field.trim())

**of each field**

20 .collect();

**Builds a**

**cfg! checks configuration**

21 if cfg!(debug_assertions) {

**collection**

**at compile time.**

22 eprintln!("debug: {:?} -\> {:?}",

**of fields**

23 record, fields);

**eprintln! prints to**

24 }

**standard error (stderr).**

25

26 let name = fields\[0\];

27 if let Ok(length) = fields\[1\].parse::\<f32\>() {

**Attempts to parse**

28 println!("{}, {}cm", name, length);

**field as a floating-**

29 }

**point number**

30 }

**println! prints to**

31 }

**standard out (stdout).**

Listing 1.2 might be confusing to some readers, especially those who have never seen Rust before. Here are some brief notes before moving on:




 On line 17, the fields variable is annotated with the type Vec\<\_\>. Vec is shorthand for \_vector\_, a collection type that can expand dynamically. The underscore (\_) instructs Rust to infer the type of the elements.

 On lines 22 and 28, we instruct Rust to print information to the console. The println! macro prints its arguments to standard out (stdout), whereas eprintln! prints to standard error (stderr).

Macros are similar to functions except that instead of returning data, these return code. Macros are often used to simplify common patterns.

eprintln! and println! both use a string literal with an embedded mini-language in their first argument to control their output. The {} placeholder tells Rust to use a programmer-defined method to represent the value as a string rather than the default representation available with {:?}.

 Line 27 contains some novel features. if let Ok(length) = fields\[1\].parse

::\<f32\>() reads as “attempt to parse fields\[1\] as a 32-bit floating-point number and, if that is successful, then assign the number to the length variable.”

The if let construct is a concise method of conditionally processing data that also provides a local variable assigned to that data. The parse() method returns Ok(T) (where T stands for any type) when it can successfully parse the string; otherwise, it returns Err(E) (where E stands for an error type). The effect of if let Ok(T) is to skip any error cases like the one that’s encountered while processing the line Invalid,data.

When Rust is unable to infer the types from the surrounding context, it will ask for you to specify those. The call to parse() includes an inline type annotation as parse::\<f32\>().

Converting source code into an executable file is called *compiling*. To compile Rust code, we need to install the Rust compiler and run it against the source code. To compile listing 1.2, follow these steps:

1

Open a console prompt (such as cmd.exe, PowerShell, Terminal, or Alacritty).

2

Move to the ch1/ch1-penguins directory (not ch1/ch1-penguins/src) of the source code you downloaded in section 1.4.

3

Execute cargo run. Its output is shown in the following code snippet: **\$ cargo run**

Compiling ch1-penguins v0.1.0 (../code/ch1/ch1-penguins)

Finished dev \[unoptimized + debuginfo\] target(s) in 0.40s

Running \`target/debug/ch1-penguins\`

dbg: " Little penguin,33" -\> \["Little penguin", "33"\]

Little penguin, 33cm

dbg: " Yellow-eyed penguin,65" -\> \["Yellow-eyed penguin", "65"\]

Yellow-eyed penguin, 65cm

dbg: " Fiordland penguin,60" -\> \["Fiordland penguin", "60"\]

Fiordland penguin, 60cm

dbg: " Invalid,data" -\> \["Invalid", "data"\]

***What is Rust?***


You probably noticed the distracting lines starting with dbg:. We can eliminate these by compiling a *release build* using cargo’s --release flag. This conditional compilation functionality is provided by the cfg!(debug_assertions) { … } block within lines 22–24

of listing 1.2. Release builds are much faster at runtime, but incur longer compilation times:

**\$ cargo run --release**

Compiling ch1-penguins v0.1.0 (.../code/ch1/ch1-penguins)

Finished release \[optimized\] target(s) in 0.34s

Running \`target/release/ch1-penguins\`

Little penguin, 33cm

Yellow-eyed penguin, 65cm

Fiordland penguin, 60cm

It’s possible to further reduce the output by adding the -q flag to cargo commands.

-q is shorthand for *quiet*. The following snippet shows what that looks like: **\$ cargo run -q --release**

Little penguin, 33cm

Yellow-eyed penguin, 65cm

Fiordland penguin, 60cm

Listing 1.1 and listing 1.2 were chosen to pack as many representative features of Rust into examples that are easy to understand. Hopefully these demonstrated that Rust programs have a high-level feel, paired with low-level performance. Let’s take a step back from specific language features now and consider some of the thinking behind the language and where it fits within the programming language ecosystem.

***1.6***

***What is Rust?***

Rust’s distinguishing feature as a programming language is its ability to prevent invalid data access at compile time. Research projects by Microsoft’s Security Response Center and the Chromium browser project both suggest that issues relating to invalid data access account for approximately 70% of serious security bugs.13 Rust eliminates that class of bugs. It guarantees that your program is *memory-safe* without imposing any runtime costs.

Other languages can provide this level of safety, but these require adding checks that execute while your program is running, thus slowing it down. Rust manages to break out of this continuum, creating its own space as illustrated by figure 1.1.

Rust’s distinguishing feature as a professional community is its willingness to explicitly include values into its decision-making process. This ethos of inclusion is pervasive. Public messaging is welcoming. All interactions within the Rust community are governed by its code of conduct. Even the Rust compiler’s error messages are ridiculously helpful.

13 See the articles “We need a safer systems programming language,” <http://mng.bz/VdN5> and “Memory safety,”

<http://mng.bz/xm7B> for more information.




**Python**

**Rust**

Safety

**Most programming languages**

**C**

**operate within this band.**

**Rust provides both safety and control.**

Figure 1.1

Rust provides both safety

and control. Other languages have tended

Control

to trade one against the other.

Until late 2018, visitors to the Rust home page were greeted with the (technically heavy) message, “Rust is a systems programming language that runs blazingly fast, prevents segfaults, and guarantees thread safety.” At that point, the community implemented a change to its wording to put its users (and its potential users) at the center (table 1.1).

Table 1.1

Rust slogans over time. As Rust has developed its confidence, it has increasingly embraced the idea of acting as a facilitator and supporter of everyone wanting to achieve their programming aspirations.

Until late 2018

From that point onward

“Rust is a systems programming language that runs blazingly

“Empowering everyone to build reliable

fast, prevents segfaults, and guarantees thread safety.”

and efficient software.”

Rust is labelled as a *systems programming language*, which tends to be seen as quite a specialized, almost esoteric branch of programming. However, many Rust programmers have discovered that the language is applicable to many other domains. Safety, productivity, and control are useful in all software engineering projects. Moreover, the Rust community’s inclusiveness means that the language benefits from a steady stream of new voices with diverse interests.

Let’s flesh out those three goals: safety, productivity, and control. What are these and why do these matter?

***1.6.1***

***Goal of Rust: Safety***

Rust programs are free from

 *Dangling pointers*—Live references to data that has become invalid over the course of the program (see listing 1.3)



 *Data races*—The inability to determine how a program will behave from run to run because external factors change (see listing 1.4)

 *Buffer overflow*—An attempt to access the 12th element of an array with only 6

elements (see listing 1.5)

 *Iterator invalidation*—An issue caused by something that is iterated over after being altered midway through (see listing 1.6)

When programs are compiled in debug mode, Rust also protects against *integer overflow*. What is integer overflow? Well, integers can only represent a finite set of numbers; these have a fixed-width in memory. Integer overflow is what happens when the integers hit their limit and flow over to the beginning again.

The following listing shows a dangling pointer. Note that you’ll find this source code in the ch1/ch1-cereals/src/main.rs file.

Listing 1.3

Attempting to create a dangling pointer

1 \#\[derive(Debug)\]

**Allows the println! macro**

2 enum Cereal {

**to print the Cereal enum**

3 Barley, Millet, Rice,

4 Rye, Spelt, Wheat,

**An enum (enumeration) is**

5 }

**a type with a fixed number**

6

**of legal variants.**

7 fn main() {

**Initializes an empty**

8 let mut grains: Vec\<Cereal\> = vec\![\];

**vector of Cereal**

9 grains.push(Cereal::Rye);

**Adds one item to**

10 drop(grains);

**the grains vector**

11 println!("{:?}", grains);

12 }

**Deletes grains**

**Attempts to access**

**and its contents**

**the deleted value**

Listing 1.3 contains a pointer within grains, which is created on line 8. Vec\<Cereal\> is implemented with an internal pointer to an underlying array. But the listing does not compile. An attempt to do so triggers an error message that complains about attempting to “borrow” a “moved” value. Learning how to interpret that error message and to fix the underlying error are topics for the pages to come. Here’s the output from attempting to compile the code for listing 1.4:

**\$ cargo run**

Compiling ch1-cereals v0.1.0 (/rust-in-action/code/ch1/ch1-cereals) error\[E0382\]: borrow of moved value: \`grains\`

--\> src/main.rs:12:22

\|

8 \| let mut grains: Vec\<Cereal\> = vec\![\];

\| ------- move occurs becausègrains\` has typèstd::vec::Vec\<Cereal\>\`, which does not implement thèCopy\` trait

9 \| grains.push(Cereal::Rye);

10 \| drop(grains);

\| ------ value moved here

11 \|




12 \| println!("{:?}", grains);

\| ^^^^^^ value borrowed here after move

error: aborting due to previous error

For more information about this error, try \`rustc --explain E0382\`.

error: could not compilèch1-cereals\`.

Listing 1.4 shows an example of a data race condition. If you remember, this condition results from the inability to determine how a program behaves from run to run due to changing external factors. You’ll find this code in the ch1/ch1-race/src/

main.rs file.

Listing 1.4

Example of Rust preventing a race condition

1 use std::thread;

**Brings multi-threading**

2 fn main() {

**into local scope**

3 let mut data = 100;

4

5 thread::spawn(\|\| { data = 500; });

**thread::spawn() takes a**

6 thread::spawn(\|\| { data = 1000; });

**closure as an argument.**

7 println!("{}", data);

8 }

If you are unfamiliar with the term *thread*, the upshot is that this code is not deterministic. It’s impossible to know what value data will hold when main() exits. On lines 6 and 7 of the listing, two threads are created by calls to thread::spawn(). Each call takes a closure as an argument, denoted by vertical bars and curly braces (e.g., \|\| {…}). The thread spawned on line 5 is attempting to set the data variable to 500, whereas the thread spawned on line 6 is attempting to set it to 1,000. Because the scheduling of threads is determined by the OS rather than the program, it’s impossible to know if the thread defined first will be the one that runs first.

Attempting to compile listing 1.5 results in a stampede of error messages. Rust does not allow multiple places in an application to have write access to data. The code attempts to allow this in three places: once within the main thread running main() and once in each child thread created by thread::spawn(). Here’s the compiler message: **\$ cargo run**

Compiling ch1-race v0.1.0 (rust-in-action/code/ch1/ch1-race)

error\[E0373\]: closure may outlive the current function, but it

borrows \`datà, which is owned by the current function

--\> src/main.rs:6:19

\|

6 \| thread::spawn(\|\| { data = 500; });

\| ^^ ---- \`dataìs borrowed here

\| \|

\| may outlive borrowed valuèdatà

\|

note: function requires argument type to outlivè'static\`

--\> src/main.rs:6:5



\|

6 \| thread::spawn(\|\| { data = 500; });

\| ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

help: to force the closure to take ownership of \`datà

(and any other referenced variables), use thèmovè keyword

\|

6 \| thread::spawn(move \|\| { data = 500; });

\| ^^^^^^^

**Three other errors omitted.**

...

error: aborting due to 4 previous errors

Some errors have detailed explanations: E0373, E0499, E0502.

For more information about an error, try \`rustc --explain E0373\`.

error: could not compilèch1-racè.

Listing 1.5 provides an example of a buffer overflow. A buffer overflow describes situations where an attempt is made to access items in memory that do not exist or that are illegal. In our case, an attempt to access fruit\[4\] results in the program crashing, as the fruit variable only contains three fruit. The source code for this listing is in the file ch1/ch1-fruit/src/main.rs.

Listing 1.5

Example of invoking a panic via a buffer overflow

1 fn main() {

**Rust will cause a crash rather**

2 let fruit = vec\!['

', '

', '

'\];

**than assign an invalid memory**

3

**location to a variable.**

4 let buffer_overflow = fruit\[4\];

5 assert_eq!(buffer_overflow, '

')

**assert_eq!() tests that**

6 }

**arguments are equal.**

When listing 1.5 is compiled and executed, you’ll encounter this error message: **\$ cargo run**

Compiling ch1-fruit v0.1.0 (/rust-in-action/code/ch1/ch1-fruit)

Finished dev \[unoptimized + debuginfo\] target(s) in 0.31s

Running \`target/debug/ch1-fruit\`

thread 'main' panicked at 'index out of bounds:

the len is 3 but the index is 4', src/main.rs:3:25

note: run with \`RUST_BACKTRACE=1ènvironment variable

to display a backtrace

The next listing shows an example of iterator invalidation, where an issue is caused by something that’s iterated over after being altered midway through. The source code for this listing is in ch1/ch1-letters/src/main.rs.

Listing 1.6

Attempting to modify an iterator while iterating over it

1 fn main() {

2 let mut letters = vec\![

**Creates a mutable**

3 "a", "b", "c"

**vector letters**

4 \];




5

**Copies each letter**

6 for letter in letters {

**and appends it to the**

7 println!("{}", letter);

**end of letters**

8 letters.push(letter.clone());

9 }

10 }

Listing 1.6 fails to compile because Rust does not allow the letters variable to be modified within the iteration block. Here’s the error message:

**\$ cargo run**

Compiling ch1-letters v0.1.0 (/rust-in-action/code/ch1/ch1-letters) error\[E0382\]: borrow of moved value: \`letters\`

--\> src/main.rs:8:7

\|

2 \| let mut letters = vec\![

\| ----------- move occurs becausèletters\` has type

\| \`std::vec::Vec\<&str\>\`, which does not

\| implement thèCopy\` trait

...

6 \| for letter in letters {

\| -------

\| \|

\| \`letters\` moved due to this implicit call

\| tò.into_iter()\`

\| help: consider borrowing to avoid moving

\| into the for loop: \`&letters\`

7 \| println!("{}", letter);

8 \| letters.push(letter.clone());

\| ^^^^^^^ value borrowed here after move

error: aborting due to previous error

For more information about this error, try \`rustc --explain E0382\`.

error: could not compilèch1-letters\`.

To learn more, run the command again with --verbose.

While the language of the error message is filled with jargon ( *borrow*, *move*, *trait*, and so on), Rust has protected the programmer from stepping into a trap that many others fall into. And fear not—that jargon will become easier to understand as you work through the first few chapters of this book.

Knowing that a language is safe provides programmers with a degree of liberty.

Because they know their program won’t implode, they become much more willing to experiment. Within the Rust community, this liberty has spawned the expression *fearless concurrency*.

***1.6.2***

***Goal of Rust: Productivity***

When given a choice, Rust prefers the option that is easiest for the developer. Many of its more subtle features are productivity boosts. But programmer productivity is a difficult concept to demonstrate through an example in a book. Let’s start with something



that can snag beginners—using assignment (=) within an expression that should use an equality (==) test:

1 fn main() {

2 let a = 10;

3

4 if a = 10 {

5 println!("a equals ten");

6 }

7 }

In Rust, the preceding code fails to compile. The Rust compiler generates the following message:

error\[E0308\]: mismatched types

--\> src/main.rs:4:8

\|

4 \| if a = 10 {

\| ^^^^^^

\| \|

\| expected \`bool\`, found \`()\`

\| help: try comparing for equality: à == 10èrror: aborting due to previous error For more information about this error, try \`rustc --explain E0308\`.

error: could not compilèplayground\`.

To learn more, run the command again with --verbose.

At first, “mismatched types” might feel like a strange error message to encounter.

Surely we can test variables for equality against integers.

After some thought, it becomes apparent why the if test receives the wrong type.

The if is not receiving an integer. It’s receiving the result of an assignment. In Rust, this is the blank type: (). () is pronounced *unit*.14

When there is no other meaningful return value, expressions return (). As the following shows, adding a second equals sign on line 4 results in a working program that prints a equals ten:

1 fn main() {

2 let a = 10;

**Using a valid assignment**

**operator (==) allows the**

3

**program to compile.**

4 if a == 10 {

5 println!("a equals ten");

6 }

7 }

14 The name *unit* reveals some of Rust’s heritage as a descendant of the ML family of programming languages that includes OCaml and F#. The term stems from mathematics. Theoretically, a unit type only has a single value. Compare this with Boolean types that have two values, true or false, or strings that have an infinite number of valid values.




Rust has many ergonomic features. It offers generics, sophisticated data types, pattern matching, and closures.15 Those who have worked with other ahead-of-time compilation languages are likely to appreciate Rust’s build system and its comprehensive package manager: cargo.

At first glance, we see that cargo is a front end for rustc, the Rust compiler, but cargo provides several additional utilities including the following:

 cargo new creates a skeleton Rust project in a new directory (cargo init uses the current directory).

 cargo build downloads dependencies and compiles the code.

 cargo run executes cargo build and then also runs the resulting executable file.

 cargo doc builds HTML documentation for every dependency in the current project.

***1.6.3***

***Goal of Rust: Control***

Rust offers programmers fine-grained control over how data structures are laid out in memory and their access patterns. While Rust uses sensible defaults that align with its

“zero cost abstractions” philosophy, those defaults do not suit all situations.

At times, it is imperative to manage your application’s performance. It might matter to you that data is stored in the *stack* rather than on the *heap*. Perhaps, it might make sense to add *reference counting* to create a shared reference to a value. Occasionally, it might be useful to create one’s own type of *pointer* for a particular access pattern. The design space is large and Rust provides the tools to allow you to implement your preferred solution.

NOTE

If terms such as *stack*, *heap*, and *reference counting* are new, don’t put the book down! We’ll spend lots of time explaining these and how they work together throughout the rest of the book.

Listing 1.7 prints the line a: 10, b: 20, c: 30, d: Mutex { data: 40 }. Each representation is another way to store an integer. As we progress through the next few chapters, the trade-offs related to each level become apparent. For the moment, the important thing to remember is that the menu of types is comprehensive. You are welcome to choose exactly what’s right for your specific use case.

Listing 1.7 also demonstrates multiple ways to create integers. Each form provides differing semantics and runtime characteristics. But programmers retain full control of the trade-offs that they want to make.

15 If these terms are unfamiliar, do keep reading. These are explained throughout the book. They are language features that you will miss in other languages.

***Rust’s big features***


Listing 1.7

Multiple ways to create integer values

**Integer on the heap, also**

1 use std::rc::Rc;

**known as a boxed integer**

2 use std::sync::{Arc, Mutex};

**Integer**

3

**Boxed integer wrapped**

**on the**

4 fn main() {

**within a reference counter**

**stack**

5 let a = 10;

6 let b = Box::new(20);

**Integer wrapped in an atomic**

**reference counter and protected**

7 let c = Rc::new(Box::new(30));

**by a mutual exclusion lock**

8 let d = Arc::new(Mutex::new(40));

9 println!("a: {:?}, b: {:?}, c: {:?}, d: {:?}", a, b, c, d); 10 }

To understand why Rust is doing something the way it is, it can be helpful to refer back to these three principles:

 The language’s first priority is safety.

 Data within Rust is immutable by default.

 Compile-time checks are strongly preferred. Safety should be a “zero-cost abstraction.”

***1.7***

***Rust’s big features***

Our tools shape what we believe we can create. Rust enables you to build the software that you want to make, but were too scared to try. What kind of tool is Rust? Flowing from the three principles discussed in the last section are three overarching features of the language:

 Performance

 Concurrency

 Memory efficiency

***1.7.1***

***Performance***

Rust offers all of your computer’s available performance. Famously, Rust does not rely on a garbage collector to provide its memory safety.

There is, unfortunately, a problem with promising you faster programs: the speed of your CPU is fixed. Thus, for software to run faster, it needs to do less. Yet, the language is large. To resolve this conflict, Rust pushes the burden onto the compiler.

The Rust community prefers a bigger language with a compiler that does more, rather than a simpler language where the compiler does less. The Rust compiler aggressively optimizes both the size and speed of your program. Rust also has some less obvious tricks:

 *Cache-friendly data structures are provided by default.* Arrays usually hold data within Rust programs rather than deeply nested tree structures that are created by pointers. This is referred to as *data-oriented programming*.




 *The availability of a modern package manager (cargo) makes it trivial to benefit from tens* *of thousands of open source packages.* C and C++ have much less consistency here, and building large projects with many dependencies is typically difficult.

 *Methods are always dispatched statically unless you explicitly request dynamic dispatch.*

This enables the compiler to heavily optimize code, sometimes to the point of eliminating the cost of a function call entirely.

***1.7.2***

***Concurrency***

Asking a computer to do more than one thing at the same time has proven difficult for software engineers. As far as an OS is concerned, two independent threads of execution are at liberty to destroy each other if a programmer makes a serious mistake.

Yet Rust has spawned the expression *fearless concurrency*. Its emphasis on safety crosses the bounds of independent threads. There is no global interpreter lock (GIL) to constrain a thread’s speed. We explore some of the implications of this in part 2.

***1.7.3***

***Memory efficiency***

Rust enables you to create programs that require minimal memory. When needed, you can use fixed-size structures and know exactly how every byte is managed. High-level constructs, such as iteration and generic types, incur minimal runtime overhead.

***1.8***

***Downsides of Rust***

It’s easy to talk about this language as if it is the panacea for all software engineering.

For example

 “A high-level syntax with low-level performance!”

 “Concurrency without crashes!”

 “C with perfect safety!”

These slogans (sometimes overstated) are great. But for all of its merits, Rust does have some disadvantages.

***1.8.1***

***Cyclic data structures***

In Rust, it is difficult to model cyclic data like an arbitrary graph structure. Implementing a doubly-linked list is an undergraduate-level computer science problem. Yet Rust’s safety checks do hamper progress here. If you’re new to the language, avoid implementing these sorts of data structures until you’re more familiar with Rust.

***1.8.2***

***Compile times***

Rust is slower at compiling code than its peer languages. It has a complex compiler toolchain that receives multiple intermediate representations and sends lots of code to the LLVM compiler. The unit of compilation for a Rust program is not an individual file but a whole package (known affectionately as a *crate*). As crates can include

***TLS security case studies***


multiple modules, these can be exceedingly large units to compile. Although this enables whole-of-crate optimization, it requires whole-of-crate compilation as well.

***1.8.3***

***Strictness***

It’s impossible—well, difficult—to be lazy when programming with Rust. Programs won’t compile until everything is just right. The compiler is strict, but helpful.

Over time, it’s likely that you’ll come to appreciate this feature. If you’ve ever programmed in a dynamic language, then you may have encountered the frustration of your program crashing because of a misnamed variable. Rust brings that frustration forward so that your users don’t have to experience the frustration of things crashing.

***1.8.4***

***Size of the language***

Rust is large! It has a rich type system, several dozen keywords, and includes some features that are unavailable in other languages. These factors all combine to create a steep learning curve. To make this manageable, I encourage learning Rust gradually.

Start with a minimal subset of the language and give yourself time to learn the details when you need these. That is the approach taken in this book. Advanced concepts are deferred until much later.

***1.8.5***

***Hype***

The Rust community is wary of growing too quickly and being consumed by hype. Yet, a number of software projects have encountered this question in their Inbox: “Have you considered rewriting this in Rust?” Unfortunately, software written in Rust is still software. It not immune to security problems and does not offer a panacea to all of software engineering’s ills.

***1.9***

***TLS security case studies***

To demonstrate that Rust will not alleviate all errors, let’s examine two serious exploits that threatened almost all internet-facing devices and consider whether Rust would have prevented those.

By 2015, as Rust gained prominence, implementations of SSL/TLS (namely, OpenSSL and Apple’s own fork) were found to have serious security holes. Known informally as *Heartbleed* and *goto fail;* , both exploits provide opportunities to test Rust’s claims of memory safety. Rust is likely to have helped in both cases, but it is still possible to write Rust code that suffers from similar issues.

***1.9.1***

***Heartbleed***

Heartbleed, officially designated as CVE-2014-0160,16 was caused by re-using a buffer incorrectly. A *buffer* is a space set aside in memory for receiving input. Data can leak from one read to the next if the buffer’s contents are not cleared between writes.

16 See “CVE-2014-0160 Detail,” <https://nvd.nist.gov/vuln/detail/CVE-2014-0160>.




Why does this situation occur? Programmers hunt for performance. Buffers are reused to minimize how often memory applications ask for memory from the OS.

Imagine that we want to process some secret information from multiple users. We decide, for whatever reason, to reuse a single buffer through the course of the program. If we don’t reset this buffer once we use it, information from earlier calls will leak to the latter ones. Here is a précis of a program that would encounter this error: **Binds a reference (&) to a mutable (mut) array**

**(\[…\]) that contains 1,024 unsigned 8-bit integers**

**(u8) initialized to 0 to the variable buffer**

**Fills buffer with**

**bytes from the data**

let buffer = &mut\[0u8; 1024\];

**from user1**

read_secrets(&user1, buffer);

store_secrets(buffer);

**The buffer still contains data**

read_secrets(&user2, buffer);

**from user1 that may or may**

store_secrets(buffer);

**not be overwritten by user2.**

Rust does not protect you from logical errors. It ensures that your data is never able to be written in two places at the same time. It does not ensure that your program is free from all security issues.

***1.9.2***

***Goto fail;***

The goto fail; bug, officially designated as CVE-2014-1266,17 was caused by programmer error coupled with C design issues (and potentially by its compiler not pointing out the flaw). A function that was designed to verify a cryptographic key pair ended up skipping all checks. Here is a selected extract from the original SSLVerifySignedServerKeyExchange function with a fair amount of obfuscatory syntax retained:18

1 static OSStatus

2 SSLVerifySignedServerKeyExchange(SSLContext \*ctx,

3 bool isRsa,

4 SSLBuffer signedParams,

5 uint8_t \*signature,

6 UInt16 signatureLen)

7{

8 OSStatus err;

**Initializes OSStatus with**

9 ...

**a pass value (e.g., 0)**

10

11 if ((err = SSLHashSHA1.update(

12 &hashCtx, &serverRandom)) != 0)

**A series of defensive**

13 goto fail;

**programming checks**

14

15 if ((err = SSLHashSHA1.update(&hashCtx, &signedParams)) != 0) 17 See “CVE-2014-1266 Detail,” [https://nvd.nist.gov/vuln/detail/CVE-2014-1266.](https://nvd.nist.gov/vuln/detail/CVE-2014-1266)

18 Original available [at http://mng.bz/RKGj.](http://mng.bz/RKGj)

***Where does Rust fit best?***


**Unconditional goto skips SSLHashSHA1.final()**

16 goto fail;

**and the (significant) call to sslRawVerify().**

17 goto fail;

18 if ((err = SSLHashSHA1.final(&hashCtx, &hashOut)) != 0) 19 goto fail;

20

21 err = sslRawVerify(ctx,

22 ctx-\>peerPubKey,

23 dataToSign, /\* plaintext \\\*/

24 dataToSignLen, /\* plaintext length \\\*/

25 signature,

26 signatureLen);

27 if(err) {

28 sslErrorLog("SSLDecodeSignedServerKeyExchange: sslRawVerify "

29 "returned %d\n", (int)err);

30 goto fail;

31 }

32

33 fail:

34 SSLFreeBuffer(&signedHashes);

35 SSLFreeBuffer(&hashCtx);

**Returns the pass value of 0, even for inputs**

36 return err;

**that should have failed the verification test**

37 }

In the example code, the issue lies between lines 15 and 17. In C, logical tests do not require curly braces. C compilers interpret those three lines like this: if ((err = SSLHashSHA1.update(&hashCtx, &signedParams)) != 0) {

goto fail;

}

goto fail;

Would Rust have helped? Probably. In this specific case, Rust’s grammar would have caught the bug. It does not allow logical tests without curly braces. Rust also issues a warning when code is unreachable. But that doesn’t mean the error is made impossible in Rust. Stressed programmers under tight deadlines make mistakes. In general, similar code would compile and run.

TIP

Code with caution.

***1.10***

***Where does Rust fit best?***

Although it was designed as a systems programming language, Rust is a general-purpose language. It has been successfully deployed in many areas, which we discuss next.

***1.10.1***

***Command-line utilities***

Rust offers three main advantages for programmers creating command-line utilities: minimal startup time, low memory use, and easy deployment. Programs start their work quickly because Rust does not need to initialize an interpreter (Python, Ruby, etc.) or virtual machine (Java, C#, etc.).




As a bare metal language, Rust produces memory-efficient programs.19 As you’ll see throughout the book, many types are zero-sized. That is, these only exist as hints to the compiler and take up no memory at all in the running program.

Utilities written in Rust are compiled as *static binaries* by default. This compilation method avoids depending on shared libraries that you must install before the program can run. Creating programs that can run without installation steps makes these easy to distribute.

***1.10.2***

***Data processing***

Rust excels at text processing and other forms of data wrangling. Programmers benefit from control over memory use and fast startup times. As of mid-2017, Rust touts the world’s fastest regular expression engine. In 2019, the Apache Arrow data-processing project—foundational to the Python and R data science ecosystems—accepted the Rust-based DataFusion project.

Rust also underlies the implementation of multiple search engines, data-processing engines, and log-parsing systems. Its type system and memory control provide you with the ability to create high throughput data pipelines with a low and stable memory footprint. Small filter programs can be easily embedded into the larger framework via Apache Storm, Apache Kafka, or Apache Hadoop streaming.

***1.10.3***

***Extending applications***

Rust is well suited for extending programs written in a dynamic language. This enables JNI (Java Native Interface) extensions, C extensions, or Erlang/Elixir NIFs (native implemented functions) in Rust. C extensions are typically a scary proposition.

These tend to be quite tightly integrated with the runtime. Make a mistake and you could be looking at runaway memory consumption due to a memory leak or a complete crash. Rust takes away a lot of this anxiety.

 Sentry, a company that processes application errors, finds that Rust is an excellent candidate for rewriting CPU-intensive components of their Python system.20

 Dropbox used Rust to rewrite the file synchronization engine of its client-side application: “More than performance, \[Rust’s\] ergonomics and focus on correctness have helped us tame sync’s complexity.”21

***1.10.4***

***Resource-constrained environments***

C has occupied the domain of microcontrollers for decades. Yet, the Internet of Things (IoT) is coming. That could mean many billions of insecure devices exposed to the network. Any input parsing code will be routinely probed for weaknesses. Given how infrequently firmware updates for these devices occur, it’s critical that these are as 19 The joke goes that Rust is as close to bare metal as possible.

20 See “Fixing Python Performance with Rust,” <http://mng.bz/ryxX>.

21 See “Rewriting the heart of our sync engine,” <http://mng.bz/Vdv5>.



secure as possible from the outset. Rust can play an important role here by adding a layer of safety without imposing runtime costs.

***1.10.5***

***Server-side applications***

Most applications written in Rust live on the server. These could be serving web traffic or supporting businesses running their operations. There is also a tier of services that sit between the OS and your application. Rust is used to write databases, monitoring systems, search appliances, and messaging systems. For example

 The npm package registry for the JavaScript and node.js communities is written in Rust.22

 sled (<https://github.com/spacejam/sled>), an embedded database, can process a workload of 1 billion operations that includes 5% writes in less than a minute on a 16-core machine.

 Tantivy, a full text search engine, can index 8 GB of English Wikipedia in approximately 100 s on a 4-core desktop machine.23

***1.10.6***

***Desktop applications***

There is nothing inherent in Rust’s design that prevents it from being deployed to develop user-facing software. Servo, the web browser engine that acted as an incuba-tor for Rust’s early development, is a user-facing application. Naturally, so are games.

***1.10.7***

***Desktop***

There is still a significant need to write applications that live on people’s computers.

Desktop applications are often complex, difficult to engineer, and hard to support.

With Rust’s ergonomic approach to deployment and its rigor, it is likely to become the secret sauce for many applications. To start, these will be built by small, independent developers. As Rust matures, so will the ecosystem.

***1.10.8***

***Mobile***

Android, iOS, and other smartphone operating systems generally provide a blessed path for developers. In the case of Android, that path is Java. In the case of macOS, developers generally program in Swift. There is, however, another way.

Both platforms provide the ability for native applications to run on them. This is generally intended for applications written in C++, such as games, to be able to be deployed to people’s phones. Rust is able to talk to the phone via the same interface with no additional runtime cost.

22 See “Community makes Rust an easy choice for npm: The npm Registry uses Rust for its CPU-bound bottle-necks,” <http://mng.bz/xm9B>.

23 See “Of tantivy’s indexing,” [https://fulmicoton.com/posts/behold-tantivy-part2/.](https://fulmicoton.com/posts/behold-tantivy-part2/)




***1.10.9***

***Web***

As you are probably aware, JavaScript is the language of the web. Over time though, this will change. Browser vendors are developing a standard called WebAssembly (Wasm) that promises to be a compiler target for many languages. Rust is one of the first. Porting a Rust project to the browser requires only two additional command-line commands. Several companies are exploring the use of Rust in the browser via Wasm, notably CloudFlare and Fastly.

***1.10.10 Systems programming***

In some sense, systems programming is Rust’s raison d’être. Many large programs have been implemented in Rust, including compilers (Rust itself), video game engines, and operating systems. The Rust community includes writers of parser generators, databases, and file formats.

Rust has proven to be a productive environment for programmers who share Rust’s goals. Three standout projects in this area include the following:

 Google is sponsoring the development of Fuchsia OS, an operating system for devices.24

 Microsoft is actively exploring writing low-level components in Rust for Windows.25

 Amazon Web Services (AWS) is building Bottlerocket, a bespoke OS for hosting containers in the cloud.26

***1.11***

***Rust’s hidden feature: Its community***

It takes more than software to grow a programming language. One of the things that the Rust team has done extraordinarily well is to foster a positive and welcoming community around the language. Everywhere you go within the Rust world, you’ll find that you’ll be treated with courtesy and respect.

***1.12***

***Rust phrase book***

When you interact with members of the Rust community, you’ll soon encounter a few terms that have special meaning. Understanding the following terms makes it easier to understand why Rust has evolved the way that it has and the problems that it attempts to solve:

 *Empowering everyone*—All programmers regardless of ability or background are welcome to participate. Programming, and particularly systems programming, should not be restricted to a blessed few.

24 See “Welcome to Fuchsia!,” <https://fuchsia.dev/>.

25 See “Using Rust in Windows,” [http://mng.bz/A0vW.](http://mng.bz/A0vW)

26 See “Bottlerocket: Linux-based operating system purpose-built to run containe[rs,” https://aws.amazon.com/](https://aws.amazon.com/bottlerocket/)

[bottlerocket/](https://aws.amazon.com/bottlerocket/).

***Summary***


 *Blazingly fast*—Rust is a fast programming language. You’ll be able to write programs that match or exceed the performance of its peer languages, but you will have more safety guarantees.

 *Fearless concurrency*—Concurrent and parallel programming have always been seen as difficult. Rust frees you from whole classes of errors that have plagued its peer languages.

 *No Rust 2.0*—Rust code written today will always compile with a future Rust compiler. Rust is intended to be a reliable programming language that can be depended upon for decades to come. In accordance with *semantic versioning*, Rust is never backward-incompatible, so it will never release a new major version.

 *Zero-cost abstractions*—The features you gain from Rust impose no runtime cost.

When you program in Rust, safety does not sacrifice speed.

***Summary***

 Many companies have successfully built large software projects in Rust.

 Software written in Rust can be compiled for the PC, the browser, and the server, as well as mobile and IoT devices.

 The Rust language is well loved by software developers. It has repeatedly won Stack Overflow’s “most loved programming language” title.

 Rust allows you to experiment without fear. It provides correctness guarantees that other tools are unable to provide without imposing runtime costs.

 With Rust, there are three main command_line tools to learn:

– cargo, which manages a whole crate

– rustup, which manages Rust installations

– rustc, which manages compilation of Rust source code

 Rust projects are not immune from all bugs.

 Rust code is stable, fast, and light on resources.