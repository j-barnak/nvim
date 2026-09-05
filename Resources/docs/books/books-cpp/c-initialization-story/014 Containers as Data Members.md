**9. Containers as Data Members**

CarInfo, DataPacket, and Product types used relatively simple data members like integers, doubles, or strings. While std::string is, in fact, a container (of characters), we tend to use it as an elementary type. In this section, I’d like to discuss more complex data members like arrays, vectors, or maps. First, we’ll try to understand the syntax and ways of initializing them, and then you’ll learn about std::initializer_list.

 

**The basics**

If you have a simple structure with various containers, here are some basic ways you can initialize them in a default constructor:

**Ex 9.1. The basic syntax for containers as data members. Run** [**@Compiler Explorer**](https://godbolt.org/z/e991j5oja)

\#include \<array\>


\#include \<map\>

\#include \<string\>

\#include \<vector\>

**struct S** {

S()

: numbers { 1, 2, 3, 4}

//, nums { 1, 2, 3}

, doubles { 0.1, 1.1, 2.1 }

, ints { 100, 101, 102}

, moreInts( 10, 1) // 10 1's, not 10 and 1

, names ( 10, "hello" ) // 10 "hello" strings

, mapping { {"one", 1}, {"two", 2} }

{ }

**int** numbers\[4\];

// int nums\[\]; // need to provide the size!

std::array\<**double**, 3\> doubles;

132

Containers as Data Members 133

std::vector\<**int**\> ints;

std::vector\<**int**\> moreInts;

std::vector\<std::string\> names;

std::map\<std::string, **int**\> mapping; };

**int** main() {

S s;

std::cout \<\< "s.numbers\[0\]: " \<\< s.numbers\[0\] \<\< '\n';

std::cout \<\< "s.double\[0\]: " \<\< s.doubles\[0\] \<\< '\n';

std::cout \<\< "s.ints\[0\]: " \<\< s.ints\[0\] \<\< '\n';

std::cout \<\< "s.moreInts\[9\]: " \<\< s.moreInts\[9\] \<\< '\n';

std::cout \<\< "s.names\[9\]: " \<\< s.names\[9\] \<\< '\n';

std::cout \<\< "s.mapping\[**\\**one**\\**\]: " \<\< s.mapping\["one"\] \<\< '\n'; }

 

Here are the options from the example:

• int numbers\[4\];- is a regular C-style array; we can use aggregate initialization to

put the values.

• The syntax with //, nums { 1, 2, 3} is not an option, as we cannot declare an array

without the size and then initialize it later.

• doubles is std::array\<double, 3\> which is a C++11-style array, it’s also an

aggregate type.

• ints is a std::vector of integers, and we can use list initialization to set elements.

Note that there’s no need to pass the size/count of those elements.

• moreInts is another vector, but this time I used parens () to call the vector(size\_-

type count, const T& value = T()) constructor. In this case, braces {} would call the wrong constructor and create a vector with two elements 1 and 10. It’s because the value type stored in the container is convertible to the size type (size_t). Additionally,

according to core guidelines [ES.23¹](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es23-prefer-the--initializer-syntax), for constructors with sizes, it’s clearer to use parens.

• names is a vector of std::string, and I also used parens () to call the “size”

constructor. This time, the braces {} would also call the “size” constructor as it would be clear to the compiler that {10, "hello"} is not a pair of two elements of the same type.

¹<https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es23-prefer-the--initializer-syntax> Containers as Data Members 134

 

• mapping is std::map, and we can also use a handy constructor to pass all pairs of key

values at once.

A huge benefit of using standard containers (as regular data members, not pointers) is that there’s no need to implement additional special member functions. Copy, move, or the assignment operator works out of the box. Not to mention that there’s no need for a custom destructor.

From previous chapters, you know that for default initialization, we can also rely on NSDMI and set the values the moment we declare a data member:

**Ex 9.2. Containers as data members and NSDMI. Run** [**@Compiler Explorer**](https://godbolt.org/z/e3njeP9o9) \#include \<array\>


\#include \<map\>

\#include \<string\>

\#include \<vector\>

**struct S** {

**int** numbers\[4\] { 1, 2, 3, 4};

// int nums\[\] { 0, 1, 2 }; // need to provide the size!

std::array\<**double**, 3\> doubles { 0.1, 1.1, 2.1 };

std::vector\<**int**\> ints { 100, 101, 102};

std::vector\<**int**\> moreInts = std::vector\<**int**\>(10, 1);

std::vector\<std::string\> names = std::vector\<std::string\>(10, "hello");

std::map\<std::string, **int**\> mapping { {"one", 1}, {"two", 2} }; };

**int** main() {

S s;

std::cout \<\< "s.numbers\[0\]: " \<\< s.numbers\[0\] \<\< '\n';

std::cout \<\< "s.double\[0\]: " \<\< s.doubles\[0\] \<\< '\n';

std::cout \<\< "s.ints\[0\]: " \<\< s.ints\[0\] \<\< '\n';

std::cout \<\< "s.moreInts\[9\]: " \<\< s.moreInts\[9\] \<\< '\n';

std::cout \<\< "s.names\[9\]: " \<\< s.names\[9\] \<\< '\n';

std::cout \<\< "s.mapping\[**\\**one**\\**\]: " \<\< s.mapping\["one"\] \<\< '\n'; }

 

In most cases, the NSDMI syntax is convenient and allows us to initialize all container-like members where we declare them. As we discussed in the section on NSDMI and direct

Containers as Data Members 135

 

initialization, we have to use, for example, a copy initialization to call the vector’s constructor using parens (). There’s no need to duplicate the code in a constructor, and the S structure can preserve its aggregate status (thus, we can leverage aggregate initialization).

Since C++11, all standard containers can take a list of values into a constructor. For example, before C++11, for std::vector, you’d had to use push_back calls to populate a container with different values. How does the new Standard achieve this? See in the next section.

 

**Using** **std::initializer** **list**

With the idea of list initialization, there also came support to pass such a list not only to aggregate types. Since C++11, you can use std::initializer_list\<T\>, a lightweight proxy object that provides access to an array of objects of type const T.

The Standard shows the following example [decl.init.list](https://timsong-cpp.github.io/cppwp/n4868/dcl.init.list#5)²:

 

**struct** **X** {

X(std::initializer_list\<**double**\> v);

};

X x{ 1,2,3 };

The initialization will be implemented in a way roughly equivalent to this:

**const** **double** \_\_a\[3\] = {**double**{1}, **double**{2}, **double**{3}}; X x(std::initializer_list\<**double**\>(\_\_a, \_\_a+3));

 

In other words, the compiler creates a const array and then passes you a proxy object that looks like a regular C++ container with iterators, begin(), end(), and even the size() function. Here’s a basic example that illustrates the usage of this type:

 

²<https://timsong-cpp.github.io/cppwp/n4868/dcl.init.list#5>

Containers as Data Members 136

 

**Ex 9.3. A function taking** **initializer_list****. Run** [**@Compiler Explorer**](https://godbolt.org/z/h4fY3KanK)


\#include \<initializer_list\>

**void** foo(std::initializer_list\<**int**\> list) {

**if** (!std::empty(list)) {

**for** (**auto**& x : list)

std::cout \<\< x \<\< ", ";

std::cout \<\< "(" \<\< list.size() \<\< " elements)**\n**";

}

**else**

std::cout \<\< "empty list**\n**";

}

**int** main() {

foo({});

foo({1, 2, 3});

foo({1, 2, 3, 4, 5});

}

In the example, there’s a function taking a std::initializer_list of integers. Since it looks like a regular container, we can use non-member functions like std::empty, use it in a range-based for loop, and check its size(). Please notice that there’s no need to pass const initializer_list\<int\>& (a const reference) as the initializer list is a lightweight object, so passing by value doesn’t copy the referenced elements in the “hidden” array.

Note that we cannot do the same with std::array as the parameter to a function would have to have a fixed size. initializer_list has a variable length; the compiler takes care of that. Moreover, the “internal” array is created on the stack, so it doesn’t require any additional memory allocation (like if you used std::vector). The list also takes homogenous values, and the initialization disallows narrowing conversions. For example:

// foo({1, 2, 3, 4, 5.5}); // error, narrowing foo({1, 'x', '0', 10}); // fine, char converted to int

There’s also a handy use case where you can use range-based for loop directly with the initializer_list:

Containers as Data Members 137


**int** main() {

**for** (**auto** x : {"hello", "coding", "world"})

std::cout \<\< x \<\< ", ";

}

The temporary initializer_list has an extended lifetime and is visible in the scope of

the loop. To see the underlying mechanism for this code, you can look at this [C++ Insights](https://cppinsights.io/s/67363d91)

[example](https://cppinsights.io/s/67363d91)³.

I also have to point out that since initializer_list refers to some internal local array, then you should not return it:

std::initializer_list\<**int**\> wrong() { // for illustration only!

**return** { 1, 2, 3, 4};

}

**int** main() {

std::initializer_list\<**int**\> x = wrong(); }

The above code is equivalent to the following:

std::initializer_list\<**int**\> wrong() {

**const int** arr\[\] { 1, 2, 3, 4}

**return** std::initializer_list\<**int**\>{arr, arr+4}; }

**int** main() {

std::initializer_list\<**int**\> x = wrong(); }

The example only illustrates this mistake, so you know how this type works. The function returns pointers/iterators to a local object, and that will cause undefined behavior. The

compiler should warn about such usage. See a demo [@Compiler Explorer⁴](https://godbolt.org/z/bonveWf4a).

³<https://cppinsights.io/s/67363d91>

⁴<https://godbolt.org/z/bonveWf4a> Containers as Data Members 138

 

All in all, we can make the following conclusion:

![](/tmp/audit/iter1/epubregen/c-initialization-story/media/index-153_1.png)

std::initializer_list is a “view” type; it references some implementation—dependent and a local array of const values. Use it mainly for passing into functions when you need a variable number of arguments of the same type. If you try to return such lists and pass them around, then you risk lifetime issues. Use with care.

 

**Constructors taking** **std::initializer_list**

As mentioned, all containers from the Standard Library have constructors supporting initializer_list. For instance:

// the vector class:

**constexpr** vector( std::initializer_list\<T\> init,

**const** Allocator& alloc = Allocator() );

// map:

map( std::initializer_list\<value_type\> init,

**const** Compare& comp = Compare(), **const** Allocator& alloc = Allocator() );

How does it work? Let’s see the basic class type with a user-declared constructor taking the list:

**Ex 9.4. Test constructor with** **initializer_list****. Run** [**@Compiler Explorer**](https://godbolt.org/z/h1W88Pebq)


\#include \<initializer_list\>

**struct X** {

X(std::initializer_list\<**int**\> list)

: count{list.size()} { puts("X(init_list)"); }

X(**size_t** cnt) : count{cnt} { puts("X(cnt)"); }

X() { puts("X()"); }

**size_t** count {};

};

**int** main() {

Containers as Data Members 139

X x;

std::cout \<\< "x.count = " \<\< x.count \<\< '\n';

X y { 1 };

std::cout \<\< "y.count = " \<\< y.count \<\< '\n';

X z { 1, 2, 3, 4 };

std::cout \<\< "z.count = " \<\< z.count \<\< '\n';

X w ( 3 );

std::cout \<\< "w.count = " \<\< w.count \<\< '\n'; }

 

The X class defines three constructors, and one of them takes initializer_list. If we run the program, you’ll see the following output:

X()

x.count = 0

X(init_list)

y.count = 1

X(init_list)

z.count = 4

X(cnt)

w.count = 3

As you can see, writing X x; invokes a default constructor. Similarly, if you write X x{};, the compiler won’t call a constructor with the empty initializer list. But in other cases, the list constructor is “greedy” and will take precedence over the regular constructor taking one argument. To call the exact constructor, you need to use direct initialization with parens ().

 

**Example implementation**

Let’s go further with containers and have some more realistic examples. I want to show you the Package class that holds several Product objects. As an additional complexity, inside this Package class, let’s count the total value of the package, as well as count products by name. Here’s the Product class (similar to our previous declarations):

Containers as Data Members 140

**struct Product** {

Product() = **default**;

Product(std::string s, **double** v)

: name{std::move(s)}, value{v}

{ }

std::string name;

**double** value{};

};

And the Package class:

**class Package** {

**public**:

**void** addProduct(**const** Product& p) {

++counts\_\[p.name\];

prods\_.push_back(p);

totalValue\_ += p.value;

}

**void** printContents() **const** {

**for** (**auto**& \[key, val\] : counts\_)

std::cout \<\< key \<\< ", count: " \<\< val\<\< '\n';

std::cout \<\< "total value: " \<\< totalValue\_ \<\< '\n';

}

**private**:

std::vector\<Product\> prods\_; // all products

std::map\<std::string, **unsigned**\> counts\_;

**double** totalValue\_ { };

};

The Package class holds all objects that we pass through the AddProduct() member function and also performs some internal changes: it counts the total sum of values and also adds the product to the counts\_ dictionary. We can run this code with the following client code:

Containers as Data Members 141

 

**Ex 9.5. The Package class demo. Run** [**@Compiler Explorer**](https://godbolt.org/z/djKhxc731)


\#include \<string\>

\#include \<vector\>

\#include \<map\>

**struct Product** { /\*as before\*/ }; **class Package** { /\*as above\*/ };

**int** main() {

Package pack;

pack.addProduct({"crayons", 3.0});

pack.addProduct({"pen", 2.0});

pack.addProduct({"bricks", 11.0});

pack.addProduct({"bricks", 12.0});

pack.addProduct({"pen", 12.0});

pack.addProduct({"pencil", 12.0});

pack.printContents();

}

And not surprisingly, we’ll get the following output:

bricks, count: 2

crayons, count: 1

pen, count: 2

pencil, count: 1

total value: 52

While the code looks correct, this approach has at least one inconvenience. The client must use addProduct several times to populate the internal containers. This can be improved by creating a constructor (as well as some function overloads) that would take whole containers:

Containers as Data Members 142

Package(**const** std::vector\<Product\>& items) {

**for** (**const auto**& elem : items)

addProduct(elem);

}

Having a function taking more elements at once might be handy if you process a bulk of data. For example, loading products from a file or getting a network packet.

On the other hand, for unit tests or test code, you might want to initialize your objects with a list of objects. In the case of taking std::vector you have to write.

Package pack {

std::vector\<Product\>{{"pen", 1.0}, {"pencil", 2.0}} };

Notice the additional pair of braces. The first pair opens a call to a constructor, and the next creates a temporary vector which is later passed to the constructor. On the other hand, you can also use std::initializer_list and get a simpler syntax:

**Ex 9.6. The Package class with** **initializer_list****. Run** [**@Compiler Explorer**](https://godbolt.org/z/fG1oejKq8)

**struct Product** { /\*as before\*/ };

**class Package** {

**public**:

Package() = **default**;

Package(std::initializer_list\<Product\> items) {

**for** (**auto**& elem : items)

addProduct(elem);

}

**void** addProduct(**const** Product& p) {

++counts\_\[p.name\];

prods\_.push_back(p);

totalValue\_ += p.value;

}

**void** printContents() **const** {

**for** (**auto**& \[key, val\] : counts\_)

std::cout \<\< key \<\< ", count: " \<\< val\<\< '\n';

std::cout \<\< "total value: " \<\< totalValue\_ \<\< '\n'; Containers as Data Members 143

}

**private**:

std::vector\<Product\> prods\_; // all products

std::map\<std::string, **unsigned**\> counts\_;

**double** totalValue\_ { };

};

**int** main() {

Package pack {

{"pen", 1.0}, {"pencil", 2.0}

};

pack.addProduct({"crayons", 3.0});

pack.addProduct({"pen", 2.0});

pack.addProduct({"bricks", 11.0});

pack.addProduct({"bricks", 12.0});

pack.printContents();

}

In the example above, there are two constructors: one default and another with std::initializer_list. I had to specify a default constructor, so it’s possible to create Package emptyPackage;, as initializer_list doesn’t allow us to pass empty lists {} or use default initialization.

What’s an advantage over passing std::vector? Apart from nested braces, std::vector requires a dynamic allocation for a memory block to store its elements. For std::initializer_list the compiler deduces the size and creates a C-style array underneath for elements, so there’s no extra allocation here.

We’re also not limited to only constructors, as we can use initializer_list in regular functions:

Containers as Data Members 144

Package(std::initializer_list\<Product\> items) {

addProducts(items);

}

**void** addProduct(**const** Product& p) { /\* as before \*/ }

**void** addProducts(std::initializer_list\<Product\> items) {

**for** (**auto**& elem : items)

addProduct(elem);

}

The example above shows just a part of implementing the Package class. I created a new member function, addProducts, which takes initializer_list and calls addProduct to perform the main job. The constructor is also updated to call the new function and doesn’t duplicate code.

 

**The cost of copying elements**

Passing elements through std::initializer_list is very convenient, but it’s good to know that when you pass it to a std::vector’s constructor (or other standard containers), each element has to be copied. It’s because, conceptually, objects in the initializer_list are put into a const temporary array, so they have to be copied to the container. See the following example which compares push_back with emplace_back and initializer_list:

**Ex 9.7. Extra copy in** **initializer_list****. Run** [**@Compiler Explorer**](https://godbolt.org/z/fnzv61rnr)

**struct Value** {

Value(**int** x) : v(x) { std::cout \<\< "Value(" \<\< v \<\< ")**\n**"; }

Value(**const** Value& rhs) : v{rhs.v} {std::cout \<\< "copy Value(" \<\< v \<\< ")**\\** n"; }

Value(Value&& rhs) : v{rhs.v} {std::cout \<\< "move Value(" \<\< v \<\< ")**\n**"; }

~Value() **noexcept** { std::cout \<\< "~Value(" \<\< v \<\< ")**\n**"; }

**int** v {0};

};

**int** main() {

std::vector\<Value\> vals { 1, 2, };

Containers as Data Members 145

std::vector\<Value\> moreVals;

moreVals.reserve(4);

std::cout \<\< "with emplace... **\n**";

moreVals.emplace_back(3);

moreVals.emplace_back(4);

std::cout \<\< "with push... **\n**";

moreVals.push_back(5);

moreVals.push_back(6);

}

If we run the program, we’ll get the following output:

Value(1)

Value(2)

copy Value(1)

copy Value(2)

~Value(2)

~Value(1)

with emplace...

Value(3)

Value(4)

with push...

Value(5)

move Value(5)

~Value(5)

Value(6)

move Value(6)

~Value(6)

... other destructors ...

As you can see, in the case of initializer_list, we have two constructors called and then two copy constructors. Then two destructors for those temporary objects are called. In the case of emplace_back(), the compiler creates objects “in place”, so there’s no need to copy or even move objects around. In the case of push_back(), the temporary object is created, which can then be “moved” to the final destination.

Similarly, when you initialize std::vector of std::string with initializer_list, you will get extra copies:

Containers as Data Members 146

std::vector\<std::string\> words { "Hello", "World" };

In the above case, two temporary string objects are created from string literals and then copied into the container.

 

**Some inconvenience - non-copyable types**

In the previous section, we spoke about extra copy that we’d get with the initializer_list, which also causes issues when your objects are not copyable. For example, when you want to create a vector of unique_ptr.

**Ex 9.8. Trying to pass** **unique_ptr****. Run** [**@Compiler Explorer**](https://godbolt.org/z/xPoxxr1ba)

\#include \<vector\>

\#include \<memory\>

**struct Shape** { **virtual void** render() **const** ; }; **struct Circle** : Shape { **void** render() **const override**; }; **struct Rectangle** : Shape { **void** render() **const override**; };

**int** main() {

std::vector\<std::unique_ptr\<Shape\>\> shapes {

std::make_unique\<Circle\>(), std::make_unique\<Rectangle\>()

};

}

The line where I want to create a vector fails to compile, and we get many messages about copying issues. The unique pointers cannot be copied, they can only be moved, and passing initializer_list doesn’t give us any options to handle those cases. The only way to build such a container is to use emplace_back or push_back:

std::vector\<std::unique_ptr\<Shape\>\> shapes; shapes.reserve(2);

shapes.push_back(std::make_unique\<Circle\>()); // or shapes.emplace_back(std::make_unique\<Rectangle\>());

See the working code at [Compiler Explorer](https://godbolt.org/z/E7h4vzYP4)⁵

⁵<https://godbolt.org/z/E7h4vzYP4>

Containers as Data Members 147

 

**More options (advanced)**

Is std::initializer_list the best way to pass a list of homogenous values? It has some uses and might be good enough for classes that look like containers, and you want to provide a handy way of passing a list of values at once. But, we can also leverage some template techniques and use variadic function templates.

**Ex 9.9. Variadic function template. Run** [**@Compiler Explorer**](https://godbolt.org/z/svrnaW5re)

**template**\<**typename**... Ts\>

**requires** (std::same_as\<Ts, Product\> && ...) **void** addProducts(**const** Product & first, **const** Ts&... args) {

addProduct(first);

(addProduct(args), ...);

}

pack.addProducts({"pencil", 12.0}, Product{"pen", 10}); //pack.addProducts({"pencil", 12.0}, 10); // error, 10 is not a Product

 

I don’t want to go into full details, as it’s outside the scope of the book, but here are the core features that enable such code:

• Variadic templates allow us to pass any number of arguments into a function and

process it with argument pack syntax.

• Concepts from C++20 add a way to require all input types to be Product. For example,

in the last line, I tried to pass 10 as the second argument to the function, and the compiler generated an error that the integer 10 didn’t match the concept requirements.

• (addProduct(args), ...); is a fold expression over a comma operator that nicely

expands the argument pack at compile time. Fold expressions have been available since C++17.

• The code might also be updated with rvalue references (forming a universal reference)

which would be forwarded to the internal function.

We can similarly write a function for unique_ptr:

Containers as Data Members 148

 

**Ex 9.10. Initialization from a list of unique pointers. Run** [**@Compiler Explorer**](https://godbolt.org/z/dx5zaj5PY)

**template**\<**typename T**, **typename**... Args\> **auto** initFromMoveable(Args&&... args) {

std::vector\<std::unique_ptr\<T\>\> vec;

vec.reserve(**sizeof**...(Args));

(vec.emplace_back(std::forward\<Args\>(args)), ...);

**return** vec;

}

**int** main() {

**auto** shapes = initFromMoveable\<Shape\>(

std::make_unique\<Circle\>(), std::make_unique\<Rectangle\>()

);

}

For more information about those techniques, have a look at articles at the C++Stories blog:

[C++20 Concepts - a Quick Introduction⁶](https://www.cppstories.com/2021/concepts-intro/), [C++ Templates: How to Iterate through std::tuple:](https://www.cppstories.com/2022/tuple-iteration-basics/)

[the Basics⁷](https://www.cppstories.com/2022/tuple-iteration-basics/).

![](/tmp/audit/iter1/epubregen/c-initialization-story/media/index-163_1.png)

std::initializer_list has a bad reputation in C++. You can see this in Jason

Turner’s talk from C++Now 2018, [“Initializer Lists are Broken — Let’s Fix Them.”⁸](https://www.youtube.com/watch?v=sSlmmZMFsXQ) and understand different solutions to passing lists to a function. And look at this

article by Andrzej Krzemieński about [The cost of](https://akrzemi1.wordpress.com/2016/07/07/the-cost-of-stdinitializer_list/) [std::initializer_list](https://akrzemi1.wordpress.com/2016/07/07/the-cost-of-stdinitializer_list/)[⁹](https://akrzemi1.wordpress.com/2016/07/07/the-cost-of-stdinitializer_list/).

 

**Summary**

In this chapter, we discussed having various containers as data members. If we use containers from the Standard Library, then they handle all memory management and allocations. We can use those standard containers as regular types without worrying about custom implementation for special member functions. Thanks to the NSDMI feature, we can safely initialize them with a convenient syntax. In the second part of the chapter, you learned about initializer_list, which is an option to pass multiple values at once with a handy API.

⁶<https://www.cppstories.com/2021/concepts-intro/>

⁷<https://www.cppstories.com/2022/tuple-iteration-basics/>

⁸<https://www.youtube.com/watch?v=sSlmmZMFsXQ>

⁹<https://akrzemi1.wordpress.com/2016/07/07/the-cost-of-stdinitializer_list/>

Containers as Data Members 149

 

The initializer_list type is only a view of an internal array of const objects. For simple types, initializer_list has some benefits, but you must be aware of the extra copy when passing things around. Additionally, if you have a constructor taking the list, then it will be “greedy” and takes priority over other non-default constructors.