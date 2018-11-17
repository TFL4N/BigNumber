//
//  ChineseRemainderTheorem.swift
//  BigNumber
//
//  Created by Spizzace on 11/17/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation
import GMP

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
    __gmpz_set(total_x, &first_congruence.a.integer_impl.integer)
    __gmpz_set(total_mod, &first_congruence.modulus.integer_impl.integer)
    
    for congruence in congruences.dropFirst() {
        // next congruence
        if let solution = chineseRemainderTheorem(a_1: total_x, a_2: &congruence.a.integer_impl.integer, m_1: total_mod, m_2: &congruence.modulus.integer_impl.integer) {
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
    
    return Congruence(BigInt(total_x), modulus: BigInt(total_mod))
    
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
    __gmpz_set(total_x, &first_congruence.a.integer_impl.integer)
    __gmpz_set(total_mod, &first_congruence.modulus.integer_impl.integer)
    
    for congruence in congruences.dropFirst() {
        // temp =  m_0^(-1) * m_0 * x_1
        __gmpz_invert(temp, total_mod, &congruence.modulus.integer_impl.integer)
        __gmpz_mul(temp, temp, total_mod)
        __gmpz_mul(temp, temp, &congruence.a.integer_impl.integer)
        
        // temp_2 =  m_1^(-1) * m_1 * x_0
        __gmpz_invert(temp_2, &congruence.modulus.integer_impl.integer, total_mod)
        __gmpz_mul(temp_2, temp_2, &congruence.modulus.integer_impl.integer)
        __gmpz_mul(temp_2, temp_2, total_x)
        
        // temp = (m_0^(-1) * m_0 * x_1) + (m_1^(-1) * m_1 * x_0)
        __gmpz_add(temp, temp, temp_2)
        
        // get new modulus and solution
        __gmpz_mul(total_mod, total_mod, &congruence.modulus.integer_impl.integer)
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
public func chineseRemainderTheorem(_ c1: Congruence, _ c2: Congruence) -> Congruence? {
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
    
    __gmpz_set(a_1, &c1.a.integer_impl.integer)
    __gmpz_set(a_2, &c2.a.integer_impl.integer)
    __gmpz_set(m_1, &c1.modulus.integer_impl.integer)
    __gmpz_set(m_2, &c2.modulus.integer_impl.integer)
    
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
