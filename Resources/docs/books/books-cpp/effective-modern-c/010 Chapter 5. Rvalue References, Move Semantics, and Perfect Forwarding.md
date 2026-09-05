**CHAPTER 5**

**Rvalue References, Move Semantics,**

**and Perfect Forwarding**

When you first learn about them, move semantics and perfect forwarding seem pretty straightforward:

• **Move semantics** makes it possible for compilers to replace expensive copying operations with less expensive moves. In the same way that copy constructors and copy assignment operators give you control over what it means to copy objects, move constructors and move assignment operators offer control over the semantics of moving. Move semantics also enables the creation of move-only types, such as std::unique_ptr, std::future, and std::thread.

• **Perfect forwarding** makes it possible to write function templates that take arbitrary arguments and forward them to other functions such that the target functions receive exactly the same arguments as were passed to the forwarding functions.

Rvalue references are the glue that ties these two rather disparate features together.

They’re the underlying language mechanism that makes both move semantics and perfect forwarding possible.

The more experience you have with these features, the more you realize that your initial impression was based on only the metaphorical tip of the proverbial iceberg. The world of move semantics, perfect forwarding, and rvalue references is more nuanced than it appears. std::move doesn’t move anything, for example, and perfect forwarding is imperfect. Move operations aren’t always cheaper than copying; when they are, they’re not always as cheap as you’d expect; and they’re not always called in a context where moving is valid. The construct “*type*&&” doesn’t always represent an rvalue reference.

**157**

No matter how far you dig into these features, it can seem that there’s always more to uncover. Fortunately, there is a limit to their depths. This chapter will take you to the bedrock. Once you arrive, this part of C++11 will make a lot more sense. You’ll know the usage conventions for std::move and std::forward, for example. You’ll be comfortable with the ambiguous nature of “*type*&&”. You’ll understand the reasons for the surprisingly varied behavioral profiles of move operations. All those pieces will fall into place. At that point, you’ll be back where you started, because move semantics, perfect forwarding, and rvalue references will once again seem pretty straightforward. But this time, they’ll stay that way.

In the Items in this chapter, it’s especially important to bear in mind that a parameter is always an lvalue, even if its type is an rvalue reference. That is, given void f(**Widget&& w**);

the parameter w is an lvalue, even though its type is rvalue-reference-to-Widget. (If

this surprises you, please review the overview of lvalues and rvalues that begins on

page 2.)

**Item 23: Understand std::move and std::forward.**

It’s useful to approach std::move and std::forward in terms of what they *don’t* do.

std::move doesn’t move anything. std::forward doesn’t forward anything. At runtime, neither does anything at all. They generate no executable code. Not a single byte.

std::move and std::forward are merely functions (actually function templates) that perform casts. std::move unconditionally casts its argument to an rvalue, while std::forward performs this cast only if a particular condition is fulfilled. That’s it.

The explanation leads to a new set of questions, but, fundamentally, that’s the complete story.

To make the story more concrete, here’s a sample implementation of std::move in C++11. It’s not fully conforming to the details of the Standard, but it’s very close.

template\<typename T\> // in namespace std

typename remove_reference\<T\>::type&&

**move**(T&& param)

{

using ReturnType = // alias declaration;

typename remove_reference\<T\>::type&&; // see Item 9

return **static_cast\<ReturnType\>(param)**;

}

**158 \| Item 22**

I’ve highlighted two parts of the code for you. One is the name of the function, because the return type specification is rather noisy, and I don’t want you to lose your bearings in the din. The other is the cast that comprises the essence of the function.

As you can see, std::move takes a reference to an object (a universal reference, to be

precise—see Item 24) and it returns a reference to the same object.

The “&&” part of the function’s return type implies that std::move returns an rvalue

reference, but, as Item 28 explains, if the type T happens to be an lvalue reference, T&& would become an lvalue reference. To prevent this from happening, the type trait (see

Item 9) std::remove_reference is applied to T, thus ensuring that “&&” is applied to a type that isn’t a reference. That guarantees that std::move truly returns an rvalue reference, and that’s important, because rvalue references returned from functions are rvalues. Thus, std::move casts its argument to an rvalue, and that’s all it does.

As an aside, std::move can be implemented with less fuss in C++14. Thanks to function return type deduction (see Item 3) and to the Standard Library’s alias template std::remove_reference_t (see Item 9), std::move can be written this way: template\<typename T\> // C++14; still in

**decltype(auto)** move(T&& param) // namespace std

{

using ReturnType = **remove_reference_t\<T\>** &&;

return static_cast\<ReturnType\>(param);

}

Easier on the eyes, no?

Because std::move does nothing but cast its argument to an rvalue, there have been suggestions that a better name for it might have been something like rvalue_cast.

Be that as it may, the name we have is std::move, so it’s important to remember what std::move does and doesn’t do. It does cast. It doesn’t move.

Of course, rvalues are candidates for moving, so applying std::move to an object tells the compiler that the object is eligible to be moved from. That’s why std::move has the name it does: to make it easy to designate objects that may be moved from.

In truth, rvalues are only *usually* candidates for moving. Suppose you’re writing a class representing annotations. The class’s constructor takes a std::string parameter comprising the annotation, and it copies the parameter to a data member. Flush

with the information in Item 41, you declare a by-value parameter:

class Annotation {

public:

explicit Annotation(**std::string** text); // param to be copied,

**Item 23 \| 159**

… // so per Item 41,

}; // pass by value

But Annotation’s constructor needs only to read text’s value. It doesn’t need to modify it. In accord with the time-honored tradition of using const whenever possible, you revise your declaration such that text is const:

class Annotation {

public:

explicit Annotation(**const** std::string text)

…

};

To avoid paying for a copy operation when copying text into a data member, you remain true to the advice of Item 41 and apply std::move to text, thus producing an rvalue:

class Annotation {

public:

explicit Annotation(const std::string text)

: value(**std::move(text)**) // "move" text into value; *this code*

{ … } // *doesn't do what it seems to!*

…


std::string value;

};

This code compiles. This code links. This code runs. This code sets the data member value to the content of text. The only thing separating this code from a perfect realization of your vision is that text is not moved into value, it’s *copied*. Sure, text is cast to an rvalue by std::move, but text is declared to be a const std::string, so before the cast, text is an lvalue const std::string, and the result of the cast is an rvalue const std::string, but throughout it all, the constness remains.

Consider the effect that has when compilers have to determine which std::string constructor to call. There are two possibilities:

class string { // std::string is actually a

public: // typedef for std::basic_string\<char\>

…

string(const string& rhs); // copy ctor

string(string&& rhs); // move ctor

…

};

**160 \| Item 23**

In the Annotation constructor’s member initialization list, the result of std::move(text) is an rvalue of type const std::string. That rvalue can’t be passed to std::string’s move constructor, because the move constructor takes an rvalue reference to a *non-const* std::string. The rvalue can, however, be passed to the copy constructor, because an lvalue-reference-to-const is permitted to bind to a const rvalue. The member initialization therefore invokes the *copy* constructor in std::string, even though text has been cast to an rvalue! Such behavior is essential to maintaining const-correctness. Moving a value out of an object generally modifies the object, so the language should not permit const objects to be passed to functions (such as move constructors) that could modify them.

There are two lessons to be drawn from this example. First, don’t declare objects const if you want to be able to move from them. Move requests on const objects are silently transformed into copy operations. Second, std::move not only doesn’t actually move anything, it doesn’t even guarantee that the object it’s casting will be eligible to be moved. The only thing you know for sure about the result of applying std::move to an object is that it’s an rvalue.

The story for std::forward is similar to that for std::move, but whereas std::move *unconditionally* casts its argument to an rvalue, std::forward does it only under certain conditions. std::forward is a *conditional* cast. To understand when it casts and when it doesn’t, recall how std::forward is typically used. The most common scenario is a function template taking a universal reference parameter that is to be passed to another function:

void process(const Widget& lvalArg); // process lvalues

void process(Widget&& rvalArg); // process rvalues

template\<typename T\> // template that passes

void logAndProcess(**T&& param**) // param to process

{

auto now = // get current time

std::chrono::system_clock::now();

makeLogEntry("Calling 'process'", now);

process(**std::forward\<T\>(param)**);

}

Consider two calls to logAndProcess, one with an lvalue, the other with an rvalue: Widget w;

logAndProcess(w); // call with lvalue

logAndProcess(std::move(w)); // call with rvalue

**Item 23 \| 161**

Inside logAndProcess, the parameter param is passed to the function process. pro cess is overloaded for lvalues and rvalues. When we call logAndProcess with an lvalue, we naturally expect that lvalue to be forwarded to process as an lvalue, and when we call logAndProcess with an rvalue, we expect the rvalue overload of pro cess to be invoked.

But param, like all function parameters, is an lvalue. Every call to process inside logAndProcess will thus want to invoke the lvalue overload for process. To prevent this, we need a mechanism for param to be cast to an rvalue if and only if the argument with which param was initialized—the argument passed to logAndProcess—

was an rvalue. This is precisely what std::forward does. That’s why std::forward is a *conditional* cast: it casts to an rvalue only if its argument was initialized with an rvalue.

You may wonder how std::forward can know whether its argument was initialized with an rvalue. In the code above, for example, how can std::forward tell whether param was initialized with an lvalue or an rvalue? The brief answer is that that information is encoded in logAndProcess’s template parameter T. That parameter is passed to std::forward, which recovers the encoded information. For details on exactly how that works, consult Item 28.

Given that both std::move and std::forward boil down to casts, the only difference being that std::move always casts, while std::forward only sometimes does, you might ask whether we can dispense with std::move and just use std::forward everywhere. From a purely technical perspective, the answer is yes: std::forward can do it all. std::move isn’t necessary. Of course, neither function is really *necessary*, because we could write casts everywhere, but I hope we agree that that would be, well, yucky.

std::move’s attractions are convenience, reduced likelihood of error, and greater clarity. Consider a class where we want to track how many times the move constructor is called. A static counter that’s incremented during move construction is all we need. Assuming the only non-static data in the class is a std::string, here’s the conventional way (i.e., using std::move) to implement the move constructor: class Widget {

public:

Widget(Widget&& rhs)

: s(**std::move**(rhs.s))

{ ++moveCtorCalls; }

…

**162 \| Item 23**


static std::size_t moveCtorCalls;

std::string s;

};

To implement the same behavior with std::forward, the code would look like this: class Widget {

public:

Widget(Widget&& rhs) // unconventional,

: s(**std::forward\<std::string\>** (rhs.s)) // *undesirable*

{ ++moveCtorCalls; } // implementation

…

};

Note first that std::move requires only a function argument (rhs.s), while std::forward requires both a function argument (rhs.s) and a template type argument (std::string). Then note that the type we pass to std::forward should be a non-reference, because that’s the convention for encoding that the argument being

passed is an rvalue (see Item 28). Together, this means that std::move requires less typing than std::forward, and it spares us the trouble of passing a type argument that encodes that the argument we’re passing is an rvalue. It also eliminates the possibility of our passing an incorrect type (e.g., std::string&, which would result in the data member s being copy constructed instead of move constructed).

More importantly, the use of std::move conveys an unconditional cast to an rvalue, while the use of std::forward indicates a cast to an rvalue only for references to which rvalues have been bound. Those are two very different actions. The first one typically sets up a move, while the second one just passes— *forwards*—an object to another function in a way that retains its original lvalueness or rvalueness. Because these actions are so different, it’s good that we have two different functions (and function names) to distinguish them.

**Things to Remember**

• std::move performs an unconditional cast to an rvalue. In and of itself, it doesn’t move anything.

• std::forward casts its argument to an rvalue only if that argument is bound to an rvalue.

• Neither std::move nor std::forward do anything at runtime.

**Item 23 \| 163**

**Item 24: Distinguish universal references from rvalue** **references.**

It’s been said that the truth shall set you free, but under the right circumstances, a well-chosen lie can be equally liberating. This Item is such a lie. Because we’re dealing with software, however, let’s eschew the word “lie” and instead say that this Item comprises an “abstraction.”

To declare an rvalue reference to some type T, you write T&&. It thus seems reasonable to assume that if you see “T&&” in source code, you’re looking at an rvalue reference. Alas, it’s not quite that simple:

void f(Widget**&&** param); // rvalue reference Widget**&&** var1 = Widget(); // rvalue reference auto**&&** var2 = var1; // *not* rvalue reference template\<typename T\>

