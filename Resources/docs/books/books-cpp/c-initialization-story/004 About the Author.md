**About the Author**

**Bartłomiej (Bartek) Filipek** is a C++ software developer from a beautiful city Cracow in Southern Poland. He started his professional career in 2007 and in 2010 he graduated from Jagiellonian University with a Masters Degree in Computer Science.

Bartek currently works at [Xara⁶](http://www.xara.com/), where he develops features for advanced document editors. He also has experience with desktop graphics applications, game development, large-scale systems for aviation, writing graphics drivers and even biofeedback. In the past, Bartek has also taught programming (mostly game and graphics programming courses) at local universities in Cracow.

Since 2011 Bartek has been regularly blogging at [cppstories.com⁷](https://www.cppstories.com%5D/) (started as [bfilipek.com](https://www.bfilipek.com/)⁸). The blog focuses on core C++ and getting up-to-date with the C++ Standards. He’s also a

co-organiser of the [C++ User Group in Cracow](https://www.meetup.com/C-User-Group-Cracow/)⁹. You can hear Bartek in one [@CppCast](http://cppcast.com/2018/04/bartlomiej-filipek/)

[episode¹⁰](http://cppcast.com/2018/04/bartlomiej-filipek/) where he talks about C++17, blogging and text processing.

Since October 2018, Bartek has been a C++ Expert for the Polish National Body which works directly with ISO/IEC JTC 1/SC 22 (C++ Standardisation Committee). Bartek was awarded his first MVP title for the years 2019/2020 by Microsoft.

In his spare time, he loves collecting and assembling Lego models with his son.

Bartek is the author of [C++17 In Detail¹¹](https://leanpub.com/cpp17indetail) and [C++ Lambda Story](https://leanpub.com/cpplambda)¹²

⁶<http://www.xara.com/>

⁷[https://www.cppstories.com\]](https://www.cppstories.com%5D/)

⁸[https://www.bfilipek.com](https://www.bfilipek.com/)

⁹<https://www.meetup.com/C-User-Group-Cracow/>

¹⁰<http://cppcast.com/2018/04/bartlomiej-filipek/>

¹¹<https://leanpub.com/cpp17indetail>

¹²<https://leanpub.com/cpplambda>

### vii

## Acknowledgements

This book wouldn’t be possible without valuable input from many C++ experts and friends.

I especially would like to thank to the following people:

• JFT (John Taylor),

• Mariusz Jaskółka,

• Florin Chertes (see his profile at [LinkedIn¹³](https://www.linkedin.com/in/florin-ioan-chertes-41b6845/)),

• Konrad Jaśkowiec (see his profile at [LinkedIn¹⁴](https://pl.linkedin.com/in/konrad-ja%C5%9Bkowiec-84585159)),

• Professor Boguslaw Cyganek (see his profile at [AGH university page](https://home.agh.edu.pl/~cyganek/)¹⁵),

• Dawid Pilarski (see his blog at [panicsoftware.com¹⁶](https://blog.panicsoftware.com/))

• Javier Estrada (see his blog at [javierestrada.blog¹⁷](https://javierestrada.blog/)),

• Jonathan Boccara (from [fluentcpp.com/](https://www.fluentcpp.com/)¹⁸),

• Andreas Fertig (see his blog at [andreasfertig¹⁹](https://andreasfertig.blog/)),

• Peter Sommerlad (see his website and training info at [sommerlad.ch/²⁰](https://sommerlad.ch/)),

• Timur Doumler (see his website at [timur.audio/²¹](https://timur.audio/) and his [Twitter²²](https://twitter.com/timur_audio)).

They spent a lot of time on finding even little things that could be improved and extended.

Last but not least, I got a lot of feedback and comments from the blog readers, Patreon

Discord Server (See [@C++Stories @Patreon](https://www.patreon.com/cppstories)²³), and discussions at [C++ Polska²⁴](https://cpp-polska.pl/). Thank you all!

With all of the help from those kind people, the book quality got better and better!

¹³<https://www.linkedin.com/in/florin-ioan-chertes-41b6845/>

¹⁴<https://pl.linkedin.com/in/konrad-ja%C5%9Bkowiec-84585159>

¹⁵<https://home.agh.edu.pl/~cyganek/>

¹⁶<https://blog.panicsoftware.com/>

¹⁷<https://javierestrada.blog/>

¹⁸<https://www.fluentcpp.com/>

¹⁹<https://andreasfertig.blog/>

²⁰<https://sommerlad.ch/>

²¹<https://timur.audio/>

²²<https://twitter.com/timur_audio>

²³<https://www.patreon.com/cppstories>

²⁴<https://cpp-polska.pl/>

### viii

**Revision History**

 

• 20th June 2022 - The first public version! The books is almost done. Missing parts:

some sections in 10. Containers as Data Members, some sections in 11. Non-regular Data Members.

• 22nd June 2022 - new sections on NSDMI, direct init and parens, more about inheriting

constructors, link to GoodReads, wording, hotfixes.

• 24th June 2022 - updated the “copy and move constructor” chapter, typos and small

wording improvements.

• 16th July 2022 -Containers as Data Members chapter rewritten, noexcept consistency

and noexcept move operations advantages in the move constructor section, wording, fixes, layout.

• 13th September 2022 - changed title to “C++ Initialization Story”, adapted book

structure, rewritten “Non-local objects” chapter (previously only on inline variables),

new extracted chapter on Techniques, new section on CRTP.

• 18th November 2022 - heavily updated and completed “Non-regular data members”

chapter, constinit and thread_local sections in the “Non-local objects” chapter,

filled the “implicit conversion” section in the Constructors chapter.

• 23rd December 2022 - content completed! Added Deduction chapter, filled missing

sections in the Techniques chapter. Layout improvements, a few more questions, exercises and fixes.