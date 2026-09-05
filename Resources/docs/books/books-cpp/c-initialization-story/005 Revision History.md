### ix

**1. Local Variables and Simple Types**

 

Let’s start simple and ask, “what is initialization?” When we go to the definition from

[C++Reference¹](https://en.cppreference.com/w/cpp/language/initialization), we can read:

 

*Initialization* of a variable provides its initial value at the time of construction.

 

We can translate this definition to the following example:

**void** foo() {

**int** x = 42;

// ... use 'x' later...

}

Above, we have a function with a local variable x. The variable is declared as integer and initialized with the value 42. This is one of many ways you can assign that initial value. Here are some more options:

**struct Point** { **int** x; **int** y; }; // declare a custom type Point createPoint(**int** x) { **return** {x,-x}; } **int** main() {

**int** x { 42 }; // list initialization

**double** y = { 100.0 }; // copy list initialization

**auto** ptr = std::make_unique\<**float**\>(90.5f); // auto type deduction

**auto** z = createPoint(42); // through a factory function

std::string s (10, 'x'); // calling a constructor

Point p { 10 }; // aggregate initialization

std::array\<**float**, 100\> numbers { 1.1f, 2.2f }; // array initialization

// ...

}

¹<https://en.cppreference.com/w/cpp/language/initialization>

 

1