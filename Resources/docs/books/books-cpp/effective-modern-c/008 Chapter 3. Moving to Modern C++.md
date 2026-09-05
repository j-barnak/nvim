**Moving to Modern C++**

When it comes to big-name features, C++11 and C++14 have a lot to boast of. auto, smart pointers, move semantics, lambdas, concurrency—each is so important, I devote a chapter to it. It’s essential to master those features, but becoming an effective modern C++ programmer requires a series of smaller steps, too. Each step answers specific questions that arise during the journey from C++98 to modern C++. When should you use braces instead of parentheses for object creation? Why are alias declarations better than typedefs? How does constexpr differ from const? What’s the relationship between const member functions and thread safety? The list goes on and on. And one by one, this chapter provides the answers.

**Item 7: Distinguish between () and {} when creating**

**objects.**

Depending on your perspective, syntax choices for object initialization in C++11

embody either an embarrassment of riches or a confusing mess. As a general rule, initialization values may be specified with parentheses, an equals sign, or braces: int x**(**0**)**; // initializer is in parentheses

int y **=** 0; // initializer follows "="

int z**{** 0 **}**; // initializer is in braces

In many cases, it’s also possible to use an equals sign and braces together: int z **=** **{** 0 **}**; // initializer uses "=" and braces For the remainder of this Item, I’ll generally ignore the equals-sign-plus-braces syntax, because C++ usually treats it the same as the braces-only version.

**49**

The “confusing mess” lobby points out that the use of an equals sign for initialization often misleads C++ newbies into thinking that an assignment is taking place, even though it’s not. For built-in types like int, the difference is academic, but for user-defined types, it’s important to distinguish initialization from assignment, because different function calls are involved:

Widget w1; // call default constructor

Widget w2 = w1; // not an assignment; calls *copy ctor*

w1 = w2; // an assignment; calls *copy operator=*

Even with several initialization syntaxes, there were some situations where C++98

had no way to express a desired initialization. For example, it wasn’t possible to directly indicate that an STL container should be created holding a particular set of values (e.g., 1, 3, and 5).

To address the confusion of multiple initialization syntaxes, as well as the fact that they don’t cover all initialization scenarios, C++11 introduces *uniform initialization*: a single initialization syntax that can, at least in concept, be used anywhere and express everything. It’s based on braces, and for that reason I prefer the term *braced* *initialization*. “Uniform initialization” is an idea. “Braced initialization” is a syntactic construct.

Braced initialization lets you express the formerly inexpressible. Using braces, specifying the initial contents of a container is easy:

std::vector\<int\> v**{** 1, 3, 5 **}**; // v's initial content is 1, 3, 5

Braces can also be used to specify default initialization values for non-static data members. This capability—new to C++11—is shared with the “=” initialization syntax, but not with parentheses:


…


int x**{** 0 **}**; // fine, x's default value is 0

int y **=** 0; // also fine

int z**(**0**)**; // error!

};

On the other hand, uncopyable objects (e.g., std::atomics—see Item 40) may be initialized using braces or parentheses, but not using “=”:

std::atomic\<int\> ai1**{** 0 **}**; // fine

**50 \| Item 7**

std::atomic\<int\> ai2**(**0**)**; // fine std::atomic\<int\> ai3 **=** 0; // error!

It’s thus easy to understand why braced initialization is called “uniform.” Of C++’s three ways to designate an initializing expression, only braces can be used everywhere.

A novel feature of braced initialization is that it prohibits implicit *narrowing conversions* among built-in types. If the value of an expression in a braced initializer isn’t guaranteed to be expressible by the type of the object being initialized, the code won’t compile:

double x, y, z;

…

int sum1**{** x + y + z **}**; // error! sum of doubles may

// not be expressible as int

Initialization using parentheses and “=” doesn’t check for narrowing conversions, because that could break too much legacy code:

int sum2**(**x + y + z**)**; // okay (value of expression

// truncated to an int)

int sum3 **=** x + y + z; // ditto

Another noteworthy characteristic of braced initialization is its immunity to C++’s *most vexing parse*. A side effect of C++’s rule that anything that can be parsed as a declaration must be interpreted as one, the most vexing parse most frequently afflicts developers when they want to default-construct an object, but inadvertently end up declaring a function instead. The root of the problem is that if you want to call a constructor with an argument, you can do it like this,

Widget w1**(10)**; // call Widget ctor with argument 10

but if you try to call a Widget constructor with zero arguments using the analogous syntax, you declare a function instead of an object:

Widget w2**()**; // most vexing parse! declares a function

// named w2 that returns a Widget!

Functions can’t be declared using braces for the parameter list, so default-constructing an object using braces doesn’t have this problem:

Widget w3**{}**; // calls Widget ctor with no args

**Item 7 \| 51**

There’s thus a lot to be said for braced initialization. It’s the syntax that can be used in the widest variety of contexts, it prevents implicit narrowing conversions, and it’s immune to C++’s most vexing parse. A trifecta of goodness! So why isn’t this Item entitled something like “Prefer braced initialization syntax”?

The drawback to braced initialization is the sometimes-surprising behavior that accompanies it. Such behavior grows out of the unusually tangled relationship among braced initializers, std::initializer_lists, and constructor overload resolution.

Their interactions can lead to code that seems like it should do one thing, but actually does another. For example, Item 2 explains that when an auto-declared variable has a braced initializer, the type deduced is std::initializer_list, even though other ways of declaring a variable with the same initializer would yield a more intuitive type. As a result, the more you like auto, the less enthusiastic you’re likely to be about braced initialization.

In constructor calls, parentheses and braces have the same meaning as long as std::initializer_list parameters are not involved:


public:

Widget(int i, bool b); // ctors not declaring

Widget(int i, double d); // std::initializer_list params

…

};

Widget w1**(**10, true**)**; // calls first ctor

Widget w2**{**10, true**}**; // also calls first ctor

Widget w3**(**10, 5.0**)**; // calls second ctor

Widget w4**{**10, 5.0**}**; // also calls second ctor

If, however, one or more constructors declare a parameter of type std::initial izer_list, calls using the braced initialization syntax strongly prefer the overloads taking std::initializer_lists. *Strongly*. If there’s *any way* for compilers to con-strue a call using a braced initializer to be to a constructor taking a std::initial izer_list, compilers will employ that interpretation. If the Widget class above is augmented with a constructor taking a std::initializer_list\<long double\>, for example,


public:

Widget(int i, bool b); // as before

Widget(int i, double d); // as before

**52 \| Item 7**

**Widget(std::initializer_list\<long double\> il);** // added

…

};

Widgets w2 and w4 will be constructed using the new constructor, even though the type of the std::initializer_list elements (long double) is, compared to the non-std::initializer_list constructors, a worse match for both arguments!

Look:

Widget w1**(**10, true**)**; // uses parens and, as before,

// calls first ctor

Widget w2**{**10, true**}**; // uses braces, but *now calls*

// *std::initializer_list ctor*

// (10 and true convert to long double)

Widget w3**(**10, 5.0**)**; // uses parens and, as before,

// calls second ctor

Widget w4**{**10, 5.0**}**; // uses braces, but *now calls*

// *std::initializer_list ctor*

// (10 and 5.0 convert to long double)

Even what would normally be copy and move construction can be hijacked by std::initializer_list constructors:


public:

Widget(int i, bool b); // as before

Widget(int i, double d); // as before

Widget(std::initializer_list\<long double\> il); // as before

**operator float() const;** // convert

… // to float

};

Widget w5**(**w4**)**; // uses parens, *calls copy ctor* Widget w6**{**w4**}**; // uses braces, *calls*

// *std::initializer_list ctor*

// (w4 converts to float, and float

// converts to long double)

**Item 7 \| 53**

Widget w7**(**std::move(w4)**)**; // uses parens, *calls move ctor* Widget w8**{**std::move(w4)**}**; // uses braces, *calls*

// *std::initializer_list ctor*

// (for same reason as w6)

Compilers’ determination to match braced initializers with constructors taking std::initializer_lists is so strong, it prevails even if the best-match std::ini tializer_list constructor can’t be called. For example:


public:

Widget(int i, bool b); // as before

Widget(int i, double d); // as before

Widget(std::initializer_list\< **bool**\> il); // element type is

// now bool

… // no implicit

}; // conversion funcs

Widget w**{10, 5.0}**; // error! requires narrowing conversions Here, compilers will ignore the first two constructors (the second of which offers an exact match on both argument types) and try to call the constructor taking a std::initializer_list\<bool\>. Calling that constructor would require converting an int (10) and a double (5.0) to bools. Both conversions would be narrowing (bool can’t exactly represent either value), and narrowing conversions are prohibited inside braced initializers, so the call is invalid, and the code is rejected.

Only if there’s no way to convert the types of the arguments in a braced initializer to the type in a std::initializer_list do compilers fall back on normal overload resolution. For example, if we replace the std::initializer_list\<bool\> constructor with one taking a std::initializer_list\<std::string\>, the non-std::initializer_list constructors become candidates again, because there is no way to convert ints and bools to std::strings:


public:

Widget(int i, bool b); // as before

Widget(int i, double d); // as before

// std::initializer_list element type is now std::string

Widget(std::initializer_list\< **std::string**\> il);

… // no implicit

**54 \| Item 7**

}; // conversion funcs Widget w1**(**10, true**)**; // uses parens, still calls first ctor Widget w2**{**10, true**}**; // uses braces, *now calls first ctor* Widget w3**(**10, 5.0**)**; // uses parens, still calls second ctor Widget w4**{**10, 5.0**}**; // uses braces, *now calls second ctor* This brings us near the end of our examination of braced initializers and constructor overloading, but there’s an interesting edge case that needs to be addressed. Suppose you use an empty set of braces to construct an object that supports default construction and also supports std::initializer_list construction. What do your empty braces mean? If they mean “no arguments,” you get default construction, but if they mean “empty std::initializer_list,” you get construction from a std::ini tializer_list with no elements.

The rule is that you get default construction. Empty braces mean no arguments, not an empty std::initializer_list:


public:

Widget(); // default ctor

Widget(std::initializer_list\<int\> il); // std::initializer

// \_list ctor

… // no implicit

}; // conversion funcs

Widget w1; // calls default ctor

Widget w2**{}**; // also calls default ctor

Widget w3**()**; // most vexing parse! declares a function!

If you *want* to call a std::initializer_list constructor with an empty std::ini tializer_list, you do it by making the empty braces a constructor argument—by putting the empty braces inside the parentheses or braces demarcating what you’re passing:

Widget w4(**{}**); // calls std::initializer_list ctor

// with empty list

Widget w5{**{}**}; // ditto

**Item 7 \| 55**

At this point, with seemingly arcane rules about braced initializers, std::initial izer_lists, and constructor overloading burbling about in your brain, you may be wondering how much of this information matters in day-to-day programming. More than you might think, because one of the classes directly affected is std::vector.

std::vector has a non-std::initializer_list constructor that allows you to specify the initial size of the container and a value each of the initial elements should have, but it also has a constructor taking a std::initializer_list that permits you to specify the initial values in the container. If you create a std::vector of a numeric type (e.g., a std::vector\<int\>) and you pass two arguments to the constructor, whether you enclose those arguments in parentheses or braces makes a tremendous difference:

std::vector\<int\> v1**(**10, 20**)**; // *use non-std::initializer_list*

// *ctor:* create 10-element

// std::vector, all elements have

// value of 20

std::vector\<int\> v2**{**10, 20**}**; // *use std::initializer_list ctor:*

// create 2-element std::vector,

// element values are 10 and 20

But let’s step back from std::vector and also from the details of parentheses, braces, and constructor overloading resolution rules. There are two primary take-aways from this discussion. First, as a class author, you need to be aware that if your set of overloaded constructors includes one or more functions taking a std::ini tializer_list, client code using braced initialization may see only the std::ini tializer_list overloads. As a result, it’s best to design your constructors so that the overload called isn’t affected by whether clients use parentheses or braces. In other words, learn from what is now viewed as an error in the design of the std::vec tor interface, and design your classes to avoid it.

An implication is that if you have a class with no std::initializer_list constructor, and you add one, client code using braced initialization may find that calls that used to resolve to non-std::initializer_list constructors now resolve to the new function. Of course, this kind of thing can happen any time you add a new function to a set of overloads: calls that used to resolve to one of the old overloads might start calling the new one. The difference with std::initializer_list constructor overloads is that a std::initializer_list overload doesn’t just compete with other overloads, it overshadows them to the point where the other overloads may hardly be considered. So add such overloads only with great deliberation.

The second lesson is that as a class client, you must choose carefully between parentheses and braces when creating objects. Most developers end up choosing one kind **56 \| Item 7**

of delimiter as a default, using the other only when they have to. Braces-by-default folks are attracted by their unrivaled breadth of applicability, their prohibition of narrowing conversions, and their immunity to C++’s most vexing parse. Such folks understand that in some cases (e.g., creation of a std::vector with a given size and initial element value), parentheses are required. On the other hand, the go-parentheses-go crowd embraces parentheses as their default argument delimiter.

They’re attracted to its consistency with the C++98 syntactic tradition, its avoidance of the auto-deduced-a-std::initializer_list problem, and the knowledge that their object creation calls won’t be inadvertently waylaid by std::initial izer_list constructors. They concede that sometimes only braces will do (e.g., when creating a container with particular values). There’s no consensus that either approach is better than the other, so my advice is to pick one and apply it consistently.

If you’re a template author, the tension between parentheses and braces for object creation can be especially frustrating, because, in general, it’s not possible to know which should be used. For example, suppose you’d like to create an object of an arbitrary type from an arbitrary number of arguments. A variadic template makes this conceptually straightforward:

template\<typename T, // type of object to create

typename... Ts\> // types of arguments to use

void doSomeWork(Ts&&... params)

{

*create local T object from params...*

…

}

There are two ways to turn the line of pseudocode into real code (see Item 25 for information about std::forward):

T localObject**(**std::forward\<Ts\>(params)... **)**; // using parens T localObject**{**std::forward\<Ts\>(params)... **}**; // using braces So consider this calling code:

std::vector\<int\> v;

…

doSomeWork\<std::vector\<int\>\>(10, 20);

**Item 7 \| 57**

If doSomeWork uses parentheses when creating localObject, the result is a std::vector with 10 elements. If doSomeWork uses braces, the result is a std::vec tor with 2 elements. Which is correct? The author of doSomeWork can’t know. Only the caller can.

This is precisely the problem faced by the Standard Library functions

std::make_unique and std::make_shared (see Item 21). These functions resolve

the problem by internally using parentheses and by documenting this decision as part of their interfaces.1

**Things to Remember**

• Braced initialization is the most widely usable initialization syntax, it prevents narrowing conversions, and it’s immune to C++’s most vexing parse.

• During constructor overload resolution, braced initializers are matched to std::initializer_list parameters if at all possible, even if other constructors offer seemingly better matches.

• An example of where the choice between parentheses and braces can make a significant difference is creating a std::vector\< *numeric type*\> with two arguments.

• Choosing between parentheses and braces for object creation inside templates can be challenging.

**Item 8: Prefer nullptr to 0 and NULL.**

So here’s the deal: the literal 0 is an int, not a pointer. If C++ finds itself looking at 0

in a context where only a pointer can be used, it’ll grudgingly interpret 0 as a null pointer, but that’s a fallback position. C++’s primary policy is that 0 is an int, not a pointer.

Practically speaking, the same is true of NULL. There is some uncertainty in the details in NULL’s case, because implementations are allowed to give NULL an integral type other than int (e.g., long). That’s not common, but it doesn’t really matter, because the issue here isn’t the exact type of NULL, it’s that neither 0 nor NULL has a pointer type.

