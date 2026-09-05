**Chapter 11. You Know C, So C++ is Easy!**

*C++ will do for C what Algol-68 did for Algol.* \[1\]

—David L. Jones

\[1\] Algol-68 was a monster-sized language that built on the small and successful Algol-60. It was hard to understand (it had a formal specification written in denotational semantics), hard to implement, and hard to use. But it was "very powerful" or so everyone said. Algol-68

effectively killed Algol-60 by replacing it, before self-destructing in a wave of impracticality.

Some people see parallels between the two Algols and the two C's.

*If you think C++ is not overly complicated, just what is a* ***protected abstract virtual base pure virtual***

***private destructor**, and when was the last time you needed one?*

—Tom Cargill, *C++ Journal*, Fall 1990

allez-OOP!…abstraction—extracting out the essential characteristics of a thing…encapsulation—grouping together related types, data, and functions…showing some class—giving user-defined types the same privileges as predefined types…constructors and destructors…inheritance—reusing operations that are already defined…multiple inheritance—deriving from two or more base classes…overloading—having one name for the same action on different types…input/output in C++…polymorphism—runtime binding…other corners of C++…if I was going there, I wouldn't start from here…it may be crufty, but it's the only game in town…some light relief—the dead computers society

**Allez-OOP!**

You know C, so C++ is easy, right? Well, maybe. Most C++ books are three or four hundred pages of densely packed text. It's easy to get lost in a forest of detail, and not be able to see the semantic wood for the binary trees. On the other hand, for most practical purposes C++ is a superset of ANSI C.

Some of the places where it's not are listed in a table at the end of this chapter. But to benefit from the language, or even understand it fully, you have to understand the underlying concepts. This is what people mean when they talk about the "object-oriented paradigm" and the "shift in thinking" needed to program in C++. We strip away the mystique, and describe C++ in simple English, relating it to familiar C features.

It's similar to the window-interface paradigm, when we learned to rewrite our programs for the window system point of view. The control logic was turned inside-out to cope with window_main_loop. Object-oriented programing is in the same vein, but rewriting for the datatype point of view.

Object-Oriented Programming (OOP) is not a new idea; the concept has been around since Simula-67

pioneered it more than a quarter of a century ago. Object-oriented programming (naturally) involves the use of objects as the central theme. There are lots of ways to define a software object; most of them agree that a key element is grouping together data with the code that processes it, and having some fancy ways of treating it as a unit. Many programming languages refer to this type of thing as a

"class." There are some ten-dollar definitions of object-oriented programming, too. You can usually follow them only if you already know what OOP is. They generally run something like:

Object-oriented programming is characterized by inheritance and dynamic binding. C++ supports inheritance through class derivation. Dynamic binding is provided by virtual class functions. Virtual functions provide a method of encapsulating the implementation details of an inheritance hierarchy.

Well, duh! Here we'll make a lightning tour of C++, and describe only the highlights. We'll try to bring the framework of the language into sharp relief by leaving out many less important details. Our approach is to look at the key concepts of OOP, and summarize the C++ features that support each.

The concepts build on one another in the logical order in which they appear here. Some of the programming examples deliberately relate to everyday actions like squeezing juice from an orange.

Juice-squeezing is not usually achieved by software. We call functions to do it here, to focus attention on the abstraction rather than the lowest-level implementation details. First, let's summarize the terminology and describe it in terms of concepts we already know from C (see Table 11-1).

C++ was known by the name "C with classes" up until about 1985, but it now includes much, much more than this. It was quite a reasonable extension to C at that point, easy to explain, implement, and teach. Then it got caught up in a wave of enthusiasm that has not yet crested, and a lot of other features (including the metaphorical kitchen sink) were added. To halt this, it has been suggested that C++ should have "conservation of featurism": new features in C++ should be subject to growth curtailment rules, like those that apply to pub licenses in the Republic of Ireland—anyone proposing an additional one must surrender two existing ones to be withdrawn from use. You want multiple inheritance? Sure—but you have to give up exceptions and templates!

***Table 11-1. The Key Concepts of Object-Oriented Programming***

**Term Definition**

Abstraction

The process of refining away the unimportant details of an object, so that only the essential characteristics that describe it remain. Abstraction is a design activity. The other concepts are the OOP features that provide it.

Class

A user-defined type, just as int is a built-in type. The built-in types have well-defined operations (arithmetic etc.) on them, and the class mechanism must allow the programmer to specify operations on the class types he or she defines, too. Anything in a **class** is known as a **member** of the class.

Member functions of a class (the operations) are also known as **methods**.

Object

A specific variable of a class type, just as j may be a specific variable of type int. An **object** is also known as an **instance** of a class.

Encapsulation Grouping together the types, data, and functions that make up a class. In C, a header file provides a very weak example of encapsulation. It is a feeble example because it is a purely lexical convention, and the compiler knows nothing about the header file as a semantic unit.

Inheritance

This is the big one—allowing one class to receive the data structures and functions described in a simpler base class. The derived class gets the operations and data of the base class, and can specialize or customize them as needed. It can also add new data and function members. There's no example in C that suggests the concept of inheritance. C does not have anything resembling this feature.

Now C++ is a rather large language. As a concrete example, the size of a C compiler front-end might be around 40,000 lines; a C++ compiler front-end might be twice as big, or more.

![Image 148](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-248_1.png)

**Abstraction—Extracting Out the Essential Characteristics of a Thing** Object-oriented programming starts with object-oriented design. And object-oriented design starts with abstraction.

What's an "object"? Using our new-found skill of "abstraction", consider the similarities between real-world objects, say, a car and a software object. The attributes they share are shown in Table 11-2.

**Software Dogma**

**The Key Idea: Abstraction**

Abstraction is the notion of looking at a group of "somethings" (such as cars, invoices, or executing computer programs) and realizing that they have common themes. You can then ignore the unimportant differences and just record the key data items that characterize the thing (e.g., license number, amount due, or address space boundaries). When you do this, it is called "abstraction", and the types of data that you store are "abstract data types".

Abstraction sounds like a tough mathematical concept, but don't be fooled—it's actually a simplification.

***Table 11-2. Abstraction Example***

**Automobile Example**

**Object Characteristic**

**Software example: A Sorting**

**Program**

"Car"

Has a name for the whole

"sort"

thing

Input: fuel & oil

Well-defined inputs and

Input: an unordered file

outputs

Output: transportation

Output: a file of ordered records

Engine, transmission, pumps, etc. Composed of smaller self-

