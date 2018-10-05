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
    
    public func allSolutions() -> [BigInt] {
        guard self.solutions.count > 0 else {
            return []
        }
        
        guard self.modulus != self.originalModulus else {
            return self.solutions
        }
        
        /// this is broken, see solveQuadratic powers of 2
        
        let output = [BigInt]()
//        var max = self.solutions.max()!
//        var k = 1
//        while max*k < self.originalModulus {
//            output.append(contentsOf: self.solutions.map {$0*k})
//        }
        
        return output
    }
    
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
 
 */
public func solveQuadraticCongruence(a: BigInt, modulus m: BigInt) -> QuadraticCongruenceSolution? {
    /// prime factor modulus
    /// find congruent solutions relative to a
    /// loop through congruences
    /// if answer is a reduced modulo answer
    ///// multiply all moduli together
    /// else
    ///// multiply all moduli other together
    let prime_factors = m.primeFactorsAndExponents()
    var reduced_modulus = BigInt(1)
    var new_modulus = BigInt(1)
    var answers = [QuadraticCongruenceSolution]()
    
    for (factor, exponent) in prime_factors {
        if let solution = solveQuadraticCongruence(a: a, primePowerModulus: factor, exponent: exponent) {
            if solution.solutions[0] == 0 {
                // reduces modulo answers, i.e. x = 0 (mod m)
                reduced_modulus *= solution.modulus
            } else {
                new_modulus *= solution.modulus
                answers.append(solution)
            }
        } else {
          return nil
        }
    }
    let result_modulus = new_modulus * reduced_modulus
    
    // if all answers are reduced modulo
    ///// answer is o mod (n/product)
    let ans_count = answers.count
    if ans_count == 0 {
        print("All anwers are reduced moduli")
        return QuadraticCongruenceSolution(solutions: [0],
                                           modulus: m/reduced_modulus,
                                           originalModulus: BigInt(m))
    }
    
//    answers[0] = QuadraticCongruenceSolution(solutions: [2,6], modulus: 8, originalModulus: 32)
    
    
    ///// if m is odd or a % m_2 == 0
    //////////  exp = 0
    //// if a is odd
    ////////// exp = n in 2^n
    //// else (a is divisible by p)
    ////////// find r
    let even_exp: UInt
    if prime_factors[0].0 == 2
        && answers.count > 0
        && answers.first!.modulus.isEven() {
        /// the first answer is non reduced and even
        let n = prime_factors[0].1
        var r: UInt = 0
        var new_a = BigInt(a)
        repeat {
            new_a /= 2
            r += 1
        } while new_a % 2 == 0 && r < n
        
        even_exp = n - r
    } else {
        even_exp = 0
    }
    
    print("---------")
    print(a,m)
    print(prime_factors)
    print("reduced_modulus:", reduced_modulus)
    print("new_modulus:", new_modulus)
    print("result_modulus:", result_modulus)
    print("even exponent:", even_exp)
    print("---------")
    
    // if theres only one non reduced answer, combine with reduced modulo answers
    if ans_count == 1 {
        print("There's one non reduced modulus")
        print(answers[0].solutions[0].isEven() ? "There's an even factor" : "There's an odd factor")
        let congruence = answers[0]
        let solution: BigInt
        if reduced_modulus > 1 {
            solution = chineseRemainderTheorem(Congruence(congruence.solutions[0], modulus: congruence.modulus),
                                               Congruence(0, modulus: reduced_modulus))!.a
        
        } else {
            solution = congruence.solutions[0]
        }
        
        let solutions = [solution, result_modulus - solution]
        if congruence.modulus.isOdd() {
            return QuadraticCongruenceSolution(solutions: solutions,
                                               modulus: result_modulus,
                                               originalModulus: BigInt(m))
        } else {
            /// answer modulus is even, so must be 2^n
            if even_exp == 1 { // 2^1
                // theres only one solution
                return QuadraticCongruenceSolution(solutions: [solution],
                                                   modulus: result_modulus,
                                                   originalModulus: BigInt(m))
            } else if even_exp == 2 { // 2^2
                // there are two solutions
                return QuadraticCongruenceSolution(solutions: solutions,
                                                   modulus: result_modulus,
                                                   originalModulus: BigInt(m))
            } else { // > 2^3
                // there are four solutions
                var other_solution = (congruence.solutions[0] * congruence.modulus) / 2
                other_solution %= congruence.modulus
                
                if result_modulus > 1 {
                    other_solution = chineseRemainderTheorem(Congruence(other_solution, modulus: congruence.modulus),
                                                             Congruence(0, modulus: reduced_modulus))!.a
                }
                
                return QuadraticCongruenceSolution(solutions: solutions + [other_solution, result_modulus - other_solution],
                                                   modulus: result_modulus,
                                                   originalModulus: BigInt(m))
            }
        }
    }
    
    print("There are multiple non reduced moduli")
    
    // at this point there is more than one non reduced answer
    ///////////////////////
    var congruences = [Congruence](repeating: Congruence(), count: ans_count + 1)
    let number_of_solutions = 1 << ans_count
    
    var solutions = [BigInt]()
    solutions.reserveCapacity(number_of_solutions)
    
    // add reduced modulo congruence
    if reduced_modulus > 1 {
        congruences[ans_count].modulus = reduced_modulus
    } else {
        congruences.removeLast()
    }
    
    if m.isOdd() {
        for i in 0..<number_of_solutions {
            var j = i
            for r in 0..<ans_count {
                let sign = j%2 == 0 ? 1 : -1
                j /= 2
                
                let ans = answers[r]
                congruences[r].a = sign * ans.solutions[0]
                congruences[r].modulus = ans.modulus
            }
            
            let new_answer = chineseRemainderTheorem(congruences: congruences)!.a
            solutions.append(new_answer)
        }
        
        return QuadraticCongruenceSolution(solutions: solutions,
                                           modulus: result_modulus,
                                           originalModulus: BigInt(m))
    } else {
        /// modulus is even
        // move first answer (the even answer to the back)
        let even_ans = answers.removeFirst()
        answers.append(even_ans)
        
//        //// if even component is greater than 8, then there are additional congruences
//        var addtl_answers: [Congruence]? = nil
//        var addtl_congruence: [Congruence]? = nil
//        if even_exp > 2 {
//            let count = ans_count+1
//            addtl_answers = [Congruence](repeating: Congruence(), count: ans_count)
//
//            addtl_congruence = [Congruence](repeating: Congruence(), count: count)
//
//
//            for r in 0..<ans_count-1 {
//                let ans = answers[r]
//                addtl_answers![r].a = ans.solutions[0]
//                addtl_answers![r].modulus = ans.modulus
//            }
//
//            // change even congruence
//            let temp = (even_ans.solutions[0] + even_ans.modulus)/2
//            addtl_answers![ans_count-1].a = temp % even_ans.modulus
//            addtl_answers![ans_count-1].modulus = even_ans.modulus
//
//            // add reduced modulo answer
//            if reduced_modulus > 1 {
//                addtl_congruence![count-1].a = 0
//                addtl_congruence![count-1].modulus = reduced_modulus
//            } else {
//                addtl_congruence!.removeLast()
//            }
//            print("!!!", addtl_congruence!)
//            print("!!!", reduced_modulus)
//        }
        
        let even_solutions = even_exp == 1 ? number_of_solutions/2 : number_of_solutions
        for i in 0..<even_solutions {
            var j = i
            for r in 0..<ans_count {
                let sign = j%2 == 0 ? 1 : -1
                j /= 2
                
                let ans = answers[r]
                congruences[r].a = sign * ans.solutions[0]
                congruences[r].modulus = ans.modulus
                
//                if even_exp > 2 {
//                    let ans = addtl_answers![r]
//                    addtl_congruence![r].a = sign * ans.a
//                    addtl_congruence![r].modulus = ans.modulus
//                }
            }
            
            print(congruences)
            let new_answer = chineseRemainderTheorem(congruences: congruences)!.a
            solutions.append(new_answer)
            
//            if even_exp > 2 {
//                let new_answer = chineseRemainderTheorem(congruences: addtl_congruence!)!
//                solutions.append(new_answer.a)
//
//
//                print(addtl_congruence!)
//                print(new_answer)
//                print()
//            }
        }
        
        print(solutions)
        
        return QuadraticCongruenceSolution(solutions: solutions, modulus: result_modulus, originalModulus: BigInt(m))
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
                return QuadraticCongruenceSolution(solutions: solutions.solutions,
                                                   modulus: solutions.modulus,
                                                   originalModulus: BigInt(modulus))
            } else {
                return nil
            }
        } else {
            if let solutions = solveQuadraticCongruence(a: a, oddPrimePowerModulus: p, exponent: n) {
                return QuadraticCongruenceSolution(solutions: solutions,
                                                   modulus: modulus,
                                                   originalModulus: BigInt(modulus))
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
            return QuadraticCongruenceSolution(solutions: [0],
                                               modulus: p**(n/2),
                                               originalModulus: BigInt(modulus))
        } else {
            // n = 2m+1
            // x = 0 (mod p^(m+1))
            return QuadraticCongruenceSolution(solutions: [0],
                                               modulus: p**(1+n/2),
                                               originalModulus: BigInt(modulus))
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
        let p_inverse = p ** m
        
        if p == 2 {
            if let quad_solutions = solveQuadraticCongruence(a: new_a, evenPrimePowerModulus: new_n) {
                // undo the transformation
                
//                let new_modulus: BigInt
                let new_modulus: BigInt = BigInt(1) << (n - m)
//                if new_n == 1 { // n - r
//                    new_modulus = 2
//                } else if new_n == 2 {
//                    new_modulus = 4
//                } else {
//                    new_modulus = BigInt(1) << (n-m-1)
//                }
                
                
                
                print("##############")
                print("n:", n)
                print("r:", r)
                print("m:", m)
                print("new_a:", new_a)
                print("new_n:", new_n)
                print("n-m-1:", n-m-1)
                print("n-2m:", n-(2*m))
                print("new_mod:",new_modulus)
                print("p_inv:",p_inverse)
                print(quad_solutions)
                print(quad_solutions.solutions.map {$0 * p_inverse})
                print("##############")
                
                let solutions = quad_solutions.solutions.map {$0 * p_inverse}
                return QuadraticCongruenceSolution(solutions: solutions,
                                                   modulus:new_modulus,
                                                   originalModulus: BigInt(modulus))
            } else {
                return nil
            }
        } else {
            if var solutions = solveQuadraticCongruence(a: new_a, oddPrimePowerModulus: p, exponent: new_n) {
                // undo the transformation
                solutions = solutions.map {$0 * p_inverse}
                return QuadraticCongruenceSolution(solutions: solutions,
                                                   modulus: p ** (n-m),
                                                   originalModulus: BigInt(modulus))
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
    - Parameter `a` must be odd, i.e. `a` and `modulus` are coprime
    - Parameter `evenPrimePowerModulus >= 1`
 
 - Parameters:
    - a: odd residue
    - evenPrimePowerModulus: the exponent of 2
 - Returns: An array of BigInts if a solution exists, otherwise nil
 */
public func solveQuadraticCongruence(a: BigInt, evenPrimePowerModulus n: UInt) -> QuadraticCongruenceSolution? {
    let original_mod = BigInt(1) << n
    
    if n == 0 {
        return nil
    } else if n == 1 {
        return QuadraticCongruenceSolution(solutions: [1],
                                           modulus: BigInt(2),
                                           originalModulus: original_mod)
    } else if n == 2 {
        if a % 4 == 1 {
            return QuadraticCongruenceSolution(solutions: [1,3],
                                               modulus: BigInt(4),
                                               originalModulus: original_mod)
        } else {
            return nil
        }
    } else if a % 8 != 1 {
        return nil
    } else {
        return QuadraticCongruenceSolution(solutions: [1,3],
                                           modulus: BigInt(4),
                                           originalModulus: original_mod)
    }
    
//    var sol_1 = BigInt(1)
//    var sol_2 = BigInt(3)
//
//    if n > 3 {
//        var i_1 = 0
//        var i_2 = 0
//
//        for k in 3..<n {
//
//            i_1 = ((sol_1*sol_1 - a) / (1 << k)).isOdd() ? 1 : 0
//            i_2 = ((sol_2*sol_2 - a) / (1 << k)).isOdd() ? 1 : 0
//
//            sol_1 += i_1 * 1 << (k-1)
//            sol_2 += i_2 * 1 << (k-1)
//        }
//    }
//
//    let q = 1 << n
//    return [sol_1,sol_2, q - sol_1, q - sol_2]
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
    __gmpz_set(total_mod, &first_congruence.modulus.integer)

    for congruence in congruences.dropFirst() {
        // temp =  m_0^(-1) * m_0 * x_1
        __gmpz_invert(temp, total_mod, &congruence.modulus.integer)
        __gmpz_mul(temp, temp, total_mod)
        __gmpz_mul(temp, temp, &congruence.a.integer)

        // temp_2 =  m_1^(-1) * m_1 * x_0
        __gmpz_invert(temp_2, &congruence.modulus.integer, total_mod)
        __gmpz_mul(temp_2, temp_2, &congruence.modulus.integer)
        __gmpz_mul(temp_2, temp_2, total_x)

        // temp = (m_0^(-1) * m_0 * x_1) + (m_1^(-1) * m_1 * x_0)
        __gmpz_add(temp, temp, temp_2)

        // get new modulus and solution
        __gmpz_mul(total_mod, total_mod, &congruence.modulus.integer)
        __gmpz_mod(total_x, temp, total_mod)
    }

    return Congruence(BigInt(total_x), modulus: BigInt(total_mod))
}

/**
 Finds the solution of two congruences, if such a solution exists.  It does by using the Ore's algorithm.

 References:
 [Algorithm](O. Ore, American Mathematical Monthly,vol.59,pp.365-370,1952)
 
 - Precondition:
    - All moduli are greater than 1
 - Parmeters: Two congruences
 - Returns: A BigInt solution, if solvable
 */
func chineseRemainderTheorem(_ c1: Congruence, _ c2: Congruence) -> Congruence? {
    let a_1 = MPZ_Pointer.allocate(capacity: 1)
    let a_2 = MPZ_Pointer.allocate(capacity: 1)
    let m_1 = MPZ_Pointer.allocate(capacity: 1)
    let m_2 = MPZ_Pointer.allocate(capacity: 1)
    let vars = [a_1,a_2,m_1,m_2]
    for v in vars {
        v.initialize(to: mpz_t())
        __gmpz_init(v)
    }
    
    defer {
        for v in vars {
            __gmpz_clear(v)
            v.deinitialize(count: 1)
            v.deallocate()
        }
    }
    
    __gmpz_set(a_1, &c1.a.integer)
    __gmpz_set(a_2, &c2.a.integer)
    __gmpz_set(m_1, &c1.modulus.integer)
    __gmpz_set(m_2, &c2.modulus.integer)
    
    if let solution = chineseRemainderTheorem(a_1: a_1, a_2: a_2, m_1: m_1, m_2: m_2) {
        let result = BigInt(solution.solution)
        let modulus = BigInt(solution.moduli_lcm)
        defer {
            __gmpz_clear(solution.solution)
            __gmpz_clear(solution.moduli_lcm)
            
            solution.solution.deinitialize(count: 1)
            solution.moduli_lcm.deinitialize(count: 1)
            
            solution.solution.deallocate()
            solution.moduli_lcm.deallocate()
        }
        
        return Congruence(result, modulus: modulus)
    } else {
        return nil
    }
}
    
/**
 Finds the solution of two congruences, if such a solution exists.  It does by using the Ore's algorithm.
 
 References:
 [Algorithm](O. Ore, American Mathematical Monthly,vol.59,pp.365-370,1952)
 
 - Precondition:
    - All moduli are greater than 1
    - All pointer are not null
 - Postcondition:
    - User is responsible for managing return pointer
 - Parmeters: Two congruences
 - Returns: A pointer to mpz_t, if solvable
 */
internal func chineseRemainderTheorem(a_1: MPZ_Pointer, a_2: MPZ_Pointer, m_1: MPZ_Pointer, m_2: MPZ_Pointer) -> (solution: MPZ_Pointer, moduli_lcm: MPZ_Pointer)? {
    /*
     let m = lcm(m_1,m_2)
     let c_k = m / m_k
     find x_k such that:
        x_1*c_1 + x_2+c_2 = 1
        m(x_1/_m1 + x_2/m_2) = 1
        m( (m_2*x_1 + m_1*x_2) / (m_1*m_2) ) = 1
        m_2*x_1 + m_1*x_2 = gcd(m_1,m_2)    because m_1*m_2 == lcm * gcd
        Use Euclid's algorithm
     Return a_1*x_1*c_1 + a_2*x_2*c_2  % lcm(m_1,m_2)
     */
    let gcd = MPZ_Pointer.allocate(capacity: 1)
    let x_1 = MPZ_Pointer.allocate(capacity: 1)
    let x_2 = MPZ_Pointer.allocate(capacity: 1)
    let temp = MPZ_Pointer.allocate(capacity: 1)
    
    let vars = [gcd,x_1,x_2,temp]
    for v in vars {
        v.initialize(to: mpz_t())
        __gmpz_init(v)
    }
    
    defer {
        for v in vars {
            __gmpz_clear(v)
            v.deinitialize(count: 1)
            v.deallocate()
        }
    }
    
    // find the gcd(m1,m2) and also the Bézout coefficients
    __gmpz_gcdext(gcd, x_2, x_1, m_1, m_2)
    
    /// if the gcd(m_1,m_2) does not divide (a-b) there is no solution
    __gmpz_sub(temp, a_1, a_2)         // temp = a_1 - a_2
    __gmpz_mod(temp, temp, gcd)         // temp = temp % gcd
    if __gmpz_cmp_ui(temp, 0) != 0 {    // temp != 0
        return nil
    }
    
    /// lcm * gcd = m_1 * m_2
    /// lcm / m_1 = m_2 / gcd == c_1
    /// a_1*x_1*c_1 = a_1*x_1*(m_2/gcd)
    __gmpz_mul(x_1, a_1, x_1)        // x_1 = a_1 * x_1
    __gmpz_mul(x_1, x_1, m_2)        // x_1 = a_1 * x_1 * m_2
    __gmpz_divexact(x_1, x_1, gcd)   // x_1 = a_1 * x_1 * m_2 / gcd
    
    __gmpz_mul(x_2, a_2, x_2)        // x_2 = a_2 * x_2
    __gmpz_mul(x_2, x_2, m_1)        // x_2 = a_2 * x_2 * m_1
    __gmpz_divexact(x_2, x_2, gcd)   // x_2 = a_2 * x_2 * m_1 / gcd
    
    /// calculate result
    /// x_1 + x_2 % lcm(m_1,m_2)
    let result = MPZ_Pointer.allocate(capacity: 1)
    let lcm = MPZ_Pointer.allocate(capacity: 1)
    
    result.initialize(to: mpz_t())
    lcm.initialize(to: mpz_t())
    
    __gmpz_init(result)
    __gmpz_init(lcm)
    
    __gmpz_mul(temp, m_1, m_2)       // temp = m_1 * m_2
    __gmpz_divexact(lcm, temp, gcd) // temp = lcm = m_1 * m_2 / gcd
    
    __gmpz_add(x_1, x_1, x_2)        // x_1 = x_1 + x_2
    __gmpz_mod(result, x_1, lcm)    // r = x_1 % lcm
    
    return (result,lcm)
}

// Ax^2 + Bxy + Cy^2 + Dx + Ey + F = 0
func quadraticSolver(Ax2: BigInt, Bxy: BigInt, Cy2: BigInt, Dx: BigInt, Ey: BigInt, F: BigInt) {
    var A = BigInt(Ax2)
    var B = BigInt(Bxy)
    var C = BigInt(Cy2)
    var D = BigInt(Dx)
    var E = BigInt(Ey)
    var F = BigInt(F)
    
    // if A == B == C == 0, then is linear Equation
    //
    if A == 0 && B == 0 && C == 0 {
        return
    }
    
    // Ax^2 + Bxy + Cy^2 + Dx + Ey + F = 0
    // find GCD of A,B,C,D,E == GCD_A_E
    // if F is not multiple of GCD(A, B, C, D, E) so there are no solutions.
    //
    let GCD_A_E = BigInt.gcd(A, B, C, D, E)
    if !F.isMultiple(of: GCD_A_E) {
        return
    }
    
    // divide all A-F by GCD_A_E
    A /= GCD_A_E
    B /= GCD_A_E
    C /= GCD_A_E
    D /= GCD_A_E
    E /= GCD_A_E
    F /= GCD_A_E
    
    // find B^2 - 4AC == (Dt)
    // if (Dt) == 0, goto Zero Discriminant
    //
    var discriminant = B*B - 4*A*C
    if discriminant == 0 {
        return
    }
    
    // Translate origin by (alpha, beta)
    // Compute alpha = 2CD - BE
    // Compute beta = 2AE - BD
    // Compute k = -(Dt) (ae^2 - bed + cd^2 + f(Dt))
    // quadratic is now of form ax^2 + bxy + cy^2 = k
//    let alpha = 2*C*D - B*E
//    let beta = 2*A*E - B*D
    var k = -discriminant * (A*E*E - B*E*D + C*D*D + F*discriminant)
    
    // compute GCD of A, B, C = GCD_ABC
    // if k is not a mutiple of GCD_ABC, there are no solutions
    //
    let GCD_ABC = BigInt.gcd(A, B, C)
    if !k.isMultiple(of: GCD_ABC) {
        return
    }
    
    // if (Dt) < 0, goto Negative/NonSquare Discriminant
    // else if (Dt) is a perfect square, goto PerfectSquare Discriminant
    // else (Dt) > 0, goto Positive/NonSquare Discriminant
    if discriminant.isPerfectSquare() {
        return
    } else {
        /////// Positive/NonSquare Discriminant
        // if k == 0, the only solution in (0,0)
        //
        if k == 0 {
            return
        }
        
        // compute GCD of A, B, C = GCD_ABC
        // divide A, B, C, K by GCD_ABC
        // K is multiple of GCD_ABC, tested above
        A /= GCD_ABC
        B /= GCD_ABC
        C /= GCD_ABC
        k /= GCD_ABC
        
        // divide (dt) by GCD_ABC ^ 2
        discriminant /= GCD_ABC * GCD_ABC

        // find GCD of A, K == GCD_AK
        // if GCD_AK != 1
        //
        if A.gcd(k) != 1 {
            //// GCD(A,K) must not equal 1 for quadratic modular algorithm to work, i.e. be not coprime
            // Perform the transformation x = PX + QY, y = RX + SY with PS - QR = 1.
            // In particular perform: x = mX + (m-1)Y, y = X + Y
            // We get: (am^2+bm+c)*X^2 + (2(am^2+bm+c) - (2am+b))*XY + ((am^2+bm+c) - (2am+b) + a)*Y^2
            // Also perform: x = X + Y, y = (m-1)X + mY
            // We get: (a+(m-1)*b+(m-1)^2*c)*X^2 + (2a + b(2m-1) + 2cm(m-1))*X*Y + (a+bm+cm^2)*Y^2
            // The discriminant of the new formula does not change.
            // Compute m=1, 2, 3,... until gcd(am^2+bm+c, K) = 1.
            // When using the second formula, change sign of m so we know the formula used when
            // undoing the unimodular transformation later.
            
            
            var m = BigInt(0)
            var temp = BigInt(0)
            var temp_2 = BigInt(0)
            repeat {
                // Compute cm^2 + bm + a and exit loop if this value is not coprime with K.
                temp_2 = C * m               // t2 = cm
                temp = m*(temp_2 + B) + A    // t = cm^2 + bm + a
                
                if temp.gcd(k) == 1 {
                    m += 1
                    m.negate()
                    break
                }
                
                m += 1
                // Compute am^2 + bm + c and loop while this value is not coprime with K.
                temp_2 = A*m               // t2 = am
                temp = m*(temp_2 + B) + C  // t = am^2 + bm + c
    
            } while temp.gcd(k) != 1
            
            // if m is positive
            if m.signum() > 0 {
                // x = mX + (m-1)Y, y = X + Y
                // (am^2+bm+c)*X^2 + [2(am^2+bm+c) - (2am+b)]*XY + [(am^2+bm+c) - (2am+b) + a]*Y^2
                
                // Compute 2am + b
                temp_2 *= 2
                temp_2 += B  // t2 == 2am + b
                
                // Compute c.
                B = temp - temp_2  // b = (am^2 + bm + c) - (2am + b)
                C = B + A          // c = (am^2 + bm + c) - (2am + b) + a
                
                // Compute b
                B += temp     // b = [(am^2 + bm + c) - (2am + b)] + (am^2 + bm + c)
                              // b = 2(am^2 + bm + c) - (2am + b)
                
                // Compute a
                A.set(temp)   // a = (am^2 + bm + c)
                
            } else {
                // x = X + Y, y = (m-1)X + mY
                // (a+(m-1)*b+(m-1)^2*c)*X^2 + (2a + b(2m-1) + 2cm(m-1))*X*Y + (a+bm+cm^2)*Y^2
                
                // Compute 2cm + b
                temp_2 *= 2
                temp_2 += B
                
                // Compute a
                B = temp - temp_2  // b = (cm^2 + bm + a) - (2cm + b)
                                   // b = cm^2 - 2cm + bm - b + a
                A = B  + C         // a = (cm^2 - 2cm + bm - b + a) + c
                                   // a = c(m-1)^2 + b(m-1) + a
                
                // Compute b
                B = B + temp   // b = (cm^2 - 2cm + bm - b + a) + (cm^2 + bm + a)
                               // b = 2cm^2 - 2cm + 2bm - b + 2a = 2cm(m-1) + b(2m-1) + 2a
                
                // Compute c
                C.set(temp)         // c = (cm^2 + bm + a)
            }
        }
        
        // prime factor K
        // find even factor multiplicities of K (the square factors)
//        let primes = k.primeFactorsAndExponents().map{($0,$1)}.filter{$0.1 % 2 == UInt(0)}
        
        
        return
    } // end if perfect square
}

// ax^2 + bx + c = 0 (mod n) where n is different from zero.
func solveQuadraticModularEquation(Ax2: BigInt, Bx: BigInt, C: BigInt, modulus: BigInt) {
    /// modulus must be > 1
    
    // if a == 1, solve as linear
    //
    
    // if b == 0, solve as square root
    //
    
    ///////
    // if a != 1, find modular inverse and multiply all coeffiecents
    //
    // equation is x^2 + a'bx + a'c = 0 (mod n)
    //
}
