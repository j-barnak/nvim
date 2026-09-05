![Cover: Writing A C Compiler, Build a Real Programming Language from Scratch by Nora Sandler](/tmp/audit/iter1/epubregen/writing-a-c-compiler/media/37c5d4495079f37c6cc6867ba86f5b428b662433.jpg)

# `CONTENTS IN DETAIL`

1.  `TITLE PAGE`
2.  `COPYRIGHT`
3.  `DEDICATION`
4.  `ABOUT THE AUTHOR AND TECHNICAL REVIEWER`
5.  `ACKNOWLEDGMENTS`
6.  `INTRODUCTION`
7.  Who This Book Is For
8.  Why Write a C Compiler?
9.  Compilation from 10,000 Feet
10. What You’ll Build
11. How to Use This Book
12. The Test Suite
13. Extra Credit Features
14. Some Advice on Choosing an Implementation Language
15. System Requirements
16. Installing GCC and GDB on Linux
17. Installing the Command Line Developer Tools on macOS
18. Running on Apple Silicon
19. Validating Your Setup
20. Additional Resources
21. Let’s Go!
22. `PART I: THE BASICS`
23. `1`  
    `A MINIMAL COMPILER`
24. The Four Compiler Passes
25. Hello, Assembly!
26. The Compiler Driver
27. The Lexer
28. The Parser
29. An Example Abstract Syntax Tree
30. The AST Definition
31. The Formal Grammar
32. Recursive Descent Parsing
33. Assembly Generation
34. Code Emission
35. Summary
36. Additional Resources
37. `2`  
    `UNARY OPERATORS`
38. Negation and Bitwise Complement in Assembly
39. The Stack
40. The Lexer
41. The Parser
42. TACKY: A New Intermediate Representation
43. Defining TACKY
44. Generating TACKY
45. Generating Names for Temporary Variables
46. Updating the Compiler Driver
47. Assembly Generation
48. Converting TACKY to Assembly
49. Replacing Pseudoregisters
50. Fixing Up Instructions
51. Code Emission
52. Summary
53. Additional Resources
54. `3`  
    `BINARY OPERATORS`
55. The Lexer
56. The Parser
57. The Trouble with Recursive Descent Parsing
58. The Adequate Solution: Refactoring the Grammar
59. The Better Solution: Precedence Climbing
60. Precedence Climbing in Action
61. TACKY Generation
62. Assembly Generation
63. Doing Arithmetic in Assembly
64. Converting Binary Operations to Assembly
65. Replacing Pseudoregisters
66. Fixing Up the idiv, add, sub, and imul Instructions
67. Code Emission
68. Extra Credit: Bitwise Operators
69. Summary
70. Additional Resources
71. `4`  
    `LOGICAL AND RELATIONAL OPERATORS`
72. Short-Circuiting Operators
73. The Lexer
74. The Parser
75. TACKY Generation
76. Adding Jumps, Copies, and Comparisons to the TACKY IR
77. Converting Short-Circuiting Operators to TACKY
78. Generating Labels
79. Comparisons and Jumps in Assembly
80. Comparisons and Status Flags
81. Conditional Set Instructions
82. Jump Instructions
83. Assembly Generation
84. Replacing Pseudoregisters
85. Fixing Up the cmp Instruction
86. Code Emission
87. Summary
88. Additional Resources
89. `5`  
    `LOCAL VARIABLES`
90. Variables, Declarations, and Assignment
91. The Lexer
92. The Parser
93. The Updated AST and Grammar
94. An Improved Precedence Climbing Algorithm
95. Semantic Analysis
96. Variable Resolution
97. The --validate Option
98. TACKY Generation
99. Variable and Assignment Expressions
100. Declarations, Statements, and Function Bodies
101. Functions with No return Statement
102. Extra Credit: Compound Assignment, Increment, and Decrement
103. Summary
104. `6`  
     `IF STATEMENTS AND CONDITIONAL EXPRESSIONS`
105. The Lexer
106. The Parser
107. Parsing if Statements
108. Parsing Conditional Expressions
109. Variable Resolution
110. TACKY Generation
111. Converting if Statements to TACKY
112. Converting Conditional Expressions to TACKY
113. Extra Credit: Labeled Statements and goto
114. Summary
115. `7`  
     `COMPOUND STATEMENTS`