Modules, header files, functions,

contained objects

data structures

There are many cars and many

Can have many instantiations The implementation should allow

different types of cars

of the object

several users to sort at once, for

example, not rely on one global

temporary working space.

The fuel pump doesn't rely on or Those smaller, self-contained The routine to read records should be affect the windshield washer

objects don't interact except independent of the key comparison through well-defined

routine.

interfaces

Advancing the timing is not a

Can't directly manipulate, or The user should not need to know or normal driving task, so there is

even see, the implementation be able to take advantage of the no control accessible to the driver details

specific sort algorithm used

that directly achieves this.

(quicksort, heapsort, shellsort, etc.)

Can fit a larger engine without

Can change the

The implementor should be able to

changing the driver's controls

implementation without

substitute a better sort algorithm

![Image 149](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-249_1.png)

changing the user interface

without affecting any users.

Notice that many of the software attributes are "shoulds." OOP languages like C++ provide the features needed to move these goals from being a desired state to an easily-accomplished fact.

Abstraction is useful in software because it allows the programmer to:

• hide irrelevant detail, and concentrate on essentials.

• present a "black box" interface to the outside world. The interface specifies the valid operations on the object, but does not indicate how the object will implement them internally.

• break a complicated system down into independent components. This in turn localizes knowledge, and prevents undisciplined interaction between components.

• reuse and share code.

C supports abstraction through allowing the user to define new types (struct, enum) that are almost as convenient as the predefined types (int, char, etc. ), and to use them in a similar way.

We say "almost as convenient" because C does not allow the predefined operators (\*, \<\<, \[\], +

etc.) to be redefined for user-defined types. C++ removes this barrier. C++ also provides automatic and controlled initialization, cleanup at the end of data's lifetime, and implicit type conversion. All of this is either missing from C, or not present in so convenient a form.

Abstraction creates an abstract data type, and C++ uses the class feature to implement it. This is a view from the top down, looking at the attributes of data types. It is also possible to approach this from the bottom up, and view it in terms of encapsulation: grouping together the various data and methods that implement a type.

**Encapsulation—Grouping Together Related Types, Data, and Functions** When you bundle together an abstract data type with its operations, it is termed "encapsulation". Non-OOP languages don't have adequate mechanisms for doing this. There is no way to tell a C compiler,

"These three functions are the only valid operations on this particular struct type." There is no way to prevent a programmer from defining additional functions that access the struct in an unchecked or inconsistent manner.

**Software Dogma**

**The Key Idea— A** *Class* **Encapsulates (Bundles Together) Code with Its Related Data** When programming first evolved, assembler programs could only operate on bits and words. As high-level languages developed, they provided easy access to the growing variety of hardware operands: floats, doubles, longs, chars, and so on. Some high-level languages enforced strong typing to ensure that only operations appropriate to a variable's type could be done. This was a rudimentary form of class, as it tied together data items with the permissible operations on them. The operations were typically restricted to individual

![Image 150](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-250_1.png)

hardware instructions, like "floating-point multiply".

The next development allowed programmers to group together various data types into user-defined records (structs in C), but there was no way to restrict the functions that could manipulate the data or control access to the individual fields. If a struct was visible at all, any part of it could be modified in any way. There was no way to tie the functions to the types so that it was clear they belonged together.

The current state of the art is object-oriented programming languages that enforce data integrity by bundling together the user-defined data structures plus the user-defined functions that are allowed to operate on them. No other functions are allowed to access the data. This extends strong typing from built-in data types to user-defined data types.

**Showing Some Class—Giving User-Defined Types the Same Privileges as Predefined** **Types**

The C++ class mechanism provides OOP encapsulation. A class is the software realization of encapsulation. A class is a type, just like char, int, double, and struct rec \* are types, and so you must declare variables of the class to do anything useful. You can do pretty much anything to a class that you can do to a type, such as take its size, or declare variables of it. You can pretty much do anything to an object that you can do to a variable, for example, take its address, pass it as an argument, receive it as a function return value, make it a constant value, and so on. An object (variable of a class type) can be declared just like declaring any other variable: Vegetable carrot;

Here Vegetable is the name of a class (more about how to create the class itself shortly), and carrot is an object of that class. It's a helpful convention to start class names with a capital letter.

A C++ class allows user-defined types to:

• group together user-defined types and the operations on them.

• have the same privileges and appearance as built-in types.

• build up sophisticated types out of more basic ones.

![Image 151](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-251_1.png)

**Software Dogma**

**The Key Idea: A Class**

A class is just a user-defined type with all the operations on it.

A class is often implemented as a struct of data, grouped together with pointers-to-functions that operate on that data. The compiler imposes strong typing—ensuring that these functions are only invoked for objects of the class, and that no other functions are invoked for the objects.

The C++ class accomplishes all this. It can be compared to a struct, and indeed can be conveniently implemented as a struct. The general form is:

class *classname* {

*availability*: *declarations*

. . .

*availability*: *declarations*

};

**Availability**

The *availability* is a keyword that says who can access the declarations that follow. The *availability* will be one of the following:

public:

The declarations that come after are visible outside the class and can be set, called, and manipulated as desired. It's preferred to not make data public. This is because leaving data private keeps the metaphor complete: only the object itself can change things; outside functions have to use member functions, which ensures the data is only updated in a disciplined way.

protected: The declarations that come after are visible to functions inside this class, and to functions in classes derived from this class.

private:

The declarations that come after can only be used by the member functions of this class. Private declarations are visible outside the class (the name is known), but they are not accessible.

There are two other keywords, friend and virtual, that affect availability. These keywords apply to individual declarations, rather than whole groups of them as the ones above. Unlike the other three availability controls, friend and virtual are not followed by a colon.

friend This says that the function is not a member of the class, but can access private and protected data just as though it were. A friend can be another function or another class.

virtual We have not yet covered the concepts that motivate this, so we'll postpone explaining it till

![Image 152](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-252_1.png)

later.

