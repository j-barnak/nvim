![](media/index-1233_1.jpg)

C DATE AND TIME FORMAT SPECIFIERS

The examples listed in Table C-1 are based on the date of January 19, 2038, at 03:14:07 UTC, the time at which the 32-bit Unix time

representation overflows.

Table C-1: Format Specifiers for Date and Time Formatting in the EST

Time Zone with Current Locale en_US.UTF-8

Format Example

Meaning

%a

Mon

Locale’s abbreviated weekday name

%A

Monday

Locale’s full weekday name

%b

Jan

Locale’s abbreviated month name

%B

January

Locale’s full month name

%c

Mon 18 Jan 2038

Locale’s date and time

10:14:07 PM EST

%C

20

Century; like %Y, except omit last two

digits

%d

18

Day of month

%D

01/18/38

Date; same as %m/%d/%y

Format Example

Meaning

%e

18

Day of month, space padded; same as

%\_d

%F

2038-01-18

Full date, like %Y-%m-%d

%g

38

Last two digits of year of ISO week number

(see %G)

%G

2038

Year of ISO week number (see %V);

normally useful only with %V

%h

Jan

Same as %b

%H

22

Hour (00–23)

%I

10

Hour (01–12)

%j

18

Day of year (001–366)

%k

22

Hour, space padded (0–23); same as %\_H

%l

10

Hour, space padded (1–12); same as %\_I

%m

1

Month (01–12)

%M

14

Minute (00–59)

%n

A newline

%N

0

Nanosecond

(000000000–999999999)

%p

PM

Locale’s equivalent of either AM or

PM; blank if not known

%P

pm

Like %p, but lowercase

%q

1

Quarter of year (1–4)

%r

10:14:07 PM

Locale’s 12-hour clock time

%R

22:14

24-hour hour and minute; same as %H:%M

%s

2147483647

Seconds since 1970-01-01

00:00:00 UTC

Format Example

Meaning

%S

7

Second (00–60)

%T

22:14:07

Time; same as %H:%M:%S

%u

1

Day of week (1–7); 1 is Monday

%U

3

Week number of year, with Sunday as

first day of week (00–53)

%V

3

ISO week number, with Monday as first

day of week (01–53)

%w

1

Day of week (0–6); 0 is Sunday

%W

3

Week number of year, with Monday as

first day of week (00–53)

%x

01/18/2038

Locale’s date representation

%X

10:14:07 PM

Locale’s time representation

%y

38

Last two digits of year (00–99)

%Y

2038

Year

%z

-500

\+ *hhmm* numeric time zone

%Z

EST

Alphabetic time zone abbreviation