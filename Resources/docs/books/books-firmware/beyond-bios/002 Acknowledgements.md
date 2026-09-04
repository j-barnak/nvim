Vincent Zimmer

 

Suresh Marisetty

 

Michael Rothman

 

**Beyond BIOS**

 

Developing with the

Unified Extensible Firmware Interface

 

Third Edition

 

**PRESS**

ISBN 978-1-5015-1478-4

e-ISBN (PDF) 978-1-5015-0569-0

e-ISBN (EPUB) 978-1-5015-0583-6

 

**Library of Congress Cataloging-in-Publication Data**

A CIP catalog record for this book has been applied for at the Library of Congress.

 

**Bibliographic information published by the Deutsche Nationalbibliothek** The Deutsche Nationalbibliothek lists this publication in the Deutsche Nationalbibliografie; detailed bibliographic data are available on the Internet at http://dnb.dnb.de.

 

© 2017 Walter de Gruyter Inc., Boston/Berlin

Printing and binding: CPI books GmbH, Leck

♾ Printed on acid-free paper

Printed in Germany

 

www.degruyter.com

**Acknowledgements**

 

 

The authors recognize the efforts and contribution of the two men and a dog: Mark Doran, Ken Reneris, and Andrew Fish, who conceived and hatched EFI.

The authors recognize and thank the other original Framework (Tiano) archi-tects Andrew Fish, Bob Hale, Mike Kinney, Barnes Cooper, Will Stevens, Krithivas,

ER Uber, Mahesh Natu, Rahul Khanna, Jim Ewertz, Kirk Brannock, and others whose names are lost to time and the team’s intrepid leader, Mark Doran. We thank

Isaac Oram, John Lambino, and the entire Tiano Architecture Team (TAT) team for fleshing out and enhancing the architecture. Thank you to the Tiano engineering

team for their patience while implementing the first versions and to our internal and external customers. The innovation in this book is from these fertile brains. Also,

many of this team will recall over ten years of “design discussions” at R&R.

We thank our managers, past and present, for giving us the chance and the time

to work on the architecture and this book including Doug Fisher, Richard Wirt, Stu Goossen, Mike Richmond, Kah Loh, Jeff Griffen, Michael Greene, Ju Lu, and Ron

Story.

We acknowledge the ever-supportive marketing team: Shala, Laurie, Harry,

Fadi, Elmer, and Bailey.

No Intel book is published without peer review. We’d like to thank all the re-

viewers for identifying errors and for providing valuable insight and encouragement along the way. Without their help, this book would not have been a success. From

Intel, these individuals participated, at one time or another, in the review of this project: Rob Branch, Mallik Bulusu, Brad Davis, Michael Krau, John Suresh Kumar,

Matthew Parrish, Mike Richmond, Lee Rosenbaum, and Sudhakar Otturu. Other reviewers included Cameron Esfahani from Apple Computer Corporation, Todd

Greene from QLogic Corporation, Penny Huang from Micro-Star International Com-pany, Limited, Jimmy Hwang from American Megatrends, Incorporated, and Dong

Wei from Hewlett-Packard Development Company, L.P.

A book like this describes the efforts of a large number of talented individuals.

The authors would like to thank all of them for their efforts and support. Please accept our apologies if we missed you. We can only say that space is as limited here

as it is in ROMs and time as limited here as it is in schedules. We’ll try to fix it in the next release.

 

DOI 10.1515/9781501505690-001

**Preface**

 

There are two mistakes one can make on the road to truth…not going all the way, and not

starting.

Buddha

 

This is a book about a new way to solve an old set of problems that are persistent as well as fundamental, but not always well understood: How should you boot a com-

puter? What sits at the reset vector? What can the operating system count on when it is loaded and initially receives control? What should the internal structures be be-

tween these two endpoints? How can the same basic structure work for handhelds and megaservers? How do we convince ourselves today’s design will work 10 or 20

years from now? How much will it cost to switch? How much will it cost steady state? What comes after BIOS (Basic Input/Output System)?

*Beyond BIOS* is a book about a largely invisible subject. The general user, if they have any view of BIOS at all, tends to view it as ten unnecessary seconds on the way

to booting the operating system or as setup. The community that knows and uses the BIOS has tended to view it as an uncontrolled place of kludge, myth, bug, and

legend. The very small community of BIOS developers has viewed their code not only as highly mutable and embodying much of the compatibility that has made the

