**Introduction**

If you’re an experienced C++ programmer and are anything like me, you initially approached C++11 thinking, “Yes, yes, I get it. It’s C++, only more so.” But as you learned more, you were surprised by the scope of the changes. auto declarations, range-based for loops, lambda expressions, and rvalue references change the face of C++, to say nothing of the new concurrency features. And then there are the idiomatic changes. 0 and typedefs are out, nullptr and alias declarations are in.

Enums should now be scoped. Smart pointers are now preferable to built-in ones.

Moving objects is normally better than copying them.

There’s a lot to learn about C++11, not to mention C++14.

More importantly, there’s a lot to learn about making *effective* use of the new capabil-ities. If you need basic information about “modern” C++ features, resources abound, but if you’re looking for guidance on how to employ the features to create software that’s correct, efficient, maintainable, and portable, the search is more challenging.

That’s where this book comes in. It’s devoted not to describing the features of C++11

and C++14, but instead to their effective application.

The information in the book is broken into guidelines called *Items*. Want to understand the various forms of type deduction? Or know when (and when not) to use auto declarations? Are you interested in why const member functions should be thread safe, how to implement the Pimpl Idiom using std::unique_ptr, why you should avoid default capture modes in lambda expressions, or the differences between std::atomic and volatile? The answers are all here. Furthermore, they’re platform-independent, Standards-conformant answers. This is a book about *portable* C++.

The Items in this book are guidelines, not rules, because guidelines have exceptions.

The most important part of each Item is not the advice it offers, but the rationale behind the advice. Once you’ve read that, you’ll be in a position to determine whether the circumstances of your project justify a violation of the Item’s guidance. The true **1**

goal of this book isn’t to tell you what to do or what to avoid doing, but to convey a deeper understanding of how things work in C++11 and C++14.

**Terminology and Conventions**

To make sure we understand one another, it’s important to agree on some terminology, beginning, ironically, with “C++.” There have been four official versions of C++, each named after the year in which the corresponding ISO Standard was adopted: *C++98*, *C++03*, *C++11*, and *C++14*. C++98 and C++03 differ only in technical details, so in this book, I refer to both as C++98. When I refer to C++11, I mean both C++11 and C++14, because C++14 is effectively a superset of C++11. When I write C++14, I mean specifically C++14. And if I simply mention C++, I’m making a broad statement that pertains to all language versions.

**Term I Use Language Versions I Mean**

C++

All

C++98

C++98 and C++03

C++11

C++11 and C++14

C++14

C++14

As a result, I might say that C++ places a premium on efficiency (true for all versions), that C++98 lacks support for concurrency (true only for C++98 and C++03), that C++11 supports lambda expressions (true for C++11 and C++14), and that C++14 offers generalized function return type deduction (true for C++14 only).

C++11’s most pervasive feature is probably move semantics, and the foundation of move semantics is distinguishing expressions that are *rvalues* from those that are *lvalues*. That’s because rvalues indicate objects eligible for move operations, while lvalues generally don’t. In concept (though not always in practice), rvalues correspond to temporary objects returned from functions, while lvalues correspond to objects you can refer to, either by name or by following a pointer or lvalue reference.

A useful heuristic to determine whether an expression is an lvalue is to ask if you can take its address. If you can, it typically is. If you can’t, it’s usually an rvalue. A nice feature of this heuristic is that it helps you remember that the type of an expression is independent of whether the expression is an lvalue or an rvalue. That is, given a type T, you can have lvalues of type T as well as rvalues of type T. It’s especially important to remember this when dealing with a parameter of rvalue reference type, because the parameter itself is an lvalue:

**2 \|**

class Widget {

public:

Widget(**Widget&& rhs**); // *rhs is an lvalue*, though it has

… // an rvalue reference type

};

Here, it’d be perfectly valid to take rhs’s address inside Widget’s move constructor, so rhs is an lvalue, even though its type is an rvalue reference. (By similar reasoning, all parameters are lvalues.)

That code snippet demonstrates several conventions I normally follow:

• The class name is Widget. I use Widget whenever I want to refer to an arbitrary user-defined type. Unless I need to show specific details of the class, I use Widget without declaring it.

• I use the parameter name *rhs* (“right-hand side”). It’s my preferred parameter name for the *move operations* (i.e., move constructor and move assignment operator) and the *copy operations* (i.e., copy constructor and copy assignment operator). I also employ it for the right-hand parameter of binary operators: Matrix operator+(const Matrix& lhs, const Matrix& **rhs**);

It’s no surprise, I hope, that *lhs* stands for “left-hand side.”

• I apply special formatting to parts of code or parts of comments to draw your attention to them. In the Widget move constructor above, I’ve highlighted the declaration of rhs and the part of the comment noting that rhs is an lvalue.

Highlighted code is neither inherently good nor inherently bad. It’s simply code you should pay particular attention to.

• I use “…” to indicate “other code could go here.” This narrow ellipsis is different from the wide ellipsis (“...”) that’s used in the source code for C++11’s variadic templates. That sounds confusing, but it’s not. For example:

template\<typename**...** Ts\> // these are C++

void processVals(const Ts& **...** params) // source code

{ // ellipses

**…** // this means "some

// code goes here"

}

The declaration of processVals shows that I use typename when declaring type parameters in templates, but that’s merely a personal preference; the keyword class would work just as well. On those occasions where I show code excerpts

**\| 3**

from a C++ Standard, I declare type parameters using class, because that’s what the Standards do.

When an object is initialized with another object of the same type, the new object is said to be a *copy* of the initializing object, even if the copy was created via the move constructor. Regrettably, there’s no terminology in C++ that distinguishes between an object that’s a copy-constructed copy and one that’s a move-constructed copy: void someFunc(Widget w); // someFunc's parameter w

