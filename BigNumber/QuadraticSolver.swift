//
//  QuadraticSolver.swift
//  BigNumber
//
//  Created by Spizzace on 9/29/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation
import GMP

/**
 Represents the congruence `x ≡ a (mod m)`
 */
public struct Congruence: Equatable {
    var a: BigInt
    var modulus: BigInt
    
    init() {
        self.a = 0
        self.modulus = 0
    }
    
    init(_ a: BigInt, modulus: BigInt) {
        self.a = a
        self.modulus = modulus
    }
}

internal typealias MPZ_Pointer = UnsafeMutablePointer<mpz_t>

/**
 QuadraticCongruenceSolution is used to store a solution to a quadratic congruence.
 */
public struct QuadraticCongruenceSolution: CustomStringConvertible {
    public let solutions: [BigInt]
    public let modulus: BigInt
    public let originalModulus: BigInt
    
    public private(set) lazy var allSolutions: [BigInt]? = {
        guard self.solutions.count > 0 else {
            return nil
        }
        
        guard self.modulus != self.originalModulus else {
            return self.solutions
        }
        
        var output = [BigInt]()
        var max = self.solutions.max()!
        var k = 1
        while max*k < self.originalModulus {
            output.append(contentsOf: self.solutions.map {$0*k})
        }
        
        return output
    }()
    
    public var description: String {
        return "Solution(\(self.solutions), mod: \(self.modulus), orig: \(self.originalModulus))"
    }
    
    public init(solutions: [BigInt], modulus: BigInt, originalModulus: BigInt) {
        self.solutions = solutions
        self.modulus = modulus
        self.originalModulus = originalModulus
    }
}

/**
 Solves the quadratic congruence:
    ```
    x^2 ≡ a (mod p^n), where p is prime
    ```
 First, if `a` and `p` are coprime, use the specialized fuctions. If `a` is a multiple of `p^n`, then the solution is `x ≡ 0 (mod m)`, where if `n` is even `m = n/2` otherwise `m = 1 + n/2`.  The only remaining case if `a` is a multiple `p`.  Find the `gcd(a,p) = p^r`.  If `r` is odd, there are no solutions.  Otherwise apply a transformation:
    ```
    r=2m, x=X*p^m, a=A*p^(2m)
    ```
 Whichs yields the congruence:
 ```
 X^2 ≡ A (mod p^(n-2m))
 ```
 At this point, `A` and `p^(n-2m)` are coprime, so use the specialized functions to get a solution. Then undo the transformation and return.
 
 References:
 
 [Algorithm Overview](http://www.numbertheory.org/php/squareroot.html)
 
 [Algorithm Implementation](http://www.numbertheory.org/gnubc/sqroot)
 
 - Precondition:
    - `exponent >= 1`
 - Parameters:
    - a: the residue
    - primePowerModulus: the prime base of the modulus
    - exponent: the exponent of the modulus
 - Returns: a CongruenceSolution representing the solution, if it exists
 */
