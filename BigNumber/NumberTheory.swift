//
//  NumberTheory.swift
//  BigNumber
//
//  Created by Spizzace on 3/15/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

public typealias ContinedFractionExpansion = (UInt, [UInt])

//  phi(n^k)=n^(k-1)phi(n)
public func eulersTotient(_ n: BigInt) -> BigInt {
    var numerator = BigInt(n)
    var denominator: BigInt = 1
    for p in n.primeFactorsUnique() {
        numerator *= p - 1
        denominator *= p
    }
    
    return numerator / denominator
}

public func greatestCommonDivisor() -> BigInt {
    return 0
}

// https://proofwiki.org/wiki/Continued_Fraction_Expansion_of_Irrational_Square_Root/Example/13/Convergents
public func continuedFractionExpansionOfQuadraticSurd(_ n: UInt) -> ContinedFractionExpansion {
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

public func getConvergent(n: UInt, continuedFraction expansion: ContinedFractionExpansion ) -> Rational {
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

// https://en.wikipedia.org/wiki/Pell%27s_equation#The_smallest_solution_of_Pell_equations
// https://proofwiki.org/wiki/Pell%27s_Equation/Examples/13
// http://mathworld.wolfram.com/PellEquation.html

// x^2 - Dy^2 = 1
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