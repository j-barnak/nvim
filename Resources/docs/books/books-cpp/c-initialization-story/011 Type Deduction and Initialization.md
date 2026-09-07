**6. Type Deduction and**

**Initialization**

Since C++11, we can write shorter code thanks to automatic type inference with auto or decltype keywords. Rather than specifying the full type for a new object, we can ask the compiler to deduce its type. In this chapter, we’ll discuss how “type deduction” affects initialization. We’ll also learn about the “AAA” rule - Almost Always Auto.



**Deduction with** **auto**

One of the most prominent cases where auto type deduction can help is when you work with iterators or other “verbose” types. Before C++11, you had to specify the exact type of the iterator:

std::map\<std::string, **int**\> mapping { ... }; std::map\<std::string, **int**\>::iterator it = mapping.find("hello");

std::vector\<std::pair\<**int**, **double**\>\> pairs { ... }; std::vector\<std::pair\<**int**, **double**\>\>::const_iterator startIT = pairs.cbegin();

Since C++11, you can ask the compiler to deduce the correct type:

**auto** it = mapping.find("hello");

**auto** startIT = pairs.cbegin();



89

Type Deduction and Initialization 90



Type deduction is also a lifesaver for cases with maps:

**Ex 6.1. Trying a correct type for map elements. Run** [**@Compiler Explorer**](https://godbolt.org/z/Kbf1zzs6T) map\<string, **int**\> m { {"hello", 1}, {"world", 2}};

**for** (**const** pair\<string, **int**\>& elem : m)

cout \<\< elem.first \<\< ", " \<\< &elem.first \<\< '\n';

cout \<\< m.begin()-\>first \<\< ", " \<\< &m.begin()-\>first \<\< '\n'; cout \<\< next(m.begin())-\>first \<\< ", " \<\< &next(m.begin())-\>first \<\< '\n';



Do you see the problem here? If you run the program, you’ll see the following addresses:

hello, 0x7ffe4eb027f0 // loop iteration 1

world, 0x7ffe4eb027f0 // loop iteration 2

hello, 0x15ae2d0

world, 0x15ae320

It looks like we have a mismatch! std::pair\<std::string, int\> is not the correct type when iterating through std::map. The proper type is std::pair\<const std::string, int\>. In other words, the key has to be constant. Since the type differs, the compiler has to create copies for elem(it performs an implicit conversion)! When you replace the loop line with:

**for** (**const auto**& elem : m)

// or the full version...

**for** (**const** std::pair\<**const** std::string, **int**\>& elem : m)

The code compiles and produces exact addresses. For example: hello, 0x1a7a2d0 and hello, 0x1a7a2d0.

In some cases, we don’t even know the type. This happens for lambdas, where the compiler creates some unique, anonymous name:

**auto** fooSquare = \[\](**int** x) { **return** x\*x; }

There’s no way to know the exact type of the above lambda object¹.

Let’s now see the core principles for auto.

¹You can store lambda into wrappers like std::function or convert that into a function pointer (for capture-less lambdas). Type Deduction and Initialization 91



**Rules for** **auto** **type deduction**

We can summarize the rules for auto in the following list of five cases:

**1. If the initializer is a constant expression, the type of the variable is deduced to** **be the type of the expression:**

**auto** num = 42; // num is an int **auto** pi = 3.14; // pi is double

// special cases from string literal and nullptr: **auto** str = "hello world"; // str is const char\* **auto** p = **nullptr**; // p is std::nullptr_t



**2. If the initializer is an expression with a type that is not a reference, the type of** **the variable is deduced to be the type of the expression, with top-level** **cv-qualifiers removed:**

**int** num = 42;

**const int** cnum = num;

**const int**\* pNum = &num;

**const int**\* **const** pCNum = &num;

Using direct initialization:

**auto** a { num }; // a is int **auto** a2 { cnum }; // a2 is int, const removed **auto** a3 { pNum }; // a3 is const int\* **auto** a4 { pCNum }; // a4 is const int\*, const removed

The same deduction happens when you use copy initialization syntax:

Type Deduction and Initialization 92

**auto** b = num; // b is int **auto** b2 = cnum; // b2 is int, const removed **auto** b3 = pNum; // b3 is const int\* **auto** b4 = pCnum; // b4 is const int\*, const removed



**3. If the initializer is an expression with a type that is a reference, the type of the** **variable is deduced to be the type of the referred-to object, with top-level** **cv-qualifiers and references removed:**

**int** num = 42;

**int**& rnum = num;

**const int**& crnum = num;

**auto** c { num }; // c is int

**auto** c2 { rnum }; // c2 is int, ref removed **auto** c3 { crnum }; // c3 is int, const and ref removed **auto** d = num; // d is int

**auto** d2 = rnum; // d2 is int, ref removed **auto** d3 = crnum; // d3 is int, const and ref removed



**4. If the initializer is a braced-init-list, the type of the variable is deduced to be a** **std::initializer_list** **of the appropriate type:**

**auto** list = { 1, 2, 3}; // list is std::initializer_list\<int\> **auto** one = { 1.1 }; // one is std::initializer_list\<double\>

The copy initialization syntax generates the same results as direct initialization, but copy list initialization generates initializer_list\<T\>:

**auto** x { 42 }; // x is int

**auto** y = 42; // y is int

**auto** z = { 42 }; // z is initializer_list\<int\>!



**5. If the initializer is a lambda expression, the type of the variable is deduced to** **be a unique, unnamed function type:**

Type Deduction and Initialization 93

**auto** magic = \[\](){}; // magic has type unique, unnamed function type



**Adding type specifiers**

You can also add a reference, const or a pointer signature to force concrete types::

**int** num = 42;

**auto**& ref = num; // ref is int& **const auto**& cref = num; // cref is const int& **auto**\* pNum = &num; // pNum is int\*

There’s also a special type specifier, auto&& that can bind to lvalues and rvalues and preserves the constness:

std::string hello { "Hello" };

std::string& refHello = hello;

**auto**&& str = hello; // str is string& **auto**&& rstr = refHello; // rstr is string&

**const** std::string world { "World" }; **const** std::string& refWorld = world; **auto**&& w = world; // str is const string& **auto**&& rw = refWorld; // rstr is const string&

The above example shows a basic use of auto&& (also called universal or forwarding

reference²). In the case of str or rstr, the deduced type is a reference to std::string. In a case where the initializer is a constant, the resulting reference will also be const; see w and rw. There’s also an interesting property that auto&& can bind to rvalue references (“temporaries”):



²See more about universal references in this amazing article by Scott Meyers: https://isocpp.org/blog/2012/11/universal—

references-in-c11-scott-meyers.

Type Deduction and Initialization 94

// auto& str2 = std::string { "HI" }; // err! can bind to lvalues only! **const auto**& str3 = std::string { "HI"}; // fine, but const ref //str3\[1\] = 'i'; // err, it's const **auto**&& str4 = std::string { "HI" }; // fine! str3 is string&& str4\[1\] = 'i'; // fine to change

The line with str2 generates a compiler error, while the other two lines are fine. The main difference is that str3 is a constant object. auto&& is more flexible. It’s an essential part of the range-based for loop so that it can work with containers that are constant or not.



**Another view on the deduction**

Conceptually when you write /\*spec\*/ auto x = expr; the compiler uses the same rules as for template type deduction:

**template** \<**typename T**\> x_func(/\*spec\*/ T param) { } x_func(/\*expr\*/);

In an amazing book by Scott Meyers - “Effective Modern C++”, Item 2 - we can read about three following cases:

**1. The type specifier is a pointer or a reference but not a universal reference,**

**int** num = 42;

**const auto**& rx = num;

// same deduction as:

**template** \<**typename T**\> foo_rx(**const** T& num) { }; foo_rx(num);

Above, we can see that the code for deducing type rx involves the same rules as passing num to foo_rx.

Type Deduction and Initialization 95

**2. The type specifier is a universal reference,**

**auto**&& ux = 42;

**template** \<**typename T**\> foo_ux(T&& num) { }; foo_ux(42);



**3. The type specifier is neither a pointer nor a reference.**

**auto** num = 42;

**template** \<**typename T**\> foo_num(T num) { }; foo_num(42);

Let’s meet the second keyword from C++11, decltype.



**Deduction with** **decltype**

The decltype keyword (added in C++11) is used to determine the type of a variable or expression based on its declaration. This means that if you use decltype on a variable, it will return the type of that variable, including any const or reference qualifiers. For example:

**int** x = 10;

**decltype**(x) y = 20; // y is int

**const int** z = 30;

**decltype**(z) w = 40; // w is const int

One key difference between decltype and auto is that decltype will always return the exact type of the variable or expression, while auto will strip away const and reference qualifiers.

Another difference is that decltype can be used on expressions and variables, while auto can only be used on initializers. You can use decltype to determine the type of more complex expressions, such as function calls or template arguments.

In short, if the argument for decltype is not an unparenthesized variable or unparenthesized class member access expression, we have three cases:

1. if the value category of expression is xvalue, then decltype yields T&&, Type Deduction and Initialization 96



2. if the value category of expression is lvalue, then decltype yields T&,

3. if the value category of expression is prvalue, then decltype yields T.

For example:

std::string name { "a funny name" }; // decltype(name) is std::string

// decltype((name)) is std::string&

**struct Object** { **int** x; std::string n; }; **const** Object obj { 0, "" };

// decltype(obj) is const Object

// decltype(obj.x) is int

One handy use case for decltype is declaring a proper return type for a function, based on the type of function’s parameters:

**auto** calcString(**const** Object& obj)-\> **decltype**(obj.parameter()) { ... }

In the above line, decltype is used to get the return type of a member function from the Object class. Note that it’s not possible to use auto in that context.



**Printing type info**

With some extra machinery³, we can run an experiment and show the types of our variables:



³Using GCC’s \_\_PRETTY_FUNCTION\_\_ based on https://stackoverflow.com/questions/281818/unmangling-the-result-of-std—

type-infoname. Solutions based on typeid() might not work, as they don’t convey CV qualifiers as decltype() does. Type Deduction and Initialization 97



**Ex 6.2. Printing type info. Run** [**@Compiler Explorer**](https://godbolt.org/z/YdvoKWMhe)

**template** \<**typename T**\>

**constexpr** std::string_view typeName() {

**constexpr auto** prefix = std::string_view{"with T = "};

**constexpr auto** function = std::string_view{\_\_PRETTY_FUNCTION\_\_};

**const auto** start = function.find(prefix) + prefix.size();

**return** function.substr(start, function.find("; ")-start); }

**template** \<**typename T**, **typename**... Ts\> **void** typeNames(**const char**\*str ) {

std::cout \<\< str \<\< typeName\<T\>();

((std::cout \<\< ", " \<\< typeName\<Ts\>()), ...); // fold expression, C++17 }



The code uses \_\_PRETTY_FUNCTION\_\_ compile-time string. It slices it in predefined places to extract the template parameter typename. Later this function is applied on the variadic pack inside typeNames() and the names are printed via std::cout.

And here’s an example:

**Ex 6.2. Printing type info, use cases. Run** [**@Compiler Explorer**](https://godbolt.org/z/YdvoKWMhe)

**int** main() {

**int** num = 42;

**int**& rnum = num;

**const int**& crnum = num;

**auto** c { num };

**auto** c2 { rnum };

**auto** c3 { crnum };

typeNames\<**decltype**(c), **decltype**(c2), **decltype**(c3)\>("c, c2, c3: ");

**auto** x { 42 }; // x is int

**auto** y = 42; // y is int

**auto** z = { 42 }; // z is initializer_list\<int\>!

typeNames\<**decltype**(x), **decltype**(y), **decltype**(z)\>("**\n**x, y, z: ");

**struct Object** { std::string str; };

Type Deduction and Initialization 98

**const** Object unknown { "unknown" };

**const** Object& refunknown = unknown;

**auto**&& u = unknown;

**auto**&& refu = refunknown;

typeNames\<**decltype**(u), **decltype**(refu)\>("**\n**u and refu: "); }



The output:

c, c2, c3: int, int, int

x, y, z: int, int, std::initializer_list\<int\> u and refu: const main()::Object&, const main()::Object&

The program shows the type names from three groups of auto use cases. By using decltype we can precisely get the types and preserve their constness or reference status.

Thanks to auto we can declare variables and there’s no need to spell their long type names. But in C++17 we also got another cool addition. Let’s meet structured bindings.



**Structured bindings in C++17**

Starting from C++17, you can write:

std::set\<**int**\> mySet;

**auto** \[iter, inserted\] = mySet.insert(10);

insert() returns std::pair indicating if the element was inserted or not, and the iterator to this element. Instead of pair.first and pair.second, you can use variables with concrete

names⁴.

Such syntax is called a *structured binding expression*.



**The Syntax**

The basic syntax for structured bindings is as follows:

⁴you can also assign the result to your variables by using std::tie(); still, this technique is not as convenient as structured

bindings in C++17.

Type Deduction and Initialization 99

**auto** \[a, b, c, ...\] = expression; **auto** \[a, b, c, ...\] { expression }; **auto** \[a, b, c, ...\] ( expression );

The compiler introduces all identifiers from the a, b, c, ... list as names in the surrounding scope and binds them to subobjects or elements of the object denoted by expression.

Behind the scenes, the compiler might generate the following **pseudo code**:

**auto** tempTuple = expression;

**using** a = tempTuple.first;

**using** b = tempTuple.second;

**using** c = tempTuple.third;

Conceptually, the expression is copied into a tuple-like object (tempTuple) with member variables that are exposed through a, b and c. However, the variables a, b, and c are not references; they are aliases (or bindings) to the generated object member variables. The temporary object has a unique name assigned by the compiler.

For example:

std::pair a(0, 1.0f);

**auto** \[x, y\] = a;

x binds to int stored in the generated object that is a copy of a. And similarly, y binds to float.

**Modifiers**

Several modifiers can be used with structured bindings:

const modifiers:

**const auto** \[a, b, c, ...\] = expression;

References:

Type Deduction and Initialization 100

**auto**& \[a, b, c, ...\] = expression; **auto**&& \[a, b, c, ...\] = expression;

For example:

std::pair a(0, 1.0f);

**auto**& \[x, y\] = a;

x = 10; // write access

// a.first is now 10

In the example, x binds to the element in the generated object, which is a reference to a.

Now it’s also relatively easy to get a reference to a tuple member:

**auto**& \[ refA, refB, refC, refD \] = myTuple;

Or better via a const reference:

**const auto**& \[ refA, refB, refC, refD \] = myTuple;

You can also add \[\[attribute\]\] to structured bindings:

\[\[maybe_unused\]\] **auto**& \[a, b, c, ...\] = expression;



**Binding**

Structured Binding is not only limited to tuples; we have three cases from which we can bind from:

**1. If the initializer is an array:**

// works with arrays:

**double** myArray\[3\] = { 1.0, 2.0, 3.0 }; **auto** \[a, b, c\] = myArray;

In this case, an array is copied into a temporary object, and a, b, and c refers to copied elements from the array.

The number of identifiers must match the number of elements in the array.

Type Deduction and Initialization 101

**2. If the initializer supports** **std::tuple_size\<\>****, provides** **get\<N\>()** **and also exposes** **std::tuple_element** **functions:**

std::pair myPair(0, 1.0f);

**auto** \[a, b\] = myPair; // binds myPair.first/second

In the above snippet, we bind to myPair. But this also means you can provide support for your classes, assuming you add the get\<N\> interface implementation. See an example in the later section.

**3. If the initializer’s type contains only non-static data members:**

**struct Point** { **double** x; **double** y; };

Point GetStartPoint() { **return** { 0.0, 0.0 }; }

**const auto** \[x, y\] = GetStartPoint();

x and y refer to Point::x and Point::y from the Point structure.

The class doesn’t have to be POD, but the number of identifiers must equal to the number of non-static data members. The members must also be accessible from the given context.



**Expressive Code With Structured Bindings**

If you have a std::map of elements, you might know that internally, they are stored as pairs of \<const Key, ValueType\>.

Now, when you iterate through elements of that map:

**for** (**const auto**& elem : myMap) { ... }

You need to write elem.first and elem.second to refer to the key and value. One of the **coolest use cases** of structured binding is that we can use it inside a range based for loop:

Type Deduction and Initialization 102

std::map\<KeyType, ValueType\> myMap; // C++14:

**for** (**const auto**& elem : myMap) {

// elem.first - is velu key

// elem.second - is the value

}

// C++17:

**for** (**const auto**& \[key,val\] : myMap) {

// use key/value directly

}

In the above example, we bind to a pair of \[key, val\] so we can use those names in the loop. Before C++17, you had to operate on an iterator from the map - which returns a pair \<first, second\>. Using the real names key/value is more expressive.

The above technique can be used in the following example:

**Ex 6.3. Iterating through maps with structured binding. Run** [**@Compiler Explorer**](https://godbolt.org/z/59EToMazY) \#include \<map\>

\#include \<iostream\>

**int** main() {

**const** std::map\<std::string, **int**\> mapCityPopulation {

{ "Beijing", 21'707'000 }, { "London", 8'787'892 },

{ "New York", 8'622'698 }

};

**for** (**const auto**&\[city, population\] : mapCityPopulation)

std::cout \<\< city \<\< ": " \<\< population \<\< '\n';

}

In the loop body, you can safely use the city and population variables.

![](media/index-117_1.png)

Initially structured bindings had some limitations in C++17. For example you couldn’t declare them static or constexpr or capture in a lambda. Those issues were removed in C++20 and backported to C++17. The main idea is that a “binding” should behave like a regular variable.

Type Deduction and Initialization 103



**Lifetime extension, references, and loops**

You might also spot another Modern C++ feature connected to auto in the example with the iterating over maps. It’s a range-based for loop. The syntax heavily relies on type deduction as it can be used for the type of the element’s value during the iteration and to get proper begin() and end() iterators. In short:

**for** (range-declaration : range-expression) loop-statement

As of C++20, it expands into:

**auto** && \_\_range = range-expression; **auto** \_\_begin = begin-expr;

**auto** \_\_end = end-expr;

**for** ( ; \_\_begin != \_\_end; ++\_\_begin) {

range-declaration = \*\_\_begin;

loop-statement

}

As you can see, range-expression binds to \_\_range, and since it’s an rvalue reference, it can support const and non const ranges. Additionally, since it’s an rvalue reference, it can *extend* the lifetime of temporary objects (so the temporary lives till the reference lives).

We can observe similar behavior for const references:

**void** fooVec(**const** std::vector\<**int**\>& vec) { } **void** fooVecRR(std::vector\<**int**\>&& vec) {

**if** (!vec.empty())

vec\[0\] = 42;

}

fooVec({1, 2, 3});

fooVecRR({1, 2, 3});

This time we can pass a temporary vector, created from the initializer list {1, 2, 3}, directly

to our two functions. See the code [@Compiler Explorerer⁵](https://godbolt.org/z/qEKoMe6aj).

⁵<https://godbolt.org/z/qEKoMe6aj> Type Deduction and Initialization 104



On the other hand, if you try writing: void fooVec(vector\<int\>& vec) { }, then the compiler will report an error about binding a non-const lvalue reference of type vector\<int\>& to an rvalue of type std::vector\<int\>.

Going back to loops, we also have to consider a more complicated case:

**Ex 6.4. Loops and UB in C++20. Run** [**@Compiler Explorer**](https://godbolt.org/z/KW4s83Gh9) **auto** getVec() {

std::vector\<std::vector\<**int**\>\> ints { {1, 2}, {3, 4}, {5, 6} };

**return** ints;

}

**int** main() {

**for** (**auto**& i : getVec()\[1\])

std::cout \<\< i;

}

This code compiles as of C++20, but it’s an Undefined Behaviour! It may crash, print garbage, or even pretend to work fine.

The reason for this situation that we try to bind:

**auto** && \_\_range = getVec()\[1\];

But in the above expression, we have two temporary objects: one big vector from getVec() and then its \[1\] sub “range”. C++20 rules only extend the lifetime of \[1\], and when the expression ends with a semicolon, the big vector ends its lifetime.

To have a better solution, you have to store the “big vector” outside:

**for** (**auto** temp getVec(); **auto**& i : temp\[1\])

std::cout \<\< i;

![](media/index-119_1.png)



This section specifically stressed the C++20 version, as in C++23, a range-based for loop will be much safer with temporary objects! In short, all temporary objects in the range-expression part will extend their lifetime. See those accepted

proposals: [P2644⁶](https://wg21.link/P2644) and [P2012](https://wg21.link/P2012)⁷ for more information.



⁶<https://wg21.link/P2644>

⁷<https://wg21.link/P2012>

Type Deduction and Initialization 105



**Almost Always Auto**

AAA, or Almost Always Auto, is a coding style guideline that recommends the use of the auto keyword for declaring variables in C++. The idea behind this guideline is that using auto can make code easier to read and maintain by reducing the amount of boilerplate type information that needs to be written and maintained.

The core syntax is:

**auto** x = initializer; // including calling a function **auto** y = type{ init }; // forcing a type

For example:

**auto** ptr = std::make_unique\<Object\>(/\*...\*/); **auto** ptrSh = std::make_shared\<Widget\>(/\*...\*/);

std::string computeName(**int** num) { /\* ... \*/ }; **auto** str = computeName(42);

**auto** intro = std::string { "Hello World" }; **auto** elapsed = 42s; // chrono literals, seconds **auto** strElapsed = "42"s; // std::string literal

Ideally you can also put const to indicate that an object won’t change:

**const auto** str = computeName(100); **const auto** factor = **double** { 10.1 }; **const auto** arr = std::to_array({ 0, 2, 1, 3 });

The term was popularlized by Herb Sutter [in GotW-94 post](https://herbsutter.com/2013/08/12/gotw-94-solution-aaa-style-almost-always-auto/)⁸, [GotW 93⁹](https://herbsutter.com/2013/06/13/gotw-93-solution-auto-variables-part-2/) and [GotW 92¹⁰](https://herbsutter.com/2013/06/07/gotw-92-solution-auto-variables-part-1/):



⁸<https://herbsutter.com/2013/08/12/gotw-94-solution-aaa-style-almost-always-auto/>

⁹<https://herbsutter.com/2013/06/13/gotw-93-solution-auto-variables-part-2/>

¹⁰<https://herbsutter.com/2013/06/07/gotw-92-solution-auto-variables-part-1/>

Type Deduction and Initialization 106



**Guideline:** Remember that preferring auto variables is motivated primarily by correctness, performance, maintainability, and robustness—and only lastly about typing convenience.



Here are some of the key benefits of using AAA in C++:

• Improved readability: By using auto, you can reduce the amount of repetitive type

information in your code, making it easier to read and understand.

• Reduced maintenance overhead: With auto, you don’t need to update the type of a

variable when it changes, as the type will be automatically deduced from the initializer. This can save time and reduce the risk of errors.

• Better type safety: The rules for auto type deduction in C++ are designed to ensure that

the types of variables declared with auto are correct and consistent with the initializer. This can help prevent common errors, such as assigning a value of the wrong type to a variable and implicit conversions.

• Ensuring initialization: You cannot leave an auto variable being not initialized.

The term uses “almost”, so here are the cases when you cannot use this syntax:

// when a type conststs of two or more names: **auto** number = **long long** { 100 }; // syntax error!

// non static data member initialization

**struct X** {

**auto** val = **int** { 10 }; // syntax error }

Additionally, before C++17 you could not initialize things like std::mutex:

**auto** m = std::mutex{};

Since mutex is not a moveable type you couldn’t use copy initialization. But this limitation was lifted with C++17’s mandatory copy elision.

While the AAA style has some benefits there’s are some complains:

Type Deduction and Initialization 107



• One potential downside of using automatic style in C++ is that it can make code less

readable, especially for developers who are not familiar with the particular style being used. auto x = 42 might be harder to read than just a simple int x = 42.

• Not all developers might be aware of the rules of automatic type deduction and thus

they might introduce some errors or inefficiencies. For example for (auto x : cont). The code is short, but it will create a copy for each element in a container. The correct form should use auto& x or even auto&& x.

• Similarly assigning auto x = obj.getter_with_reference() might cause an

additionally copy when getter_with_reference returns a reference to some internal data. In that case it’s essential to use auto& x.

• When the return type of some function changes in some radical way: for example from

a value type to a reference, it can introduce some unwanted effects in tha code that only uses auto val = func().



**Summary**

This chapter brought several interesting techniques when defining a new variable. Thanks to auto or decltype, you can ask the compiler to infer the type from the expression or an initializer. This might help when a type has a long or complex name (for example, an iterator) or when the type is unknown (like a type of a closure/lambda object). auto works similarly to template type deduction. Hence, it removes constness or references from types appearing in the initializer. On the other hand, decltype can create an exact type based on other variables and expressions, including their value category. While auto and decltype were added in C++11, in C++17, we got a nice “extension” called structured bindings. Bindings can unpack pairs, tuples, arrays, and simple structures, leading to simpler syntax and more expressive code.

![](media/index-122_1.png)

Since C++17, you can also rely on Class Type Argument Deduction (CTAD). This feature allows you to write std::vector nums { 1, 2, 3} and deduces the proper template parameter for the class template. Still, this topic goes beyond the book and won’t be covered. You can read more in books like “C++ Templates: The

Complete Guide (2nd Edition)” or articles: [Class template argument deduction](https://en.cppreference.com/w/cpp/language/class_template_argument_deduction)

[(CTAD) C++ reference¹¹](https://en.cppreference.com/w/cpp/language/class_template_argument_deduction), [CTAD – What Is This New Acronym All About?](https://accu.org/journals/overload/26/143/orr_2465/)

[@ACCU](https://accu.org/journals/overload/26/143/orr_2465/)¹².

¹¹<https://en.cppreference.com/w/cpp/language/class_template_argument_deduction>

¹²<https://accu.org/journals/overload/26/143/orr_2465/>

Type Deduction and Initialization 108



In one section, we also looked at AAA, which stands for Almost Always Auto - a convention to declare all variables starting with auto. We looked at the benefits of this approach and also some caveats.

At the end of the chapter, I’d like to bring a good quote from the: Google C++ Style guide [on](https://google.github.io/styleguide/cppguide.html#Type_deduction)

[type deduction](https://google.github.io/styleguide/cppguide.html#Type_deduction)¹³:



The fundamental rule is: use type deduction only to make the code clearer or safer, and do not use it merely to avoid the inconvenience of writing an explicit type. When judging whether the code is clearer, keep in mind that your readers are not necessarily on your team, or familiar with your project, so types that you and your reviewer experience as unnecessary clutter will very often provide useful information to others. For example, you can assume that the return type of make_unique\<Foo\>() is obvious, but the return type of MyWidgetFactory() probably isn’t.



¹³<https://google.github.io/styleguide/cppguide.html#Type_deduction>