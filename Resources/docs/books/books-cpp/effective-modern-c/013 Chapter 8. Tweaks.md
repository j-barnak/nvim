**Tweaks**

For every general technique or feature in C++, there are circumstances where it’s reasonable to use it, and there are circumstances where it’s not. Describing when it makes sense to use a general technique or feature is usually fairly straightforward, but this chapter covers two exceptions. The general technique is pass by value, and the general feature is emplacement. The decision about when to employ them is affected by so many factors, the best advice I can offer is to *consider* their use. Nevertheless, both are important players in effective modern C++ programming, and the Items that follow provide the information you’ll need to determine whether using them is appropriate for your software.

**Item 41: Consider pass by value for copyable parameters**

**that are cheap to move and always copied.**

Some function parameters are intended to be copied.1 For example, a member function addName might copy its parameter into a private container. For efficiency, such a function should copy lvalue arguments, but move rvalue arguments:

class Widget {

public:

void addName(**const std::string&** newName) // take lvalue;

{ names.push_back(newName); } // copy it

void addName(**std::string&&** newName) // take rvalue; 1 In this Item, to “copy” a parameter generally means to use it as the source of a copy or move operation. Recall

on page 2 that C++ has no terminology to distinguish a copy made by a copy operation from one made by a move operation.

**281**

{ names.push_back(std::move(newName)); } // move it; see

… // Item 25 for use

// of std::move

private:

std::vector\<std::string\> names;

};

This works, but it requires writing two functions that do essentially the same thing.

That chafes a bit: two functions to declare, two functions to implement, two functions to document, two functions to maintain. Ugh.

Furthermore, there will be two functions in the object code—something you might care about if you’re concerned about your program’s footprint. In this case, both functions will probably be inlined, and that’s likely to eliminate any bloat issues related to the existence of two functions, but if these functions aren’t inlined everywhere, you really will get two functions in your object code.

An alternative approach is to make addName a function template taking a universal

reference (see Item 24):

class Widget {

public:

**template\<typename T\>** // take lvalues void addName(**T&& newName**) // *and* rvalues;

{ // copy lvalues,

names.push_back(std::forward\<T\>(newName)); // move rvalues;

} // see Item 25

// for use of

… // std::forward

};

This reduces the source code you have to deal with, but the use of universal references leads to other complications. As a template, addName’s implementation must typically be in a header file. It may yield several functions in object code, because it not only instantiates differently for lvalues and rvalues, it also instantiates differently for std::string and types that are convertible to std::string (see Item 25). At the

same time, there are argument types that can’t be passed by universal reference (see

Item 30), and if clients pass improper argument types, compiler error messages can

be intimidating (see Item 27).

Wouldn’t it be nice if there were a way to write functions like addName such that lvalues were copied, rvalues were moved, there was only one function to deal with (in both source and object code), and the idiosyncrasies of universal references were avoided? As it happens, there is. All you have to do is abandon one of the first rules you probably learned as a C++ programmer. That rule was to avoid passing objects of **282 \| Item 41**

user-defined types by value. For parameters like newName in functions like addName, pass by value may be an entirely reasonable strategy.

Before we discuss why pass-by-value may be a good fit for newName and addName, let’s see how it would be implemented:

class Widget {

public:

void addName(**std::string** newName) // take lvalue or

{ names.push_back(std::move(newName)); } // rvalue; move it

…

};

The only non-obvious part of this code is the application of std::move to the parameter newName. Typically, std::move is used with rvalue references, but in this case, we know that (1) newName is a completely independent object from whatever the caller passed in, so changing newName won’t affect callers and (2) this is the final use of newName, so moving from it won’t have any impact on the rest of the function.

The fact that there’s only one addName function explains how we avoid code duplication, both in the source code and the object code. We’re not using a universal reference, so this approach doesn’t lead to bloated header files, odd failure cases, or confounding error messages. But what about the efficiency of this design? We’re passing *by value*. Isn’t that expensive?

In C++98, it was a reasonable bet that it was. No matter what callers passed in, the parameter newName would be created by *copy construction*. In C++11, however, add Name will be copy constructed only for lvalues. For rvalues, it will be *move constructed*. Here, look:

Widget w;

…

std::string name("Bart");

w.addName(name); // call addName with lvalue

…

w.addName(name + "Jenne"); // call addName with rvalue

// (see below)

**Item 41 \| 283**

In the first call to addName (when name is passed), the parameter newName is initialized with an lvalue. newName is thus copy constructed, just like it would be in C++98.

In the second call, newName is initialized with the std::string object resulting from a call to operator+ for std::string (i.e., the append operation). That object is an rvalue, and newName is therefore move constructed.

Lvalues are thus copied, and rvalues are moved, just like we want. Neat, huh?

It is neat, but there are some caveats you need to keep in mind. Doing that will be easier if we recap the three versions of addName we’ve considered:

