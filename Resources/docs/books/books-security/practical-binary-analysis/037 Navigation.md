## Practical Binary Analysis

1.  Cover Page
2.  Title Page
3.  Copyright Page
4.  Dedication
5.  About the Author
6.  BRIEF CONTENTS
7.  CONTENTS IN DETAIL
8.  FOREWORD
9.  PREFACE
10. ACKNOWLEDGMENTS
11. INTRODUCTION
    1.  What Is Binary Analysis, and Why Do You Need It?
    2.  What Makes Binary Analysis Challenging?
    3.  Who Should Read This Book?
    4.  What’s in This Book?
    5.  How to Use This Book
12. PART I: BINARY FORMATS
13. 1 ANATOMY OF A BINARY
    1.  1.1 The C Compilation Process
    2.  1.2 Symbols and Stripped Binaries
    3.  1.3 Disassembling a Binary
    4.  1.4 Loading and Executing a Binary
    5.  1.5 Summary
    6.  Exercises
14. 2 THE ELF FORMAT
    1.  2.1 The Executable Header
    2.  2.2 Section Headers
    3.  2.3 Sections
    4.  2.4 Program Headers
    5.  2.5 Summary
    6.  Exercises
15. 3 THE PE FORMAT: A BRIEF INTRODUCTION
    1.  3.1 The MS-DOS Header and MS-DOS Stub
    2.  3.2 The PE Signature, File Header, and Optional Header
    3.  3.3 The Section Header Table
    4.  3.4 Sections
    5.  3.5 Summary
    6.  Exercises
16. 4 BUILDING A BINARY LOADER USING LIBBFD
    1.  4.1 What Is libbfd?
    2.  4.2 A Simple Binary-Loading Interface
    3.  4.3 Implementing the Binary Loader
    4.  4.4 Testing the Binary Loader
    5.  4.5 Summary
    6.  Exercises
17. PART II: BINARY ANALYSIS FUNDAMENTALS
18. 5 BASIC BINARY ANALYSIS IN LINUX
    1.  5.1 Resolving Identity Crises Using file
    2.  5.2 Using ldd to Explore Dependencies
    3.  5.3 Viewing File Contents with xxd
    4.  5.4 Parsing the Extracted ELF with readelf
    5.  5.5 Parsing Symbols with nm
    6.  5.6 Looking for Hints with strings
    7.  5.7 Tracing System Calls and Library Calls with strace and ltrace
    8.  5.8 Examining Instruction-Level Behavior Using objdump
    9.  5.9 Dumping a Dynamic String Buffer Using gdb
    10. 5.10 Summary
    11. Exercise
19. 6 DISASSEMBLY AND BINARY ANALYSIS FUNDAMENTALS
    1.  6.1 Static Disassembly
    2.  6.2 Dynamic Disassembly
    3.  6.3 Structuring Disassembled Code and Data
    4.  6.4 Fundamental Analysis Methods
    5.  6.5 Effects of Compiler Settings on Disassembly
    6.  6.6 Summary
    7.  Exercises
20. 7 SIMPLE CODE INJECTION TECHNIQUES FOR ELF
    1.  7.1 Bare-Metal Binary Modification Using Hex Editing
    2.  7.2 Modifying Shared Library Behavior Using LD_PRELOAD
    3.  7.3 Injecting a Code Section
    4.  7.4 Calling Injected Code
    5.  7.5 Summary
    6.  Exercises
21. PART III: ADVANCED BINARY ANALYSIS
22. 8 CUSTOMIZING DISASSEMBLY
    1.  8.1 Why Write a Custom Disassembly Pass?
    2.  8.2 Introduction to Capstone
    3.  8.3 Implementing a ROP Gadget Scanner
    4.  8.4 Summary
    5.  Exercises
23. 9 BINARY INSTRUMENTATION
    1.  9.1 What Is Binary Instrumentation?
    2.  9.2 Static Binary Instrumentation
    3.  9.3 Dynamic Binary Instrumentation
    4.  9.4 Profiling with Pin
    5.  9.5 Automatic Binary Unpacking with Pin
    6.  9.6 Summary
    7.  Exercises
