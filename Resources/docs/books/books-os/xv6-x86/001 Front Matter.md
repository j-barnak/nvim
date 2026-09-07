**xv6**  
  
a simple, Unix-like teaching operating system  
  
Russ Cox Frans Kaashoek Robert Morris  
  
xv6-book@pdos.csail.mit.edu  
  
Draft as of September 4, 2018  
  
**Contents**  
  
0 Operating system interfaces  
  
7  
  
1 Operating system organization 17  
  
2 Page tables 29  
  
3 Traps, interrupts, and drivers 39  
  
4 Locking 51  
  
5 Scheduling 61  
  
6 File system 75  
  
7 Summary 93  
  
A PC hardware 95  
  
B The boot loader 99  
  
Index 105  
  
DRAFT as of September 4, 2018 3 https://pdos.csail.mit.edu/6.828/xv6  
  
**Foreword and acknowledgements**  
  
This is a draft text intended for a class on operating systems. It explains the main con- cepts of operating systems by studying an example kernel, named xv6. xv6 is a re-im- plementation of Dennis Ritchie’s and Ken Thompson’s Unix Version 6 (v6). xv6 loose- ly follows the structure and style of v6, but is implemented in ANSI C for an x86- based multiprocessor.  
  
The text should be read along with the source code for xv6. This approach is inspired by John Lions’s Commentary on UNIX 6th Edition (Peer to Peer Communications; IS- BN: 1-57398-013-7; 1st edition (June 14, 2000)). See https://pdos.csail.mit.edu/6.828 for pointers to on-line resources for v6 and xv6, including several hands-on homework as- signments using xv6.  
  
We have used this text in 6.828, the operating systems class at MIT. We thank the fac- ulty, teaching assistants, and students of 6.828 who have all directly or indirectly con- tributed to xv6. In particular, we would like to thank Austin Clements and Nickolai Zeldovich. Finally, we would like to thank people who emailed us bugs in the text or suggestions for provements: Abutalib Aghayev, Sebastian Boehm, Anton Burtsev, Raphael Carvalho, Rasit Eskicioglu, Color Fuzzy, Giuseppe, Tao Guo, Robert Hilder- man, Wolfgang Keller, Austin Liew, Pavan Maddamsetti, Jacek Masiulaniec, Michael McConville, miguelgvieira, Mark Morrissey, Harry Pan, Askar Safin, Salman Shah, Rus- lan Savchenko, Pawel Szczurko, Warren Toomey, tyfkda, and Zou Chang Wei.  
  
If you spot errors or have suggestions for improvement, please send email to Frans Kaashoek and Robert Morris (kaashoek,rtm@csail.mit.edu).  
  
DRAFT as of September 4, 2018 5 https://pdos.csail.mit.edu/6.828/xv6  
  