class Widget { // Approach 1:

public: // overload for

void addName(**const std::string&** newName) // lvalues and

{ names.push_back(newName); } // rvalues

void addName(**std::string&&** newName)

{ names.push_back(std::move(newName)); }

…

private:

std::vector\<std::string\> names;

};

class Widget { // Approach 2:

public: // use universal

**template\<typename T\>** // reference void addName(**T&& newName**)

{ names.push_back(std::forward\<T\>(newName)); }

…

};

class Widget { // Approach 3:

public: // pass by value

void addName(**std::string** newName)

{ names.push_back(std::move(newName)); }

…

};

I refer to the first two versions as the “by-reference approaches,” because they’re both based on passing their parameters by reference.

**284 \| Item 41**

Here are the two calling scenarios we’ve examined:

Widget w;

…

std::string name("Bart");

w.addName(name); // pass lvalue

…

w.addName(name + "Jenne"); // pass rvalue

Now consider the cost, in terms of copy and move operations, of adding a name to a Widget for the two calling scenarios and each of the three addName implementations we’ve discussed. The accounting will largely ignore the possibility of compilers optimizing copy and move operations away, because such optimizations are context- and compiler-dependent and, in practice, don’t change the essence of the analysis.

• **Overloading:** Regardless of whether an lvalue or an rvalue is passed, the caller’s argument is bound to a reference called newName. That costs nothing, in terms of copy and move operations. In the lvalue overload, newName is copied into Widget::names. In the rvalue overload, it’s moved. Cost summary: one copy for lvalues, one move for rvalues.

• **Using a universal reference:** As with overloading, the caller’s argument is bound to the reference newName. This is a no-cost operation. Due to the use of std::forward, lvalue std::string arguments are copied into Widget::names, while rvalue std::string arguments are moved. The cost summary for

std::string arguments is the same as with overloading: one copy for lvalues, one move for rvalues.

Item 25 explains that if a caller passes an argument of a type other than std::string, it will be forwarded to a std::string constructor, and that could cause as few as zero std::string copy or move operations to be performed.

Functions taking universal references can thus be uniquely efficient. However, that doesn’t affect the analysis in this Item, so we’ll keep things simple by assuming that callers always pass std::string arguments.

• **Passing by value:** Regardless of whether an lvalue or an rvalue is passed, the parameter newName must be constructed. If an lvalue is passed, this costs a copy construction. If an rvalue is passed, it costs a move construction. In the body of the function, newName is unconditionally moved into Widget::names. The cost summary is thus one copy plus one move for lvalues, and two moves for rvalues.

Compared to the by-reference approaches, that’s one extra move for both lvalues and rvalues.

**Item 41 \| 285**

Look again at this Item’s title:

Consider pass by value for copyable parameters that are cheap to move

and always copied.

It’s worded the way it is for a reason. Four reasons, in fact:

1\. You should only *consider* using pass by value. Yes, it requires writing only one function. Yes, it generates only one function in the object code. Yes, it avoids the issues associated with universal references. But it has a higher cost than the alternatives, and, as we’ll see below, in some cases, there are expenses we haven’t yet discussed.

2\. Consider pass by value only for *copyable parameters*. Parameters failing this test must have move-only types, because if they’re not copyable, yet the function always makes a copy, the copy must be created via the move constructor.2 Recall that the advantage of pass by value over overloading is that with pass by value, only one function has to be written. But for move-only types, there is no need to provide an overload for lvalue arguments, because copying an lvalue entails calling the copy constructor, and the copy constructor for move-only types is disabled. That means that only rvalue arguments need to be supported, and in that case, the “overloading” solution requires only one overload: the one taking an rvalue reference.

Consider a class with a std::unique_ptr\<std::string\> data member and a setter for it. std::unique_ptr is a move-only type, so the “overloading”

approach to its setter consists of a single function:

class Widget {

public:

…

void setPtr(**std::unique_ptr\<std::string\>&&** ptr)

{ p = **std::move(ptr)**; }

private:

std::unique_ptr\<std::string\> p;

};

A caller might use it this way:

2 Sentences like this are why it’d be nice to have terminology that distinguishes copies made via copy operations from copies made via move operations.

**286 \| Item 41**

Widget w;

…

w.setPtr(**std::make_unique\<std::string\>("Modern C++")**); Here the rvalue std::unique_ptr\<std::string\> returned from

std::make_unique (see Item 21) is passed by rvalue reference to setPtr, where it’s moved into the data member p. The total cost is one move.

If setPtr were to take its parameter by value,

class Widget {

public:

…

void setPtr(**std::unique_ptr\<std::string\>** ptr)

{ p = std::move(ptr); }

…

};

the same call would move construct the parameter ptr, and ptr would then be move assigned into the data member p. The total cost would thus be two moves

—twice that of the “overloading” approach.

3\. Pass by value is worth considering only for parameters that are *cheap to move*.