void f(std::vector\<T\> **&&** param); // rvalue reference template\<typename T\>

void f(T**&&** param); // *not* rvalue reference In fact, “T&&” has two different meanings. One is rvalue reference, of course. Such references behave exactly the way you expect: they bind only to rvalues, and their primary *raison d’être* is to identify objects that may be moved from.

The other meaning for “T&&” is *either* rvalue reference *or* lvalue reference. Such references look like rvalue references in the source code (i.e., “T&&”), but they can behave as if they were lvalue references (i.e., “T&”). Their dual nature permits them to bind to rvalues (like rvalue references) as well as lvalues (like lvalue references). Furthermore, they can bind to const or non-const objects, to volatile or non-volatile objects, even to objects that are both const and volatile. They can bind to virtually *anything*. Such unprecedentedly flexible references deserve a name of their own. I call them *universal references*.1

Universal references arise in two contexts. The most common is function template parameters, such as this example from the sample code above:

1 Item 25 explains that universal references should almost always have std::forward applied to them, and as this book goes to press, some members of the C++ community have started referring to universal references as *forwarding references*.

**164 \| Item 24**


void f(T**&&** param); // param is a universal reference The second context is auto declarations, including this one from the sample code above:

auto**&&** var2 = var1; // var2 is a universal reference What these contexts have in common is the presence of *type deduction*. In the template f, the type of param is being deduced, and in the declaration for var2, var2’s type is being deduced. Compare that with the following examples (also from the sample code above), where type deduction is missing. If you see “T&&” without type deduction, you’re looking at an rvalue reference:

void f(Widget**&&** param); // no type deduction;

// param is an rvalue reference

Widget**&&** var1 = Widget(); // no type deduction;

// var1 is an rvalue reference

Because universal references are references, they must be initialized. The initializer for a universal reference determines whether it represents an rvalue reference or an lvalue reference. If the initializer is an rvalue, the universal reference corresponds to an rvalue reference. If the initializer is an lvalue, the universal reference corresponds to an lvalue reference. For universal references that are function parameters, the initializer is provided at the call site:


void f(T&& param); // param is a universal reference

Widget w;

f(**w**); // lvalue passed to f; param's type is

// Widget& (i.e., an lvalue reference)

f(**std::move(w)**); // rvalue passed to f; param's type is

// Widget&& (i.e., an rvalue reference)

For a reference to be universal, type deduction is necessary, but it’s not sufficient. The *form* of the reference declaration must also be correct, and that form is quite constrained. It must be precisely “T&&”. Look again at this example from the sample code we saw earlier:


void f(**std::vector\<T\>&&** param); // param is an rvalue reference When f is invoked, the type T will be deduced (unless the caller explicitly specifies it, an edge case we’ll not concern ourselves with). But the form of param’s type declara-Item 24 \| 165

tion isn’t “T&&”, it’s “std::vector\<T\>&&”. That rules out the possibility that param is a universal reference. param is therefore an rvalue reference, something that your compilers will be happy to confirm for you if you try to pass an lvalue to f: std::vector\<int\> v;

f(v); // error! can't bind lvalue to

// rvalue reference

Even the simple presence of a const qualifier is enough to disqualify a reference from being universal:


void f(**const** T&& param); // param is an rvalue reference If you’re in a template and you see a function parameter of type “T&&”, you might think you can assume that it’s a universal reference. You can’t. That’s because being in a template doesn’t guarantee the presence of type deduction. Consider this push_back member function in std::vector:

template\<class T, class Allocator = allocator\<T\>\> // from C++

class vector { // Standards

public:

void push_back(**T&&** x);

…

};

push_back’s parameter certainly has the right form for a universal reference, but there’s no type deduction in this case. That’s because push_back can’t exist without a particular vector instantiation for it to be part of, and the type of that instantiation fully determines the declaration for push_back. That is, saying

std::vector\<Widget\> v;

causes the std::vector template to be instantiated as follows:

class vector\<Widget, allocator\<Widget\>\> {

public:

void push_back(**Widget&&** x); // rvalue reference

…

};

Now you can see clearly that push_back employs no type deduction. This push_back for vector\<T\> (there are two—the function is overloaded) always declares a parameter of type rvalue-reference-to-T.

In contrast, the conceptually similar emplace_back member function in std::vec tor *does* employ type deduction:

**166 \| Item 24**

template\<class T, class Allocator = allocator\<T\>\> // still from class vector { // C++

public: // Standards

template \<class... Args\>

void emplace_back(**Args&&** ... args);

…

};

Here, the type parameter Args is independent of vector’s type parameter T, so Args must be deduced each time emplace_back is called. (Okay, Args is really a parameter pack, not a type parameter, but for purposes of this discussion, we can treat it as if it were a type parameter.)

The fact that emplace_back’s type parameter is named Args, yet it’s still a universal reference, reinforces my earlier comment that it’s the *form* of a universal reference that must be “T&&”. There’s no requirement that you use the name T. For example, the following template takes a universal reference, because the form (“*type*&&”) is right, and param’s type will be deduced (again, excluding the corner case where the caller explicitly specifies the type):

template\<typename MyTemplateType\> // param is a

void someFunc(**MyTemplateType&&** param); // universal reference I remarked earlier that auto variables can also be universal references. To be more precise, variables declared with the type auto&& are universal references, because type deduction takes place and they have the correct form (“T&&”). auto universal references are not as common as universal references used for function template parameters, but they do crop up from time to time in C++11. They crop up a lot more in C++14, because C++14 lambda expressions may declare auto&& parameters. For example, if you wanted to write a C++14 lambda to record the time taken in an arbitrary function invocation, you could do this:

auto timeFuncInvocation =

\[\](**auto&&** func, **auto&&** ... params) // C++14

{

*start timer;*

std::forward\<decltype(func)\>(func)( // invoke func

std::forward\<decltype(params)\>(params)... // on params

);

*stop timer and record elapsed time;*

};

If your reaction to the “std::forward\<decltype( *blah* *blah* *blah*)\>” code inside the lambda is, “What the…?!”, that probably just means you haven’t yet read Item 33.

Don’t worry about it. The important thing in this Item is the auto&& parameters that **Item 24 \| 167**

the lambda declares. func is a universal reference that can be bound to any callable object, lvalue or rvalue. args is zero or more universal references (i.e., a universal reference parameter pack) that can be bound to any number of objects of arbitrary types. The result, thanks to auto universal references, is that timeFuncInvocation can time pretty much any function execution. (For information on the difference

between “any” and “pretty much any,” turn to Item 30.)

Bear in mind that this entire Item—the foundation of universal references—is a lie…

er, an “abstraction.” The underlying truth is known as *reference collapsing*, a topic to

which Item 28 is dedicated. But the truth doesn’t make the abstraction any less useful.

Distinguishing between rvalue references and universal references will help you read source code more accurately (“Does that T&& I’m looking at bind to rvalues only or to everything?”), and it will avoid ambiguities when you communicate with your colleagues (“I’m using a universal reference here, not an rvalue reference…”). It will also allow you to make sense of Items 25 and 26, which rely on the distinction. So embrace the abstraction. Revel in it. Just as Newton’s laws of motion (which are technically incorrect) are typically just as useful as and easier to apply than Einstein’s theory of general relativity (“the truth”), so is the notion of universal references normally preferable to working through the details of reference collapsing.

**Things to Remember**

• If a function template parameter has type T&& for a deduced type T, or if an object is declared using auto&&, the parameter or object is a universal reference.

• If the form of the type declaration isn’t precisely *type*&&, or if type deduction does not occur, *type*&& denotes an rvalue reference.

• Universal references correspond to rvalue references if they’re initialized with rvalues. They correspond to lvalue references if they’re initialized with lvalues.

**Item 25: Use std::move on rvalue references,**

**std::forward on universal references.**

Rvalue references bind only to objects that are candidates for moving. If you have an rvalue reference parameter, you *know* that the object it’s bound to may be moved: class Widget {

Widget(**Widget&&** rhs); // rhs *definitely* refers to an **168 \| Item 24**

… // object eligible for moving

};

That being the case, you’ll want to pass such objects to other functions in a way that permits those functions to take advantage of the object’s rvalueness. The way to do that is to cast parameters bound to such objects to rvalues. As Item 23 explains, that’s not only what std::move does, it’s what it was created for:


public:

Widget(Widget&& rhs) // rhs is rvalue reference

: name(**std::move(rhs.name)**),

p(**std::move(rhs.p)**)

{ … }

…


std::string name;

std::shared_ptr\<SomeDataStructure\> p;

};

A universal reference, on the other hand (see Item 24), *might* be bound to an object that’s eligible for moving. Universal references should be cast to rvalues only if they

were initialized with rvalues. Item 23 explains that this is precisely what std::for ward does:


public:


void setName(T&& newName) // newName is

{ name = **std::forward\<T\>(newName)**; } // universal reference

…

};

In short, rvalue references should be *unconditionally cast* to rvalues (via std::move) when forwarding them to other functions, because they’re *always* bound to rvalues, and universal references should be *conditionally cast* to rvalues (via std::forward) when forwarding them, because they’re only *sometimes* bound to rvalues.

Item 23 explains that using std::forward on rvalue references can be made to exhibit the proper behavior, but the source code is wordy, error-prone, and unidiomatic, so you should avoid using std::forward with rvalue references. Even worse is the idea of using std::move with universal references, because that can have the effect of unexpectedly modifying lvalues (e.g., local variables):

**Item 25 \| 169**


public:


void setName(**T&&** newName) // universal reference

{ name = **std::move(newName)**; } // compiles, but is

… // *bad, bad, bad!*


std::string name;

std::shared_ptr\<SomeDataStructure\> p;

};

std::string getWidgetName(); // factory function

Widget w;

auto n = getWidgetName(); // n is local variable

w.setName(n); // *moves* n into w!

… // n's value now unknown

Here, the local variable n is passed to w.setName, which the caller can be forgiven for assuming is a read-only operation on n. But because setName internally uses std::move to unconditionally cast its reference parameter to an rvalue, n’s value will be moved into w.name, and n will come back from the call to setName with an unspecified value. That’s the kind of behavior that can drive callers to despair—possibly to violence.

You might argue that setName shouldn’t have declared its parameter to be a universal reference. Such references can’t be const (see Item 24), yet setName surely shouldn’t modify its parameter. You might point out that if setName had simply been overloaded for const lvalues and for rvalues, the whole problem could have been avoided. Like this:


public:

void setName(**const std::string&** newName) // set from

{ name = newName; } // const lvalue

void setName(**std::string&&** newName) // set from

{ name = std::move(newName); } // rvalue

…

};

**170 \| Item 25**

That would certainly work in this case, but there are drawbacks. First, it’s more source code to write and maintain (two functions instead of a single template). Second, it can be less efficient. For example, consider this use of setName: w.setName("Adela Novak");

With the version of setName taking a universal reference, the string literal "Adela Novak" would be passed to setName, where it would be conveyed to the assignment operator for the std::string inside w. w’s name data member would thus be assigned directly from the string literal; no temporary std::string objects would arise. With the overloaded versions of setName, however, a temporary std::string object would be created for setName’s parameter to bind to, and this temporary std::string would then be moved into w’s data member. A call to setName would thus entail execution of one std::string constructor (to create the temporary), one std::string move assignment operator (to move newName into w.name), and one std::string destructor (to destroy the temporary). That’s almost certainly a more expensive execution sequence than invoking only the std::string assignment operator taking a const char\* pointer. The additional cost is likely to vary from implementation to implementation, and whether that cost is worth worrying about will vary from application to application and library to library, but the fact is that replacing a template taking a universal reference with a pair of functions overloaded on lvalue references and rvalue references is likely to incur a runtime cost in some cases.

If we generalize the example such that Widget’s data member may be of an arbitrary type (rather than knowing that it’s std::string), the performance gap can widen considerably, because not all types are as cheap to move as std::string (see

Item 29).

The most serious problem with overloading on lvalues and rvalues, however, isn’t the volume or idiomaticity of the source code, nor is it the code’s runtime performance.

It’s the poor scalability of the design. Widget::setName takes only one parameter, so only two overloads are necessary, but for functions taking more parameters, each of which could be an lvalue or an rvalue, the number of overloads grows geometrically: *n* parameters necessitates 2 *n* overloads. And that’s not the worst of it. Some functions