1 More flexible designs—ones that permit callers to determine whether parentheses or braces should be used in functions generated from a template—are possible. For details, see the 5 June 2013 entry of [*Andrzej’s C++*](http://akrzemi1.wordpress.com/)

[*blog*, “](http://akrzemi1.wordpress.com/)[Intuitive interface — Part I](http://akrzemi1.wordpress.com/2013/06/05/intuitive-interface-part-i/).”

**58 \| Item 7**

In C++98, the primary implication of this was that overloading on pointer and integral types could lead to surprises. Passing 0 or NULL to such overloads never called a pointer overload:

void f(int); // three overloads of f

void f(bool);

void f(void\*);

f(0); // calls f(int), not f(void\*)

f(NULL); // might not compile, but typically calls

// f(int). Never calls f(void\*)

The uncertainty regarding the behavior of f(NULL) is a reflection of the leeway granted to implementations regarding the type of NULL. If NULL is defined to be, say, 0L

(i.e., 0 as a long), the call is ambiguous, because conversion from long to int, long to bool, and 0L to void\* are considered equally good. The interesting thing about that call is the contradiction between the *apparent* meaning of the source code (“I’m calling f with NULL—the null pointer”) and its *actual* meaning (“I’m calling f with some kind of integer—not the null pointer”). This counterintuitive behavior is what led to the guideline for C++98 programmers to avoid overloading on pointer and integral types. That guideline remains valid in C++11, because, the advice of this Item notwithstanding, it’s likely that some developers will continue to use 0 and NULL, even though nullptr is a better choice.

nullptr’s advantage is that it doesn’t have an integral type. To be honest, it doesn’t have a pointer type, either, but you can think of it as a pointer of *all* types. nullptr’s actual type is std::nullptr_t, and, in a wonderfully circular definition, std::nullptr_t is defined to be the type of nullptr. The type std::nullptr_t implicitly converts to all raw pointer types, and that’s what makes nullptr act as if it were a pointer of all types.

Calling the overloaded function f with nullptr calls the void\* overload (i.e., the pointer overload), because nullptr can’t be viewed as anything integral: f(nullptr); // calls f(void\*) overload

Using nullptr instead of 0 or NULL thus avoids overload resolution surprises, but that’s not its only advantage. It can also improve code clarity, especially when auto variables are involved. For example, suppose you encounter this in a code base: auto result = findRecord( /\* arguments \*/ );

if (**result == 0**) {

**Item 8 \| 59**

…

}

If you don’t happen to know (or can’t easily find out) what findRecord returns, it may not be clear whether result is a pointer type or an integral type. After all, 0

(what result is tested against) could go either way. If you see the following, on the other hand,

auto result = findRecord( /\* arguments \*/ );

if (**result == nullptr**) {

…

}

there’s no ambiguity: result must be a pointer type.

nullptr shines especially brightly when templates enter the picture. Suppose you have some functions that should be called only when the appropriate mutex has been locked. Each function takes a different kind of pointer:

int f1(std::shared_ptr\<Widget\> spw); // call these only when

double f2(std::unique_ptr\<Widget\> upw); // the appropriate

bool f3(Widget\* pw); // mutex is locked

Calling code that wants to pass null pointers could look like this:

std::mutex f1m, f2m, f3m; // mutexes for f1, f2, and f3

using MuxGuard = // C++11 typedef; see Item 9

std::lock_guard\<std::mutex\>;

…

{

MuxGuard g(f1m); // lock mutex for f1

auto result = f1(**0**); // pass 0 as null ptr to f1

} // unlock mutex

…

{

MuxGuard g(f2m); // lock mutex for f2

auto result = f2(**NULL**); // pass NULL as null ptr to f2

} // unlock mutex

…

{

**60 \| Item 8**

MuxGuard g(f3m); // lock mutex for f3

auto result = f3(**nullptr**); // pass nullptr as null ptr to f3

} // unlock mutex

The failure to use nullptr in the first two calls in this code is sad, but the code works, and that counts for something. However, the repeated pattern in the calling code—lock mutex, call function, unlock mutex—is more than sad. It’s disturbing.

This kind of source code duplication is one of the things that templates are designed to avoid, so let’s templatize the pattern:

template\<typename FuncType,

typename MuxType,

typename PtrType\>

auto lockAndCall(FuncType func,

MuxType& mutex,

PtrType ptr) -\> decltype(func(ptr))

{

MuxGuard g(mutex);

return func(ptr);

}

If the return type of this function (auto … -\> decltype(func(ptr)) has you scratch‐

ing your head, do your head a favor and navigate to Item 3, which explains what’s

going on. There you’ll see that in C++14, the return type could be reduced to a simple decltype(auto):

template\<typename FuncType,

typename MuxType,

typename PtrType\>

**decltype(auto)** lockAndCall(FuncType func, // C++14

MuxType& mutex,

PtrType ptr)

{

MuxGuard g(mutex);

return func(ptr);

}

Given the lockAndCall template (either version), callers can write code like this: auto result1 = lockAndCall(f1, f1m, **0**); // error!

…

auto result2 = lockAndCall(f2, f2m, **NULL**); // error!

…

**Item 8 \| 61**

auto result3 = lockAndCall(f3, f3m, **nullptr**); // fine Well, they can write it, but, as the comments indicate, in two of the three cases, the code won’t compile. The problem in the first call is that when 0 is passed to lockAnd Call, template type deduction kicks in to figure out its type. The type of 0 is, was, and always will be int, so that’s the type of the parameter ptr inside the instantiation of this call to lockAndCall. Unfortunately, this means that in the call to func inside lockAndCall, an int is being passed, and that’s not compatible with the std::shared_ptr\<Widget\> parameter that f1 expects. The 0 passed in the call to lockAndCall was intended to represent a null pointer, but what actually got passed was a run-of-the-mill int. Trying to pass this int to f1 as a std::shared_ptr

\<Widget\> is a type error. The call to lockAndCall with 0 fails because inside the template, an int is being passed to a function that requires a std::

shared_ptr\<Widget\>.

The analysis for the call involving NULL is essentially the same. When NULL is passed to lockAndCall, an integral type is deduced for the parameter ptr, and a type error occurs when ptr—an int or int-like type—is passed to f2, which expects to get a std::unique_ptr\<Widget\>.

In contrast, the call involving nullptr has no trouble. When nullptr is passed to lockAndCall, the type for ptr is deduced to be std::nullptr_t. When ptr is passed to f3, there’s an implicit conversion from std::nullptr_t to Widget\*, because std::nullptr_t implicitly converts to all pointer types.

The fact that template type deduction deduces the “wrong” types for 0 and NULL (i.e., their true types, rather than their fallback meaning as a representation for a null pointer) is the most compelling reason to use nullptr instead of 0 or NULL when you want to refer to a null pointer. With nullptr, templates pose no special challenge.

Combined with the fact that nullptr doesn’t suffer from the overload resolution surprises that 0 and NULL are susceptible to, the case is ironclad. When you want to refer to a null pointer, use nullptr, not 0 or NULL.

**Things to Remember**

• Prefer nullptr to 0 and NULL.

• Avoid overloading on integral and pointer types.

**62 \| Item 8**

**Item 9: Prefer alias declarations to typedefs.**

I’m confident we can agree that using STL containers is a good idea, and I hope that

Item 18 convinces you that using std::unique_ptr is a good idea, but my guess is that neither of us is fond of writing types like “std::unique_ptr\<std::unor dered_map\<std::string, std::string\>\>” more than once. Just thinking about it probably increases the risk of carpal tunnel syndrome.

Avoiding such medical tragedies is easy. Introduce a typedef:

typedef

std::unique_ptr\<std::unordered_map\<std::string, std::string\>\> UPtrMapSS;

But typedefs are soooo C++98. They work in C++11, sure, but C++11 also offers *alias declarations*:

**using UPtrMapSS =**

std::unique_ptr\<std::unordered_map\<std::string, std::string\>\>; Given that the typedef and the alias declaration do exactly the same thing, it’s reasonable to wonder whether there is a solid technical reason for preferring one over the other.

There is, but before I get to it, I want to mention that many people find the alias declaration easier to swallow when dealing with types involving function pointers:

// FP is a synonym for a pointer to a function taking an int and

// a const std::string& and returning nothing

**typedef** void (\***FP**)(int, const std::string&); // typedef

// same meaning as above

**using** **FP** = void (\*)(int, const std::string&); // alias

// declaration

Of course, neither form is particularly easy to choke down, and few people spend much time dealing with synonyms for function pointer types, anyway, so this is hardly a compelling reason to choose alias declarations over typedefs.

But a compelling reason does exist: templates. In particular, alias declarations may be templatized (in which case they’re called *alias templates*), while typedefs cannot.

This gives C++11 programmers a straightforward mechanism for expressing things that in C++98 had to be hacked together with typedefs nested inside templatized structs. For example, consider defining a synonym for a linked list that uses a custom allocator, MyAlloc. With an alias template, it’s a piece of cake:

**Item 9 \| 63**

**template\<typename T\>** // MyAllocList\<T\> **using MyAllocList** = std::list\<T, MyAlloc\<T\>\>; // is synonym for

// std::list\<T,

// MyAlloc\<T\>\>

MyAllocList\<Widget\> lw; // client code

With a typedef, you pretty much have to create the cake from scratch:

**template\<typename T\>** // MyAllocList\<T\>::type **struct MyAllocList {** // is synonym for

**typedef** std::list\<T, MyAlloc\<T\>\> **type**; // std::list\<T,

**};** // MyAlloc\<T\>\> MyAllocList\<Widget\>::type lw; // client code

It gets worse. If you want to use the typedef inside a template for the purpose of creating a linked list holding objects of a type specified by a template parameter, you have to precede the typedef name with typename:

template\<typename T\>

class Widget { // Widget\<T\> contains

private: // a MyAllocList\<T\>

**typename** MyAllocList\<T\>::type list; // as a data member

…

};

Here, MyAllocList\<T\>::type refers to a type that’s dependent on a template type parameter (T). MyAllocList\<T\>::type is thus a *dependent type*, and one of C++’s many endearing rules is that the names of dependent types must be preceded by type name.

If MyAllocList is defined as an alias template, this need for typename vanishes (as does the cumbersome “::type” suffix):

template\<typename T\>

using MyAllocList = std::list\<T, MyAlloc\<T\>\>; // as before template\<typename T\>



**MyAllocList\<T\>** list; // no "typename",

… // no "::type"

};

To you, MyAllocList\<T\> (i.e., use of the alias template) may look just as dependent on the template parameter T as MyAllocList\<T\>::type (i.e., use of the nested type **64 \| Item 9**

def), but you’re not a compiler. When compilers process the Widget template and encounter the use of MyAllocList\<T\> (i.e., use of the alias template), they know that MyAllocList\<T\> is the name of a type, because MyAllocList is an alias template: it *must* name a type. MyAllocList\<T\> is thus a *non-dependent type*, and a typename specifier is neither required nor permitted.

When compilers see MyAllocList\<T\>::type (i.e., use of the nested typedef) in the Widget template, on the other hand, they can’t know for sure that it names a type, because there might be a specialization of MyAllocList that they haven’t yet seen where MyAllocList\<T\>::type refers to something other than a type. That sounds crazy, but don’t blame compilers for this possibility. It’s the humans who have been known to produce such code.

For example, some misguided soul may have concocted something like this: class Wine { … };

template\<\> // MyAllocList specialization

class MyAllocList\<Wine\> { // for when T is Wine


enum class WineType // see Item 10 for info on

{ White, Red, Rose }; // "enum class"

WineType **type**; // in this class, type is

… // a *data member*!

};

As you can see, MyAllocList\<Wine\>::type doesn’t refer to a type. If Widget were to be instantiated with Wine, MyAllocList\<T\>::type inside the Widget template would refer to a data member, not a type. Inside the Widget template, then, whether MyAllocList\<T\>::type refers to a type is honestly dependent on what T is, and that’s why compilers insist on your asserting that it is a type by preceding it with typename.

If you’ve done any template metaprogramming (TMP), you’ve almost certainly bumped up against the need to take template type parameters and create revised types from them. For example, given some type T, you might want to strip off any const-or reference-qualifiers that T contains, e.g., you might want to turn const std::string& into std::string. Or you might want to add const to a type or turn it into an lvalue reference, e.g., turn Widget into const Widget or into Widget&. (If you haven’t done any TMP, that’s too bad, because if you want to be a truly effective C++ programmer, you need to be familiar with at least the basics of this facet of C++.

You can see examples of TMP in action, including the kinds of type transformations I

just mentioned, in Items 23 and 27.) **Item 9 \| 65**

C++11 gives you the tools to perform these kinds of transformations in the form of *type traits*, an assortment of templates inside the header \<type_traits\>. There are dozens of type traits in that header, and not all of them perform type transformations, but the ones that do offer a predictable interface. Given a type T to which you’d like to apply a transformation, the resulting type is std:: *transformation*

\<T\>::type. For example:

std::**remove_const**\<T\>::type // yields T from const T

std::**remove_reference**\<T\>::type // yields T from T& and T&& std::**add_lvalue_reference**\<T\>::type // yields T& from T

The comments merely summarize what these transformations do, so don’t take them too literally. Before using them on a project, you’d look up the precise specifications, I know.

My motivation here isn’t to give you a tutorial on type traits, anyway. Rather, note that application of these transformations entails writing “::type” at the end of each use. If you apply them to a type parameter inside a template (which is virtually always how you employ them in real code), you’d also have to precede each use with type name. The reason for both of these syntactic speed bumps is that the C++11 type traits are implemented as nested typedefs inside templatized structs. That’s right, they’re implemented using the type synonym technology I’ve been trying to convince you is inferior to alias templates!

There’s a historical reason for that, but we’ll skip over it (it’s dull, I promise), because the Standardization Committee belatedly recognized that alias templates are the better way to go, and they included such templates in C++14 for all the C++11 type transformations. The aliases have a common form: for each C++11 transformation std:: *transformation*\<T\>::type, there’s a corresponding C++14 alias template named std:: *transformation***\_t**. Examples will clarify what I mean: std::remove_const\<T\>::type // C++11: const T → T

std::remove_const**\_t**\<T\> // C++14 equivalent

std::remove_reference\<T\>::type // C++11: T&/T&& → T

std::remove_reference**\_t**\<T\> // C++14 equivalent

std::add_lvalue_reference\<T\>::type // C++11: T → T&

std::add_lvalue_reference**\_t**\<T\> // C++14 equivalent

The C++11 constructs remain valid in C++14, but I don’t know why you’d want to use them. Even if you don’t have access to C++14, writing the alias templates yourself is child’s play. Only C++11 language features are required, and even children can **66 \| Item 9**

mimic a pattern, right? If you happen to have access to an electronic copy of the C++14 Standard, it’s easier still, because all that’s required is some copying and past-ing. Here, I’ll get you started:

template \<class T\>

using remove_const_t = typename remove_const\<T\>::type;

template \<class T\>

using remove_reference_t = typename remove_reference\<T\>::type;

template \<class T\>

using add_lvalue_reference_t =

typename add_lvalue_reference\<T\>::type;

See? Couldn’t be easier.

**Things to Remember**

• typedefs don’t support templatization, but alias declarations do.

• Alias templates avoid the “::type” suffix and, in templates, the “typename”

prefix often required to refer to typedefs.

• C++14 offers alias templates for all the C++11 type traits transformations.

**Item 10: Prefer scoped enums to unscoped enums.**

As a general rule, declaring a name inside curly braces limits the visibility of that name to the scope defined by the braces. Not so for the enumerators declared in C++98-style enums. The names of such enumerators belong to the scope containing the enum, and that means that nothing else in that scope may have the same name: enum Color { **black**, **white**, **red** }; // black, white, red are

// in same scope as Color

auto **white** = false; // error! white already

// declared in this scope

The fact that these enumerator names leak into the scope containing their enum definition gives rise to the official term for this kind of enum: *unscoped*. Their new C++11

counterparts, *scoped enums*, don’t leak names in this way:

**enum** **class** Color { black, white, red }; // black, white, red

// are scoped to Color

auto **white** = false; // fine, no other

**Item 9 \| 67**

// "white" in scope Color c = **white**; // error! no enumerator named

// "white" is in this scope

Color c = **Color::white**; // fine

auto c = **Color::white**; // also fine (and in accord

// with Item 5's advice)

Because scoped enums are declared via “enum class”, they’re sometimes referred to as *enum classes*.

The reduction in namespace pollution offered by scoped enums is reason enough to prefer them over their unscoped siblings, but scoped enums have a second compelling advantage: their enumerators are much more strongly typed. Enumerators for unscoped enums implicitly convert to integral types (and, from there, to floating-point types). Semantic travesties such as the following are therefore completely valid: enum Color { black, white, red }; // unscoped enum

std::vector\<std::size_t\> // func. returning

primeFactors(std::size_t x); // prime factors of x

Color c = red;

…

if (c \< 14.5) { // compare Color to double (!)

auto factors = // compute prime factors

primeFactors(c); // of a Color (!)

…

}

Throw a simple “class” after “enum”, however, thus transforming an unscoped enum into a scoped one, and it’s a very different story. There are no implicit conversions from enumerators in a scoped enum to any other type:

enum **class** Color { black, white, red }; // enum is now scoped

Color c = **Color::**red; // as before, but

… // with scope qualifier

if (c \< 14.5) { // error! can't compare

// Color and double

**68 \| Item 10**

auto factors = // error! can't pass Color to primeFactors(c); // function expecting std::size_t

…

}

If you honestly want to perform a conversion from Color to a different type, do what you always do to twist the type system to your wanton desires—use a cast: if (**static_cast\<double\>(**c**)** \< 14.5) { // odd code, but

// it's valid

auto factors = // suspect, but

primeFactors(**static_cast\<std::size_t\>(**c**)**); // it compiles

…

}

It may seem that scoped enums have a third advantage over unscoped enums, because scoped enums may be forward-declared, i.e., their names may be declared without specifying their enumerators:

enum Color; // error!

enum class Color; // fine

This is misleading. In C++11, unscoped enums may also be forward-declared, but only after a bit of additional work. The work grows out of the fact that every enum in C++ has an integral *underlying type* that is determined by compilers. For an unscoped enum like Color,

enum Color { black, white, red };

compilers might choose char as the underlying type, because there are only three values to represent. However, some enums have a range of values that is much larger, e.g.:

enum Status { good = 0,

failed = 1,

incomplete = 100,

corrupt = 200,

indeterminate = 0xFFFFFFFF

};

Here the values to be represented range from 0 to 0xFFFFFFFF. Except on unusual machines (where a char consists of at least 32 bits), compilers will have to select an integral type larger than char for the representation of Status values.

**Item 10 \| 69**

To make efficient use of memory, compilers often want to choose the smallest underlying type for an enum that’s sufficient to represent its range of enumerator values. In some cases, compilers will optimize for speed instead of size, and in that case, they may not choose the smallest permissible underlying type, but they certainly want to be *able* to optimize for size. To make that possible, C++98 supports only enum definitions (where all enumerators are listed); enum declarations are not allowed. That makes it possible for compilers to select an underlying type for each enum prior to the enum being used.

But the inability to forward-declare enums has drawbacks. The most notable is probably the increase in compilation dependencies. Consider again the Status enum: enum Status { good = 0,

failed = 1,

incomplete = 100,

corrupt = 200,

indeterminate = 0xFFFFFFFF

};

This is the kind of enum that’s likely to be used throughout a system, hence included in a header file that every part of the system is dependent on. If a new status value is then introduced,

enum Status { good = 0,

failed = 1,

incomplete = 100,

corrupt = 200,

**audited = 500,**

indeterminate = 0xFFFFFFFF

};

it’s likely that the entire system will have to be recompiled, even if only a single sub-system—possibly only a single function!—uses the new enumerator. This is the kind of thing that people *hate*. And it’s the kind of thing that the ability to forward-declare enums in C++11 eliminates. For example, here’s a perfectly valid declaration of a scoped enum and a function that takes one as a parameter:

enum class Status; // forward declaration

void continueProcessing(Status s); // use of fwd-declared enum

The header containing these declarations requires no recompilation if Status’s definition is revised. Furthermore, if Status is modified (e.g., to add the audited enumerator), but continueProcessing’s behavior is unaffected (e.g., because **70 \| Item 10**

continueProcessing doesn’t use audited), continueProcessing’s implementation need not be recompiled, either.

But if compilers need to know the size of an enum before it’s used, how can C++11’s enums get away with forward declarations when C++98’s enums can’t? The answer is simple: the underlying type for a scoped enum is always known, and for unscoped enums, you can specify it.

By default, the underlying type for scoped enums is int:

enum class Status; // underlying type is int

If the default doesn’t suit you, you can override it:

enum class Status**: std::uint32_t**; // underlying type for

// Status is std::uint32_t

// (from \<cstdint\>)

Either way, compilers know the size of the enumerators in a scoped enum.

To specify the underlying type for an unscoped enum, you do the same thing as for a scoped enum, and the result may be forward-declared:

enum Color**: std::uint8_t**; // fwd decl for unscoped enum;

// underlying type is

// std::uint8_t

Underlying type specifications can also go on an enum’s definition:

enum class Status**: std::uint32_t** { good = 0,

failed = 1,

incomplete = 100,

corrupt = 200,

audited = 500,

indeterminate = 0xFFFFFFFF

};

In view of the fact that scoped enums avoid namespace pollution and aren’t susceptible to nonsensical implicit type conversions, it may surprise you to hear that there’s at least one situation where unscoped enums may be useful. That’s when referring to fields within C++11’s std::tuples. For example, suppose we have a tuple holding values for the name, email address, and reputation value for a user at a social networking website:

using UserInfo = // type alias; see Item 9

std::tuple\<std::string, // name

**Item 10 \| 71**

std::string, // email

std::size_t\> ; // reputation

Though the comments indicate what each field of the tuple represents, that’s probably not very helpful when you encounter code like this in a separate source file: UserInfo uInfo; // object of tuple type

…

auto val = **std::get\<1\>** (uInfo); // get value of field 1

As a programmer, you have a lot of stuff to keep track of. Should you really be expected to remember that field 1 corresponds to the user’s email address? I think not. Using an unscoped enum to associate names with field numbers avoids the need to:

**enum UserInfoFields { uiName, uiEmail, uiReputation };**

UserInfo uInfo; // as before

…

auto val = std::get\< **uiEmail**\>(uInfo); // ah, get value of

// email field

What makes this work is the implicit conversion from UserInfoFields to

std::size_t, which is the type that std::get requires.

The corresponding code with scoped enums is substantially more verbose: enum **class** UserInfoFields { uiName, uiEmail, uiReputation };

UserInfo uInfo; // as before

…

auto val =

std::get\< **static_cast\<std::size_t\>(UserInfoFields::uiEmail)**\> (uInfo);

The verbosity can be reduced by writing a function that takes an enumerator and returns its corresponding std::size_t value, but it’s a bit tricky. std::get is a template, and the value you provide is a template argument (notice the use of angle brackets, not parentheses), so the function that transforms an enumerator into a std::size_t has to produce its result *during compilation*. As Item 15 explains, that means it must be a constexpr function.

In fact, it should really be a constexpr function template, because it should work with any kind of enum. And if we’re going to make that generalization, we should **72 \| Item 10**

generalize the return type, too. Rather than returning std::size_t, we’ll return the enum’s underlying type. It’s available via the std::underlying_type type trait. (See

Item 9 for information on type traits.) Finally, we’ll declare it noexcept (see Item 14),

because we know it will never yield an exception. The result is a function template toUType that takes an arbitrary enumerator and can return its value as a compile-time constant:

template\<typename E\>

constexpr typename std::underlying_type\<E\>::type

toUType(E enumerator) noexcept

{

return

static_cast\<typename

std::underlying_type\<E\>::type\>(enumerator);

}

In C++14, toUType can be simplified by replacing typename std::underly

ing_type\<E\>::type with the sleeker std::underlying_type_t (see Item 9):

template\<typename E\> // C++14

constexpr std::underlying_type**\_t**\<E\>

toUType(E enumerator) noexcept

{

return static_cast\<std::underlying_type**\_t**\<E\>\>(enumerator);

}

The even-sleeker auto return type (see Item 3) is also valid in C++14:

template\<typename E\> // C++14

constexpr **auto**

toUType(E enumerator) noexcept

{

return static_cast\<std::underlying_type_t\<E\>\>(enumerator);

}

Regardless of how it’s written, toUType permits us to access a field of the tuple like this:

auto val = std::get\< **toUType(UserInfoFields::uiEmail)**\>(uInfo); It’s still more to write than use of the unscoped enum, but it also avoids namespace pollution and inadvertent conversions involving enumerators. In many cases, you may decide that typing a few extra characters is a reasonable price to pay for the ability to avoid the pitfalls of an enum technology that dates to a time when the state of the art in digital telecommunications was the 2400-baud modem.

**Item 10 \| 73**

**Things to Remember**

• C++98-style enums are now known as unscoped enums.

• Enumerators of scoped enums are visible only within the enum. They convert to other types only with a cast.

• Both scoped and unscoped enums support specification of the underlying type.

The default underlying type for scoped enums is int. Unscoped enums have no default underlying type.

• Scoped enums may always be forward-declared. Unscoped enums may be

forward-declared only if their declaration specifies an underlying type.

**Item 11: Prefer deleted functions to private undefined**

**ones.**

If you’re providing code to other developers, and you want to prevent them from calling a particular function, you generally just don’t declare the function. No function declaration, no function to call. Easy, peasy. But sometimes C++ declares functions for you, and if you want to prevent clients from calling those functions, the peasy isn’t quite so easy any more.

The situation arises only for the “special member functions,” i.e., the member func‐

tions that C++ automatically generates when they’re needed. Item 17 discusses these functions in detail, but for now, we’ll worry only about the copy constructor and the copy assignment operator. This chapter is largely devoted to common practices in C++98 that have been superseded by better practices in C++11, and in C++98, if you want to suppress use of a member function, it’s almost always the copy constructor, the assignment operator, or both.

The C++98 approach to preventing use of these functions is to declare them private and not define them. For example, near the base of the iostreams hierarchy in the C++ Standard Library is the class template basic_ios. All istream and ostream classes inherit (possibly indirectly) from this class. Copying istreams and ostreams is undesirable, because it’s not really clear what such operations should do. An istream object, for example, represents a stream of input values, some of which may have already been read, and some of which will potentially be read later. If an istream were to be copied, would that entail copying all the values that had already been read as well as all the values that would be read in the future? The easiest way to deal with such questions is to define them out of existence. Prohibiting the copying of streams does just that.

**74 \| Item 10**

To render istream and ostream classes uncopyable, basic_ios is specified in C++98

as follows (including the comments):

template \<class charT, class traits = char_traits\<charT\> \>

class basic_ios : public ios_base {

public:

…

**private:**

basic_ios(const basic_ios& ); // not defined

basic_ios& operator=(const basic_ios&); // not defined

};

Declaring these functions private prevents clients from calling them. Deliberately failing to define them means that if code that still has access to them (i.e., member functions or friends of the class) uses them, linking will fail due to missing function definitions.

In C++11, there’s a better way to achieve essentially the same end: use “= delete” to mark the copy constructor and the copy assignment operator as *deleted functions*.

Here’s the same part of basic_ios as it’s specified in C++11:

template \<class charT, class traits = char_traits\<charT\> \>

class basic_ios : public ios_base {

**public:**

…

basic_ios(const basic_ios& ) **= delete;**

basic_ios& operator=(const basic_ios&) **= delete;**

…

};

The difference between deleting these functions and declaring them private may seem more a matter of fashion than anything else, but there’s greater substance here than you might think. Deleted functions may not be used in any way, so even code that’s in member and friend functions will fail to compile if it tries to copy basic_ios objects. That’s an improvement over the C++98 behavior, where such improper usage wouldn’t be diagnosed until link-time.

By convention, deleted functions are declared public, not private. There’s a reason for that. When client code tries to use a member function, C++ checks accessibility before deleted status. When client code tries to use a deleted private function, some compilers complain only about the function being private, even though the function’s accessibility doesn’t really affect whether it can be used. It’s worth bearing this in mind when revising legacy code to replace private-and-not-defined member **Item 11 \| 75**

functions with deleted ones, because making the new functions public will generally result in better error messages.

An important advantage of deleted functions is that *any* function may be deleted, while only member functions may be private. For example, suppose we have a non-member function that takes an integer and returns whether it’s a lucky number: bool isLucky(int number);

C++’s C heritage means that pretty much any type that can be viewed as vaguely numerical will implicitly convert to int, but some calls that would compile might not make sense:

if (isLucky('a')) … // is 'a' a lucky number?

if (isLucky(true)) … // is "true"?

if (isLucky(3.5)) … // should we truncate to 3

// before checking for luckiness?

If lucky numbers must really be integers, we’d like to prevent calls such as these from compiling.

One way to accomplish that is to create deleted overloads for the types we want to filter out:

bool isLucky(int number); // original function

bool isLucky(char) **= delete**; // reject chars

bool isLucky(bool) **= delete**; // reject bools

bool isLucky(double) **= delete**; // reject doubles and

// floats

(The comment on the double overload that says that both doubles and floats will be rejected may surprise you, but your surprise will dissipate once you recall that, given a choice between converting a float to an int or to a double, C++ prefers the conversion to double. Calling isLucky with a float will therefore call the double overload, not the int one. Well, it’ll try to. The fact that that overload is deleted will prevent the call from compiling.)

Although deleted functions can’t be used, they are part of your program. As such, they are taken into account during overload resolution. That’s why, with the deleted function declarations above, the undesirable calls to isLucky will be rejected: if (isLucky('a')) … // error! call to deleted function

**76 \| Item 11**

if (isLucky(true)) … // error!

if (isLucky(3.5f)) … // error!

Another trick that deleted functions can perform (and that private member functions can’t) is to prevent use of template instantiations that should be disabled. For

example, suppose you need a template that works with built-in pointers (Chapter 4’s

advice to prefer smart pointers to raw pointers notwithstanding):

template\<typename T\>

void processPointer(T\* ptr);

There are two special cases in the world of pointers. One is void\* pointers, because there is no way to dereference them, to increment or decrement them, etc. The other is char\* pointers, because they typically represent pointers to C-style strings, not pointers to individual characters. These special cases often call for special handling, and, in the case of the processPointer template, let’s assume the proper handling is to reject calls using those types. That is, it should not be possible to call processPointer with void\* or char\* pointers.

That’s easily enforced. Just delete those instantiations:

template\<\>

void processPointer\<void\>(void\*) = delete;

template\<\>

void processPointer\<char\>(char\*) = delete;

Now, if calling processPointer with a void\* or a char\* is invalid, it’s probably also invalid to call it with a const void\* or a const char\*, so those instantiations will typically need to be deleted, too:

template\<\>

void processPointer\<const void\>(const void\*) = delete;

template\<\>

void processPointer\<const char\>(const char\*) = delete;

And if you really want to be thorough, you’ll also delete the const volatile void\*

and const volatile char\* overloads, and then you’ll get to work on the overloads for pointers to the other standard character types: std::wchar_t, std::char16_t, and std::char32_t.

Interestingly, if you have a function template inside a class, and you’d like to disable some instantiations by declaring them private (à la classic C++98 convention), you can’t, because it’s not possible to give a member function template specialization a **Item 11 \| 77**

different access level from that of the main template. If processPointer were a member function template inside Widget, for example, and you wanted to disable calls for void\* pointers, this would be the C++98 approach, though it would not compile:


public:

…

template\<typename T\>

void processPointer(T\* ptr)

{ … }


template\<\> // error!

void processPointer\<void\>(void\*);

};

