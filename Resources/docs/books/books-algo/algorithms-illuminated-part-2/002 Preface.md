## Preface

 

This book is the second of a four-part series based on my online algorithms courses that have been running regularly since 2012, which in turn are based on an undergraduate course that I’ve taught many times at Stanford University. The first part of the series is not a prerequisite for this one, and this book should be accessible to any reader who has the background described in the “Who Are You?” section below and is familiar with asymptotic notation (which is

reviewed in Appendix C).

What We’ll Cover

Algorithms Illuminated, Part 2 provides an introduction to and basic literacy in the following three topics.

Graph search and applications. Graphs model many different types of networks, including road networks, communication networks, social networks, and networks of dependencies between tasks. Graphs can get complex, but there are several blazingly fast primitives for reasoning about graph structure. We begin with linear-time algorithms for searching a graph, with applications ranging from network analysis to task sequencing.

Shortest paths. In the shortest-path problem, the goal is to com-pute the best route in a network from point A to point B. The problem has obvious applications, like computing driving directions, and also shows up in disguise in many more general planning problems. We’ll generalize one of our graph search algorithms and arrive at Dijkstra’s famous shortest-path algorithm.

Data structures. This book will make you an educated client of several different data structures for maintaining an evolving set of objects with keys. The primary goal is to develop your intuition

### vii viii Preface

 

about which data structure is the right one for your application. The optional advanced sections provide guidance in how to implement these data structures from scratch.

We first discuss heaps, which can quickly identify the stored object with the smallest key and are useful for sorting, implementing a priority queue, and implementing Dijkstra’s algorithm in near-linear time. Search trees maintain a total ordering over the keys of the stored objects and support an even richer array of operations. Hash tables are optimized for super-fast lookups and are ubiquitous in modern programs. We’ll also cover the bloom filter, a close cousin of the hash table that uses less space at the expense of occasional errors.

For a more detailed look into the book’s contents, check out the “Upshot” sections that conclude each chapter and highlight the most important points. The starred sections of the book are the most advanced ones. The time-constrained reader can skip these on a first reading without loss of continuity.

Topics covered in the other three parts. Algorithms Illumi-nated, Part 1 covers asymptotic notation (big-O notation and its close cousins), divide-and-conquer algorithms and the master method, randomized QuickSort and its analysis, and linear-time selection algo-rithms. Part 3 focuses on greedy algorithms (scheduling, minimum spanning trees, clustering, Huffman codes) and dynamic programming (knapsack, sequence alignment, shortest paths, optimal search trees). Part 4 is all about N P-completeness, what it means for the algorithm designer, and strategies for coping with computationally intractable problems, including the analysis of heuristics and local search.

 

Skills You’ll Learn

Mastering algorithms takes time and effort. Why bother?

Become a better programmer. You’ll learn several blazingly fast subroutines for processing data as well as several useful data structures for organizing data that you can deploy directly in your own programs. Implementing and using these algorithms will stretch and improve your programming skills. You’ll also learn general algorithm design paradigms that are relevant for many different problems across different domains, as well as tools for predicting the performance of Preface ix

 

such algorithms. These “algorithmic design patterns” can help you come up with new algorithms for problems that arise in your own work.

Sharpen your analytical skills. You’ll get lots of practice describ-ing and reasoning about algorithms. Through mathematical analysis, you’ll gain a deep understanding of the specific algorithms and data structures covered in these books. You’ll acquire facility with sev-eral mathematical techniques that are broadly useful for analyzing algorithms.

Think algorithmically. After you learn about algorithms, it’s hard to not see them everywhere, whether you’re riding an elevator, watching a flock of birds, managing your investment portfolio, or even watching an infant learn. Algorithmic thinking is increasingly useful and prevalent in disciplines outside of computer science, including biology, statistics, and economics.

Literacy with computer science’s greatest hits. Studying al-gorithms can feel like watching a highlight reel of many of the greatest hits from the last sixty years of computer science. No longer will you feel excluded at that computer science cocktail party when someone cracks a joke about Dijkstra’s algorithm. After reading these books, you’ll know exactly what they mean.

