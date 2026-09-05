**auto**

In concept, auto is as simple as simple can be, but it’s more subtle than it looks.

Using it saves typing, sure, but it also prevents correctness and performance issues that can bedevil manual type declarations. Furthermore, some of auto’s type deduction results, while dutifully conforming to the prescribed algorithm, are, from the perspective of a programmer, just wrong. When that’s the case, it’s important to know how to guide auto to the right answer, because falling back on manual type declarations is an alternative that’s often best avoided.

This brief chapter covers all of auto’s ins and outs.

**Item 5: Prefer auto to explicit type declarations.**

Ah, the simple joy of

int x;

Wait. Damn. I forgot to initialize x, so its value is indeterminate. Maybe. It might actually be initialized to zero. Depends on the context. Sigh.

Never mind. Let’s move on to the simple joy of declaring a local variable to be initialized by dereferencing an iterator:

template\<typename It\> // algorithm to dwim ("do what I mean") void dwim(It b, It e) // for all elements in range from

{ // b to e

while (b != e) {

**typename std::iterator_traits\<It\>::value_type**

currValue = \*b;

…

**37**

}

}

Ugh. “typename std::iterator_traits\<It\>::value_type” to express the type of the value pointed to by an iterator? Really? I must have blocked out the memory of how much fun that is. Damn. Wait—didn’t I already say that?

Okay, simple joy (take three): the delight of declaring a local variable whose type is that of a closure. Oh, right. The type of a closure is known only to the compiler, hence can’t be written out. Sigh. Damn.

Damn, damn, damn! Programming in C++ is not the joyous experience it should be!

Well, it didn’t used to be. But as of C++11, all these issues go away, courtesy of auto.

auto variables have their type deduced from their initializer, so they must be initialized. That means you can wave goodbye to a host of uninitialized variable problems as you speed by on the modern C++ superhighway:

**int** x1; // potentially uninitialized

**auto** x2; // error! initializer required

**auto** x3 **= 0**; // fine, x's value is well-defined Said highway lacks the potholes associated with declaring a local variable whose value is that of a dereferenced iterator:

template\<typename It\> // as before

void dwim(It b, It e)

{

while (b != e) {

**auto** currValue = \*b;

…

}

}

And because auto uses type deduction (see Item 2), it can represent types known

only to compilers:

**auto** derefUPLess = // comparison func.

\[\](const std::unique_ptr\<Widget\>& p1, // for Widgets

const std::unique_ptr\<Widget\>& p2) // pointed to by

{ return \*p1 \< \*p2; }; // std::unique_ptrs

Very cool. In C++14, the temperature drops further, because parameters to lambda expressions may involve auto:

auto derefLess = // C++14 comparison

\[\](const **auto**& p1, // function for

**38 \| Item 5**

const **auto**& p2) // values pointed

{ return \*p1 \< \*p2; }; // to by *anything*

// pointer-like

Coolness notwithstanding, perhaps you’re thinking we don’t really need auto to declare a variable that holds a closure, because we can use a std::function object.

It’s true, we can, but possibly that’s not what you were thinking. And maybe now you’re thinking “What’s a std::function object?” So let’s clear that up.

std::function is a template in the C++11 Standard Library that generalizes the idea of a function pointer. Whereas function pointers can point only to functions, however, std::function objects can refer to any callable object, i.e., to anything that can be invoked like a function. Just as you must specify the type of function to point to when you create a function pointer (i.e., the signature of the functions you want to point to), you must specify the type of function to refer to when you create a std::function object. You do that through std::function’s template parameter.

For example, to declare a std::function object named func that could refer to any callable object acting as if it had this signature,

bool(const std::unique_ptr\<Widget\>&, // C++11 signature for

const std::unique_ptr\<Widget\>&) // std::unique_ptr\<Widget\>

// comparison function

you’d write this:

std::function\< **bool(const std::unique_ptr\<Widget\>&,**

**const std::unique_ptr\<Widget\>&)**\> func;

Because lambda expressions yield callable objects, closures can be stored in std::function objects. That means we could declare the C++11 version of derefUP

Less without using auto as follows:

**std::function\<bool(const std::unique_ptr\<Widget\>&,**

**const std::unique_ptr\<Widget\>&)\>**

derefUPLess = \[\](const std::unique_ptr\<Widget\>& p1,

const std::unique_ptr\<Widget\>& p2)

{ return \*p1 \< \*p2; };