The problem is that template specializations must be written at namespace scope, not class scope. This issue doesn’t arise for deleted functions, because they don’t need a different access level. They can be deleted outside the class (hence at namespace scope):


public:

…

template\<typename T\>

void processPointer(T\* ptr)

{ … }

…

};

template\<\> // still

void Widget::processPointer\<void\>(void\*) = delete; // public,

// but

// deleted

The truth is that the C++98 practice of declaring functions private and not defining them was really an attempt to achieve what C++11’s deleted functions actually accomplish. As an emulation, the C++98 approach is not as good as the real thing. It doesn’t work outside classes, it doesn’t always work inside classes, and when it does work, it may not work until link-time. So stick to deleted functions.

**78 \| Item 11**

**Things to Remember**

• Prefer deleted functions to private undefined ones.

• Any function may be deleted, including non-member functions and template instantiations.

**Item 12: Declare overriding functions override.**

The world of object-oriented programming in C++ revolves around classes, inheritance, and virtual functions. Among the most fundamental ideas in this world is that virtual function implementations in derived classes *override* the implementations of their base class counterparts. It’s disheartening, then, to realize just how easily virtual function overriding can go wrong. It’s almost as if this part of the language were designed with the idea that Murphy’s Law wasn’t just to be obeyed, it was to be honored.

Because “overriding” sounds a lot like “overloading,” yet is completely unrelated, let me make clear that virtual function overriding is what makes it possible to invoke a derived class function through a base class interface:

class Base {

public:

virtual void doWork(); // base class virtual function

…

};

class Derived: public Base {

public:

virtual void doWork(); // overrides Base::doWork

… // ("virtual" is optional

}; // here)

std::unique_ptr\< **Base**\> upb = // create base class pointer std::make_unique\< **Derived**\>(); // to derived class object;

// see Item 21 for info on

… // std::make_unique

upb-\>doWork(); // call doWork through base

// class ptr; derived class

// function is invoked

For overriding to occur, several requirements must be met:

**Item 11 \| 79**

• The base class function must be virtual.

• The base and derived function names must be identical (except in the case of destructors).

• The parameter types of the base and derived functions must be identical.

• The constness of the base and derived functions must be identical.

• The return types and exception specifications of the base and derived functions must be compatible.

To these constraints, which were also part of C++98, C++11 adds one more:

• The functions’ *reference qualifiers* must be identical. Member function reference qualifiers are one of C++11’s less-publicized features, so don’t be surprised if you’ve never heard of them. They make it possible to limit use of a member function to lvalues only or to rvalues only. Member functions need not be virtual to use them:


public:

…

void doWork() **&** ; // this version of doWork applies

// only when \*this is an lvalue

void doWork() **&&** ; // this version of doWork applies

}; // only when \*this is an rvalue

…

Widget makeWidget(); // factory function (returns rvalue)

Widget w; // normal object (an lvalue)

…

w.doWork(); // calls Widget::doWork for lvalues

// (i.e., Widget::doWork &)

makeWidget().doWork(); // calls Widget::doWork for rvalues

// (i.e., Widget::doWork &&)

I’ll say more about member functions with reference qualifiers later, but for now, simply note that if a virtual function in a base class has a reference qualifier, derived class overrides of that function must have exactly the same reference **80 \| Item 12**

qualifier. If they don’t, the declared functions will still exist in the derived class, but they won’t override anything in the base class.

All these requirements for overriding mean that small mistakes can make a big difference. Code containing overriding errors is typically valid, but its meaning isn’t what you intended. You therefore can’t rely on compilers notifying you if you do something wrong. For example, the following code is completely legal and, at first sight, looks reasonable, but it contains no virtual function overrides—not a single derived class function that is tied to a base class function. Can you identify the problem in each case, i.e., why each derived class function doesn’t override the base class function with the same name?

class Base {

public:

virtual void mf1() const;

virtual void mf2(int x);

virtual void mf3() &;

void mf4() const;

};

class Derived: public Base {

public:

virtual void mf1();

virtual void mf2(unsigned int x);

virtual void mf3() &&;

void mf4() const;

};

Need some help?

• mf1 is declared const in Base, but not in Derived.

• mf2 takes an int in Base, but an unsigned int in Derived.

• mf3 is lvalue-qualified in Base, but rvalue-qualified in Derived.

• mf4 isn’t declared virtual in Base.

You may think, “Hey, in practice, these things will elicit compiler warnings, so I don’t need to worry.” Maybe that’s true. But maybe it’s not. With two of the compilers I checked, the code was accepted without complaint, and that was with all warnings enabled. (Other compilers provided warnings about some of the issues, but not all of them.)

Because declaring derived class overrides is important to get right, but easy to get wrong, C++11 gives you a way to make explicit that a derived class function is **Item 12 \| 81**

supposed to override a base class version: declare it override. Applying this to the example above would yield this derived class:

class Derived: public Base {

public:

virtual void mf1() **override**;

virtual void mf2(unsigned int x) **override**;

virtual void mf3() && **override**;

virtual void mf4() const **override**;

};

This won’t compile, of course, because when written this way, compilers will kvetch about all the overriding-related problems. That’s exactly what you want, and it’s why you should declare all your overriding functions override.

The code using override that does compile looks as follows (assuming that the goal is for all functions in Derived to override virtuals in Base):

class Base {

public:

virtual void mf1() const;

virtual void mf2(int x);

virtual void mf3() &;

**virtual** void mf4() const;

};

class Derived: public Base {

public:

virtual void mf1() **const** override;

virtual void mf2(**int** x) override;

virtual void mf3() **&** override;

void mf4() const override; // adding "virtual" is OK,

}; // but not necessary

Note that in this example, part of getting things to work involves declaring mf4 virtual in Base. Most overriding-related errors occur in derived classes, but it’s possible for things to be incorrect in base classes, too.

A policy of using override on all your derived class overrides can do more than just enable compilers to tell you when would-be overrides aren’t overriding anything. It can also help you gauge the ramifications if you’re contemplating changing the signature of a virtual function in a base class. If derived classes use override everywhere, you can just change the signature, recompile your system, see how much damage you’ve caused (i.e., how many derived classes fail to compile), then decide whether the signature change is worth the trouble. Without override, you’d have to hope you have comprehensive unit tests in place, because, as we’ve seen, derived class virtuals **82 \| Item 12**

that are supposed to override base class functions, but don’t, need not elicit compiler diagnostics.

C++ has always had keywords, but C++11 introduces two *contextual keywords*, over ride and final.2 These keywords have the characteristic that they are reserved, but only in certain contexts. In the case of override, it has a reserved meaning only when it occurs at the end of a member function declaration. That means that if you have legacy code that already uses the name override, you don’t need to change it for C++11:

class Warning { // potential legacy class from C++98

public:

…

void **override**(); // legal in both C++98 and C++11

… // (with the same meaning)

};

