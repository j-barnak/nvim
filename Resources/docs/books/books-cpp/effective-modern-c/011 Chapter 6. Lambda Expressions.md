**Lambda Expressions**

Lambda expressions— *lambdas*—are a game changer in C++ programming. That’s somewhat surprising, because they bring no new expressive power to the language.

Everything a lambda can do is something you can do by hand with a bit more typing.

But lambdas are such a convenient way to create function objects, the impact on day-to-day C++ software development is enormous. Without lambdas, the STL “\_if”

algorithms (e.g., std::find_if, std::remove_if, std::count_if, etc.) tend to be employed with only the most trivial predicates, but when lambdas are available, use of these algorithms with nontrivial conditions blossoms. The same is true of algorithms that can be customized with comparison functions (e.g., std::sort, std::nth_element, std::lower_bound, etc.). Outside the STL, lambdas make it possible to quickly create custom deleters for std::unique_ptr and

std::shared_ptr (see Items 18 and 19), and they make the specification of predicates for condition variables in the threading API equally straightforward (see

Item 39). Beyond the Standard Library, lambdas facilitate the on-the-fly specification of callback functions, interface adaption functions, and context-specific functions for one-off calls. Lambdas really make C++ a more pleasant programming language.

The vocabulary associated with lambdas can be confusing. Here’s a brief refresher:

• A *lambda expression* is just that: an expression. It’s part of the source code. In std::find_if( *container*.begin(), *container*.end(),

**\[\](int val) { return 0 \< val && val \< 10; }**);

the highlighted expression is the lambda.

• A *closure* is the runtime object created by a lambda. Depending on the capture mode, closures hold copies of or references to the captured data. In the call to **215**

std::find_if above, the closure is the object that’s passed at runtime as the third argument to std::find_if.

• A *closure class* is a class from which a closure is instantiated. Each lambda causes compilers to generate a unique closure class. The statements inside a lambda become executable instructions in the member functions of its closure class.

A lambda is often used to create a closure that’s used only as an argument to a function. That’s the case in the call to std::find_if above. However, closures may generally be copied, so it’s usually possible to have multiple closures of a closure type corresponding to a single lambda. For example, in the following code,

{

int x; // x is local variable

…

auto c1 = // c1 is copy of the

\[x\](int y) { return x \* y \> 55; }; // closure produced

// by the lambda

auto c2 = c1; // c2 is copy of c1

auto c3 = c2; // c3 is copy of c2

…

}

c1, c2, and c3 are all copies of the closure produced by the lambda.

Informally, it’s perfectly acceptable to blur the lines between lambdas, closures, and closure classes. But in the Items that follow, it’s often important to distinguish what exists during compilation (lambdas and closure classes), what exists at runtime (closures), and how they relate to one another.

**Item 31: Avoid default capture modes.**

There are two default capture modes in C++11: by-reference and by-value. Default by-reference capture can lead to dangling references. Default by-value capture lures you into thinking you’re immune to that problem (you’re not), and it lulls you into thinking your closures are self-contained (they may not be).

That’s the executive summary for this Item. If you’re more engineer than executive, you’ll want some meat on those bones, so let’s start with the danger of default by-reference capture.

**216 \| Item 30**

A by-reference capture causes a closure to contain a reference to a local variable or to a parameter that’s available in the scope where the lambda is defined. If the lifetime of a closure created from that lambda exceeds the lifetime of the local variable or parameter, the reference in the closure will dangle. For example, suppose we have a container of filtering functions, each of which takes an int and returns a bool indicating whether a passed-in value satisfies the filter:

using FilterContainer = // see Item 9 for std::vector\<std::function\<bool(int)\>\>; // "using", Item 2

// for std::function

FilterContainer filters; // filtering funcs

We could add a filter for multiples of 5 like this:

filters.emplace_back( // see Item 42 for

\[\](int value) { return value % 5 == 0; } // info on

); // emplace_back

However, it may be that we need to compute the divisor at runtime, i.e., we can’t just hard-code 5 into the lambda. So adding the filter might look more like this: void addDivisorFilter()

{

auto calc1 = computeSomeValue1();

auto calc2 = computeSomeValue2();

auto **divisor** = computeDivisor(calc1, calc2);

filters.emplace_back( // danger!

**\[&\]**(int value) { return value % divisor == 0; } // ref to

); // divisor

} // will

// dangle!

This code is a problem waiting to happen. The lambda refers to the local variable divisor, but that variable ceases to exist when addDivisorFilter returns. That’s immediately after filters.emplace_back returns, so the function that’s added to filters is essentially dead on arrival. Using that filter yields undefined behavior from virtually the moment it’s created.

Now, the same problem would exist if divisor’s by-reference capture were explicit, filters.emplace_back(

\[**&divisor**\](int value) // danger! ref to

{ return value % divisor == 0; } // divisor will

); // still dangle!

**Item 31 \| 217**

but with an explicit capture, it’s easier to see that the viability of the lambda is dependent on divisor’s lifetime. Also, writing out the name, “divisor,” reminds us to ensure that divisor lives at least as long as the lambda’s closures. That’s a more specific memory jog than the general “make sure nothing dangles” admonition that

“\[&\]” conveys.

