//
//  NumberTheory.swift
//  BigNumber
//
//  Created by Spizzace on 3/15/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation
import GMP


/**
 Finds the root of a function in the interval (a, b).  It does so iteratively, by halving the interval, and convergenting on the root.
 
 - Precondition: F(a) and F(b) must have opposite signs, i.e. greater than and less than zero
 - Parameters:
    - a: The initial value for a in F(a)
    - b: The initial value for b in F(b)
    - f: The function for which the root is being found
    - maxIterations: The maximum number of iterations before the routine gives up and returns null
    - tolerance: The maximum size of the interval for an acceptable answers
 - Returns: The root, if it exists in the interval (a,b)
 */
public func findRootBisection(a a_0: BigFloat, b b_0: BigFloat, f: ((BigFloat)->BigFloat), maxIterations: Int = 100000, tolerance: BigFloat = 0.00001) -> BigFloat? {
    var a: BigFloat = BigFloat(a_0)
    var b: BigFloat = BigFloat(b_0)
    var c: BigFloat = 0
    
    let f_a_sign = f(a) > 0
    var f_c: BigFloat = 0
    
    var n = 0
    repeat {
        c = (a + b) / 2
        
        f_c = f(c)
        if f_c == 0.0 || (b - a) / 2 < tolerance {
            return c
        }
        
        if (f_c > 0) == f_a_sign {
            a = c
        } else {
            b = c
        }
        
        // loop
        n += 1
    } while n < maxIterations
    
    return nil
}

public func divisors(_ n: Int, includeN: Bool = false, handler: ((inout Bool, Int)->Void)) {
    var div = 1
    var upper_bound = n
    var stop = false
    
    handler(&stop,1)
    
    while div < upper_bound - 1 && !stop {
        div += 1
        
        if n % div == 0 {
            handler(&stop, div)
            upper_bound = n / div
            
            if upper_bound != div && !stop {
                handler(&stop,upper_bound)
            }
        }
    }
    
    if includeN {
        handler(&stop,n)
    }
}

public func divisors(_ n: Int, sorted: Bool = false, includeSelf: Bool = false) -> [Int] {
    var output: [Int] = []
    
    divisors(n) { (_, div) in
        output.append(div)
    }
    
    
    if includeSelf {
        output.append(n)
    }
    
    if sorted {
        output.sort()
    }
    return output
}

public func binomialCoefficients(n: UInt, k: UInt) -> BigInt {
    let result = BigInt()
    
    __gmpz_bin_uiui(&result.integer, n, k)
    
    return result
}

// https://en.wikipedia.org/wiki/Lagrange_polynomial
public func lagrangeBasisPolynomial(x_values: [Int], j: Array<Int>.Index) -> Polynomial {
    var numerator: Polynomial = 1
    var denominator: Int = 1
    let x_j = x_values[j]
    
    for (i, el) in x_values.enumerated() {
        if i == j {
            continue
        }
        
        numerator *= [-el,1]
        denominator *= x_j - el
    }
    
    return numerator / denominator
}

public func lagrangeBasisPolynomial(count: Int, j: Array<Int>.Index) -> Polynomial {
    var numerator: Polynomial = 1
    var denominator: Int = 1
    let x_j = j + 1
    
    for x in 1...count {
        if x == x_j {
            continue
        }
        
        numerator *= [-x,1]
        denominator *= x_j - x
    }
    
    return numerator / denominator
}

public func lagrangePolynomial(y_values: [Int]) -> Polynomial {
    let count = y_values.count
    var sum: Polynomial = 0
    
    
    for (j, el) in y_values.enumerated() {
        sum += el * lagrangeBasisPolynomial(count: count, j: j)
    }
    
    return sum
}

/**
 Euler's Totient function is the number of relatively prime numbers less than or equal to *N*.  It other words, the number of integers *k* in the range 1 ≤ *k* ≤ *N*. It uses the formula:
    ````
    φ(n^k) = n^(k-1) * φ(n)
    ````
 The totient is a multiplicative function, i.e.
    ````
    φ(mn) = φ(m)φ(n)
    ````
 
 - parameter n: The number to totient
 - returns: The number of relatively primes numbers less than or equal to n
 */
public func eulersTotient(_ n: BigInt) -> BigInt {
    var numerator = BigInt(n)
    var denominator: BigInt = 1
    for p in n.primeFactorsUnique() {
        numerator *= p - 1
        denominator *= p
    }
    
    return numerator / denominator
}

public typealias ContinuedFractionExpansion = (UInt, [UInt])

/**
 The square root of very positive squarefree integer can be expressed as continued fraction with a repeating period.
  [ProofWiki](https://proofwiki.org/wiki/Continued_Fraction_Expansion_of_Irrational_Square_Root/Example/13/Convergents)
 
 This function will accept square numbers, and simply return a tuple with the square root and an empty array, as expected.
 
 - Parameter n: A positive integer
 - Returns: A tuple with the whole root, and an array of the repeating period
 */
public func continuedFractionExpansionOfQuadraticSurd(_ n: UInt) -> ContinuedFractionExpansion {
    // check if perfect square
    let root = sqrt(Double(n))
    let sq_floor_n = floor(root)
    if root == sq_floor_n {
        return (UInt(root), [])
    }
    
    ///
    func findNextTerm(P: UInt, Q: UInt, a: UInt) -> (P: UInt, Q: UInt, a: UInt) {
        let Pr = a * Q - P
        let Qr = (n - Pr*Pr) / Q
        let ar = UInt(floor((sq_floor_n + Double(Pr)) / Double(Qr)))
        
        return (Pr, Qr, ar)
    }
    
    ////
    let a0 = UInt(sq_floor_n)
    var expansion = [a0]
    let first = findNextTerm(P: 0, Q: 1, a: a0 )
    var tuple = first
    repeat {
        expansion.append(tuple.a)
        tuple = findNextTerm(P: tuple.P, Q: tuple.Q, a: tuple.a)
    } while tuple != first
    
    return (expansion.removeFirst(), expansion)
}

