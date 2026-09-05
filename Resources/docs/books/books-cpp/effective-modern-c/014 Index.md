**304 \| Index**

CRTP (Curiously Recurring Template Pattern),

copy operation, 3

131

CRTP (Curiously Recurring Template Pat‐

ctor (see constructor)

tern), 131

Curiously Recurring Template Pattern (CRTP),

ctor, 6

131

custom deleter, 120

custom deleters, definition of, 120

dangling pointer, 134

dead stores, 276

**D**

declaration, 5

dangling pointer, definition of, 134

deep copy, 154

dangling references, 217

definition, 5

dead stores, definition of, 276

deleted function, 75

Dealtry, William, xiv

dependent type, 64

declarations, definition of, 5

deprecated feature, 6

decltype, 23-30

disabled templates, 189

auto&& parameters in lambdas and,

dtor, 6

229-232

enabled templates, 189

decltype(auto) and, 26

exception safe, 4

reference collapsing and, 203

exception-neutral, 93

return expressions and, 29

exclusive ownership, 119

treatment of names vs. treatment of expres‐

expired std::weak_ptr, 135

sions, 28

function argument, 4

deduced types, viewing, 30-35

function objects, 5

deduction, type (see type deduction)

function parameter, 4

deep copy, definition of, 154

function signature, 6

default capture modes, 216-223

generalized lambda capture, 225

default launch policy, 246-249

generic lambdas, 229

thread-local storage and, 247

hardware thread, 242

defaulted dtor, 152

incomplete type, 148

defaulted member functions, 112

init capture, 224

defaulted virtual destructors, 112

integral constant expression, 97

definition of terms

interruptible thread, 256

alias template, 63

joinable std::thread, 250

alias templates, 63

lambda, 5, 215

array decay, 15

lambda expression, 215

basic guarantee, 4

lhs, 3

braced initialization, 50

literal types, 100

C++03, 2

lvalue, 2

C++11, 2

make function, 139

C++14, 2

memory-mapped I/O, 276

C++98, 2

most vexing parse, 51

callable object, 5

move operation, 3

class template, 5

move semantic, 157

closure, 5, 216

move-only type, 105, 119

closure class, 216

named return value optimization (NRVO),

code smell, 263

174

const propagation, 210

narrow contracts, 95-96

contextual keyword, 83

narrowing conversions, 51

control block, 128

non-dependent type, 64

copy of an object, 4

**Index \| 305**

NRVO (named return value optimization),

wide contracts, 95-96

174

Widget, 3

override, 79

definitions of terms

oversubscription, 243

alias declarations, 63

parameter forwarding, 207

copy elision, 174

perfect forwarding, 4, 157, 207

definitions, definition of, 5

Pimpl Idiom, 147

deleted functions, 74-79

RAII classes, 253

definition of, 75

RAII object, 253

vs. private and undefined ones, 74-79

RAII objects, 253

deleters

raw pointer, 6

custom, 142

redundant loads, 276

std::unique_ptr vs. std::shared_ptr, 126, 155

reference collapsing, 198

deleting non-member functions, 76-77

reference count, 125

deleting template instantiations, 77-78

reference qualifier, 80

dependent type, definition of, 64

relaxed memory consistency, 274

deprecated features

resource ownership, 117

automatic copy operation generation, 112

return value optimization (RVO), 174

C++98-style exception specifications, 90

rhs, 3

definition of, 6

Rule of Three, 111

std::auto_ptr, 118

rvalue, 2

destructor

RVO (return value optimization), 174

defaulted, 112, 152

scoped enums, 67

relationship to copy operations and

sequential memory consistency, 274

resource management, 111

shallow copy, 154

digit separators, apostrophes as, 252

shared ownership, 125

disabled templates, definition of, 189

shared state, 259

dtor (see destructor)

small string optimization (SSO), 205

Dziubinski, Matt P., xiv

smart pointers, 6

software threads, 242

**E**

special member functions, 109

Einstein's theory of general relativity, 168

spurious wakeups, 264

ellipses, narrow vs. wide, 3

static storage duration, 222

emplacement

strong guarantee, 4

