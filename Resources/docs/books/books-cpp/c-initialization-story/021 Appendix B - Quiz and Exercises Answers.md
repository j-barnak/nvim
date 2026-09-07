**Appendix B - Quiz and Exercises**

**Answers**

See the correct answers.



**The quiz from chapters 1…6**

1. 2, as a side note, for classes with a base class, you can use inheriting constructors, which

use a base class name, instead the derived class name to declare a constructor.

2. 2

3. 2

4. 3

5. 2

6. 2, 3

7. 1, auto follows the rules of template type deduction, so references and constness are

not preserved.

8. 1, 2, 3 - all answers are correct

9. 3 - since we have auto elem : vec, elem is a copy of an element from the vector, so

if we change it, the value in the vector won’t be affected.

10. 2, 3 - rvalue reference (42) can bind to a const reference or to a regular value.



**The final quiz**

1. 2

2. 2

3. 1

4. 1

5. 3

254

Appendix B - Quiz and Exercises Answers 255



6. 2

7. 2

8. 1

9. 2, aggregates and in-class member initialization available since C++14

10. 2, (move constructor prevents implicit copy constructor, see code [@C++ Insight](https://cppinsights.io/s/9a1daa06)¹⁰

11. 2, the proper element type is std::pair\<const std::string, int\>, so each time,

we’ll have a copy in the loop iteration; see chapter on deduction.

12. 3, this is the special rule for the copy list initialization, it will yield initializer_list.

13. 1, a temporary is needed for opt1.

14. 3

15. 1, initializer_list requires a copyable type; see section “Some inconvenience - non-copyable types” in the non-regular data members chapter.



**Solution to the first coding problem, NSDMI**

**Solution to the first coding problem. Run** [**@Compiler Explorer**](https://godbolt.org/z/5W8Penovj)

**struct Point** {

**double** x { 1.0 };

**double** y { 2.0 };

};

As you can see, the solution uses NSDMI to initialize x and y to the required values.



**Solution to the second coding problem, NSDMI**



¹⁰<https://cppinsights.io/s/9a1daa06>

Appendix B - Quiz and Exercises Answers 256



**Solution to the second coding problem. Run** [**@Compiler Explorer**](https://godbolt.org/z/1hq4K3Wf5)

**constexpr unsigned int** DEFAULT_CATEGORY = 4; **constexpr unsigned int** DEFAULT_FLAGS = 0x0a;

**struct SalesRecord** {

std::string name\_ {"empty"};

**double** price\_ { 1.0 };

**unsigned int** category\_ : 4 { DEFAULT_CATEGORY };

**unsigned int** flags\_ : 4 { DEFAULT_FLAGS}; };



The solution initializes data members to required values, including bit fields supported since C++20.

Appendix B - Quiz and Exercises Answers 257



**Solution to the third coding problem,** **inline**

**Solution to the Counted Type problem. Run** [**@Wandbox**](https://wandbox.org/permlink/pJApU2bA4GpXVBuU)

**struct CountedType** {

**static inline int** instanceCounter = 0;

**static inline int** maxInstanceCounter = 0;

// simple counting... only ctor and dtor implemented...

CountedType() { ++instanceCounter; ++maxInstanceCounter; }

~CountedType() {--instanceCounter; }

CountedType(**const** CountedType&) { ++instanceCounter; ++maxInstanceCounter; } };



This solution implements a default constructor, a copy constructor, and a destructor. Since we want to know the maximum number of instances, this variable is not decremented in the destructor.



**Solution to the fourth coding problem, fix code**

**Solution to the fourth problem. Run** [**@Compiler Explorer**](https://godbolt.org/z/Esd4r85Gn)

**struct SalesRec** {

std::string name\_;

**double** price\_{}; // \<\< make it 0 by default! };

**void** addPromo(std::vector\<SalesRec\>& sales, **double** discount) {

**for** (**auto**& elem : sales) // \<\< reference

elem.price\_ = (1.0-discount)\*elem.price\_;

}

**double** computeTotal(**const** std::vector\<SalesRec\>& sales) {

**double** sum{}; // \<\< set it to 0 at start

**for** (**const auto**& elem : sales) // \<\< don't copy elements

sum += elem.price\_;

Appendix B - Quiz and Exercises Answers 258

**return** sum;

}

The solution has 4 places with correct syntax. It forces price\_ and sum to be properly initialized to 0.0 at the start. Then it uses proper semantics for loop iterations.