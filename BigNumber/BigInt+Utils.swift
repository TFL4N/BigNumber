//
//  BigInt+Utils.swift
//  BigNumber
//
//  Created by Spizzace on 8/19/17.
//  Copyright © 2017 SpaiceMaine. All rights reserved.
//

import GMP

// MARK: Instance methods
extension BigInt {
    public func radical() -> BigInt {
        return self.primeFactorsUnique().reduce(1,*)
    }
    
    public func digitalSum() -> BigInt {
        // alloc and init vars
        var result = mpz_t()
        __gmpz_init_set_ui(&result, 0)
        
        var working = mpz_t()
        __gmpz_init_set(&working, &self.integer)
        
        var remainder = mpz_t()
        __gmpz_init_set_ui(&remainder, 0)
        
        // calc digital sum
        while __gmpz_cmp_ui(&working, 0) > 0 {
            __gmpz_fdiv_qr_ui(&working, &remainder, &working, 10)
            __gmpz_add(&result, &remainder, &result)
        }
        
        // create output
        let output = BigInt()
        __gmpz_set(&output.integer, &result)
        
        // clear vars
        __gmpz_clear(&result)
        __gmpz_clear(&working)
        __gmpz_clear(&remainder)
        
        return output
    }
    
    public func orderOfMagnitude() -> UInt {
        let str = self.toString()
        return UInt(str.count)
    }
}

// MARK: Static functions
public typealias ContinedFractionExpansion = (UInt, [UInt])

extension BigInt {
    //  phi(n^k)=n^(k-1)phi(n)
    public static func eulersTotient(_ n: BigInt) -> BigInt {
        var numerator = BigInt(n)
        var denominator: BigInt = 1
        for p in n.primeFactorsUnique() {
            numerator *= p - 1
            denominator *= p
        }
        
        return numerator / denominator
    }
    
    public static func greatestCommonDivisor() -> BigInt {
        return 0
    }
    
    // https://proofwiki.org/wiki/Continued_Fraction_Expansion_of_Irrational_Square_Root/Example/13/Convergents
    public static func continuedFractionExpansionOfQuadraticSurd(_ n: UInt) -> ContinedFractionExpansion {
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
    
    // https://en.wikipedia.org/wiki/Pell%27s_equation#The_smallest_solution_of_Pell_equations
    // https://proofwiki.org/wiki/Pell%27s_Equation/Examples/13
    // http://mathworld.wolfram.com/PellEquation.html
    
    // x^2 - Dy^2 = 1
    public static func findSmallestSolutionOfPellsEquation(D: UInt) -> (x: BigInt, y: BigInt) {
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
    public static func combinations(from n: UInt, choose r: UInt) -> BigInt {
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
    
    public static func numberOfPrimes(min: UInt, max: UInt) -> UInt {
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
    
    public static func expontential(_ n: BigInt, power: UInt) -> BigInt {
        return n ** power
    }
    
    public static func factorial(_ n: UInt) -> BigInt {
        // alloc vars
        let output: BigInt = 0
        
        // perform factorial
        __gmpz_fac_ui(&output.integer, n)
        
        return output
    }
    
    public static func getString(_ n: inout mpz_t, base: Int32) -> String? {
        if let r = __gmpz_get_str(nil, base, &n) {
            return String(cString: r)
        } else {
            return nil
        }
    }
    
    public static func getString(_ n: inout mpz_t) -> String {
        return self.getString(&n, base: 10)!
    }
}