116. The Scoop on Scopes
117. The Parser
118. Variable Resolution
119. Resolving Variables in Multiple Scopes
120. Updating the Variable Resolution Pseudocode
121. TACKY Generation
122. Summary
123. `8`  
     `LOOPS`
124. Loops and How to Escape Them
125. The Lexer
126. The Parser
127. Semantic Analysis
128. Extending Variable Resolution
129. Loop Labeling
130. Implementing Loop Labeling
131. TACKY Generation
132. break and continue Statements
133. do Loops
134. while Loops
135. for Loops
136. Extra Credit: switch Statements
137. Summary
138. `9`  
     `FUNCTIONS`
139. Declaring, Defining, and Calling Functions
140. Declarations and Definitions
141. Function Calls
142. Identifier Linkage
143. Compiling Libraries
144. The Lexer
145. The Parser
146. Semantic Analysis
147. Extending Identifier Resolution
148. Writing the Type Checker
149. TACKY Generation
150. Assembly Generation
151. Understanding Calling Conventions
152. Calling Functions with the System V ABI
153. Converting Function Calls and Definitions to Assembly
154. Replacing Pseudoregisters
155. Allocating Stack Space During Instruction Fix-Up
156. Code Emission
157. Calling Library Functions
158. Summary
159. `10`  
     `FILE SCOPE VARIABLE DECLARATIONS AND STORAGE-CLASS SPECIFIERS`
160. All About Declarations
161. Scope
162. Linkage
163. Storage Duration
164. Definitions vs. Declarations
165. Error Cases
166. Linkage and Storage Duration in Assembly
167. The Lexer
168. The Parser
169. Parsing Type and Storage-Class Specifiers
170. Distinguishing Between Function and Variable Declarations
171. Semantic Analysis
172. Identifier Resolution: Resolving External Variables
173. Type Checking: Tracking Static Functions and Variables
174. TACKY Generation
175. Assembly Generation
176. Generating Assembly for Variable Definitions
177. Replacing Pseudoregisters According to Their Storage Duration
178. Fixing Up Instructions
179. Code Emission
180. Summary
181. `PART II: TYPES BEYOND INT`
182. `11`  
     `LONG INTEGERS`
183. Long Integers in Assembly
184. Type Conversions
185. Static Long Variables
186. The Lexer
187. The Parser
188. Semantic Analysis
189. Adding Type Information to the AST
190. Type Checking Expressions
191. Type Checking return Statements
192. Type Checking Declarations and Updating the Symbol Table
193. TACKY Generation
194. Tracking the Types of Temporary Variables
195. Generating Extra Return Instructions
196. Assembly Generation
197. Tracking Assembly Types in the Backend Symbol Table
198. Replacing Longword and Quadword Pseudoregisters
199. Fixing Up Instructions
200. Code Emission
201. Summary
202. `12`  
     `UNSIGNED INTEGERS`
203. Type Conversions, Again
204. Converting Between Signed and Unsigned Types of the Same Size
205. Converting unsigned int to a Larger Type
206. Converting signed int to a Larger Type
207. Converting from Larger to Smaller Types
208. The Lexer
209. The Parser
210. The Type Checker
211. TACKY Generation
212. Unsigned Integer Operations in Assembly
213. Unsigned Comparisons
214. Unsigned Division
215. Zero Extension
216. Assembly Generation
217. Replacing Pseudoregisters
218. Fixing Up the Div and MovZeroExtend Instructions
219. Code Emission
220. Summary
221. `13`  
     `FLOATING-POINT NUMBERS`
222. IEEE 754, What Is It Good For?
223. The IEEE 754 Double-Precision Format
224. Rounding Behavior
225. Rounding Modes
226. Rounding Constants
227. Rounding Type Conversions
228. Rounding Arithmetic Operations
229. Linking Shared Libraries
230. The Lexer
231. Recognizing Floating-Point Constant Tokens
232. Matching the End of a Constant
233. The Parser
234. The Type Checker
235. TACKY Generation
236. Floating-Point Operations in Assembly
237. Working with SSE Instructions
238. Using Floating-Point Values in the System V Calling Convention
239. Doing Arithmetic with SSE Instructions
240. Comparing Floating-Point Numbers
241. Converting Between Floating-Point and Integer Types
242. Assembly Generation
243. Floating-Point Constants
244. Unary Instructions, Binary Instructions, and Conditional Jumps
245. Type Conversions
246. Function Calls
247. Return Instructions
248. The Complete Conversion from TACKY to Assembly
249. Pseudoregister Replacement
250. Instruction Fix-Up
251. Code Emission
252. Formatting Floating-Point Numbers
253. Labeling Floating-Point Constants
254. Storing Constants in the Read-Only Data Section
255. Initializing Static Variables to 0.0 or –0.0
256. Putting It All Together
257. Extra Credit: NaN
258. Summary
259. Additional Resources
260. `14`  
     `POINTERS`
