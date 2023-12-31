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
 The Farey sequence of order *n* is the sequence of reduced fractions between 1 and 0, where the denominator is less than other equal to *n*.
 ````
 F[5] = [(0, 1), (1, 5), (1, 4), (1, 3), (2, 5), (1, 2), (3, 5), (2, 3), (3, 4), (4, 5), (1, 1)]
 ````
 
 References:
 
 [Algorithm](https://en.wikipedia.org/wiki/Farey_sequence#Next_term)
 */
func createFareySequence(limit: Int, descendingOrder descending: Bool = false) -> [(Int,Int)] {
    var a: Int = 0
    var b: Int = 1
    var c: Int = 1
    var d: Int = limit
    
    if descending  {
        a = 1
        c = limit - 1
    }
    
    var output = [(a,b)]
    /*
     while (c <= n and not descending) or (a > 0 and descending):
     k = int((n + b) / d)
     a, b, c, d = c, d, (k*c-a), (k*d-b)
     print "%d/%d" % (a,b)
     */
    while (!descending && c <= limit) || (descending && a > 0) {
        let k = (limit + b) / d
        
        let new_c = k*c - a
        let new_d = k*d - b
        
        a = c
        b = d
        c = new_c
        d = new_d
        
        output.append((a,b))
    }
    
    
    return output
}

/**
 Returns a repunit of length n in base base
 */
public func createRepunit(_ n: UInt, base: Int = 10) -> BigInt {
    let base = BigInt(base)
    return ((base ** n) - 1) / (base - 1)
}

/**
 Finds the length of the smallest repunit of which *n* is a factor
 */
public func smallestRepunit(_ n: Int) -> Int {
    var count = 1
    var repunit = 1
    
    while repunit > 0 {
        repunit = ((repunit*10) + 1) % n
        count += 1
    }
    
    return count
}

/**
 This function finds *k* such that:
 ```
 base^k ≡ 1 (mod x)
 ```
 
 References:
 
 [Algorithm Implementation](https://www.geeksforgeeks.org/multiplicative-order/)
 
 - Parameters:
    - base: The base 
    - modulus:
 - Returns: The multiplicative order if it exists
 */
public func multiplicativeOrder(base: Int, modulus: Int) -> UInt? {
    var result = 1
    
    var k: UInt = 1
    while k < modulus {
        result = (result * base) % modulus
        
        if result == 1 {
            return k
        }
        
        // increment power
        k += 1
    }
    
    return nil
}



/**
 
 */
public func approximateIntegral(min: BigFloat, max: BigFloat, n: UInt, function: (BigFloat)->BigFloat) -> BigFloat {
    let intervals = n % 2 == 0 ? n : n + 1
    
    let delta_x = (max - min) / intervals
    let constant = delta_x / 3
    var x = min
    var y = function(x)
    var current_interval = 0
    var total: BigFloat = 0
    while current_interval < intervals {
        /// (dx/3) [f(x0) + 4f(x1) + f(x2)]
        /////////////
        
        /// f(x0)
        var interval_total = y
        
        x += delta_x
        current_interval += 1
        
        /// 4*f(x1)
        y = function(x)
        interval_total += 4 * y
        
        x += delta_x
        current_interval += 1
        
        /// f(x2)
        y = function(x)
        interval_total += y
        
        /// (dx/3) [f(x0) + 4f(x1) + f(x2)]
        total += constant * interval_total
    }
    
    return total
}

public func fastExponentation<T:Numeric>(_ n: T, _ exponent: UInt) -> T {
    if exponent == 0 {
        return 1
    }
    
    var exp = exponent
    var y: T = 1
    var x = n
    
    while exp > 1 {
        if exp % 2 == UInt(0) {
            x *= x
            exp /= 2
        } else {
            y *= x
            x *= x
            
            exp = (exp-1)/2
        }
    }
    
    return x*y
}

public func quadraticRoots(ax2 a: BigFloat, bx b: BigFloat, c: BigFloat) -> (BigFloat,BigFloat)? {
    var d = b*b - 4*a*c
    
    guard d >= 0 else {
        return nil
    }
    
    d = sqrt(d)
    
    let a_2 = 2*a
    let ans_1 = (-b) + d
    let ans_2 = (-b) - d
    
    return (ans_1/a_2, ans_2/a_2)
}

/**
 TODO: make sure roots are rounded toward zero
 */
public func quadraticRoots(ax2 a: BigInt, bx b: BigInt, c: BigInt) -> (BigInt,BigInt)? {
    var d = b*b - 4*a*c
    
    guard d >= 0 else {
        return nil
    }
    
    d = sqrt(d)
    
//    print("===== BigInt =====")
//    print("-b:", -b)
//    print("d:", d)
//    print((-b) + d, (-b) - d)
//    print("==================")
    
    let a_2 = 2*a
    let ans_1 = (-b) + d
    let ans_2 = b + d
    
    return (ans_1/a_2, -ans_2/a_2)
}

/**
 Finds the root of a function in the interval (a, b).  It does so iteratively, by halving the interval, and convergenting on the root.
 
 - Precondition:
    - `F(a)` and `F(b)` must have opposite signs, i.e. greater than and less than zero
    - `a < b`
 - Parameters:
    - a: The initial value for `a` in `F(a)`
    - b: The initial value for `b` in `F(b)`
    - f: The function for which the root is being found
    - maxIterations: The maximum number of iterations before the routine gives up and returns null
    - tolerance: The maximum size of the interval for an acceptable answers
 - Returns: The root, if it exists in the interval `(a,b)`
 */
public func findRootBisection(a a_0: BigFloat, b b_0: BigFloat, maxIterations: Int = 100000, tolerance: BigFloat? = 0.00001, f: ((BigFloat)->BigFloat)) -> BigFloat? {
    let has_tolerance = tolerance != nil
    let tolerance = has_tolerance ? tolerance! : 0
    
    var a: BigFloat = a_0
    var b: BigFloat = b_0
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

/**
 This function enumerates all the divisors of *n*
 */
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
    
    if includeN && n != 1 {
        handler(&stop,n)
    }
}

/**
 This function returns an array of the divisors of *n*
 */
public func divisors(_ n: Int, sorted: Bool = false, includeSelf: Bool = false) -> [Int] {
    var output: [Int] = []
    
    divisors(n) { (_, div) in
        output.append(div)
    }
    
    
    if includeSelf && n != 1 {
        output.append(n)
    }
    
    if sorted {
        output.sort()
    }
    
    return output
}

// includes self in sum
public func divisorsSum(_ n: Int) -> Int {
    var sum = 0
    divisors(n, includeN: true) { (_, div) in
        sum += div
    }
    
    return sum
}

public func factors(_ n: Int, handler: ((inout Bool, Int, Int)->Void)) {
    var div = 1
    var upper_bound = n
    var stop = false
    
    handler(&stop,1,n)
    
    loop: while div < upper_bound - 1 && !stop {
        div += 1
        
        if n % div == 0 {
            upper_bound = n / div
            handler(&stop, div, upper_bound)
            
            if upper_bound == div {
                break loop
            }
        }
    }
}

public func partitions(_ n: Int, cache: inout [Int:BigInt]) -> BigInt {
    if n < 0 {
        return 0
    } else if n == 1 || n == 0 {
        return 1
    } else if let val = cache[n] {
        return val
    }
    
    var sum: BigInt = 0
    for k in 1...n {
        sum += divisorsSum(k) * partitions(n-k, cache: &cache)
    }
    
    let result = sum / n
    
    cache[n] = result
    
    return result
}

public func partitions(_ n: Int) -> BigInt {
    var cache: [Int:BigInt] = [:]
    return partitions(n, cache: &cache)
}

public func binomialCoefficients(n: UInt, k: UInt) -> BigInt {
    let result = BigInt()
    
    __gmpz_bin_uiui(&result.integer_impl.integer, n, k)
    
    return result
}

public func enumeratePartitions(handler: (Int,BigInt)->Bool){
    func nextPartition(n: Int, partitions: inout [BigInt], divisorSums: inout [Int] ) -> BigInt {
        divisorSums.append(divisorsSum(n))
        
        var new_partition: BigInt = 0
        let count = partitions.count - 1
        for i in 0...count {
            new_partition += divisorSums[count - i] * partitions[i]
        }
        
        new_partition /= n
        partitions.append(new_partition)
        
        return new_partition
    }
    
    var count = 0
    
    var partitions: [BigInt] = [1]
    var divisorSums: [Int] = []
    var stop = false
    
    while !stop {
        count += 1
        stop = handler(count, nextPartition(n: count,
                                            partitions: &partitions,
                                            divisorSums: &divisorSums))
    }
}

/**
// https://en.wikipedia.org/wiki/Lagrange_polynomial
 */
public func lagrangeBasisPolynomial(x_values: [Int], j: Array<Int>.Index) -> Polynomial<Rational> {
    var numerator: Polynomial<Rational> = 1
    var denominator: Int = 1
    let x_j = x_values[j]
    
    for (i, el) in x_values.enumerated() {
        if i == j {
            continue
        }
        
        numerator *= [Rational(-el),1]
        denominator *= x_j - el
    }
    
    return numerator / denominator
}

public func lagrangeBasisPolynomial(count: Int, j: Array<Int>.Index) -> Polynomial<Rational> {
    var numerator: Polynomial<Rational> = 1
    var denominator: Int = 1
    let x_j = j + 1
    
    for x in 1...count {
        if x == x_j {
            continue
        }
        
        numerator *= [Rational(-x),1]
        denominator *= x_j - x
    }
    
    return numerator / denominator
}

public func lagrangePolynomial(y_values: [Int]) -> Polynomial<Rational> {
    let count = y_values.count
    var sum: Polynomial<Rational> = 0
    
    
    for (j, el) in y_values.enumerated() {
        sum += el * lagrangeBasisPolynomial(count: count, j: j)
    }
    
    return sum
}

/**
 Euler's Totient function is the number of relatively prime numbers less than or equal to *N*.  It other words, the number of integers `k` in the range 1 ≤ *k* ≤ *N*. It uses the formula:
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
    var numerator = n
    var denominator: BigInt = 1
    for p in n.primeFactorsUnique() {
        numerator *= p - 1
        denominator *= p
    }
    
    return numerator / denominator
}

/**
 This function finds the smallest of solution of Pell's equation of the form:
    ````
    x^2 - Dy^2 = 1
    ````
 It does so by finding the continue fraction expansion of the quadratic surd `√N`.  Then iteratively tries to find the first integer solution.
 
 Interestingly enough, Fermat was the first to extensively study this equation. And Euler erroneously attributed it to Pell
 
[Wikipedia - The smallest solution](https://en.wikipedia.org/wiki/Pell%27s_equation#The_smallest_solution_of_Pell_equations)
 
[ProofWiki - Example](https://proofwiki.org/wiki/Pell%27s_Equation/Examples/13)
 
[MathWord - Pell's Equation](http://mathworld.wolfram.com/PellEquation.html)

 - Precondition: D must be squarefree
 
 - Parameter D: A squarefree positive integer
 - Returns: A tuple of the smallest solution (x,y)
 */
public func findSmallestSolutionOfPellsEquation(D: UInt) -> (x: BigInt, y: BigInt) {
    let (root, expansion) = continuedFractionOfQuadraticSurd(D)
    
    var a0 = BigInt(root)
    var p0 = BigInt(root)
    var q0 = BigInt(1)
    
    var a1 = BigInt(expansion[0])
    var p1 = a0 * a1 + 1
    var q1 = a1
    
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
// with repetition = (r + n - 1)! / r!(n-1)!
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



