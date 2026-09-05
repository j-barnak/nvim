#### Chapter 7.

# Evaluating Expressions

> You are my creator, but I am your master; Obey!
>
> Mary Shelley, *Frankenstein*

If you want to properly set the mood for this chapter, try to conjure up a thunderstorm, one of those swirling tempests that likes to yank open shutters at the climax of the story. Maybe toss in a few bolts of lightning. In this chapter, our interpreter will take breath, open its eyes, and execute some code.

![A bolt of lightning strikes a Victorian mansion. Spooky!](media/image/evaluating-expressions/lightning.png)

A decrepit Victorian mansion is optional, but adds to the ambiance.

There are all manner of ways that language implementations make a computer do what the user’s source code commands. They can compile it to machine code, translate it to another high-level language, or reduce it to some bytecode format for a virtual machine to run. For our first interpreter, though, we are going to take the simplest, shortest path and execute the syntax tree itself.

Right now, our parser only supports expressions. So, to “execute” code, we will evaluate an expression and produce a value. For each kind of expression syntax we can parse—literal, operator, etc.—we need a corresponding chunk of code that knows how to evaluate that tree and produce a result. That raises two questions:

1.  What kinds of values do we produce?

2.  How do we organize those chunks of code?

Taking them on one at a time . . . 

## 7.1 Representing Values

In Lox, values are created by literals, computed by expressions, and stored in variables. The user sees these as *Lox* objects, but they are implemented in the underlying language our interpreter is written in. That means bridging the lands of Lox’s dynamic typing and Java’s static types. A variable in Lox can store a value of any (Lox) type, and can even store values of different types at different points in time. What Java type might we use to represent that?

Here, I’m using “value” and “object” pretty much interchangeably.

Later in the C interpreter we’ll make a slight distinction between them, but that’s mostly to have unique terms for two different corners of the implementation—in-place versus heap-allocated data. From the user’s perspective, the terms are synonymous.

Given a Java variable with that static type, we must also be able to determine which kind of value it holds at runtime. When the interpreter executes a `+` operator, it needs to tell if it is adding two numbers or concatenating two strings. Is there a Java type that can hold numbers, strings, Booleans, and more? Is there one that can tell us what its runtime type is? There is! Good old java.lang.Object.

In places in the interpreter where we need to store a Lox value, we can use Object as the type. Java has boxed versions of its primitive types that all subclass Object, so we can use those for Lox’s built-in types:

|               |                     |
|---------------|---------------------|
| Lox type      | Java representation |
| Any Lox value | Object              |
| `nil`         | `null`              |
| Boolean       | Boolean             |
| number        | Double              |
| string        | String              |

Given a value of static type Object, we can determine if the runtime value is a number or a string or whatever using Java’s built-in `instanceof` operator. In other words, the JVM’s own object representation conveniently gives us everything we need to implement Lox’s built-in types. We’ll have to do a little more work later when we add Lox’s notions of functions, classes, and instances, but Object and the boxed primitive classes are sufficient for the types we need right now.

Another thing we need to do with values is manage their memory, and Java does that too. A handy object representation and a really nice garbage collector are the main reasons we’re writing our first interpreter in Java.

## 7.2 Evaluating Expressions