261. Objects and Values
262. Operations on Pointers
263. Address and Dereference Operations
264. Null Pointers and Type Conversions
265. Pointer Comparisons
266. & Operations on Dereferenced Pointers
267. The Lexer
268. The Parser
269. Parsing Declarations
270. Parsing Type Names
271. Putting It All Together
272. Semantic Analysis
273. Type Checking Pointer Expressions
274. Tracking Static Pointer Initializers in the Symbol Table
275. TACKY Generation
276. Pointer Operations in TACKY
277. A Strategy for TACKY Conversion
278. Assembly Generation
279. Replacing Pseudoregisters with Memory Operands
280. Fixing Up the lea and push Instructions
281. Code Emission
282. Summary
283. `15`  
     `ARRAYS AND POINTER ARITHMETIC`
284. Arrays and Pointer Arithmetic
285. Array Declarations and Initializers
286. Memory Layout of Arrays
287. Array-to-Pointer Decay
288. Pointer Arithmetic to Access Array Elements
289. Even More Pointer Arithmetic
290. Array Types in Function Declarations
291. Things We Aren’t Implementing
292. The Lexer
293. The Parser
294. Parsing Array Declarators
295. Parsing Abstract Array Declarators
296. Parsing Compound Initializers
297. Parsing Subscript Expressions
298. The Type Checker
299. Converting Arrays to Pointers
300. Validating Lvalues
301. Type Checking Pointer Arithmetic
302. Type Checking Subscript Expressions
303. Type Checking Cast Expressions
304. Type Checking Function Declarations
305. Type Checking Compound Initializers
306. Initializing Static Arrays
307. Initializing Scalar Variables with ZeroInit
308. TACKY Generation
309. Pointer Arithmetic
310. Subscripting
311. Compound Initializers
312. Tentative Array Definitions
313. Assembly Generation
314. Converting TACKY to Assembly
315. Replacing PseudoMem Operands
316. Fixing Up Instructions
317. Code Emission
318. Summary
319. `16`  
     `CHARACTERS AND STRINGS`
320. Character Traits
321. String Literals
322. Working with Strings in Assembly
323. The Lexer
324. The Parser
325. Parsing Type Specifiers
326. Parsing Character Constants
327. Parsing String Literals
328. Putting It All Together
329. The Type Checker
330. Characters
331. String Literals in Expressions
332. String Literals Initializing Non-static Variables
333. String Literals Initializing Static Variables
334. TACKY Generation
335. String Literals as Array Initializers
336. String Literals in Expressions
337. Top-Level Constants in TACKY
338. Assembly Generation
339. Operations on Characters
340. Top-Level Constants
341. The Complete Conversion from TACKY to Assembly
342. Pseudo-Operand Replacement
343. Instruction Fix-Up
344. Code Emission
345. Hello Again, World!
346. Summary
347. `17`  
     `SUPPORTING DYNAMIC MEMORY ALLOCATION`
348. The void Type
349. Memory Management with void \*
350. Complete and Incomplete Types
351. The sizeof Operator
352. The Lexer
353. The Parser
354. The Type Checker
355. Conversions to and from void \*
356. Functions with void Return Types
357. Scalar and Non-scalar Types
358. Restrictions on Incomplete Types
359. Extra Restrictions on void
360. Conditional Expressions with void Operands
361. Existing Validation for Arithmetic Expressions and Comparisons
362. sizeof Expressions
363. TACKY Generation
364. Functions with void Return Types
365. Casts to void
366. Conditional Expressions with void Operands
367. sizeof Expressions
368. The Latest and Greatest TACKY IR
369. Assembly Generation
370. Summary
371. `18`  
     `STRUCTURES`
