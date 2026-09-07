**Appendix A - Rules for Special**



**Member Function Generation**

In the chapters about constructors and the destructor, we discussed when a compiler implicitly generates a given special member for a class type. In this appendix, you’ll see a handy summary of the rules and guidelines for most common use cases.



**The diagram**

A C++ expert Howard Hinnant, a few years ago created a diagram⁵ with the rules:

![](media/index-263_1.png)



⁵diagram redrawn, with permission of Howard Hinnant.

248

Appendix A - Rules for Special Member Function Generation 249



Howard is a lead designer and author of the C++11 proposal for move semantics, the std::chrono library, and a few other vital parts of Modern C++. The diagram, along with

an informative description, can be found on this page: [C++ class declarations](https://howardhinnant.github.io/classdecl.html)⁶ and also see

this presentation: [Everything you need to know about move semantics - Howard Hinnant](https://www.youtube.com/watch?v=vLinb2fgkHk)

[@YouTube⁷](https://www.youtube.com/watch?v=vLinb2fgkHk).

How to read the diagram:

Labels:

• defaulted - compiler generates the function if possible.

• defaulted\* - deprecated behavior since C++11, the compiler might warn about a

function generation.

• not-declared - there’s no declaration of a function so that it won’t participate in the

overload resolution.

• deleted - the function is =delete, meaning that it participates in the overload

resolution, but it won’t be accessible.

• user declared - a given function is declared by the user and not implicitly provided by

the compiler. That includes empty implementation, =default or even =delete.

Rules:

• If a user declares no special member functions, the compiler defaults all special member

functions.

• If a user declares any constructor, the compiler defaults all special member functions

except for the default constructor

• If a user declares a default constructor, the compiler defaults all special member

functions

• If a user declares a destructor, the compiler defaults a default constructor, copy constructor and copy assignment operations. The move constructor and move assignment are not declared. The approach is deprecated, and compilers might warn about such behavior. Usually, when you declare a destructor, there’s a high chance the default copy constructor might be insufficient.

• If a user declares a copy constructor, the compiler doesn’t declare the default constructor, destructor, and copy assignment is defaulted. The move constructor and move assignment are not declared.

⁶<https://howardhinnant.github.io/classdecl.html>

⁷<https://www.youtube.com/watch?v=vLinb2fgkHk> Appendix A - Rules for Special Member Function Generation 250



• If a user declares a copy assignment, the compiler default constructor, destructor, and

copy assignment are defaulted. The move constructor and move assignment are not declared.

• If a user declares a move constructor, the compiler doesn’t declare the default

constructor, and the destructor is defaulted. The move assignment is not declared. The most important part is that the copy constructor and the copy assignment operator are deleted.

• If a user declares a move assignment, the compiler defaults a default constructor and

destructor. The move constructor is not declared. The copy constructor and the copy assignment operator are deleted.



**More functions provided**

In a row, there’s only one “user-declared” function, but if your class type has more than one special member function declared, then you have to look at the intersection of the matching rows. For example, suppose you declare a default constructor and a move assignment. In that case, the compiler will provide a default implementation for the destructor but will delete copy operations and not declare the move constructor.



**Inheritance**

And how about base and derived classes?

• A default constructor for a class T will be defined as deleted if T has a direct or virtual

base that has a deleted default constructor, or it is ambiguous or inaccessible from this constructor.

• A copy constructor for a class T will be defined as deleted if T has a direct or virtual base

class that cannot be copied (has deleted, inaccessible, or ambiguous copy constructors).

• A move constructor for a class T will be defined as deleted if T has a direct or

virtual base class that cannot be moved (has deleted, inaccessible, or ambiguous move constructors).

For example

Appendix A - Rules for Special Member Function Generation 251

**struct Base** {

Base(Base&&) = **delete**;

};

**struct Derived** : Base { };

**int** main() {

Derived d; // won't compile!

}

The above code doesn’t compile. We delete the move constructor from the Base class. This means that the move constructor in the Derived type is also deleted. In both types, the default constructor is not declared and not accessible.



**Rules**



**Rule of zero**

In most cases, defining a class without any special member functions will just work:

**class RuleOfZero** {

**public**:

// no custom special member functions...

// member functions...

// data members...

};

In the above case, the RuleOfZero class has all special member functions implicitly defined by the compiler.

See the following rule from the C++ Coding Guideline: [C.20: If you can avoid defining default](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c20-if-you-can-avoid-defining-default-operations-do)

[operations, do](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c20-if-you-can-avoid-defining-default-operations-do)⁸.

⁸<https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c20-if-you-can-avoid-defining-default-operations-do> Appendix A - Rules for Special Member Function Generation 252



**Rule of three (deprecated!)**

Before C++11, when there were no move operations, you could implement all special member functions:

**class OldRuleOfThree** {

**public**:

~OldRuleOfThree();

OldRuleOfThree(**const** OldRuleOfThree& other);

OldRuleOfThree& **operator**=(**const** OldRuleOfThree& other); };

However, since C++11, you **shouldn’t use this pattern**, as having a copy operation declared won’t declare the move operations. The lack of move operations will “slow down” the code that uses those objects, as the compiler will be able to copy data rather than optimize with move.

**Rule of 5 and 6**

For C++11 and above, if you implement a class that serves as a container or a manager for a resource, then you probably need to implement all special member functions:

**class RuleOfSix** {

**public**:

RuleOfSix();

~RuleOfSix() **noexcept**;

RuleOfSix(**const** RuleOfSix& other);

RuleOfSix& **operator**=(**const** container& other);

RuleOfSix(RuleOfSix&& other) **noexcept**;

RuleOfSix& **operator**=(container&& other) **noexcept**; };

See the following rule from the C++ Coding Guideline: [C.21: If you define or =delete any](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c21-if-you-define-or-delete-any-copy-move-or-destructor-function-define-or-delete-them-all)

[copy, move, or destructor function, define or =delete them all⁹](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c21-if-you-define-or-delete-any-copy-move-or-destructor-function-define-or-delete-them-all).

⁹[https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c21-if-you-define-or-delete-any-copy-move-or-](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c21-if-you-define-or-delete-any-copy-move-or-destructor-function-define-or-delete-them-all)

[destructor-function-define-or-delete-them-all](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c21-if-you-define-or-delete-any-copy-move-or-destructor-function-define-or-delete-them-all) Appendix A - Rules for Special Member Function Generation 253



**Moveable only types**

**class MoveableOnly** {

**public**:

MoveableOnly() **noexcept**;

~MoveableOnly() **noexcept**;

MoveableOnly(MoveableOnly&& other) **noexcept**;

MoveableOnly& **operator**=(MoveableOnly&& other) **noexcept**; };

Note that in the above case, because we declare move operations, then the compiler will delete copy operations:

// MoveableOnly(const MoveableOnly&) = delete; // MoveableOnly& operator=(const MoveableOnly&) = delete;

Example types: std::unique_ptr.



**Polymorphic base classes**

**class BasePoly** {

**public**:

**virtual** ~BasePoly() = **default**;

BasePoly& **operator**=(BasePoly&& other) = **delete**;

**virtual void** foo();

}

By declaring move assignment, we prevent copy operations (they will be deleted); the move constructor is not declared. But we have to explicitly introduce a virtual destructor because, by default, the compiler creates only a non-virtual default destructor.