When moves are cheap, the cost of an extra one may be acceptable, but when they’re not, performing an unnecessary move is analogous to performing an unnecessary copy, and the importance of avoiding unnecessary copy operations is what led to the C++98 rule about avoiding pass by value in the first place!

4\. You should consider pass by value only for parameters that are *always copied*. To see why this is important, suppose that before copying its parameter into the names container, addName checks to see if the new name is too short or too long.

If it is, the request to add the name is ignored. A pass-by-value implementation could be written like this:

class Widget {

public:

void addName(std::string newName)

{

**if ((newName.length() \>= minLen) &&**

**(newName.length() \<= maxLen))**

{

names.push_back(std::move(newName));

}

}

**Item 41 \| 287**

…

private:

std::vector\<std::string\> names;

};

This function incurs the cost of constructing and destroying newName, even if nothing is added to names. That’s a price the by-reference approaches wouldn’t be asked to pay.

Even when you’re dealing with a function performing an unconditional copy on a copyable type that’s cheap to move, there are times when pass by value may not be appropriate. That’s because a function can copy a parameter in two ways: via *construction* (i.e., copy construction or move construction) and via *assignment* (i.e., copy assignment or move assignment). addName uses construction: its parameter newName is passed to vector::push_back, and inside that function, newName is copy constructed into a new element created at the end of the std::vector. For functions that use construction to copy their parameter, the analysis we saw earlier is complete: using pass by value incurs the cost of an extra move for both lvalue and rvalue arguments.

When a parameter is copied using assignment, the situation is more complicated.

Suppose, for example, we have a class representing passwords. Because passwords can be changed, we provide a setter function, changeTo. Using a pass-by-value strategy, we could implement Password like this:

class Password {

public:

explicit Password(**std::string pwd**) // pass by value

: **text(std::move(pwd))** {} // *construct* text void changeTo(**std::string newPwd**) // pass by value

{ **text = std::move(newPwd);** } // *assign* text

…

private:

std::string text; // text of password

};

Storing the password as plain text will whip your software security SWAT team into a frenzy, but ignore that and consider this code:

**288 \| Item 41**

std::string initPwd("Supercalifragilisticexpialidocious"); Password p(initPwd);

There are no suprises here: p.text is constructed with the given password, and using pass by value in the constructor incurs the cost of a std::string move construction that would not be necessary if overloading or perfect forwarding were employed. All is well.

A user of this program may not be as sanguine about the password, however, because

“Supercalifragilisticexpialidocious” is found in many dictionaries. He or she may therefore take actions that lead to code equivalent to the following being executed: std::string newPassword = "Beware the Jabberwock";

p.changeTo(newPassword);

Whether the new password is better than the old one is debatable, but that’s the user’s problem. Ours is that changeTo’s use of assignment to copy the parameter newPwd probably causes that function’s pass-by-value strategy to explode in cost.

The argument passed to changeTo is an lvalue (newPassword), so when the parameter newPwd is constructed, it’s the std::string copy constructor that’s called. That constructor allocates memory to hold the new password. newPwd is then move-assigned to text, which causes the memory already held by text to be deallocated.

There are thus two dynamic memory management actions within changeTo: one to allocate memory for the new password, and one to deallocate the memory for the old password.

But in this case, the old password (“Supercalifragilisticexpialidocious”) is longer than the new one (“Beware the Jabberwock”), so there’s no need to allocate or deallocate anything. If the overloading approach were used, it’s likely that none would take place:

class Password {

public:

…

void changeTo(**const std::string& newPwd**) // the overload

{ // for lvalues

**text = newPwd;** // can reuse text's memory if

// text.capacity() \>= newPwd.size()

}

…

**Item 41 \| 289**

private:

std::string text; // as above

};

In this scenario, the cost of pass by value includes an extra memory allocation and deallocation—costs that are likely to exceed that of a std::string move operation by orders of magnitude.

Interestingly, if the old password were shorter than the new one, it would typically be impossible to avoid an allocation-deallocation pair during the assignment, and in that case, pass by value would run at about the same speed as pass by reference. The cost of assignment-based parameter copying can thus depend on the values of the objects participating in the assignment! This kind of analysis applies to any parameter type that holds values in dynamically allocated memory. Not all types qualify, but many—including std::string and std::vector—do.

This potential cost increase generally applies only when lvalue arguments are passed, because the need to perform memory allocation and deallocation typically occurs only when true copy operations (i.e., not moves) are performed. For rvalue arguments, moves almost always suffice.

The upshot is that the extra cost of pass by value for functions that copy a parameter using assignment depends on the type being passed, the ratio of lvalue to rvalue arguments, whether the type uses dynamically allocated memory, and, if so, the implementation of that type’s assignment operators and the likelihood that the memory associated with the assignment target is at least as large as the memory associated with the assignment source. For std::string, it also depends on whether the implementation uses the small string optimization (SSO—see Item 29) and, if so, whether the values being assigned fit in the SSO buffer.

