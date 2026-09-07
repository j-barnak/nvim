**12. Aggregates and Designated**

**Initializers in C++20**

Across the book, you’ve seen a lot of cases for intuitively simple structures with all public data members. Such types, along with arrays, are called *Aggregates*. In this chapter, we’ll look at some C++20 changes and new ways to initialize such objects.



**Aggregates in C++20**

To sum up, as of C++20, here’s the definition of an *aggregate type* from the C++ Standard:

[dcl.init.aggr¹](https://timsong-cpp.github.io/cppwp/n4868/dcl.init.aggr#:initialization,aggregate).



An aggregate is an array or a class type with:

• no user-provided, explicit, or inherited constructors

• no private or protected non-static data members

• no virtual functions, and

• no virtual, private, or protected base classes



Here are some examples of aggregates:



¹<https://timsong-cpp.github.io/cppwp/n4868/dcl.init.aggr#:initialization,aggregate>

199

Aggregates and Designated Initializers in C++20 200



**Ex 12.1. Aggregate classes, several examples. Run** [**@Compiler Explorer**](https://godbolt.org/z/5oz47o8z5)

**struct Base** { **int** x {42}; };

**struct Derived** : Base { **int** y; };

**struct Param** {

std::string name;

**int** val;

**void** Parse(); // member functions allowed };

**int** main() {

Derived d {100, 1000};

std::cout \<\< "d.x " \<\< d.x \<\< ", d.y " \<\< d.y \<\< '\n';

Derived d2 { 1 };

std::cout \<\< "d2.x " \<\< d2.x \<\< ", d2.y " \<\< d2.y \<\< '\n';

Param p {"value", 10};

std::cout \<\< "p.name " \<\< p.name \<\< ", p.val " \<\< p.val \<\< '\n';

**double** arr\[\] { 1.1, 2.2, 3.3, 4.4};

std::cout \<\< "arr\[0\] " \<\< arr\[0\] \<\< '\n';

std::array floats { 10.1f, 20.2f, 30.3f };

std::cout \<\< "floats\[0\] " \<\< floats\[0\] \<\< '\n';

std::array params {Param{"val", 10}, Param{"name", 42}};

std::cout \<\< "params\[0\].name " \<\< params\[0\].name \<\< '\n'; }



In C++20, in some limited cases, you can also use parens X(args...) to initialize an aggregate. Here’s a short example with major use cases and limitations:

Aggregates and Designated Initializers in C++20 201



**Ex 12.2. Initialization with round parens in C++20. Run** [**@Compiler Explorer**](https://godbolt.org/z/fo6TKnYTo)

**struct Point** { **int** x; **int** y; };

**struct PointExt** { Point pt; **int** z; };

**int** main() {

// C++20 and parens:

Point pt (1, 2);

// Point pt = (1, 2); // doesn't work, wrong syntax

Point pt1 = {1, 2}; // fine with braces

//Point pt2 { 1.1, 2.2 }; // narrowing prevented

Point pt3 ( 1.1, 2.2 ); // narrowing is fine

PointExt pt4 { 4, 5, 6}; // brace elision works

//PointExt pt5 ( (4, 5), 6); // nesting doesn't work

// PointExt pt5 ( 4, 5, 6); // brace elision doesn't work

PointExt pt5 ( Point(4, 5), 6); // need to be explicit

**double** params\[\] (9.81, 3.14, 1.44);

// double paramsDeduced\[\] = (9.81, 3.14, 1.44); // wrong syntax

**int** arrX\[10\] (1, 2, 3, 4); // rest is 0 }



Here are some basic rules about the new way of initialization:

• You have to use direct initialization (args...) not copy style =(args...). In the

example, pt = (1, 2); fails to compile, while Point pt1 = {1, 2}; works. A similar rule works for arrays.

• On the other hand, braces {} prevent narrowing conversion, but parens () allows it.

In the example, pt3 will be initialized with 1 and 2which are truncated from 1.1 and 2.2 double values.

• When you use braces, you can skip braces for nested types. This feature is impossible

with parens, and you must be explicit about subobjects.

Such improvement helps, especially in a generic template code where you want to work with various types of objects. For example, the following code wasn’t possible until C++20: Aggregates and Designated Initializers in C++20 202



**Ex 12.2. Aggregates and parens for** **make_unique****. Run** [**@Compiler Explorer**](https://godbolt.org/z/f1E856cYd) **struct Point** { **int** x; **int** y; };

**int** main() {

**auto** ptr = std::make_unique\<Point\>(10, 20); }



make_unique takes a variable number of arguments and passes them to a constructor. This function uses parens to call the constructor. Since our aggregate has no user-declared constructors, then such syntax generates errors. With the C++20 change, the code works fine now.

We can also try another example that compiles in C++20 but failed before:

**Ex 13.3. Aggregates and parens for** **emplace\_****. Run** [**@Compiler Explorer**](https://godbolt.org/z/9dE49EGs8) **struct Point** { **int** x; **int** y; };

**int** main() {

std::vector\<Point\> points;

points.emplace_back(10, 20);

}

The emplace_back() function takes arguments and creates a Point object at the end of the vector. This is an alternative to push_back, which requires passing an already created object, and then a copy of the object is put at the end of the container. emplace_back uses () to create an object, and before C++20 aggregates had issues to work with this function.

If you like to know more, I highly recommend reading [C++20’s parenthesized aggregate](https://quuxplusone.github.io/blog/2022/06/03/aggregate-parens-init-considered-kinda-bad/)

[initialization has some downsides – Arthur O’Dwyer²](https://quuxplusone.github.io/blog/2022/06/03/aggregate-parens-init-considered-kinda-bad/), which discusses pros and cons of this new initialization syntax. Plus, look at this short lighting talk from ACCU 2022 by Timur

Doumler: [Lightning Talk - Direct Aggregate Initialisation](https://www.youtube.com/watch?v=1_2e8r4zXJg) ³.



**The basics of Designated Initializers**

The C++20 Standard also gives us another handy way to initialize data members. The new feature is called designated initializers, which might be familiar to C programmers.

²<https://quuxplusone.github.io/blog/2022/06/03/aggregate-parens-init-considered-kinda-bad/>

³<https://www.youtube.com/watch?v=1_2e8r4zXJg> Aggregates and Designated Initializers in C++20 203



As of C++20, to initialize an aggregate object, you can write the following:

Type obj = { .designator = val, .designator { val2 }, ... };

For example:

**struct Point** { **double** x; **double** y; }; Point p { .x = 10.0, .y = 20.0 };

**Designator** points to a name of a non-static data member from our class, like .x or .y.

One of the main reasons to use this new kind of initialization is to increase readability. Compare the following initialization forms:

**struct Date** {

**int** year;

**int** month;

**int** day;

};

// new

Date inFutureCpp20 { .year = 2050, .month = 4, .day = 10 }; // old

Date inFutureOld { 2050, 4, 10 };

In the case of the Date class, it might be unclear what the order of days/month or month/days is. With designated initializers (inFutureCpp20), it’s very easy to see the order of data members.



**Rules**

The following rules apply to designated initializers:

• designated initializers work only for aggregate initialization, so they only support

aggregate types,

• designated initialization requires braces {} and doesn’t support C++20 initialization

with parens (), Aggregates and Designated Initializers in C++20 204



• designators can only refer to non-static data members,

• designators in the initialization expression must have the same order of data members

in a class declaration,

**–** this is unlike the C language, where you can put designators in any order,

• not all data members must be specified in the expression,

• you cannot mix regular initialization with designators,

• there can only be one designator for a data member,

• you cannot nest designators.

Here’s a simple example that illustrates the main errors with designated initializers:

**struct Date** {

**int** year;

**int** month;

**int** day;

**static int** mode;

};

Date d { .mode = 10 }; // error, mode is static! Date d { .day = 1, .year = 2010 }; // error, out of order! Date d { 2050, .month = 12 }; // error, mix!

The code above illustrates several cases where designated initializers won’t work: static data member, use out-of-order initialization, or a mix. In all cases, the compiler generates an error.



**Advantages of designated initialization**

• Readability: A designator points to the specific data member, so it’s impossible to make

mistakes here.

• Flexibility: You can skip some data members and rely on default values for others.

• Compatibility with C: In C99, it’s popular to use a similar form of initialization

(although even more relaxed). With the C++20 feature, it’s possible to have very similar code and share it.

• Standardization: Some compilers, like GCC or Clang, already had some extensions for

this feature, so it’s a natural step to enable it in all compilers.

Aggregates and Designated Initializers in C++20 205



**Examples**

Let’s take a look at some examples:

**Ex 12.4. Designated initializers demo. Run** [**@Compiler Explorer**](https://godbolt.org/z/h9PPsbxW3)

\#include \<iostream\>

\#include \<string\>

**struct Product** {

std::string name\_;

**bool** inStock\_ { false };

**double** price\_ = 0.0;

};

**void** Print(**const** Product& p) {

std::cout \<\< "name: " \<\< p.name\_ \<\< ", in stock: "

\<\< std::boolalpha \<\< p.inStock\_ \<\< ", price: " \<\< p.price\_ \<\< '\n';

}

**struct Time** { **int** hour; **int** minute; }; **struct Date** { Time t; **int** year; **int** month; **int** day; };

**int** main() {

Product p { .name\_ = "box", .inStock\_ {true }};

Print(p);

Date d { .t { .hour = 10, .minute = 35 },

.year = 2050, .month = 5, .day = 10 };

// pass to a function:

Print({.name\_ = "tv", .inStock\_ {true }, .price\_{100.0}});

// not all members used:

Print({.name\_ = "car", .price\_{2000.0}}); }



It’s also interesting that we can use designated initialization inside another designated Aggregates and Designated Initializers in C++20 206



initialization. For example:

**struct Time** { **int** hour; **int** min; }; **struct Date** { Time t; **int** year; **int** month; **int** day; };

Date d { .t { .hour = 10, .min = 6 }, .year = 2050, .month = 5, .day = 10 };

However, we can’t use “nested” ones, like:

Date d { .t.hour = 10, .t.min = 35, .year = 2050, .month = 5, .day = 10 };

The syntax .t.hour does not work.

As another demo, we can create an almost JSON-like structure ⁴:

**Ex 12.5. JSON-like structure initialization. Run** [**@Compiler Explorer**](https://godbolt.org/z/e9e4MebbY)

\#include \<iostream\>

\#include \<string\>

\#include \<vector\>

**struct Date** { **int** year; **int** month; **int** day; }; **struct Team** { std::string name; std::string where; }; **struct GameSession** {

std::string game;

std::string localization;

std::vector\<Team\> teams;

Date date;

};

**int** main() {

GameSession test {

.game = "Pong",

.localization = "Pacific Ocean", .teams = {

Team {

.name = "Johny Test", .where = "Arctica",

⁴Thanks to Mariusz Jaskółka for inspiration.

Aggregates and Designated Initializers in C++20 207

},

Team {

.name = "Jane Doe", .where = "Antarctic",

},

},

.date = {

.year = 2022,

.month = 10,

.day = 6

},

};

}

Thanks to designated initializers, we can create large objects and still be able to assign values in a readable form. Such GameSession from the above demo might be handy for some unit test scenarios.



**Summary**

When you have a simple type composed of all public data members without complex special member functions, C++ allows you to create them in a simplified manner. What’s more, C++ has evolved to streamline the work even more. For example, in C++20, we get Designated Initializers which usually yield a more readable way of initializing aggregate types. Additionally, C++20 extended the use of regular parens () for initialization, so the “factory” function can easily be more generic and work with both aggregate and complex classes.