Next, we need blobs of code to implement the evaluation logic for each kind of expression we can parse. We could stuff that code into the syntax tree classes in something like an `interpret()` method. In effect, we could tell each syntax tree node, “Interpret thyself”. This is the Gang of Four’s [Interpreter design pattern](https://en.wikipedia.org/wiki/Interpreter_pattern). It’s a neat pattern, but like I mentioned earlier, it gets messy if we jam all sorts of logic into the tree classes.

Instead, we’re going to reuse our groovy Visitor pattern. In the previous chapter, we created an AstPrinter class. It took in a syntax tree and recursively traversed it, building up a string which it ultimately returned. That’s almost exactly what a real interpreter does, except instead of concatenating strings, it computes values.

We start with a new class.

```
package com.craftinginterpreters.lox;

class Interpreter implements Expr.Visitor<Object> {
}
```

*lox/Interpreter.java*, create new file

The class declares that it’s a visitor. The return type of the visit methods will be Object, the root class that we use to refer to a Lox value in our Java code. To satisfy the Visitor interface, we need to define visit methods for each of the four expression tree classes our parser produces. We’ll start with the simplest . . . 

### 7.2.1 Evaluating literals

The leaves of an expression tree—the atomic bits of syntax that all other expressions are composed of—are literals. Literals are almost values already, but the distinction is important. A literal is a *bit of syntax* that produces a value. A literal always appears somewhere in the user’s source code. Lots of values are produced by computation and don’t exist anywhere in the code itself. Those aren’t literals. A literal comes from the parser’s domain. Values are an interpreter concept, part of the runtime’s world.

In the next chapter, when we implement variables, we’ll add identifier expressions, which are also leaf nodes.

So, much like we converted a literal *token* into a literal *syntax tree node* in the parser, now we convert the literal tree node into a runtime value. That turns out to be trivial.

      @Override
      public Object visitLiteralExpr(Expr.Literal expr) {
        return expr.value;
      }

*lox/Interpreter.java*, in class *Interpreter*

We eagerly produced the runtime value way back during scanning and stuffed it in the token. The parser took that value and stuck it in the literal tree node, so to evaluate a literal, we simply pull it back out.

### 7.2.2 Evaluating parentheses

The next simplest node to evaluate is grouping—the node you get as a result of using explicit parentheses in an expression.

      @Override
      public Object visitGroupingExpr(Expr.Grouping expr) {
        return evaluate(expr.expression);
      }

*lox/Interpreter.java*, in class *Interpreter*

A grouping node has a reference to an inner node for the expression contained inside the parentheses. To evaluate the grouping expression itself, we recursively evaluate that subexpression and return it.

We rely on this helper method which simply sends the expression back into the interpreter’s visitor implementation:

Some parsers don’t define tree nodes for parentheses. Instead, when parsing a parenthesized expression, they simply return the node for the inner expression. We do create a node for parentheses in Lox because we’ll need it later to correctly handle the left-hand sides of assignment expressions.

      private Object evaluate(Expr expr) {
        return expr.accept(this);
      }

*lox/Interpreter.java*, in class *Interpreter*

### 7.2.3 Evaluating unary expressions

Like grouping, unary expressions have a single subexpression that we must evaluate first. The difference is that the unary expression itself does a little work afterwards.

      @Override
      public Object visitUnaryExpr(Expr.Unary expr) {
        Object right = evaluate(expr.right);

        switch (expr.operator.type) {
          case MINUS:
            return -(double)right;
        }

        // Unreachable.
        return null;
      }

*lox/Interpreter.java*, add after *visitLiteralExpr*()

First, we evaluate the operand expression. Then we apply the unary operator itself to the result of that. There are two different unary expressions, identified by the type of the operator token.

Shown here is `-`, which negates the result of the subexpression. The subexpression must be a number. Since we don’t *statically* know that in Java, we cast it before performing the operation. This type cast happens at runtime when the `-` is evaluated. That’s the core of what makes a language dynamically typed right there.

You’re probably wondering what happens if the cast fails. Fear not, we’ll get into that soon.

You can start to see how evaluation recursively traverses the tree. We can’t evaluate the unary operator itself until after we evaluate its operand subexpression. That means our interpreter is doing a **post-order traversal**—each node evaluates its children before doing its own work.

The other unary operator is logical not.

```
    switch (expr.operator.type) {
```

```
      case BANG:
        return !isTruthy(right);
```

```
      case MINUS:
```

*lox/Interpreter.java*, in *visitUnaryExpr*()

The implementation is simple, but what is this “truthy” thing about? We need to make a little side trip to one of the great questions of Western philosophy: *What is truth?*

### 7.2.4 Truthiness and falsiness

OK, maybe we’re not going to really get into the universal question, but at least inside the world of Lox, we need to decide what happens when you use something other than `true` or `false` in a logic operation like `!` or any other place where a Boolean is expected.

We *could* just say it’s an error because we don’t roll with implicit conversions, but most dynamically typed languages aren’t that ascetic. Instead, they take the universe of values of all types and partition them into two sets, one of which they define to be “true”, or “truthful”, or (my favorite) “truthy”, and the rest which are “false” or “falsey”. This partitioning is somewhat arbitrary and gets weird in a few languages.

In JavaScript, strings are truthy, but empty strings are not. Arrays are truthy but empty arrays are . . . also truthy. The number `0` is falsey, but the *string* `"0"` is truthy.

In Python, empty strings are falsey like in JS, but other empty sequences are falsey too.

In PHP, both the number `0` and the string `"0"` are falsey. Most other non-empty strings are truthy.

Get all that?

Lox follows Ruby’s simple rule: `false` and `nil` are falsey, and everything else is truthy. We implement that like so:

      private boolean isTruthy(Object object) {
        if (object == null) return false;
        if (object instanceof Boolean) return (boolean)object;
        return true;
      }

*lox/Interpreter.java*, add after *visitUnaryExpr*()

### 7.2.5 Evaluating binary operators

On to the last expression tree class, binary operators. There’s a handful of them, and we’ll start with the arithmetic ones.

      @Override
      public Object visitBinaryExpr(Expr.Binary expr) {
        Object left = evaluate(expr.left);
        Object right = evaluate(expr.right);

        switch (expr.operator.type) {
          case MINUS:
            return (double)left - (double)right;
          case SLASH:
            return (double)left / (double)right;
          case STAR:
            return (double)left * (double)right;
        }

        // Unreachable.
        return null;
      }

*lox/Interpreter.java*, add after *evaluate*()

Did you notice we pinned down a subtle corner of the language semantics here? In a binary expression, we evaluate the operands in left-to-right order. If those operands have side effects, that choice is user visible, so this isn’t simply an implementation detail.

If we want our two interpreters to be consistent (hint: we do), we’ll need to make sure clox does the same thing.

I think you can figure out what’s going on here. The main difference from the unary negation operator is that we have two operands to evaluate.

I left out one arithmetic operator because it’s a little special.

```
    switch (expr.operator.type) {
      case MINUS:
        return (double)left - (double)right;
```

```
      case PLUS:
        if (left instanceof Double && right instanceof Double) {
          return (double)left + (double)right;
        }

        if (left instanceof String && right instanceof String) {
          return (String)left + (String)right;
        }

        break;
```

```
      case SLASH:
```

*lox/Interpreter.java*, in *visitBinaryExpr*()

The `+` operator can also be used to concatenate two strings. To handle that, we don’t just assume the operands are a certain type and *cast* them, we dynamically *check* the type and choose the appropriate operation. This is why we need our object representation to support `instanceof`.

We could have defined an operator specifically for string concatenation. That’s what Perl (`.`), Lua (`..`), Smalltalk (`,`), Haskell (`++`), and others do.

I thought it would make Lox a little more approachable to use the same syntax as Java, JavaScript, Python, and others. This means that the `+` operator is **overloaded** to support both adding numbers and concatenating strings. Even in languages that don’t use `+` for strings, they still often overload it for adding both integers and floating-point numbers.

Next up are the comparison operators.

```
    switch (expr.operator.type) {
```

```
      case GREATER:
        return (double)left > (double)right;
      case GREATER_EQUAL:
        return (double)left >= (double)right;
      case LESS:
        return (double)left < (double)right;
      case LESS_EQUAL:
        return (double)left <= (double)right;
```

```
      case MINUS:
```

*lox/Interpreter.java*, in *visitBinaryExpr*()

They are basically the same as arithmetic. The only difference is that where the arithmetic operators produce a value whose type is the same as the operands (numbers or strings), the comparison operators always produce a Boolean.

The last pair of operators are equality.

          case BANG_EQUAL: return !isEqual(left, right);
          case EQUAL_EQUAL: return isEqual(left, right);

*lox/Interpreter.java*, in *visitBinaryExpr*()

Unlike the comparison operators which require numbers, the equality operators support operands of any type, even mixed ones. You can’t ask Lox if 3 is *less* than `"three"`, but you can ask if it’s *equal* to it.

Spoiler alert: it’s not.

Like truthiness, the equality logic is hoisted out into a separate method.

      private boolean isEqual(Object a, Object b) {
        if (a == null && b == null) return true;
        if (a == null) return false;

        return a.equals(b);
      }

*lox/Interpreter.java*, add after *isTruthy*()

This is one of those corners where the details of how we represent Lox objects in terms of Java matter. We need to correctly implement *Lox’s* notion of equality, which may be different from Java’s.

Fortunately, the two are pretty similar. Lox doesn’t do implicit conversions in equality and Java does not either. We do have to handle `nil`/`null` specially so that we don’t throw a NullPointerException if we try to call `equals()` on `null`. Otherwise, we’re fine. Java’s `equals()` method on Boolean, Double, and String have the behavior we want for Lox.

What do you expect this to evaluate to:

    (0 / 0) == (0 / 0)

According to [IEEE 754](https://en.wikipedia.org/wiki/IEEE_754), which specifies the behavior of double-precision numbers, dividing a zero by zero gives you the special **NaN** (“not a number”) value. Strangely enough, NaN is *not* equal to itself.

In Java, the `==` operator on primitive doubles preserves that behavior, but the `equals()` method on the Double class does not. Lox uses the latter, so doesn’t follow IEEE. These kinds of subtle incompatibilities occupy a dismaying fraction of language implementers’ lives.

And that’s it! That’s all the code we need to correctly interpret a valid Lox expression. But what about an *invalid* one? In particular, what happens when a subexpression evaluates to an object of the wrong type for the operation being performed?

## 7.3 Runtime Errors

I was cavalier about jamming casts in whenever a subexpression produces an Object and the operator requires it to be a number or a string. Those casts can fail. Even though the user’s code is erroneous, if we want to make a usable language, we are responsible for handling that error gracefully.

We could simply not detect or report a type error at all. This is what C does if you cast a pointer to some type that doesn’t match the data that is actually being pointed to. C gains flexibility and speed by allowing that, but is also famously dangerous. Once you misinterpret bits in memory, all bets are off.

Few modern languages accept unsafe operations like that. Instead, most are **memory safe** and ensure—through a combination of static and runtime checks—that a program can never incorrectly interpret the value stored in a piece of memory.

It’s time for us to talk about **runtime errors**. I spilled a lot of ink in the previous chapters talking about error handling, but those were all *syntax* or *static* errors. Those are detected and reported before *any* code is executed. Runtime errors are failures that the language semantics demand we detect and report while the program is running (hence the name).

Right now, if an operand is the wrong type for the operation being performed, the Java cast will fail and the JVM will throw a ClassCastException. That unwinds the whole stack and exits the application, vomiting a Java stack trace onto the user. That’s probably not what we want. The fact that Lox is implemented in Java should be a detail hidden from the user. Instead, we want them to understand that a *Lox* runtime error occurred, and give them an error message relevant to our language and their program.

The Java behavior does have one thing going for it, though. It correctly stops executing any code when the error occurs. Let’s say the user enters some expression like:

```
2 * (3 / -"muffin")
```

You can’t negate a muffin, so we need to report a runtime error at that inner `-` expression. That in turn means we can’t evaluate the `/` expression since it has no meaningful right operand. Likewise for the `*`. So when a runtime error occurs deep in some expression, we need to escape all the way out.

I don’t know, man, *can* you negate a muffin?

![A muffin, negated.](media/image/evaluating-expressions/muffin.png)

We could print a runtime error and then abort the process and exit the application entirely. That has a certain melodramatic flair. Sort of the programming language interpreter equivalent of a mic drop.

Tempting as that is, we should probably do something a little less cataclysmic. While a runtime error needs to stop evaluating the *expression*, it shouldn’t kill the *interpreter*. If a user is running the REPL and has a typo in a line of code, they should still be able to keep the session going and enter more code after that.

### 7.3.1 Detecting runtime errors

Our tree-walk interpreter evaluates nested expressions using recursive method calls, and we need to unwind out of all of those. Throwing an exception in Java is a fine way to accomplish that. However, instead of using Java’s own cast failure, we’ll define a Lox-specific one so that we can handle it how we want.

Before we do the cast, we check the object’s type ourselves. So, for unary `-`, we add:

```
      case MINUS:
```

```
        checkNumberOperand(expr.operator, right);
```

```
        return -(double)right;
```

*lox/Interpreter.java*, in *visitUnaryExpr*()

The code to check the operand is:

      private void checkNumberOperand(Token operator, Object operand) {
        if (operand instanceof Double) return;
        throw new RuntimeError(operator, "Operand must be a number.");
      }

*lox/Interpreter.java*, add after *visitUnaryExpr*()

When the check fails, it throws one of these:

```
package com.craftinginterpreters.lox;

class RuntimeError extends RuntimeException {
  final Token token;

  RuntimeError(Token token, String message) {
    super(message);
    this.token = token;
  }
}
```

*lox/RuntimeError.java*, create new file

Unlike the Java cast exception, our class tracks the token that identifies where in the user’s code the runtime error came from. As with static errors, this helps the user know where to fix their code.

I admit the name “RuntimeError” is confusing since Java defines a RuntimeException class. An annoying thing about building interpreters is your names often collide with ones already taken by the implementation language. Just wait until we support Lox classes.

We need similar checking for the binary operators. Since I promised you every single line of code needed to implement the interpreters, I’ll run through them all.

Greater than:

```
      case GREATER:
```

```
        checkNumberOperands(expr.operator, left, right);
```

```
        return (double)left > (double)right;
```

*lox/Interpreter.java*, in *visitBinaryExpr*()

Greater than or equal to:

```
      case GREATER_EQUAL:
```

```
        checkNumberOperands(expr.operator, left, right);
```

```
        return (double)left >= (double)right;
```

*lox/Interpreter.java*, in *visitBinaryExpr*()

Less than:

```
      case LESS:
```

```
        checkNumberOperands(expr.operator, left, right);
```

```
        return (double)left < (double)right;
```

*lox/Interpreter.java*, in *visitBinaryExpr*()

Less than or equal to:

```
      case LESS_EQUAL:
```

```
        checkNumberOperands(expr.operator, left, right);
```

```
        return (double)left <= (double)right;
```

*lox/Interpreter.java*, in *visitBinaryExpr*()

Subtraction:

```
      case MINUS:
```

```
        checkNumberOperands(expr.operator, left, right);
```

```
        return (double)left - (double)right;
```

*lox/Interpreter.java*, in *visitBinaryExpr*()

Division:

```
      case SLASH:
```

```
        checkNumberOperands(expr.operator, left, right);
```

```
        return (double)left / (double)right;
```

*lox/Interpreter.java*, in *visitBinaryExpr*()

Multiplication:

```
      case STAR:
```

```
        checkNumberOperands(expr.operator, left, right);
```

```
        return (double)left * (double)right;
```

*lox/Interpreter.java*, in *visitBinaryExpr*()

All of those rely on this validator, which is virtually the same as the unary one:

      private void checkNumberOperands(Token operator,
                                       Object left, Object right) {
        if (left instanceof Double && right instanceof Double) return;
       
        throw new RuntimeError(operator, "Operands must be numbers.");
      }

*lox/Interpreter.java*, add after *checkNumberOperand*()

Another subtle semantic choice: We evaluate *both* operands before checking the type of *either*. Imagine we have a function `say()` that prints its argument then returns it. Using that, we write:

```
say("left") - say("right");
```

Our interpreter prints “left” and “right” before reporting the runtime error. We could have instead specified that the left operand is checked before even evaluating the right.

The last remaining operator, again the odd one out, is addition. Since `+` is overloaded for numbers and strings, it already has code to check the types. All we need to do is fail if neither of the two success cases match.

```
          return (String)left + (String)right;
        }
```

```
        throw new RuntimeError(expr.operator,
            "Operands must be two numbers or two strings.");
```

```
      case SLASH:
```

*lox/Interpreter.java*, in *visitBinaryExpr*(), replace 1 line

That gets us detecting runtime errors deep in the innards of the evaluator. The errors are getting thrown. The next step is to write the code that catches them. For that, we need to wire up the Interpreter class into the main Lox class that drives it.

## 7.4 Hooking Up the Interpreter

The visit methods are sort of the guts of the Interpreter class, where the real work happens. We need to wrap a skin around them to interface with the rest of the program. The Interpreter’s public API is simply one method.

      void interpret(Expr expression) {
        try {
          Object value = evaluate(expression);
          System.out.println(stringify(value));
        } catch (RuntimeError error) {
          Lox.runtimeError(error);
        }
      }

*lox/Interpreter.java*, in class *Interpreter*

This takes in a syntax tree for an expression and evaluates it. If that succeeds, `evaluate()` returns an object for the result value. `interpret()` converts that to a string and shows it to the user. To convert a Lox value to a string, we rely on:

      private String stringify(Object object) {
        if (object == null) return "nil";

        if (object instanceof Double) {
          String text = object.toString();
          if (text.endsWith(".0")) {
            text = text.substring(0, text.length() - 2);
          }
          return text;
        }

        return object.toString();
      }

*lox/Interpreter.java*, add after *isEqual*()

This is another of those pieces of code like `isTruthy()` that crosses the membrane between the user’s view of Lox objects and their internal representation in Java.

It’s pretty straightforward. Since Lox was designed to be familiar to someone coming from Java, things like Booleans look the same in both languages. The two edge cases are `nil`, which we represent using Java’s `null`, and numbers.

Lox uses double-precision numbers even for integer values. In that case, they should print without a decimal point. Since Java has both floating point and integer types, it wants you to know which one you’re using. It tells you by adding an explicit `.0` to integer-valued doubles. We don’t care about that, so we hack it off the end.

Yet again, we take care of this edge case with numbers to ensure that jlox and clox work the same. Handling weird corners of the language like this will drive you crazy but is an important part of the job.

Users rely on these details—either deliberately or inadvertently—and if the implementations aren’t consistent, their program will break when they run it on different interpreters.

### 7.4.1 Reporting runtime errors

If a runtime error is thrown while evaluating the expression, `interpret()` catches it. This lets us report the error to the user and then gracefully continue. All of our existing error reporting code lives in the Lox class, so we put this method there too:

      static void runtimeError(RuntimeError error) {
        System.err.println(error.getMessage() +
            "\n[line " + error.token.line + "]");
        hadRuntimeError = true;
      }

*lox/Lox.java*, add after *error*()

We use the token associated with the RuntimeError to tell the user what line of code was executing when the error occurred. Even better would be to give the user an entire call stack to show how they *got* to be executing that code. But we don’t have function calls yet, so I guess we don’t have to worry about it.

After showing the error, `runtimeError()` sets this field:

```
  static boolean hadError = false;
```

```
  static boolean hadRuntimeError = false;
```

```
  public static void main(String[] args) throws IOException {
```

*lox/Lox.java*, in class *Lox*

That field plays a small but important role.

```
    run(new String(bytes, Charset.defaultCharset()));

    // Indicate an error in the exit code.
    if (hadError) System.exit(65);
```

```
    if (hadRuntimeError) System.exit(70);
```

```
  }
```

*lox/Lox.java*, in *runFile*()

If the user is running a Lox script from a file and a runtime error occurs, we set an exit code when the process quits to let the calling process know. Not everyone cares about shell etiquette, but we do.

If the user is running the REPL, we don’t care about tracking runtime errors. After they are reported, we simply loop around and let them input new code and keep going.

### 7.4.2 Running the interpreter

Now that we have an interpreter, the Lox class can start using it.

```
public class Lox {
```

```
  private static final Interpreter interpreter = new Interpreter();
```

```
  static boolean hadError = false;
```

*lox/Lox.java*, in class *Lox*

We make the field static so that successive calls to `run()` inside a REPL session reuse the same interpreter. That doesn’t make a difference now, but it will later when the interpreter stores global variables. Those variables should persist throughout the REPL session.

Finally, we remove the line of temporary code from the last chapter for printing the syntax tree and replace it with this:

```
    // Stop if there was a syntax error.
    if (hadError) return;
```

```
    interpreter.interpret(expression);
```

```
  }
```

*lox/Lox.java*, in *run*(), replace 1 line

We have an entire language pipeline now: scanning, parsing, and execution. Congratulations, you now have your very own arithmetic calculator.

As you can see, the interpreter is pretty bare bones. But the Interpreter class and the Visitor pattern we’ve set up today form the skeleton that later chapters will stuff full of interesting guts—variables, functions, etc. Right now, the interpreter doesn’t do very much, but it’s alive!

![A skeleton waving hello.](media/image/evaluating-expressions/skeleton.png)

## Challenges

1.  Allowing comparisons on types other than numbers could be useful. The operators might have a reasonable interpretation for strings. Even comparisons among mixed types, like `3 < "pancake"` could be handy to enable things like ordered collections of heterogeneous types. Or it could simply lead to bugs and confusion.

    Would you extend Lox to support comparing other types? If so, which pairs of types do you allow and how do you define their ordering? Justify your choices and compare them to other languages.

2.  Many languages define `+` such that if *either* operand is a string, the other is converted to a string and the results are then concatenated. For example, `"scone" + 4` would yield `scone4`. Extend the code in `visitBinaryExpr()` to support that.

3.  What happens right now if you divide a number by zero? What do you think should happen? Justify your choice. How do other languages you know handle division by zero, and why do they make the choices they do?

    Change the implementation in `visitBinaryExpr()` to detect and report a runtime error for this case.

## Design Note: Static and Dynamic Typing

Some languages, like Java, are statically typed which means type errors are detected and reported at compile time before any code is run. Others, like Lox, are dynamically typed and defer checking for type errors until runtime right before an operation is attempted. We tend to consider this a black-and-white choice, but there is actually a continuum between them.

It turns out even most statically typed languages do *some* type checks at runtime. The type system checks most type rules statically, but inserts runtime checks in the generated code for other operations.

For example, in Java, the *static* type system assumes a cast expression will always safely succeed. After you cast some value, you can statically treat it as the destination type and not get any compile errors. But downcasts can fail, obviously. The only reason the static checker can presume that casts always succeed without violating the language’s soundness guarantees, is because the cast is checked *at runtime* and throws an exception on failure.

A more subtle example is [covariant arrays](https://en.wikipedia.org/wiki/Covariance_and_contravariance_(computer_science)#Covariant_arrays_in_Java_and_C.23) in Java and C#. The static subtyping rules for arrays allow operations that are not sound. Consider:

```
Object[] stuff = new Integer[1];
stuff[0] = "not an int!";
```

This code compiles without any errors. The first line upcasts the Integer array and stores it in a variable of type Object array. The second line stores a string in one of its cells. The Object array type statically allows that—strings *are* Objects—but the actual Integer array that `stuff` refers to at runtime should never have a string in it! To avoid that catastrophe, when you store a value in an array, the JVM does a *runtime* check to make sure it’s an allowed type. If not, it throws an ArrayStoreException.

Java could have avoided the need to check this at runtime by disallowing the cast on the first line. It could make arrays *invariant* such that an array of Integers is *not* an array of Objects. That’s statically sound, but it prohibits common and safe patterns of code that only read from arrays. Covariance is safe if you never *write* to the array. Those patterns were particularly important for usability in Java 1.0 before it supported generics. James Gosling and the other Java designers traded off a little static safety and performance—those array store checks take time—in return for some flexibility.

There are few modern statically typed languages that don’t make that trade-off *somewhere*. Even Haskell will let you run code with non-exhaustive matches. If you find yourself designing a statically typed language, keep in mind that you can sometimes give users more flexibility without sacrificing *too* many of the benefits of static safety by deferring some type checks until runtime.

On the other hand, a key reason users choose statically typed languages is because of the confidence the language gives them that certain kinds of errors can *never* occur when their program is run. Defer too many type checks until runtime, and you erode that confidence.