That’s all there is to say about override, but it’s not all there is to say about member function reference qualifiers. I promised I’d provide more information on them later, and now it’s later.

If we want to write a function that accepts only lvalue arguments, we declare a non-const lvalue reference parameter:

void doSomething(Widget**&** w); // accepts only lvalue Widgets If we want to write a function that accepts only rvalue arguments, we declare an rvalue reference parameter:

void doSomething(Widget**&&** w); // accepts only rvalue Widgets Member function reference qualifiers simply make it possible to draw the same distinction for the object on which a member function is invoked, i.e., \*this. It’s precisely analogous to the const at the end of a member function declaration, which indicates that the object on which the member function is invoked (i.e., \*this) is const.

The need for reference-qualified member functions is not common, but it can arise.

For example, suppose our Widget class has a std::vector data member, and we offer an accessor function that gives clients direct access to it:


public:

2 Applying final to a virtual function prevents the function from being overridden in derived classes. final may also be applied to a class, in which case the class is prohibited from being used as a base class.

**Item 12 \| 83**

using DataType = std::vector\<double\>; // see Item 9 for

… // info on "using"

DataType& data() { return values; }

…


DataType values;

};

This is hardly the most encapsulated design that’s seen the light of day, but set that aside and consider what happens in this client code:

Widget w;

…

auto vals1 = w.data(); // copy w.values into vals1

The return type of Widget::data is an lvalue reference (a std::vector\<double\>&, to be precise), and because lvalue references are defined to be lvalues, we’re initializing vals1 from an lvalue. vals1 is thus copy constructed from w.values, just as the comment says.

Now suppose we have a factory function that creates Widgets,

Widget makeWidget();

and we want to initialize a variable with the std::vector inside the Widget returned from makeWidget:

auto vals2 = makeWidget().data(); // copy values inside the

// Widget into vals2

Again, Widgets::data returns an lvalue reference, and, again, the lvalue reference is an lvalue, so, again, our new object (vals2) is copy constructed from values inside the Widget. This time, though, the Widget is the temporary object returned from makeWidget (i.e., an rvalue), so copying the std::vector inside it is a waste of time.

It’d be preferable to move it, but, because data is returning an lvalue reference, the rules of C++ require that compilers generate code for a copy. (There’s some wiggle room for optimization through what is known as the “as if rule,” but you’d be foolish to rely on your compilers finding a way to take advantage of it.)

What’s needed is a way to specify that when data is invoked on an rvalue Widget, the result should also be an rvalue. Using reference qualifiers to overload data for lvalue and rvalue Widgets makes that possible:

**84 \| Item 12**


public:

using DataType = std::vector\<double\>;

…

DataType& data() **&** // for lvalue Widgets,

{ return values; } // return lvalue

DataType data() **&&** // for rvalue Widgets,

{ return std::move(values); } // return rvalue

…


DataType values;

};

Notice the differing return types from the data overloads. The lvalue reference overload returns an lvalue reference (i.e., an lvalue), and the rvalue reference overload returns a temporary object (i.e., an rvalue). This means that client code now behaves as we’d like:

auto vals1 = w.data(); // calls lvalue overload for

// Widget::data, *copy*-

// constructs vals1

auto vals2 = makeWidget().data(); // calls rvalue overload for

// Widget::data, *move*-

// constructs vals2

This is certainly nice, but don’t let the warm glow of this happy ending distract you from the true point of this Item. That point is that whenever you declare a function in a derived class that’s meant to override a virtual function in a base class, be sure to declare that function override.

**Things to Remember**

• Declare overriding functions override.

• Member function reference qualifiers make it possible to treat lvalue and rvalue objects (\*this) differently.

**Item 12 \| 85**

**Item 13: Prefer const_iterators to iterators.**

const_iterators are the STL equivalent of pointers-to-const. They point to values that may not be modified. The standard practice of using const whenever possible dictates that you should use const_iterators any time you need an iterator, yet have no need to modify what the iterator points to.

That’s as true for C++98 as for C++11, but in C++98, const_iterators had only halfhearted support. It wasn’t that easy to create them, and once you had one, the ways you could use it were limited. For example, suppose you want to search a std::vector\<int\> for the first occurrence of 1983 (the year “C++” replaced “C with Classes” as the name of the programming language), then insert the value 1998 (the year the first ISO C++ Standard was adopted) at that location. If there’s no 1983 in the vector, the insertion should go at the end of the vector. Using iterators in C++98, that was easy:

std::vector\<int\> values;

…

std::vector\<int\>::iterator it =

std::find(values.begin(),values.end(), 1983);

values.insert(it, 1998);

But iterators aren’t really the proper choice here, because this code never modifies what an iterator points to. Revising the code to use const_iterators should be trivial, but in C++98, it was anything but. Here’s one approach that’s conceptually sound, though still not correct:

typedef std::vector\<int\>::iterator IterT; // type-

typedef std::vector\<int\>::const_iterator ConstIterT; // defs

std::vector\<int\> values;

…

ConstIterT ci =

std::find(**static_cast\<ConstIterT\>(**values.begin()**)**, // cast **static_cast\<ConstIterT\>(**values.end()**)**, // cast

1983);

values.insert(**static_cast\<IterT\>(ci)**, 1998); // may not

// compile; see

// below

**86 \| Item 13**

The typedefs aren’t required, of course, but they make the casts in the code easier to write. (If you’re wondering why I’m showing typedefs instead of following the

advice of Item 9 to use alias declarations, it’s because this example shows C++98

code, and alias declarations are a feature new to C++11.)

The casts in the call to std::find are present because values is a non-const container and in C++98, there was no simple way to get a const_iterator from a non-const container. The casts aren’t strictly necessary, because it was possible to get const_iterators in other ways (e.g., you could bind values to a reference-to-const variable, then use that variable in place of values in your code), but one way or another, the process of getting const_iterators to elements of a non-const container involved some amount of contorting.

Once you had the const_iterators, matters often got worse, because in C++98, locations for insertions (and erasures) could be specified only by iterators.

const_iterators weren’t acceptable. That’s why, in the code above, I cast the const_iterator (that I was so careful to get from std::find) into an iterator: passing a const_iterator to insert wouldn’t compile.

To be honest, the code I’ve shown might not compile, either, because there’s no portable conversion from a const_iterator to an iterator, not even with a static_cast. Even the semantic sledgehammer known as reinterpret_cast can’t do the job. (That’s not a C++98 restriction. It’s true in C++11, too. const_iterators simply don’t convert to iterators, no matter how much it might seem like they should.) There are some portable ways to generate iterators that point where const_iterators do, but they’re not obvious, not universally applicable, and not worth discussing in this book. Besides, I hope that by now my point is clear: const_iterators were so much trouble in C++98, they were rarely worth the bother. At the end of the day, developers don’t use const whenever *possible*, they use it whenever *practical*, and in C++98, const_iterators just weren’t very practical.

All that changed in C++11. Now const_iterators are both easy to get and easy to use. The container member functions cbegin and cend produce const_iterators, even for non-const containers, and STL member functions that use iterators to identify positions (e.g., insert and erase) actually use const_iterators. Revising the original C++98 code that uses iterators to use const_iterators in C++11 is truly trivial:

std::vector\<int\> values; // as before

…

**auto** it = // use cbegin **Item 13 \| 87**

std::find(values. **c**begin(),values. **c**end(), 1983); // and cend values.insert(it, 1998);

Now *that’s* code using const_iterators that’s practical!

About the only situation in which C++11’s support for const_iterators comes up a bit short is when you want to write maximally generic library code. Such code takes into account that some containers and container-like data structures offer begin and end (plus cbegin, cend, rbegin, etc.) as *non-member* functions, rather than members. This is the case for built-in arrays, for example, and it’s also the case for some third-party libraries with interfaces consisting only of free functions. Maximally generic code thus uses non-member functions rather than assuming the existence of member versions.

For example, we could generalize the code we’ve been working with into a findAnd Insert template as follows:

template\<typename C, typename V\>

void findAndInsert(C& container, // in container, find

const V& targetVal, // first occurrence

const V& insertVal) // of targetVal, then

{ // insert insertVal

**using std::cbegin;** // there

**using std::cend;**

auto it = std::find(**cbegin**(container), // non-member cbegin

**cend**(container), // non-member cend

targetVal);

container.insert(it, insertVal);

}

This works fine in C++14, but, sadly, not in C++11. Through an oversight during standardization, C++11 added the non-member functions begin and end, but it failed to add cbegin, cend, rbegin, rend, crbegin, and crend. C++14 rectifies that oversight.

If you’re using C++11, you want to write maximally generic code, and none of the libraries you’re using provides the missing templates for non-member cbegin and friends, you can throw your own implementations together with ease. For example, here’s an implementation of non-member cbegin:

template \<class C\>

auto cbegin(const C& container)-\>decltype(std::begin(container))

{

**88 \| Item 13**

return std::begin(container); // see explanation below

}

You’re surprised to see that non-member cbegin doesn’t call member cbegin, aren’t you? So was I. But follow the logic. This cbegin template accepts any type of argument representing a container-like data structure, C, and it accesses this argument through its reference-to-const parameter, container. If C is a conventional container type (e.g., a std::vector\<int\>), container will be a reference to a const version of that container (e.g., a const std::vector\<int\>&). Invoking the non-member begin function (provided by C++11) on a const container yields a const_iterator, and that iterator is what this template returns. The advantage of implementing things this way is that it works even for containers that offer a begin member function (which, for containers, is what C++11’s non-member begin calls), but fail to offer a cbegin member. You can thus use this non-member cbegin on containers that directly support only begin.

This template also works if C is a built-in array type. In that case, container becomes a reference to a const array. C++11 provides a specialized version of non-member begin for arrays that returns a pointer to the array’s first element. The elements of a const array are const, so the pointer that non-member begin returns for a const array is a pointer-to-const, and a pointer-to-const is, in fact, a const_iterator for an array. (For insight into how a template can be specialized for built-in arrays, consult Item 1’s discussion of type deduction in templates that take reference parameters to arrays.)

But back to basics. The point of this Item is to encourage you to use const_itera tors whenever you can. The fundamental motivation—using const whenever it’s meaningful—predates C++11, but in C++98, it simply wasn’t practical when working with iterators. In C++11, it’s eminently practical, and C++14 tidies up the few bits of unfinished business that C++11 left behind.

**Things to Remember**

• Prefer const_iterators to iterators.

• In maximally generic code, prefer non-member versions of begin, end,

rbegin, etc., over their member function counterparts.

**Item 13 \| 89**

**Item 14: Declare functions noexcept if they won’t emit** **exceptions.**

In C++98, exception specifications were rather temperamental beasts. You had to summarize the exception types a function might emit, so if the function’s implementation was modified, the exception specification might require revision, too. Changing an exception specification could break client code, because callers might be dependent on the original exception specification. Compilers typically offered no help in maintaining consistency among function implementations, exception specifications, and client code. Most programmers ultimately decided that C++98 exception specifications weren’t worth the trouble.

During work on C++11, a consensus emerged that the truly meaningful information about a function’s exception-emitting behavior was whether it had any. Black or white, either a function might emit an exception or it guaranteed that it wouldn’t.

This maybe-or-never dichotomy forms the basis of C++11’s exception specifications, which essentially replace C++98’s. (C++98-style exception specifications remain valid, but they’re deprecated.) In C++11, unconditional noexcept is for functions that guarantee they won’t emit exceptions.

Whether a function should be so declared is a matter of interface design. The exception-emitting behavior of a function is of key interest to clients. Callers can query a function’s noexcept status, and the results of such a query can affect the exception safety or efficiency of the calling code. As such, whether a function is noexcept is as important a piece of information as whether a member function is const. Failure to declare a function noexcept when you know that it won’t emit an exception is simply poor interface specification.

But there’s an additional incentive to apply noexcept to functions that won’t produce exceptions: it permits compilers to generate better object code. To understand why, it helps to examine the difference between the C++98 and C++11 ways of saying that a function won’t emit exceptions. Consider a function f that promises callers they’ll never receive an exception. The two ways of expressing that are: int f(int x) **throw()**; // no exceptions from f: *C++98 style* int f(int x) **noexcept**; // no exceptions from f: *C++11 style* If, at runtime, an exception leaves f, f’s exception specification is violated. With the C++98 exception specification, the call stack is unwound to f’s caller, and, after some actions not relevant here, program execution is terminated. With the C++11 exception specification, runtime behavior is slightly different: the stack is only *possibly* unwound before program execution is terminated.

**90 \| Item 14**

The difference between unwinding the call stack and *possibly* unwinding it has a surprisingly large impact on code generation. In a noexcept function, optimizers need not keep the runtime stack in an unwindable state if an exception would propagate out of the function, nor must they ensure that objects in a noexcept function are destroyed in the inverse order of construction should an exception leave the function.

Functions with “throw()” exception specifications lack such optimization flexibility, as do functions with no exception specification at all. The situation can be summarized this way:

*RetType function*( *params*) **noexcept**; // most optimizable *RetType function*( *params*) **throw()**; // less optimizable *RetType function*( *params*); // less optimizable This alone is sufficient reason to declare functions noexcept whenever you know they won’t produce exceptions.

For some functions, the case is even stronger. The move operations are the preemi-nent example. Suppose you have a C++98 code base making use of a std::vec tor\<Widget\>. Widgets are added to the std::vector from time to time via push_back:

std::vector\<Widget\> vw;

…

Widget w;

… // work with w

vw.push_back(w); // add w to vw

…

Assume this code works fine, and you have no interest in modifying it for C++11.