PC and its offspring so successful, but also as their livelihood.

This is a book that is about what comes after BIOS, which we call the Unified Ex-

tensible Firmware Interface (UEFI) and Platform Initialization (PI). In doing so, it must also be a book at least partly about what a BIOS or its replacement is called

upon to do. It is not a cookbook on how to port the PI from platform to platform. It is not a rehash of the specifications. Instead, it tries to fit in the middle ground be-

tween specifications and cookbook. It tries to focus on the concepts and constructs that are cross-platform and implied, if not stated, by the architecture. It is supposed

to help to get to some of the “why” behind the specs and make the porting work make some sense.

This book is a child of its time. Both the UEFI and the PI are under the control of the UEFI Forum, an industry-wide group in which you are encouraged to partici-

pate. *Beyond BIOS* mainly focuses on the current state of the PI and UEFI since the 2005 formation of the Forum, its working groups, and its sub-teams. This is not to

say that this is only a history book or a simple summary of the standard. Instead, we believe it remains valuable as an introduction to the newer versions of the specifica-

tions no matter who “has the pen.”

 

If you find this book to be useful, then we encourage you to obtain *Harnessing the UEFI Shell: Moving the Platform beyond DOS by* Rothman, Zimmer and Lewis, De\|G

Press, February 2017.

 

DOI 10.1515/9781501505690-002

**viii** \| Preface

 

**The Chapters**

 

## **Chapter 1** provides a description of the evolution.

 

The rest of the book is organized into two major sections. The earlier chapters pre-

sent an introduction to UEFI, and the later chapters cover the Platform Initialization.

 

## **Chapter 2** provides an overview of the basic UEFI architecture. This is a must-read

for anyone seeking an understanding of the Unified Extensible Firmware Interface (UEFI).

 

## **Chapter 3** describes the UEFI driver model. This is important for vendors writing device drivers for output devices (such as video), input devices (such as keyboards or mice), networking adapters, and block devices. These drivers can be stored in the

host-bus adapter, the platform ROM, or loaded from the UEFI system partition.

 

## **Chapter 4** describes of series of commonly used UEFI protocols. This chapter com-

plements the earlier two chapters and includes data on additional boot services application interfaces.

 

## **Chapter 5** includes information on the UEFI runtime operational environment. This chapter is important for operating system vendors who need to interact with the

platform during the operating system execution.

 

## **Chapter 6** describes UEFI input and output console services. This chapter provides details on the particular capabilities, interfaces, and relationships of the console

services.

 

## **Chapter 7** includes a list of different platforms and the Platform Initialization-based implementations. This chapter demonstrates the flexibility of the Platform Initializa-

tion by mapping the infrastructure to widely varying hardware platforms.

 

## **Chapter 8** describes the basics of the Platform Initialization Driver Execution Envi-ronment (DXE). This is important to read for anyone working on the phase of execu-

tion prior to UEFI service availability but after early pre-EFI initialization (PEI).

 

## **Chapter 9** describes some common UEFI interfaces. This chapter includes infor-mation on interfaces that are important for both UEFI and DXE development.

Preface \| **ix**

 

## **Chapter 10** describes UEFI and platform initialization issues around security and platform trust. This is important because beyond the basic UEFI and Platform Ini-

tialization specifications, which describe mechanism, further discussion is included

on composition and construction of technology.

 

## **Chapter 11** describes Boot Device Selection (BDS). This includes the policy by which

Framework platforms decide look-and-feel, in addition to how to boot.

 

## **Chapter 12** describes the various boot flows that can occur within a platform. These

include power-event restarts, and so on.

 

## **Chapter 13** describes the Pre-EFI Initialization environment. This is the phase of

execution that occurs after reset and is responsible for the early hardware state and memory initialization.

 

## **Chapter 14** includes information on emulation of a firmware environment within an operating system.

 

## **Chapter 15** describes mechanisms and capabilities for reducing platform boot time. Since “visible” firmware is often broken firmware, decreasing time for a system

restart is key.

 

## **Chapter 16** describes the application of firmware for an embedded boot solution. The bulk of shipping systems are embedded computing environments, so the use of

UEFI and Platform Initialization for this class of system is becoming more im-portant.

 

## **Chapter 17** includes details on manageability. The platform and firmware play a

pivotal role in both bare-metal, OS-absent scenarios and also as a complement to OS runtime manageability usages.

 

The Appendixes include source code data types and commonly-used interfaces.