—function templates, actually—take an *unlimited* number of parameters, each of which could be an lvalue or rvalue. The poster children for such functions are std::make_shared, and, as of C++14, std::make_unique (see Item 21). Check out

the declarations of their most commonly used overloads:

template\<class T, class... Args\> // from C++11

shared_ptr\<T\> make_shared(**Args&&...** args); // Standard template\<class T, class... Args\> // from C++14

unique_ptr\<T\> make_unique(**Args&&...** args); // Standard **Item 25 \| 171**

For functions like these, overloading on lvalues and rvalues is not an option: universal references are the only way to go. And inside such functions, I assure you, std::forward is applied to the universal reference parameters when they’re passed to other functions. Which is exactly what you should do.

Well, usually. Eventually. But not necessarily initially. In some cases, you’ll want to use the object bound to an rvalue reference or a universal reference more than once in a single function, and you’ll want to make sure that it’s not moved from until you’re otherwise done with it. In that case, you’ll want to apply std::move (for rvalue references) or std::forward (for universal references) to only the *final* use of the reference. For example:

template\<typename T\> // text is

void setSignText(T&& text) // univ. reference

{

sign.setText(**text**); // use text, but

// don't modify it

auto now = // get current time

std::chrono::system_clock::now();

signHistory.add(now,

std::forward\<T\>(**text**)); // conditionally cast

} // text to rvalue

Here, we want to make sure that text’s value doesn’t get changed by sign.setText, because we want to use that value when we call signHistory.add. Ergo the use of std::forward on only the final use of the universal reference.

For std::move, the same thinking applies (i.e., apply std::move to an rvalue reference the last time it’s used), but it’s important to note that in rare cases, you’ll want to call std::move_if_noexcept instead of std::move. To learn when and why, consult

Item 14.

If you’re in a function that returns *by value*, and you’re returning an object bound to an rvalue reference or a universal reference, you’ll want to apply std::move or std::forward when you return the reference. To see why, consider an operator+

function to add two matrices together, where the left-hand matrix is known to be an rvalue (and can hence have its storage reused to hold the sum of the matrices): **Matrix** // by-value return operator+(**Matrix&& lhs**, const Matrix& rhs)

{

lhs += rhs;

**172 \| Item 25**

return **std::move(lhs)**; // *move* lhs into

} // return value

By casting lhs to an rvalue in the return statement (via std::move), lhs will be moved into the function’s return value location. If the call to std::move were omitted,

Matrix // as above

operator+(Matrix&& lhs, const Matrix& rhs)

{

lhs += rhs;

return **lhs**; // *copy* lhs into

} // return value

the fact that lhs is an lvalue would force compilers to instead *copy* it into the return value location. Assuming that the Matrix type supports move construction, which is more efficient than copy construction, using std::move in the return statement yields more efficient code.

If Matrix does not support moving, casting it to an rvalue won’t hurt, because the rvalue will simply be copied by Matrix’s copy constructor (see Item 23). If Matrix is later revised to support moving, operator+ will automatically benefit the next time it is compiled. That being the case, there’s nothing to be lost (and possibly much to be gained) by applying std::move to rvalue references being returned from functions that return by value.

The situation is similar for universal references and std::forward. Consider a function template reduceAndCopy that takes a possibly unreduced Fraction object, reduces it, and then returns a copy of the reduced value. If the original object is an rvalue, its value should be moved into the return value (thus avoiding the expense of making a copy), but if the original is an lvalue, an actual copy must be created.

Hence:


**Fraction** // by-value return

reduceAndCopy(**T&&** frac) // universal reference param

{

frac.reduce();

return **std::forward\<T\>(frac)**; // move rvalue into return

} // value, copy lvalue

If the call to std::forward were omitted, frac would be unconditionally copied into reduceAndCopy’s return value.

Some programmers take the information above and try to extend it to situations where it doesn’t apply. “If using std::move on an rvalue reference parameter being **Item 25 \| 173**

copied into a return value turns a copy construction into a move construction,” they reason, “I can perform the same optimization on local variables that I’m returning.”

In other words, they figure that given a function returning a local variable by value, such as this,

Widget makeWidget() // "Copying" version of makeWidget

{

**Widget w;** // local variable

… // configure w

**return w;** // "copy" w into return value

}

they can “optimize” it by turning the “copy” into a move:

Widget makeWidget() // Moving version of makeWidget

{

**Widget w;**

…

return **std::move(w)**; // move w into return value

} // ( *don't do this!)*

My liberal use of quotation marks should tip you off that this line of reasoning is flawed. But why is it flawed?

It’s flawed, because the Standardization Committee is way ahead of such programmers when it comes to this kind of optimization. It was recognized long ago that the

“copying” version of makeWidget can avoid the need to copy the local variable w by constructing it in the memory alloted for the function’s return value. This is known as the *return value optimization* (RVO), and it’s been expressly blessed by the C++

Standard for as long as there’s been one.

Wording such a blessing is finicky business, because you want to permit such *copy* *elision* only in places where it won’t affect the observable behavior of the software.

Paraphrasing the legalistic (arguably toxic) prose of the Standard, this particular blessing says that compilers may elide the copying (or moving) of a local object2 in a function that returns by value if (1) the type of the local object is the same as that returned by the function and (2) the local object is what’s being returned. With that in mind, look again at the “copying” version of makeWidget:

2 Eligible local objects include most local variables (such as w inside makeWidget) as well as temporary objects created as part of a return statement. Function parameters don’t qualify. Some people draw a distinction between application of the RVO to named and unnamed (i.e., temporary) local objects, limiting the term RVO to unnamed objects and calling its application to named objects the *named return value optimization* (NRVO).

**174 \| Item 25**

Widget makeWidget() // "Copying" version of makeWidget

{

**Widget w;**

…

**return w;** // "copy" w into return value

}

Both conditions are fulfilled here, and you can trust me when I tell you that for this code, every decent C++ compiler will employ the RVO to avoid copying w. That means that the “copying” version of makeWidget doesn’t, in fact, copy anything.

The moving version of makeWidget does just what its name says it does (assuming Widget offers a move constructor): it moves the contents of w into makeWidget’s return value location. But why don’t compilers use the RVO to eliminate the move, again constructing w in the memory alloted for the function’s return value? The answer is simple: they can’t. Condition (2) stipulates that the RVO may be performed only if what’s being returned is a local object, but that’s not what the moving version of makeWidget is doing. Look again at its return statement:

return **std::move(w)**;

What’s being returned here isn’t the local object w, it’s *a reference to* *w*—the result of std::move(w). Returning a reference to a local object doesn’t satisfy the conditions required for the RVO, so compilers must move w into the function’s return value location. Developers trying to help their compilers optimize by applying std::move to a local variable that’s being returned are actually limiting the optimization options available to their compilers!

But the RVO is an optimization. Compilers aren’t *required* to elide copy and move operations, even when they’re permitted to. Maybe you’re paranoid, and you worry that your compilers will punish you with copy operations, just because they can. Or perhaps you’re insightful enough to recognize that there are cases where the RVO is difficult for compilers to implement, e.g., when different control paths in a function return different local variables. (Compilers would have to generate code to construct the appropriate local variable in the memory allotted for the function’s return value, but how could compilers determine which local variable would be appropriate?) If so, you might be willing to pay the price of a move as insurance against the cost of a copy. That is, you might still think it’s reasonable to apply std::move to a local object you’re returning, simply because you’d rest easy knowing you’d never pay for a copy.

In that case, applying std::move to a local object would *still* be a bad idea. The part of the Standard blessing the RVO goes on to say that if the conditions for the RVO

are met, but compilers choose not to perform copy elision, the object being returned *must be treated as an rvalue*. In effect, the Standard requires that when the RVO is **Item 25 \| 175**

permitted, either copy elision takes place or std::move is implicitly applied to local objects being returned. So in the “copying” version of makeWidget,

Widget makeWidget() // as before

{

Widget w;

…

return w;

}

compilers must either elide the copying of w or they must treat the function as if it were written like this:

Widget makeWidget()

{

Widget w;

…

return **std::move(w)**; // treat w as rvalue, because

} // no copy elision was performed

The situation is similar for by-value function parameters. They’re not eligible for copy elision with respect to their function’s return value, but compilers must treat them as rvalues if they’re returned. As a result, if your source code looks like this, **Widget** makeWidget(**Widget w**) // by-value parameter of same

{ // type as function's return

…

**return w**;

}

compilers must treat it as if it had been written this way:

Widget makeWidget(Widget w)

{

…

return **std::move(w)**; // treat w as rvalue

}

This means that if you use std::move on a local object being returned from a function that’s returning by value, you can’t help your compilers (they have to treat the local object as an rvalue if they don’t perform copy elision), but you can certainly hinder them (by precluding the RVO). There are situations where applying std::move to a local variable can be a reasonable thing to do (i.e., when you’re passing it to a function and you know you won’t be using the variable any longer), but as part of a return statement that would otherwise qualify for the RVO or that returns a by-value parameter isn’t among them.

**176 \| Item 25**

**Things to Remember**

• Apply std::move to rvalue references and std::forward to universal references the last time each is used.

• Do the same thing for rvalue references and universal references being returned from functions that return by value.

• Never apply std::move or std::forward to local objects if they would otherwise be eligible for the return value optimization.

**Item 26: Avoid overloading on universal references.**

Suppose you need to write a function that takes a name as a parameter, logs the current date and time, then adds the name to a global data structure. You might come up with a function that looks something like this:

std::multiset\<std::string\> names; // global data structure

void logAndAdd(const std::string& name)

{

auto now = // get current time

std::chrono::system_clock::now();

log(now, "logAndAdd"); // make log entry

names.emplace(name); // add name to global data

} // structure; see Item 42

// for info on emplace

This isn’t unreasonable code, but it’s not as efficient as it could be. Consider three potential calls:

std::string petName("Darla");

logAndAdd(**petName**); // pass lvalue std::string logAndAdd(**std::string("Persephone")**); // pass rvalue std::string logAndAdd(**"Patty Dog"** ); // pass string literal In the first call, logAndAdd’s parameter name is bound to the variable petName.

Within logAndAdd, name is ultimately passed to names.emplace. Because name is an lvalue, it is copied into names. There’s no way to avoid that copy, because an lvalue (petName) was passed into logAndAdd.

**Item 25 \| 177**

In the second call, the parameter name is bound to an rvalue (the temporary std::string explicitly created from "Persephone"). name itself is an lvalue, so it’s copied into names, but we recognize that, in principle, its value could be moved into names. In this call, we pay for a copy, but we should be able to get by with only a move.

In the third call, the parameter name is again bound to an rvalue, but this time it’s to a temporary std::string that’s implicitly created from "Patty Dog". As in the second call, name is copied into names, but in this case, the argument originally passed to logAndAdd was a string literal. Had that string literal been passed directly to emplace, there would have been no need to create a temporary std::string at all.

Instead, emplace would have used the string literal to create the std::string object directly inside the std::multiset. In this third call, then, we’re paying to copy a std::string, yet there’s really no reason to pay even for a move, much less a copy.

We can eliminate the inefficiencies in the second and third calls by rewriting logAndAdd to take a universal reference (see Item 24) and, in accord with Item 25, std::forwarding this reference to emplace. The results speak for themselves: **template\<typename T\>**

void logAndAdd(**T&&** name)

{

auto now = std::chrono::system_clock::now();

log(now, "logAndAdd");

names.emplace(**std::forward\<T\>(**name**)**);

}

std::string petName("Darla"); // as before

logAndAdd(**petName**); // as before, copy

// lvalue into multiset

logAndAdd(**std::string("Persephone")**); // *move* rvalue instead

// of copying it

logAndAdd(**"Patty Dog"** ); // *create std::string*

// *in multiset* instead

// of copying a temporary

// std::string

Hurray, optimal efficiency!

Were this the end of the story, we could stop here and proudly retire, but I haven’t told you that clients don’t always have direct access to the names that logAndAdd **178 \| Item 26**

requires. Some clients have only an index that logAndAdd uses to look up the corresponding name in a table. To support such clients, logAndAdd is overloaded: std::string nameFromIdx(int idx); // return name

// corresponding to idx

void logAndAdd(**int idx**) // new overload

{

auto now = std::chrono::system_clock::now();

log(now, "logAndAdd");

names.emplace(**nameFromIdx(idx)**);

}

Resolution of calls to the two overloads works as expected:

std::string petName("Darla"); // as before

logAndAdd(petName); // as before, these

logAndAdd(std::string("Persephone")); // calls all invoke

logAndAdd("Patty Dog"); // the T&& overload logAndAdd(22); // calls int overload

Actually, resolution works as expected only if you don’t expect too much. Suppose a client has a short holding an index and passes that to logAndAdd:

short nameIdx;

… // give nameIdx a value

logAndAdd(nameIdx); // error!

The comment on the last line isn’t terribly illuminating, so let me explain what happens here.

There are two logAndAdd overloads. The one taking a universal reference can deduce T to be short, thus yielding an exact match. The overload with an int parameter can match the short argument only with a promotion. Per the normal overload resolution rules, an exact match beats a match with a promotion, so the universal reference overload is invoked.

Within that overload, the parameter name is bound to the short that’s passed in.

name is then std::forwarded to the emplace member function on names (a

std::multiset\<std::string\>), which, in turn, dutifully forwards it to the std::string constructor. There is no constructor for std::string that takes a short, so the std::string constructor call inside the call to multiset::emplace **Item 26 \| 179**

inside the call to logAndAdd fails. All because the universal reference overload was a better match for a short argument than an int.

Functions taking universal references are the greediest functions in C++. They instantiate to create exact matches for almost any type of argument. (The few kinds of

arguments where this isn’t the case are described in Item 30.) This is why combining overloading and universal references is almost always a bad idea: the universal reference overload vacuums up far more argument types than the developer doing the overloading generally expects.

An easy way to topple into this pit is to write a perfect forwarding constructor. A small modification to the logAndAdd example demonstrates the problem. Instead of writing a free function that can take either a std::string or an index that can be used to look up a std::string, imagine a class Person with constructors that do the same thing:


public:


explicit Person(T&& n) // perfect forwarding ctor;

: name(std::forward\<T\>(n)) {} // initializes data member

explicit Person(int idx) // int ctor

: name(nameFromIdx(idx)) {}

…


std::string name;

};

As was the case with logAndAdd, passing an integral type other than int (e.g., std::size_t, short, long, etc.) will call the universal reference constructor overload instead of the int overload, and that will lead to compilation failures. The problem here is much worse, however, because there’s more overloading present in Person than meets the eye. Item 17 explains that under the appropriate conditions, C++ will generate both copy and move constructors, and this is true even if the class contains a templatized constructor that could be instantiated to produce the signature of the copy or move constructor. If the copy and move constructors for Person are thus generated, Person will effectively look like this:


public:

template\<typename T\> // perfect forwarding ctor

explicit Person(T&& n)

: name(std::forward\<T\>(n)) {}

**180 \| Item 26**

explicit Person(int idx); // int ctor

**Person(const Person& rhs);** // copy ctor

// (compiler-generated)

**Person(Person&& rhs);** // move ctor

… // (compiler-generated)

};

This leads to behavior that’s intuitive only if you’ve spent so much time around compilers and compiler-writers, you’ve forgotten what it’s like to be human: Person p("Nancy");

auto cloneOfP(p); // create new Person from p;

// *this won't compile!*

Here we’re trying to create a Person from another Person, which seems like about as obvious a case for copy construction as one can get. (p’s an lvalue, so we can banish any thoughts we might have about the “copying” being accomplished through a move operation.) But this code won’t call the copy constructor. It will call the perfect-forwarding constructor. That function will then try to initialize Person’s std::string data member with a Person object (p). std::string having no constructor taking a Person, your compilers will throw up their hands in exasperation, possibly punishing you with long and incomprehensible error messages as an expression of their displeasure.

“Why,” you might wonder, “does the perfect-forwarding constructor get called instead of the copy constructor? We’re initializing a Person with another Person!”

Indeed we are, but compilers are sworn to uphold the rules of C++, and the rules of relevance here are the ones governing the resolution of calls to overloaded functions.

Compilers reason as follows. cloneOfP is being initialized with a non-const lvalue (p), and that means that the templatized constructor can be instantiated to take a non-const lvalue of type Person. After such instantiation, the Person class looks like this:


public:

**explicit Person(Person& n)** // instantiated from

: name(std::forward\<Person&\>(n)) {} // perfect-forwarding

// template

explicit Person(int idx); // as before

**Item 26 \| 181**

Person(const Person& rhs); // copy ctor

… // (compiler-generated)

};

In the statement,

auto cloneOfP(p);

p could be passed to either the copy constructor or the instantiated template. Calling the copy constructor would require adding const to p to match the copy constructor’s parameter’s type, but calling the instantiated template requires no such addition.

The overload generated from the template is thus a better match, so compilers do what they’re designed to do: generate a call to the better-matching function. “Copying” non-const lvalues of type Person is thus handled by the perfect-forwarding constructor, not the copy constructor.

If we change the example slightly so that the object to be copied is const, we hear an entirely different tune:

**const** Person cp("Nancy"); // object is now const

auto cloneOfP(cp); // calls copy constructor!

Because the object to be copied is now const, it’s an exact match for the parameter taken by the copy constructor. The templatized constructor can be instantiated to have the same signature,


public:

**explicit Person(const Person& n);** // instantiated from

// template

Person(const Person& rhs); // copy ctor

// (compiler-generated)

…

};

but this doesn’t matter, because one of the overload-resolution rules in C++ is that in situations where a template instantiation and a non-template function (i.e., a “normal” function) are equally good matches for a function call, the normal function is preferred. The copy constructor (a normal function) thereby trumps an instantiated template with the same signature.

**182 \| Item 26**

(If you’re wondering why compilers generate a copy constructor when they could instantiate a templatized constructor to get the signature that the copy constructor would have, review Item 17.)

The interaction among perfect-forwarding constructors and compiler-generated copy and move operations develops even more wrinkles when inheritance enters the picture. In particular, the conventional implementations of derived class copy and move operations behave quite surprisingly. Here, take a look:

class SpecialPerson: public Person {

public:

SpecialPerson(const SpecialPerson& rhs) // copy ctor; calls

: **Person(rhs)** // base class

{ … } // forwarding ctor!

SpecialPerson(SpecialPerson&& rhs) // move ctor; calls

: **Person(std::move(rhs))** // base class

{ … } // forwarding ctor!

};

As the comments indicate, the derived class copy and move constructors don’t call their base class’s copy and move constructors, they call the base class’s perfect-forwarding constructor! To understand why, note that the derived class functions are using arguments of type SpecialPerson to pass to their base class, then work through the template instantiation and overload-resolution consequences for the constructors in class Person. Ultimately, the code won’t compile, because there’s no std::string constructor taking a SpecialPerson.

I hope that by now I’ve convinced you that overloading on universal reference parameters is something you should avoid if at all possible. But if overloading on universal references is a bad idea, what do you do if you need a function that forwards most argument types, yet needs to treat some argument types in a special fashion?

That egg can be unscrambled in a number of ways. So many, in fact, that I’ve devoted

an entire Item to them. It’s Item 27. The next Item. Keep reading, you’ll bump right into it.

**Things to Remember**

• Overloading on universal references almost always leads to the universal reference overload being called more frequently than expected.

• Perfect-forwarding constructors are especially problematic, because they’re typically better matches than copy constructors for non-const lvalues, and they can hijack derived class calls to base class copy and move constructors.

**Item 26 \| 183**

**Item 27: Familiarize yourself with alternatives to**

**overloading on universal references.**

Item 26 explains that overloading on universal references can lead to a variety of problems, both for freestanding and for member functions (especially constructors).

Yet it also gives examples where such overloading could be useful. If only it would behave the way we’d like! This Item explores ways to achieve the desired behavior, either through designs that avoid overloading on universal references or by employing them in ways that constrain the types of arguments they can match.

The discussion that follows builds on the examples introduced in Item 26. If you haven’t read that Item recently, you’ll want to review it before continuing.

**Abandon overloading**

The first example in Item 26, logAndAdd, is representative of the many functions that can avoid the drawbacks of overloading on universal references by simply using different names for the would-be overloads. The two logAndAdd overloads, for example, could be broken into logAndAddName and logAndAddNameIdx. Alas, this approach won’t work for the second example we considered, the Person constructor, because constructor names are fixed by the language. Besides, who wants to give up overloading?

**Pass by const T&**

An alternative is to revert to C++98 and replace pass-by-universal-reference with pass-by-lvalue-reference-to-const. In fact, that’s the first approach Item 26 considers (shown on page 175). The drawback is that the design isn’t as efficient as we’d prefer.

Knowing what we now know about the interaction of universal references and overloading, giving up some efficiency to keep things simple might be a more attractive trade-off than it initially appeared.

**Pass by value**

An approach that often allows you to dial up performance without any increase in complexity is to replace pass-by-reference parameters with, counterintuitively, pass

by value. The design adheres to the advice in Item 41 to consider passing objects by value when you know you’ll copy them, so I’ll defer to that Item for a detailed discussion of how things work and how efficient they are. Here, I’ll just show how the technique could be used in the Person example:


public:

explicit Person(**std::string** n) // replaces T&& ctor; see **184 \| Item 27**

: name(std::move(n)) {} // Item 41 for use of std::move explicit Person(int idx) // as before

: name(nameFromIdx(idx)) {}

…


std::string name;

};

Because there’s no std::string constructor taking only an integer, all int and int-like arguments to a Person constructor (e.g., std::size_t, short, long) get fun-neled to the int overload. Similarly, all arguments of type std::string (and things from which std::strings can be created, e.g., literals such as "Ruth") get passed to the constructor taking a std::string. There are thus no surprises for callers. You could argue, I suppose, that some people might be surprised that using 0 or NULL to indicate a null pointer would invoke the int overload, but such people should be

referred to Item 8 and required to read it repeatedly until the thought of using 0 or NULL as a null pointer makes them recoil.

**Use Tag dispatch**

Neither pass by lvalue-reference-to-const nor pass by value offers support for perfect forwarding. If the motivation for the use of a universal reference is perfect forwarding, we have to use a universal reference; there’s no other choice. Yet we don’t want to abandon overloading. So if we don’t give up overloading and we don’t give up universal references, how can we avoid overloading on universal references?

It’s actually not that hard. Calls to overloaded functions are resolved by looking at all the parameters of all the overloads as well as all the arguments at the call site, then choosing the function with the best overall match—taking into account all parameter/argument combinations. A universal reference parameter generally provides an exact match for whatever’s passed in, but if the universal reference is part of a parameter list containing other parameters that are *not* universal references, sufficiently poor matches on the non-universal reference parameters can knock an overload with a universal reference out of the running. That’s the basis behind the *tag dispatch* approach, and an example will make the foregoing description easier to understand.

We’ll apply tag dispatch to the logAndAdd example on page 177. Here’s the code for

that example, lest you get sidetracked looking it up:

std::multiset\<std::string\> names; // global data structure

template\<typename T\> // make log entry and add

**Item 27 \| 185**

void logAndAdd(T&& name) // name to data structure

{

auto now = std::chrono::system_clock::now();

log(now, "logAndAdd");

names.emplace(std::forward\<T\>(name));

}

By itself, this function works fine, but were we to introduce the overload taking an int that’s used to look up objects by index, we’d be back in the troubled land of

Item 26. The goal of this Item is to avoid that. Rather than adding the overload, we’ll reimplement logAndAdd to delegate to two other functions, one for integral values and one for everything else. logAndAdd itself will accept all argument types, both integral and non-integral.

The two functions doing the real work will be named logAndAddImpl, i.e., we’ll use overloading. One of the functions will take a universal reference. So we’ll have both overloading and universal references. But each function will also take a second parameter, one that indicates whether the argument being passed is integral. This second parameter is what will prevent us from tumbling into the morass described in

Item 26, because we’ll arrange it so that the second parameter will be the factor that determines which overload is selected.

Yes, I know, “Blah, blah, blah. Stop talking and show me the code!” No problem.

Here’s an almost-correct version of the updated logAndAdd:


void logAndAdd(T&& name)

{

logAndAddImpl(std::forward\<T\>(name),

**std::is_integral\<T\>()**); // *not quite correct*

}

This function forwards its parameter to logAndAddImpl, but it also passes an argument indicating whether that parameter’s type (T) is integral. At least, that’s what it’s supposed to do. For integral arguments that are rvalues, it’s also what it does. But, as