24. 10 PRINCIPLES OF DYNAMIC TAINT ANALYSIS
    1.  10.1 What Is DTA?
    2.  10.2 DTA in Three Steps: Taint Sources, Taint Sinks, and Taint Propagation
    3.  10.3 Using DTA to Detect the Heartbleed Bug
    4.  10.4 DTA Design Factors: Taint Granularity, Taint Colors, and Taint Policies
    5.  10.5 Summary
    6.  Exercise
25. 11 PRACTICAL DYNAMIC TAINT ANALYSIS WITH LIBDFT
    1.  11.1 Introducing libdft
    2.  11.2 Using DTA to Detect Remote Control-Hijacking
    3.  11.3 Circumventing DTA with Implicit Flows
    4.  11.4 A DTA-Based Data Exfiltration Detector
    5.  11.5 Summary
    6.  Exercise
26. 12 PRINCIPLES OF SYMBOLIC EXECUTION
    1.  12.1 An Overview of Symbolic Execution
    2.  12.2 Constraint Solving with Z3
    3.  12.3 Summary
    4.  Exercises
27. 13 PRACTICAL SYMBOLIC EXECUTION WITH TRITON
    1.  13.1 Introduction to Triton
    2.  13.2 Maintaining Symbolic State with Abstract Syntax Trees
    3.  13.3 Backward Slicing with Triton
    4.  13.4 Using Triton to Increase Code Coverage
    5.  13.5 Automatically Exploiting a Vulnerability
    6.  13.6 Summary
    7.  Exercise
28. PART IV: APPENDIXES
29. A A CRASH COURSE ON X86 ASSEMBLY
    1.  A.1 Layout of an Assembly Program
    2.  A.2 Structure of an x86 Instruction
    3.  A.3 Common x86 Instructions
    4.  A.4 Common Code Constructs in Assembly
30. B IMPLEMENTING PT_NOTE OVERWRITING USING LIBELF
    1.  B.1 Required Headers
    2.  B.2 Data Structures Used in elfinject
    3.  B.3 Initializing libelf
    4.  B.4 Getting the Executable Header
    5.  B.5 Finding the PT_NOTE Segment
    6.  B.6 Injecting the Code Bytes
    7.  B.7 Aligning the Load Address for the Injected Section
    8.  B.8 Overwriting the .note.ABI-tag Section Header
    9.  B.9 Setting the Name of the Injected Section
    10. B.10 Overwriting the PT_NOTE Program Header
    11. B.11 Modifying the Entry Point
31. C LIST OF BINARY ANALYSIS TOOLS
    1.  C.1 Disassemblers
    2.  C.2 Debuggers
    3.  C.3 Disassembly Frameworks
    4.  C.4 Binary Analysis Frameworks
32. D FURTHER READING
    1.  D.1 Standards and References
    2.  D.2 Papers and Articles
    3.  D.3 Books
33. INDEX