So, as I said, when parameters are copied via assignment, analyzing the cost of pass by value is complicated. Usually, the most practical approach is to adopt a “guilty until proven innocent” policy, whereby you use overloading or universal references instead of pass by value unless it’s been demonstrated that pass by value yields acceptably efficient code for the parameter type you need.

Now, for software that must be as fast as possible, pass by value may not be a viable strategy, because avoiding even cheap moves can be important. Moreover, it’s not always clear how many moves will take place. In the Widget::addName example, pass by value incurs only a single extra move operation, but suppose that Widget::add Name called Widget::validateName, and this function also passed by value. (Presumably it has a reason for always copying its parameter, e.g., to store it in a data structure of all values it validates.) And suppose that validateName called a third function that also passed by value…

**290 \| Item 41**

You can see where this is headed. When there are chains of function calls, each of which employs pass by value because “it costs only one inexpensive move,” the cost for the entire chain of calls may not be something you can tolerate. Using by-reference parameter passing, chains of calls don’t incur this kind of accumulated overhead.

An issue unrelated to performance, but still worth keeping in mind, is that pass by value, unlike pass by reference, is susceptible to *the slicing problem*. This is well-trod C++98 ground, so I won’t dwell on it, but if you have a function that is designed to accept a parameter of a base class type *or any type derived from it*, you don’t want to declare a pass-by-value parameter of that type, because you’ll “slice off” the derived-class characteristics of any derived type object that may be passed in: class Widget { … }; // base class

class SpecialWidget: public Widget { … }; // derived class

void processWidget(**Widget** w); // func for any kind of Widget,

// including derived types;

… // *suffers from slicing problem*

SpecialWidget sw;

…

processWidget(sw); // processWidget sees a

// Widget, not a SpecialWidget!

If you’re not familiar with the slicing problem, search engines and the Internet are your friends; there’s lots of information available. You’ll find that the existence of the slicing problem is another reason (on top of the efficiency hit) why pass by value has a shady reputation in C++98. There are good reasons why one of the first things you probably learned about C++ programming was to avoid passing objects of user-defined types by value.

C++11 doesn’t fundamentally change the C++98 wisdom regarding pass by value. In general, pass by value still entails a performance hit you’d prefer to avoid, and pass by value can still lead to the slicing problem. What’s new in C++11 is the distinction between lvalue and rvalue arguments. Implementing functions that take advantage of move semantics for rvalues of copyable types requires either overloading or using universal references, both of which have drawbacks. For the special case of copyable, cheap-to-move types passed to functions that always copy them and where slicing is not a concern, pass by value can offer an easy-to-implement alternative that’s nearly as efficient as its pass-by-reference competitors, but avoids their disadvantages.

**Item 41 \| 291**

**Things to Remember**

• For copyable, cheap-to-move parameters that are always copied, pass by value may be nearly as efficient as pass by reference, it’s easier to implement, and it can generate less object code.

• Copying parameters via construction may be significantly more expensive than copying them via assignment.

• Pass by value is subject to the slicing problem, so it’s typically inappropriate for base class parameter types.

**Item 42: Consider emplacement instead of insertion.**

If you have a container holding, say, std::strings, it seems logical that when you add a new element via an insertion function (i.e., insert, push_front, push_back, or, for std::forward_list, insert_after), the type of element you’ll pass to the function will be std::string. After all, that’s what the container has in it.

Logical though this may be, it’s not always true. Consider this code:

std::vector\<std::string\> vs; // container of std::string

vs.push_back(**"xyzzy"** ); // add string literal Here, the container holds std::strings, but what you have in hand—what you’re actually trying to push_back—is a string literal, i.e., a sequence of characters inside quotes. A string literal is not a std::string, and that means that the argument you’re passing to push_back is not of the type held by the container.

push_back for std::vector is overloaded for lvalues and rvalues as follows: template \<class T, // from the C++11

class Allocator = allocator\<T\>\> // Standard

class vector {

public:

…

void push_back(const T& x); // insert lvalue

void push_back(T&& x); // insert rvalue

…

};

In the call

vs.push_back("xyzzy");

**292 \| Item 41**

compilers see a mismatch between the type of the argument (const char\[6\]) and the type of the parameter taken by push_back (a reference to a std::string). They address the mismatch by generating code to create a temporary std::string object from the string literal, and they pass that temporary object to push_back. In other words, they treat the call as if it had been written like this:

vs.push_back(**std::string(**"xyzzy" **)**); // create temp. std::string

// and pass it to push_back

The code compiles and runs, and everybody goes home happy. Everybody except the performance freaks, that is, because the performance freaks recognize that this code isn’t as efficient as it should be.

To create a new element in a container of std::strings, they understand, a std::string constructor is going to have to be called, but the code above doesn’t make just one constructor call. It makes two. And it calls the std::string destructor, too. Here’s what happens at runtime in the call to push_back:

1\. A temporary std::string object is created from the string literal "xyzzy". This object has no name; we’ll call it *temp*. Construction of *temp* is the first std::string construction. Because it’s a temporary object, *temp* is an rvalue.

2\. *temp* is passed to the rvalue overload for push_back, where it’s bound to the rvalue reference parameter x. A copy of x is then constructed in the memory for the std::vector. This construction—the *second* one—is what actually creates a new object inside the std::vector. (The constructor that’s used to copy x into the std::vector is the move constructor, because x, being an rvalue reference, gets cast to an rvalue before it’s copied. For information about the casting of

rvalue reference parameters to rvalues, see Item 25.)

3\. Immediately after push_back returns, *temp* is destroyed, thus calling the std::string destructor.

The performance freaks can’t help but notice that if there were a way to take the string literal and pass it directly to the code in step 2 that constructs the std::string object inside the std::vector, we could avoid constructing and destroying *temp*.

That would be maximally efficient, and even the performance freaks could content-edly decamp.

Because you’re a C++ programmer, there’s an above-average chance you’re a performance freak. If you’re not, you’re still probably sympathetic to their point of view. (If you’re not at all interested in performance, shouldn’t you be in the Python room down the hall?) So I’m pleased to tell you that there is a way to do exactly what is **Item 42 \| 293**

needed for maximal efficiency in the call to push_back. It’s to not call push_back.

push_back is the wrong function. The function you want is emplace_back.

emplace_back does exactly what we desire: it uses whatever arguments are passed to it to construct a std::string directly inside the std::vector. No temporaries are involved:

vs. **emplace_back**("xyzzy"); // construct std::string inside

// vs directly from "xyzzy"

emplace_back uses perfect forwarding, so, as long as you don’t bump into one of perfect forwarding’s limitations (see Item 30), you can pass any number of arguments

of any combination of types through emplace_back. For example, if you’d like to create a std::string in vs via the std::string constructor taking a character and a repeat count, this would do it:

vs.emplace_back(50, 'x'); // insert std::string consisting

// of 50 'x' characters

emplace_back is available for every standard container that supports push_back.

Similarly, every standard container that supports push_front supports

emplace_front. And every standard container that supports insert (which is all but std::forward_list and std::array) supports emplace. The associative containers offer emplace_hint to complement their insert functions that take a “hint”

iterator, and std::forward_list has emplace_after to match its insert_after.

What makes it possible for emplacement functions to outperform insertion functions is their more flexible interface. Insertion functions take *objects to be inserted*, while emplacement functions take *constructor arguments for objects to be inserted*. This difference permits emplacement functions to avoid the creation and destruction of temporary objects that insertion functions can necessitate.

Because an argument of the type held by the container can be passed to an emplacement function (the argument thus causes the function to perform copy or move construction), emplacement can be used even when an insertion function would require no temporary. In that case, insertion and emplacement do essentially the same thing.

For example, given

std::string queenOfDisco("Donna Summer");

both of the following calls are valid, and both have the same net effect on the container:

vs. **push_back**(queenOfDisco); // copy-construct queenOfDisco

// at end of vs

vs. **emplace_back**(queenOfDisco); // ditto

**294 \| Item 42**

Emplacement functions can thus do everything insertion functions can. They sometimes do it more efficiently, and, at least in theory, they should never do it less efficiently. So why not use them all the time?

Because, as the saying goes, in theory, there’s no difference between theory and practice, but in practice, there is. With current implementations of the Standard Library, there are situations where, as expected, emplacement outperforms insertion, but, sadly, there are also situations where the insertion functions run faster. Such situations are not easy to characterize, because they depend on the types of arguments being passed, the containers being used, the locations in the containers where insertion or emplacement is requested, the exception safety of the contained types’ constructors, and, for containers where duplicate values are prohibited (i.e., std::set, std::map, std::unordered_set, std::unordered_map), whether the value to be added is already in the container. The usual performance-tuning advice thus applies: to determine whether emplacement or insertion runs faster, benchmark them both.

That’s not very satisfying, of course, so you’ll be pleased to learn that there’s a heuristic that can help you identify situations where emplacement functions are most likely to be worthwhile. If all the following are true, emplacement will almost certainly outperform insertion:

• **The value being added is constructed into the container, not assigned.** The example that opened this Item (adding a std::string with the value "xyzzy" to a std::vector vs) showed the value being added to the end of vs—to a place where no object yet existed. The new value therefore had to be constructed into the std::vector. If we revise the example such that the new std::string goes into a location already occupied by an object, it’s a different story. Consider: std::vector\<std::string\> vs; // as before

… // add elements to vs

**vs.emplace**(**vs.begin()**, "xyzzy"); // add "xyzzy" to

// *beginning* of vs

For this code, few implementations will construct the added std::string into the memory occupied by vs\[0\]. Instead, they’ll move-assign the value into place.