public func solveQuadraticCongruence(a: BigInt, primePowerModulus p: BigInt, exponent n: UInt) -> QuadraticCongruenceSolution? {
    // if 'a' is not a multiple of p, then 'a' and p^n are coprime so specialized functions can be used
    let modulus = p ** n
    if !a.isMultiple(of: p) {
        if p == 2 {
            if let solutions = solveQuadraticCongruence(a: a, evenPrimePowerModulus: n) {
                return QuadraticCongruenceSolution(solutions: solutions, modulus: modulus, originalModulus: modulus)
            } else {
                return nil
            }
        } else {
            if let solutions = solveQuadraticCongruence(a: a, oddPrimePowerModulus: p, exponent: n) {
                return QuadraticCongruenceSolution(solutions: solutions, modulus: modulus, originalModulus: modulus)
            } else {
                return nil
            }
        }
    }
    
    // check if 'a' is a multiple of p^n
    if a.isMultiple(of: modulus) {
        // a is divisible p^n
        // a * k = p^n, for some k
        // x ≡ 0 (mod p^m)
        if n % 2 == UInt(0) {
            // n = 2m
            // x = 0 (mod p^m)
            return QuadraticCongruenceSolution(solutions: [0], modulus: p**(n/2), originalModulus: modulus)
        } else {
            // n = 2m+1
            // x = 0 (mod p^(m+1))
            return QuadraticCongruenceSolution(solutions: [0], modulus: p**(1+n/2), originalModulus: modulus)
        }
    }
    
    // 'a' is a multiple of p
    // 'a' is form the k*p^r
    // find r
    var r: UInt = 0
    var new_a = BigInt(a)
    repeat {
        new_a /= p
        r += 1
    } while new_a % p == 0 && r < n
    
    if r % 2 != UInt(0) {
        /// r is odd, there are no solutions
        return nil
    } else {
        /// r is even
        /// apply transformation
        // let r=2m, x=X*p^m, a=A*p^(2m)
        // congruences is now: (X*p^m)^2 ≡ A*p^(2m) (mod p^(n-2m)*p^2m)
        // which simplifies to: X^2 ≡ A (mod p^(n-2m))
        // however, the new modulus is p^(n-m)
        let m = r / 2
        let new_n = n - r
        let new_modulus = p ** (n-m)
        let p_inverse = p ** m
        
        if p == 2 {
            if var solutions = solveQuadraticCongruence(a: new_a, evenPrimePowerModulus: new_n) {
                // undo the transformation
                solutions = solutions.map {$0 * p_inverse}
                return QuadraticCongruenceSolution(solutions: solutions, modulus: new_modulus, originalModulus: modulus)
            } else {
                return nil
            }
        } else {
            if var solutions = solveQuadraticCongruence(a: new_a, oddPrimePowerModulus: p, exponent: new_n) {
                // undo the transformation
                solutions = solutions.map {$0 * p_inverse}
                return QuadraticCongruenceSolution(solutions: solutions, modulus: new_modulus, originalModulus: modulus)
            } else {
                return nil
            }
        }
    }
}

/**
 Solves the quadratic congruence:
    ```
    x^2 ≡ a (mod p^n), where p is an odd prime
    ```
 First a solution to the congruence `x^2 ≡ a (mod p)` is found. If there is a solution with modulus `p`, then Hensel's Lemma is used to produce solutions to higher powers.  Otherwise, there are no solutions.
 Hensel's Lemma is as follows: given `x[k]` is solution of `x^2 ≡ a mod p^n` solve for y in the congruence:
    ```
    2yx[k] ≡ 1 (mod p^n)
    ```
 Then
    ```
    x[k+1] = x[k] - y(x[k]^2 - a) (mod p^(n+1))
    ```
 References:
 
 [Algorithm](https://www.johndcook.com/blog/quadratic_congruences/)
 
 [Example](https://math.stackexchange.com/questions/1895058/how-to-find-modulus-square-root/1895883#1895883)
 
 - Precondition:
    - `a` and the modulus are coprime
    - `exponent >= 1`
 - Parameters:
    - a: the residue
    - oddPrimePowerModulus: the odd prime base of the modulus
    - exponent: the exponent of the modulus
 - Returns: An array of BigInts if a solution exist, otherwise nil
 */
public func solveQuadraticCongruence(a: BigInt, oddPrimePowerModulus p: BigInt, exponent n: UInt ) -> [BigInt]? {
    guard var base_solution = solveQuadraticCongruence(a: a, oddPrimeModulus: p)?.first else {
        return nil
    }
    
    let modulus = p ** n
    var temp = BigInt()
    var inverse = BigInt()
    
    if n > 1 {
        for k in 2...n {
            temp = 2 * base_solution
            __gmpz_invert(&inverse.integer, &temp.integer, &modulus.integer)
            inverse %= p
            
            base_solution = base_solution - inverse*(base_solution*base_solution - a)
            base_solution %= p ** k
        }
    }
    
    return [base_solution, modulus - base_solution]
}