Item 28 explains, if an lvalue argument is passed to the universal reference name, the type deduced for T will be an lvalue reference. So if an lvalue of type int is passed to logAndAdd, T will be deduced to be int&. That’s not an integral type, because references aren’t integral types. That means that std::is_integral\<T\> will be false for any lvalue argument, even if the argument really does represent an integral value.

Recognizing the problem is tantamount to solving it, because the ever-handy Standard C++ Library has a type trait (see Item 9), std::remove_reference, that does both what its name suggests and what we need: remove any reference qualifiers from a type. The proper way to write logAndAdd is therefore:

**186 \| Item 27**


void logAndAdd(T&& name)

{

logAndAddImpl(

std::forward\<T\>(name),

std::is_integral\< **typename std::remove_reference\<T\>::type**\>()

);

}

This does the trick. (In C++14, you can save a few keystrokes by using

std::remove_reference_t\<T\> in place of the highlighted text. For details, see

Item 9.)

With that taken care of, we can shift our attention to the function being called, logAndAddImpl. There are two overloads, and the first is applicable only to non-integral types (i.e., to types where std::is_integral\<typename std::remove_ref erence\<T\>::type\> is false):

template\<typename T\> // non-integral

void logAndAddImpl(T&& name, **std::false_type**) // argument:

{ // add it to

auto now = std::chrono::system_clock::now(); // global data

log(now, "logAndAdd"); // structure

names.emplace(std::forward\<T\>(name));

}

This is straightforward code, once you understand the mechanics behind the highlighted parameter. Conceptually, logAndAdd passes a boolean to logAndAddImpl indicating whether an integral type was passed to logAndAdd, but true and false are *runtime* values, and we need to use overload resolution—a *compile-time* phenom-enon—to choose the correct logAndAddImpl overload. That means we need a *type* that corresponds to true and a different type that corresponds to false. This need is common enough that the Standard Library provides what is required under the names std::true_type and std::false_type. The argument passed to logAndAd dImpl by logAndAdd is an object of a type that inherits from std::true_type if T is integral and from std::false_type if T is not integral. The net result is that this logAndAddImpl overload is a viable candidate for the call in logAndAdd only if T is not an integral type.

The second overload covers the opposite case: when T is an integral type. In that event, logAndAddImpl simply finds the name corresponding to the passed-in index and passes that name back to logAndAdd:

std::string nameFromIdx(int idx); // as in Item 26

**Item 27 \| 187**

void logAndAddImpl(int idx, **std::true_type**) // integral

{ // argument: look

logAndAdd(nameFromIdx(idx)); // up name and

} // call logAndAdd

// with it

By having logAndAddImpl for an index look up the corresponding name and pass it to logAndAdd (from where it will be std::forwarded to the other logAndAddImpl overload), we avoid the need to put the logging code in both logAndAddImpl overloads.

In this design, the types std::true_type and std::false_type are “tags” whose only purpose is to force overload resolution to go the way we want. Notice that we don’t even name those parameters. They serve no purpose at runtime, and in fact we hope that compilers will recognize that the tag parameters are unused and will optimize them out of the program’s execution image. (Some compilers do, at least some of the time.) The call to the overloaded implementation functions inside logAndAdd

“dispatches” the work to the correct overload by causing the proper tag object to be created. Hence the name for this design: *tag dispatch*. It’s a standard building block of template metaprogramming, and the more you look at code inside contemporary C++ libraries, the more often you’ll encounter it.

For our purposes, what’s important about tag dispatch is less how it works and more how it permits us to combine universal references and overloading without the prob‐

lems described in Item 26. The dispatching function—logAndAdd—takes an unconstrained universal reference parameter, but this function is not overloaded. The implementation functions—logAndAddImpl—are overloaded, and one takes a universal reference parameter, but resolution of calls to these functions depends not just on the universal reference parameter, but also on the tag parameter, and the tag values are designed so that no more than one overload will be a viable match. As a result, it’s the tag that determines which overload gets called. The fact that the universal reference parameter will always generate an exact match for its argument is immaterial.

**Constraining templates that take universal references**

A keystone of tag dispatch is the existence of a single (unoverloaded) function as the client API. This single function dispatches the work to be done to the implementation functions. Creating an unoverloaded dispatch function is usually easy, but the second problem case Item 26 considers, that of a perfect-forwarding constructor for the Person class (shown on page 178), is an exception. Compilers may generate copy

and move constructors themselves, so even if you write only one constructor and use tag dispatch within it, some constructor calls may be handled by compiler-generated functions that bypass the tag dispatch system.

**188 \| Item 27**

In truth, the real problem is not that the compiler-generated functions sometimes bypass the tag dispatch design, it’s that they don’t *always* pass it by. You virtually always want the copy constructor for a class to handle requests to copy lvalues of that

type, but, as Item 26 demonstrates, providing a constructor taking a universal refer‐

ence causes the universal reference constructor (rather than the copy constructor) to be called when copying non-const lvalues. That Item also explains that when a base class declares a perfect-forwarding constructor, that constructor will typically be called when derived classes implement their copy and move constructors in the conventional fashion, even though the correct behavior is for the base class’s copy and move constructors to be invoked.

For situations like these, where an overloaded function taking a universal reference is greedier than you want, yet not greedy enough to act as a single dispatch function, tag dispatch is not the droid you’re looking for. You need a different technique, one that lets you rachet down the conditions under which the function template that the universal reference is part of is permitted to be employed. What you need, my friend, is std::enable_if.

std::enable_if gives you a way to force compilers to behave as if a particular template didn’t exist. Such templates are said to be *disabled*. By default, all templates are *enabled*, but a template using std::enable_if is enabled only if the condition specified by std::enable_if is satisfied. In our case, we’d like to enable the Person perfect-forwarding constructor only if the type being passed isn’t Person. If the type being passed is Person, we want to disable the perfect-forwarding constructor (i.e., cause compilers to ignore it), because that will cause the class’s copy or move constructor to handle the call, which is what we want when a Person object is initialized with another Person.

The way to express that idea isn’t particularly difficult, but the syntax is off-putting, especially if you’ve never seen it before, so I’ll ease you into it. There’s some boilerplate that goes around the condition part of std::enable_if, so we’ll start with that.

Here’s the declaration for the perfect-forwarding constructor in Person, showing only as much of the std::enable_if as is required simply to use it. I’m showing only the declaration for this constructor, because the use of std::enable_if has no effect on the function’s implementation. The implementation remains the same as in

Item 26.


public:

template\<typename T,

**typename = typename std::enable_if\< *condition*\>::type**\> explicit Person(T&& n);

…

**Item 27 \| 189**

};

To understand exactly what’s going on in the highlighted text, I must regretfully suggest that you consult other sources, because the details take a while to explain, and there’s just not enough space for it in this book. (During your research, look into

“SFINAE” as well as std::enable_if, because SFINAE is the technology that makes std::enable_if work.) Here, I want to focus on expression of the condition that will control whether this constructor is enabled.

The condition we want to specify is that T isn’t Person, i.e., that the templatized constructor should be enabled only if T is a type other than Person. Thanks to a type trait that determines whether two types are the same (std::is_same), it would seem that the condition we want is !std::is_same\<Person, T\>::value. (Notice the “!”

at the beginning of the expression. We want for Person and T to *not* be the same.)

This is close to what we need, but it’s not quite correct, because, as Item 28 explains, the type deduced for a universal reference initialized with an lvalue is always an lvalue reference. That means that for code like this,

Person p("Nancy");

auto cloneOfP(p); // initialize from lvalue

the type T in the universal constructor will be deduced to be Person&. The types Per son and Person& are not the same, and the result of std::is_same will reflect that: std::is_same\<Person, Person&\>::value is false.

If we think more precisely about what we mean when we say that the templatized constructor in Person should be enabled only if T isn’t Person, we’ll realize that when we’re looking at T, we want to ignore

• **Whether it’s a reference.** For the purpose of determining whether the universal reference constructor should be enabled, the types Person, Person&, and Per son&& are all the same as Person.

• **Whether it’s const or volatile.** As far as we’re concerned, a const Person and a volatile Person and a const volatile Person are all the same as a Person.

This means we need a way to strip any references, consts, and volatiles from T

before checking to see if that type is the same as Person. Once again, the Standard Library gives us what we need in the form of a type trait. That trait is std::decay.

std::decay\<T\>::type is the same as T, except that references and *cv-qualifiers* (i.e., const or volatile qualifiers) are removed. (I’m fudging the truth here, because std::decay, as its name suggests, also turns array and function types into pointers **190 \| Item 27**

(see Item 1), but for purposes of this discussion, std::decay behaves as I’ve described.) The condition we want to control whether our constructor is enabled, then, is

!std::is_same\<Person, typename std::decay\<T\>::type\>::value

i.e., Person is not the same type as T, ignoring any references or cv-qualifiers. (As

Item 9 explains, the “typename” in front of std::decay is required, because the type std::decay\<T\>::type depends on the template parameter T.)

Inserting this condition into the std::enable_if boilerplate above, plus formatting the result to make it easier to see how the pieces fit together, yields this declaration for Person’s perfect-forwarding constructor:


public:

template\<

typename T,

typename = typename std::enable_if\<

**!std::is_same\<Person,**

**typename std::decay\<T\>::type**

**\>::value**

\>::type

\>

explicit Person(T&& n);

…

};

If you’ve never seen anything like this before, count your blessings. There’s a reason I saved this design for last. When you can use one of the other mechanisms to avoid mixing universal references and overloading (and you almost always can), you should. Still, once you get used to the functional syntax and the proliferation of angle brackets, it’s not that bad. Furthermore, this gives you the behavior you’ve been striv-ing for. Given the declaration above, constructing a Person from another Person—

lvalue or rvalue, const or non-const, volatile or non-volatile—will never invoke the constructor taking a universal reference.

Success, right? We’re done!

Um, no. Belay that celebration. There’s still one loose end from Item 26 that continues to flap about. We need to tie it down.

Suppose a class derived from Person implements the copy and move operations in the conventional manner:

**Item 27 \| 191**

class SpecialPerson: public Person {

public:

SpecialPerson(const SpecialPerson& rhs) // copy ctor; calls

: **Person(rhs)** // base class

{ … } // forwarding ctor!

SpecialPerson(SpecialPerson&& rhs) // move ctor; calls

: **Person(std::move(rhs))** // base class

{ … } // forwarding ctor!

…

};

This is the same code I showed in Item 26 (on page 206), including the comments, which, alas, remain accurate. When we copy or move a SpecialPerson object, we expect to copy or move its base class parts using the base class’s copy and move constructors, but in these functions, we’re passing SpecialPerson objects to the base class’s constructors, and because SpecialPerson isn’t the same as Person (not even after application of std::decay), the universal reference constructor in the base class is enabled, and it happily instantiates to perform an exact match for a SpecialPer son argument. This exact match is better than the derived-to-base conversions that would be necessary to bind the SpecialPerson objects to the Person parameters in Person’s copy and move constructors, so with the code we have now, copying and moving SpecialPerson objects would use the Person perfect-forwarding constructor to copy or move their base class parts! It’s déjà Item 26 all over again.

The derived class is just following the normal rules for implementing derived class copy and move constructors, so the fix for this problem is in the base class and, in particular, in the condition that controls whether Person’s universal reference constructor is enabled. We now realize that we don’t want to enable the templatized constructor for any argument type other than Person, we want to enable it for any argument type other than Person *or a type derived from* *Person*. Pesky inheritance!

You should not be surprised to hear that among the standard type traits is one that determines whether one type is derived from another. It’s called std::is_base_of.

std::is_base_of\<T1, T2\>::value is true if T2 is derived from T1. Types are considered to be derived from themselves, so std::is_base_of\<T, T\>::value is true.

This is handy, because we want to revise our condition controlling Person’s perfect-forwarding constructor such that the constructor is enabled only if the type T, after stripping it of references and cv-qualifiers, is neither Person nor a class derived from Person. Using std::is_base_of instead of std::is_same gives us what we need: **192 \| Item 27**


public:

template\<

typename T,

typename = typename std::enable_if\<

!std::**is_base_of**\<Person,

typename std::decay\<T\>::type

\>::value

\>::type

\>

explicit Person(T&& n);

…

};

Now we’re finally done. Provided we’re writing the code in C++11, that is. If we’re using C++14, this code will still work, but we can employ alias templates for std::enable_if and std::decay to get rid of the “typename” and “::type” cruft, thus yielding this somewhat more palatable code:

class Person { // C++14

public:

template\<

typename T,

typename = std::enable_if**\_t**\< // less code here

!std::is_base_of\<Person,

std::decay**\_t**\<T\> // and here

\>::value

\> // and here

\>

explicit Person(T&& n);

…

};

Okay, I admit it: I lied. We’re still not done. But we’re close. Tantalizingly close.

Honest.

We’ve seen how to use std::enable_if to selectively disable Person’s universal reference constructor for argument types we want to have handled by the class’s copy and move constructors, but we haven’t yet seen how to apply it to distinguish integral and non-integral arguments. That was, after all, our original goal; the constructor ambiguity problem was just something we got dragged into along the way.

**Item 27 \| 193**

All we need to do—and I really do mean that this is everything—is (1) add a Person constructor overload to handle integral arguments and (2) further constrain the templatized constructor so that it’s disabled for such arguments. Pour these ingredi-ents into the pot with everything else we’ve discussed, simmer over a low flame, and savor the aroma of success:


public:

template\<

typename T,

typename = std::enable_if_t\<

!std::is_base_of\<Person, std::decay_t\<T\>\>::value

**&&**

**!std::is_integral\<std::remove_reference_t\<T\>\>::value**

\>

\>

explicit Person(T&& n) // ctor for std::strings and

: name(std::forward\<T\>(n)) // args convertible to

{ … } // std::strings

**explicit Person(int idx)** // ctor for integral args

**: name(nameFromIdx(idx))**

**{ … }**

… // copy and move ctors, etc.


std::string name;

};

*Voilà!* A thing of beauty! Well, okay, the beauty is perhaps most pronounced for those with something of a template metaprogramming fetish, but the fact remains that this approach not only gets the job done, it does it with unique aplomb. Because it uses perfect forwarding, it offers maximal efficiency, and because it controls the combination of universal references and overloading rather than forbidding it, this technique can be applied in circumstances (such as constructors) where overloading is unavoidable.

**Trade-offs**

The first three techniques considered in this Item—abandoning overloading, passing by const T&, and passing by value—specify a type for each parameter in the function(s) to be called. The last two techniques—tag dispatch and constraining template eligibility—use perfect forwarding, hence don’t specify types for the parameters. This fundamental decision—to specify a type or not—has consequences.

**194 \| Item 27**

As a rule, perfect forwarding is more efficient, because it avoids the creation of temporary objects solely for the purpose of conforming to the type of a parameter declaration. In the case of the Person constructor, perfect forwarding permits a string literal such as "Nancy" to be forwarded to the constructor for the std::string inside Person, whereas techniques not using perfect forwarding must create a temporary std::string object from the string literal to satisfy the parameter specification for the Person constructor.

But perfect forwarding has drawbacks. One is that some kinds of arguments can’t be perfect-forwarded, even though they can be passed to functions taking specific types.

Item 30 explores these perfect forwarding failure cases.

A second issue is the comprehensibility of error messages when clients pass invalid arguments. Suppose, for example, a client creating a Person object passes a string literal made up of char16_ts (a type introduced in C++11 to represent 16-bit characters) instead of chars (which is what a std::string consists of):

Person p(**u**"Konrad Zuse"); // "Konrad Zuse" consists of

// characters of type const char16_t

With the first three approaches examined in this Item, compilers will see that the available constructors take either int or std::string, and they’ll produce a more or less straightforward error message explaining that there’s no conversion from const char16_t\[12\] to int or std::string.

With an approach based on perfect forwarding, however, the array of const char16_ts gets bound to the constructor’s parameter without complaint. From there it’s forwarded to the constructor of Person’s std::string data member, and it’s only at that point that the mismatch between what the caller passed in (a const char16_t array) and what’s required (any type acceptable to the std::string constructor) is discovered. The resulting error message is likely to be, er, impressive.

With one of the compilers I use, it’s more than 160 lines long.

In this example, the universal reference is forwarded only once (from the Person constructor to the std::string constructor), but the more complex the system, the more likely that a universal reference is forwarded through several layers of function calls before finally arriving at a site that determines whether the argument type(s) are acceptable. The more times the universal reference is forwarded, the more baffling the error message may be when something goes wrong. Many developers find that this issue alone is grounds to reserve universal reference parameters for interfaces where performance is a foremost concern.

In the case of Person, we know that the forwarding function’s universal reference parameter is supposed to be an initializer for a std::string, so we can use a **Item 27 \| 195**

static_assert to verify that it can play that role. The std::is_constructible type trait performs a compile-time test to determine whether an object of one type can be constructed from an object (or set of objects) of a different type (or set of types), so the assertion is easy to write:


public:

template\< // as before

typename T,

typename = std::enable_if_t\<

!std::is_base_of\<Person, std::decay_t\<T\>\>::value

&&

!std::is_integral\<std::remove_reference_t\<T\>\>::value

\>

\>

explicit Person(T&& n)

: name(std::forward\<T\>(n))

{

// assert that a std::string can be created from a T object

**static_assert(**

**std::is_constructible\<std::string, T\>::value,**

**"Parameter n can't be used to construct a std::string"**

**);**

… // the usual ctor work goes here

}

… // remainder of Person class (as before)

};

This causes the specified error message to be produced if client code tries to create a Person from a type that can’t be used to construct a std::string. Unfortunately, in this example the static_assert is in the body of the constructor, but the forwarding code, being part of the member initialization list, precedes it. With the compilers I use, the result is that the nice, readable message arising from the static_assert appears only *after* the usual error messages (up to 160-plus lines of them) have been emitted.

**196 \| Item 27**

**Things to Remember**

• Alternatives to the combination of universal references and overloading include the use of distinct function names, passing parameters by lvalue-reference-to-const, passing parameters by value, and using tag dispatch.

• Constraining templates via std::enable_if permits the use of universal references and overloading together, but it controls the conditions under which compilers may use the universal reference overloads.

• Universal reference parameters often have efficiency advantages, but they typically have usability disadvantages.

**Item 28: Understand reference collapsing.**

Item 23 remarks that when an argument is passed to a template function, the type deduced for the template parameter encodes whether the argument is an lvalue or an rvalue. The Item fails to mention that this happens only when the argument is used to initialize a parameter that’s a universal reference, but there’s a good reason for the omission: universal references aren’t introduced until Item 24. Together, these observations about universal references and lvalue/rvalue encoding mean that for this template,


void func(T&& param);

the deduced template parameter T will encode whether the argument passed to param was an lvalue or an rvalue.

The encoding mechanism is simple. When an lvalue is passed as an argument, T is deduced to be an lvalue reference. When an rvalue is passed, T is deduced to be a non-reference. (Note the asymmetry: lvalues are encoded as lvalue references, but rvalues are encoded as *non-references*.) Hence:

Widget widgetFactory(); // function returning rvalue

Widget w; // a variable (an lvalue)

func(w); // call func with lvalue; T deduced

// to be **Widget&**

func(widgetFactory()); // call func with rvalue; T deduced

// to be **Widget**

**Item 27 \| 197**

In both calls to func, a Widget is passed, yet because one Widget is an lvalue and one is an rvalue, different types are deduced for the template parameter T. This, as we shall soon see, is what determines whether universal references become rvalue references or lvalue references, and it’s also the underlying mechanism through which std::forward does its work.

Before we can look more closely at std::forward and universal references, we must note that references to references are illegal in C++. Should you try to declare one, your compilers will reprimand you:

int x;

…

auto**& &** rx = x; // error! can't declare reference to reference But consider what happens when an lvalue is passed to a function template taking a universal reference:


void func(T&& param); // as before

func(w); // invoke func with lvalue;

// T deduced as Widget&

If we take the type deduced for T (i.e., Widget&) and use it to instantiate the template, we get this:

void func(**Widget& &&** param);

A reference to a reference! And yet compilers issue no protest. We know from

Item 24 that because the universal reference param is being initialized with an lvalue, param’s type is supposed to be an lvalue reference, but how does the compiler get from the result of taking the deduced type for T and substituting it into the template to the following, which is the ultimate function signature?

void func(**Widget&** param);

The answer is *reference collapsing*. Yes, *you* are forbidden from declaring references to references, but *compilers* may produce them in particular contexts, template instantiation being among them. When compilers generate references to references, reference collapsing dictates what happens next.

There are two kinds of references (lvalue and rvalue), so there are four possible reference-reference combinations (lvalue to lvalue, lvalue to rvalue, rvalue to lvalue, and rvalue to rvalue). If a reference to a reference arises in a context where this is permitted (e.g., during template instantiation), the references *collapse* to a single reference according to this rule:

**198 \| Item 28**

If either reference is an lvalue reference, the result is an lvalue reference.

Otherwise (i.e., if both are rvalue references) the result is an rvalue reference.

In our example above, substitution of the deduced type Widget& into the template func yields an rvalue reference to an lvalue reference, and the reference-collapsing rule tells us that the result is an lvalue reference.

Reference collapsing is a key part of what makes std::forward work. As explained in Item 25, std::forward is applied to universal reference parameters, so a common use case looks like this:


void f(T&& fParam)

{

… // do some work

someFunc(**std::forward\<T\>** (fParam)); // forward fParam to

} // someFunc

Because fParam is a universal reference, we know that the type parameter T will encode whether the argument passed to f (i.e., the expression used to initialize fParam) was an lvalue or an rvalue. std::forward’s job is to cast fParam (an lvalue) to an rvalue if and only if T encodes that the argument passed to f was an rvalue, i.e., if T is a non-reference type.

Here’s how std::forward can be implemented to do that:

template\<typename T\> // in

T&& forward(typename // namespace remove_reference\<T\>::type& param) // std

{

return static_cast\<T&&\>(param);

}

This isn’t quite Standards-conformant (I’ve omitted a few interface details), but the differences are irrelevant for the purpose of understanding how std::forward behaves.

Suppose that the argument passed to f is an lvalue of type Widget. T will be deduced as Widget&, and the call to std::forward will instantiate as std::forward

\<Widget&\>. Plugging Widget& into the std::forward implementation yields this: **Item 28 \| 199**

**Widget&** && forward(typename

remove_reference\< **Widget&** \>::type& param)

{ return static_cast\< **Widget&** &&\>(param); }

The type trait std::remove_reference\<Widget&\>::type yields Widget (see

Item 9), so std::forward becomes:

Widget& && forward(**Widget**& param)

{ return static_cast\<Widget& &&\>(param); }

Reference collapsing is also applied to the return type and the cast, and the result is the final version of std::forward for the call:

**Widget&** forward(**Widget&** param) // still in

{ return static_cast\< **Widget&** \>(param); } // namespace std As you can see, when an lvalue argument is passed to the function template f, std::forward is instantiated to take and return an lvalue reference. The cast inside std::forward does nothing, because param’s type is already Widget&, so casting it to Widget& has no effect. An lvalue argument passed to std::forward will thus return an lvalue reference. By definition, lvalue references are lvalues, so passing an lvalue to std::forward causes an lvalue to be returned, just like it’s supposed to.

Now suppose that the argument passed to f is an rvalue of type Widget. In this case, the deduced type for f’s type parameter T will simply be Widget. The call inside f to std::forward will thus be to std::forward\<Widget\>. Substituting Widget for T in the std::forward implementation gives this:

**Widget**&& forward(typename

remove_reference\< **Widget**\>::type& param)

{ return static_cast\< **Widget**&&\>(param); }

Applying std::remove_reference to the non-reference type Widget yields the same type it started with (Widget), so std::forward becomes this:

Widget&& forward(**Widget**& param)

{ return static_cast\<Widget&&\>(param); }

There are no references to references here, so there’s no reference collapsing, and this is the final instantiated version of std::forward for the call.

Rvalue references returned from functions are defined to be rvalues, so in this case, std::forward will turn f’s parameter fParam (an lvalue) into an rvalue. The end result is that an rvalue argument passed to f will be forwarded to someFunc as an rvalue, which is precisely what is supposed to happen.

**200 \| Item 28**

In C++14, the existence of std::remove_reference_t makes it possible to implement std::forward a bit more concisely:

template\<typename T\> // C++14; still in

T&& forward(**remove_reference_t\<T\>** & param) // namespace std

{

return static_cast\<T&&\>(param);

}

Reference collapsing occurs in four contexts. The first and most common is template instantiation. The second is type generation for auto variables. The details are essentially the same as for templates, because type deduction for auto variables is essentially the same as type deduction for templates (see Item 2). Consider again this

example from earlier in the Item:


void func(T&& param);

Widget widgetFactory(); // function returning rvalue

Widget w; // a variable (an lvalue)

func(w); // call func with lvalue; T deduced

// to be *Widget&*

func(widgetFactory()); // call func with rvalue; T deduced

// to be *Widget*

This can be mimicked in auto form. The declaration

**auto&&** w1 = w;

initializes w1 with an lvalue, thus deducing the type Widget& for auto. Plugging Widget& in for auto in the declaration for w1 yields this reference-to-reference code, **Widget& &&** w1 = w;

which, after reference collapsing, becomes

**Widget&** w1 = w;

As a result, w1 is an lvalue reference.

On the other hand, this declaration,

**auto&&** w2 = widgetFactory();

initializes w2 with an rvalue, causing the non-reference type Widget to be deduced for auto. Substituting Widget for auto gives us this:

**Item 28 \| 201**

**Widget&&** w2 = widgetFactory();

There are no references to references here, so we’re done; w2 is an rvalue reference.

We’re now in a position to truly understand the universal references introduced in

Item 24. A universal reference isn’t a new kind of reference, it’s actually an rvalue ref‐

erence in a context where two conditions are satisfied:

• **Type deduction distinguishes lvalues from rvalues**. Lvalues of type T are deduced to have type T&, while rvalues of type T yield T as their deduced type.

• **Reference collapsing occurs**.

The concept of universal references is useful, because it frees you from having to recognize the existence of reference collapsing contexts, to mentally deduce different types for lvalues and rvalues, and to apply the reference collapsing rule after mentally substituting the deduced types into the contexts in which they occur.

I said there were four such contexts, but we’ve discussed only two: template instantiation and auto type generation. The third is the generation and use of typedefs and alias declarations (see Item 9). If, during creation or evaluation of a typedef, references to references arise, reference collapsing intervenes to eliminate them. For example, suppose we have a Widget class template with an embedded typedef for an rvalue reference type,



public:

**typedef T&& RvalueRefToT;**

…

};