construction vs. assignment and, 295

tag dispatch, 188

emplacement functions, 293-300

task-based programming, 241

exception safety and, 296-299

template class, 5

explicit constructors and, 299-300

template function, 5

heuristic for use of, 295-296

thread local storage (TLS), 247

perfect forwarding and, 294

thread-based programming, 241

vs. insertion, 292-301

trailing return type, 25

enabled templates, definition of, 189

translation, 97

enums

undefined behavior, 6

compilation dependencies and, 70

uniform initialization, 50

enum classes (see scoped enums)

unjoinable std::thread, 250

forward declaring, 69-71

unscoped enum, 67

implicit conversions and, 68

unscoped enums, 67

scoped vs. unscoped, 67

weak count, 144

std::get and, 71-73

weak memory consistency, 274

std::tuples and, 71-73

**306 \| Index**

underlying type for, 69-71

Widget::processPointer, 78

equals sign (=), assignment vs. initialization, 50

Wine, 65

errata list for this book, 7

example functions/templates

error messages, universal reference and, 195

(see also std::)

event communication

addDivisorFilter, 217, 223

boolean flags, 264

arraySize, 16

condition variables and, 262

authAndAccess, 25-28, 26-27

cost and efficiency of polling, 265

Base::Base, 113

future as mechanism for, 266-270

Base::doWork, 79

example classes/templates

Base::mf1, 81-82

(see also std::)

Base::mf2, 81-82

Base, 79-82, 112

Base::mf3, 81-82

Bond, 119

Base::mf4, 81-82

Derived, 79, 81-82

Base::operator=, 113

Investment, 119, 122

Base::~Base, 112

IPv4Header, 213

calcEpsilon, 47

IsValAndArch, 226

calcValue, 261

MyAllocList, 64

cbegin, 88

MyAllocList\<Wine\>, 65

cleanup, 96

Password, 288-290

compress, 237

Person, 180-182, 184, 189, 191, 193, 196

computerPriority, 140

Point, 24, 100, 101, 106

continueProcessing, 70

Polynomial, 103-105

createInitList, 23

PolyWidget, 239

createVec, 32, 35

RealEstate, 119

cusDel, 146

ReallyBigType, 145

delInvmt2, 123

SomeCompilerGeneratedClassName, 229

Derived::doWork, 79

SpecialPerson, 183, 192

Derived::mf1, 81-82

SpecialWidget, 291

Derived::mf2, 81-82

std::add_lvalue_reference, 66

Derived::mf3, 81-82

std::basic_ios, 75

Derived::mf4, 81-82

std::get, 257

detect, 268, 270

std::pair, 93

doAsyncWork, 241-242

std::remove_const, 66

doSomething, 83

std::remove_reference, 66

doSomeWork, 57, 221

std::string, 160

doWork, 96, 251, 255

std::vector, 24, 166, 292

dwim, 37-38

std::vector\<bool\>, 46

f, 10-16, 18, 22-23, 32, 34, 59, 90, 95,

Stock, 119

164-166, 199, 208, 247

StringTable, 113

f1, 17, 29, 60

struct Point, 24

f2, 17, 29, 60

TD, 31

f3, 60

ThreadRAII, 254, 257

fastLoadWidget, 136

Warning, 83

features, 43

Widget, 3, 5, 50, 52, 64, 78, 80, 83, 106-108, findAndInsert, 88

109, 112, 115, 130-132, 148-155, 162,

func, 5, 39, 197-198, 201

168-170, 202, 210, 219, 224, 260,

func_for_cx, 19

281-288, 291

func_for_rx, 19

Widget::Impl, 150-153

func_for_x, 19

**Index \| 307**

fwd, 207

SomeCompilerGeneratedClassName::oper‐

Investment::~Investment, 122

ator(), 229

isLucky, 76

someFunc, 4, 17, 20, 167

IsValAndArch::IsValAndArch, 226

SpecialPerson::SpecialPerson, 183, 192

IsValAndArch::operator(), 226

SpecialWidget::processWidget, 291

killWidget, 297

std::add_lvalue_reference, 66

loadWidget, 136

