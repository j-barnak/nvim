# `CONTENTS IN DETAIL`

1.  PRAISE FOR SERIOUS CRYPTOGRAPHY
2.  TITLE PAGE
3.  COPYRIGHT
4.  ABOUT THE AUTHOR AND TECHNICAL REVIEWER
5.  `FOREWORD TO THE FIRST EDITION`
6.  `ACKNOWLEDGMENTS`
7.  `INTRODUCTION`
8.  `This Book’s Approach`
9.  `Who This Book Is For`
10. `How This Book Is Organized`
11. `On the Second Edition`
12. `LIST OF ABBREVIATIONS`
13. `PART I: FUNDAMENTALS`
14. `1`  
    `ENCRYPTION`
15. `The Basics`
16. `Classical Ciphers`
17. `The Caesar Cipher`
18. `The Vigenère Cipher`
19. `How Ciphers Work`
20. `The Permutation`
21. `The Mode of Operation`
22. `Why Classical Ciphers Are Insecure`
23. `The Perfect Cipher: The One-Time Pad`
24. `Encryption and Decryption`
25. `Why Is the One-Time Pad Secure?`
26. `Encryption Security`
27. `Attack Models`
28. `Security Goals`
29. `Security Notions`
30. `Asymmetric Encryption`
31. `When Ciphers Do More Than Encryption`
32. `Authenticated Encryption`
33. `Format-Preserving Encryption`
34. `Fully Homomorphic Encryption`
35. `Searchable Encryption`
36. `Tweakable Encryption`
37. `How Things Can Go Wrong`
38. `Weak Cipher`
39. `Wrong Model`
40. `Further Reading`
41. `2`  
    `RANDOMNESS`
42. `Random or Nonrandom?`
43. `Randomness as a Probability Distribution`
44. `Entropy: A Measure of Uncertainty`
45. `Random and Pseudorandom Number Generators`
46. `How PRNGs Work`
47. `Security Concerns`
48. `The PRNG Fortuna`
49. `Cryptographic vs. Noncryptographic PRNGs`
50. `The Uselessness of Statistical Tests`
51. `Real-World PRNGs`
52. `Random Bits in Linux`
53. `The CryptGenRandom() Function in Windows`
54. `A Hardware-Based PRNG: Intel Secure Key`
55. `How Things Can Go Wrong`
56. `Poor Entropy Sources`
57. `Insufficient Entropy at Boot Time`
58. `Noncryptographic PRNG`
59. `Sampling Bug with Strong Randomness`
60. `Further Reading`
61. `3`  
    `CRYPTOGRAPHIC SECURITY`
62. `Defining the Impossible`
63. `Security in Theory: Unconditional Security`
64. `Security in Practice: Computational Security`
65. `Quantifying Security`
66. `Measuring Security in Bits`
67. `Calculating the Full Attack Cost`
68. `Choosing and Evaluating Security Levels`
69. `Achieving Security`
70. `Provable Security`
71. `Heuristic Security`
72. `Generating Keys`
73. `Symmetric Keys`
74. `Asymmetric Keys`
75. `Protecting Keys`
76. `How Things Can Go Wrong`
77. `Incorrect Security Proof`
78. `Short Keys for Legacy Support`
79. `Further Reading`
80. `PART II: SYMMETRIC CRYPTO`
81. `4`  
    `BLOCK CIPHERS`
82. `What Is a Block Cipher?`
83. `Security Goals`
84. `Block Size`
85. `The Codebook Attack`
86. `How to Construct Block Ciphers`
87. `A Block Cipher’s Rounds`
88. `The Slide Attack and Round Keys`
89. `Substitution–Permutation Networks`
90. `Feistel Schemes`
91. `The Advanced Encryption Standard`
92. `AES Internals`
93. `AES in Action`
94. `How to Implement AES`
95. `Table-Based Implementations`
96. `Native Instructions`
97. `AES Security`
98. `Modes of Operation`
99. `Electronic Codebook Mode`
100. `Cipher Block Chaining Mode`
101. `Message Encryption in CBC Mode`
102. `Counter Mode`
103. `How Things Can Go Wrong`
104. `Meet-in-the-Middle Attacks`
105. `Padding Oracle Attacks`
106. `Further Reading`
107. `5`  
     `STREAM CIPHERS`