If you know that a closure will be used immediately (e.g., by being passed to an STL

algorithm) and won’t be copied, there is no risk that references it holds will outlive the local variables and parameters in the environment where its lambda is created. In that case, you might argue, there’s no risk of dangling references, hence no reason to avoid a default by-reference capture mode. For example, our filtering lambda might be used only as an argument to C++11’s std::all_of, which returns whether all elements in a range satisfy a condition:

template\<typename C\>

void workWithContainer(const C& container)

{

auto calc1 = computeSomeValue1(); // as above

auto calc2 = computeSomeValue2(); // as above

auto **divisor** = computeDivisor(calc1, calc2); // as above

using ContElemT = typename C::value_type; // type of

// elements in

// container

using std::begin; // for

using std::end; // genericity;

// see Item 13

if (std::all_of( // if all values

begin(container), end(container), // in container

**\[&\]**(const ContElemT& value) // are multiples

{ return value % divisor == 0; }) // of divisor...

) {

… // they are...

} else {

… // at least one

} // isn't...

}

It’s true, this is safe, but its safety is somewhat precarious. If the lambda were found to be useful in other contexts (e.g., as a function to be added to the filters container) and was copy-and-pasted into a context where its closure could outlive divi **218 \| Item 31**

sor, you’d be back in dangle-city, and there’d be nothing in the capture clause to specifically remind you to perform lifetime analysis on divisor.

Long-term, it’s simply better software engineering to explicitly list the local variables and parameters that a lambda depends on.

By the way, the ability to use auto in C++14 lambda parameter specifications means that the code above can be simplified in C++14. The ContElemT typedef can be eliminated, and the if condition can be revised as follows:

if (std::all_of(begin(container), end(container),

\[&\](const **auto**& value) // C++14

{ return value % divisor == 0; }))

One way to solve our problem with divisor would be a default by-value capture mode. That is, we could add the lambda to filters as follows:

filters.emplace_back( // now

**\[=\]**(int value) { return value % divisor == 0; } // divisor

); // can't

// dangle

This suffices for this example, but, in general, default by-value capture isn’t the anti-dangling elixir you might imagine. The problem is that if you capture a pointer by value, you copy the pointer into the closures arising from the lambda, but you don’t prevent code outside the lambda from deleteing the pointer and causing your copies to dangle.

“That could never happen!” you protest. “Having read Chapter 4, I worship at the

house of smart pointers. Only loser C++98 programmers use raw pointers and delete.” That may be true, but it’s irrelevant because you do, in fact, use raw pointers, and they can, in fact, be deleted out from under you. It’s just that in your modern C++ programming style, there’s often little sign of it in the source code.

Suppose one of the things Widgets can do is add entries to the container of filters: class Widget {

public:

… // ctors, etc.

void addFilter() const; // add an entry to filters

private:

int divisor; // used in Widget's filter

};

Widget::addFilter could be defined like this:

**Item 31 \| 219**


{


**\[=\]**(int value) { return value % divisor == 0; }

);

}

To the blissfully uninitiated, this looks like safe code. The lambda is dependent on divisor, but the default by-value capture mode ensures that divisor is copied into any closures arising from the lambda, right?

Wrong. Completely wrong. Horribly wrong. Fatally wrong.

Captures apply only to non-static local variables (including parameters) visible in the scope where the lambda is created. In the body of Widget::addFilter, divisor is not a local variable, it’s a data member of the Widget class. It can’t be captured. Yet if the default capture mode is eliminated, the code won’t compile:


{

filters.emplace_back( // error!

**\[\]**(int value) { return value % divisor == 0; } // divisor

); // not

} // available

Furthermore, if an attempt is made to explicitly capture divisor (either by value or by reference—it doesn’t matter), the capture won’t compile, because divisor isn’t a local variable or a parameter:


{


**\[divisor\]**(int value) // error! no local

{ return value % divisor == 0; } // divisor to capture

);

}

So if the default by-value capture clause isn’t capturing divisor, yet without the default by-value capture clause, the code won’t compile, what’s going on?

The explanation hinges on the implicit use of a raw pointer: this. Every non-static member function has a this pointer, and you use that pointer every time you mention a data member of the class. Inside any Widget member function, for example, compilers internally replace uses of divisor with this-\>divisor. In the version of Widget::addFilter with a default by-value capture,

**220 \| Item 31**


{


**\[=\]**(int value) { return value % divisor == 0; }

);

}

what’s being captured is the Widget’s this pointer, not divisor. Compilers treat the code as if it had been written as follows:


{

**auto currentObjectPtr = this;**


**\[currentObjectPtr\]**(int value)

{ return value % **currentObjectPtr-\>** divisor == 0; }

);

}

Understanding this is tantamount to understanding that the viability of the closures arising from this lambda is tied to the lifetime of the Widget whose this pointer they

contain a copy of. In particular, consider this code, which, in accord with Chapter 4, uses pointers of only the smart variety:

using FilterContainer = // as before

std::vector\<std::function\<bool(int)\>\>;

FilterContainer filters; // as before

void doSomeWork()

{

auto pw = // create Widget; see

std::make_unique\<Widget\>(); // Item 21 for

// std::make_unique

pw-\>addFilter(); // add filter that uses

// Widget::divisor

…

} // destroy Widget; filters