std::basic_ios::basic_ios, 75, 160

lockAndCall, 61

std::basic_ios::operator=, 75, 160

logAndAdd, 177-179, 186-187

std::forward, 199-201, 230

logAndAddImpl, 187-188

std::get, 257

logAndProcess, 161

std::make_shared, 139-147, 171

makeInvestment, 119-120, 122-123

std::make_unique, 139-147, 171

makeStringDeque, 27

std::move, 158

makeWidget, 80, 84, 174-176

std::pair::swap, 93

midpoint, 101

std::remove_const, 66

myFunc, 16

std::remove_reference, 66

nameFromIdx, 179

std::swap, 93

operator+, 3, 172-173

std::vector::emplace_back, 167

Password::changeTo, 288-289

std::vector::operator\[\], 24, 24

Password::Password, 288

std::vector::push_back, 166, 292

Person::Person, 180-182, 184, 189, 191, std::vector\<bool\>::operator\[\], 46

193-194, 196

StringTable::StringTable, 113

Point::distanceFromOrigin, 106

StringTable::~StringTable, 113

Point::Point, 100

ThreadRAII::get, 254, 257

Point::setX, 100-101

ThreadRAII::operator=, 257

Point::setY, 100

ThreadRAII::ThreadRAII, 254, 257

Point::xValue, 100

ThreadRAII::~ThreadRAII, 254, 257

Point::yValue, 100-101

toUType, 73

Polynomial::roots, 103-105

Warning::override, 83

PolyWidget::operator(), 239

Widget::addFilter, 219-222

pow, 99-100

Widget::addName, 281-284

primeFactors, 68

Widget::create, 132

process, 130, 132, 161

Widget::data, 83-85

processPointer, 77, 78

Widget::doWork, 80

processPointer\<char\>, 77

Widget::isArchived, 224

processPointer\<const char\>, 77

Widget::isProcessed, 224

processPointer\<const void\>, 77

Widget::isValidated, 224

processPointer\<void\>, 78

Widget::magicValue, 106-108

processVal, 211

Widget::operator float, 53

processVals, 3

Widget::operator=, 109, 112, 115, 152-154

processWidget, 146

Widget::process, 130-131

react, 268

Widget::processPointer\<char\>, 77

reallyAsync, 249

Widget::processPointer\<void\>, 77

reduceAndCopy, 173

Widget::processWidget, 140

reflection, 102

Widget::setName, 169-170

setAlarm, 233, 235

Widget::setPtr, 286

setSignText, 172

Widget::Widget, 3, 52-55, 109, 112, 115, setup, 96

148-155, 162, 168-169

Widget::~Widget, 112, 148, 151

**308 \| Index**

widgetFactory, 201

**G**

workOnVal, 212

generalized lambda capture, definition of, 225

workWithContainer, 218

generic code, move operations and, 206

example structs (see example classes/templates)

generic lambdas

exception safety

definition of, 229

alternatives to std::make_shared, 145-147, operator() in, 229

298

gratuitous swipe at Python, 293

definition of, 4

gratuitous use

emplacement and, 296-299

of French, 164, 194

make functions and, 140, 298

of Yiddish, 82

exception specifications, 90

greediest functions in C++, 180

exception-neutral, definition of, 93

Grimm, Rainer, xiv

exclusive ownership, definition of, 119

expired std::weak_ptr, 135

**H**

explicit constructors, insertion functions and,

299

Halbersma, Rein, xiv

explicitly typed initializer idiom, 43-48

hardware threads, definition of, 242

highlighting in this book, 3

**F**

Hinnant, Howard, xiv

"Hitchhiker's Guide to the Galaxy, The", allu‐

Facebook, 299

sion to, 30

feminine manifestation of the divine (see

Huchley, Benjamin, xiv

Urbano, Nancy L.)

Fernandes, Martinho, xiv

**I**

final keyword, 83

Fioravante, Matthew, xiv

implicit copy operations, in classes declaring

forwarding (see perfect forwarding)

move operations, 111

forwarding references, 164

implicit generation of special member func‐

French, gratuitous use of, 164, 194

tions, 109-115

Friesen, Stanley, xiii