But move assignment requires an object to move from, and that means that a temporary object will need to be created to be the source of the move. Because the primary advantage of emplacement over insertion is that temporary objects are neither created nor destroyed, when the value being added is put into the container via assignment, emplacement’s edge tends to disappear.

Alas, whether adding a value to a container is accomplished by construction or assignment is generally up to the implementer. But, again, heuristics can help.

**Item 42 \| 295**

Node-based containers virtually always use construction to add new values, and most standard containers are node-based. The only ones that aren’t are

std::vector, std::deque, and std::string. (std::array isn’t, either, but it doesn’t support insertion or emplacement, so it’s not relevant here.) Within the non-node-based containers, you can rely on emplace_back to use construction instead of assignment to get a new value into place, and for std::deque, the same is true of emplace_front.

• **The argument type(s) being passed differ from the type held by the container.**

Again, emplacement’s advantage over insertion generally stems from the fact that its interface doesn’t require creation and destruction of a temporary object when the argument(s) passed are of a type other than that held by the container. When an object of type T is to be added to a *container*\<T\>, there’s no reason to expect emplacement to run faster than insertion, because no temporary needs to be created to satisfy the insertion interface.

• **The container is unlikely to reject the new value as a duplicate.** This means that the container either permits duplicates or that most of the values you add will be unique. The reason this matters is that in order to detect whether a value is already in the container, emplacement implementations typically create a node with the new value so that they can compare the value of this node with existing container nodes. If the value to be added isn’t in the container, the node is linked in. However, if the value is already present, the emplacement is aborted and the node is destroyed, meaning that the cost of its construction and destruction was wasted. Such nodes are created for emplacement functions more often than for insertion functions.

The following calls from earlier in this Item satisfy all the criteria above. They also run faster than the corresponding calls to push_back.

vs.emplace_back("xyzzy"); // construct new value at end of

// container; don't pass the type in

// container; don't use container

// rejecting duplicates

vs.emplace_back(50, 'x'); // ditto

When deciding whether to use emplacement functions, two other issues are worth keeping in mind. The first regards resource management. Suppose you have a container of std::shared_ptr\<Widget\>s,

std::list\<std::shared_ptr\<Widget\>\> ptrs;

and you want to add a std::shared_ptr that should be released via a custom deleter (see Item 19). Item 21 explains that you should use std::make_shared to create **296 \| Item 42**

std::shared_ptrs whenever you can, but it also concedes that there are situations where you can’t. One such situation is when you want to specify a custom deleter. In that case, you must use new directly to get the raw pointer to be managed by the std::shared_ptr.

If the custom deleter is this function,

void killWidget(Widget\* pWidget);

the code using an insertion function could look like this:

ptrs. **push_back**(std::shared_ptr\<Widget\>(new Widget, killWidget)); It could also look like this, though the meaning would be the same:

ptrs. **push_back**({ new Widget, killWidget });

Either way, a temporary std::shared_ptr would be constructed before calling push_back. push_back’s parameter is a reference to a std::shared_ptr, so there has to be a std::shared_ptr for this parameter to refer to.

The creation of the temporary std::shared_ptr is what emplace_back would avoid, but in this case, that temporary is worth far more than it costs. Consider the following potential sequence of events:

1\. In either call above, a temporary std::shared_ptr\<Widget\> object is constructed to hold the raw pointer resulting from “new Widget”. Call this object *temp*.

2\. push_back takes *temp* by reference. During allocation of a list node to hold a copy of *temp*, an out-of-memory exception gets thrown.

3\. As the exception propagates out of push_back, *temp* is destroyed. Being the sole std::shared_ptr referring to the Widget it’s managing, it automatically releases that Widget, in this case by calling killWidget.

Even though an exception occurred, nothing leaks: the Widget created via “new Widget” in the call to push_back is released in the destructor of the

std::shared_ptr that was created to manage it ( *temp*). Life is good.

Now consider what happens if emplace_back is called instead of push_back: ptrs. **emplace_back**(new Widget, killWidget);

1\. The raw pointer resulting from “new Widget” is perfect-forwarded to the point inside emplace_back where a list node is to be allocated. That allocation fails, and an out-of-memory exception is thrown.

**Item 42 \| 297**

2. As the exception propagates out of emplace_back, the raw pointer that was the only way to get at the Widget on the heap is lost. That Widget (and any resources it owns) is leaked.

In this scenario, life is *not* good, and the fault doesn’t lie with std::shared_ptr. The same kind of problem can arise through the use of std::unique_ptr with a custom deleter. Fundamentally, the effectiveness of resource-managing classes like std::shared_ptr and std::unique_ptr is predicated on resources (such as raw pointers from new) being *immediately* passed to constructors for resource-managing objects. The fact that functions like std::make_shared and std::make_unique automate this is one of the reasons they’re so important.

