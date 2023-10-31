# BigNumber
A Swift library that utilizes multiple-precision to provide several convenience classes and functions for solving number theory and related problems.  Some example classes can represent polynomials and continued fractions.  Some example functions include Prime Factorization Enumeration, Continued Fraction Enumeration, Solving Diophatine Equations, and Solving Quadratic Congruences.

![Euler Project Badge](https://projecteuler.net/profile/tflan.png)

I wrote this library to help solve math problems designed with computer aid in mind from [Project Euler](https://projecteuler.net/).  They release a new math problem approximately every week.  Far so I've solved over 150 problems, which seemed like a lot more a few years ;).  But why use Swift instead of C or C++, most problems are designed to be temporally protected from brute force methods.  Simplifying the problem is almost always required, so the overhead of Swift is usually not a limiting factor.  Choosing Swift was a matter of personal preference. It's an expressive language that I knew already and have worked with.  I usually prototype a solution in a Playground (REPL) for quick development cycles.  And if I need a performance boost, I wrote a script that will compile a Playground into an executable. 

## Features
* Provides multiple-precision integer and floating-point Swift types
  * Wraps GMP (GNU Multiple Precision) and GNU MPFR (Multiple Precision Floating-point)
  * Conforms to Swift SignedInteger and SignedNumeric protocols
* Provides Rational type conforming to SignedNumeric Protocol 
* Generic Polynomial class that conforms to the SignedNumeric Protocol
  * Add, subtract, multiply polynomials with ease
* Generic Bézier Curve class that conforms to the SignedNumeric Protocol
  * Add, subtract, multiply Bézier curve if you want
* Basic Geometry Representation with multiple precision
  * Lines, Triangles, and Circles  
* Utility Functions
  * Euler's Totient function 
  * Quadratic Congruence Solver
  * Pell's Equation Solver
  * System of Linear Congruences Solver using Chinese Remainder Theorem
  * Root solver using the Bisection Method
  * Farey sequence generator
  * Lagrange Polynomial generator
* Enumerators, loop through sequences using a closure
  * Prime factors enumerator
  * Partitions enumerator
  * Divisors enumerator 

## Screenshots
![pells_equation_screenshot](https://github.com/TFL4N/BigNumber/assets/1775614/da225f9e-8299-4b28-bc2c-947ba9b887f0)
![diophatine_screenshot](https://github.com/TFL4N/BigNumber/assets/1775614/67eb8663-5bd5-4c1f-a1e3-aa186c9c61d6)
![fraction_convergent_screenshot](https://github.com/TFL4N/BigNumber/assets/1775614/cd5dc6cf-4f2c-4427-90fd-0b6a87ae3aa0)
![quadratic_congruence_screenshot](https://github.com/TFL4N/BigNumber/assets/1775614/2d966ca5-04cb-4fd0-be80-7c26b092d6bf)


# Issues