incomplete type, definition of, 148

function

indeterminate destructor behavior for futures,

arguments, definition of, 4

260

conditionally noexcept, 93

inference, type (see type deduction)

decay, 17

init capture, 224-229

defaulted (see defaulted member functions)

definition of, 224

deleted, 74-79

initialization

greediest in C++, 180

braced, 50

member, 87

order with std::thread data members, 254

member reference qualifiers and, 83-85

syntaxes for, 49

member templates, 115

uniform, 50

member, defaulted, 112

inlining, in lambdas vs. std::bind, 236

names, overloaded, 211-213

insertion

non-member, 88

explicit constructors and, 300

objects, definition of, 5

vs. emplacement, 292-301

parameters, definition of, 4

integral constant expression, definition of, 97

pointer parameter syntaxes, 211

interface design

private and undefined, 74

constexpr and, 102

return type deduction, 25-26

exception specifications and, 90

signature, definition of, 6

wide vs. narrow contracts, 95

universal references and, 180

interruptible threads, definition of, 256

**Index \| 309**

**J**

Lavavej, Stephan T., xiii, 139

"Jabberwocky", allusion to, 289

legacy types, move operations and, 203

John 8:32, allusion to, 164

lhs, definition of, 3

joinability, testing std::threads for, 255

Liber, Nevin “:-)”, xiv

joinable std::threads

literal types, definition of, 100

definition of, 250

load balancing, 244

destruction of, 251-253

local variables

testing for joinability, 255

by-value return and, 173-176

when not destroyed, 120

**K**

lvalues, definition of, 2

Kaminski, Tomasz, xiv

Karpov, Andrey, xiv

**M**

keywords, contextual, 83

Maher, Michael, xv

Kirby-Green,Tom, xiv

make functions

Kohl, Nate, xiv

avoiding code duplication and, 140

Kreuzer, Gerhard, xiv, xv

custom deleters and, 142

Krügler, Daniel, xiii

definition of, 139

exception safety and, 140-142, 298

**L**

parentheses vs. braces, 143

"Mary Poppins", allusion to, 289

lambdas

Matthews, Hubert, xiv

auto&& parameters and decltype in,

memory

229-232

consistency models, 274

bound and unbound arguments and, 238

memory-mapped I/O, definition of, 276

by-reference captures and, 217-219

Merkle, Bernhard, xiii

by-value capture, drawbacks of, 219-223

Mesopotamia, 109

by-value capture, pointers and, 219

"Modern C++ Design" (book), xiii

creating closures with, 216

most vexing parse, definition of, 51

dangling references and, 217-219

move capture, 224

default capture modes and, 216-223

emulation with std::bind, 226-229, 239

definition of, 5, 215

lambdas and, 239

expressive power of, 215

move operations

generic, 229

defaulting, 113-114

implicit capture of the this pointer, 220-222

definition of, 3

init capture, 224-229

generic code and, 206

inlining and, 236

implicitly generated, 109-112

lambda capture and objects of static storage

legacy types and, 203

duration, 222

Pimpl Idiom and, 152-153

move capture and, 238

std::array and, 204

overloading and, 235

std::shared_ptr and, 126

polymorphic function objects and, 239

std::string and, 205

variadic, 231

strong guarantee and, 205

vs. std::bind, 232-240

templates and, 206

bound arguments, treatment of, 238

move operations and

inlining and, 236

move semantics, definition of, 157

move capture and, 239

move-enabled types, 110

polymorphic functions objects and, 239

move-only type, definition of, 105, 119

readability and, 232-236

unbound arguments, treatment of, 238

**310 \| Index**

**N**

universal references and, 171, 177-197

named return value optimization (NRVO), 174

override, 79-85

narrow contracts, definition of, 95-96

as keyword, 83

narrow ellipsis, 3

requirements for overriding, 79-81

narrowing conversions, definition of, 51

virtual functions and, 79-85

Needham, Bradley E., xiv, xv

oversubscription, definition of, 243

Neri, Cassio, xiv

"Overview of the New C++" (book), xiii

Newton's laws of motion, 168

Niebler, Eric, xiv

**P**