and suppose we instantiate Widget with an lvalue reference type:

Widget\< **int&** \> w;

Substituting int& for T in the Widget template gives us the following typedef: typedef **int& &&** RvalueRefToT;

Reference collapsing reduces it to this,

typedef **int&** RvalueRefToT;

which makes clear that the name we chose for the typedef is perhaps not as descriptive as we’d hoped: *RvalueRef* ToT is a typedef for an *lvalue reference* when Widget is instantiated with an lvalue reference type.

**202 \| Item 28**

The final context in which reference collapsing takes place is uses of decltype. If, during analysis of a type involving decltype, a reference to a reference arises, reference collapsing will kick in to eliminate it. (For information about decltype, see

Item 3.)

**Things to Remember**

• Reference collapsing occurs in four contexts: template instantiation, auto type generation, creation and use of typedefs and alias declarations, and

decltype.

• When compilers generate a reference to a reference in a reference collapsing context, the result becomes a single reference. If either of the original references is an lvalue reference, the result is an lvalue reference. Otherwise it’s an rvalue reference.

• Universal references are rvalue references in contexts where type deduction distinguishes lvalues from rvalues and where reference collapsing occurs.

**Item 29: Assume that move operations are not present,**

**not cheap, and not used.**

Move semantics is arguably *the* premier feature of C++11. “Moving containers is now as cheap as copying pointers!” you’re likely to hear, and “Copying temporary objects is now so efficient, coding to avoid it is tantamount to premature optimization!” Such sentiments are easy to understand. Move semantics is truly an important feature. It doesn’t just allow compilers to replace expensive copy operations with comparatively cheap moves, it actually *requires* that they do so (when the proper conditions are fulfilled). Take your C++98 code base, recompile with a C++11-conformant compiler and Standard Library, and— *shazam!* —your software runs faster.

Move semantics can really pull that off, and that grants the feature an aura worthy of legend. Legends, however, are generally the result of exaggeration. The purpose of this Item is to keep your expectations grounded.

Let’s begin with the observation that many types fail to support move semantics. The entire C++98 Standard Library was overhauled for C++11 to add move operations for types where moving could be implemented faster than copying, and the implementation of the library components was revised to take advantage of these operations, but chances are that you’re working with a code base that has not been completely revised to take advantage of C++11. For types in your applications (or in the libraries you use) where no modifications for C++11 have been made, the exis-Item 28 \| 203

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_1.jpg)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_2.png)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_3.jpg)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_4.png)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_5.jpg)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_6.png)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_7.jpg)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_8.png)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_9.jpg)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-222_10.png)

tence of move support in your compilers is likely to do you little good. True, C++11

is willing to generate move operations for classes that lack them, but that happens only for classes declaring no copy operations, move operations, or destructors (see

Item 17). Data members or base classes of types that have disabled moving (e.g., by

deleting the move operations—see Item 11) will also suppress compiler-generated

move operations. For types without explicit support for moving and that don’t qualify for compiler-generated move operations, there is no reason to expect C++11 to deliver any kind of performance improvement over C++98.

Even types with explicit move support may not benefit as much as you’d hope. All containers in the standard C++11 library support moving, for example, but it would be a mistake to assume that moving all containers is cheap. For some containers, this is because there’s no truly cheap way to move their contents. For others, it’s because the truly cheap move operations the containers offer come with caveats the container elements can’t satisfy.

Consider std::array, a new container in C++11. std::array is essentially a built-in array with an STL interface. This is fundamentally different from the other standard containers, each of which stores its contents on the heap. Objects of such container types hold (as data members), conceptually, only a pointer to the heap memory storing the contents of the container. (The reality is more complex, but for purposes of this analysis, the differences are not important.) The existence of this pointer makes it possible to move the contents of an entire container in constant time: just copy the pointer to the container’s contents from the source container to the target, and set the source’s pointer to null:

**std::vector**\<Widget\> vw1;

vw1

// put data into vw1

*Widgets*

…

// move vw1 into vw2. *Runs in*

vw1

// *constant time*. Only ptrs

*null*

*Widgets*

// in vw1 and vw2 are modified

vw2

auto vw2 = std::move(vw1);

std::array objects lack such a pointer, because the data for a std::array’s contents are stored directly in the std::array object:

**204 \| Item 29**

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-223_1.jpg)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-223_2.png)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-223_3.jpg)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-223_4.png)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-223_5.jpg)

![](/tmp/audit/iter1/epubregen/effective-modern-c/media/index-223_6.png)

**std::array**\<Widget, 10000\> aw1;

aw1

// put data into aw1

*Widgets*

…

aw1

// move aw1 into aw2. *Runs in*

*Widgets (moved from)*

// *linear time.* All elements in

aw2

// aw1 are moved into aw2

*Widgets (moved to)*

auto aw2 = std::move(aw1);

Note that the elements in aw1 are *moved* into aw2. Assuming that Widget is a type where moving is faster than copying, moving a std::array of Widget will be faster than copying the same std::array. So std::array certainly offers move support.

Yet both moving and copying a std::array have linear-time computational complexity, because each element in the container must be copied or moved. This is far from the “moving a container is now as cheap as assigning a couple of pointers”

claim that one sometimes hears.

On the other hand, std::string offers constant-time moves and linear-time copies.

That makes it sound like moving is faster than copying, but that may not be the case.

Many string implementations employ the *small string optimization* (SSO). With the SSO, “small” strings (e.g., those with a capacity of no more than 15 characters) are stored in a buffer within the std::string object; no heap-allocated storage is used.

Moving small strings using an SSO-based implementation is no faster than copying them, because the copy-only-a-pointer trick that generally underlies the performance advantage of moves over copies isn’t applicable.

The motivation for the SSO is extensive evidence that short strings are the norm for many applications. Using an internal buffer to store the contents of such strings eliminates the need to dynamically allocate memory for them, and that’s typically an efficiency win. An implication of the win, however, is that moves are no faster than copies, though one could just as well take a glass-half-full approach and say that for such strings, copying is no slower than moving.

Even for types supporting speedy move operations, some seemingly sure-fire move

situations can end up making copies. Item 14 explains that some container opera‐

tions in the Standard Library offer the strong exception safety guarantee and that to ensure that legacy C++98 code dependent on that guarantee isn’t broken when upgrading to C++11, the underlying copy operations may be replaced with move operations only if the move operations are known to not throw. A consequence is that even if a type offers move operations that are more efficient than the corre-Item 29 \| 205

sponding copy operations, and even if, at a particular point in the code, a move operation would generally be appropriate (e.g., if the source object is an rvalue), compilers might still be forced to invoke a copy operation because the corresponding move operation isn’t declared noexcept.

There are thus several scenarios in which C++11’s move semantics do you no good:

• **No move operations:** The object to be moved from fails to offer move operations. The move request therefore becomes a copy request.

• **Move not faster:** The object to be moved from has move operations that are no faster than its copy operations.

• **Move not usable:** The context in which the moving would take place requires a move operation that emits no exceptions, but that operation isn’t declared noex cept.

It’s worth mentioning, too, another scenario where move semantics offers no efficiency gain:

• **Source object is lvalue:** With very few exceptions (see e.g., Item 25) only rvalues

may be used as the source of a move operation.

But the title of this Item is to *assume* that move operations are not present, not cheap, and not used. This is typically the case in generic code, e.g., when writing templates, because you don’t know all the types you’re working with. In such circumstances, you must be as conservative about copying objects as you were in C++98—before move semantics existed. This is also the case for “unstable” code, i.e., code where the characteristics of the types being used are subject to relatively frequent modification.

Often, however, you know the types your code uses, and you can rely on their characteristics not changing (e.g., whether they support inexpensive move operations).

When that’s the case, you don’t need to make assumptions. You can simply look up the move support details for the types you’re using. If those types offer cheap move operations, and if you’re using objects in contexts where those move operations will be invoked, you can safely rely on move semantics to replace copy operations with their less expensive move counterparts.

**Things to Remember**

• Assume that move operations are not present, not cheap, and not used.

• In code with known types or support for move semantics, there is no need for assumptions.

**206 \| Item 29**

**Item 30: Familiarize yourself with perfect forwarding** **failure cases.**

One of the features most prominently emblazoned on the C++11 box is perfect forwarding. *Perfect* forwarding. It’s *perfect*! Alas, tear the box open, and you’ll find that there’s “perfect” (the ideal), and then there’s “perfect” (the reality). C++11’s perfect forwarding is very good, but it achieves true perfection only if you’re willing to overlook an epsilon or two. This Item is devoted to familiarizing you with the epsilons.

Before embarking on our epsilon exploration, it’s worthwhile to review what’s meant by “perfect forwarding.” “Forwarding” just means that one function passes— *forwards*

—its parameters to another function. The goal is for the second function (the one being forwarded to) to receive the same objects that the first function (the one doing the forwarding) received. That rules out by-value parameters, because they’re *copies* of what the original caller passed in. We want the forwarded-to function to be able to work with the originally-passed-in objects. Pointer parameters are also ruled out, because we don’t want to force callers to pass pointers. When it comes to general-purpose forwarding, we’ll be dealing with parameters that are references.

*Perfect forwarding* means we don’t just forward objects, we also forward their salient characteristics: their types, whether they’re lvalues or rvalues, and whether they’re const or volatile. In conjunction with the observation that we’ll be dealing with reference parameters, this implies that we’ll be using universal references (see

Item 24), because only universal reference parameters encode information about the lvalueness and rvalueness of the arguments that are passed to them.

Let’s assume we have some function f, and we’d like to write a function (in truth, a function template) that forwards to it. The core of what we need looks like this: template\<typename T\>

void fwd(**T&& param**) // accept any argument

{

f(**std::forward\<T\>(param)**); // forward it to f

}

Forwarding functions are, by their nature, generic. The fwd template, for example, accepts any type of argument, and it forwards whatever it gets. A logical extension of this genericity is for forwarding functions to be not just templates, but *variadic* templates, thus accepting any number of arguments. The variadic form for fwd looks like this:

template\<typename**...** Ts\>

void fwd(Ts&& **...** params) // accept any arguments

{

**Item 30 \| 207**

f(std::forward\<Ts\>(params)**...** ); // forward them to f

}

This is the form you’ll see in, among other places, the standard containers’ emplacement functions (see Item 42) and the smart pointer factory functions,

