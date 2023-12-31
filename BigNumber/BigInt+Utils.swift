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
        __gmpz_gcd(&result.integer_impl.integer, &self.integer_impl.integer, &n.integer_impl.integer)
        return result
    }
    
    public func gcd(_ n: UInt) -> BigInt {
        let result = BigInt()
        __gmpz_gcd_ui(&result.integer_impl.integer, &self.integer_impl.integer, n)
        return result
    }
    
    public func lcm(_ n: BigInt) -> BigInt {
        let result = BigInt()
        __gmpz_lcm(&result.integer_impl.integer, &self.integer_impl.integer, &n.integer_impl.integer)
        return result
    }
    
    public func isMultiple(of: BigInt) -> Bool {
        return __gmpz_divisible_p(&self.integer_impl.integer, &of.integer_impl.integer) != 0
    }
    
    public mutating func remove(_ factor: BigInt) -> UInt {
        self.ensureUnique()
        
        let count = __gmpz_remove(&self.integer_impl.integer,
                                  &self.integer_impl.integer,
                                  &factor.integer_impl.integer)
        
        return count
    }
    
    public static func remove(_ factor: BigInt, from: BigInt) -> (UInt, BigInt) {
        let result = BigInt()
        let count = __gmpz_remove(&result.integer_impl.integer,
                                  &from.integer_impl.integer,
                                  &factor.integer_impl.integer)
        
        return (count, result)
    }
    
    public func inverse(modulus: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_invert(&result.integer_impl.integer, &self.integer_impl.integer, &modulus.integer_impl.integer)
        
        return result
    }
    
    public func scanBits1(start_bit: UInt) -> UInt? {
        let result = __gmpz_scan1(&self.integer_impl.integer, start_bit)
        
        if result == UInt.max {
            return nil
        } else {
            return result
        }
    }
    
    public func scanBits0(start_bit: UInt) -> UInt? {
        let result = __gmpz_scan0(&self.integer_impl.integer, start_bit)
        
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
        __gmpz_abs(&self.integer_impl.integer, &self.integer_impl.integer)
    
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
        __gmpz_init_set(&working, &self.integer_impl.integer)
        
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
        __gmpz_set(&output.integer_impl.integer, &result)
        
        return output
    }
    
    public func orderOfMagnitude() -> UInt {
        let str = self.toString()
        return UInt(str.count)
    }
}

public func pow(_ n: BigInt, _ power: UInt) -> BigInt {
    return n ** power
}

/**
 The modular exponential is (base^exponent) % modulus
 
 Negative exp is supported if an inverse base^-1 mod modulus exists (see mpz_invert in Number Theoretic Functions). If an inverse doesn’t exist then a divide by zero is raised.
 
 - Returns: (base^exponent) % modulus
 */
public func modularExponential(base: BigInt, exponent: BigInt, modulus: BigInt) -> BigInt {
    let result = BigInt()
    
    __gmpz_powm(&result.integer_impl.integer, &base.integer_impl.integer, &exponent.integer_impl.integer, &modulus.integer_impl.integer)
    
    return result
}

/**
 The modular exponential is (base^exponent) % modulus
 
 Negative exp is supported if an inverse base^-1 mod modulus exists (see mpz_invert in Number Theoretic Functions). If an inverse doesn’t exist then a divide by zero is raised.
 
 - Returns: (base^exponent) % modulus
 */
public func modularExponential(base: BigInt, exponent: UInt, modulus: BigInt) -> BigInt {
    let result = BigInt()
    
    __gmpz_powm_ui(&result.integer_impl.integer, &base.integer_impl.integer, exponent, &modulus.integer_impl.integer)
    
    return result
}

// MARK: Static functions
public func gcd(_ n1: BigInt, _ n2: BigInt) -> BigInt {
    let result = BigInt()
    
    __gmpz_gcd(&result.integer_impl.integer, &n1.integer_impl.integer, &n2.integer_impl.integer)
    
    return result
}

public func gcd(_ n1: BigInt, _ n2: BigInt, _ numbers: BigInt ...) -> BigInt {
    let result = BigInt()
    
    __gmpz_gcd(&result.integer_impl.integer, &n1.integer_impl.integer, &n2.integer_impl.integer)
    
    for n in numbers {
        __gmpz_gcd(&result.integer_impl.integer, &result.integer_impl.integer, &n.integer_impl.integer)
    }
    
    return result
}

public func gcd(_ numbers: [BigInt]) -> BigInt {
    let count = numbers.count
    switch count {
    case 1:
        return numbers[0]
    case 2:
        return numbers[0].gcd(numbers[1])
    case 3...:
        let result = numbers[0].gcd(numbers[1])
        
        for i in 2..<count {
            __gmpz_gcd(&result.integer_impl.integer, &result.integer_impl.integer, &numbers[i].integer_impl.integer)
        }
        
        return result
        
    default:
        return 0
    }
}

public func sqrt(_ n: BigInt) -> BigInt {
    let result = BigInt()
    
    __gmpz_sqrt(&result.integer_impl.integer,
                &n.integer_impl.integer)
    
    return result
}

public func sqrt(_ n: BigInt) -> (root:BigInt, remainder: BigInt) {
    let root = BigInt()
    let remainder = BigInt()
    
    __gmpz_sqrtrem(&root.integer_impl.integer,
                   &remainder.integer_impl.integer,
                &n.integer_impl.integer)
    
    return (root,remainder)
}

extension BigInt {
    public static func factorial(_ n: UInt) -> BigInt {
        // alloc vars
        let output: BigInt = 0
        
        // perform factorial
        __gmpz_fac_ui(&output.integer_impl.integer, n)
        
        return output
    }
    
    public static func fibonacci(_ n: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_fib_ui(&result.integer_impl.integer, n)
        
        return result
    }
    
    // returns (F(n), F(n-1))
    public static func fibonacci(_ n: UInt) -> (BigInt,BigInt) {
        let result = BigInt()
        let result2 = BigInt()
        
        __gmpz_fib2_ui(&result.integer_impl.integer, &result2.integer_impl.integer, n)
        
        return (result, result2)
    }
    
    public static func lucas(_ n: UInt) -> BigInt  {
        let result = BigInt()
        
        __gmpz_lucnum_ui(&result.integer_impl.integer, n)
        
        return result
    }
    
    // returns (L(n), L(n-1))
    public static func lucas(_ n: UInt) -> (BigInt,BigInt)  {
        let result = BigInt()
        let result2 = BigInt()
        
        __gmpz_lucnum2_ui(&result.integer_impl.integer, &result2.integer_impl.integer, n)
        
        return (result, result2)
    }
    
    public static func binaryCoefficients(n: BigInt, r: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_bin_ui(&result.integer_impl.integer,
                      &n.integer_impl.integer,
                      r)
        
        return result
    }
    
    public static func binaryCoefficients(n: UInt, r: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_bin_uiui(&result.integer_impl.integer,
                        n,
                        r)
        
        return result
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