Nikitin, Alexey A., xiv

parameters

noexcept, 90-96

forwarding, definition of, 207

compiler warnings and, 96

of rvalue reference type, 2

conditional, 93

Parent, Sean, xiv

deallocation functions and, 94

pass by value, 281-292

destructors and, 94

efficiency of, 283-291

function interfaces and, 93

slicing problem and, 291

move operations and, 91-92

perfect forwarding

operator delete and, 94

(see also universal references)

optimization and, 90-93

constructors, 180-183, 188-194

strong guarantee and, 92

copying objects and, 180-183

swap functions and, 92-93

inheritance and, 183, 191-193

non-dependent type, definition of, 64

definition of, 4, 157, 207

non-member functions, 88

emplacement and, 294

deleting, 76

failure cases, 207-214

Novak, Adela, 171

bitfields, 213

NRVO (named return value optimization), 174

braced initializers, 208

NULL

declaration-only integral static const

overloading and, 59

data members, 210-211

templates and, 60

overloaded function/template names,

nullptr

211

overloading and, 59

std::bind and, 238

templates and, 60-62

Pimpl Idiom, 147-156

type of, 59

compilation time and, 148

vs. 0 and NULL, 58-62

copy operations and, 153-154

definition of, 147

**O**

move operations and, 152-153

objects

std::shared_ptr and, 155-156

() vs. {} for creation of, 49-58

std::unique_ptr and, 149

destruction of, 120

polling, cost/efficiency of, 265

operator templates, type arguments and, 235

polymorphic function objects, 239

operator(), in generic lambdas, 229

private and undefined functions, vs. deleted

operator\[\], return type of, 24, 46

functions, 74

Orr, Roger, xiv

proxy class, 45-46

OS threads, definition of, 242

Python, gratuitous swipe at, 293

overloading

alternatives to, 184-197

**R**

lambdas and, 235

races, testing for std::thread joinability and, 255

pointer and integral types, 59

RAII classes

scalability of, 171

definition of, 253

**Index \| 311**

for std::thread objects, 269

**S**

RAII objects, definition of, 253

Schober, Hendrik, xiii

raw pointers

scoped enums

as back pointers, 138

definition of, 67

definition of, 6

vs. unscoped enums, 67-74

disadvantages of, 117

sequential consistency, definition of, 274

read-modify-write (RMW) operations, 272

SFINAE technology, 190

std::atomic and, 272

shallow copy, definition of, 154

volatile and, 272

shared ownership, definition of, 125

redundant loads, definition of, 276

shared state

reference collapsing, 197-203

definition of, 259

alias declarations and, 202

future destructor behavior and, 259

auto and, 201

reference count in, 259

contexts for, 201-203

shared_from_this, 131

decltype and, 203

Simon, Paul, 117

rules for, 199

slicing problem, 291

typedefs and, 202

small string optimization (SSO), 205, 290

reference count, definition of, 125

smart pointers, 117-156

reference counting control blocks (see control

dangling pointers and, 134

blocks)

definition of, 6, 118

reference qualifiers

exclusive-ownership resource management

definition of, 80

and, 118

on member functions, 83-85

vs. raw pointers, 117

references

software threads, definition of, 242

dangling, 217

special member functions

forwarding, 164

definition of, 109

in binary code, 210

implicit generation of, 109-115

to arrays, 16

member function templates and, 115

to references, illegality of, 198

"special" memory, 275-277

relaxed memory consistency, 274

spurious wakeups, definition of, 264

reporting bugs and suggesting improvements, 6

SSO (small string optimization), 205, 290

Resource Acquisition is Initialization (see

"Star Trek", allusion to, 125

RAII)

"Star Wars", allusion to, 189

resource management

static storage duration, definition of, 222

copy operations and destructor and, 111

static_assert, 151, 196

deletion and, 126

std::add_lvalue_reference, 66

resource ownership, definition of, 117

std::add_lvalue_reference_t, 66

return value optimization (RVO), 174-176

std::allocate_shared

rhs, definition of, 3

and classes with custom memory manage‐

RMW (read-modify-write) operations, 272

ment and, 144

