#### Chapter A2.

# Appendix II

For your edification, here is the code produced by the little script we built to automate generating the syntax tree classes for jlox.

## A2.1 Expressions

Expressions are the first syntax tree nodes we see, introduced in “Representing Code”. The main Expr class defines the visitor interface used to dispatch against the specific expression types, and contains the other expression subclasses as nested classes.

```
package com.craftinginterpreters.lox;

import java.util.List;

abstract class Expr {
  interface Visitor<R> {
    R visitAssignExpr(Assign expr);
    R visitBinaryExpr(Binary expr);
    R visitCallExpr(Call expr);
    R visitGetExpr(Get expr);
    R visitGroupingExpr(Grouping expr);
    R visitLiteralExpr(Literal expr);
    R visitLogicalExpr(Logical expr);
    R visitSetExpr(Set expr);
    R visitSuperExpr(Super expr);
    R visitThisExpr(This expr);
    R visitUnaryExpr(Unary expr);
    R visitVariableExpr(Variable expr);
  }

  // Nested Expr classes here...

  abstract <R> R accept(Visitor<R> visitor);
}
```

*lox/Expr.java*, create new file

### A2.1.1 Assign expression

Variable assignment is introduced in “Statements and State”.

      static class Assign extends Expr {
        Assign(Token name, Expr value) {
          this.value = value;
        }

          return visitor.visitAssignExpr(this);
        }

        final Expr value;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.2 Binary expression

Binary operators are introduced in “Representing Code”.

      static class Binary extends Expr {
        Binary(Expr left, Token operator, Expr right) {
          this.left = left;
          this.operator = operator;
          this.right = right;
        }

          return visitor.visitBinaryExpr(this);
        }

        final Expr left;
        final Token operator;
        final Expr right;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.3 Call expression

Function call expressions are introduced in “Functions”.

      static class Call extends Expr {
        Call(Expr callee, Token paren, List<Expr> arguments) {
          this.callee = callee;
          this.paren = paren;
          this.arguments = arguments;
        }

          return visitor.visitCallExpr(this);
        }

        final Expr callee;
        final Token paren;
        final List<Expr> arguments;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.4 Get expression

Property access, or “get” expressions are introduced in “Classes”.

      static class Get extends Expr {
        Get(Expr object, Token name) {
          this.object = object;
        }

          return visitor.visitGetExpr(this);
        }

        final Expr object;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.5 Grouping expression

Using parentheses to group expressions is introduced in “Representing Code”.

      static class Grouping extends Expr {
        Grouping(Expr expression) {
          this.expression = expression;
        }

          return visitor.visitGroupingExpr(this);
        }

        final Expr expression;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.6 Literal expression

Literal value expressions are introduced in “Representing Code”.

      static class Literal extends Expr {
        Literal(Object value) {
          this.value = value;
        }

          return visitor.visitLiteralExpr(this);
        }

        final Object value;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.7 Logical expression

The logical `and` and `or` operators are introduced in “Control Flow”.

      static class Logical extends Expr {
        Logical(Expr left, Token operator, Expr right) {
          this.left = left;
          this.operator = operator;
          this.right = right;
        }

          return visitor.visitLogicalExpr(this);
        }

        final Expr left;
        final Token operator;
        final Expr right;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.8 Set expression

Property assignment, or “set” expressions are introduced in “Classes”.

      static class Set extends Expr {
        Set(Expr object, Token name, Expr value) {
          this.object = object;
          this.value = value;
        }

          return visitor.visitSetExpr(this);
        }

        final Expr object;
        final Expr value;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.9 Super expression

The `super` expression is introduced in “Inheritance”.

      static class Super extends Expr {
        Super(Token keyword, Token method) {
          this.keyword = keyword;
          this.method = method;
        }

          return visitor.visitSuperExpr(this);
        }

        final Token keyword;
        final Token method;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.10 This expression

The `this` expression is introduced in “Classes”.

      static class This extends Expr {
        This(Token keyword) {
          this.keyword = keyword;
        }

          return visitor.visitThisExpr(this);
        }

        final Token keyword;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.11 Unary expression

Unary operators are introduced in “Representing Code”.

      static class Unary extends Expr {
        Unary(Token operator, Expr right) {
          this.operator = operator;
          this.right = right;
        }

          return visitor.visitUnaryExpr(this);
        }

        final Token operator;
        final Expr right;
      }

*lox/Expr.java*, nest inside class *Expr*

### A2.1.12 Variable expression