// now holds dangling pointer!

When a call is made to doSomeWork, a filter is created that depends on the Widget object produced by std::make_unique, i.e., a filter that contains a copy of a pointer to that Widget—the Widget’s this pointer. This filter is added to filters, but when doSomeWork finishes, the Widget is destroyed by the std::unique_ptr managing its **Item 31 \| 221**

lifetime (see Item 18). From that point on, filters contains an entry with a dangling pointer.

This particular problem can be solved by making a local copy of the data member you want to capture and then capturing the copy:


{

**auto divisorCopy = divisor;** // copy data member


**\[divisorCopy\]**(int value) // capture the copy

{ return value % **divisorCopy** == 0; } // use the copy

);

}

To be honest, if you take this approach, default by-value capture will work, too, void Widget::addFilter() const

{

**auto divisorCopy = divisor;** // copy data member


**\[=\]**(int value) // capture the copy

{ return value % **divisorCopy** == 0; } // use the copy

);

}

but why tempt fate? A default capture mode is what made it possible to accidentally capture this when you thought you were capturing divisor in the first place.

In C++14, a better way to capture a data member is to use generalized lambda cap‐

ture (see Item 32):


{

filters.emplace_back( // C++14:

**\[divisor = divisor\]**(int value) // copy divisor to closure

{ return value % **divisor** == 0; } // use the copy

);

}

There’s no such thing as a default capture mode for a generalized lambda capture, however, so even in C++14, the advice of this Item—to avoid default capture modes

—stands.

An additional drawback to default by-value captures is that they can suggest that the corresponding closures are self-contained and insulated from changes to data outside **222 \| Item 31**

the closures. In general, that’s not true, because lambdas may be dependent not just on local variables and parameters (which may be captured), but also on objects with *static storage duration*. Such objects are defined at global or namespace scope or are declared static inside classes, functions, or files. These objects can be used inside lambdas, but they can’t be captured. Yet specification of a default by-value capture mode can lend the impression that they are. Consider this revised version of the add DivisorFilter function we saw earlier:

void addDivisorFilter()

{

**static** auto calc1 = computeSomeValue1(); // now static

**static** auto calc2 = computeSomeValue2(); // now static

**static** auto **divisor** = // now static computeDivisor(calc1, calc2);


**\[=\]**(int value) // captures nothing!

{ return value % **divisor** == 0; } // refers to above static

);

**++divisor**; // modify divisor

}

A casual reader of this code could be forgiven for seeing “\[=\]” and thinking, “Okay, the lambda makes a copy of all the objects it uses and is therefore self-contained.” But it’s not self-contained. This lambda doesn’t use any non-static local variables, so nothing is captured. Rather, the code for the lambda refers to the static variable divisor. When, at the end of each invocation of addDivisorFilter, divisor is incremented, any lambdas that have been added to filters via this function will exhibit new behavior (corresponding to the new value of divisor). Practically speaking, this lambda captures divisor by reference, a direct contradiction to what the default by-value capture clause seems to imply. If you stay away from default by-value capture clauses, you eliminate the risk of your code being misread in this way.

**Things to Remember**

• Default by-reference capture can lead to dangling references.

• Default by-value capture is susceptible to dangling pointers (especially this), and it misleadingly suggests that lambdas are self-contained.

**Item 31 \| 223**

**Item 32: Use init capture to move objects into closures.**

Sometimes neither by-value capture nor by-reference capture is what you want. If you have a move-only object (e.g., a std::unique_ptr or a std::future) that you want to get into a closure, C++11 offers no way to do it. If you have an object that’s expensive to copy but cheap to move (e.g., most containers in the Standard Library), and you’d like to get that object into a closure, you’d much rather move it than copy it. Again, however, C++11 gives you no way to accomplish that.

But that’s C++11. C++14 is a different story. It offers direct support for moving objects into closures. If your compilers are C++14-compliant, rejoice and read on. If you’re still working with C++11 compilers, you should rejoice and read on, too, because there are ways to approximate move capture in C++11.

The absence of move capture was recognized as a shortcoming even as C++11 was adopted. The straightforward remedy would have been to add it in C++14, but the Standardization Committee chose a different path. They introduced a new capture mechanism that’s so flexible, capture-by-move is only one of the tricks it can perform. The new capability is called *init capture*. It can do virtually everything the C++11 capture forms can do, plus more. The one thing you can’t express with an init capture is a default capture mode, but Item 31 explains that you should stay away from those, anyway. (For situations covered by C++11 captures, init capture’s syntax is a bit wordier, so in cases where a C++11 capture gets the job done, it’s perfectly reasonable to use it.)

Using an init capture makes it possible for you to specify

1\. **the name of a data member** in the closure class generated from the lambda and 2. **an expression** initializing that data member.

Here’s how you can use init capture to move a std::unique_ptr into a closure: class Widget { // some useful type

public:

…

bool isValidated() const;

bool isProcessed() const;

bool isArchived() const;

private:

…

};

**224 \| Item 32**

auto pw = std::make_unique\<Widget\>(); // create Widget; see

// Item 21 for info on

// std::make_unique

… // configure \*pw

