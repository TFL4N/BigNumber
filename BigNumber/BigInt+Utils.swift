//
//  BigInt+Utils.swift
//  BigNumber
//
//  Created by Spizzace on 8/19/17.
//  Copyright © 2017 SpaiceMaine. All rights reserved.
//

import GMP

extension BigInt {
    public func digitalSum() -> BigInt {
        // alloc and init vars
        var result = mpz_t()
        __gmpz_init_set_ui(&result, 0)
        
        var working = mpz_t()
        __gmpz_init_set(&working, &self.integer)
        
        var remainder = mpz_t()
        __gmpz_init_set_ui(&remainder, 0)
        
        var quotient = mpz_t()
        __gmpz_init_set_ui(&quotient, 0)
        
        var temp =  mpz_t()
        __gmpz_init_set_ui(&temp, 0)
        
        // calc digital sum
        while __gmpz_cmp_ui(&working, 0) > 0 {
            __gmpz_fdiv_qr_ui(&quotient, &remainder, &working, 10)
            
            __gmpz_set_ui(&temp, 0)
            __gmpz_add(&temp, &remainder, &result)
            
            __gmpz_set(&result, &temp)
            __gmpz_set(&working, &quotient)
        }
        
        // create output
        let output = BigInt()
        __gmpz_set(&output.integer, &result)
        
        // clear vars
        __gmpz_clear(&result)
        __gmpz_clear(&working)
        __gmpz_clear(&remainder)
        __gmpz_clear(&quotient)
        __gmpz_clear(&temp)
        
        return output
    }
    
    public static func factorial(_ n: UInt) -> BigInt {
        // alloc vars
        var result = mpz_t()
        __gmpz_init_set_ui(&result, 0)
        
        // perform factorial
        __gmpz_fac_ui(&result, n)
        
        // create output
        let output = BigInt()
        __gmpz_set(&output.integer, &result)
        
        // clear vars
        __gmpz_clear(&result)
        
        return output
    }
}