Rule of Three, definition of, 111

efficiency of, 142

rvalue references

std::all_of, 218

definition of, 2

std::array, move operations and, 204

final use of, 172

std::async, 243

parameters, 2

default launch policy, 246-249

passing to std::forward, 231-232

destructors for futures from, 259

vs. universal references, 164-168

launch policy, 245

rvalue_cast, 159

launch policy and thread-local storage,

RVO (see return value optimization)

247-248

**312 \| Index**

launch policy and timeout-based loops, 247

std::literals, 233

std::packaged_task and, 261

std::make_shared, 139-147, 171

std::atomic

(see also make functions)

code reordering and, 273

alternatives to, 298

copy operations and, 277

classes with custom memory management

multiple variables and transactions and,

and, 144

106-108

efficiency of, 142

RMW operations and, 272

large objects and, 144-145

use with volatile, 279

std::make_unique, 139-147, 171

vs. volatile, 271-279

(see also make functions)

std::auto_ptr, 118

std::move, 158-161

std::basic_ios, 75

by-value parameters and, 283

std::basic_ios::basic_ios, 75

by-value return and, 172-176

std::basic_ios::operator=, 75

casts and, 158

std::bind

const objects and, 159-161

bound and unbound arguments and, 238

replacing with std::forward, 162-163

inlining and, 236

rvalue references and, 168-173

move capture and, 238

universal references and, 169

move capture emulation and, 226-229

std::move_if_noexcept, 92

overloading and, 235

std::nullptr_t, 59

perfect forwarding and, 238

std::operator, 160

polymorphic function objects and, 239

std::operator=, 75

readability and, 232-236

std::operator\[\], 24, 46

vs. lambdas, 232-240

std::packaged_task, 261-262

std::cbegin, 88

std::async and, 261

std::cend, 88

std::pair, 93

std::crbegin, 88

std::pair::swap, 93

std::crend, 88

std::plus, 235

std::decay, 190

std::promise, 258

std::enable_if, 189-194

setting, 266

std::enable_shared_from_this, 131-132

std::promise\<void\>, 267

std::false_type, 187

std::rbegin, 88

std::forward, 161-162, 199-201

std::ref, 238

by-value return and, 172-176

std::remove_const, 66

casts and, 158

std::remove_const_t, 66

passing rvalue references to, 231

std::remove_reference, 66

replacing std::move with, 162

std::remove_reference_t, 66

universal references and, 168-173

std::rend, 88

std::function, 39-40

std::result_of, 249

std::future\<void\>, 267

std::shared_future\<void\>, 267

std::initializer_lists, braced initializers and, 52

std::shared_ptr, 125-134

std::is_base_of, 192

arrays and, 133

std::is_constructible, 195

construction from raw pointer, 129-132

std::is_nothrow_move_constructible, 92

construction from this, 130-132

std::is_same, 190-191

conversion from std::unique_ptr, 124

std::launch::async, 246

creating from std::weak_ptr, 135

automating use as launch policy, 249

cycles and, 137

std::launch::deferred, 246

deleters and, 126

timeout-based loops and, 247

vs. std::unique_ptr deleters, 155

**Index \| 313**

efficiency of, 125, 133

**T**

move operations and, 126

T&&, meanings of, 164

multiple control blocks and, 129

tag dispatch, 185-188

size of, 126

task-based programming, definition of, 241

vs. std::weak_ptr, 134

tasks

std::string, move operations and, 205

load balancing and, 244

std::swap, 93

querying for deferred status, 248

std::system_error, 242

vs. threads, 241-245

std::threads

template

as data members, member initialization

alias templates, 63-65

order and, 254

aliases, 63

destroying joinable, 251-253

classes, definition of, 5

implicit join or detach, 252

disabled vs. enabled, 189

joinable vs. unjoinable, 250

functions, definition of, 5

RAII class for, 253-257, 269

instantiations, deleting, 77

std::true_type, 187

move operations and, 206

std::unique_ptr, 118-124

names, perfect forwarding and, 211

conversion to std::shared_ptr, 124

parentheses vs. braces in, 57

deleters and, 120-123, 126

