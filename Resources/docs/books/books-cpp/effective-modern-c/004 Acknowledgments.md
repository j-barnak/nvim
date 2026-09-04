**Acknowledgments**

I started investigating what was then known as C++0x (the nascent C++11) in 2009. I posted numerous questions to the Usenet newsgroup comp.std.c++, and I’m grateful to the members of that community (especially Daniel Krügler) for their very help‐

[ful postings. In more recent years, I’ve turned to Stack Overflow](http://stackoverflow.com/) when I had questions about C++11 and C++14, and I’m equally indebted to that community for its help in understanding the finer points of modern C++.

In 2010, I prepared materials for a training course on C++0x (ultimately published as

[*Overview of the New C++*, Artima Publishing, 2010). Both those materials and my](http://www.artima.com/shop/overview_of_the_new_cpp)

knowledge greatly benefited from the technical vetting performed by Stephan T. Lavavej, Bernhard Merkle, Stanley Friesen, Leor Zolman, Hendrik Schober, and Anthony Williams. Without their help, I would probably never have been in a position to undertake *Effective Modern C++*. That title, incidentally, was suggested or endorsed

[by several readers responding to my 18 February 2014 blog post, “Help me name my](http://scottmeyers.blogspot.com/2014/02/help-me-name-my-book.html)

[book,” and Andrei Alexandrescu (author of](http://scottmeyers.blogspot.com/2014/02/help-me-name-my-book.html) [*Modern C++ Design*, Addison-Wesley,](http://erdani.com/index.php/books/modern-c-design/)

2001\) was kind enough to bless the title as not poaching on his terminological turf.

I’m unable to identify the origins of all the information in this book, but some sour‐

ces had a relatively direct impact. Item 4’s use of an undefined template to coax type

information out of compilers was suggested by Stephan T. Lavavej, and Matt P. Dziubinski brought Boost.TypeIndex to my attention. In Item 5, the unsigned-std::vector\<int\>::size_type example is from Andrey Karpov’s 28 February 2010 article, “[In what way can C++0x standard help you eliminate 64-bit errors.” The](http://www.viva64.com/en/b/0060/)

std::pair\<std::string, int\>/std::pair\<const std::string, int\> example in the same Item is from Stephan T. Lavavej’s talk at *Going Native 2012*[, “STL11: Magic](http://channel9.msdn.com/Events/GoingNative/GoingNative-2012/STL11-Magic-Secrets)

[&& Secrets.”](http://channel9.msdn.com/Events/GoingNative/GoingNative-2012/STL11-Magic-Secrets) Item 6 [was inspired by Herb Sutter’s 12 August 2013 article, “GotW \#94](http://herbsutter.com/2013/08/12/gotw-94-solution-aaa-style-almost-always-auto/)

[Solution: AAA Style (Almost Always Auto).”](http://herbsutter.com/2013/08/12/gotw-94-solution-aaa-style-almost-always-auto/) Item 9 was motivated by Martinho Fernandes’ blog post of 27 May 2012, “[Handling dependent names](http://flamingdangerzone.com/cxx11/2012/05/27/dependent-names-bliss.html).” The Item 12 example demonstrating overloading on reference qualifiers is based on Casey’s answer to

[the question, “What’s a use case for overloading member functions on reference](http://stackoverflow.com/questions/21052377/whats-a-use-case-for-overloading-member-functions-on-reference-qualifiers)

**xiii**

[qualifiers?,” posted to Stack Overflow on 14 January 2014. My](http://stackoverflow.com/questions/21052377/whats-a-use-case-for-overloading-member-functions-on-reference-qualifiers) Item 15 treatment of C++14’s expanded support for constexpr functions incorporates information I received from Rein Halbersma. Item 16 is based on Herb Sutter’s *C++ and Beyond* *2012* presentation, “You don’t know const and mutable.” Item 18’s advice to have factory functions return std::unique_ptrs is based on Herb Sutter’s 30 May 2013

article, “[GotW# 90 Solution: Factories](http://herbsutter.com/2013/05/30/gotw-90-solution-factories/).” In Item 19, fastLoadWidget is derived from Herb Sutter’s *Going Native 2013* [presentation, “My Favorite C++ 10-Liner.” My treat‐](http://channel9.msdn.com/Events/GoingNative/2013/My-Favorite-Cpp-10-Liner)

ment of std::unique_ptr and incomplete types in Item 22 draws on Herb Sutter’s

[27 November 2011 article, “GotW \#100: Compilation Firewalls](http://herbsutter.com/gotw/_100/)” as well as Howard Hinnant’s 22 May 2011 answer to the Stack Overflow question, “[Is](http://stackoverflow.com/questions/6012157/is-stdunique-ptrt-required-to-know-the-full-definition-of-t)

[std::unique_ptr\<T\> required to know the full definition of T?” The](http://stackoverflow.com/questions/6012157/is-stdunique-ptrt-required-to-know-the-full-definition-of-t) Matrix addition example in Item 25 is based on writings by David Abrahams. JoeArgonne’s 8 Decem‐

[ber 2012 comment on the 30 November 2012 blog post, “Another alternative to](http://jrb-programming.blogspot.com/2012/11/another-alternative-to-lambda-move.html)

[lambda move capture,”](http://jrb-programming.blogspot.com/2012/11/another-alternative-to-lambda-move.html) was the source of Item 32’s std::bind-based approach to

emulating init capture in C++11. Item 37’s explanation of the problem with an implicit detach in std::thread’s destructor is taken from Hans-J. Boehm’s 4

December 2008 paper, “[N2802: A plea to reconsider detach-on-destruction for thread](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2008/n2802.html)

[objects](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2008/n2802.html).” Item 41 was originally motivated by discussions of David Abrahams’ 15

[August 2009 blog post, “Want speed? Pass by value.” The idea that move-only types](http://web.archive.org/web/20140113221447/http:/cpp-next.com/archive/2009/08/want-speed-pass-by-value/)

deserve special treatment is due to Matthew Fioravante, while the analysis of assignment-based copying stems from comments by Howard Hinnant. In Item 42, Stephan T. Lavavej and Howard Hinnant helped me understand the relative performance profiles of emplacement and insertion functions, and Michael Winterberg brought to my attention how emplacement can lead to resource leaks. (Michael cred-its Sean Parent’s *Going Native 2013* [presentation, “C++ Seasoning](http://channel9.msdn.com/Events/GoingNative/2013/Cpp-Seasoning),” as his source).

Michael also pointed out how emplacement functions use direct initialization, while insertion functions use copy initialization.

Reviewing drafts of a technical book is a demanding, time-consuming, and utterly critical task, and I’m fortunate that so many people were willing to do it for me. Full or partial drafts of *Effective Modern C++* were officially reviewed by Cassio Neri, Nate Kohl, Gerhard Kreuzer, Leor Zolman, Bart Vandewoestyne, Stephan T. Lavavej, Nevin “:-)” Liber, Rachel Cheng, Rob Stewart, Bob Steagall, Damien Watkins, Bradley E. Needham, Rainer Grimm, Fredrik Winkler, Jonathan Wakely, Herb Sutter, Andrei Alexandrescu, Eric Niebler, Thomas Becker, Roger Orr, Anthony Williams, Michael Winterberg, Benjamin Huchley, Tom Kirby-Green, Alexey A Nikitin, William Dealtry, Hubert Matthews, and Tomasz Kamiński. I also received feedback from several readers through [O’Reilly’s Early Release EBooks and](http://shop.oreilly.com/category/early-release.do) [Safari Books Online’s Rough](http://my.safaribooksonline.com/roughcuts)

[Cuts](http://my.safaribooksonline.com/roughcuts)[, comments on my blog ( *The View from Aristeia*](http://scottmeyers.blogspot.com/)), and email. I’m grateful to each of these people. The book is *much* better than it would have been without their help.

I’m particularly indebted to Stephan T. Lavavej and Rob Stewart, whose extraordi-narily detailed and comprehensive remarks lead me to worry that they spent nearly as **xiv \| Acknowledgments**

much time on this book as I did. Special thanks also go to Leor Zolman, who, in addition to reviwing the manuscript, double-checked all the code examples.

Dedicated reviews of digital versions of the book were performed by Gerhard Kreuzer, Emyr Williams, and Bradley E. Needham.

My decision to limit the line length in code displays to 64 characters (the maximum likely to display properly in print as well as across a variety of digital devices, device orientations, and font configurations) was based on data provided by Michael Maher.

Ashley Morgan Williams made dining at the Lake Oswego Pizzicato uniquely enter-taining. When it comes to man-sized Caesars, she’s the go-to gal.

More than 20 years after first living through my playing author, my wife, Nancy L.

Urbano, once again tolerated many months of distracted conversations with a cock-tail of resignation, exasperation, and timely splashes of understanding and support.

During the same period, our dog, Darla, was largely content to doze away the hours I spent staring at computer screens, but she never let me forget that there’s life beyond the keyboard.

**Acknowledgments \| xv**