108. `How Stream Ciphers Work`
109. `Hardware-Oriented Stream Ciphers`
110. `Feedback Shift Registers`
111. `Grain-128a`
112. `A5/1`
113. `Software-Oriented Stream Ciphers`
114. `RC4`
115. `Salsa20`
116. `How Things Can Go Wrong`
117. `Nonce Reuse`
118. `Broken RC4 Implementation`
119. `Weak Ciphers Baked into Hardware`
120. `Further Reading`
121. `6`  
     `HASH FUNCTIONS`
122. `Secure Hash Functions`
123. `Unpredictability Again`
124. `Preimage Resistance`
125. `Collision Resistance`
126. `How to Find Collisions`
127. `How to Build Hash Functions`
128. `Compression-Based Hash Functions`
129. `Permutation-Based Hash Functions`
130. `The SHA Family of Hash Functions`
131. `SHA-1`
132. `SHA-2`
133. `The SHA-3 Competition`
134. `Keccak (SHA-3)`
135. `The BLAKE2 and BLAKE3 Hash Functions`
136. `How Things Can Go Wrong`
137. `The Length-Extension Attack`
138. `Fooling Proof-of-Storage Protocols`
139. `Further Reading`
140. `7`  
     `KEYED HASHING`
141. `Message Authentication Codes`
142. `MACs in Secure Communication`
143. `Forgery and Chosen-Message Attacks`
144. `Replay Attacks`
145. `Pseudorandom Functions`
146. `PRF Security`
147. `PRFs Are Stronger Than MACs`
148. `How to Create Keyed Hashes from Unkeyed Hashes`
149. `The Secret-Prefix Construction`
150. `The Secret-Suffix Construction`
151. `The HMAC Construction`
152. `A Generic Attack Against Hash-Based MACs`
153. `How to Create Keyed Hashes from Block Ciphers`
154. `Breaking CBC-MAC`
155. `Fixing CBC-MAC`
156. `Dedicated MAC Designs`
157. `Poly1305`
158. `SipHash`
159. `How Things Can Go Wrong`
160. `Timing Attacks on MAC Verification`
161. `When Sponges Leak`
162. `Further Reading`
163. `8`  
     `AUTHENTICATED ENCRYPTION`
164. `Authenticated Encryption Using MACs`
165. `Encrypt-and-MAC Approach`
166. `MAC-Then-Encrypt Composition`
167. `Encrypt-Then-MAC Composition`
168. `Authenticated Ciphers`
169. `Authenticated Encryption with Associated Data`
170. `Predictability and Nonces`
171. `Criteria for a Good Authenticated Cipher`
172. `The AES-GCM Authenticated Cipher Standard`
173. `GCM Internals`
174. `GCM Security`
175. `GCM Efficiency`
176. `The OCB Authenticated Cipher Mode`
177. `OCB Internals`
178. `OCB Security`
179. `OCB Efficiency`
180. `The SIV Authenticated Cipher Mode`
181. `Permutation-Based AEAD`
182. `How Things Can Go Wrong`
183. `AES-GCM and Weak Hash Keys`
184. `AES-GCM and Small Tags`
185. `Further Reading`
186. `PART III: ASYMMETRIC CRYPTO`
187. `9`  
     `HARD PROBLEMS`
188. `Computational Hardness`
189. `Running Time`
190. `Polynomial vs. Superpolynomial Time`
191. `Complexity Classes`
192. `Nondeterministic Polynomial Time`
193. `NP-Complete Problems`
194. `The P vs. NP Problem`
195. `The Factoring Problem`
196. `Factoring Large Numbers`
197. `Factoring Is Probably Not NP-Hard`
198. `The Discrete Logarithm Problem`
199. `Groups`
200. `The Hard Thing`
201. `How Things Can Go Wrong`
202. `When Factoring Is Easy`
203. `Small Hard Problems Aren’t Hard`
204. `Further Reading`
205. `10`  
     `RSA`
206. `The Math Behind RSA`
207. `The RSA Trapdoor Permutation`
208. `RSA Key Generation and Security`
209. `Encrypting with RSA`
210. `Textbook RSA Encryption’s Malleability`
211. `Strong RSA Encryption with OAEP`
212. `Signing with RSA`
213. `Textbook RSA Signatures`
214. `The PSS Signature Standard`
215. `Full Domain Hash Signatures`
216. `RSA Implementations`
217. `A Fast Exponentiation Algorithm`
218. `Small Exponents for Faster Public-Key Operations`
219. `The Chinese Remainder Theorem`
220. `How Things Can Go Wrong`
221. `The Bellcore Attack on RSA-CRT`
222. `Shared Private Exponents or Moduli`
223. `Further Reading`
224. `11`  
     `DIFFIE–HELLMAN`