It’s important to recognize that even setting aside the syntactic verbosity and need to repeat the parameter types, using std::function is not the same as using auto. An auto-declared variable holding a closure has the same type as the closure, and as such it uses only as much memory as the closure requires. The type of a std::function-declared variable holding a closure is an instantiation of the std::function template, and that has a fixed size for any given signature. This size may not be adequate for the closure it’s asked to store, and when that’s the case, the std::function constructor will allocate heap memory to store the closure. The result is that the **Item 5 \| 39**

std::function object typically uses more memory than the auto-declared object.

And, thanks to implementation details that restrict inlining and yield indirect function calls, invoking a closure via a std::function object is almost certain to be slower than calling it via an auto-declared object. In other words, the std::func tion approach is generally bigger and slower than the auto approach, and it may yield out-of-memory exceptions, too. Plus, as you can see in the examples above, writing “auto” is a whole lot less work than writing the type of the std::function instantiation. In the competition between auto and std::function for holding a closure, it’s pretty much game, set, and match for auto. (A similar argument can be made for auto over std::function for holding the result of calls to std::bind, but

in Item 34, I do my best to convince you to use lambdas instead of std::bind, anyway.)

The advantages of auto extend beyond the avoidance of uninitialized variables, verbose variable declarations, and the ability to directly hold closures. One is the ability to avoid what I call problems related to “type shortcuts.” Here’s something you’ve probably seen—possibly even written:

std::vector\<int\> v;

…

**unsigned** sz = v.size();

The official return type of v.size() is std::vector\<int\>::size_type, but few developers are aware of that. std::vector\<int\>::size_type is specified to be an unsigned integral type, so a lot of programmers figure that unsigned is good enough and write code such as the above. This can have some interesting consequences. On 32-bit Windows, for example, both unsigned and std::vector\<int\>::size_type are the same size, but on 64-bit Windows, unsigned is 32 bits, while std::vec tor\<int\>::size_type is 64 bits. This means that code that works under 32-bit Windows may behave incorrectly under 64-bit Windows, and when porting your application from 32 to 64 bits, who wants to spend time on issues like that?

Using auto ensures that you don’t have to:

**auto** sz = v.size(); // sz's type is std::vector\<int\>::size_type Still unsure about the wisdom of using auto? Then consider this code:

std::unordered_map\<std::string, int\> m;

…

for (const std::pair\<std::string, int\>& p : m)

{

… // do something with p

}

**40 \| Item 5**

This looks perfectly reasonable, but there’s a problem. Do you see it?

Recognizing what’s amiss requires remembering that the key part of a std::unor dered_map is const, so the type of std::pair in the hash table (which is what a std::unordered_map is) isn’t std::pair\<std::string, int\>, it’s std::pair

\< *const* std::string, int\>. But that’s not the type declared for the variable p in the loop above. As a result, compilers will strive to find a way to convert std::pair\<const std::string, int\> objects (i.e., what’s in the hash table) to std::pair\<std::string, int\> objects (the declared type for p). They’ll succeed by creating a temporary object of the type that p wants to bind to by copying each object in m, then binding the reference p to that temporary object. At the end of each loop iteration, the temporary object will be destroyed. If you wrote this loop, you’d likely be surprised by this behavior, because you’d almost certainly intend to simply bind the reference p to each element in m.

Such unintentional type mismatches can be autoed away:

for (const **auto**& p : m)

{

… // as before

}

This is not only more efficient, it’s also easier to type. Furthermore, this code has the very attractive characteristic that if you take p’s address, you’re sure to get a pointer to an element within m. In the code not using auto, you’d get a pointer to a temporary object—an object that would be destroyed at the end of the loop iteration.

The last two examples—writing unsigned when you should have written std::vec tor\<int\>::size_type and writing std::pair\<std::string, int\> when you should have written std::pair\<const std::string, int\>—demonstrate how explicitly specifying types can lead to implicit conversions that you neither want nor expect. If you use auto as the type of the target variable, you need not worry about mismatches between the type of variable you’re declaring and the type of the expression used to initialize it.

There are thus several reasons to prefer auto over explicit type declarations. Yet auto isn’t perfect. The type for each auto variable is deduced from its initializing expression, and some initializing expressions have types that are neither anticipated nor desired. The conditions under which such cases arise, and what you can do about them, are discussed in Items 2 and 6, so I won’t address them here. Instead, I’ll turn