Variable access expressions are introduced in “Statements and State”.

      static class Variable extends Expr {
        Variable(Token name) {
        }

          return visitor.visitVariableExpr(this);
        }

      }

*lox/Expr.java*, nest inside class *Expr*

## A2.2 Statements

Statements form a second hierarchy of syntax tree nodes independent of expressions. We add the first couple of them in “Statements and State”.

```
package com.craftinginterpreters.lox;

import java.util.List;

abstract class Stmt {
  interface Visitor<R> {
    R visitBlockStmt(Block stmt);
    R visitClassStmt(Class stmt);
    R visitExpressionStmt(Expression stmt);
    R visitFunctionStmt(Function stmt);
    R visitIfStmt(If stmt);
    R visitPrintStmt(Print stmt);
    R visitReturnStmt(Return stmt);
    R visitVarStmt(Var stmt);
    R visitWhileStmt(While stmt);
  }

  // Nested Stmt classes here...

  abstract <R> R accept(Visitor<R> visitor);
}
```

*lox/Stmt.java*, create new file

### A2.2.1 Block statement

The curly-braced block statement that defines a local scope is introduced in “Statements and State”.

      static class Block extends Stmt {
        Block(List<Stmt> statements) {
          this.statements = statements;
        }

          return visitor.visitBlockStmt(this);
        }

        final List<Stmt> statements;
      }

*lox/Stmt.java*, nest inside class *Stmt*

### A2.2.2 Class statement

Class declarations are introduced in, unsurprisingly, “Classes”.

      static class Class extends Stmt {
        Class(Token name,
              Expr.Variable superclass,
              List<Stmt.Function> methods) {
          this.superclass = superclass;
          this.methods = methods;
        }

          return visitor.visitClassStmt(this);
        }

        final Expr.Variable superclass;
        final List<Stmt.Function> methods;
      }

*lox/Stmt.java*, nest inside class *Stmt*

### A2.2.3 Expression statement

The expression statement is introduced in “Statements and State”.

      static class Expression extends Stmt {
        Expression(Expr expression) {
          this.expression = expression;
        }

          return visitor.visitExpressionStmt(this);
        }

        final Expr expression;
      }

*lox/Stmt.java*, nest inside class *Stmt*

### A2.2.4 Function statement

Function declarations are introduced in, you guessed it, “Functions”.

      static class Function extends Stmt {
        Function(Token name, List<Token> params, List<Stmt> body) {
          this.params = params;
          this.body = body;
        }

          return visitor.visitFunctionStmt(this);
        }

        final List<Token> params;
        final List<Stmt> body;
      }

*lox/Stmt.java*, nest inside class *Stmt*

### A2.2.5 If statement

The `if` statement is introduced in “Control Flow”.

      static class If extends Stmt {
        If(Expr condition, Stmt thenBranch, Stmt elseBranch) {
          this.condition = condition;
          this.thenBranch = thenBranch;
          this.elseBranch = elseBranch;
        }

          return visitor.visitIfStmt(this);
        }

        final Expr condition;
        final Stmt thenBranch;
        final Stmt elseBranch;
      }

*lox/Stmt.java*, nest inside class *Stmt*

### A2.2.6 Print statement

The `print` statement is introduced in “Statements and State”.

      static class Print extends Stmt {
        Print(Expr expression) {
          this.expression = expression;
        }

          return visitor.visitPrintStmt(this);
        }

        final Expr expression;
      }

*lox/Stmt.java*, nest inside class *Stmt*

### A2.2.7 Return statement

You need a function to return from, so `return` statements are introduced in “Functions”.

      static class Return extends Stmt {
        Return(Token keyword, Expr value) {
          this.keyword = keyword;
          this.value = value;
        }

          return visitor.visitReturnStmt(this);
        }

        final Token keyword;
        final Expr value;
      }

*lox/Stmt.java*, nest inside class *Stmt*

### A2.2.8 Variable statement

Variable declarations are introduced in “Statements and State”.

      static class Var extends Stmt {
        Var(Token name, Expr initializer) {
          this.initializer = initializer;
        }

          return visitor.visitVarStmt(this);
        }

        final Expr initializer;
      }

*lox/Stmt.java*, nest inside class *Stmt*

### A2.2.9 While statement

The `while` statement is introduced in “Control Flow”.

      static class While extends Stmt {
        While(Expr condition, Stmt body) {
          this.condition = condition;
          this.body = body;
        }

          return visitor.visitWhileStmt(this);
        }

        final Expr condition;
        final Stmt body;
      }

*lox/Stmt.java*, nest inside class *Stmt*