/**
 This function calculations the Nth convergent of a Continued Fraction Expansion.
 
 - Parameters:
    - n: Zero indexed Nth convergent to be found
    - continuedFraction: The ContinuedFractionExpansion describing the convergence
 - Returns: A Rational of the Nth convergent
 */
public func getConvergent(n: UInt, continuedFraction expansion: ContinuedFractionExpansion ) -> Rational {
    if n == 0 || expansion.1.isEmpty {
        return Rational(expansion.0)
    }
    
    let period = expansion.1.count
    var depth = Int(n) - 1
    var num = Rational(expansion.1[depth % period])
    while depth > 0 {
        depth -= 1
        
        num = Rational(expansion.1[depth % period]) + num.inverse()
    }
    
    return expansion.0 + num.inverse()
}

/**
 This function enumerates the convergents of a continued fraction starting from the 0th convergent to the Nth.  It keep returning the N+1 convergent until false is set to the first parameter of the handler closure
 
 - Precondition: The continued fraction's expansion period must be nonzero
 - Parameter handler: A closure of the form, (Stop, Convergent, Depth)
 */
public func enumerateConvergents(continuedFraction: ContinuedFractionExpansion, handler: ((inout Bool,Rational,Int)->Void)) {
    let expanse = continuedFraction.1
    let period = expanse.count
    var stop = false
    
    var depth: Int = 0
    var p: UInt = continuedFraction.0
    var p_1: UInt = p
    var p_2: UInt = 0
    
    var q: UInt = 1
    var q_1: UInt = q
    var q_2: UInt = 0
    
    
    // 0
    handler(&stop,Rational(p,q),depth)
    if stop {
        return
    }
    
    // 1
    depth = 1
    q = expanse[1%period]
    p = p*q + 1
    
    handler(&stop,Rational(p,q),depth)
    
    while !stop {
        depth += 1
        
        p_2 = p_1
        q_2 = q_1
        
        p_1 = p
        q_1 = q
        
        let a_k = expanse[(depth-1)%period]
        p = a_k*p_1 + p_2
        q = a_k*q_1 + q_2
        
        //        print("--------")
        //        print("k: ", depth)
        //        print("a_k: ", a_k)
        //        print("p: ", p, " : ", p_1, " : ", p_2)
        //        print("q: ", q, " : ", q_1, " : ", q_2)
        //        print(Rational(p,q))
        //        print("--------")
        
        handler(&stop,Rational(p,q),depth)
    }
}

/**
 This function finds the smallest of solution of Pell's equation of the form:
    ````
    x^2 - Dy^2 = 1
    ````
 It does so by finding the continue fraction expansion of the quadratic surd *√N*.  Then iteratively tries to find the first integer solution.
 
 Interestingly enough, Fermat was the first to extensively study this equation. And Euler erroneously attributed it to Pell
 
[Wikipedia - The smallest solution](https://en.wikipedia.org/wiki/Pell%27s_equation#The_smallest_solution_of_Pell_equations)
[ProofWiki - Example](https://proofwiki.org/wiki/Pell%27s_Equation/Examples/13)
[MathWord - Pell's Equation](http://mathworld.wolfram.com/PellEquation.html)

 - Precondition: D must be squarefree
 
 - Parameter D: A squarefree positive integer
 - Returns: A tuple of the smallest solution (x,y)
 */
public func findSmallestSolutionOfPellsEquation(D: UInt) -> (x: BigInt, y: BigInt) {
    let (root, expansion) = continuedFractionExpansionOfQuadraticSurd(D)
    
    var a0 = BigInt(root)
    var p0 = BigInt(root)
    var q0 = BigInt(1)
    
    var a1 = BigInt(expansion[0])
    var p1 = BigInt(a0 * a1 + 1)
    var q1 = BigInt(a1)
    
    let r = expansion.count
    if (r == 1 || r == 2) && p1*p1 - D*q1*q1 == 1 {
        return (p1, q1)
    }
    
    var n = 3
    var stop = false
    while !stop {
        let an = BigInt(expansion[(n - 2) % expansion.count])
        let pn = an * p1 + p0
        let qn = an * q1 + q0
        
        a0 = a1
        p0 = p1
        q0 = q1
        
        a1 = an
        p1 = pn
        q1 = qn
        
        if n % r == 0 {
            stop = p1*p1 - D*q1*q1 == 1
        }
        
        // loop condition
        n += 1
    }
    
    return (p1, q1)
}

// n! / r!(n-r)!
public func combinations(from n: UInt, choose r: UInt) -> BigInt {
    if n == 0 {
        return 0
    } else if r == 1 {
        return BigInt(n)
    }
    
    let n_fact = BigInt.factorial(n)
    let r_fact = BigInt.factorial(r)
    let nr_fact = BigInt.factorial(n-r)
    
    return n_fact / (r_fact * nr_fact)
}

public func numberOfPrimes(min: UInt, max: UInt) -> UInt {
    let num = BigInt(min)
    var count: UInt = 0
    repeat {
        if num.isPrime() != .notPrime {
            count += 1
        }
        
        num.moveToNextPrime()
    } while num <= max
    
    return count
}