/**
 Solves the quadratic congruence:
    ```
    x^2 ≡ a (mod 2^n), where a is odd
    ```
 if `n=1`, there is only one solution, `a=[1]`.
 if `n = 2`, there is a solution, `a = [1,3]`, if `a ≡ 1 (mod 4)`
 if `n >= 3`, a solutions exists only if `a ≡ 1 (mod 8)`.  In order to find a solution, first find the solution of the congruence:
    ```
    x^2 ≡ a (mod 2^3) ≡ [1,3]
    ```
 Then iteratively produce solutions of higher powers. If `x[k]` is a solution, then let `i = 1` if `(x[k]^2 - a) / 2^k` is odd, otherwise `i = 0`.  Then next solution is:
    ```
    x[k+1] = x[k] + i*2^(k-1)
    ```
 References:
 
 [Algorithm Explanation](https://www.johndcook.com/blog/quadratic_congruences/)
 
 - Precondition:
    - Parameter `a` must be odd
    - Parameter `evenPrimePowerModulus >= 1`
 
 - Parameters:
    - a: odd residue
    - evenPrimePowerModulus: the exponent of 2
 - Returns: An array of BigInts if a solution exists, otherwise nil
 */
public func solveQuadraticCongruence(a: BigInt, evenPrimePowerModulus n: UInt) -> [BigInt]? {
    if n == 0 {
        return nil
    } else if n == 1 {
        return [1]
    } else if n == 2 {
        if a % 4 == 1 {
            return [1,3]
        } else {
            return nil
        }
    } else if a % 8 != 1 {
        return nil
    }
    
    var sol_1 = BigInt(1)
    var sol_2 = BigInt(3)
    
    if n > 3 {
        var i_1 = 0
        var i_2 = 0

        for k in 3..<n {

            i_1 = ((sol_1*sol_1 - a) / (1 << k)).isOdd() ? 1 : 0
            i_2 = ((sol_2*sol_2 - a) / (1 << k)).isOdd() ? 1 : 0

            sol_1 += i_1 * 1 << (k-1)
            sol_2 += i_2 * 1 << (k-1)
        }
    }
    
    let q = 1 << n
    return [sol_1,sol_2, q - sol_1, q - sol_2]
}

/**
 Solves the quadratic congruence:
 ```
 x^2 = a (mod p), where p is an odd prime.
 ```
 
 The modular is equation is solved using the Shanks-Tonelli algorithm, which requires that p be an odd prime.  However, it first checks if p is of the form:
 ```
 p = 4k + 3, or p ≡ 3 (mod 4)
 ```
 In which case the solution is:
 ```
 a^((p+1)/4) (mod 4)
 ```
 
 If a solution exists, there are two solutions.  Only abs(root) is returned, the other solution is -root.
 
 References:
 
 [Tonelli–Shanks -- Wikipedia](https://en.wikipedia.org/wiki/Tonelli–Shanks_algorithm)
 
 [Algorithm Implementation](https://gmplib.org/list-archives/gmp-devel/2006-May/000633.html)
 
 - Precondition:
    - `p` is an odd prime
 - Parameters:
 - a: the residue
 - p: the modulus
 - Returns: square root of the congruence
 */