standard operators and type arguments for,

vs. std::shared_ptr deleters, 155

235

efficiency of, 118

type deduction, 9-18

factory functions and, 119-123

array arguments and, 15-17

for arrays, 124

for pass by value, 14-15

size of, 123

for pointer and reference types, 11-14

std::vector, 24, 166, 292

for universal references, 13-14

std::vector constructors, 56

function arguments and, 17

std::vector::emplace_back, 167

vs. auto type deduction, 18-19

std::vector::push_back, 166, 292

terminology and conventions, 2-6

std::vector\<bool\>, 43-46

testing std::threads for joinability, 255

std::vector\<bool\>::operator\[\], 46

"The Hitchhiker's Guide to the Galaxy", allu‐

std::vector\<bool\>::reference, 43-45

sion to, 30

std::weak_ptr, 134-139

"The View from Aristeia" (blog), xv, 269

caching and, 136

thread handle destructor behavior, 258-262

construction of std::shared_ptr with, 135

thread local storage (TLS), definition of, 247

cycles and, 137

thread-based programming, definition of, 241

efficiency of, 138

threads

expired, 135

destruction, 252

observer design pattern and, 137

exhaustion, 243

vs. std::shared_ptr, 134

function return values and, 242

Steagall, Bob, xiv

hardware, 242

Stewart, Rob, xiv

implicit join or detach, 252

strong guarantee

joinable vs. unjoinable, 250

definition of, 4

OS threads, 242

move operations and, 205

setting priority/affinity, 245, 252, 268

noexcept and, 91

software, 242

Summer, Donna, 294

suspending, 268-270

Supercalifragilisticexpialidocious, 289

system threads, 242

Sutter, Herb, xiv

testing for joinability, 255

system threads, 242

vs. tasks, 241-245

**314 \| Index**

thread_local variables, 247

vs. rvalue references, 164-168

time suffixes, 233

unjoinable std::threads, definition of, 250

timeout-based loops, 247

unscoped enums

TLS (see thread-local storage)

definition of, 67

translation, definition of, 97

vs. scoped enums, 67-74

type arguments, operator templates and, 235

Urbano, Nancy L. (see feminine manifestation

type deduction

of the divine)

(see also template, type deduction)

for auto, 18-23

**V**

emplace_back and, 166

Vandewoestyn, Bart, xiv

universal references and, 165

variadic lambdas, 231

type inference (see type deduction)

"View from Aristeia, The" (blog), xv, 269

type traits, 66-67

virtual functions, override and, 79-85

type transformations, 66

void future, 267

typedefs, reference collapsing and, 202

volatile

typeid and viewing deduced types, 31-33

code reordering and, 275

typename

dead stores and, 276

dependent type and, 64

redundant loads and, 276

non-dependent type and, 64

RMW operations and, 272

vs. class for template parameters, 3

"special" memory and, 275-277

types, testing for equality, 190

use with std::atomic, 279

vs. std::atomic, 271-279

**U**undefined behavior, definition of, 6

**W**

undefined template to elicit compiler error

Wakely, Jonathan, xiv

messages, 31

warnings, compiler (see compiler warnings)

uniform initialization, 50

Watkins, Damien, xiv

universal references

weak count, definition of, 144

(see also perfect forwarding)

weak memory consistency, 274

advantages over overloading, 171

wide contracts, definition of, 95-96

alternatives to overloading on, 183-197

wide ellipsis, 3

auto and, 167

Widget, definition of, 3

constructors and, 180-183, 188-194

Williams, Anthony, xiii, 257

efficiency and, 178

Williams, Ashley Morgan, xv

error messages and, 195-196

Williams, Emyr, xv

final use of, 172

Winkler, Fredrik, xiv

greedy functions and, 180

Winterberg, Michael, xiv

initializers and, 165

lvalue/rvalue encoding, 197

names of, 167

**Y**

overloading and, 177-197

Yiddish, gratuitous use of, 82

real meaning of, 202

std::move and, 169

**Z**

syntactic form of, 165

Zolman, Leor, xiii, xiv

type deduction and, 165

Zuse, Konrad, 195

**Index \| 315**