I submitted a formal paper (document number X3J16/93-0121) to the C++ standardization committee, suggesting that all five of the availability keywords should begin with "p", by renaming friend to protégé (this would also promote internationalization and express the asymmetry of the relationship in a way that friend doesn't).The keyword virtual should be renamed to placeholder, and the descriptive term "pure," which has nothing to do with availability, should be renamed to "empty." This would slightly increase the lexical orthogonality in the language, and if the committee liked the experiment they could extend it to more significant semantic areas of the language. \[2\] No word yet on whether they'll go for it…

\[2\] This is not a facetious suggestion: the misnamed const keyword in standard C causes very real problems. Here is an opportunity to avoid similar problems and bring consistency to a thorny area in C++.

**Declarations**

The *declarations* are just regular C declarations of functions, types (including other classes), or data.

The class binds them together. Each function declaration in the class needs an implementation, which can be inside the class or (usually) separated out. So the whole thing may look like: class Fruit { public: peel(); slice(); juice();


};

// an instance of the class

Fruit melon;

Remember, C++ comments start with // and go to the line end.

**Programming Challenge**

**Try Compiling and Running a C++ Program…**

It's time to try a C++ program. C++ source files usually have an extension of .cpp or .cc or .C. Create such a file, type in the above code, and add a "hello world" main program.

Declare a couple of objects of the fruit class.

On many systems, you invoke the C++ compiler by:

CC fruit.cpp

Compared with C, it seems you have to shout at the C++ compiler to invoke it. Compile, and run the a.out file. Congratulations—it may not do much, but you have successfully written a C++ class.

The implementation of a member function, when placed outside its class, has some special syntactic sugar on the front.

The syntactic sugar :: says "Hey! I'm important! I refer to something in a class."

So instead of looking like the regular C function declaration, return-type functionname(parameters) {...};

member functions (also known as "methods") will have the form return-type Classname :: functionname(parameters)

{ . . . };

The :: is called "the scope resolution operator." The identifier that precedes it is a class to look in. If there's no preceding identifier, it means global scope. If the implementation of peel() is put inside the class, it might look like this:

class Fruit { public: void peel(){ printf("in peel"); }

slice();

juice();


};

And, if you separate it out, it will look like this

class Fruit { public: void peel();

slice();

juice();


};

void Fruit::peel(){ printf("in peel"); }

The two approaches are semantically equivalent, but the second is more usual and provides benefits for organizing the source more cleanly using include files. The first approach is commonly used for very short functions, and it makes the code automatically expand in line instead of causing a function call.

**Programming Challenge**

![Image 153](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-254_1.png)

**Write the Method Bodies**

Write similar bodies for slice() and juice() for the Fruit class. Copy the body of peel to start with.

1\. In a real system, these methods would presumably operate a robot arm to carry out the desired fruit preparation. In this training exercise, just make each method print out the fact that it has been invoked.

2\. Give these methods likely parameters and return types. For example, slice() should take an integer parameter indicating the desired number of slices, juice() should return a float value representing the number of cc's of juice obtained, and so on. The prototypes in the class definition will have to match the function definitions, of course.

3\. Try accessing data in the private part of the class, from inside a method and then from outside.

**How to Call a Method**

Look at the interesting way to call a function within a class. You have to prefix it with the instance, or class variable, you want it to operate on.

Fruit melon, orange, banana;

main() {

melon.slice();

orange.juice();

return 0;

}

Then the object does that operation on itself. It's quite similar to some predefined operators; when we write i++ we are saying "take the i object and do the post-increment operation on it." Invoking a member function on a class object is equivalent to the "sending a message to that object" terminology that other object-oriented languages use.

Every method has a this pointer parameter implicitly passed to it, allowing an object to refer to itself inside a method. Note how the explicit use of the this pointer can be omitted when inside a member function, and it is assumed.

class Fruit { public: void peel();

![Image 154](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-255_1.png)


} ;

void Fruit::peel(){ printf("this ptr=%p", this);

this-\>weight--;

weight--;}

Fruit apple;

printf("address of apple=%x",&apple);

apple.peel();

**Programming Challenge**

**Call the Methods**

1\. Make calls to the methods slice() and juice() that you wrote in the previous exercise.

2\. Experiment with accessing the this pointer that is the implicitly-passed first argument to every method.

**Constructors and Destructors**

Most classes have at least one constructor. This is a function that is implicitly called whenever an object of that class is created. It sets initial values in the object. There is also a corresponding clean-up function, called a "destructor," which is invoked when an object is destroyed (goes out of scope or is returned to the heap). Destructors are less common than constructors, and you write the code to handle any special termination needs, garbage collection, and so on. Some people use destructors as a bulletproof way to ensure that synchronization locks are always released on exit from appropriate scopes. So they not only clean up an object, but also the locks that the object held. Constructors and destructors are needed because no one *outside* the class is able to access the private data. Therefore, you need a privileged function *inside* the class to create an object and fill in its initial data values.

This is a bit of a leap from C, where you just initialize a variable with an assignment in its definition, or even leave it uninitialized. You can define several different constructor functions, and tell them apart by their arguments. Constructor functions always have the same name as the class, and look like this:

Classname :: Classname (arguments) { . . . };

In the fruit example:

![Image 155](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-256_1.png)

class Fruit { public: peel(); slice(); juice();

Fruit(int i, int j); // constructor

~Fruit(); // destructor


} ;

// constructor body

Fruit::Fruit(int i, int j) { weight=i; calories_per_oz=j; }

// object declarations are initialized by the constructor.

Fruit melon(4,5), banana(12,8);

Constructors are needed because classes typically contain structs with many fields, requiring sophisticated initialization. An object's constructor function will be called automatically whenever an object of that class is created, and should never be invoked explicitly by the programmer. For a global, static object, its constructor will be automatically called at program start-up, and its destructor will be called at program exit.

Constructors and destructors violate the "nothing up my sleeve" approach of C. They cause potentially large amounts of work to be done implicitly at runtime on the programmer's behalf, breaking the C

philosophy that nothing in the language should require implementation by a hidden runtime routine.

**Programming Challenge**

**Do Something Destructive**

Write a body for the Fruit destructor including a printf() statement, and declare a Fruit object in an inner scope. You will need to \#include \<stdio.h\> at the start of your program. Then recompile and run the a.out file, checking that the destructor is called when the object goes out of scope.

**Inheritance—Reusing Operations that Are Already Defined**

Single inheritance occurs when a class specializes, or refines, the data structures and methods of a single base class. That creates a hierarchy, similar to a scientific taxonomy. Each level is a specialization of the one above. Type inheritance is an essential part of OOP, and it is a concept that doesn't really exist in C. Get ready to spring forward with that "conceptual leap"!

**Software Dogma**

![Image 156](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-257_1.png)

![Image 157](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-257_2.png)

**The Key Idea: Inheritance**

Deriving one class from another such that all of the other's characteristics are automatically available. Being able to declare types which share some or all of the characteristics of previously-declared types. Being able to share some characteristics from more than one parent type.

Inheritance usually provides increasing specialization as you go from a simple base class (e.g. vehicle) to a more specific derived class (e.g. passenger car, fire truck, or delivery van). It could equally subset or extend the available operations, though. The shape class seems to be the popular example of choice in the C++ literature. From a basic shape, more specialized configurations of circle, square, and pentagon can be derived. We think it makes more sense if we first consider a real-world example of "class inheritance" in the Linnaean taxonomy of the animal kingdom (see Figure 11-1), and a similar example showing how it relates to the existing C type model.

***Figure 11-1. Two Real-World Examples of an Inheritance Hierarchy***

In the example above:

• The phylum chordata contains every creature that has a notochord (roughly, a spinal cord), and only those creatures. There are 32 phyla in the animal kingdom in all.

• All mammals have a spinal cord. They inherit it by virtue of being "derived" from the chordata phylum. Mammals also have specialized characteristics: they feed their young milk, they have only one bone in the lower jaw, they have hair, a certain bone configuration in the inner ear, two generations of teeth, and so on.

• Primates inherit all the characteristics of mammals (including the quality of having a spinal cord, which mammals inherited from chordates). Primates are further distinguished by forward-facing eyes, a large braincase, and a particular pattern of incisor teeth.

• The hominidae family inherits everything from primates and more distant ancestors. It adds to the class the unique specialization of a number of skeletal modifications suitable for walking upright on two feet. The homo sapiens species is now the only species alive within this family.

All other species have become extinct.

To be a little more abstract, the hierarchy of types in C can be similarly analyzed:

• All types in C are either composite (types like arrays or structs, which are composed of smaller elements) or scalar. Scalar types have the property that each value is atomic (it is not composed of other types).

• The numeric types inherit all the properties of scalar types, and they have the additional quality that they record arithmetic quantities.

• The integer types inherit all the properties of numeric types, and they have the additional characteristic that they only operate on whole numbers (no fractional quantities).

The type char is a smaller range within the values in the integer family.

Although we can amuse ourselves by showing how inheritance can theoretically be applied to the familiar C types, we note that this model is of no practical use to a C programmer. C does not allow the programmer to create first class new data types, much less data types that inherit attributes from other data types. So a programmer cannot use the type hierarchy in real programs. An important part of OOP is figuring out the hierarchies of the abstract data types in your application. The major novelty that C++ provides, which cannot easily be accomplished by disciplined use of C, is inheritance.

Inheritance allows the programmer to make the type hierarchies explicit, and to use the relationships to control code.

Let's invent a class Apple that has every characteristic of fruit, and two specialized operations of its own. The two things that are done with apples that are not generally done with other kinds of fruit, are:

• bobbing for apples. You can't bob for pears, for example, as they are denser than apples and sink. Apple bobbing is implemented by the method bob_for().

• making candy apples ("toffee apples" to the British). People don't make caramel-covered grapes, not even in California. Making candy apples is implemented by the method make_candy_apple().

So we make Apple a derived class that inherits all the Fruit class operations and adds these two specializations of its own. Don't get hung up on how these methods might be implemented. Obviously, they are far removed from usual computing. Remember, we're concentrating on the new concepts, without getting caught up in specific algorithms.

**Software Dogma**

![Image 158](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-259_1.png)

**How C++ Does Inheritance**

Inheritance takes place between two classes (and not between individual functions).

An example of a base class is:

class Fruit { public: peel(); slice(); juice();


} ;

An example of class inheritance is:

class Apple**: public Fruit** {

public:

void make_candy_apple(float weight);

void bob_for(int tub_id, int

number_of_attempts);

}

An example object declaration is:

Apple teachers;

The example says that class Apple is a specialization of the base class Fruit. The public keyword on the first line of the inherited Apple class controls accessibility into the base class from outside the derived class. It is one of several possibilities too detailed to cover fully here.

The syntax for inheritance is uncomfortable at first. The derived class name is followed by a colon followed by the base class name. It's terse, it doesn't provide much of a hint which is the base class and which the derived, and it doesn't convey any suggestion of specialization. It's not based on an existing C idiom, so orthogonality can't guide us.

Don't confuse nesting one class inside another with inheritance. Nesting just brings one class into another with no special privileges or relationship. Nesting is often used to bring in a container class (a class that implements some data structure, like a linked list, hash table, queue, etc.). Now that templates have been added to C++, these are being used for container classes, too.

Inheritance says *the derived class is a variation of the base class* and there are many detailed semantics governing how they can access each other. It's the difference between a smaller object being one part of many in a larger object (nesting), and one object being a specialization of a more general parent object (inheritance). We wouldn't say that a mammal is nested in a dog; we may say that dogs inherit mammalian characteristics. Figure out which situation you have, and use the appropriate idiom.

![Image 159](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-260_1.png)

![Image 160](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-260_2.png)

**Multiple Inheritance—Deriving from Two or More Base Classes** *C makes it easy to shoot yourself in the foot. C++ makes it harder, but when you do, it blows away* *your whole leg.*

—Bjarne Stroustrup

Multiple inheritance allows two classes to be combined into one, so that objects of the resulting class would behave as objects of either class. It turns a tree hierarchy into a lattice.

Continuing our Fruit metaphor, we might also have a class Sauces, and note that some objects that are fruits can also be used as sauces. This gives a type hierarchy featuring multiple inheritance that can be represented as:

Some likely object declarations would be:

FruitSauce orange, cranberry; // Instances that are sauce and

fruit

Multiple inheritance is much less common than single inheritance, and has been the subject of considerable debate as to whether it should be in the language at all. It's not in other OOP languages like Smalltalk. It is in other OOP languages like Eiffel. We should note that, in practice, type hierarchies tend to look much more like Figure 11-2 than like Figure 11-3.

***Figure 11-2. Direct Inheritance***

***Figure 11-3. Multiple Inheritance***

![Image 161](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-261_1.png)

Multiple inheritance seems a difficult, error-prone feature in both implementation and use. Some people say that no convincing examples have been produced where there was no alternative design avoiding multiple inheritance.

**Overloading—Having One Name for the Same Action on Different Types** Overloading simply means reusing an existing name, but using it to operate on different types. The name can be the name of a function, or it can be an operator symbol. Operator overloading is already present in C in a rudimentary way. Virtually all languages over-load operators for built-in types.

double e,f,g;

int i,j,k;

. . .

e = f+g; /\* floating-point addition \*/

i = j+k; /\* integer addition \*/

The + operation is different in the two cases. The first will generate a floating-point add instruction, and the second an integer add instruction. Since the same conceptual operation is being performed, the name or operator should be the same. Since C++ allows the creation of new types, the programmer is given the ability to overload names and operators for those new types too. Overloading allows programmers to reuse function names and most operators, +, =, \*, -, \[\], and (), giving them additional meanings for user-defined class types. This is all part of the OOP philosophy of treating objects as a composite whole.

Overloading (by definition) is always resolved at compile time. The compiler looks at the types of the operands, and checks that it has seen a declaration of that operator for those types. In order to conserve programmer sanity, you should only overload an operator for a similar operation; don't overload \* so that it now does division.

**How C++ Does Operator Overloading**

As an example, let's overload the "+" operator, and define addition for the Fruit class. First add the prototype for the operator to the class:

class Fruit { public: void peel(); slice(); juice();

int operator+(Fruit &f); // overload "+"

operator


} ;

Then provide a body for the overloaded operator function:

int Fruit::operator+(Fruit &f) {

printf("calling fruit addition\n"); // just so we

can see

return weight + f.weight;

}

As before, every method is passed an implicit this pointer, allowing us to reference the left operand of the operator. The right operand of the addition is the parameter called f here; it is an instance of Fruit, and the preceding ampersand indicates it is passed by reference.

The overloaded function can be called like this:

Apple apple;

Fruit orange;

int ounces = apple+orange;

The precedence and number of operands ("arity" in compiler jargon) remain the same for the overloaded operator as for the original operator. So, you see, C++ says you *can* add apples to oranges, if you define it first. C++ gives the phrase "operator error" a whole new class of meanings.

Overloading is also very convenient in C++ I/O, described in the next section.

**Input/Output in C++**

As well as having the stdio library of C, C++ features some new I/O routines and concepts of its own.

There is an I/O interface known as iostream.h that helps to make I/O more convenient \[3\] and more in tune with the object-oriented philosophy.

\[3\] Don't confuse the C++ iostream (formerly known as streams) I/O interface with the unrelated UNIX kernel STREAMS framework for communicating between a device driver and a user process.

The operators \<\< (to put, or "insert") and \>\> (to get, or "extract") are used instead of functions like putchar() and getchar().

![Image 162](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-263_1.png)

The \<\< and \>\> operators are still used for shift left and right as in C, but they are overloaded for C++

I/O. The compiler looks at the types of their operands to decide whether to generate code for a shift, or for I/O. If the leftmost operand is a stream, I/O was intended. Using operators, not functions, has four big advantages:

• The operators can be defined for every type. Thus, we do not need an individual function or (equivalently) a string format specifier like "%d" for each different type.

• There is some notational convenience in using an operator rather than a function when you wish to output multiple messages. Just as you can write an expression i+j+k+l, the left-associativity of the operator ensures that you can sensibly chain multiple I/O operands together:

•

cout \<\< "the value is " \<\< i \<\< endl;

• It provides an additional layer that simplifies format control and the use of functions like scanf(). Let's face it, the scanf() family could certainly use a bit of simplifying (despite the fact that the manual for it is quite short).

• It is possible, and desirable, to overload the extract and insert operators (as these double chevrons are called) for reading and writing an entire object as a single operation. This is just an application of overloading as shown in the previous section.

You can make do with C's stdio.h functions in C++, but it's worthwhile to switch to the C++

features at an early point.

**Polymorphism—Runtime Binding**

Everyone has played nethack, so everyone knows that polymorphism is Greek for "many shapes." In C++ it means supporting different methods for related objects, and allowing runtime binding to the appropriate one. The mechanism by which this is supported in C++ is *overloading*—all the polymorphic methods are given the same name, and the runtime system figures out which one is the appropriate one. This is needed when you inherit: sometimes it's not possible to tell at compile time whether you have an object of the base class or the inheriting class. The process of figuring this out and calling the right method is called "late binding," and you tell the compiler you want it by applying the virtual keyword to a method.

With ordinary compile-time overloading the signature of the functions must differ enough so that the compiler can tell by looking at the argument types which function is intended. With virtual functions the signatures must be identical and the polymorphism is resolved at run time. Polymorphism is the last highlight of C++ that we will cover, and it is easier to explain with a code example than with text.

**Software Dogma**

**The Key Idea: Polymorphism**

Polymorphism refers to the ability to have one name for a function or an operator, and use it for several different derived class types. Each object will carry out a different variant of the operation in a manner appropriate to itself. It starts with "overloading" a name—reusing the same name to represent the same concept with different objects. It is useful because it means that you can give similar things similar names. The polymorphism comes in when the runtime system selects which of these identically named functions is the right one.

Let's start by considering our familiar base class of Fruit and adding a method to peel a fruit object.

Once again, we won't fill in the details of peeling, just have it print a message.

\#include \<stdio.h\>

class Fruit { public: void peel(){printf("peeling a base class fruit\n");}

slice();

juice();


} ;

When we declare a fruit object, and invoke the peel() method like this, Fruit banana;

banana.peel();

we will get the message

peeling a base class fruit

So far, so good. Now consider deriving our apple class, and *giving this its own method for peeling!*

After all, apples are peeled somewhat differently than bananas: you can peel a banana with your thumbs, but you need a knife to peel an apple. We know we can have methods with the same name, as C++ can cope with overloading.

class Apple : public Fruit {

public:

void peel() {printf("peeling an apple\n");}

void make_candy_apple(float weight);

};

Let's declare a pointer to a fruit, then make it point to an apple object (which inherits from the fruit class), and see what happens when we try peeling.

Fruit \* p;

p = new Apple;

p-\>peel();

![Image 163](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-265_1.png)

Whoa! If you try it, you'll get output like this:

% CC fruits.cpp

% a.out

peeling a base class fruit

In other words, the Apple-specific method peel() wasn't called, the base class's peel() was!

**Explanation**

The reason is that C++ demands that you warn it when you start supplanting base class methods with derived class ones. You warn it by adding the keyword virtual to the base class method that you might be replacing. You can see now why we were reticent about explaining virtual back on page 301 where we first discovered it. You needed a lot of background information, which we have now covered.

**Handy Heuristic**

**Virtually Impractical**

Why isn't virtual the default? After all, you can always get the method from the base class by saying:

p-\>Fruit::peel();

It's pretty much for the same reason that C originally used the register keyword—it's a dumb optimization. So that every method call doesn't involve an extra indirection at runtime, you have to tell the compiler which ones do.

The word virtual is a bit of a misnomer in this context. Elsewhere throughout computer science,

"virtual" means letting the user see something that is not really there, and supporting the illusion by some means. Here, it means *not* letting the user see something that *is* really there (the base class method). A more meaningful (though impractically long) keyword would be choose_the_appropriate_method_at_runtime_for_whatever_object_t his_is

or more simply, placeholder.

**How C++ Does Polymorphism**

Adding the keyword virtual to our base class method, and making no other changes results in

\#include \<stdio.h\>

class Fruit {

public: virtual void peel(){printf("peeling a base class

fruit\n");}

slice(); juice();


} ;

And the compilation and execution is

% CC fruits.cpp

% a.out

peeling an apple

Exactly as desired. So far, this could all have been achieved at compile time, but polymorphism is a runtime effect. It refers to the process of C++ objects deciding at runtime which function should be called to carry out a particular operation.

The runtime system looks at the object that has called the overloaded method, and chooses the method that goes with that class of object. If this is a derived object, we don't want it to call the base class version. We want it to call the derived class version, but this may not have been seen by the compiler when the base class was compiled. Therefore, this must be done dynamically at runtime, or, in C++

terminology, "virtually."

Single inheritance is usually implemented by having each object contain a pointer vptr to a vector vtbl of function pointers. There is one of these vectors for each class, and there is one entry in the vector for each method in the class. In this way, the implementation code is shared by all objects of a given class. The vector is laid out so that a given function pointer lies at the same offset in the virtual tables for all subclasses of a class. Each method call can be mapped to a vtbl offset at compiletime.

At runtime, the call is made indirectly through the pointer at the appropriate offset. Multiple inheritance requires a slightly more complicated scheme with another layer of indirection. If that didn't make sense, draw yourself a picture of it; it's the end of the line for this particular bus.

**Fancy Pants Polymorphism**

There are a lot more fancy tricks that you can pull with polymorphism, and sometimes it's downright essential. It makes a derived class's method preferred over those of the base class, but still allows the base class ones to be used if no derived ones have been defined. Sometimes a method does not know at compiletime whether it is operating on an object of its own class or one derived from it.

Polymorphism says this has to work correctly.

main() {

Apple apple;

![Image 164](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-267_1.png)

Fruit orange;

Fruit \* p;

p=&apple;

p-\>peel();

p=&orange;

p-\>peel();

}

At runtime, the results will be:

% a.out

peeling an apple

peeling a base class fruit

**Software Dogma**

**Deep Thought—Polymorphism Has Something in Common with Interposing** Polymorphism and interposing both allow multiple functions to have the same one identifier. Interposing is a bit of a blunt instrument, as it binds every occurrence of the name to the same one definition at compile time. Polymorphism is a little more discerning, as it makes the binding decision on an object-by-object basis at runtime.

**Other Corners of C++**

There are plenty of smaller C++ concepts not covered in this brief review of the high points. And there are plenty more detailed rules that apply to the concepts mentioned here. However, if you master the material in this chapter you will have a basic understanding of the OOP concepts and how they are expressed in C++. You will have enough of a head start to begin writing experimental C++ programs.

And that is the real way, the only way, to learn any programming language.

Among the concepts not covered here, C++ also has:

• Exceptions: borrowed from Ada and also from Clu (an experimental language developed at MIT, in which the key idea is a "cluster"). These are for changing the flow of control for error-handling. They simplify some kinds of error-handling by automatically diverting processing to a part of the program that can process the error.

• Templates: support parameterized types. Like the class/object relationship, a template/function can be thought of as providing a "cookie-cutter" approach to algorithms.

Once you get the basic algorithm down, you can plug different types into it. They are similar to the generic facility in Ada and parameterized modules in Clu. They have quite complicated semantics. This code:

![Image 165](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-268_1.png)

•

template \<class T\> T min (T a, T b) { return (a \< b) ? a : b; }

allows one to assign any arbitrary type T (for which the \<

operator has been defined) to the variables a and b and the

function min. Some people refer to templates as providing

compiletime polymorphism. It's a bit of a stretch, but they mean that a stated operation can be done on a variety of different

types, and it's all figured out at compiletime.

• In-lining of functions: a programmer can stipulate that a particular function should be expanded in-line (as though it were a macro) in the instruction stream rather than generating a function call.

• The operators new and delete, to replace malloc() and free() function calls. The operators are slightly more convenient (the sizeof calculation is done implicitly for example, and the proper constructor/destructor is called). new truly creates an object, whereas malloc just allocates memory.

• Call-by-reference: C uses only call-by-value (except for arrays). C++ brings call-by-reference into the language.

**Software Dogma**

**C++ Design Goals: That Was Then. This Is Now.**

From *SIGPLAN Notices*, vol. 21, no. 10, October 1986 "An Overview of C++," by Bjarne Stroustrup

Section 6. What is Missing?

C++ was designed under severe constraints of compatibility, internal consistency, and efficiency: no feature was included that

1\. \[1\] would cause a serious incompatibility with C at the source or linker levels.

![Image 166](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-269_1.png)

2\. \[2\] would cause run-time or space overheads for a program that did not use it.

3\. \[3\] would increase run-time or space requirements for a C program.

4\. \[4\] would significantly increase the compile time compared with C.

5\. \[5\] could only be implemented by making requirements of the programming environment (linker, loader, etc.) that could not be simply and efficiently implemented in a traditional C programming environment.

Features that might have been provided but weren't because of these criteria include garbage collection, parameterized classes, exceptions, multiple inheritance, support for concurrency, and integration of the language with a programming environment. Not all of these possible extensions would actually be appropriate for C++, and unless great constraint is exercised when selecting and designing features for a language, a large, unwieldy, and inefficient mess will result. The severe constraints on the design of C++ have probably been beneficial and will continue to guide the evolution of C++.

*Ah, What years those were! The Reagan years, when tomato ketchup was a vegetable, trees* *were the major source of pollution, and C++ was assured of remaining unencumbered by* *parameterized classes, exceptions, and multiple inheritance.*

**If I Was Going There, I Wouldn't Start from Here**

There is a property of programming languages known as orthogonality. This refers to the degree to which different features follow the same underlying principles. For example, in Ada, a programmer who learns how packages work will be able to apply this knowledge to generic packages, too.

Unhappily, much of C++ is quite unorthogonal. Mastering one feature in C++ provides no clue or mental model that can be applied to other features. Most programmers will take the approach of only using a simpler subset of C++.

**Software Dogma**

**A Simple Subset of C++**

C++ features to use:

• classes

• constructors and destructors, but only with very simple bodies

• overloading, including operator overloading and C++ I/O

• single inheritance and polymorphic functions

C++ features to avoid using:

• templates

![Image 167](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-270_1.png)

• exceptions

• virtual base classes

• multiple inheritance

The major purpose of a programming language is to provide a framework for expressing problem solutions in terms which a computer can process. The better a language is at representing this discourse, the more successful it will be. The Fortran language, one of the first high-level languages, provided a powerful means of expressing mathematical formulae (the name "Fortran" means

" *For* mula *tran* slation"). The COBOL language addressed itself to file processing, decimal arithmetic and output editing. And it is highly successful in that domain. C gave systems programmers access to many hardware-supported operators. The language didn't "get in the way" with many layers of abstraction.

A language will be successful if its constructs are useful "building blocks" for solving problems in a given domain. Deciding on the "building blocks" of the language is the most important part of language design; the details, like choosing whether a semicolon is a terminator or a separator, cannot be ignored, but the building blocks are critical. How good a language C++ is will be decided on the basis of whether its features are good "building blocks" for solving interesting problems and whether the language can be reliably used by normal programmers.

Some people claim that C++ classes will revolutionize software reuse. Reuse is a nebulous goal in software. Inheritance is not necessarily the panacea that it seems. Those with long memories are reminded of inflated claims made for Ada a decade ago. Let's make an analogy by saying that a computer program is like a book. Then you have libraries of both. And you want to reuse some routines in one of your programs. This corresponds to some paragraphs in the book.

**Software Dogma**

**Design Challenge: The C++ Machine**

In the past, some people have built special-purpose computer hardware that would be very efficient at executing a particular language:

Algol-60:

early Burroughs processors

Lisp: Symbolics

Inc.

Ada: Rational

Computers

What would a C++ machine look like? Why have all special language processors come to a sticky end?

This is a trick question—there's no common theme. The market for a single language is always less than for a general machine. Workstations ate the Lisp machine for lunch. The end of the Cold War killed the Ada machine. Burroughs ploughs on as part of Unisys.

The problem is that you can't create any kind of new worthwhile text by cutting and pasting entire paragraphs from other books. The level of abstraction is wrong. You can share text on the level of individual words or letters (this corresponds to individual lines of code or characters), but the effort involved in laboriously cutting them out is higher than the effort involved in deriving them afresh for the new work. And in just the same way, software reuse at the library level has empirically turned out to be less than originally envisioned.

There is a small number of special-purpose routines that can be and are shared: mathematical libraries, a few data structure routines, and sorting and searching libraries. That's about it. These correspond to diagrams or reference tables in a book, which can be lifted wholesale and understood somewhere else.

C++ may be more successful at software reuse than previous languages because its style of inheritance, based on objects, allows data to be inherited as well as code. Ada generics allow this too, but the Ada feature is cumbersome and too abstract for most programmers. To continue the analogy above, C++

makes it easier to check books out from the library, but you still have the problem of copying the relevant parts sensibly.

![Image 168](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-272_1.png)

**It May Be Crufty \[4\], but It's the Only Game in Town**

\[4\] "Crufty / *kruhf'tee*/ \[origin unknown\] adj. possibly over-complex"— *The New Hacker's* *Dictionary*, ed. Eric Raymond, Cambridge, MA, MIT Press, 1991.

Having seen some of the serious failings in C in the first few chapters of this book, it would be really nice to say that C++ addresses these while retaining the flavor of C. It would be really nice, but it isn't going to happen, because it isn't true. C++ has some point improvements, but it retains many of the flaws of C, and piles up another big layer of complexity on top. The original C philosophy of "no features that need invisible runtime support" has been compromised.

**Software Dogma**

**Improvements in C++ Over C**

• The error-prone construct of initializing a char array without enough room for the trailing nul is regarded as an error. char b\[3\]="Bob"; will cause an error in C++, but not in C.

• A typecast can be written in the more normal-looking format of float(i) as well as the strange-looking C style of (float)i.

• C++ allows a constant integer to define the size of an array.

•

•

const int size=128;

char a\[size\];

is allowed in C++, but will generate an error message from C.

• Declarations can be intermingled with statements, dropping the C requirement that all declarations precede all statements in a block. It's great that this arbitrary rule was dropped. Since this fix causes an incompatibility with C, why not go the whole way and provide a simpler alternative that fixes the horrible C declaration syntax, too?

Although C++ may be crufty, it's the only game in town. All the major players are behind it. All new development at AT&T is said to be in C++ now. The graphics part of Windows NT (which was later, slower and bigger than expected) was written in C++. Most new software development tools, applications libraries, and advanced technologies are now written in C++, or at least the ANSI C subset of it. But how long will it be before we start to see spectacular bugs like the AT&T network shutdown, caused or aggravated by features in C++ rather than C?

![Image 169](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-273_1.png)

It doesn't matter. C++ will become widely used in spite of its flaws, and we hope it will eventually lead the way to something better.

**Handy Heuristic**

**Transitioning from C to C++**

The best way to get started with C++ is to start programming in its ANSI C subset. Avoid the early translators based on cfront, which generated C code rather than machine code.

Using C as a portable machine language really complicated linking and debugging, as cfront mangled all the function names to encode argument information. Name-mangling is a horrible kludge which will likely live on in C++ for a long time. Contrast this with Ada, which does it properly and does not define the semantics by a hacked implementation.

Name-mangling is a hack for doing type checking between different files. But it implies that all your C++ rules must be complied with the same compiler as the name-mangling scheme may differ among compilers. This is a big defect in the C++ reuse model as it effectively prevents reuse at the binary level.

Here is a representative sample of the ways that C is not a C++ subset, to give an idea of potential trouble spots.

Restrictions in C++ that are not in C:

• The main() routine may not be called by user code in C++. This is permitted (but most unusual) in C.

• Function prototypes are mandatory in C++, but optional in C.

• Typedef names cannot clash with struct tags in C++, but they can in C (they belong to separate namespaces).

• A cast is required to assign a void \* pointer to another pointer type in C++; no cast is require d in C.

• Features in C++ that mean something different in C:

• There are more than a dozen new keywords in C++. These may be used as identifiers in a C program, but such use will usually generate an error message from a C++ compiler.

• A declaration can appear anywhere a statement can in C++; in C, declarations must appear before statements in a block.

• A struct name in an inner scope will hide an object name in an outer scope in C++, but not in C.

• Character literals have type char in C++, but type int in C. That is, sizeof('a') yields 1 in C++ and a larger value in C.

• Pathological cases involving the // comment convention of C++ (as shown in Chapter 2).

There are many more differences, but you now know enough to be dangerous. So go out there and be dangerous. When you're comfortable with the compiler and all the tools working in the ANSI C

subset, then spread your wings and start defining your own classes. Choose a good C++ book—look at several, and choose one in a style you like. Make sure it is current with the language, which is still evolving. Make sure it covers exceptions and templates, which were the latest two things added.

Just as with C, C++ standardization is now a joint effort of ISO (Working Group 21), and ANSI X3J16. The most optimistic estimates predict that it will take around six years to standardize the language, finishing in 1996, but make sure your C++ book mentions the ANSI C++ direction.

**So What Is a *Protected Abstract Virtual Base Pure Virtual Private***

***Destructor*****?**

Let's break this down and take it a little bit at a time. The phrase actually decomposes into two parts: a *pure virtual private destructor* that is inherited from a *protected abstract* *virtual base*.

• A *private destructor* is the function called when an object goes out of scope.

"Private" means that it can only be called by a member or friend of the class.

• A *pure virtual* function contains no code itself, but is used to act as a guide for other derived functions through inheritance.

• A *pure virtual destructor* only makes sense if defined by a derived class. Since a destructor automatically does default clean-up actions on a class, like call member or base destructors, there is often no need to explicitly write any code in the destructor definition.

Simple enough. Tackling the second phrase

• An *abstract virtual base* means that the base class is shared by the multiply-inherited classes (it's a "virtual base"), and that it contains at least one pure virtual function, from which other classes derive through inheritance (an "abstract base").

Virtual base classes also have special initialization semantics.

• A *protected abstract virtual base* class is one we inherited "protectedly," so our children know our parentage, but outsiders don't.

So, putting it all together, a *protected abstract virtual base pure virtual private destructor* is a destructor function, that

• can only be called by members or friends of the class, and

• has no definition in the base class that declares it, but will be defined later in a derived class,

• that (refering to the derived class) shares the multiply inherited base

• which (refering to the base class) is inherited in a protected way.

And the last time we needed one was…well, we haven't yet! Does this start to remind anyone of the program proof of the Fast Fourier Transform? It certainly ranks alongside it in complexity.

In C++ code, this might look like:

class vbc {

protected: virtual void v()=0;

private: virtual ~vbc()=0; // private destructor

};

// vbc is an abstract class because it contains pure

virtual functions

classX:virtual protected vbc {

// X inherits vbc virtually, and does it in a way such

that

// vbc's protected members are protected members of X.

// So vbc is a "protected abstract virtual base" class of X.

protected: void v() {}

~X() { /\* do some X destruction \*/ }

};

// When an X object is destroyed, X::~X is called, and

then...

// X's "protected abstract virtual base pure virtual

private destructor"

// is called too. So even though it's declared pure, it

must be defined.

These are the kind of semantics that gives C++ a reputation for being overly complicated.

The problem is not any one feature, but rather the complexity of how all the different features interact. We'll stop at this point, and allow the reader to form his or her own conclusions.

**Some Light Relief—The Dead Computers Society**

There are many and varied computer-related organizations, but the prize for most unusual surely goes to The Dead Computers Society!

Modeled after the "Dead Poets Society," which was actually an appreciation group for classical rhymesters, the Dead Computers Society is an appreciation group for computer architectures that no longer exist. It started as an informal discussion panel at the 1991 ASPLOS ("Architecture Support for Programming Languages and OS's") conference in Santa Clara, California. A group of friends and colleagues attending the conference noticed that many of them had worked on systems that were now discontinued.

They decided to make light of this by forming the Dead Computers Society and holding an open forum round table on the issues involved. The hope was that an intelligent retrospective would allow future designers to learn from the lessons of the past. Membership of the Dead Computers Society is open to anyone who has helped design, build, or program a computer system that no longer exists, ideally for a company that no longer exists. There are a lot of these; a partial list is shown in Table 11-3.

***Table 11-3. Dead Computers***

**The Dead Computers Honor Roll**

American Supercomputer Inc.

Intel iPSC/1

Ametek/Symult Intel

iPSC/2

Astronautics Intel/Siemens

BiiN

Burroughs BSP

Masscomp/Concurrent

CDC 7600, Cyberplus

Multiflow

CHoPP Myrias

Culler Scientific

Niche

Cydrome Prisma

Denelcor SCS

Elxsi SSI

Evans & Sutherland CD

Star Technologies

ETA/CDC Supertek

FLEX (Flexible Computer)

Suprenum/Siemens

Goodyear Aerospace/Loral DataFlow Systems

Texas Instruments ASC

Guiltech/SAXPY Topologix

Floating Point Systems AP-line and T-series

Unisys ISP

Intel 432

On the other hand, membership is also open to anyone who just thinks it's a kind of neat idea. At the inaugural meeting, there were over 350 attendees.

The panel moderator tried to draw the members out on the "one single thing that, more than anything else, was responsible for your dead computer." The Elxsi designer said that they had tried to push the technology too much and used ECL (emitter-coupled logic) before it was ready for prime time.

However, the chief architect from Multiflow, which went down the tubes around the same time as Elxsi, felt that their decision not to use ECL was one of several factors that ultimately caused Multiflow's demise!

About the only consensus was that management and market conditions were responsible for many, many more bankruptcies than were technical failures. This is understandable; companies that don't

![Image 170](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-277_1.png)

listen to their customers *always* go out of business. Companies that try to push the state of the art often succeed.

There were some minor technical themes, like making your product hard to program (e.g. the CDC7600 with two-level memory, or one's complement arithmetic, or the cruel and unusual punishment of 60-bit words) doesn't help. It's not too surprising that no major common technical theme emerged. Maybe there isn't one. One thing is certain, though: we all learn far more from our mistakes than from our successes.

**Some Final Light Relief—Your Certificate of Merit!**

\[Instructions: cut out from book, write your name in, and hand to boss\]

**Further Reading**

One C book I have found very helpful is *C, A Reference Manual*, written by Samuel P. Harbison and Guy L. Steele, ( Englewood Cliffs, Prentice Hall, 1991). Harbison and Steele wrote this book based on their experience developing a family of C compilers for a wide range of different architectures, and their practical insights shine off every page.