my attention to a different concern you may have about using auto in place of traditional type declarations: the readability of the resulting source code.

**Item 5 \| 41**

First, take a deep breath and relax. auto is an option, not a mandate. If, in your professional judgment, your code will be clearer or more maintainable or in some other way better by using explicit type declarations, you’re free to continue using them. But bear in mind that C++ breaks no new ground in adopting what is generally known in the programming languages world as *type inference*. Other statically typed procedural languages (e.g., C#, D, Scala, Visual Basic) have a more or less equivalent feature, to say nothing of a variety of statically typed functional languages (e.g., ML, Haskell, OCaml, F#, etc.). In part, this is due to the success of dynamically typed languages such as Perl, Python, and Ruby, where variables are rarely explicitly typed. The software development community has extensive experience with type inference, and it has demonstrated that there is nothing contradictory about such technology and the creation and maintenance of large, industrial-strength code bases.

Some developers are disturbed by the fact that using auto eliminates the ability to determine an object’s type by a quick glance at the source code. However, IDEs’ ability to show object types often mitigates this problem (even taking into account the IDE type-display issues mentioned in Item 4), and, in many cases, a somewhat

abstract view of an object’s type is just as useful as the exact type. It often suffices, for example, to know that an object is a container or a counter or a smart pointer, without knowing exactly what kind of container, counter, or smart pointer it is.

Assuming well-chosen variable names, such abstract type information should almost always be at hand.

The fact of the matter is that writing types explicitly often does little more than introduce opportunities for subtle errors, either in correctness or efficiency or both. Furthermore, auto types automatically change if the type of their initializing expression changes, and that means that some refactorings are facilitated by the use of auto. For example, if a function is declared to return an int, but you later decide that a long would be better, the calling code automatically updates itself the next time you compile if the results of calling the function are stored in auto variables. If the results are stored in variables explicitly declared to be int, you’ll need to find all the call sites so that you can revise them.

**Things to Remember**

• auto variables must be initialized, are generally immune to type mismatches that can lead to portability or efficiency problems, can ease the process of refactoring, and typically require less typing than variables with explicitly specified types.

• auto-typed variables are subject to the pitfalls described in Items 2 and 6.

**42 \| Item 5**

**Item 6: Use the explicitly typed initializer idiom when** **auto deduces undesired types.**

Item 5 explains that using auto to declare variables offers a number of technical advantages over explicitly specifying types, but sometimes auto’s type deduction zigs when you want it to zag. For example, suppose I have a function that takes a Widget and returns a std::vector\<bool\>, where each bool indicates whether the Widget offers a particular feature:

std::vector\<bool\> features(const Widget& w);

Further suppose that bit 5 indicates whether the Widget has high priority. We can thus write code like this:

Widget w;

…

bool highPriority = features(w)\[5\]; // is w high priority?

…

processWidget(w, highPriority); // process w in accord

// with its priority

There’s nothing wrong with this code. It’ll work fine. But if we make the seemingly innocuous change of replacing the explicit type for highPriority with auto, **auto** highPriority = features(w)\[5\]; // is w high priority?

the situation changes. All the code will continue to compile, but its behavior is no longer predictable:

processWidget(w, highPriority); // undefined behavior!

As the comment indicates, the call to processWidget now has undefined behavior.

But why? The answer is likely to be surprising. In the code using auto, the type of highPriority is no longer bool. Though std::vector\<bool\> conceptually holds bools, operator\[\] for std::vector\<bool\> doesn’t return a reference to an element of the container (which is what std::vector::operator\[\] returns for every type *except* bool). Instead, it returns an object of type std::vector\<bool\>::reference (a class nested inside std::vector\<bool\>).

std::vector\<bool\>::reference exists because std::vector\<bool\> is specified to represent its bools in packed form, one bit per bool. That creates a problem for std::vector\<bool\>’s operator\[\], because operator\[\] for std::vector\<T\> is supposed to return a T&, but C++ forbids references to bits. Not being able to return a **Item 6 \| 43**

bool&, operator\[\] for std::vector\<bool\> returns an object that *acts like* a bool&.

For this act to succeed, std::vector\<bool\>::reference objects must be usable in essentially all contexts where bool&s can be. Among the features in std::vec tor\<bool\>::reference that make this work is an implicit conversion to bool. (Not to bool&, to *bool*. To explain the full set of techniques used by std::vec tor\<bool\>::reference to emulate the behavior of a bool& would take us too far afield, so I’ll simply remark that this implicit conversion is only one stone in a larger mosaic.)

With this information in mind, look again at this part of the original code: bool highPriority = features(w)\[5\]; // declare highPriority's

// type explicitly

Here, features returns a std::vector\<bool\> object, on which operator\[\] is invoked. operator\[\] returns a std::vector\<bool\>::reference object, which is then implicitly converted to the bool that is needed to initialize highPriority. high Priority thus ends up with the value of bit 5 in the std::vector\<bool\> returned by features, just like it’s supposed to.

Contrast that with what happens in the auto-ized declaration for highPriority: **auto** highPriority = features(w)\[5\]; // deduce highPriority's

// type

Again, features returns a std::vector\<bool\> object, and, again, operator\[\] is invoked on it. operator\[\] continues to return a std::vector\<bool\>::reference object, but now there’s a change, because auto deduces that as the type of highPrior ity. highPriority doesn’t have the value of bit 5 of the std::vector\<bool\> returned by features at all.

The value it does have depends on how std::vector\<bool\>::reference is implemented. One implementation is for such objects to contain a pointer to the machine word holding the referenced bit, plus the offset into that word for that bit. Consider what that means for the initialization of highPriority, assuming that such a std::vector\<bool\>::reference implementation is in place.

The call to features returns a temporary std::vector\<bool\> object. This object has no name, but for purposes of this discussion, I’ll call it *temp*. operator\[\] is invoked on *temp*, and the std::vector\<bool\>::reference it returns contains a pointer to a word in the data structure holding the bits that are managed by *temp*, plus the offset into that word corresponding to bit 5. highPriority is a copy of this std::vector\<bool\>::reference object, so highPriority, too, contains a pointer to a word in *temp*, plus the offset corresponding to bit 5. At the end of the statement, **44 \| Item 6**

*temp* is destroyed, because it’s a temporary object. Therefore, highPriority contains a dangling pointer, and that’s the cause of the undefined behavior in the call to proc essWidget:

processWidget(w, highPriority); // undefined behavior!

// highPriority contains

// dangling pointer!

std::vector\<bool\>::reference is an example of a *proxy class*: a class that exists for the purpose of emulating and augmenting the behavior of some other type. Proxy classes are employed for a variety of purposes. std::vector\<bool\>::reference exists to offer the illusion that operator\[\] for std::vector\<bool\> returns a refer‐

ence to a bit, for example, and the Standard Library’s smart pointer types (see Chap‐

ter 4) are proxy classes that graft resource management onto raw pointers. The utility

of proxy classes is well-established. In fact, the design pattern “Proxy” is one of the most longstanding members of the software design patterns Pantheon.

Some proxy classes are designed to be apparent to clients. That’s the case for std::shared_ptr and std::unique_ptr, for example. Other proxy classes are designed to act more or less invisibly. std::vector\<bool\>::reference is an example of such “invisible” proxies, as is its std::bitset compatriot, std::bitset::ref erence.

Also in that camp are some classes in C++ libraries employing a technique known as *expression templates*. Such libraries were originally developed to improve the efficiency of numeric code. Given a class Matrix and Matrix objects m1, m2, m3, and m4, for example, the expression

Matrix sum = m1 + m2 + m3 + m4;

can be computed much more efficiently if operator+ for Matrix objects returns a proxy for the result instead of the result itself. That is, operator+ for two Matrix objects would return an object of a proxy class such as Sum\<Matrix, Matrix\> instead of a Matrix object. As was the case with std::vector\<bool\>::reference and bool, there’d be an implicit conversion from the proxy class to Matrix, which would permit the initialization of sum from the proxy object produced by the expression on the right side of the “=”. (The type of that object would traditionally encode the entire initialization expression, i.e., be something like Sum\<Sum\<Sum\<Matrix, Matrix\>, Matrix\>, Matrix\>. That’s definitely a type from which clients should be shielded.) As a general rule, “invisible” proxy classes don’t play well with auto. Objects of such classes are often not designed to live longer than a single statement, so creating variables of those types tends to violate fundamental library design assumptions. That’s **Item 6 \| 45**

the case with std::vector\<bool\>::reference, and we’ve seen that violating that assumption can lead to undefined behavior.

You therefore want to avoid code of this form:

auto someVar = *expression of "invisible" proxy class type*; But how can you recognize when proxy objects are in use? The software employing them is unlikely to advertise their existence. They’re supposed to be *invisible*, at least conceptually! And once you’ve found them, do you really have to abandon auto and the many advantages Item 5 demonstrates for it?

Let’s take the how-do-you-find-them question first. Although “invisible” proxy classes are designed to fly beneath programmer radar in day-to-day use, libraries using them often document that they do so. The more you’ve familiarized yourself with the basic design decisions of the libraries you use, the less likely you are to be blindsided by proxy usage within those libraries.

Where documentation comes up short, header files fill the gap. It’s rarely possible for source code to fully cloak proxy objects. They’re typically returned from functions that clients are expected to call, so function signatures usually reflect their existence.

Here’s the spec for std::vector\<bool\>::operator\[\], for example:

namespace std { // from C++ Standards

template \<class Allocator\>

class vector\<bool, Allocator\> {

public:

…

**class reference** { … };

**reference** operator\[\](size_type n);

…

};

}

Assuming you know that operator\[\] for std::vector\<T\> normally returns a T&, the unconventional return type for operator\[\] in this case is a tip-off that a proxy class is in use. Paying careful attention to the interfaces you’re using can often reveal the existence of proxy classes.

In practice, many developers discover the use of proxy classes only when they try to track down mystifying compilation problems or debug incorrect unit test results.

Regardless of how you find them, once auto has been determined to be deducing the type of a proxy class instead of the type being proxied, the solution need not involve abandoning auto. auto itself isn’t the problem. The problem is that auto isn’t deduc-46 \| Item 6

ing the type you want it to deduce. The solution is to force a different type deduction.

The way you do that is what I call *the explicitly typed initializer idiom*.

The explicitly typed initializer idiom involves declaring a variable with auto, but casting the initialization expression to the type you want auto to deduce. Here’s how it can be used to force highPriority to be a bool, for example:

**auto** highPriority = **static_cast\<bool\>(**features(w)\[5\]**)**; Here, features(w)\[5\] continues to return a std::vector\<bool\>::reference object, just as it always has, but the cast changes the type of the expression to bool, which auto then deduces as the type for highPriority. At runtime, the std::vec tor\<bool\>::reference object returned from std::vector\<bool\>::operator\[\]

executes the conversion to bool that it supports, and as part of that conversion, the still-valid pointer to the std::vector\<bool\> returned from features is dereferenced. That avoids the undefined behavior we ran into earlier. The index 5 is then applied to the bits pointed to by the pointer, and the bool value that emerges is used to initialize highPriority.

For the Matrix example, the explicitly typed initializer idiom would look like this: **auto** sum = **static_cast\<Matrix\>(**m1 + m2 + m3 + m4**)**; Applications of the idiom aren’t limited to initializers yielding proxy class types. It can also be useful to emphasize that you are deliberately creating a variable of a type that is different from that generated by the initializing expression. For example, suppose you have a function to calculate some tolerance value:

double calcEpsilon(); // return tolerance value

calcEpsilon clearly returns a double, but suppose you know that for your application, the precision of a float is adequate, and you care about the difference in size between floats and doubles. You could declare a float variable to store the result of calcEpsilon,

**float** ep = calcEpsilon(); // impliclitly convert

// double → float

but this hardly announces “I’m deliberately reducing the precision of the value returned by the function.” A declaration using the explicitly typed initializer idiom, however, does:

**auto** ep = **static_cast\<float\>(**calcEpsilon()**)**; Similar reasoning applies if you have a floating-point expression that you are deliberately storing as an integral value. Suppose you need to calculate the index of an element in a container with random access iterators (e.g., a std::vector, std::deque, **Item 6 \| 47**

or std::array), and you’re given a double between 0.0 and 1.0 indicating how far from the beginning of the container the desired element is located. (0.5 would indicate the middle of the container.) Further suppose that you’re confident that the resulting index will fit in an int. If the container is c and the double is d, you could calculate the index this way,

**int** index = d \* c.size();

but this obscures the fact that you’re intentionally converting the double on the right to an int. The explicitly typed initializer idiom makes things transparent: **auto** index = **static_cast\<int\>(**d \* c.size()**)**; **Things to Remember**

• “Invisible” proxy types can cause auto to deduce the “wrong” type for an initializing expression.

• The explicitly typed initializer idiom forces auto to deduce the type you want it to have.

**48 \| Item 6**

**CHAPTER 3**