However, you do want to take advantage of the fact that C++11’s move semantics can improve the performance of legacy code when move-enabled types are involved. You therefore ensure that Widget has move operations, either by writing them yourself or by seeing to it that the conditions for their automatic generation are fulfilled (see

Item 17).

When a new element is added to a std::vector, it’s possible that the std::vector lacks space for it, i.e., that the std::vector’s size is equal to its capacity. When that happens, the std::vector allocates a new, larger, chunk of memory to hold its **Item 14 \| 91**

elements, and it transfers the elements from the existing chunk of memory to the new one. In C++98, the transfer was accomplished by copying each element from the old memory to the new memory, then destroying the objects in the old memory. This approach enabled push_back to offer the strong exception safety guarantee: if an exception was thrown during the copying of the elements, the state of the std::vec tor remained unchanged, because none of the elements in the old memory were destroyed until all elements had been successfully copied into the new memory.

In C++11, a natural optimization would be to replace the copying of std::vector elements with moves. Unfortunately, doing this runs the risk of violating push_back’s exception safety guarantee. If *n* elements have been moved from the old memory and an exception is thrown moving element *n+1*, the push_back operation can’t run to completion. But the original std::vector has been modified: *n* of its elements have been moved from. Restoring their original state may not be possible, because attempting to move each object back into the original memory may itself yield an exception.

This is a serious problem, because the behavior of legacy code could depend on push_back’s strong exception safety guarantee. Therefore, C++11 implementations can’t silently replace copy operations inside push_back with moves unless it’s known that the move operations won’t emit exceptions. In that case, having moves replace copies would be safe, and the only side effect would be improved performance.

std::vector::push_back takes advantage of this “move if you can, but copy if you must” strategy, and it’s not the only function in the Standard Library that does. Other functions sporting the strong exception safety guarantee in C++98 (e.g., std::vec tor::reserve, std::deque::insert, etc.) behave the same way. All these functions replace calls to copy operations in C++98 with calls to move operations in C++11

only if the move operations are known to not emit exceptions. But how can a function know if a move operation won’t produce an exception? The answer is obvious: it checks to see if the operation is declared noexcept.3

swap functions comprise another case where noexcept is particularly desirable. swap is a key component of many STL algorithm implementations, and it’s commonly employed in copy assignment operators, too. Its widespread use renders the optimizations that noexcept affords especially worthwhile. Interestingly, whether swaps in the Standard Library are noexcept is sometimes dependent on whether user-3 The checking is typically rather roundabout. Functions like std::vector::push_back call std::move_if_noexcept, a variation of std::move that conditionally casts to an rvalue (see Item 23), depending on whether the type’s move constructor is noexcept. In turn, std::move_if_noexcept consults std::is_nothrow_move_constructible, and the value of this type trait (see Item 9) is set by compilers,

based on whether the move constructor has a noexcept (or throw()) designation.

**92 \| Item 14**

defined swaps are noexcept. For example, the declarations for the Standard Library’s swaps for arrays and std::pair are:

template \<class T, size_t N\>

void swap(T (&a)\[N\], // see

T (&b)\[N\]) **noexcept(noexcept(swap(\*a, \*b)))**; // below

template \<class T1, class T2\>

struct pair {

…

void swap(pair& p) **noexcept(noexcept(swap(first, p.first)) &&** **noexcept(swap(second, p.second)));**

…

};

These functions are *conditionally noexcept*: whether they are noexcept depends on whether the expressions inside the noexcept clauses are noexcept. Given two arrays of Widget, for example, swapping them is noexcept only if swapping individual elements in the arrays is noexcept, i.e., if swap for Widget is noexcept. The author of Widget’s swap thus determines whether swapping arrays of Widget is noexcept.

That, in turn, determines whether other swaps, such as the one for arrays of arrays of Widget, are noexcept. Similarly, whether swapping two std::pair objects containing Widgets is noexcept depends on whether swap for Widgets is noexcept. The fact that swapping higher-level data structures can generally be noexcept only if swapping their lower-level constituents is noexcept should motivate you to offer noexcept swap functions whenever you can.

By now, I hope you’re excited about the optimization opportunities that noexcept affords. Alas, I must temper your enthusiasm. Optimization is important, but correctness is more important. I noted at the beginning of this Item that noexcept is part of a function’s interface, so you should declare a function noexcept only if you are willing to commit to a noexcept implementation over the long term. If you declare a function noexcept and later regret that decision, your options are bleak.

You can remove noexcept from the function’s declaration (i.e., change its interface), thus running the risk of breaking client code. You can change the implementation such that an exception could escape, yet keep the original (now incorrect) exception specification. If you do that, your program will be terminated if an exception tries to leave the function. Or you can resign yourself to your existing implementation, abandoning whatever kindled your desire to change the implementation in the first place.

None of these options is appealing.

The fact of the matter is that most functions are *exception-neutral*. Such functions throw no exceptions themselves, but functions they call might emit one. When that **Item 14 \| 93**

happens, the exception-neutral function allows the emitted exception to pass through on its way to a handler further up the call chain. Exception-neutral functions are never noexcept, because they may emit such “just passing through” exceptions. Most functions, therefore, quite properly lack the noexcept designation.

Some functions, however, have natural implementations that emit no exceptions, and for a few more—notably the move operations and swap—being noexcept can have such a significant payoff, it’s worth implementing them in a noexcept manner if at all possible.4 When you can honestly say that a function should never emit exceptions, you should definitely declare it noexcept.

Please note that I said some functions have *natural* noexcept implementations.

Twisting a function’s implementation to permit a noexcept declaration is the tail wagging the dog. Is putting the cart before the horse. Is not seeing the forest for the trees. Is…choose your favorite metaphor. If a straightforward function implementation might yield exceptions (e.g., by invoking a function that might throw), the hoops you’ll jump through to hide that from callers (e.g., catching all exceptions and replacing them with status codes or special return values) will not only complicate your function’s implementation, it will typically complicate code at call sites, too. For example, callers may have to check for status codes or special return values. The runtime cost of those complications (e.g., extra branches, larger functions that put more pressure on instruction caches, etc.) could exceed any speedup you’d hope to achieve via noexcept, plus you’d be saddled with source code that’s more difficult to com-prehend and maintain. That’d be poor software engineering.

For some functions, being noexcept is so important, they’re that way by default. In C++98, it was considered bad style to permit the memory deallocation functions (i.e., operator delete and operator delete\[\]) and destructors to emit exceptions, and in C++11, this style rule has been all but upgraded to a language rule. By default, all memory deallocation functions and all destructors—both user-defined and compiler-generated—are implicitly noexcept. There’s thus no need to declare them noexcept.

(Doing so doesn’t hurt anything, it’s just unconventional.) The only time a destructor is not implicitly noexcept is when a data member of the class (including inherited members and those contained inside other data members) is of a type that expressly states that its destructor may emit exceptions (e.g., declares it “noexcept(false)”).

Such destructors are uncommon. There are none in the Standard Library, and if the 4 The interface specifications for move operations on containers in the Standard Library lack noexcept. However, implementers are permitted to strengthen exception specifications for Standard Library functions, and, in practice, it is common for at least some container move operations to be declared noexcept. That practice exemplifies this Item’s advice. Having found that it’s possible to write container move operations such that exceptions aren’t thrown, implementers often declare the operations noexcept, even though the Standard does not require them to do so.

**94 \| Item 14**

destructor for an object being used by the Standard Library (e.g., because it’s in a container or was passed to an algorithm) emits an exception, the behavior of the program is undefined.

It’s worth noting that some library interface designers distinguish functions with *wide contracts* from those with *narrow contracts*. A function with a wide contract has no preconditions. Such a function may be called regardless of the state of the program, and it imposes no constraints on the arguments that callers pass it.5 Functions with wide contracts never exhibit undefined behavior.

Functions without wide contracts have narrow contracts. For such functions, if a precondition is violated, results are undefined.

If you’re writing a function with a wide contract and you know it won’t emit exceptions, following the advice of this Item and declaring it noexcept is easy. For functions with narrow contracts, the situation is trickier. For example, suppose you’re writing a function f taking a std::string parameter, and suppose f’s natural implementation never yields an exception. That suggests that f should be declared noex cept.

Now suppose that f has a precondition: the length of its std::string parameter doesn’t exceed 32 characters. If f were to be called with a std::string whose length is greater than 32, behavior would be undefined, because a precondition violation *by* *definition* results in undefined behavior. f is under no obligation to check this precondition, because functions may assume that their preconditions are satisfied. (Callers are responsible for ensuring that such assumptions are valid.) Even with a precondition, then, declaring f noexcept seems appropriate:

void f(const std::string& s) **noexcept**; // precondition:

// s.length() \<= 32

But suppose that f’s implementer chooses to check for precondition violations.

Checking isn’t required, but it’s also not forbidden, and checking the precondition could be useful, e.g., during system testing. Debugging an exception that’s been thrown is generally easier than trying to track down the cause of undefined behavior.

But how should a precondition violation be reported such that a test harness or a client error handler could detect it? A straightforward approach would be to throw a

“precondition was violated” exception, but if f is declared noexcept, that would be impossible; throwing an exception would lead to program termination. For this rea-5 “Regardless of the state of the program” and “no constraints” doesn’t legitimize programs whose behavior is already undefined. For example, std::vector::size has a wide contract, but that doesn’t require that it behave reasonably if you invoke it on a random chunk of memory that you’ve cast to a std::vector. The result of the cast is undefined, so there are no behavioral guarantees for the program containing the cast.

**Item 14 \| 95**

son, library designers who distinguish wide from narrow contracts generally reserve noexcept for functions with wide contracts.

As a final point, let me elaborate on my earlier observation that compilers typically offer no help in identifying inconsistencies between function implementations and their exception specifications. Consider this code, which is perfectly legal: void setup(); // functions defined elsewhere

void cleanup();

void doWork() **noexcept**

{

setup(); // set up work to be done

… // do the actual work

cleanup(); // perform cleanup actions

}

Here, doWork is declared noexcept, even though it calls the non-noexcept functions setup and cleanup. This seems contradictory, but it could be that setup and cleanup document that they never emit exceptions, even though they’re not declared that way. There could be good reasons for their non-noexcept declarations. For example, they might be part of a library written in C. (Even functions from the C Standard Library that have been moved into the std namespace lack exception specifications, e.g., std::strlen isn’t declared noexcept.) Or they could be part of a C++98 library that decided not to use C++98 exception specifications and hasn’t yet been revised for C++11.

Because there are legitimate reasons for noexcept functions to rely on code lacking the noexcept guarantee, C++ permits such code, and compilers generally don’t issue warnings about it.

**Things to Remember**

• noexcept is part of a function’s interface, and that means that callers may depend on it.

• noexcept functions are more optimizable than non-noexcept functions.

• noexcept is particularly valuable for the move operations, swap, memory deallocation functions, and destructors.

• Most functions are exception-neutral rather than noexcept.

**96 \| Item 14**

**Item 15: Use constexpr whenever possible.**

If there were an award for the most confusing new word in C++11, constexpr would probably win it. When applied to objects, it’s essentially a beefed-up form of const, but when applied to functions, it has a quite different meaning. Cutting through the confusion is worth the trouble, because when constexpr corresponds to what you want to express, you definitely want to use it.

Conceptually, constexpr indicates a value that’s not only constant, it’s known during compilation. The concept is only part of the story, though, because when con stexpr is applied to functions, things are more nuanced than this suggests. Lest I ruin the surprise ending, for now I’ll just say that you can’t assume that the results of constexpr functions are const, nor can you take for granted that their values are known during compilation. Perhaps most intriguingly, these things are *features*. It’s *good* that constexpr functions need not produce results that are const or known during compilation!

But let’s begin with constexpr objects. Such objects are, in fact, const, and they do, in fact, have values that are known at compile time. (Technically, their values are determined during *translation*, and translation consists not just of compilation but also of linking. Unless you write compilers or linkers for C++, however, this has no effect on you, so you can blithely program as if the values of constexpr objects were determined during compilation.)

Values known during compilation are privileged. They may be placed in read-only memory, for example, and, especially for developers of embedded systems, this can be a feature of considerable importance. Of broader applicability is that integral values that are constant and known during compilation can be used in contexts where C++ requires an *integral constant expression*. Such contexts include specification of array sizes, integral template arguments (including lengths of std::array objects), enumerator values, alignment specifiers, and more. If you want to use a variable for these kinds of things, you certainly want to declare it constexpr, because then compilers will ensure that it has a compile-time value:

int sz; // non-constexpr variable

…

constexpr auto arraySize1 = sz; // error! sz's value not

// known at compilation

std::array\<int, sz\> data1; // error! same problem

constexpr auto arraySize2 = 10; // fine, 10 is a

**Item 15 \| 97**

// compile-time constant std::array\<int, arraySize2\> data2; // fine, arraySize2

// is constexpr

Note that const doesn’t offer the same guarantee as constexpr, because const objects need not be initialized with values known during compilation:

int sz; // as before

…

const auto arraySize = sz; // fine, arraySize is

// const copy of sz

std::array\<int, arraySize\> data; // error! arraySize's value

// not known at compilation

Simply put, all constexpr objects are const, but not all const objects are con stexpr. If you want compilers to guarantee that a variable has a value that can be used in contexts requiring compile-time constants, the tool to reach for is con stexpr, not const.

Usage scenarios for constexpr objects become more interesting when constexpr functions are involved. Such functions produce compile-time constants *when they* *are called with compile-time constants*. If they’re called with values not known until runtime, they produce runtime values. This may sound as if you don’t know what they’ll do, but that’s the wrong way to think about it. The right way to view it is this:

• constexpr functions can be used in contexts that demand compile-time constants. If the values of the arguments you pass to a constexpr function in such a context are known during compilation, the result will be computed during compilation. If any of the arguments’ values is not known during compilation, your code will be rejected.

• When a constexpr function is called with one or more values that are not known during compilation, it acts like a normal function, computing its result at runtime. This means you don’t need two functions to perform the same operation, one for compile-time constants and one for all other values. The constexpr function does it all.

Suppose we need a data structure to hold the results of an experiment that can be run in a variety of ways. For example, the lighting level can be high, low, or off during the course of the experiment, as can the fan speed and the temperature, etc. If there are *n* environmental conditions relevant to the experiment, each of which has three possi-98 \| Item 15

ble states, the number of combinations is 3 *n*. Storing experimental results for all combinations of conditions thus requires a data structure with enough room for 3 *n* values.

Assuming each result is an int and that *n* is known (or can be computed) during compilation, a std::array could be a reasonable data structure choice. But we’d need a way to compute 3 *n* during compilation. The C++ Standard Library provides std::pow, which is the mathematical functionality we need, but, for our purposes, there are two problems with it. First, std::pow works on floating-point types, and we need an integral result. Second, std::pow isn’t constexpr (i.e., isn’t guaranteed to return a compile-time result when called with compile-time values), so we can’t use it to specify a std::array’s size.

Fortunately, we can write the pow we need. I’ll show how to do that in a moment, but first let’s look at how it could be declared and used:

**constexpr** // pow's a constexpr func int pow(int base, int exp) noexcept // that never throws

{

… // impl is below

}

constexpr auto numConds = 5; // \# of conditions

std::array\<int, **pow(3, numConds)**\> results; // results has

// 3^numConds

// elements

Recall that the constexpr in front of pow doesn’t say that pow returns a const value, it says that if base and exp are compile-time constants, pow’s result may be used as a compile-time constant. If base and/or exp are not compile-time constants, pow’s result will be computed at runtime. That means that pow can not only be called to do things like compile-time-compute the size of a std::array, it can also be called in runtime contexts such as this:

auto base = readFromDB("base"); // get these values

auto exp = readFromDB("exponent"); // at runtime

auto baseToExp = **pow(base, exp)**; // call pow function

// at runtime

Because constexpr functions must be able to return compile-time results when called with compile-time values, restrictions are imposed on their implementations.

The restrictions differ between C++11 and C++14.

In C++11, constexpr functions may contain no more than a single executable statement: a return. That sounds more limiting than it is, because two tricks can be used **Item 15 \| 99**

to extend the expressiveness of constexpr functions beyond what you might think.

First, the conditional “?:” operator can be used in place of if-else statements, and second, recursion can be used instead of loops. pow can therefore be implemented like this:

constexpr int pow(int base, int exp) noexcept

{

return (exp == 0 ? 1 : base \* pow(base, exp - 1));

}

This works, but it’s hard to imagine that anybody except a hard-core functional programmer would consider it pretty. In C++14, the restrictions on constexpr functions are substantially looser, so the following implementation becomes possible: constexpr int pow(int base, int exp) noexcept // C++14

{

auto result = 1;

for (int i = 0; i \< exp; ++i) result \*= base;

return result;

}

constexpr functions are limited to taking and returning *literal types*, which essentially means types that can have values determined during compilation. In C++11, all built-in types except void qualify, but user-defined types may be literal, too, because constructors and other member functions may be constexpr:

class Point {

public:

**constexpr** Point(double xVal = 0, double yVal = 0) noexcept

: x(xVal), y(yVal)

{}

**constexpr** double xValue() const noexcept { return x; }

**constexpr** double yValue() const noexcept { return y; }

void setX(double newX) noexcept { x = newX; }

void setY(double newY) noexcept { y = newY; }


double x, y;

};

Here, the Point constructor can be declared constexpr, because if the arguments passed to it are known during compilation, the value of the data members of the con-100 \| Item 15

structed Point can also be known during compilation. Points so initialized could thus be constexpr:

**constexpr** Point p1(9.4, 27.7); // fine, "runs" constexpr

// ctor during compilation

**constexpr** Point p2(28.8, 5.3); // also fine

Similarly, the getters xValue and yValue can be constexpr, because if they’re invoked on a Point object with a value known during compilation (e.g., a constexpr Point object), the values of the data members x and y can be known during compilation. That makes it possible to write constexpr functions that call Point’s getters and to initialize constexpr objects with the results of such functions: **constexpr**

Point midpoint(const Point& p1, const Point& p2) noexcept

{

return { (p1. **xValue()** + p2. **xValue()**) / 2, // call constexpr (p1. **yValue()** + p2. **yValue()**) / 2 }; // member funcs

}

**constexpr** auto mid = midpoint(p1, p2); // init constexpr

// object w/result of

// constexpr function

This is very exciting. It means that the object mid, though its initialization involves calls to constructors, getters, and a non-member function, can be created in read-only memory! It means you could use an expression like mid.xValue() \* 10 in an argument to a template or in an expression specifying the value of an enumerator!6 It means that the traditionally fairly strict line between work done during compilation and work done at runtime begins to blur, and some computations traditionally done at runtime can migrate to compile time. The more code taking part in the migration, the faster your software will run. (Compilation may take longer, however.) In C++11, two restrictions prevent Point’s member functions setX and setY from being declared constexpr. First, they modify the object they operate on, and in C++11, constexpr member functions are implicitly const. Second, they have void return types, and void isn’t a literal type in C++11. Both these restrictions are lifted in C++14, so in C++14, even Point’s setters can be constexpr:

6 Because Point::xValue returns double, the type of mid.xValue() \* 10 is also double. Floating-point types can’t be used to instantiate templates or to specify enumerator values, but they can be used as part of larger expressions that yield integral types. For example, static_cast\<int\>(mid.xValue() \* 10) could be used to instantiate a template or to specify an enumerator value.

**Item 15 \| 101**

class Point {

public:

…

**constexpr** void setX(double newX) noexcept // C++14

{ x = newX; }

**constexpr** void setY(double newY) noexcept // C++14

{ y = newY; }

…

};

That makes it possible to write functions like this:

// return reflection of p with respect to the origin (C++14)

constexpr Point reflection(const Point& p) noexcept

{

Point result; // create non-const Point

result. **setX**(-p.xValue()); // set its x and y values

result. **setY**(-p.yValue());

return result; // return copy of it

}

Client code could look like this:

constexpr Point p1(9.4, 27.7); // as above

constexpr Point p2(28.8, 5.3);

constexpr auto mid = midpoint(p1, p2);

constexpr auto reflectedMid = // reflectedMid's value is

reflection(mid); // (-19.1 -16.5) and known

// during compilation

The advice of this Item is to use constexpr whenever possible, and by now I hope it’s clear why: both constexpr objects and constexpr functions can be employed in a wider range of contexts than non-constexpr objects and functions. By using con stexpr whenever possible, you maximize the range of situations in which your objects and functions may be used.

It’s important to note that constexpr is part of an object’s or function’s interface.

constexpr proclaims “I can be used in a context where C++ requires a constant expression.” If you declare an object or function constexpr, clients may use it in **102 \| Item 15**

such contexts. If you later decide that your use of constexpr was a mistake and you remove it, you may cause arbitrarily large amounts of client code to stop compiling.

(The simple act of adding I/O to a function for debugging or performance tuning could lead to such a problem, because I/O statements are generally not permitted in constexpr functions.) Part of “whenever possible” in “Use constexpr whenever possible” is your willingness to make a long-term commitment to the constraints it imposes on the objects and functions you apply it to.

**Things to Remember**

• constexpr objects are const and are initialized with values known during compilation.

• constexpr functions can produce compile-time results when called with arguments whose values are known during compilation.

• constexpr objects and functions may be used in a wider range of contexts than non-constexpr objects and functions.

• constexpr is part of an object’s or function’s interface.

**Item 16: Make const member functions thread safe.**

If we’re working in a mathematical domain, we might find it convenient to have a class representing polynomials. Within this class, it would probably be useful to have a function to compute the root(s) of a polynomial, i.e., values where the polynomial evaluates to zero. Such a function would not modify the polynomial, so it’d be natural to declare it const:

class Polynomial {

public:

using RootsType = // data structure holding values

std::vector\<double\>; // where polynomial evals to zero

… // (see Item 9 for info on "using")

**RootsType roots() const;**

…

};

Computing the roots of a polynomial can be expensive, so we don’t want to do it if we don’t have to. And if we do have to do it, we certainly don’t want to do it more than once. We’ll thus cache the root(s) of the polynomial if we have to compute **Item 15 \| 103**

them, and we’ll implement roots to return the cached value. Here’s the basic approach:

class Polynomial {

public:

using RootsType = std::vector\<double\>;

RootsType roots() const

{

if (!rootsAreValid) { // if cache not valid

… // compute roots,

// store them in rootVals

rootsAreValid = true;

}

return rootVals;

}


mutable bool rootsAreValid{ false }; // see Item 7 for info mutable RootsType rootVals{}; // on initializers

};

Conceptually, roots doesn’t change the Polynomial object on which it operates, but, as part of its caching activity, it may need to modify rootVals and rootsAreValid.

That’s a classic use case for mutable, and that’s why it’s part of the declarations for these data members.

Imagine now that two threads simultaneously call roots on a Polynomial object: Polynomial p;

…

/\*----- Thread 1 ----- \*/ /\*------- Thread 2 ------- \*/

auto rootsOfP = **p.roots()**; auto valsGivingZero = **p.roots()**; This client code is perfectly reasonable. roots is a const member function, and that means it represents a read operation. Having multiple threads perform a read operation without synchronization is safe. At least it’s supposed to be. In this case, it’s not, because inside roots, one or both of these threads might try to modify the data members rootsAreValid and rootVals. That means that this code could have dif-104 \| Item 16

ferent threads reading and writing the same memory without synchronization, and that’s the definition of a data race. This code has undefined behavior.

The problem is that roots is declared const, but it’s not thread safe. The const declaration is as correct in C++11 as it would be in C++98 (retrieving the roots of a polynomial doesn’t change the value of the polynomial), so what requires rectification is the lack of thread safety.

The easiest way to address the issue is the usual one: employ a mutex:

class Polynomial {

public:

using RootsType = std::vector\<double\>;

RootsType roots() const

{

**std::lock_guard\<std::mutex\> g(m);** // *lock mutex*

if (!rootsAreValid) { // if cache not valid

… // compute/store roots

rootsAreValid = true;

}

return rootVals;

} // *unlock mutex*


**mutable std::mutex m;**

mutable bool rootsAreValid{ false };

mutable RootsType rootVals{};

};

The std::mutex m is declared mutable, because locking and unlocking it are non-const member functions, and within roots (a const member function), m would otherwise be considered a const object.

It’s worth noting that because std::mutex is a *move-only type* (i.e., a type that can be moved, but not copied), a side effect of adding m to Polynomial is that Polynomial loses the ability to be copied. It can still be moved, however.

In some situations, a mutex is overkill. For example, if all you’re doing is counting how many times a member function is called, a std::atomic counter (i.e, one where other threads are guaranteed to see its operations occur indivisibly—see Item 40) will

often be a less expensive way to go. (Whether it actually is less expensive depends on **Item 16 \| 105**

the hardware you’re running on and the implementation of mutexes in your Standard Library.) Here’s how you can employ a std::atomic to count calls:

class Point { // 2D point

public:

…

double distanceFromOrigin() const noexcept // see Item 14

{ // for noexcept

**++callCount;** // atomic increment

return std::sqrt((x \* x) + (y \* y));

}


**mutable std::atomic\<unsigned\> callCount{ 0 };**

double x, y;

};

Like std::mutexes, std::atomics are move-only types, so the existence of call Count in Point means that Point is also move-only.

Because operations on std::atomic variables are often less expensive than mutex acquisition and release, you may be tempted to lean on std::atomics more heavily than you should. For example, in a class caching an expensive-to-compute int, you might try to use a pair of std::atomic variables instead of a mutex:


public:

…

int magicValue() const

{

if (cacheValid) return cachedValue;

else {

auto val1 = expensiveComputation1();

auto val2 = expensiveComputation2();

**cachedValue = val1 + val2;** // uh oh, part 1

**cacheValid = true;** // uh oh, part 2

return cachedValue;

}

}


**106 \| Item 16**

mutable **std::atomic\<bool\>** cacheValid{ false }; mutable **std::atomic\<int\>** cachedValue;

};

This will work, but sometimes it will work a lot harder than it should. Consider:

• A thread calls Widget::magicValue, sees cacheValid as false, performs the two expensive computations, and assigns their sum to cachedValue.

• At that point, a second thread calls Widget::magicValue, also sees cacheValid as false, and thus carries out the same expensive computations that the first thread has just finished. (This “second thread” may in fact be *several* other threads.)

Such behavior is contrary to the goal of caching. Reversing the order of the assignments to cachedValue and CacheValid eliminates that problem, but the result is even worse:


public:

…

int magicValue() const

{

if (cacheValid) return cachedValue;

else {

auto val1 = expensiveComputation1();

auto val2 = expensiveComputation2();

**cacheValid = true;** // uh oh, part 1

**return cachedValue = val1 + val2;** // uh oh, part 2

}

}

…

};

Imagine that cacheValid is false, and then:

• One thread calls Widget::magicValue and executes through the point where cacheValid is set to true.

• At that moment, a second thread calls Widget::magicValue and checks cache Valid. Seeing it true, the thread returns cachedValue, even though the first **Item 16 \| 107**