std::make_shared and std::make_unique (see Item 21).

Given our target function f and our forwarding function fwd, perfect forwarding *fails* if calling f with a particular argument does one thing, but calling fwd with the same argument does something different:

f( *expression* ); // if this does one thing,

fwd( *expression* ); // but this does something else, fwd fails

// to perfectly forward *expression* to f

Several kinds of arguments lead to this kind of failure. Knowing what they are and how to work around them is important, so let’s tour the kinds of arguments that can’t be perfect-forwarded.

**Braced initializers**

Suppose f is declared like this:

void f(const std::vector\<int\>& v);

In that case, calling f with a braced initializer compiles,

f(**{ 1, 2, 3 }**); // fine, "{1, 2, 3}" implicitly

// converted to std::vector\<int\>

but passing the same braced initializer to fwd doesn’t compile:

fwd(**{ 1, 2, 3 }**); // error! doesn't compile

That’s because the use of a braced initializer is a perfect forwarding failure case.

All such failure cases have the same cause. In a direct call to f (such as f({ 1, 2, 3 })), compilers see the arguments passed at the call site, and they see the types of the parameters declared by f. They compare the arguments at the call site to the parameter declarations to see if they’re compatible, and, if necessary, they perform implicit conversions to make the call succeed. In the example above, they generate a temporary std::vector\<int\> object from { 1, 2, 3 } so that f’s parameter v has a std::vector\<int\> object to bind to.

When calling f indirectly through the forwarding function template fwd, compilers no longer compare the arguments passed at fwd’s call site to the parameter declarations in f. Instead, they *deduce* the types of the arguments being passed to fwd, and **208 \| Item 30**

they compare the deduced types to f’s parameter declarations. Perfect forwarding fails when either of the following occurs:

• **Compilers are unable to deduce a type** for one or more of fwd’s parameters. In this case, the code fails to compile.

• **Compilers deduce the “wrong” type** for one or more of fwd’s parameters. Here,

“wrong” could mean that fwd’s instantiation won’t compile with the types that were deduced, but it could also mean that the call to f using fwd’s deduced types behaves differently from a direct call to f with the arguments that were passed to fwd. One source of such divergent behavior would be if f were an overloaded function name, and, due to “incorrect” type deduction, the overload of f called inside fwd were different from the overload that would be invoked if f were called directly.

In the “fwd({ 1, 2, 3 })” call above, the problem is that passing a braced initializer to a function template parameter that’s not declared to be a std::initial izer_list is decreed to be, as the Standard puts it, a “non-deduced context.” In plain English, that means that compilers are forbidden from deducing a type for the expression { 1, 2, 3 } in the call to fwd, because fwd’s parameter isn’t declared to be a std::initializer_list. Being prevented from deducing a type for fwd’s parameter, compilers must understandably reject the call.

Interestingly, Item 2 explains that type deduction succeeds for auto variables initialized with a braced initializer. Such variables are deemed to be std::initial izer_list objects, and this affords a simple workaround for cases where the type the forwarding function should deduce is a std::initializer_list—declare a local variable using auto, then pass the local variable to the forwarding function: auto il = { 1, 2, 3 }; // il's type deduced to be

// std::initializer_list\<int\>

fwd(il); // fine, perfect-forwards il to f

**0 or NULL as null pointers**

Item 8 explains that when you try to pass 0 or NULL as a null pointer to a template, type deduction goes awry, deducing an integral type (typically int) instead of a pointer type for the argument you pass. The result is that neither 0 nor NULL can be perfect-forwarded as a null pointer. The fix is easy, however: pass nullptr instead of 0 or NULL. For details, consult Item 8.

**Item 30 \| 209**

**Declaration-only integral static const data members** As a general rule, there’s no need to define integral static const data members in classes; declarations alone suffice. That’s because compilers perform *const propagation* on such members’ values, thus eliminating the need to set aside memory for them. For example, consider this code:


public:

**static const std::size_t MinVals = 28;** // MinVals' declaration

…

};

… // no defn. for MinVals

std::vector\<int\> widgetData;

widgetData.reserve(**Widget::MinVals**); // use of MinVals

Here, we’re using Widget::MinVals (henceforth simply MinVals) to specify widget Data’s initial capacity, even though MinVals lacks a definition. Compilers work around the missing definition (as they are required to do) by plopping the value 28

into all places where MinVals is mentioned. The fact that no storage has been set aside for MinVals’ value is unproblematic. If MinVals’ address were to be taken (e.g., if somebody created a pointer to MinVals), then MinVals would require storage (so that the pointer had something to point to), and the code above, though it would compile, would fail at link-time until a definition for MinVals was provided.

With that in mind, imagine that f (the function fwd forwards its argument to) is declared like this:

void f(std::size_t val);

Calling f with MinVals is fine, because compilers will just replace MinVals with its value:

f(**Widget::MinVals**); // fine, treated as "f(28)"

Alas, things may not go so smoothly if we try to call f through fwd:

fwd(**Widget::MinVals**); // error! shouldn't link

This code will compile, but it shouldn’t link. If that reminds you of what happens if we write code that takes MinVals’ address, that’s good, because the underlying problem is the same.

Although nothing in the source code takes MinVals’ address, fwd’s parameter is a universal reference, and references, in the code generated by compilers, are usually treated like pointers. In the program’s underlying binary code (and on the hardware), **210 \| Item 30**

pointers and references are essentially the same thing. At this level, there’s truth to the adage that references are simply pointers that are automatically dereferenced.

That being the case, passing MinVals by reference is effectively the same as passing it by pointer, and as such, there has to be some memory for the pointer to point to.

Passing integral static const data members by reference, then, generally requires that they be defined, and that requirement can cause code using perfect forwarding to fail where the equivalent code without perfect forwarding succeeds.

But perhaps you noticed the weasel words I sprinkled through the preceding discussion. The code “shouldn’t” link. References are “usually” treated like pointers. Passing integral static const data members by reference “generally” requires that they be defined. It’s almost like I know something I don’t really want to tell you…

That’s because I do. According to the Standard, passing MinVals by reference requires that it be defined. But not all implementations enforce this requirement. So, depending on your compilers and linkers, you may find that you can perfect-forward integral static const data members that haven’t been defined. If you do, congratu-lations, but there is no reason to expect such code to port. To make it portable, simply provide a definition for the integral static const data member in question. For MinVals, that’d look like this:

const std::size_t Widget::MinVals; // in Widget's .cpp file

Note that the definition doesn’t repeat the initializer (28, in the case of MinVals).

Don’t stress over this detail, however. If you forget and provide the initializer in both places, your compilers will complain, thus reminding you to specify it only once.

**Overloaded function names and template names**

Suppose our function f (the one we keep wanting to forward arguments to via fwd) can have its behavior customized by passing it a function that does some of its work.

Assuming this function takes and returns ints, f could be declared like this: void f(**int (\*pf)(int)**); // pf = "processing function"

It’s worth noting that f could also be declared using a simpler non-pointer syntax.

Such a declaration would look like this, though it’d have the same meaning as the declaration above:

void f(**int pf(int)**); // declares same f as above

Either way, now suppose we have an overloaded function, processVal:

int processVal(int value);

int processVal(int value, int priority);

We can pass processVal to f,

**Item 30 \| 211**

f(processVal); // fine

but it’s something of a surprise that we can. f demands a pointer to a function as its argument, but processVal isn’t a function pointer or even a function, it’s the name of two different functions. However, compilers know which processVal they need: the one matching f’s parameter type. They thus choose the processVal taking one int, and they pass that function’s address to f.

What makes this work is that f’s declaration lets compilers figure out which version of processVal is required. fwd, however, being a function template, doesn’t have any information about what type it needs, and that makes it impossible for compilers to determine which overload should be passed:

fwd(processVal); // error! which processVal?

processVal alone has no type. Without a type, there can be no type deduction, and without type deduction, we’re left with another perfect forwarding failure case.

The same problem arises if we try to use a function template instead of (or in addition to) an overloaded function name. A function template doesn’t represent one function, it represents *many* functions:


T workOnVal(T param) // template for processing values

{ … }

fwd(workOnVal); // error! which workOnVal

// instantiation?

The way to get a perfect-forwarding function like fwd to accept an overloaded function name or a template name is to manually specify the overload or instantiation you want to have forwarded. For example, you can create a function pointer of the same type as f’s parameter, initialize that pointer with processVal or workOnVal (thus causing the proper version of processVal to be selected or the proper instantiation of workOnVal to be generated), and pass the pointer to fwd:

using ProcessFuncType = // make typedef;

int (\*)(int); // see Item 9

**ProcessFuncType** processValPtr = **processVal**; // specify needed

// signature for

// processVal

fwd(processValPtr); // fine

fwd(**static_cast\<ProcessFuncType\>(workOnVal)**); // also fine **212 \| Item 30**

Of course, this requires that you know the type of function pointer that fwd is forwarding to. It’s not unreasonable to assume that a perfect-forwarding function will document that. After all, perfect-forwarding functions are designed to accept *anything*, so if there’s no documentation telling you what to pass, how would you know?

**Bitfields**

The final failure case for perfect forwarding is when a bitfield is used as a function argument. To see what this means in practice, observe that an IPv4 header can be modeled as follows:3

struct IPv4Header {

std::uint32_t version:4,

IHL:4,

DSCP:6,

ECN:2,

totalLength:16;

…

};

If our long-suffering function f (the perennial target of our forwarding function fwd) is declared to take a std::size_t parameter, calling it with, say, the totalLength field of an IPv4Header object compiles without fuss:

void f(std::size_t sz); // function to call

IPv4Header h;

…

**f**(h.totalLength); // fine

Trying to forward h.totalLength to f via fwd, however, is a different story: **fwd**(h.totalLength); // error!

The problem is that fwd’s parameter is a reference, and h.totalLength is a non-const bitfield. That may not sound so bad, but the C++ Standard condemns the combination in unusually clear prose: “A non-const reference shall not be bound to a bit-field.” There’s an excellent reason for the prohibition. Bitfields may consist of arbitrary parts of machine words (e.g., bits 3-5 of a 32-bit int), but there’s no way to directly address such things. I mentioned earlier that references and pointers are the same thing at the hardware level, and just as there’s no way to create a pointer to 3 This assumes that bitfields are laid out lsb (least significant bit) to msb (most significant bit). C++ doesn’t guarantee that, but compilers often provide a mechanism that allows programmers to control bitfield layout.

**Item 30 \| 213**

arbitrary bits (C++ dictates that the smallest thing you can point to is a char), there’s no way to bind a reference to arbitrary bits, either.

Working around the impossibility of perfect-forwarding a bitfield is easy, once you realize that any function that accepts a bitfield as an argument will receive a *copy* of the bitfield’s value. After all, no function can bind a reference to a bitfield, nor can any function accept pointers to bitfields, because pointers to bitfields don’t exist. The only kinds of parameters to which a bitfield can be passed are by-value parameters and, interestingly, references-to-const. In the case of by-value parameters, the called function obviously receives a copy of the value in the bitfield, and it turns out that in the case of a reference-to-const parameter, the Standard requires that the reference actually bind to a *copy* of the bitfield’s value that’s stored in an object of some standard integral type (e.g., int). References-to-const don’t bind to bitfields, they bind to “normal” objects into which the values of the bitfields have been copied.

The key to passing a bitfield into a perfect-forwarding function, then, is to take advantage of the fact that the forwarded-to function will always receive a copy of the bitfield’s value. You can thus make a copy yourself and call the forwarding function with the copy. In the case of our example with IPv4Header, this code would do the trick:

// copy bitfield value; see Item 6 for info on init. form auto length = static_cast\<std::uint16_t\>(h.totalLength);

fwd(length); // forward the copy

**Upshot**

In most cases, perfect forwarding works exactly as advertised. You rarely have to think about it. But when it doesn’t work—when reasonable-looking code fails to compile or, worse, compiles, but doesn’t behave the way you anticipate—it’s important to know about perfect forwarding’s imperfections. Equally important is knowing how to work around them. In most cases, this is straightforward.

**Things to Remember**

• Perfect forwarding fails when template type deduction fails or when it deduces the wrong type.

• The kinds of arguments that lead to perfect forwarding failure are braced initializers, null pointers expressed as 0 or NULL, declaration-only integral const static data members, template and overloaded function names, and bitfields.

**214 \| Item 30**

**CHAPTER 6**