auto func = \[**pw = std::move(pw)**\] // init data mbr

{ return pw-\>isValidated() // in closure w/

&& pw-\>isArchived(); }; // std::move(pw)

The highlighted text comprises the init capture. To the left of the “=” is the name of the data member in the closure class you’re specifying, and to the right is the initializing expression. Interestingly, the scope on the left of the “=” is different from the scope on the right. The scope on the left is that of the closure class. The scope on the right is the same as where the lambda is being defined. In the example above, the name pw on the left of the “=” refers to a data member in the closure class, while the name pw on the right refers to the object declared above the lambda, i.e., the variable initialized by the call to std::make_unique. So “pw = std::move(pw)” means “create a data member pw in the closure, and initialize that data member with the result of applying std::move to the local variable pw.”

As usual, code in the body of the lambda is in the scope of the closure class, so uses of pw there refer to the closure class data member.

The comment “configure \*pw” in this example indicates that after the Widget is created by std::make_unique and before the std::unique_ptr to that Widget is captured by the lambda, the Widget is modified in some way. If no such configuration is necessary, i.e., if the Widget created by std::make_unique is in a state suitable to be captured by the lambda, the local variable pw is unnecessary, because the closure class’s data member can be directly initialized by std::make_unique:

auto func = \[**pw = std::make_unique\<Widget\>()**\] // init data mbr

{ return pw-\>isValidated() // in closure w/

&& pw-\>isArchived(); }; // result of call

// to make_unique

This should make clear that the C++14 notion of “capture” is considerably generalized from C++11, because in C++11, it’s not possible to capture the result of an expression. As a result, another name for init capture is *generalized lambda capture*.

But what if one or more of the compilers you use lacks support for C++14’s init capture? How can you accomplish move capture in a language lacking support for move capture?

**Item 32 \| 225**

Remember that a lambda expression is simply a way to cause a class to be generated and an object of that type to be created. There is nothing you can do with a lambda that you can’t do by hand. The example C++14 code we just saw, for example, can be written in C++11 like this:

class IsValAndArch { // "is validated

public: // and archived"

using DataType = std::unique_ptr\<Widget\>;

explicit IsValAndArch(DataType&& ptr) // Item 25 explains

: pw(std::move(ptr)) {} // use of std::move

bool operator()() const

{ return pw-\>isValidated() && pw-\>isArchived(); }

private:

DataType pw;

};

auto func = IsValAndArch(std::make_unique\<Widget\>());

That’s more work than writing the lambda, but it doesn’t change the fact that if you want a class in C++11 that supports move-initialization of its data members, the only thing between you and your desire is a bit of time with your keyboard.

If you want to stick with lambdas (and given their convenience, you probably do), move capture can be emulated in C++11 by

1\. **moving the object to be captured into a function object produced by** **std::bind** and

2\. **giving the lambda a reference to the “captured” object**.

If you’re familiar with std::bind, the code is pretty straightforward. If you’re not familiar with std::bind, the code takes a little getting used to, but it’s worth the trouble.

Suppose you’d like to create a local std::vector, put an appropriate set of values into it, then move it into a closure. In C++14, this is easy:

**std::vector\<double\> data**; // object to be moved

// into closure

… // populate data

auto func = \[data = **std::move(data)**\] // C++14 init capture

{ /\* uses of data \*/ };

**226 \| Item 32**

I’ve highlighted key parts of this code: the type of object you want to move (std::vector\<double\>), the name of that object (data), and the initializing expression for the init capture (std::move(data)). The C++11 equivalent is as follows, where I’ve highlighted the same key things:

std::vector\<double\> data; // as above

… // as above

auto func =

std::bind( // C++11 emulation

\[\](**const std::vector\<double\>** & **data**) // of init capture

{ /\* uses of data \*/ },

**std::move(data)**

);

Like lambda expressions, std::bind produces function objects. I call function objects returned by std::bind *bind objects*. The first argument to std::bind is a callable object. Subsequent arguments represent values to be passed to that object.

A bind object contains copies of all the arguments passed to std::bind. For each lvalue argument, the corresponding object in the bind object is copy constructed. For each rvalue, it’s move constructed. In this example, the second argument is an rvalue (the result of std::move—see Item 23), so data is move constructed into the bind object. This move construction is the crux of move capture emulation, because moving an rvalue into a bind object is how we work around the inability to move an rvalue into a C++11 closure.

When a bind object is “called” (i.e., its function call operator is invoked) the arguments it stores are passed to the callable object originally passed to std::bind. In this example, that means that when func (the bind object) is called, the move-constructed copy of data inside func is passed as an argument to the lambda that was passed to std::bind.

This lambda is the same as the lambda we’d use in C++14, except a parameter, data, has been added to correspond to our pseudo-move-captured object. This parameter is an lvalue reference to the copy of data in the bind object. (It’s not an rvalue reference, because although the expression used to initialize the copy of data (“std::move(data)”) is an rvalue, the copy of data itself is an lvalue.) Uses of data inside the lambda will thus operate on the move-constructed copy of data inside the bind object.

By default, the operator() member function inside the closure class generated from a lambda is const. That has the effect of rendering all data members in the closure **Item 32 \| 227**

