**13. Techniques and Use Cases**

Across the book, we’ve touched on many different topics, sometimes only in a theoretical way. In this chapter, however, I grouped many of those features and demonstrated their benefits in several practical use cases.

You’ll learn about the following aspects:

• Strong types and the explicit keyword,

• Initializing string data members,

• Reducing extra copies through emplace or in_place,

• Copy and Swap Idiom as a potential simplification of copy and move operations,

• CRTP,

• Mayers Singleton

• Factory with self registrating types.

Let’s start.



**Using** **explicit** **for strong types**

If you recall the first chapter, I used double to indicate horsepower (hp) inside the CarInfo structure. However, we might quickly encounter a problem where we forget about the unit and treat it as Watts instead. Can we limit such problematic cases?

The answer is positive, and the main idea is to wrap the data member double power in a separate class type with explicit constructors. That it will be harder to misuse it, such an approach is called *Strong Typing*.

Have a look at two similar wrapper types:



208

Techniques and Use Cases 209



**Ex 13.1. Strong types and area units classes. Run** [**@Compiler Explorer**](https://godbolt.org/z/PWvzWr1Eb)

**constexpr double** ToWattsRatio { 745.699872 };

**class HorsePower**;

**class WattPower** {

**public**:

WattPower() = **default**;

**explicit** WattPower(**double** p) : power\_{p} { }

**explicit** WattPower(**const** HorsePower& h);

**double** getValue() **const** { **return** power\_; } **private**:

**double** power\_ {0.};

};

**class HorsePower** {

**public**:

HorsePower() = **default**;

**explicit** HorsePower(**double** p) : power\_{p} { }

**explicit** HorsePower(**const** WattPower& w);

**double** getValue() **const** { **return** power\_; } **private**:

**double** power\_ {0.};

};

As you can see, we have two types that use explicit constructors to initialize their private data members. To create an object, you have to write the correct type name explicitly, and thus it should limit the chance of mistakes.

And here is the implementation of the converting constructors as well as stream operators for easy output:

Techniques and Use Cases 210



**Ex 13.2. Strong Types and area units, implementation. Run** [**@Compiler Explorer**](https://godbolt.org/z/PWvzWr1Eb)

**constexpr double** ToWattsRatio { 745.699872 };

**class HorsePower**;

**class WattPower** { /\* as before \*/ }; **class HorsePower** { /\* as before \*/ };

WattPower::WattPower(**const** HorsePower& h) : power\_{h.getValue()\*ToWattsRatio} { }

HorsePower::HorsePower(**const** WattPower& w) : power\_{w.getValue()/ToWattsRatio} { }

std::ostream& **operator**\<\<(std::ostream& os, **const** WattPower& w) {

os \<\< w.getValue() \<\< "W";

**return** os;

}

std::ostream& **operator**\<\<(std::ostream& os, **const** HorsePower& h) {

os \<\< h.getValue() \<\< "hp";

**return** os;

}

The interface allows us to convert between various units safely.

//HorsePower hp = 10.; // not possible, copy initialization HorsePower hp{ 10. }; // fine

WattPower w { 1. }; // fine

WattPower watts { hp }; // fine, performs the proper conversion for us!

Additionally, we have the output support that writes out the proper unit name.

We can use the solution now:

Techniques and Use Cases 211

**void** printInfo(**const** CarInfo& c) {

std::cout \<\< c.name \<\< ", "

\<\< c.year \<\< " year, " \<\< c.seats \<\< " seats, " \<\< c.power \<\< '\n';

}

**int** main() {

CarInfo firstCar{"Megane", 2003, 5, HorsePower{116}};

printInfo(firstCar);

CarInfo superCar{"Ferrari", 2022, 2, HorsePower{300}};

printInfo(superCar);

superCar.power = HorsePower{WattPower{500000}};

printInfo(superCar);

}

And we’ll get the following output:

Megane, 2003 year, 5 seats, 116hp

Ferrari, 2022 year, 2 seats, 300hp

Ferrari, 2022 year, 2 seats, 670.511hp

While I had to be more explicit and write the types, the code can be safer as it’s harder to type something accidentally.

![](media/index-226_1.png)

In C++11, you can also leverage user-defined literals to allow easier creation of objects. Especially useful for units, string, numerical types, time, and dates. For example, We could create a named literal \_m2 and then write 50.0_m2 to create an

instance rather than SqMeters{50.2}. See more at [C++Reference - User-defined](https://en.cppreference.com/w/cpp/language/user_literal)

[literals](https://en.cppreference.com/w/cpp/language/user_literal)¹.

![](media/index-226_2.png)



For more information about Strong Types, I highly recommend reading many

articles on the Fluent C++ blog. For example, start with this one: [Strong types for](https://www.fluentcpp.com/2016/12/08/strong-types-for-strong-interfaces/)

[strong interfaces - Fluent C++](https://www.fluentcpp.com/2016/12/08/strong-types-for-strong-interfaces/)².



¹<https://en.cppreference.com/w/cpp/language/user_literal>

²<https://www.fluentcpp.com/2016/12/08/strong-types-for-strong-interfaces/>

Techniques and Use Cases 212



**Best way to initialize** **string** **data members**

See the following example:

**class UserName** {

std::string name\_;

**public**:

**explicit** UserName(**const** std::string& str) : name\_(str) { } };

As you can see, a constructor is taking const std::string& str.

Let’s compare those alternative implementations in three cases: creating from a string literal, creating from an lvalue, and creating from an rvalue reference:

// creation from a string literal

UserName u1{"John With Very Long Name"};

// creation from lvalue:

std::string s2 {"Marc With Very Long Name"}; UserName u2 { s2 };

// use s2 later...

// from rvalue reference

std::string s3 {"Marc With Very Long Name"}; UserName u3 { std::move(s3) };

// third case is also similar to taking a return value: std::string GetString() { **return** "some string..."; } UserName u4 { GetString() };

Please note that allocations/creation of s2 and s3 are not taken into account; we’re only looking at what happens for the constructor call. For s2 we can also assume it’s used later in the code.

For const std::string&:

• u1- two allocations: the first one creates a temp string and binds it to the input

parameter, and then there’s a copy into name\_.

Techniques and Use Cases 213



• u2- one allocation: we have a no-cost binding to the reference, and then there’s a copy

into the member variable.

• u3- one allocation: we have a no-cost binding to the reference, and then there’s a copy

into the member variable.

• You’d have to write a ctor taking rvalue reference to skip one allocation for the u1

case, and also, that could skip one copy for the u3 case (since we could move from rvalue reference).

However, since the introduction of move semantics in C++11, it’s usually better and safer to pass string as a value and then move from it.

For example:

**class UserName** {

std::string name\_;

**public**:

**explicit** UserName(std::string str) : name\_(std::move(str)) { } };

Now we have the following results:

For std::string:

• u1- one allocation - for the input argument and then one move into the name\_. It’s

better than with const std::string& where we got two memory allocations in that case.

• u2- one allocation - we have to copy the value into the argument, and then we can

move from it.

• u3- no allocations, only two move operations - that’s better than with const string&!

When you pass std::string by value, not only is the code simpler, but there’s also no need to write separate overloads for rvalue references.

The approach with passing by value is consistent with item 41 - “Consider pass by value for copyable parameters that are cheap to move and always copied” from Effective Modern C++ by Scott Meyers.

However, is std::string cheap to move?

Although the C++ Standard doesn’t specify that, usually, strings are implemented with **Small** **String Optimisation** (**SSO**) - the string object contains extra space to fit characters without Techniques and Use Cases 214



additional memory allocation³. That means that moving a string is the same as copying it. And since the string is short, the copy is also fast.

Let’s reconsider our example of passing by value when the string is short:

UserName u1{"John"}; // fits in SSO buffer

std::string s2 {"Marc"}; // fits in SSO buffer UserName u2 { s2 };

std::string s3 {"Marc"}; // fits in SSO buffer UserName u3 { std::move(s3) };

Remember that each move is the same as a copy in a case of a short string.

For const std::string&:

• u1- two copies: one copy from the input string literal into a temporary string argument,

then another copy into the member variable.

• u2- one copy: the existing string is bound to the reference argument, and then we have

one copy into the member variable.

• u3- one copy: the rvalue reference is bound to the input parameter at no cost; later

we have a copy into the member field.

For std::string:

• u1- two copies: the input argument is created from a string literal, and then there’s a

copy into name\_.

• u2- two copies: one copy into the argument, and then there’s the second copy into the

member.

• u3- two copies: one copy into the argument (move means copy in this particular case),

and then there’s the second copy into the member.

As you see, short strings passing by value might be “slower” when you pass some existing string simply because you have two copies rather than one. On the other hand, the compiler

³SSO is not standardized and prone to change. MSVC (VS 2013 and above)/GCC (8.1 and above) - it’s a buffer of 16 bytes, and

the empty string has a size of 32 bytes. It means a space for 15 characters of the char type, or 7 for wchar_t. In Clang (6.0 and above when compiled with-stdlib=libc++) the buffer might contain space for 22 characters of char but might be only a few characters for wchar_t. The size of an empty string is only 24 bytes. For multiplatform code, it’s not a good idea to assume optimizations based on SSO. Read more at this good article: https://shaharmike.com/cpp/std-string/.

Techniques and Use Cases 215



might optimize the code better when it sees an object and not a reference. Moreover, short strings are cheap to copy, so the potential “slowdown” might not even be visible.

All in all, passing by value and then moving from a string argument is the preferred solution. You have simple code and better performance for larger strings.

As always, if your code needs maximum performance, then you have to measure all possible cases.

![](media/index-230_1.png)

**Other Types & Automation**

The problem discussed in this section can also be extended to other copyable and movable types. If the move operation is cheap, passing by value might be better than by reference. You can also use automation, like Clang-Tidy, which can detect

potential improvements. Clang Tidy has a separate rule for that use case; see [clang-](https://clang.llvm.org/extra/clang-tidy/checks/modernize-pass-by-value.html)

[tidy - modernize-pass-by-value](https://clang.llvm.org/extra/clang-tidy/checks/modernize-pass-by-value.html)⁴.



Here’s the summary of string passing and initialization of a string member:

**Input Parameter** **const string&** **string** **and** **move**

const char\* 2 allocations 1 allocation + move

const char\* SSO 2 copies 2 copies

lvalue 1 allocation 1 allocation + 1 move

lvalue SSO 1 copy 2 copies

rvalue 1 allocation 2 moves

rvalue SSO 1 copy 2 copies

This part covered only the basic approach with string references and string copies. We could also extend this discussion and cover the std::string_view added in C++17. If you want

a complete comparison, see this blog post [How to Initialize a String Member - C++ Stories](https://www.cppstories.com/2018/08/init-string-member/)⁵.



**Reducing extra copies through** **emplace** **and** **in_place**

Since C++11, programmers got a new technique to initialize objects “in place”. This approach avoids unnecessary temporary copies and works with non-movable/non-copyable types.

⁴<https://clang.llvm.org/extra/clang-tidy/checks/modernize-pass-by-value.html>

⁵<https://www.cppstories.com/2018/08/init-string-member/>

Techniques and Use Cases 216



As an example, let’s look at std::optional and std::variant from C++17 and ways to construct those types efficiently.

The first vocabulary type, std::optional, is a wrapper with an extra feature to indicate whether or not the object is present. You can create optional objects almost in the same way as the wrapped object:

**Ex 13.3. Simplified** **std::optional** **example. Run** [**@Compiler Explorer**](https://godbolt.org/z/nKnePen4c) \#include \<iostream\>

\#include \<optional\>

**int** main() {

std::optional\<**double**\> empty;

std::optional\<std::string\> ostr{"Hello World"};

std::optional\<**int**\> oi{10};

// has_value()

**if** (empty.has_value()) std::cout \<\< \*empty \<\< '\n';

**else** std::cout \<\< "empty is empty**\n**";

// operator bool

**if** (ostr) std::cout \<\< \*ostr \<\< '\n';

**else** std::cout \<\< "ostr is empty**\n**";

// value_or()

std::cout \<\< oi.value_or(42) \<\< '\n'; }

As you can see, there’s no need to explicitly state the type of the objects like:

std::optional\<std::string\> ostr{std::string{"Hello World"}}; std::optional\<**int**\> oi{**int**{10}};

This is because std::optional has a constructor that takes U&& (an rvalue reference to a type that converts to the type stored in the optional). In our case, it’s recognized as const char\*, and strings can be initialized from this.

But let’s have a look at two interesting creation techniques with std::in_place_t and emplace():

We have at least two points: default constructor and efficient construction.

Techniques and Use Cases 217



**Default Construction**

If you have a class with a default constructor, like:

**class UserName** {

**public**:

UserName() : mName("Default") { }

// ...

**private**:

std::string mName;

};

How would you create a std::optional object that contains UserName{}?

You can write:

std::optional\<UserName\> u0; // empty optional std::optional\<UserName\> u1{}; // also empty!

// optional with default constructed object: std::optional\<UserName\> u2{UserName{}};

That works, but it creates an additional temporary object. Here’s the output if you run the above code (augmented with some logging):

UserName::UserName('Default')

UserName::UserName(move 'Default') // move temp object UserName::~UserName('') // delete the temp object UserName::~UserName('Default')

The code creates a temporary object and then moves it into the object stored in std::optional.

Here we can use a more efficient constructor - by leveraging std::in_place_t:

std::optional\<UserName\> opt{std::in_place};

Produces the output:

Techniques and Use Cases 218

UserName::UserName('Default')

UserName::~UserName('Default')

The object stored in the optional is created in place, in the same way as you’d call UserName{}. No additional copy or move is needed.

You can play with those examples here [@Compiler Explorer](https://godbolt.org/z/Kb9dP941h)⁶.

**Non-Copyable/Movable Types**

As you saw in the example from the previous section, if you use a temporary object to initialize the contained value inside std::optional then the compiler will have to use the move or copy construction. But what if your type doesn’t allow that? For example, std::mutex is not movable or copyable. In that case, std::in_place is the only way to work with such types.

**Constructors With Many Arguments**

Another use case is a situation where your type has more arguments in a constructor. By default, optional can work with a single argument (rvalue ref), and efficiently pass it to the wrapped type. What if you’d like to initialize std::complex(double, double) or std::vector?

You can always create a temporary copy and then pass it in the construction:

// vector with 4 1's:

std::optional\<std::vector\<**int**\>\> opt{std::vector\<**int**\>{4, 1}}; // complex type:

std::optional\<std::complex\<**double**\>\> opt2{std::complex\<**double**\>{0, 1}};

Or use in_place and the version of the constructor that handles the variable argument list:



⁶<https://godbolt.org/z/Kb9dP941h> Techniques and Use Cases 219

**template**\< **class**... Args \>

**constexpr explicit** optional( std::in_place_t, Args&&... args ); // or initializer_list:

**template**\< **class U**, **class**... Args \> **constexpr explicit** optional( std::in_place_t,

std::initializer_list\<U\> ilist, Args&&... args );

std::optional\<std::vector\<**int**\>\> opt{std::in_place_t, 4, 1}; std::optional\<std::complex\<**double**\>\> opt2{std::in_place_t, 0, 1};

The second option is quite verbose and omits the creation of temporary objects. Temporaries

- especially for containers or larger objects, are less efficient than constructing in place.

**The** **emplace()** **member function**

If you want to change the stored value inside optional, then you can use the assignment operator or call emplace().

Following the concepts introduced in C++11 (emplace methods for containers), you can efficiently create (and destroy the old value if needed) a new object.

**std::make_optional()**

If you don’t like std::in_place, then you can look at the make_optional factory function.

The code

**auto** opt = std::make_optional\<UserName\>(); **auto** opt = std::make_optional\<std::vector\<**int**\>\>(4, 1);

Is as efficient as

std::optional\<UserName\> opt{std::in_place}; std::optional\<std::vector\<**int**\>\> opt{std::in_place_t, 4, 1};

make_optional implement in place construction equivalent to:

Techniques and Use Cases 220

**return** std::optional\<T\>(std::in_place, std::forward\<Args\>(args)...);



**In** **std::variant**

std::variant has two in_place helpers that you can use:

• std::in_place_type- used to specify which type you want to change/set in the

variant

• std::in_place_index- used to specify which index you want to change/set.

Types are numerated from 0. For example In a variant std::variant\<int, float, std::string\>: int has an index 0, float has an index 1, and the string has an index of 2. The index is the same value as returned from the variant::index member function.

Fortunately, you don’t always have to use the helpers to create a variant. It’s smart enough to recognize if it can be constructed from the passed single parameter:

// this constructs the second/float:

std::variant\<**int**, **float**, std::string\> intFloatString { 10.5f };

For std::variant, we need the helpers for at least two cases:

• ambiguity - to distinguish which type should be created where several could match

• efficient complex type creation (similar to optional)

**Note:** by default variant is initialized with the first type - assuming it has a default constructor. If the default constructor is unavailable, you’ll get a compiler error. This is different from std::optional, which is initialized to an empty optional - as mentioned in the previous section.

**Ambiguity**

What if you have initialization like:

std::variant\<**int**, **float**\> intFloat { 10.5 }; // conversion from double?

The value 10.5 could be converted to int or float, so the compiler will report a few pages of template errors… but basically, it cannot deduce what type should double be converted to.

But you can easily handle such an error by specifying which type you’d like to create: Techniques and Use Cases 221

std::variant\<**int**, **float**\> intFloat { std::in_place_index\<0\>, 10.5 }; // or

std::variant\<**int**, **float**\> intFloat { std::in_place_type\<**int**\>, 10.5 };



**Complex Types**

Similarly to std::optional, if you want to create objects that get several constructor arguments efficiently, use std::in_place\*: For example:

// initializer list passed into vector

std::variant\<std::vector\<**int**\>, std::string\> vecStr {

std::in_place_index\<0\>, { 0, 1, 2, 3 } };



**The copy and swap idiom**

The implementation of DataPacket from the second chapter contained two versions of the assignment operator:

DataPacket& **operator**=(**const** DataPacket& other) { } DataPacket& **operator**=(DataPacket&& other) **noexcept** {}

The code inside those functions contains a bit of code duplication, and what’s more, it’s not entirely safe. For example, if we change one data member, but the other change throws an exception, our object will be in an invalid state (partially assigned). To improve, we can try writing a single function:

Techniques and Use Cases 222

DataPacket& **operator**=(DataPacket other) **noexcept** {

**using** std::swap;

swap(data\_, other.data\_);

swap(checkSum\_, other.checkSum\_);

swap(serverId\_, other.serverId\_);

std::cout \<\< "Assignment for **\\"**" \<\< data\_ \<\< "**\\"\n**";

**return** \***this**;

}

The first striking thing to notice is that the operator takes DataPacket by value. Before the operator’s body, a fully initialized DataPacket object must be passed. In other words, the compiler will call a copy or move constructor for that purpose. Later we can use swap to exchange data members. I also wrote using std::swap so that the overload resolution can find all related swap functions, including those from the std namespace. swap cannot throw exceptions (as those functions are usually marked with noexcept) our assignment operator is safe and won’t cause “partially assigned”/invalid objects. Additionally, since we have an object created in the input argument, there’s no need to check against == this. Let’s invoke the new assignment implementation:

DataPacket another { ... };

DataPacket newOne { ... };

another = newOne;

In the above use case, the compiler creates a copy of newOne and passes it as the another argument in the assignment operator.

On the other hand, below, you can see a case where a move constructor will be called to create the other argument before it’s passed to the assignment operator:

DataPacket another { ... };

DataPacket newOne { ... };

another = std::move(newCar);

You can play with this example [@Compiler Explorer](https://godbolt.org/z/esoqY97cx)⁷.

To fully implement the idiom, we could add a DataPacket::swap function that could be reused in the copy and the move constructor. For example:

⁷<https://godbolt.org/z/esoqY97cx> Techniques and Use Cases 223

DataPacket(DataPacket&& other) **noexcept** : DataPacket() { // make sure data is initialized

swap(\***this**, other);

std::cout \<\< "Move ctor for **\\"**" \<\< data\_ \<\< "**\\"\n**"; }

DataPacket& **operator**=(DataPacket other) **noexcept** {

swap(\***this**, other);

std::cout \<\< "Assignment for **\\"**" \<\< data\_ \<\< "**\\"\n**";

**return** \***this**;

}

**friend void** swap(DataPacket& a, DataPacket& b) **noexcept** {

**using** std::swap;

swap(a.data\_, b.data\_);

swap(a.checkSum\_, b.checkSum\_);

swap(a.serverId\_, b.serverId\_);

}

See this alternative version [@Compiler Explorer⁸](https://godbolt.org/z/Me5189Wr8).

The move constructor version only works if the member variables are correctly initialized

when defined (that’s why we have to call a default constructor or use NSDMI described in another chapter). If you use swap with a move constructor and the variables haven’t been initialized, then the swap will swap with indeterminate values!

The idea for the idiom is intensely discussed in this Stack Overflow Question: [c++ - What is](https://stackoverflow.com/questions/3279543/what-is-the-copy-and-swap-idiom)

[the copy-and-swap idiom?](https://stackoverflow.com/questions/3279543/what-is-the-copy-and-swap-idiom)⁹.



**CRTP class counter**

In the chapter about inline variables, there was an example called “Instance Counter”. It looks like a handy type that could be used to count instances of other types separately. For example, we could inherit from it to share the code. Unfortunately, there’s an issue with such a simple approach:



⁸<https://godbolt.org/z/Me5189Wr8>

⁹<https://stackoverflow.com/questions/3279543/what-is-the-copy-and-swap-idiom> Techniques and Use Cases 224



**Ex 13.3. The** **InstanceCounter** **type. Run** [**@Compiler Explorer**](https://godbolt.org/z/vTYsGrPe8)

**class InstanceCounter** {

**static inline size_t** counter\_ { 0 }; **public**:

InstanceCounter() **noexcept** { ++counter\_; }

InstanceCounter(**const** InstanceCounter& ) **noexcept** { ++counter\_; }

InstanceCounter(InstanceCounter&& ) **noexcept** { ++counter\_; }

~InstanceCounter() **noexcept** {--counter\_; }

**static size_t** GetInstanceCounter() { **return** counter\_; } };

**struct Value** : InstanceCounter {

**int** val { 0 };

};

**struct Wrapper** : InstanceCounter {

**double** val { 0.0 };

};

**int** main() {

Value v;

Wrapper w;

std::cout \<\< "Values: " \<\< Value::GetInstanceCounter() \<\< '\n';

std::cout \<\< "Wrappers: " \<\< Wrapper::GetInstanceCounter() \<\< '\n'; }



If you run this code, you’ll see the following output:

Values: 2

Wrappers: 2

The main trouble is that both classes share the single base class, and thus there’s only one “copy” of the counter\_ static data member. We want to count the objects separately and therefore need to have distinct counters. To fix the problem, we can use a technique called *Curiously Recurring Template Pattern* (CRTP).

The core idea is to have a class that derives from a class template using itself as a template parameter.

Techniques and Use Cases 225

**template**\<**class Derived**\>

**class Base** {};

**class X** : **public** Base\<X\> {};

Now, each derived class will have a separate “copy” of the Base class, which opens at least two possibilities:

• Add common functionality to derived classes and improves their interface.

• A way to implement static polymorphism. The base class might implement a member

function that accesses the Derived class and calls the Derived implementation.

We can implement our counter helper in the following way:

**Ex 13.4. The** **InstanceCounter** **CRTP version. Run** [**@Compiler Explorer**](https://godbolt.org/z/Pcs13d17v)

**template** \<**typename Derived**\>

**class InstanceCounter** {

**static inline size_t** counter\_ { 0 }; **public**:

InstanceCounter() **noexcept** { ++counter\_; }

InstanceCounter(**const** InstanceCounter& ) **noexcept** { ++counter\_; }

InstanceCounter(InstanceCounter&& ) **noexcept** { ++counter\_; }

~InstanceCounter() **noexcept** {--counter\_; }

**static size_t** GetInstanceCounter() { **return** counter\_; } };

**struct Value** : InstanceCounter\<Value\> {

**int** val { 0 };

};

**struct Wrapper** : InstanceCounter\<Wrapper\> {

**double** val { 0.0 };

};

**int** main() {

Value v;

Wrapper w;

std::cout \<\< "Values: " \<\< Value::GetInstanceCounter() \<\< '\n';

std::cout \<\< "Wrappers: " \<\< Wrapper::GetInstanceCounter() \<\< '\n'; }

Techniques and Use Cases 226



Now the output is:

Values: 1

Wrappers: 1

As you can see, we created two different template instantiations for InstanceCounter. There’s one for Value and the second for Wrapper. Now the counters are separate and show the expected values.

![](media/index-241_1.png)

Read more about this handy technique in [Curiously Recurring Template Pattern](https://en.cppreference.com/w/cpp/language/crtp)

[@C++Reference¹⁰](https://en.cppreference.com/w/cpp/language/crtp) and also in a three-part series at the Fluent C++ blog: [The](https://www.fluentcpp.com/2017/05/12/curiously-recurring-template-pattern/)

[Curiously Recurring Template Pattern (CRTP), part 1¹¹](https://www.fluentcpp.com/2017/05/12/curiously-recurring-template-pattern/).



**Several initialization types in one class**

As the demo of various initialization techniques, I’d like to show code that creates N random “application windows.”

Here are the core points of the demo:

• A Window class contains basic parameters like name (on the title bar), width, height,

and some flags (bits per pixel, visibility).

• The demo selects a random number X and will try to generate X Window objects.

• Each object will have a random name composed of predefined words and a random

size.

• The application prints each window using std::cout.

• As an additional check, an InstanceCounter class counts the number of Window

objects. We can use this helper to verify the correctness of the demo.

Here’s the first part that defines the Flags object:



¹⁰<https://en.cppreference.com/w/cpp/language/crtp>

¹¹<https://www.fluentcpp.com/2017/05/12/curiously-recurring-template-pattern/>

Techniques and Use Cases 227



**Ex 13.5. The Flags type. Run** [**@Compiler Explorer**](https://godbolt.org/z/a5b335q5M)

**struct Flags** {

**unsigned** bppMode\_ : 4 { 0 }; // bits per pixel

**unsigned** visible\_ : 1 { 1 };

**unsigned** extData : 2 { 0 };

};

Here’s the main class:

**Ex 13.5. The Window type. Run** [**@Compiler Explorer**](https://godbolt.org/z/a5b335q5M)

**class Window** : **public** InstanceCounter\<Window\> {

**static constexpr unsigned** default_width { 1028 };

**static constexpr unsigned** default_height { 768 };

**static constexpr unsigned** default_bpp { 8 };

**unsigned** width\_ { default_width };

**unsigned** height\_ { default_height };

Flags flags\_ {.bppMode\_ { default_bpp } };

std::string title\_ { "Default Window" };

**public**:

Window() = **default**;

**explicit** Window(std::string title) : title\_(std::move(title)) { }

Window(std::string title, **unsigned** w, **unsigned** h) :

width\_(w), height\_(h), title\_(std::move(title)) {}

**friend** std::ostream& **operator**\<\<(std::ostream& os, **const** Window& w) {

os \<\< w.title\_ \<\< ": " \<\< w.width\_ \<\< "x" \<\< w.height\_; **return** os;

}

};

The Window class uses several features discussed in the book:

• NSDMI to initialize data members,

• designated initializers from C++20, combined with NSDMI for the flags\_ data

member, Techniques and Use Cases 228



• Custom constructors that offer several options to initialize the data members,

• We inherit from InstanceCounter, so each constructor invocation for the Window

will also invoke the appropriate constructor in InstanceCounter. Similarly, the InstanceCounter destructor will be nicely called from the implicit default destructor of the Window class.

And now the final demo code:

**Ex 13.5. The Window type. Run** [**@Compiler Explorer**](https://godbolt.org/z/a5b335q5M)

**void** WindowDemo() {

std::random_device rd;

std::mt19937 gen(rd());

std::uniform_int_distribution\<\> distrib(0, 20);

**const int** windowCount = std::uniform_int_distribution\<\>(2, 10)(gen);

std::cout \<\< "Generating " \<\< windowCount \<\< " random Windows**\n**";

**const** std::array adjs { "regular ", "empty ", "blue ", "super " };

**const** std::array nouns { "app", "tool", "console", "game" };

**const** std::array sizes { 1080u, 1920u, 768u, 320u, 640u, 3840u, 800u };

std::vector\<Window\> windows;

**for** (**int** i = 0; i \< windowCount; ++i) {

**auto** r = distrib(gen);

**auto** r2 = distrib(gen);

**auto** name = std::string { adjs\[(r + i) % adjs.size()\] } +

nouns\[r2 % nouns.size()\];

Window w{name, sizes\[r2 % sizes.size()\],

sizes\[r % sizes.size()\]};

windows.push_back(w);

}

**for** (**const auto**& w : windows)

std::cout \<\< w \<\< '\n';

std::cout \<\< "Created " \<\< Window::GetInstanceCounter() \<\< " Windows**\n**"; }

**int** main() {

Techniques and Use Cases 229

WindowDemo();

**if** (Window::GetInstanceCounter() != 0) {

std::cout \<\< Window::GetInstanceCounter()

\<\< " Windows are still alive!**\n**";

}

}

Here’s the possible output:

Generating 8 random Windows

super tool: 320x320

regular tool: 320x640

super game: 1080x768

super game: 640x1080

regular tool: 1920x3840

empty tool: 1920x3840

blue game: 320x768

empty console: 320x320

Created 8 Windows

In WindowDemo, the code declares some basic data and generates a random number. Later, in the main loop, we generate random numbers to pick values from adjs, nouns, and sizes arrays. Once the data is ready, I can create a Window object and place it in the std::vector. To show the creation of the Window object, I used push_back on a vector, but we can optimize it and call emplace_back, which doesn’t need a temporary object:

windows.emplace_back(name, sizes\[r2 % sizes.size()\], sizes\[r % sizes.size()\]);

Later there’s another loop that prints all windows.

![](media/index-244_1.png)

In the code, I didn’t have to specify the full type for std::array\<Type, Count\> as the compiler could deduce everything for me! Thanks to Class Type Argument Deduction (CTAD) and Deduction guides from C++17, the compiler can help us

save some typing. See more [@C++Reference - deduction guides for array¹²](https://en.cppreference.com/w/cpp/container/array/deduction_guides).

¹²<https://en.cppreference.com/w/cpp/container/array/deduction_guides> Techniques and Use Cases 230



The code uses InstanceCounter as a bonus debugging facility to ensure we have the correct number of active objects. When WindowDemo() finishes, all instances should be removed, and we can double-check it inside main().



**Meyer’s Singleton and C++11**

Meyer’s Singleton is a design pattern in C++ that is used to ensure that a class has only one instance and provide a global access point to that instance. The pattern is named after Scott Meyer, who described it in his book “Effective C++: 55 Specific Ways to Improve Your Programs and Designs”.

To implement Meyer’s Singleton in C++, you can define a class that has a private default constructor, a private copy constructor, and a private assignment operator. You can then provide a public static function that returns a reference to the single instance of the class. The first time this function is called, it creates a new instance of the class and returns a reference to it. Subsequent calls to the function return a reference to the same instance.

Here is an example of how to implement Meyer’s Singleton in C++:

**Ex 13.6. Mayer’s singleton. Run** [**@Compiler Explorer**](https://godbolt.org/z/aYdj53dGP) **class Singleton** {

**private**:

Singleton() = **default**;

Singleton(**const** Singleton&) = **delete**;

Singleton& **operator**=(**const** Singleton&) = **delete**;

**public**:

**static** Singleton& getInstance() {

**static** Singleton instance;

**return** instance;

}

**void** foo() { ... }

};

// Usage

Singleton::getInstance().foo();



Meyer’s Singleton is often used as a way to ensure that a class has only one instance and provide a global access point to that instance. In C++11 and later, it is possible to use the Techniques and Use Cases 231



static keyword to declare a local static variable within a function. This allows you to define a local variable that is initialized only once, in a threadsafe way.

![](media/index-246_1.png)

While Meyer’s Singleton is a very efficient way to implement this design pattern, singletons doesn’t have a good opinion in modern programming style. Singleton in fact is a global object, and it leads to few problems like testing, scalability, lack of explicit dependencies and few others. Please be careful when adding this pattern to your code.



**Factory with selfregistering types and static**

**initialization**

Code working here: https://wandbox.org/permlink/iQbNnOUBu0R8Vk8u with constinit !

Let’s have a look at a typical factory function below. It creates ZipCompression or BZCompression based on the extensions of the filename.

**static** unique_ptr\<ICompressionMethod\> Create(**const** string& fileName) {

**auto** extension = GetExtension(filename);

**if** (extension == "zip")

**return** make_unique\<ZipCompression\>();

**else if** (extension = "bz")

**return** make_unique\<BZCompression\>();

**return nullptr**;

}

Here are some issues with this approach:

• Each time you write a new class, and you want to include it in the factory you have to

add another if in the Create() method. Easy to forget in a complex system.

• All the types must be known to the factory

• In Create() we arbitrarily used strings to represent types. Such representation is only

visible in that single method. What if you’d like to use it somewhere else? Strings might be easily misspelt, especially if you have several places where they are compared.

Techniques and Use Cases 232



All in all, we get strong dependency between the factory and the classes.

But what if classes could register themselves? Would that help?

• The factory would just do its job: create new objects based on some matching.

• If you write a new class there’s no need to change parts of the factory class. Such class

would register automatically.

To give you more motivation I’d like to show one real-life example. When you use Google Test library, and you write:

TEST(MyModule, InitTest) {

// impl...

}

Behind this single TEST macro a lot of things happen! For starters your test is expanded into a separate class - so each test is a new class. But then, there’s a problem: you have all the tests, so how the test runner knows about them? It’s the same problem were’ trying to solve in this section. The classes need to be auto-registered.

Have a look at this code: from [googletest/…/gtest-internal.h](https://github.com/google/googletest/blob/ea31cb15f0c2ab9f5f5b18e82311eb522989d747/googletest/include/gtest/internal/gtest-internal.h#L1218)¹³:

// (some parts of the code cut out)

\#define GTEST_TEST\_(test_case_name, test_name, parent_class, parent_id)\\ class GTEST_TEST_CLASS_NAME\_(test_case_name, test_name) \\ : public parent_class { \\

virtual void TestBody();\\

static ::testing::TestInfo\* const test_info\_ GTEST_ATTRIBUTE_UNUSED\_;\\

};\\

\\

::testing::TestInfo\* const GTEST_TEST_CLASS_NAME\_(test_case_name, test_name)\\

::test_info\_ =\\

::testing::internal::MakeAndRegisterTestInfo(\\

\#test_case_name, \#test_name, NULL, NULL, \\

new ::testing::internal::TestFactoryImpl\<\\

GTEST_TEST_CLASS_NAME\_(test_case_name, test_name)\>);\\

void GTEST_TEST_CLASS_NAME\_(test_case_name, test_name)::TestBody()

¹³[https://github.com/google/googletest/blob/ea31cb15f0c2ab9f5f5b18e82311eb522989d747/googletest/include/gtest/internal/](https://github.com/google/googletest/blob/ea31cb15f0c2ab9f5f5b18e82311eb522989d747/googletest/include/gtest/internal/gtest-internal.h#L1218)

[gtest-internal.h#L1218](https://github.com/google/googletest/blob/ea31cb15f0c2ab9f5f5b18e82311eb522989d747/googletest/include/gtest/internal/gtest-internal.h#L1218)

Techniques and Use Cases 233



I cut some parts of the code to make it shorter, but basically GTEST_TEST\_ is used in TEST macro and this will expand to a new class. In the lower section, you might see a name MakeAndRegisterTestInfo. So here’s the place where the class registers!

After the registration, the runner knows all the existing tests and can invoke them.

Here are the steps to implement a similar system:

• Some Interface - we’d like to create classes that are derived from one interface. It’s the

same requirement as a “normal” factory method.

• Factory class that also holds a map of available types

• A proxy that will be used to create a given class. The factory doesn’t know how to

create a given type now, so we have to provide some proxy class to do it.

For the interface we can use ICompressionMethod:

**class ICompressionMethod** {

**public**:

ICompressionMethod() = **default**;

**virtual** ~ICompressionMethod() = **default**;

**virtual void** Compress() = 0;

};

And then the factory:

**class CompressionMethodFactory** {

**public**:

**using** TCreateMethod = unique_ptr\<ICompressionMethod\>(\*)(); **public**:

CompressionMethodFactory() = **delete**;

**static bool** Register(**const** string& name, TCreateMethod funcCreate);

**static** unique_ptr\<ICompressionMethod\> Create(**const** string& name); **private**:

**static** Map\<string, TCreateMethod\> s_methods; };

The factory holds the map of registered types. The main point here is that the factory uses now some method (TCreateMethod) to create the desired type (this is our proxy). The name of a type and that creation method must be initialized in a different place.

The implementation of such factory:

Techniques and Use Cases 234

**class CompressionMethodFactory** {

**public**:

**using** TCreateMethod = unique_ptr\<ICompressionMethod\>(\*)(); **public**:

CompressionMethodFactory() = **delete**;

**static constexpr bool** Register(string_view name,

TCreateMethod createFunc) {

**if** (**auto** val = s_methods.at(name, **nullptr**); val == **nullptr**) {

**if** (s_methods.insert(name, createFunc)) {

std::cout \<\< name \<\< " registered**\n**"; **return** true;

}

}

**return** false;

}

**static** std::unique_ptr\<ICompressionMethod\> Create(string_view name) {

**if** (**auto** val = s_methods.at(name, **nullptr**); val != **nullptr**) {

std::cout \<\< "calling " \<\< name \<\< "**\n**"; **return** val();

}

**return nullptr**;

}

**private**:

**static inline constinit** Map\<string_view, TCreateMethod, 4\> s_methods; };

Now we can implement a derived class from ICompressionMethod that will register in the factory:

Techniques and Use Cases 235

**class ZipCompression** : **public** ICompressionMethod { **public**:

**virtual void** Compress() **override**;

**static** unique_ptr\<ICompressionMethod\> CreateMethod() {

**return** std::make_unique\<ZipCompression\>();

}

**static** string_view GetFactoryName() { **return** "ZIP"; } **private**:

**static inline bool** s_registered =

CompressionMethodFactory::Register(ZipCompression::GetFactoryName(),

CreateMethod);

};

The downside of self-registration is that there’s a bit more work for a class. As you can see we have to have a static CreateMethod defined.

To register such class all we have to do is to define s_registered:

**bool** ZipCompression::s_registered =

CompressionMethodFactory::Register(ZipCompression::GetFactoryName(),

ZipCompression::CreateMethod);

The basic idea for this mechanism is that we rely on static variables. They will be initialized before main() is called.

Because the order of initialization of static variables in difference compilation units is unspecified, we might end up with a different order of elements in the factory container. Each name/type is not dependent on other already registered types in our example, so we’re safe here.

But what about the first insertion? Can we be sure that the Map is created and ready for use?

That’s why I impmeneted a special version of Map which have a constexpr constructor (implicit) and thanks to constinit will be initialized before s_registered is initialized (for some first registered class).

![](media/index-250_1.png)

My current implementation uses std::array which can be used in constant expressions. We could potentially use std::map but it would be at the edge of Undefined Baheviour so it’s not guarateed to work. In final code you can also experiment with std::vector which got constexpr support in C++20. Techniques and Use Cases 236



There’s also one qesiotn we should ask: Can s_registered be eliminated by the compiler?

Fortunately, we’re also on the safe side. From the latest draft of C++: [\[basic.stc.static#2\]¹⁴](https://timsong-cpp.github.io/cppwp/basic.stc.static#2):



If a variable with static storage duration has initialization or a destructor with side effects, it shall not be eliminated even if it appears to be unused, except that a class object or its copy/move may be eliminated as specified in class.copy.elision.



So the compiler won’t optimize those variables.

See the full example:

**Ex 13.7. Factory and Self registering classes demo. Run** [**@Wandbox**](https://wandbox.org/permlink/bO5epDpOhMH8NlXQ)

\#include "ICompressionMethod.h"

\#include "ZipCompression.h"

\#include \<iostream\>

**int** main() {

std::cout \<\< "main starts...**\n**";

**if** (**auto** pMethod = CompressionMethodFactory::Create("ZIP"); pMethod)

pMethod-\>Compress();

**else**

std::cout \<\< "Cannot find ZIP...**\n**";

**if** (**auto** pMethod = CompressionMethodFactory::Create("BZ"); pMethod)

pMethod-\>Compress();

**else**

std::cout \<\< "Cannot find BZ...**\n**";

**if** (**auto** pMethod = CompressionMethodFactory::Create("7Z"); pMethod)

pMethod-\>Compress();

**else**

std::cout \<\< "Cannot find 7Z...**\n**";

}

¹⁴<https://timsong-cpp.github.io/cppwp/basic.stc.static#2>

Techniques and Use Cases 237

![](media/index-252_1.png)

You can find more about this technique, including a topic about static libraries in

two articles at C++ Stories: [Factory With SelfRegistering Types - C++ Stories](https://www.cppstories.com/2018/02/factory-selfregister/)¹⁵

and [Static Variables Initialization in a Static Library, Example - C++ Stories](https://www.cppstories.com/2018/02/static-vars-static-lib/)¹⁶.



**Summary**

It was a fun ride! And I hope you enjoyed the techniques that we discussed in this chapter. We went from passing string types, reducing extra copies through in_place, to Copy And Swap, CRTP, and even selfregistering types. The main goal was not only to experiment with artificial examples, but to show some practical techniques where the knowledge of C++ initialization details is helpful.

¹⁵<https://www.cppstories.com/2018/02/factory-selfregister/>

¹⁶[https://www.cppstories.com/2018/02/staticvars-static-lib/](https://www.cppstories.com/2018/02/static-vars-static-lib/)