// is passed by value

Widget wid; // wid is some Widget

someFunc(wid); // in this call to someFunc,

// w is a *copy* of wid that's

// created via c *opy construction*

someFunc(std::move(wid)); // in this call to SomeFunc,

// w is a *copy* of wid that's

// created via *move construction*

Copies of rvalues are generally move constructed, while copies of lvalues are usually copy constructed. An implication is that if you know only that an object is a copy of another object, it’s not possible to say how expensive it was to construct the copy. In the code above, for example, there’s no way to say how expensive it is to create the parameter w without knowing whether rvalues or lvalues are passed to someFunc.

(You’d also have to know the cost of moving and copying Widgets.)

In a function call, the expressions passed at the call site are the function’s *arguments*.

The arguments are used to initialize the function’s *parameters*. In the first call to someFunc above, the argument is wid. In the second call, the argument is std::move(wid). In both calls, the parameter is w. The distinction between arguments and parameters is important, because parameters are lvalues, but the arguments with which they are initialized may be rvalues or lvalues. This is especially relevant during the process of *perfect forwarding*, whereby an argument passed to a function is passed to a second function such that the original argument’s rvalueness

or lvalueness is preserved. (Perfect forwarding is discussed in detail in Item 30.)

Well-designed functions are *exception safe*, meaning they offer at least the basic exception safety guarantee (i.e., the *basic guarantee*). Such functions assure callers that even if an exception is thrown, program invariants remain intact (i.e., no data structures are corrupted) and no resources are leaked. Functions offering the strong exception safety guarantee (i.e., the *strong guarantee*) assure callers that if an exception arises, the state of the program remains as it was prior to the call.

**4 \|**

When I refer to a *function object*, I usually mean an object of a type supporting an operator() member function. In other words, an object that acts like a function.

Occasionally I use the term in a slightly more general sense to mean anything that can be invoked using the syntax of a non-member function call (i.e., “*function* *Name(arguments)*”). This broader definition covers not just objects supporting oper ator(), but also functions and C-like function pointers. (The narrower definition comes from C++98, the broader one from C++11.) Generalizing further by adding member function pointers yields what are known as *callable objects*. You can generally ignore the fine distinctions and simply think of function objects and callable objects as things in C++ that can be invoked using some kind of function-calling syntax.

Function objects created through lambda expressions are known as *closures*. It’s seldom necessary to distinguish between lambda expressions and the closures they create, so I often refer to both as *lambdas*. Similarly, I rarely distinguish between *function templates* (i.e., templates that generate functions) and *template functions* (i.e., the functions generated from function templates). Ditto for *class templates* and *template classes*.

Many things in C++ can be both declared and defined. *Declarations* introduce names and types without giving details, such as where storage is located or how things are implemented:

extern int x; // object declaration

class Widget; // class declaration

bool func(const Widget& w); // function declaration

enum class Color; // scoped enum declaration

// (see Item 10)

*Definitions* provide the storage locations or implementation details: int x; // object definition

class Widget { // class definition

…

};

bool func(const Widget& w)

{ return w.size() \< 10; } // function definition

enum class Color

{ Yellow, Red, Blue }; // scoped enum definition

**\| 5**

A definition also qualifies as a declaration, so unless it’s really important that something is a definition, I tend to refer to declarations.

I define a function’s *signature* to be the part of its declaration that specifies parameter and return types. Function and parameter names are not part of the signature. In the example above, func’s signature is bool(const Widget&). Elements of a function’s declaration other than its parameter and return types (e.g., noexcept or constexpr, if present), are excluded. (noexcept and constexpr are described in Items 14 and

15.) The official definition of “signature” is slightly different from mine, but for this book, my definition is more useful. (The official definition sometimes omits return types.)

New C++ Standards generally preserve the validity of code written under older ones, but occasionally the Standardization Committee *deprecates* features. Such features are on standardization death row and may be removed from future Standards. Compilers may or may not warn about the use of deprecated features, but you should do your best to avoid them. Not only can they lead to future porting headaches, they’re generally inferior to the features that replace them. For example, std::auto_ptr is deprecated in C++11, because std::unique_ptr does the same job, only better.

Sometimes a Standard says that the result of an operation is *undefined behavior*. That means that runtime behavior is unpredictable, and it should go without saying that you want to steer clear of such uncertainty. Examples of actions with undefined behavior include using square brackets (“\[\]”) to index beyond the bounds of a std::vector, dereferencing an uninitialized iterator, or engaging in a data race (i.e., having two or more threads, at least one of which is a writer, simultaneously access the same memory location).

I call built-in pointers, such as those returned from new, *raw pointers*. The opposite of a raw pointer is a *smart pointer*. Smart pointers normally overload the pointer-dereferencing operators (operator-\> and operator\*), though Item 20 explains that std::weak_ptr is an exception.

In source code comments, I sometimes abbreviate “constructor” as *ctor* and

“destructor” as *dtor*.

**Reporting Bugs and Suggesting Improvements**

I’ve done my best to fill this book with clear, accurate, useful information, but surely there are ways to make it better. If you find errors of any kind (technical, expository, grammatical, typographical, etc.), or if you have suggestions for how the book could

[be improved, please email me at *emc++@aristeia.com*. New printings give me the](mailto:emc++@aristeia.com)

**6 \|**

opportunity to revise *Effective Modern C++*, and I can’t address issues I don’t know about!

To view the list of the issues I do know about, consult the book’s errata page, [*http://*](http://www.aristeia.com/BookErrata/emc++-errata.html)

[*www.aristeia.com/BookErrata/emc++-errata.html*.](http://www.aristeia.com/BookErrata/emc++-errata.html)

**\| 7**

**CHAPTER 1**