const within the body of the lambda. The move-constructed copy of data inside the bind object is not const, however, so to prevent that copy of data from being modified inside the lambda, the lambda’s parameter is declared reference-to-const. If the lambda were declared mutable, operator() in its closure class would not be declared const, and it would be appropriate to omit const in the lambda’s parameter declaration:

auto func =

std::bind( // C++11 emulation

\[\](**std::vector\<double\>&** data) **mutable** // of init capture

{ /\* uses of data \*/ }, // for mutable lambda

std::move(data)

);

Because a bind object stores copies of all the arguments passed to std::bind, the bind object in our example contains a copy of the closure produced by the lambda that is its first argument. The lifetime of the closure is therefore the same as the lifetime of the bind object. That’s important, because it means that as long as the closure exists, the bind object containing the pseudo-move-captured object exists, too.

If this is your first exposure to std::bind, you may need to consult your favorite C++11 reference before all the details of the foregoing discussion fall into place. Even if that’s the case, these fundamental points should be clear:

• It’s not possible to move-construct an object into a C++11 closure, but it is possible to move-construct an object into a C++11 bind object.

• Emulating move-capture in C++11 consists of move-constructing an object into a bind object, then passing the move-constructed object to the lambda by reference.

• Because the lifetime of the bind object is the same as that of the closure, it’s possible to treat objects in the bind object as if they were in the closure.

As a second example of using std::bind to emulate move capture, here’s the C++14

code we saw earlier to create a std::unique_ptr in a closure:

auto func = \[**pw** = **std::make_unique\<Widget\>()**\] // as before,

{ return pw-\>isValidated() // create pw

&& pw-\>isArchived(); }; // in closure

And here’s the C++11 emulation:

auto func = std::bind(

\[\](**const std::unique_ptr\<Widget\>** & **pw**)

{ return pw-\>isValidated()

&& pw-\>isArchived(); },

**228 \| Item 32**

**std::make_unique\<Widget\>()**

);

It’s ironic that I’m showing how to use std::bind to work around limitations in C++11 lambdas, because in Item 34, I advocate the use of lambdas over std::bind.

However, that Item explains that there are some cases in C++11 where std::bind can be useful, and this is one of them. (In C++14, features such as init capture and auto parameters eliminate those cases.)

**Things to Remember**

• Use C++14’s init capture to move objects into closures.

• In C++11, emulate init capture via hand-written classes or std::bind.

**Item 33: Use decltype on auto&& parameters to**

**std::forward them.**

One of the most exciting features of C++14 is *generic lambdas*—lambdas that use auto in their parameter specifications. The implementation of this feature is straightforward: operator() in the lambda’s closure class is a template. Given this lambda, for example,

auto f = \[\](**auto** x){ return func(normalize(x)); };

the closure class’s function call operator looks like this:

class *SomeCompilerGeneratedClassName* {

public:

**template\<typename T\>** // see Item 3 for auto operator()(**T** x) const // auto return type

{ return func(normalize(x)); }

… // other closure class

}; // functionality

In this example, the only thing the lambda does with its parameter x is forward it to normalize. If normalize treats lvalues differently from rvalues, this lambda isn’t written properly, because it always passes an lvalue (the parameter x) to normalize, even if the argument that was passed to the lambda was an rvalue.

The correct way to write the lambda is to have it perfect-forward x to normalize.

Doing that requires two changes to the code. First, x has to become a universal refer-Item 32 \| 229

ence (see Item 24), and second, it has to be passed to normalize via std::forward

(see Item 25). In concept, these are trivial modifications:

auto f = \[\](auto**&&** x)

{ return func(normalize(**std::forward\<???\>(**x**)**)); };

Between concept and realization, however, is the question of what type to pass to std::forward, i.e., to determine what should go where I’ve written ??? above.

Normally, when you employ perfect forwarding, you’re in a template function taking a type parameter T, so you just write std::forward\<T\>. In the generic lambda, though, there’s no type parameter T available to you. There is a T in the templatized operator() inside the closure class generated by the lambda, but it’s not possible to refer to it from the lambda, so it does you no good.

Item 28 explains that if an lvalue argument is passed to a universal reference parameter, the type of that parameter becomes an lvalue reference. If an rvalue is passed, the parameter becomes an rvalue reference. This means that in our lambda, we can determine whether the argument passed was an lvalue or an rvalue by inspecting the type of the parameter x. decltype gives us a way to do that (see Item 3). If an lvalue

was passed in, decltype(x) will produce a type that’s an lvalue reference. If an rvalue was passed, decltype(x) will produce an rvalue reference type.

Item 28 also explains that when calling std::forward, convention dictates that the type argument be an lvalue reference to indicate an lvalue and a non-reference to indicate an rvalue. In our lambda, if x is bound to an lvalue, decltype(x) will yield an lvalue reference. That conforms to convention. However, if x is bound to an rvalue, decltype(x) will yield an rvalue reference instead of the customary non-reference.

But look at the sample C++14 implementation for std::forward from Item 28:

template\<typename T\> // in namespace

T&& forward(remove_reference_t\<T\>& param) // std

{

return static_cast\<T&&\>(param);

}

If client code wants to perfect-forward an rvalue of type Widget, it normally instantiates std::forward with the type Widget (i.e, a non-reference type), and the std::forward template yields this function:

**Widget**&& forward(**Widget**& param) // instantiation of

{ // std::forward when

return static_cast\< **Widget**&&\>(param); // T is *Widget*

}

**230 \| Item 33**

But consider what would happen if the client code wanted to perfect-forward the same rvalue of type Widget, but instead of following the convention of specifying T to be a non-reference type, it specified it to be an rvalue reference. That is, consider what would happen if T were specified to be Widget&&. After initial instantiation of std::forward and application of std::remove_reference_t, but before reference

collapsing (once again, see Item 28), std::forward would look like this: **Widget&&** && forward(**Widget**& param) // instantiation of

{ // std::forward when

return static_cast\< **Widget&&** &&\>(param); // T is *Widget&&*

} // (before reference-

// collapsing)

Applying the reference-collapsing rule that an rvalue reference to an rvalue reference becomes a single rvalue reference, this instantiation emerges:

**Widget&&** forward(Widget& param) // instantiation of

{ // std::forward when

return static_cast\< **Widget&&** \>(param); // T is *Widget&&*

} // (after reference-

// collapsing)

If you compare this instantiation with the one that results when std::forward is called with T set to Widget, you’ll see that they’re identical. That means that instantiating std::forward with an rvalue reference type yields the same result as instantiat-ing it with a non-reference type.

That’s wonderful news, because decltype(x) yields an rvalue reference type when an rvalue is passed as an argument to our lambda’s parameter x. We established above that when an lvalue is passed to our lambda, decltype(x) yields the customary type to pass to std::forward, and now we realize that for rvalues, decltype(x) yields a type to pass to std::forward that’s not conventional, but that nevertheless yields the same outcome as the conventional type. So for both lvalues and rvalues, passing decltype(x) to std::forward gives us the result we want. Our perfect-forwarding lambda can therefore be written like this:

auto f =

\[\](auto&& param)

{

return

func(normalize(std::forward\< **decltype(param)**\>(param)));

};

From there, it’s just a hop, skip, and six dots to a perfect-forwarding lambda that accepts not just a single parameter, but any number of parameters, because C++14

lambdas can also be variadic:

**Item 33 \| 231**

auto f =

\[\](auto&& **...** params)

{

return

func(normalize(std::forward\<decltype(params)\>(params)**...** ));

};

**Things to Remember**

• Use decltype on auto&& parameters to std::forward them.

**Item 34: Prefer lambdas to std::bind.**

std::bind is the C++11 successor to C++98’s std::bind1st and std::bind2nd, but, informally, it’s been part of the Standard Library since 2005. That’s when the Standardization Committee adopted a document known as TR1, which included bind’s specification. (In TR1, bind was in a different namespace, so it was std::tr1::bind, not std::bind, and a few interface details were different.) This history means that some programmers have a decade or more of experience using std::bind. If you’re one of them, you may be reluctant to abandon a tool that’s served you well. That’s understandable, but in this case, change is good, because in C++11, lambdas are almost always a better choice than std::bind. As of C++14, the case for lambdas isn’t just stronger, it’s downright ironclad.

This Item assumes that you’re familiar with std::bind. If you’re not, you’ll want to acquire a basic understanding before continuing. Such an understanding is worthwhile in any case, because you never know when you might encounter uses of std::bind in a code base you have to read or maintain.

As in Item 32, I refer to the function objects returned from std::bind as *bind* *objects*.

The most important reason to prefer lambdas over std::bind is that lambdas are more readable. Suppose, for example, we have a function to set up an audible alarm:

// typedef for a point in time (see Item 9 for syntax) using Time = std::chrono::steady_clock::time_point;

// see Item 10 for "enum class"

enum class Sound { Beep, Siren, Whistle };

// typedef for a length of time

**232 \| Item 33**

using Duration = std::chrono::steady_clock::duration;

// *at time t, make sound s for duration d*

**void setAlarm(Time t, Sound s, Duration d);**

Further suppose that at some point in the program, we’ve determined we’ll want an alarm that will go off an hour after it’s set and that will stay on for 30 seconds. The alarm sound, however, remains undecided. We can write a lambda that revises setAlarm’s interface so that only a sound needs to be specified:

// setSoundL ("L" for "lambda") is a function object allowing a

// sound to be specified for a 30-sec alarm to go off an hour

// after it's set

auto setSoundL =

\[\](Sound s)

{

// make std::chrono components available w/o qualification

using namespace std::chrono;

**setAlarm(steady_clock::now() + hours(1),** // alarm to go off

**s,** // in an hour for

**seconds(30));** // 30 seconds

};

I’ve highlighted the call to setAlarm inside the lambda. This is a normal-looking function call, and even a reader with little lambda experience can see that the parameter s passed to the lambda is passed as an argument to setAlarm.

We can streamline this code in C++14 by availing ourselves of the standard suffixes for seconds (s), milliseconds (ms), hours (h), etc., that build on C++11’s support for user-defined literals. These suffixes are implemented in the std::literals namespace, so the above code can be rewritten as follows:

auto setSoundL =

\[\](Sound s)

{

using namespace std::chrono;

**using namespace std::literals;** // for C++14 suffixes

setAlarm(steady_clock::now() + **1h**, // C++14, but

s, // same meaning

**30s**); // as above

};