1.  iii
2.  iv
3.  v
4.  vi
5.  vii
6.  viii
7.  ix
8.  x
9.  xi
10. xii
11. xiii
12. xiv
13. xv
14. xvi
15. xvii
16. xviii
17. xix
18. xx
19. xxi
20. xxii
21. xxiii
22. xxiv
23. 1
24. 2
25. 3
26. 4
27. 5
28. 6
29. 7
30. 8
31. 9
32. 10
33. 11
34. 12
35. 13
36. 14
37. 15
38. 16
39. 17
40. 18
41. 19
42. 20
43. 21
44. 22
45. 23
46. 24
47. 25
48. 26
49. 27
50. 28
51. 29
52. 30
53. 31
54. 32
55. 33
56. 34
57. 35
58. 36
59. 37
60. 38
61. 39
62. 40
63. 41
64. 42
65. 43
66. 44
67. 45
68. 46
69. 47
70. 48
71. 49
72. 50
73. 51
74. 52
75. 53
76. 54
77. 55
78. 56
79. 57
80. 58
81. 59
82. 60
83. 61
84. 62
85. 63
86. 64
87. 65
88. 66
89. 67
90. 68
91. 69
92. 70
93. 71
94. 72
95. 73
96. 74
97. 75
98. 76
99. 77
100. 78
101. 79
102. 80
103. 81
104. 82
105. 83
106. 84
107. 85
108. 86
109. 87
110. 88
111. 89
112. 90
113. 91
114. 92
115. 93
116. 94
117. 95
118. 96
119. 97
120. 98
121. 99
122. 100
123. 101
124. 102
125. 103
126. 104
127. 105
128. 106
129. 107
130. 108
131. 109
132. 110
133. 111
134. 112
135. 113
136. 114
137. 115
138. 116
139. 117
140. 118
141. 119
142. 120
143. 121
144. 122
145. 123
146. 124
147. 125
148. 126
149. 127
150. 128
151. 129
152. 130
153. 131
154. 132
155. 133
156. 134
157. 135
158. 136
159. 137
160. 138
161. 139
162. 140
163. 141
164. 142
165. 143
166. 144
167. 145
168. 146
169. 147
170. 148
171. 149
172. 150
173. 151
174. 152
175. 153
176. 154
177. 155
178. 156
179. 157
180. 158
181. 159
182. 160
183. 161
184. 162
185. 163
186. 164
187. 165
188. 166
189. 167
190. 168
191. 169
192. 170
193. 171
194. 172
195. 173
196. 174
197. 175
198. 176
199. 177
200. 178
201. 179
202. 180
203. 181
204. 182
205. 183
206. 184
207. 185
208. 186
209. 187
210. 188
211. 189
212. 190
213. 191
214. 192
215. 193
216. 194
217. 195
218. 196
219. 197
220. 198
221. 199
222. 200
223. 201
224. 202
225. 203
226. 204
227. 205
228. 206
229. 207
230. 208
231. 209
232. 210
233. 211
234. 212
235. 213
236. 214
237. 215
238. 216
239. 217
240. 218
241. 219
242. 220
243. 221
244. 222
245. 223
246. 224
247. 225
248. 226
249. 227
250. 228
251. 229
252. 230
253. 231
254. 232
255. 233
256. 234
257. 235
258. 236
259. 237
260. 238
261. 239
262. 240
263. 241
264. 242
265. 243
266. 244
267. 245
268. 246
269. 247
270. 248
271. 249
272. 250
273. 251
274. 252
275. 253
276. 254
277. 255
278. 256
279. 257
280. 258
281. 259
282. 260
283. 261
284. 262
285. 263
286. 264
287. 265
288. 266
289. 267
290. 268
291. 269
292. 270
293. 271
294. 272
295. 273
296. 274
297. 275
298. 276
299. 277
300. 278
301. 279
302. 280
303. 281
304. 282
305. 283
306. 284
307. 285
308. 286
309. 287
310. 288
311. 289
312. 290
313. 291
314. 292
315. 293
316. 294
317. 295
318. 296
319. 297
320. 298
321. 299
322. 300
323. 301
324. 302
325. 303
326. 304
327. 305
328. 306
329. 301
330. 308
331. 309
332. 310
333. 311
334. 312
335. 313
336. 314
337. 315
338. 316
339. 317
340. 318
341. 319
342. 320
343. 321
344. 322
345. 323
346. 324
347. 325
348. 326
349. 327
350. 328
351. 329
352. 330
353. 331
354. 332
355. 333
356. 334
357. 335
358. 336
359. 337
360. 338
361. 339
362. 340
363. 341
364. 342
365. 343
366. 344
367. 345
368. 346
369. 347
370. 348
371. 349
372. 350
373. 351
374. 352
375. 353
376. 354
377. 355
378. 356
379. 357
380. 358
381. 359
382. 360
383. 361
384. 362
385. 363
386. 364
387. 365
388. 366
389. 367
390. 368
391. 369
392. 370
393. 371
394. 372
395. 373
396. 374
397. 375
398. 376
399. 377
400. 378
401. 379
402. 380
403. 381
404. 382
405. 383
406. 384
407. 385
408. 386
409. 387
410. 388
411. 389
412. 390
413. 391
414. 392
415. 393
416. 394
417. 395
418. 396
419. 397
420. 398
421. 399
422. 400
423. 401
424. 402
425. 403
426. 404
427. 405
428. 406
429. 407
430. 408
431. 409
432. 410
433. 411
434. 412
435. 413
436. 414
437. 415
438. 416
439. 417
440. 418
441. 419
442. 420
443. 421
444. 422
445. 423
446. 424
447. 425
448. 426
449. 427
450. 428
451. 429
452. 430
453. 431