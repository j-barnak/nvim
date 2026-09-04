# `INTRODUCTION`

![](media/636a68d74eb8359117dad78bd99a98f0c37c7dbb.jpg)

I wrote this book to be the one I wish I had when I started learning cryptography. In 2005, I was studying for my master’s degree near Paris, and I eagerly registered for the upcoming semester’s crypto class. Unfortunately, the class was canceled because too few students had registered. “Crypto is too hard,” the students argued, instead enrolling en masse in the computer graphics and database classes.

I’ve heard “crypto is hard” dozens of times since then. But is it really *that* hard? To play an instrument, master a programming language, or put the applications of any field into practice, you need to learn some concepts and symbols, but doing so doesn’t take a PhD. The same applies to becoming a competent cryptographer. Perhaps crypto is perceived as hard because cryptographers haven’t done a good job of teaching it.

I also wrote this book because cryptography has expanded into a multidisciplinary field. To do anything useful and relevant in crypto, you need to understand the concepts *around* crypto: how networks and computers work, what users and systems need, and how attackers can abuse algorithms and their implementations. In other words, you need a connection to reality.

## `This Book’s Approach`

The initial title of this book was *Crypto for Real* to stress the practice-oriented, real-world, no-nonsense approach I follow. I wanted to make cryptography approachable not by dumbing it down but by tying it to real applications. I provide source code examples and describe real bugs and horror stories.

Along with a clear connection to reality, other cornerstones of this book are its simplicity and its modernity. I focus on simplicity in form more than in substance: I present nontrivial concepts without the dull mathematical formalism. Instead, I attempt to impart an understanding of cryptography’s core ideas, which are more important than remembering a bunch of equations. To ensure the book’s modernity, I cover the latest developments and applications of cryptography, such as TLS 1.3 and post-quantum cryptography. I don’t discuss the details of obsolete or insecure algorithms such as DES or MD5. An exception to this is RC4, but it’s included only to explain how weak it is and to show how a stream cipher of its kind works.

*Serious Cryptography* isn’t a guide to crypto software, nor is it a compendium of technical specifications—stuff that you’ll easily find online. Instead, its foremost goal is to get you excited about cryptography and teach you its fundamental concepts along the way.

## `Who This Book Is For`

While writing, I often imagined the reader as a developer who’d been exposed to cryptography but still felt clueless and frustrated after reading abstruse textbooks and research papers. Developers often need—and want—a better grasp of crypto to avoid unfortunate design choices, and I hope this book helps.

If you aren’t a developer, don’t worry! The book doesn’t require coding skills and is accessible to anyone who understands the basics of computer science and high school math (notions of probabilities, modular arithmetic, and so on).

This book can nonetheless be intimidating, and despite its relative accessibility, it requires some effort to get the most out of it. I like the mountaineering analogy: the author paves the way, providing you with ropes and ice axes to facilitate your work, but you make the ascent yourself. Learning the concepts in this book takes effort but is rewarding.

## `How This Book Is Organized`

The book has 15 chapters, loosely split into four parts. The chapters are mostly independent from one another, except for Chapter 9, which lays the foundations for the three subsequent chapters. I recommend reading the first three chapters before anything else.

### `Part I``: Fundamentals`

**Chapter 1: Encryption **Introduces the notion of secure encryption, from weak pen-and-paper ciphers to strong, randomized encryption

**Chapter 2: Randomness **Describes how a pseudorandom generator works, what it takes for one to be secure, and how to use one securely

**Chapter 3: Cryptographic Security **Discusses theoretical and practical notions of security and compares provable security with probable security

### `Part II``: Symmetric Crypto`

**Chapter 4: Block Ciphers **Deals with ciphers that process messages block per block, focusing on the most famous one, the Advanced Encryption Standard (AES)

**Chapter 5: Stream Ciphers **Presents ciphers that produce a stream of random-looking bits that are XORed with messages to be encrypted

**Chapter 6: Hash Functions **Discusses the only algorithms that don’t work with a secret key, which turn out to be the most ubiquitous crypto building blocks

**Chapter 7: Keyed Hashing **Explains what happens if you combine a hash function with a secret key and how this serves to authenticate messages

**Chapter 8: Authenticated Encryption **Shows how some algorithms can both encrypt and authenticate a message, with examples such as the standard AES-GCM

### `Part III``: Asymmetric Crypto`

**Chapter 9: Hard Problems **Lays out the fundamental concepts behind public-key encryption, using notions from computational complexity

**Chapter 10: RSA **Leverages the factoring problem in order to build secure encryption and signature schemes with a simple arithmetic operation

**Chapter 11: Diffie–Hellman **Extends asymmetric cryptography to the notion of key agreement, wherein two parties establish a secret value using only nonsecret values

**Chapter 12: Elliptic Curves **Provides a gentle introduction to elliptic curve cryptography, which is the fastest kind of asymmetric cryptography

### `Part IV``: Applications`

**Chapter 13: TLS **Focuses on Transport Layer Security (TLS), arguably the most important protocol in network security

**Chapter 14: Quantum and Post-Quantum **Presents the concepts of quantum computing and post-quantum cryptography

**Chapter 15: Cryptocurrency Cryptography **Concludes with an overview of advanced cryptographic schemes found in blockchain applications

## `On the Second Edition`

This second edition of *Serious Cryptography* comes seven years after the first edition. Since then, cryptography has experienced significant changes. Nowadays, the term *crypto* often conjures thoughts of blockchain, Bitcoin, and other cryptocurrencies, rather than cryptography itself. Despite the debatable societal benefits of these technologies, their undeniable influence on the advancement of cryptography research and engineering can’t be overlooked. Recognizing this, I’ve written Chapter 15, “Cryptocurrency Cryptography,” which delves into fascinating cryptographic techniques employed in blockchain applications, representing some of the most intriguing advancements in the field of cryptography.

I’ve made substantial changes to each chapter, updating the text with respect to new cryptography developments and improving the text’s clarity and conciseness. Among the most significant additions: Chapter 2’s discussion of Linux kernel randomness was updated to describe the new behavior of the */dev/random* and */dev/urandom* interfaces, Chapter 12 features a new section on the EdDSA and Ed25519 signature schemes, and Chapter 14 presents NIST’s Post-Quantum Cryptography Standardization project.