225. `The Diffie–Hellman Function`
226. `The Diffie–Hellman Problems`
227. `The Computational Problem`
228. `The Decisional Problem`
229. `Variants of Diffie–Hellman`
230. `Key Agreement Protocols`
231. `Non-DH Key Agreement`
232. `Attack Models for Key Agreement Protocols`
233. `Performance`
234. `Diffie–Hellman Protocols`
235. `Anonymous Diffie–Hellman`
236. `Authenticated Diffie–Hellman`
237. `Menezes–Qu–Vanstone`
238. `How Things Can Go Wrong`
239. `Not Hashing the Shared Secret`
240. `Anonymous Diffie–Hellman from TLS 1.0`
241. `Unsafe Group Parameters`
242. `Further Reading`
243. `12`  
     `ELLIPTIC CURVES`
244. `What Is an Elliptic Curve?`
245. `Elliptic Curves Over Integers`
246. `The Addition Law`
247. `Elliptic Curve Groups`
248. `The ECDLP Problem`
249. `Diffie–Hellman Key Agreement over Elliptic Curves`
250. `Signing with Elliptic Curves`
251. `ECDSA Signature Generation`
252. `ECDSA Signature Verification`
253. `ECDSA vs. RSA Signatures`
254. `EdDSA and Ed25519`
255. `Encrypting with Elliptic Curves`
256. `Choosing a Curve`
257. `NIST Curves`
258. `Curve25519`
259. `Other Curves`
260. `How Things Can Go Wrong`
261. `ECDSA with Bad Randomness`
262. `Invalid Curve Attacks`
263. `Incompatible Ed25519 Validation Rules`
264. `Further Reading`
265. `PART IV: APPLICATIONS`
266. `13`  
     `TLS`
267. `Target Applications and Requirements`
268. `The TLS Protocol Suite`
269. `The TLS and SSL Families of Protocols`
270. `TLS in a Nutshell`
271. `Certificates and Certificate Authorities`
272. `The Record Protocol`
273. `The TLS Handshake Protocol`
274. `TLS 1.3 Cryptographic Algorithms`
275. `TLS 1.3 Improvements over TLS 1.2`
276. `Downgrade Protection`
277. `Single Round-Trip Handshake`
278. `Session Resumption`
279. `The Strengths of TLS Security`
280. `Authentication`
281. `Forward Secrecy`
282. `How Things Can Go Wrong`
283. `Compromised Certificate Authority`
284. `Compromised Server`
285. `Compromised Client`
286. `Bugs in Implementations`
287. `Further Reading`
288. `14`  
     `QUANTUM AND POST-QUANTUM`
289. `How Quantum Computers Work`
290. `Quantum Bits`
291. `Quantum Gates`
292. `Quantum Speedup`
293. `Exponential Speedup and Simon’s Problem`
294. `The Threat of Shor’s Algorithm`
295. `Grover’s Algorithm`
296. `Why Is It So Hard to Build a Quantum Computer?`
297. `Post-Quantum Cryptographic Algorithms`
298. `Code-Based Cryptography`
299. `Lattice-Based Cryptography`
300. `Multivariate Cryptography`
301. `Hash-Based Cryptography`
302. `The NIST Standards`
303. `How Things Can Go Wrong`
304. `Unclear Security Level`
305. `The Eventual Existence of Large Quantum Computers`
306. `Implementation Issues`
307. `Further Reading`
308. `15`  
     `CRYPTOCURRENCY CRYPTOGRAPHY`
309. `Hashing Applications`
310. `Merkle Trees`
311. `Proof of Work`
312. `Hierarchical Key Derivation`
313. `Algebraic Hash Functions`
314. `How Things Can Go Wrong`
315. `Multisignature Protocols`
316. `Multiple Multiparty Signatures`
317. `Schnorr Signature Protocols`
318. `How Things Can Go Wrong`
319. `Safer Schnorr Multisignatures`
320. `Aggregate Signature Protocols`
321. `Pairings`
322. `BLS Signatures`
323. `How Things Can Go Wrong`
324. `Threshold Signature Protocols`
325. `Use Cases`
326. `Security Model`
327. `Secret-Sharing Techniques`
328. `The Trivial Case`
329. `The Simple Case`
330. `The Hard Case`
331. `How Things Can Go Wrong`
332. `Zero-Knowledge Proofs`
333. `Security Model`
334. `Schnorr’s Protocol`
335. `Noninteractive Proofs`
336. `zkSNARKs`
337. `From Statements to Proofs`
338. `How Things Can Go Wrong`
339. `Really Serious Crypto`
340. `INDEX`