public func solveQuadraticCongruence(a: BigInt, oddPrimeModulus p: BigInt) -> [BigInt]? {
    
    /// check if n is divisble by p
    if a.isMultiple(of: p) {
        return [BigInt(0)]
    }
    
    /// check if n is a quadratic residue
    if __gmpz_jacobi(&a.integer, &p.integer) != 1 {
        return nil
    }
    
    // check if p is of from 4k + 3, in other words p = 3 (mod 4)
    if __gmpz_tstbit(&p.integer, 1) == 1 {
        let result = BigInt(p) + 1
        withUnsafeMutablePointer(to: &result.integer) { (r) in
            __gmpz_fdiv_q_2exp(r, r, 2)                  // r = r / 4
            __gmpz_powm(r, &a.integer, r, &p.integer)    // r = n^r (mod p)
        }
        
        // result ==  n ^ ((p+1) / 4) (mod p)
        return [result, p - result]
    }
    
    // vars
    var q = MPZ_Pointer.allocate(capacity: 1)
    var z = MPZ_Pointer.allocate(capacity: 1)
    var y = MPZ_Pointer.allocate(capacity: 1)
    var inverse_n = MPZ_Pointer.allocate(capacity: 1)
    defer {
        for x in [q,z,y,inverse_n] {
            __gmpz_clear(x)
            
            x.deinitialize(count: 1)
            x.deallocate()
        }
    }
    
    for x in [q,z,y,inverse_n] {
        x.initialize(to: mpz_t())
        __gmpz_init(x)
    }
    
    /// factor out powers of 2
    __gmpz_set(q, &p.integer) // q = p
    __gmpz_sub_ui(q, q, 1)   // q = p - 1
    
    var s: UInt = 0
    while __gmpz_tstbit(q, s) == 0 {
        s += 1
    }
    __gmpz_fdiv_q_2exp(q, q, s);
    
    // Search for a non-residue mod p
    __gmpz_set_ui(z, 2)
    while __gmpz_jacobi(z, &p.integer) != -1 {
        __gmpz_add_ui(z, z, 1)
    }
    
    // w = w^q (mod p)
    __gmpz_powm(z, z, q, &p.integer)
    
    // q = n^((q+1)/2) (mod p)
    __gmpz_add_ui(q, q, 1)                     // q = q + 1
    __gmpz_fdiv_q_2exp(q, q, 1)                // q = q / 2
    __gmpz_powm(q, &a.integer, q, &p.integer)  // q = n^q (mod p)
    
    /// loop
    var i: UInt = 0
    __gmpz_invert(inverse_n, &a.integer, &p.integer)
    main: while true {
        // y = q^2 (mod p)
        __gmpz_powm_ui(y, q, 2, &p.integer)
        
        // y = y * n^-1 (mod p)
        __gmpz_mul(y, y, inverse_n)
        __gmpz_mod(y, y, &p.integer)
        
        // loop
        i = 0
        while __gmpz_cmp_ui(y, 1) != 0 {
            i += 1
            __gmpz_powm_ui(y, y, 2, &p.integer) // y = y ^ 2 (mod p)
        }
        
        if i == 0 {
            // found solution, q^2 * n^-1 = 1 (mod p)
            break main
        }
        
        // q = q * z^(2^(s-i-1)) (mod p)
        if s-1 == UInt(1) {
            __gmpz_mul(q, q, z)
        } else {
            __gmpz_powm_ui(y, z, 1 << (s-i-1), &p.integer)
            __gmpz_mul(q, q, y)
        }
        __gmpz_mod(q, q, &p.integer)
    }
    
    let result = BigInt(q)
    return [result, p - result]
}

/**
 Solves a system of linear congruences of the form:
 ```
 x ≡ a (mod p)
 ```
 
 References:
 [Algorithm](O. Ore, American Mathematical Monthly,vol.59,pp.365-370,1952)
 
 [Wikipedia](https://en.wikipedia.org/wiki/Chinese_remainder_theorem)
 
 - Precondition:
    - `congruences.count > 1`
    - All moduli are greater than 1
 - Parameter congruences: an array of tuples (constant, modulus) describing the system
 - Returns: a congruence representing the solution of the system
 */