**Item 34 \| 233**

Our first attempt to write the corresponding std::bind call is below. It has an error that we’ll fix in a moment, but the correct code is more complicated, and even this simplified version brings out some important issues:

using namespace std::chrono; // as above

using namespace std::literals;

using namespace std::placeholders; // needed for use of "\_1"

auto setSoundB = // "B" for "bind"

std::bind(setAlarm,

steady_clock::now() + 1h, // *incorrect! see below*

\_1,

30s);

I’d like to highlight the call to setAlarm here as I did in the lambda, but there’s no call to highlight. Readers of this code simply have to know that calling setSoundB

invokes setAlarm with the time and duration specified in the call to std::bind. To the uninitiated, the placeholder “\_1” is essentially magic, but even readers in the know have to mentally map from the number in that placeholder to its position in the std::bind parameter list in order to understand that the first argument in a call to setSoundB is passed as the second argument to setAlarm. The type of this argument is not identified in the call to std::bind, so readers have to consult the setAlarm declaration to determine what kind of argument to pass to setSoundB.

But, as I said, the code isn’t quite right. In the lambda, it’s clear that the expression

“steady_clock::now() + 1h” is an argument to setAlarm. It will be evaluated when setAlarm is called. That makes sense: we want the alarm to go off an hour after invoking setAlarm. In the std::bind call, however, “steady_clock::now() + 1h”

is passed as an argument to std::bind, not to setAlarm. That means that the expression will be evaluated when std::bind is called, and the time resulting from that expression will be stored inside the resulting bind object. As a consequence, the alarm will be set to go off an hour *after the call to* *std::bind*, not an hour after the call to setAlarm!

Fixing the problem requires telling std::bind to defer evaluation of the expression until setAlarm is called, and the way to do that is to nest a second call to std::bind inside the first one:

auto setSoundB =

std::bind(setAlarm,

**std::bind(std::plus\<\>(), steady_clock::now(), 1h)**,

\_1,

30s);

**234 \| Item 34**

If you’re familiar with the std::plus template from C++98, you may be surprised to see that in this code, no type is specified between the angle brackets, i.e., the code contains “std::plus**\<\>** ”, not “std::plus**\<** *type***\>** ”. In C++14, the template type argument for the standard operator templates can generally be omitted, so there’s no need to provide it here. C++11 offers no such feature, so the C++11 std::bind equivalent to the lambda is:

using namespace std::chrono; // as above

using namespace std::placeholders;

auto setSoundB =

std::bind(setAlarm,

std::bind(std::plus\< **steady_clock::time_point**\>(),

steady_clock::now(),

hours(1)),

\_1,

seconds(30));

If, at this point, the lambda’s not looking a lot more attractive, you should probably have your eyesight checked.

When setAlarm is overloaded, a new issue arises. Suppose there’s an overload taking a fourth parameter specifying the alarm volume:

enum class Volume { Normal, Loud, LoudPlusPlus };

**void setAlarm(Time t, Sound s, Duration d, Volume v);**

The lambda continues to work as before, because overload resolution chooses the three-argument version of setAlarm:

auto setSoundL = // same as before

\[\](Sound s)

{

using namespace std::chrono;

setAlarm(steady_clock::now() + 1h, // fine, calls

s, // 3-arg version

30s); // of setAlarm

};

The std::bind call, on the other hand, now fails to compile:

auto setSoundB = // error! which

std::bind(setAlarm, // setAlarm?

std::bind(std::plus\<\>(),

steady_clock::now(),

**Item 34 \| 235**

1h),

\_1,

30s);

The problem is that compilers have no way to determine which of the two setAlarm functions they should pass to std::bind. All they have is a function name, and the name alone is ambiguous.

To get the std::bind call to compile, setAlarm must be cast to the proper function pointer type:

**using SetAlarm3ParamType = void(\*)(Time t, Sound s, Duration d);**

auto setSoundB = // now

std::bind(**static_cast\<SetAlarm3ParamType\>(**setAlarm**)**, // okay std::bind(std::plus\<\>(),

steady_clock::now(),

1h),

\_1,

30s);

But this brings up another difference between lambdas and std::bind. Inside the function call operator for setSoundL (i.e., the function call operator of the lambda’s closure class), the call to setAlarm is a normal function invocation that can be inlined by compilers in the usual fashion:

setSound**L**(Sound::Siren); // body of setAlarm may

// well be inlined here

The call to std::bind, however, passes a function pointer to setAlarm, and that means that inside the function call operator for setSoundB (i.e., the function call operator for the bind object), the call to setAlarm takes place through a function pointer. Compilers are less likely to inline function calls through function pointers, and that means that calls to setAlarm through setSoundB are less likely to be fully inlined than those through setSoundL:

setSound**B**(Sound::Siren); // body of setAlarm is less

// likely to be inlined here

It’s thus possible that using lambdas generates faster code than using std::bind.

The setAlarm example involves only a simple function call. If you want to do anything more complicated, the scales tip even further in favor of lambdas. For example, consider this C++14 lambda, which returns whether its argument is between a mini-mum value (lowVal) and a maximum value (highVal), where lowVal and highVal are local variables:

**236 \| Item 34**

auto betweenL =

\[lowVal, highVal\]

(const auto& val) // C++14

{ return lowVal \<= val && val \<= highVal; };

std::bind can express the same thing, but the construct is an example of job security through code obscurity:

using namespace std::placeholders; // as above

auto betweenB =

std::bind(std::logical_and\<\>(), // C++14

std::bind(std::less_equal\<\>(), lowVal, \_1),

std::bind(std::less_equal\<\>(), \_1, highVal));

In C++11, we’d have to specify the types we wanted to compare, and the std::bind call would then look like this:

auto betweenB = // C++11 version

std::bind(std::logical_and\< **bool**\>(),

std::bind(std::less_equal\< **int**\>(), lowVal, \_1),

std::bind(std::less_equal\< **int**\>(), \_1, highVal));

Of course, in C++11, the lambda couldn’t take an auto parameter, so it’d have to commit to a type, too:

auto betweenL = // C++11 version

\[lowVal, highVal\]

(**int val**)

{ return lowVal \<= val && val \<= highVal; };

Either way, I hope we can agree that the lambda version is not just shorter, but also more comprehensible and maintainable.

Earlier, I remarked that for those with little std::bind experience, its placeholders (e.g., \_1, \_2, etc.) are essentially magic. But it’s not just the behavior of the placeholders that’s opaque. Suppose we have a function to create compressed copies of Widgets,

enum class CompLevel { Low, Normal, High }; // compression

// level

Widget compress(const Widget& w, // make compressed

CompLevel lev); // copy of w

and we want to create a function object that allows us to specify how much a particular Widget w should be compressed. This use of std::bind will create such an object: **Item 34 \| 237**

Widget w;

using namespace std::placeholders;

auto compressRateB = std::bind(compress, w, \_1);

Now, when we pass w to std::bind, it has to be stored for the later call to compress.

It’s stored inside the object compressRateB, but how is it stored—by value or by reference? It makes a difference, because if w is modified between the call to std::bind and a call to compressRateB, storing w by reference will reflect the changes, while storing it by value won’t.

The answer is that it’s stored by value,1 but the only way to know that is to memorize how std::bind works; there’s no sign of it in the call to std::bind. Contrast that with a lambda approach, where whether w is captured by value or by reference is explicit:

auto compressRateL = // w is captured by

\[**w**\](CompLevel lev) // value; lev is

{ return compress(w, lev); }; // passed by value

Equally explicit is how parameters are passed to the lambda. Here, it’s clear that the parameter lev is passed by value. Hence:

compressRate**L**(CompLevel::High); // arg is passed

// by value

But in the call to the object resulting from std::bind, how is the argument passed?

compressRate**B**(CompLevel::High); // how is arg

// passed?

Again, the only way to know is to memorize how std::bind works. (The answer is that all arguments passed to bind objects are passed by reference, because the function call operator for such objects uses perfect forwarding.)

Compared to lambdas, then, code using std::bind is less readable, less expressive, and possibly less efficient. In C++14, there are no reasonable use cases for std::bind. In C++11, however, std::bind can be justified in two constrained situations:

1 std::bind always copies its arguments, but callers can achieve the effect of having an argument stored by reference by applying std::ref to it. The result of

auto compressRateB = std::bind(compress, **std::ref(**w**)**, \_1); is that compressRateB acts as if it holds a reference to w, rather than a copy.

**238 \| Item 34**

• **Move capture**. C++11 lambdas don’t offer move capture, but it can be emulated through a combination of a lambda and std::bind. For details, consult Item 32, which also explains that in C++14, lambdas’ support for init capture eliminates the need for the emulation.

• **Polymorphic function objects**. Because the function call operator on a bind object uses perfect forwarding, it can accept arguments of any type (modulo the restrictions on perfect forwarding described in Item 30). This can be useful when you want to bind an object with a templatized function call operator. For example, given this class,

class PolyWidget {

public:

**template\<typename T\>**

**void operator()(const T& param);**

…

};

std::bind can bind a PolyWidget as follows:

PolyWidget pw;

auto boundPW = std::bind(pw, \_1);

boundPW can then be called with different types of arguments:

boundPW(1930); // pass int to

// PolyWidget::operator()

boundPW(nullptr); // pass nullptr to

// PolyWidget::operator()

boundPW("Rosebud"); // pass string literal to

// PolyWidget::operator()

There is no way to do this with a C++11 lambda. In C++14, however, it’s easily achieved via a lambda with an auto parameter:

auto boundPW = \[pw\](const **auto**& param) // C++14

{ pw(param); };

These are edge cases, of course, and they’re transient edge cases at that, because compilers supporting C++14 lambdas are increasingly common.

When bind was unofficially added to C++ in 2005, it was a big improvement over its 1998 predecessors. The addition of lambda support to C++11 rendered std::bind all but obsolete, however, and as of C++14, there are just no good use cases for it.

**Item 34 \| 239**

**Things to Remember**

• Lambdas are more readable, more expressive, and may be more efficient than using std::bind.

• In C++11 only, std::bind may be useful for implementing move capture or for binding objects with templatized function call operators.

**240 \| Item 34**

**CHAPTER 7**