372. Declaring Structure Types
373. Structure Member Declarations
374. Tag and Member Namespaces
375. Structure Type Declarations We Aren’t Implementing
376. Operating on Structures
377. Structure Layout in Memory
378. The Lexer
379. The Parser
380. Semantic Analysis
381. Resolving Structure Tags
382. Type Checking Structures
383. TACKY Generation
384. Implementing the Member Access Operators
385. Converting Compound Initializers to TACKY
386. Structures in the System V Calling Convention
387. Classifying Structures
388. Passing Parameters of Structure Type
389. Returning Structures
390. Assembly Generation
391. Extending the Assembly AST
392. Copying Structures
393. Using Structures in Function Calls
394. Putting It All Together
395. Replacing Pseudo-operands
396. Code Emission
397. Extra Credit: Unions
398. Summary
399. Additional Resources
400. `PART III: OPTIMIZATIONS`
401. `19`  
     `OPTIMIZING TACKY PROGRAMS`
402. Safety and Observable Behavior
403. Four TACKY Optimizations
404. Constant Folding
405. Unreachable Code Elimination
406. Copy Propagation
407. Dead Store Elimination
408. With Our Powers Combined …
409. Testing the Optimization Passes
410. Wiring Up the Optimization Stage
411. Constant Folding
412. Constant Folding for Part I TACKY Programs
413. Supporting Part II TACKY Programs
414. Control-Flow Graphs
415. Defining the Control-Flow Graph
416. Creating Basic Blocks
417. Adding Edges to the Control-Flow Graph
418. Converting a Control-Flow Graph to a List of Instructions
419. Making Your Control-Flow Graph Code Reusable
420. Unreachable Code Elimination
421. Eliminating Unreachable Blocks
422. Removing Useless Jumps
423. Removing Useless Labels
424. Removing Empty Blocks
425. A Little Bit About Data-Flow Analysis
426. Copy Propagation
427. Reaching Copies Analysis
428. Rewriting TACKY Instructions
429. Supporting Part II TACKY Programs
430. Dead Store Elimination
431. Liveness Analysis
432. Removing Dead Stores
433. Supporting Part II TACKY Programs
434. Summary
435. Additional Resources
436. `20`  
     `REGISTER ALLOCATION`
437. Register Allocation in Action
438. Take One: Put Everything on the Stack
439. Take Two: Register Allocation
440. Take Three: Register Allocation with Coalescing
441. Updating the Compiler Pipeline
442. Extending the Assembly AST
443. Converting TACKY to Assembly
444. Register Allocation by Graph Coloring
445. Detecting Interference
446. Spilling Registers
447. The Basic Register Allocator
448. Handling Multiple Types During Register Allocation
449. Defining the Interference Graph
450. Building the Interference Graph
451. Calculating Spill Costs
452. Coloring the Interference Graph
453. Building the Register Map and Rewriting the Function Body
454. Instruction Fix-Up with Callee-Saved Registers
455. Code Emission
456. Register Coalescing
457. Updating the Interference Graph
458. Conservative Coalescing
459. Implementing Register Coalescing
460. Summary
461. Additional Resources
462. `NEXT STEPS`
463. Add Some Missing Features
464. Handle Undefined Behavior Safely
465. Write More TACKY Optimizations
466. Support Another Target Architecture
467. Contribute to an Open Source Programming Language Project
468. That’s a Wrap!
469. `A`  
     `DEBUGGING ASSEMBLY CODE WITH GDB OR LLDB`
470. The Program
471. Debugging with GDB
472. Configuring the GDB UI
473. Starting and Stopping the Program
474. Printing Expressions
475. Examining Memory
476. Setting Conditional Breakpoints
477. Getting Help
478. Debugging with LLDB
479. Starting and Stopping the Program
480. Displaying Assembly Code
481. Printing Expressions
482. Examining Memory
483. Setting Conditional Breakpoints
484. Getting Help
485. `B`  
     `ASSEMBLY GENERATION AND CODE EMISSION TABLES`
486. Part I
487. Converting TACKY to Assembly
488. Code Emission
489. Part II
490. Converting TACKY to Assembly
491. Code Emission
492. Part III
493. `REFERENCES`
494. `INDEX`