In calls to the insertion functions of containers holding resource-managing objects (e.g., std::list\<std::shared_ptr\<Widget\>\>), the functions’ parameter types generally ensure that nothing gets between acquisition of a resource (e.g., use of new) and construction of the object managing the resource. In the emplacement functions, perfect-forwarding defers the creation of the resource-managing objects until they can be constructed in the container’s memory, and that opens a window during which exceptions can lead to resource leaks. All standard containers are susceptible to this problem. When working with containers of resource-managing objects, you must take care to ensure that if you choose an emplacement function over its insertion counterpart, you’re not paying for improved code efficiency with diminished exception safety.

Frankly, you shouldn’t be passing expressions like “new Widget” to emplace_back or push_back or most any other function, anyway, because, as Item 21 explains, this

leads to the possibility of exception safety problems of the kind we just examined.

Closing the door requires taking the pointer from “new Widget” and turning it over to a resource-managing object in a standalone statement, then passing that object as an rvalue to the function you originally wanted to pass “new Widget” to. (Item 21

covers this technique in more detail.) The code using push_back should therefore be written more like this:

**std::shared_ptr\<Widget\> spw(new Widget,** // create Widget and **killWidget);** // have spw manage it

ptrs.push_back(**std::move(spw)**); // add spw as rvalue

The emplace_back version is similar:

**std::shared_ptr\<Widget\> spw(new Widget, killWidget);**

ptrs.emplace_back(**std::move(spw)**);

Either way, the approach incurs the cost of creating and destroying spw. Given that the motivation for choosing emplacement over insertion is to avoid the cost of a tem-298 \| Item 42

porary object of the type held by the container, yet that’s conceptually what spw is, emplacement functions are unlikely to outperform insertion functions when you’re adding resource-managing objects to a container and you follow the proper practice of ensuring that nothing can intervene between acquiring a resource and turning it over to a resource-managing object.

A second noteworthy aspect of emplacement functions is their interaction with explicit constructors. In honor of C++11’s support for regular expressions, suppose you create a container of regular expression objects:

std::vector\<std::regex\> regexes;

Distracted by your colleagues’ quarreling over the ideal number of times per day to check one’s Facebook account, you accidentally write the following seemingly mean-ingless code:

regexes. **emplace_back**(nullptr); // add nullptr to container

// of regexes?

You don’t notice the error as you type it, and your compilers accept the code without complaint, so you end up wasting a bunch of time debugging. At some point, you discover that you have inserted a null pointer into your container of regular expressions. But how is that possible? Pointers aren’t regular expressions, and if you tried to do something like this,

std::regex r = nullptr; // error! won't compile

compilers would reject your code. Interestingly, they would also reject it if you called push_back instead of emplace_back:

regexes. **push_back**(nullptr); // error! won't compile

The curious behavior you’re experiencing stems from the fact that std::regex objects can be constructed from character strings. That’s what makes useful code like this legal:

**std::regex** upperCaseWord(**"\[A-Z\]+"** );

Creation of a std::regex from a character string can exact a comparatively large runtime cost, so, to minimize the likelihood that such an expense will be incurred unintentionally, the std::regex constructor taking a const char\* pointer is explicit. That’s why these lines don’t compile:

std::regex r = nullptr; // error! won't compile

regexes.push_back(nullptr); // error! won't compile

In both cases, we’re requesting an implicit conversion from a pointer to a std::regex, and the explicitness of that constructor prevents such conversions.

**Item 42 \| 299**

In the call to emplace_back, however, we’re not claiming to pass a std::regex object. Instead, we’re passing a *constructor argument* for a std::regex object. That’s not considered an implicit conversion request. Rather, it’s viewed as if you’d written this code:

std::regex r(nullptr); // compiles

If the laconic comment “compiles” suggests a lack of enthusiasm, that’s good, because this code, though it will compile, has undefined behavior. The std::regex constructor taking a const char\* pointer requires that the pointed-to string comprise a valid regular expression, and the null pointer fails that requirement. If you write and compile such code, the best you can hope for is that it crashes at runtime. If you’re not so lucky, you and your debugger could be in for a special bonding experience.

Setting aside push_back, emplace_back, and bonding for a moment, notice how these very similar initialization syntaxes yield different results:

std::regex r1 **=** nullptr; // error! won't compile

std::regex r2**(**nullptr**)**; // compiles

In the official terminology of the Standard, the syntax used to initialize r1 (employing the equals sign) corresponds to what is known as *copy initialization*. In contrast, the syntax used to initialize r2 (with the parentheses, although braces may be used instead) yields what is called *direct initialization*. Copy initialization is not permitted to use explicit constructors. Direct initialization is. That’s why the line initializing r1 doesn’t compile, but the line initializing r2 does.

But back to push_back and emplace_back and, more generally, the insertion functions versus the emplacement functions. Emplacement functions use direct initialization, which means they may use explicit constructors. Insertion functions employ copy initialization, so they can’t. Hence:

regexes. **emplace_back**(nullptr); // compiles. Direct init permits

// use of explicit std::regex

// ctor taking a pointer

regexes. **push_back**(nullptr); // error! copy init forbids

// use of that ctor

The lesson to take away is that when you use an emplacement function, be especially careful to make sure you’re passing the correct arguments, because even explicit constructors will be considered by compilers as they try to find a way to interpret your code as valid.

**300 \| Item 42**

**Things to Remember**

• In principle, emplacement functions should sometimes be more efficient than their insertion counterparts, and they should never be less efficient.

• In practice, they’re most likely to be faster when (1) the value being added is constructed into the container, not assigned; (2) the argument type(s) passed differ from the type held by the container; and (3) the container won’t reject the value being added due to it being a duplicate.

• Emplacement functions may perform type conversions that would be rejected by insertion functions.

**Item 42 \| 301**

**Index**

**Symbols**

arguments, 15-17

&&, meanings of, 164

decay, definition of, 15

0 (zero)

parameters, 16

overloading and, 59

reference to, 16

templates and, 60

size, deducing, 16

type of, 58

auto, 37-48

= (equals sign), assignment vs. initialization, 50

advantages of, 38-41

=default, 112, 152, 257

braced initializers and, 21-23

=delete (see deleted functions)

code readability and, 42

maintenance and, 42

**A**

proxy classes and, 43-46

refactoring and, 42

Abrahams, David, xiv

reference collapsing and, 201

"Adventure", allusion to, 295

return type deduction and braced initializ‐

Alexandrescu, Andrei, xiii

ers and, 21-23

alias declarations

std::initializer_list and, 21

alias templates and, 63-65

trailing return types and, 25

definition of, 63

type deduction, 18-23

reference collapsing and, 202

universal references and, 167

vs. typedefs, 63-65

vs. std::function for function objects, 39

alias templates, 63

allusions

to "Adventure", 295

**B**

to "Citizen Kane", 239

back pointers, 138

to "Jabberwocky", 289

Barry, Dave, allusion to, 33

to "Mary Poppins", 289

basic guarantee, definition of, 4

to "Star Trek", 125

Becker, Thomas, xiv

to "Star Wars", 189

big three, the, 111

to "The Hitchhiker's Guide to the Galaxy",

bitfield arguments, 214

30

boolean flags and event communication, 264

to Dave Barry, 33

Boost.TypeIndex, 34-35

to John 8:32, 164

braced initialization, 50-55

apostrophe, as digit separator, 252

auto and, 21-23

arguments, bound and unbound, 238

definition of, 50

array

perfect forwarding and, 208-209

**303**

return type deduction and, 23

event communication and, 262-266

std::initializer_lists and, 52-54

spurious wakeups and, 264

Browning, Elizabeth Barrett, 117

timing dependencies and, 264

by-reference captures, 217-219

condvar (see condition variables)

by-value capture

const

pointers and, 219

const member functions and thread safety,

problems with, 219-223

103-109

std::move and, 283

const propagation, definition of, 210

by-value parameters, std::move and, 283

const T&&, 166

pointers and type deduction, 14

**C**

vs. constexpr, 98

C with Classes, 86

constexpr, 97-103

"C++ Concurrency in Action" (book), 257

constexpr functions, 98-102

C++03, definition of, 2

restrictions on, 99-102

C++11, definition of, 2

runtime arguments and, 99

C++14, definition of, 2

constexpr objects, 97-98

C++98

interface design and, 102

definition of, 2

vs. const, 98

exception specifications, 90

constructors

c++filt, 32

constructor calls, braces vs. parentheses,

caching factory function, 136

52-55

callable objects, definition of, 5

explicit, 299-300

captures

universal references and, 180-183, 188-194

by-reference, 217

const_iterators

by-value, 219

converting to iterators, 87

default modes, 216-223

vs. iterators, 86-89

this pointer and, 220-222

contextual keywords, definition of, 83

casts

contracts, wide vs. narrow, 95

conditional vs. unconditional, 161

control blocks, 128-132

std::move vs. std::forward, 158

definition of, 128

cbegin, 87

size of, 132

cend, 87

std::shared_ptr and, 129

Cheng, Rachel, xiv

copy elision, definition of, 174

"Citizen Kane", allusion to, 239

copy of an object, definition of, 4

class templates, definition of, 5

copy operations

closures

automatic generation of, 112

closure class, definition of, 216

defaulting, 113-114

copies of, 216

definition of, 3

definition of, 5, 216

for classes declaring copy operations or

code examples (see example classes/templates;

dtor, 112

example functions/templates)

for std::atomic, 277

code reordering

implicit

std::atomic and, 273

in classes declaring move operations,

volatile and, 275

111

code smells, 263

Pimpl Idiom and, 153-154

compiler warnings, 81

relationship to destructor and resource

noexcept and, 96

management, 111

virtual function overriding and, 81

via construction vs. assignment, 288-290

condition variables