Ace your technical interviews. Over the years, countless stu-dents have regaled me with stories about how mastering the concepts in these books enabled them to ace every technical interview question they were ever asked.

How These Books Are Different

This series of books has only one goal: to teach the basics of algorithms in the most accessible way possible. Think of them as a transcript of what an expert algorithms tutor would say to you over a series of one-on-one lessons.

There are a number of excellent more traditional and encyclopedic

textbooks on algorithms, any of which usefully complement this book series with additional details, problems, and topics. I encourage you to explore and find your own favorites. There are also several books that, unlike these books, cater to programmers looking for ready-made x Preface

 

algorithm implementations in a specific programming language. Many such implementations are freely available on the Web as well.

 

Who Are You?

The whole point of these books and the online courses upon which they are based is to be as widely and easily accessible as possible. People of all ages, backgrounds, and walks of life are well represented in my online courses, and there are large numbers of students (high-school, college, etc.), software engineers (both current and aspiring), scientists, and professionals hailing from all corners of the world.

This book is not an introduction to programming, and ideally you’ve acquired basic programming skills in a standard language (like Java, Python, C, Scala, Haskell, etc.). For a litmus test, check out

Section 8.2—if it makes sense, you’ll be fine for the rest of the book. If you need to beef up your programming skills, there are several outstanding free online courses that teach basic programming.

We also use mathematical analysis as needed to understand how and why algorithms really work. The freely available book Mathe-matics for Computer Science, by Eric Lehman, F. Thomson Leighton,

and Albert R. Meyer is an excellent and entertaining refresher on P mathematical notation (like and 8 ), the basics of proofs (induction, contradiction, etc.), discrete probability, and much more.

 

Additional Resources

These books are based on online courses that are currently running on the Coursera and Stanford Lagunita platforms. I’ve made several resources available to help you replicate as much of the online course experience as you like.

Videos. If you’re more in the mood to watch and listen than to read, check out the YouTube video playlists available from

[www.algorithmsilluminated.org.](http://www.algorithmsilluminated.org) These videos cover all of the top-ics of this book series, as well as additional advanced topics. I hope they exude a contagious enthusiasm for algorithms that, alas, is impossible to replicate fully on the printed page.

Quizzes. How can you know if you’re truly absorbing the concepts in this book? Quizzes with solutions and explanations are scattered Preface xi

 

throughout the text; when you encounter one, I encourage you to pause and think about the answer before reading on.

End-of-chapter problems. At the end of each chapter you’ll find several relatively straightforward questions for testing your under-standing, followed by harder and more open-ended challenge problems. Solutions to problems that are marked with an “(S)” appear at the end of the book. Readers can interact with me and each other about the remaining end-of-chapter problems through the book’s discussion forum (see below).

Programming problems. Most of the chapters conclude with a suggested programming project, whose goal is to help you develop a detailed understanding of an algorithm by creating your own working implementation of it. Data sets, along with test cases and their

solutions, can be found at [www.algorithmsilluminated.org.](http://www.algorithmsilluminated.org)

Discussion forums. A big reason for the success of online courses is the opportunities they provide for participants to help each other understand the course material and debug programs through discus-sion forums. Readers of these books have the same opportunity, via

the forums available at [www.algorithmsilluminated.org.](http://www.algorithmsilluminated.org)

Acknowledgments

These books would not exist without the passion and hunger supplied by the hundreds of thousands of participants in my algorithms courses over the years, both on campus at Stanford and on online platforms. I am particularly grateful to those who supplied detailed feedback on an earlier draft of this book: Tonya Blust, Yuan Cao, Jim Humelsine, Vladimir Kokshenev, Bayram Kuliyev, Patrick Monkelban, and Daniel Zingaro.

I always appreciate suggestions and corrections from readers.

These are best communicated through the discussion forums men-tioned above.

 

Tim Roughgarden

London, United Kingdom

July 2018