**7. Quiz from Chapters 1…6**

Congratulations!

You’ve just completed the first half of the book! Here’s a quick quiz about special member functions and type deduction. Try answering the following questions, and then we will continue our journey :)

**1. In a class that doesn’t inherit from other types, can you declare a** **constructor using a different name than the class name?**

1. Yes

2. No

3. Yes, but it can be only named self()

**2. What operations are called in the following code? Pick one option.**

std::string s { "Hello World" };

std::string other = s;

 

1. A constructor is called for s. Then, as assignment operation is called for other.

2. A constructor is called for s, and then a copy constructor is called to create other.

3. A constructor is called for s, and then another regular constructor is called for other.

**3. Can a constructor return a value using the** **return** **statement?**

1. Yes, it’s like a regular function with a return type of a class name.

2. No, a constructor doesn’t have any return type specified.

3. Yes, though a special data member called self_return.

 

109

Quiz from Chapters 1…6 110

 

**4. Can you mix delegating constructors with data member initialization,** **like in the constructor** **Type(int a, int b)****?**

For example:

**struct Type** {

**explicit** Type(**int** a) : a\_(a) { }

**explicit** Type(**int** a, **int** b) : Type(a), b\_(b) { }

**int** a\_;

**int** b\_;

};

1. Yes.

2. Sometimes, depending on if the data members come first.

3. No, the compiler reports an error in this case.

**5. Is the following code ok?**

Product\* arr = **new** Product\[10\];

// use...

**delete** arr;

Select the true statement:

1. Yes. The code is fine and properly destroys arr.

2. This code generates a memory leak as not all elements from arr are deleted. The code

should use delete \[\] arr;

3. The code uses delete arr, which is not necessary as the compiler will properly release

all Products.

**6. Select the true statements**

1. Copy initialization considers explicit constructors and will use them if there’s a

matching one.

2. When you pass an argument to a function by value, then a copy initialization is used

to initialize the function parameter.

3. Aggregate initialization copy-initializes each subobjects or an array element for which

an initializer is provided.

Quiz from Chapters 1…6 111

 

**7. What are types of** **y** **and** **z** **variables declared below?**

**int** x = 42;

**const auto**& y = x;

**auto** z = y;

 

1. y is const int& and z is int

2. y is int& and z is int&

3. y is const int& and z is int&

**8. Which of the following statements is true about structured binding in** **C++17?**

1. Structured binding allows you to bind multiple variables to the elements of a tuple.

2. Structured binding allows you to bind multiple variables to the fields of a struct.

3. Structured binding allows you to bind multiple variables to the elements of an array.

**9. What does the following code?**

std::vector\<**int**\> vec {1, 2, 3, 4, 5}; **for** (**auto** elem : vec)

elem = 10;

 

1. The code doesn’t compile, elem cannot be bound to vec.

2. The code compiles, after the loop completes, all elements of the vector will have a value

of 10.

3. The code compiles, after the loop completes all elements are unchanged.

**10. You have** **expr x = 42;****. Select the true statements:**

1. Compiles when expr is int&.

2. Compiles when expr is int.

3. Compiles when expr is const int&.

Please write down your answers and check them in Appendix B.

**8. Non-Static Data Member**

 

**Initialization**

You’ve learned a lot of techniques related to constructors! You can initialize data members in various constructors, delegate them to reuse code, and inherit them from base classes. Yet, we can still improve on assigning default values for data members. I mentioned this feature in the first chapter, where we gave default values for aggregates. We can do the same for classes. And in this chapter, we’ll look at the full syntax and options related to this feature.

Please have a look at the example below:

**Ex 8.1. NSDMI Basics. Run** [**@Compiler Explorer**](https://godbolt.org/z/dc88fd3Y1) **class DataPacket** {

std::string data\_;

**size_t** checkSum\_ { 0 };

**size_t** serverId\_ { 0 };

**public**:

DataPacket() = **default**;

DataPacket(**const** std::string& data, **size_t** serverId)

: data\_{data}, checkSum\_{calcCheckSum(data)}, serverId\_{serverId}

{ }

// getters and setters...

};

As you can see, the data members have their default values set at the point of declaration. There’s no need to assign default values inside constructors. This feature is much better than a default constructor because it combines declaration and initialization code. This way, it’s harder to leave data members uninitialized!

Let’s explore this handy feature of Modern C++ in detail.

 

**How it works**

This section shows how the compiler “expands” the code to initialize data members.

112