public func chineseRemainderTheorem(congruences: [Congruence]) -> Congruence? {
    let total_x = MPZ_Pointer.allocate(capacity: 1)
    let total_mod = MPZ_Pointer.allocate(capacity: 1)
    let temp = MPZ_Pointer.allocate(capacity: 1)
    let temp_2 = MPZ_Pointer.allocate(capacity: 1)
    
    let vars = [total_x,total_mod,temp,temp_2]
    
    for x in vars {
        x.initialize(to: mpz_t())
        __gmpz_init(x)
    }
    
    defer {
        for x in vars {
            __gmpz_clear(x)
            x.deinitialize(count: 1)
            x.deallocate()
        }
    }
    
    let first_congruence = congruences.first!
    __gmpz_set(total_x, &first_congruence.a.integer)
    __gmpz_set(total_mod, &first_congruence.modulus.integer)
    
    for congruence in congruences.dropFirst() {
        // next congruence
        if let solution = chineseRemainderTheorem(a_1: total_x, a_2: &congruence.a.integer, m_1: total_mod, m_2: &congruence.modulus.integer) {
            // update the current solution
            __gmpz_set(total_x, solution.solution)
            __gmpz_set(total_mod, solution.moduli_lcm)
            
            defer {
                __gmpz_clear(solution.solution)
                __gmpz_clear(solution.moduli_lcm)
                
                solution.solution.deinitialize(count: 1)
                solution.moduli_lcm.deinitialize(count: 1)
                
                solution.solution.deallocate()
                solution.moduli_lcm.deallocate()
            }
        } else {
            return nil
        }
    }
    
    return Congruence(BigInt(total_x),modulus: BigInt(total_mod))
    
}

/**
 Solves a system of linear congruences of the form:
 ```
 x ≡ a (mod p)
 ```
 All moduli must be pairwise coprime.  In other words, every possible pair of moduli must be coprime (their gcd() is 1)
 
 [Wikipedia](https://en.wikipedia.org/wiki/Chinese_remainder_theorem)
 
 [Algorithm Implementation](https://www.geeksforgeeks.org/using-chinese-remainder-theorem-combine-modular-equations/)
 
 
 - Precondition:
    - All moduli are pairwise coprime
    - All moduli are greater than 1
    - `congruences.count > 1`
 - Parameter congruences: an array of tuples (constant, modulus) describing the system
 - Returns: a congruence representing the solution of the system
 */
public func chineseRemainderTheorem(withCoprimeCongruences congruences: [Congruence]) -> Congruence? {
    let total_x = MPZ_Pointer.allocate(capacity: 1)
    let total_mod = MPZ_Pointer.allocate(capacity: 1)
    let temp = MPZ_Pointer.allocate(capacity: 1)
    let temp_2 = MPZ_Pointer.allocate(capacity: 1)

    let vars = [total_x,total_mod,temp,temp_2]

    for x in vars {
        x.initialize(to: mpz_t())
        __gmpz_init(x)
    }

    defer {
        for x in vars {
            __gmpz_clear(x)
            x.deinitialize(count: 1)
            x.deallocate()
        }
    }
    
    let first_congruence = congruences.first!
    __gmpz_set(total_x, &first_congruence.a.integer)
    __gmpz_set(total_mod, &first_congruence.mod.integer)
    
    for congruence in congruences.dropFirst() {
        // temp =  m_0^(-1) * m_0 * x_1
        __gmpz_invert(temp, total_mod, &congruence.mod.integer)
        __gmpz_mul(temp, temp, total_mod)
        __gmpz_mul(temp, temp, &congruence.a.integer)
        
        // temp_2 =  m_1^(-1) * m_1 * x_0
        __gmpz_invert(temp_2, &congruence.mod.integer, total_mod)
        __gmpz_mul(temp_2, temp_2, &congruence.mod.integer)
        __gmpz_mul(temp_2, temp_2, total_x)
        
        // temp = (m_0^(-1) * m_0 * x_1) + (m_1^(-1) * m_1 * x_0)
        __gmpz_add(temp, temp, temp_2)
        
        // get new modulus and solution
        __gmpz_mul(total_mod, total_mod, &congruence.mod.integer)
        __gmpz_mod(total_x, temp, total_mod)
    }
    
    return BigInt(total_x)
}

