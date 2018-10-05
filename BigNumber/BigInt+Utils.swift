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
    public func gcd(_ n: BigInt) -> BigInt {
        let result = BigInt()
        __gmpz_gcd(&result.integer, &self.integer, &n.integer)
        return result
    }
    
    public func gcd(_ n: UInt) -> BigInt {
        let result = BigInt()
        __gmpz_gcd_ui(&result.integer, &self.integer, n)
        return result
    }
    
    public func isMultiple(of: BigInt) -> Bool {
        return __gmpz_divisible_p(&self.integer, &of.integer) != 0
    }
    
    public func inverse(modulus: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_invert(&result.integer, &self.integer, &modulus.integer)
        
        return result
    }
    
    public func scanBits1(start_bit: UInt) -> UInt? {
        let result = __gmpz_scan1(&self.integer, start_bit)
        
        if result == UInt.max {
            return nil
        } else {
            return result
        }
    }
    
    public func scanBits0(start_bit: UInt) -> UInt? {
        let result = __gmpz_scan0(&self.integer, start_bit)
        
        if result == UInt.max {
            return nil
        } else {
            return result
        }
    }
    
    /**
     The radical of a number is the product of all its unique prime factors
     
     - Returns: The radical
     */
    public func radical() -> BigInt {
        return self.primeFactorsUnique().reduce(1,*)
    }
    
    public func makePositive() -> BigInt {
        __gmpz_abs(&self.integer, &self.integer)
    
        return self
    }
    
    func isSquareFree(n: BigInt) -> Bool {
        var last: BigInt = 0
        var is_free = true
        n.enumeratePrimeFactors { (stop, factor, _) in
            if last == factor {
                stop = true
                is_free = false
            } else {
                last = factor
            }
        }
        
        return is_free
    }
    
    /**
     The digital sum is the sum of a number's individual digits
     
     
     - ToDo: \#80 might have faster method -- convert to str, and add ascii values
     
     - Returns: The digital sum
     */
    public func digitalSum() -> BigInt {
        // alloc and init vars
        var result = mpz_t()
        __gmpz_init_set_ui(&result, 0)
        
        var working = mpz_t()
        __gmpz_init_set(&working, &self.integer)
        
        var remainder = mpz_t()
        __gmpz_init_set_ui(&remainder, 0)
        
        defer {
            __gmpz_clear(&result)
            __gmpz_clear(&working)
            __gmpz_clear(&remainder)
        }
        
        
        // calc digital sum
        while __gmpz_cmp_ui(&working, 0) > 0 {
            __gmpz_fdiv_qr_ui(&working, &remainder, &working, 10)
            __gmpz_add(&result, &remainder, &result)
        }
        
        // create output
        let output = BigInt()
        __gmpz_set(&output.integer, &result)
        
        return output
    }
    
    public func orderOfMagnitude() -> UInt {
        let str = self.toString()
        return UInt(str.count)
    }
}

// MARK: Static functions
extension BigInt {
    public static func gcd(_ n1: BigInt, _ n2: BigInt, _ numbers: BigInt ...) -> BigInt {
        let result = BigInt()
        
        __gmpz_gcd(&result.integer, &n1.integer, &n2.integer)
        
        for n in numbers {
            __gmpz_gcd(&result.integer, &result.integer, &n.integer)
        }
        
        return result
    }
    
    public static func exponential(_ n: BigInt, power: UInt) -> BigInt {
        return n ** power
    }
    
    /**
     The modular exponential is (base^exponent) % modulus
     
     Negative exp is supported if an inverse base^-1 mod modulus exists (see mpz_invert in Number Theoretic Functions). If an inverse doesn’t exist then a divide by zero is raised.
     
     - Returns: (base^exponent) % modulus
     */
    func modularExponential(base: BigInt, exponent: BigInt, modulus: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_powm(&result.integer, &base.integer, &exponent.integer, &modulus.integer)
        
        return result
    }
    
    public static func factorial(_ n: UInt) -> BigInt {
        // alloc vars
        let output: BigInt = 0
        
        // perform factorial
        __gmpz_fac_ui(&output.integer, n)
        
        return output
    }
    
    public static func fibonacci(_ n: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_fib_ui(&result.integer, n)
        
        return result
    }
    
    // returns (F(n), F(n-1))
    public static func fibonacci(_ n: UInt) -> (BigInt,BigInt) {
        let result = BigInt()
        let result2 = BigInt()
        
        __gmpz_fib2_ui(&result.integer, &result2.integer, n)
        
        return (result, result2)
    }
    
    public static func lucas(_ n: UInt) -> BigInt  {
        let result = BigInt()
        
        __gmpz_lucnum_ui(&result.integer, n)
        
        return result
    }
    
    // returns (L(n), L(n-1))
    public static func lucas(_ n: UInt) -> (BigInt,BigInt)  {
        let result = BigInt()
        let result2 = BigInt()
        
        __gmpz_lucnum2_ui(&result.integer, &result2.integer, n)
        
        return (result, result2)
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
