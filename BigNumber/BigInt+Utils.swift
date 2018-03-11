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
extension BigInt {
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
