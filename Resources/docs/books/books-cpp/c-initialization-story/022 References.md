**References**

Related materials and links about data member initialization in C++:

Proposals for C++ features:

• [N2756¹¹](https://wg21.link/N2756)- Non-static data member initializers for C++11,

• [P0683¹²](https://wg21.link/P0683)- Default Bit Field Initializer for C++20,

• [P0386¹³](https://wg21.link/P0386)- Inline Variables C++17,

• [P0329¹⁴](https://wg21.link/P0329)- Designated Initializers C++20,

• [P0960¹⁵](https://wg21.link/p0960) and [P1975¹⁶](https://wg21.link/p1975)- Aggregate initialization from a parenthesized list for C++20.

Valuable resources for C++:

• [C++ Standard Draft](https://timsong-cpp.github.io/cppwp/n4868/)¹⁷- N4868 (October 2020 pre-virtual-plenary working draft/C++20

plus editorial changes),

• [C++ compiler support - C++Reference](https://en.cppreference.com/w/cpp/compiler_support)¹⁸- a list of features and their compiler support

since C++11,

• [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)¹⁹- a community-edited and open guideline for C++ style, lead

by Bjarne Stroustrup and Herb Sutter.

Books:

• [“Embracing Modern C++ Safely”](https://amzn.to/3PywHTg)²⁰ by J. Lakos, V. Romeo , R. Khlebnikov, A. Meredith,

a wonderful and very detailed book about latest C++ features, from C++11 till C++14 in the 1st edition.

• [“Effective Modern C++: 42 Specific Ways to Improve Your Use of C++11 and C++14”²¹](https://amzn.to/3t5tmS4)

by Scott Meyers

¹¹<https://wg21.link/N2756>

¹²<https://wg21.link/P0683>

¹³<https://wg21.link/P0386>

¹⁴<https://wg21.link/P0329>

¹⁵<https://wg21.link/p0960>

¹⁶<https://wg21.link/p1975>

¹⁷<https://timsong-cpp.github.io/cppwp/n4868/>

¹⁸<https://en.cppreference.com/w/cpp/compiler_support>

¹⁹<https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines>

²⁰<https://amzn.to/3PywHTg>

²¹<https://amzn.to/3t5tmS4>

259

References 260



Presentations:

• [Core C++ 2019: Initialisation in modern C++²²](https://www.youtube.com/watch?v=v0jM4wm1zYA) by Timur Doumler,

• [CppCon 2018: “The Nightmare of Initialization in C “²³](https://www.youtube.com/watch?v=7DTlWPgX6zs) by Nicolai Josuttis,

• [CppCon 2021: Back To Basics: The Special Member Functions](https://www.youtube.com/watch?v=9BM5LAvNtus)²⁴ by Klaus Iglberger,

• [ACCU 2022: What Classes We Design and How](https://www.youtube.com/watch?v=fzsBZicBe88)²⁵- by Peter Sommerlad,

• [CppCon 2018 “The Bits Between the Bits: How We Get to main()”](https://www.youtube.com/watch?v=dOfucXtyEsU)²⁶- by Matt Godbolt

.

Articles and other links:

• [Non-Static Data Members Initialization - C++ Stories²⁷](https://www.cppstories.com/2015/02/non-static-data-members-initialization/)- initial source for the book,

• [What happens to your static variables at the start of the program? - C++ Stories²⁸](https://www.cppstories.com/2018/02/staticvars/),

• [Always Almost Auto Style](https://herbsutter.com/2013/08/12/gotw-94-solution-aaa-style-almost-always-auto/)²⁹ by Herb Sutter,

• [C++ Core Guidelines - C51³⁰](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c51-use-delegating-constructors-to-represent-common-actions-for-all-constructors-of-a-class) and [C52³¹](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c52-use-inheriting-constructors-to-import-constructors-into-a-derived-class-that-does-not-need-further-explicit-initialization)- about delegating and inheriting constructors,

• [Modern C++ Features - Inherited and Delegating Constructors](https://arne-mertz.de/2015/08/new-c-features-inherited-and-delegating-constructors/)³² by Arne Mertz,

• [Trivial, standard-layout, POD, and literal types](https://docs.microsoft.com/en-us/cpp/cpp/trivial-standard-layout-and-pod-types?view=msvc-170)³³ at Microsoft Docs,

• [Modern C++ Features - Uniform Initialization and initializer_list³⁴](https://arne-mertz.de/2015/07/new-c-features-uniform-initialization-and-initializer_list/) by Arne Mertz,

• [The cost of](https://akrzemi1.wordpress.com/2016/07/07/the-cost-of-stdinitializer_list/) [std::initializer_list](https://akrzemi1.wordpress.com/2016/07/07/the-cost-of-stdinitializer_list/)³⁵ by Andrzej Krzemieński,

• [Objects, their lifetimes and pointers](https://blog.panicsoftware.com/objects-their-lifetimes-and-pointers/)³⁶ by Dawid Pilarski,

• [Tutorial: When to Write Which Special Member³⁷](https://www.foonathan.net/2019/02/special-member-functions/) by Jonathan Müller,

• [The implication of const or reference member variables in C++](https://lesleylai.info/en/const-and-reference-member-variables/)³⁸ by Lesley Lai.

²²<https://www.youtube.com/watch?v=v0jM4wm1zYA>

²³<https://www.youtube.com/watch?v=7DTlWPgX6zs>

²⁴<https://www.youtube.com/watch?v=9BM5LAvNtus>

²⁵<https://www.youtube.com/watch?v=fzsBZicBe88>

²⁶<https://www.youtube.com/watch?v=dOfucXtyEsU>

²⁷<https://www.cppstories.com/2015/02/non-static-data-members-initialization/>

²⁸<https://www.cppstories.com/2018/02/staticvars/>

²⁹<https://herbsutter.com/2013/08/12/gotw-94-solution-aaa-style-almost-always-auto/>

³⁰[https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c51-use-delegating-constructors-to-represent-common-](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c51-use-delegating-constructors-to-represent-common-actions-for-all-constructors-of-a-class)

[actions-for-all-constructors-of-a-class](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c51-use-delegating-constructors-to-represent-common-actions-for-all-constructors-of-a-class)

³¹[https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c52-use-inheriting-constructors-to-import-constructors-](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c52-use-inheriting-constructors-to-import-constructors-into-a-derived-class-that-does-not-need-further-explicit-initialization)

[into-a-derived-class-that-does-not-need-further-explicit-initialization](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c52-use-inheriting-constructors-to-import-constructors-into-a-derived-class-that-does-not-need-further-explicit-initialization)

³²<https://arne-mertz.de/2015/08/new-c-features-inherited-and-delegating-constructors/>

³³<https://docs.microsoft.com/en-us/cpp/cpp/trivial-standard-layout-and-pod-types?view=msvc-170>

³⁴<https://arne-mertz.de/2015/07/new-c-features-uniform-initialization-and-initializer_list/>

³⁵<https://akrzemi1.wordpress.com/2016/07/07/the-cost-of-stdinitializer_list/>

³⁶<https://blog.panicsoftware.com/objects-their-lifetimes-and-pointers/>

³⁷<https://www.foonathan.net/2019/02/special-member-functions/>

³⁸<https://lesleylai.info/en/const-and-reference-member-variables/>