thread has not yet made an assignment to it. The returned value is therefore incorrect.

There’s a lesson here. For a single variable or memory location requiring synchronization, use of a std::atomic is adequate, but once you get to two or more variables or memory locations that require manipulation as a unit, you should reach for a mutex. For Widget::magicValue, that would look like this:


public:

…

int magicValue() const

{

**std::lock_guard\<std::mutex\> guard(m);** // lock m

if (cacheValid) return cachedValue;

else {

auto val1 = expensiveComputation1();

auto val2 = expensiveComputation2();

cachedValue = val1 + val2;

cacheValid = true;

return cachedValue;

}

} // unlock m

…


**mutable std::mutex m;**

mutable int cachedValue; // no longer atomic

mutable bool cacheValid{ false }; // no longer atomic

};

Now, this Item is predicated on the assumption that multiple threads may simultaneously execute a const member function on an object. If you’re writing a const member function where that’s not the case—where you can *guarantee* that there will never be more than one thread executing that member function on an object—the thread safety of the function is immaterial. For example, it’s unimportant whether member functions of classes designed for exclusively single-threaded use are thread safe. In such cases, you can avoid the costs associated with mutexes and std::atomics, as well as the side effect of their rendering the classes containing them move-only. However, such threading-free scenarios are increasingly uncommon, and they’re likely to become rarer still. The safe bet is that const member functions will be subject to con-108 \| Item 16

current execution, and that’s why you should ensure that your const member functions are thread safe.

**Things to Remember**

• Make const member functions thread safe unless you’re *certain* they’ll never be used in a concurrent context.

• Use of std::atomic variables may offer better performance than a mutex, but they’re suited for manipulation of only a single variable or memory location.

**Item 17: Understand special member function**

**generation.**

In official C++ parlance, the *special member functions* are the ones that C++ is willing to generate on its own. C++98 has four such functions: the default constructor, the destructor, the copy constructor, and the copy assignment operator. There’s fine print, of course. These functions are generated only if they’re needed, i.e., if some code uses them without their being expressly declared in the class. A default constructor is generated only if the class declares no constructors at all. (This prevents compilers from creating a default constructor for a class where you’ve specified that constructor arguments are required.) Generated special member functions are implicitly public and inline, and they’re nonvirtual unless the function in question is a destructor in a derived class inheriting from a base class with a virtual destructor.

In that case, the compiler-generated destructor for the derived class is also virtual.

But you already know these things. Yes, yes, ancient history: Mesopotamia, the Shang dynasty, FORTRAN, C++98. But times have changed, and the rules for special member function generation in C++ have changed with them. It’s important to be aware of the new rules, because few things are as central to effective C++ programming as knowing when compilers silently insert member functions into your classes.

As of C++11, the special member functions club has two more inductees: the move constructor and the move assignment operator. Their signatures are:


public:

…

**Widget(Widget&& rhs);** // move constructor

**Widget& operator=(Widget&& rhs);** // move assignment operator

…

};

**Item 16 \| 109**

The rules governing their generation and behavior are analogous to those for their copying siblings. The move operations are generated only if they’re needed, and if they are generated, they perform “memberwise moves” on the non-static data members of the class. That means that the move constructor move-constructs each non-static data member of the class from the corresponding member of its parameter rhs, and the move assignment operator move-assigns each non-static data member from its parameter. The move constructor also move-constructs its base class parts (if there are any), and the move assignment operator move-assigns its base class parts.

Now, when I refer to a move operation move-constructing or move-assigning a data member or base class, there is no guarantee that a move will actually take place.

“Memberwise moves” are, in reality, more like memberwise move *requests*, because types that aren’t *move-enabled* (i.e., that offer no special support for move operations, e.g., most C++98 legacy classes) will be “moved” via their copy operations. The heart of each memberwise “move” is application of std::move to the object to be moved from, and the result is used during function overload resolution to determine

whether a move or a copy should be performed. Item 23 covers this process in detail.

For this Item, simply remember that a memberwise move consists of move operations on data members and base classes that support move operations, but a copy operation for those that don’t.

As is the case with the copy operations, the move operations aren’t generated if you declare them yourself. However, the precise conditions under which they are generated differ a bit from those for the copy operations.

The two copy operations are independent: declaring one doesn’t prevent compilers from generating the other. So if you declare a copy constructor, but no copy assignment operator, then write code that requires copy assignment, compilers will generate the copy assignment operator for you. Similarly, if you declare a copy assignment operator, but no copy constructor, yet your code requires copy construction, compilers will generate the copy constructor for you. That was true in C++98, and it’s still true in C++11.

The two move operations are not independent. If you declare either, that prevents compilers from generating the other. The rationale is that if you declare, say, a move constructor for your class, you’re indicating that there’s something about how move construction should be implemented that’s different from the default memberwise move that compilers would generate. And if there’s something wrong with memberwise move construction, there’d probably be something wrong with memberwise move assignment, too. So declaring a move constructor prevents a move assignment operator from being generated, and declaring a move assignment operator prevents compilers from generating a move constructor.

Furthermore, move operations won’t be generated for any class that explicitly declares a copy operation. The justification is that declaring a copy operation (con-110 \| Item 17

struction or assignment) indicates that the normal approach to copying an object (memberwise copy) isn’t appropriate for the class, and compilers figure that if memberwise copy isn’t appropriate for the copy operations, memberwise move probably isn’t appropriate for the move operations.

This goes in the other direction, too. Declaring a move operation (construction or assignment) in a class causes compilers to disable the copy operations. (The copy operations are disabled by deleting them—see Item 11). After all, if memberwise move isn’t the proper way to move an object, there’s no reason to expect that memberwise copy is the proper way to copy it. This may sound like it could break C++98

code, because the conditions under which the copy operations are enabled are more constrained in C++11 than in C++98, but this is not the case. C++98 code can’t have move operations, because there was no such thing as “moving” objects in C++98. The only way a legacy class can have user-declared move operations is if they were added for C++11, and classes that are modified to take advantage of move semantics have to play by the C++11 rules for special member function generation.

Perhaps you’ve heard of a guideline known as the *Rule of Three*. The Rule of Three states that if you declare any of a copy constructor, copy assignment operator, or destructor, you should declare all three. It grew out of the observation that the need to take over the meaning of a copy operation almost always stemmed from the class performing some kind of resource management, and that almost always implied that (1) whatever resource management was being done in one copy operation probably needed to be done in the other copy operation and (2) the class destructor would also be participating in management of the resource (usually releasing it). The classic resource to be managed was memory, and this is why all Standard Library classes that manage memory (e.g., the STL containers that perform dynamic memory management) all declare “the big three”: both copy operations and a destructor.

A consequence of the Rule of Three is that the presence of a user-declared destructor indicates that simple memberwise copy is unlikely to be appropriate for the copying operations in the class. That, in turn, suggests that if a class declares a destructor, the copy operations probably shouldn’t be automatically generated, because they wouldn’t do the right thing. At the time C++98 was adopted, the significance of this line of reasoning was not fully appreciated, so in C++98, the existence of a user-declared destructor had no impact on compilers’ willingness to generate copy operations. That continues to be the case in C++11, but only because restricting the conditions under which the copy operations are generated would break too much legacy code.

The reasoning behind the Rule of Three remains valid, however, and that, combined with the observation that declaration of a copy operation precludes the implicit generation of the move operations, motivates the fact that C++11 does *not* generate move operations for a class with a user-declared destructor.

**Item 17 \| 111**

So move operations are generated for classes (when needed) only if these three things are true:

• No copy operations are declared in the class.

• No move operations are declared in the class.

• No destructor is declared in the class.

At some point, analogous rules may be extended to the copy operations, because C++11 deprecates the automatic generation of copy operations for classes declaring copy operations or a destructor. This means that if you have code that depends on the generation of copy operations in classes declaring a destructor or one of the copy operations, you should consider upgrading these classes to eliminate the dependence.

Provided the behavior of the compiler-generated functions is correct (i.e, if memberwise copying of the class’s non-static data members is what you want), your job is easy, because C++11’s “= default” lets you say that explicitly:


public:

…

~Widget(); // user-declared dtor

… // default copy ctor

Widget(const Widget&) **= default**; // behavior is OK

Widget& // default copy assign

operator=(const Widget&) **= default**; // behavior is OK

…

};

This approach is often useful in polymorphic base classes, i.e., classes defining interfaces through which derived class objects are manipulated. Polymorphic base classes normally have virtual destructors, because if they don’t, some operations (e.g., the use of delete or typeid on a derived class object through a base class pointer or reference) yield undefined or misleading results. Unless a class inherits a destructor that’s already virtual, the only way to make a destructor virtual is to explicitly declare it that way. Often, the default implementation would be correct, and “= default” is a good way to express that. However, a user-declared destructor suppresses generation of the move operations, so if movability is to be supported, “= default” often finds a second application. Declaring the move operations disables the copy operations, so if copyability is also desired, one more round of “= default” does the job: class Base {

public:

**virtual** ~Base() **= default**; // make dtor virtual **112 \| Item 17**

**Base(Base&&) = default;** // support moving **Base& operator=(Base&&) = default;**

**Base(const Base&) = default;** // support copying **Base& operator=(const Base&) = default;**

…

};

In fact, even if you have a class where compilers are willing to generate the copy and move operations and where the generated functions would behave as you want, you may choose to adopt a policy of declaring them yourself and using “= default” for their definitions. It’s more work, but it makes your intentions clearer, and it can help you sidestep some fairly subtle bugs. For example, suppose you have a class representing a string table, i.e., a data structure that permits fast lookups of string values via an integer ID:

class StringTable {

public:

StringTable() {}

… // functions for insertion, erasure, lookup,

// etc., but no copy/move/dtor functionality


std::map\<int, std::string\> values;

};

Assuming that the class declares no copy operations, no move operations, and no destructor, compilers will automatically generate these functions if they are used.

That’s very convenient.

But suppose that sometime later, it’s decided that logging the default construction and the destruction of such objects would be useful. Adding that functionality is easy: class StringTable {

public:

StringTable()

{ makeLogEntry("Creating StringTable object"); } // added

**~StringTable()** // also

{ makeLogEntry("Destroying StringTable object"); } // added

… // other funcs as before

**Item 17 \| 113**


std::map\<int, std::string\> values; // as before

};

This looks reasonable, but declaring a destructor has a potentially significant side effect: it prevents the move operations from being generated. However, creation of the class’s copy operations is unaffected. The code is therefore likely to compile, run, and pass its functional testing. That includes testing its move functionality, because even though this class is no longer move-enabled, requests to move it will compile and run. Such requests will, as noted earlier in this Item, cause copies to be made.

Which means that code “moving” StringTable objects actually copies them, i.e., copies the underlying std::map\<int, std::string\> objects. And copying a std

::map\<int, std::string\> is likely to be *orders of magnitude* slower than moving it.

The simple act of adding a destructor to the class could thereby have introduced a significant performance problem! Had the copy and move operations been explicitly defined using “= default”, the problem would not have arisen.

Now, having endured my endless blathering about the rules governing the copy and move operations in C++11, you may wonder when I’ll turn my attention to the two other special member functions, the default constructor and the destructor. That time is now, but only for this sentence, because almost nothing has changed for these member functions: the rules in C++11 are nearly the same as in C++98.

The C++11 rules governing the special member functions are thus:

• **Default constructor**: Same rules as C++98. Generated only if the class contains no user-declared constructors.

• **Destructor**: Essentially same rules as C++98; sole difference is that destructors are noexcept by default (see Item 14). As in C++98, virtual only if a base class

destructor is virtual.

• **Copy constructor**: Same runtime behavior as C++98: memberwise copy construction of non-static data members. Generated only if the class lacks a user-declared copy constructor. Deleted if the class declares a move operation.

Generation of this function in a class with a user-declared copy assignment operator or destructor is deprecated.

• **Copy assignment operator**: Same runtime behavior as C++98: memberwise copy assignment of non-static data members. Generated only if the class lacks a user-declared copy assignment operator. Deleted if the class declares a move operation. Generation of this function in a class with a user-declared copy constructor or destructor is deprecated.

**114 \| Item 17**

• **Move constructor** and **move assignment operator**: Each performs memberwise moving of non-static data members. Generated only if the class contains no user-declared copy operations, move operations, or destructor.

Note that there’s nothing in the rules about the existence of a member function *template* preventing compilers from generating the special member functions. That means that if Widget looks like this,


…

**template\<typename T\>** // construct Widget

**Widget(const T& rhs);** // from *anything*

**template\<typename T\>** // assign Widget

**Widget& operator=(const T& rhs);** // from *anything*

…

};

compilers will still generate copy and move operations for Widget (assuming the usual conditions governing their generation are fulfilled), even though these templates could be instantiated to produce the signatures for the copy constructor and copy assignment operator. (That would be the case when T is Widget.) In all likelihood, this will strike you as an edge case barely worth acknowledging, but there’s a

reason I’m mentioning it. Item 26 demonstrates that it can have important conse‐

quences.

**Things to Remember**

• The special member functions are those compilers may generate on their own: default constructor, destructor, copy operations, and move operations.

• Move operations are generated only for classes lacking explicitly declared move operations, copy operations, and a destructor.

• The copy constructor is generated only for classes lacking an explicitly declared copy constructor, and it’s deleted if a move operation is declared.

The copy assignment operator is generated only for classes lacking an explicitly declared copy assignment operator, and it’s deleted if a move operation is declared. Generation of the copy operations in classes with an explicitly declared destructor is deprecated.

• Member function templates never suppress generation of special member functions.

**Item 17 \| 115**

**CHAPTER 4**