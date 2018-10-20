//
//  Rational+Utils.swift
//  BigNumber
//
//  Created by Spizzace on 3/5/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import GMP

public func floor(_ n: Rational) -> BigInt {
    let result = BigInt()
    
    __gmpz_fdiv_q(&result.integer, &n.numerator.integer, &n.denominator.integer)
    
    return result
}

extension Rational {
    public func add(toNumerator n: UInt, subtractFromDenominator d: UInt ) {
        __gmpz_add_ui(&self.rational_impl.rational._mp_num, &self.rational_impl.rational._mp_num, n)
        __gmpz_sub_ui(&self.rational_impl.rational._mp_den, &self.rational_impl.rational._mp_den, d)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public func toFloatString(decimalPlaces: UInt = 10) -> String {
        //
        // vars
        //
        
        // alloc and init integers
        var dividend = mpz_t()
        var divisor = mpz_t()
        var quotient = mpz_t()
        var result = mpz_t()
        defer {
            __gmpz_clear(&dividend)
            __gmpz_clear(&divisor)
            __gmpz_clear(&quotient)
            __gmpz_clear(&result)
        }
        
        __gmpz_init(&dividend)
        __gmpz_init(&divisor)
        __gmpz_init(&quotient)
        __gmpz_init(&result)
        
        __gmpz_set(&dividend, &self.numerator.integer)
        __gmpz_set(&divisor, &self.denominator.integer)
        __gmpz_set_ui(&quotient, 0)
        __gmpz_set_ui(&result, 0)
        
        // output strings and loop vars
        var decimal_str: String = ""
        var decimal_count: UInt = 0
        
        //
        // get whole part
        //
        __gmpz_fdiv_qr(&quotient, &dividend, &dividend, &divisor)
        let int_str = BigInt.getString(&quotient)
        
        if __gmpz_cmp_ui(&dividend, 0) == 0 {
            return int_str
        } else {
            
            //
            // get zero padding
            //
            var padding: UInt = 0
            while __gmpz_cmp(&divisor, &dividend) > 0 {
                padding += 1
                __gmpz_mul_ui(&dividend, &dividend, 10)
            }
            
            while padding > 1 && decimal_count < decimalPlaces {
                decimal_str += "0"
                
                padding -= 1
                decimal_count += 1
            }
            
            //
            // get decimal part
            //
            while decimal_count < decimalPlaces &&  __gmpz_cmp_ui(&dividend, 0) != 0 {
                // adjust the divisor by x10 while divisor > dividend
                var adjustment: UInt = 0
                while __gmpz_cmp(&divisor, &dividend) > 0
                    && adjustment + decimal_count < decimalPlaces {
                    adjustment += 1
                    __gmpz_mul_ui(&dividend, &dividend, 10)
                    __gmpz_mul_ui(&result, &result, 10)
                }
                
                if adjustment > 0 {
                    for _ in 1..<adjustment {
                        decimal_count += 1
                    }
                }
                
                __gmpz_fdiv_qr(&quotient, &dividend, &dividend, &divisor)
                __gmpz_add(&result, &result, &quotient)
                
                decimal_count += 1
            } // end get decimal
            
            //
            // format output
            //
            if __gmpz_cmp_ui(&result, 0) != 0 {
                decimal_str += BigInt.getString(&result)
            }
            return "\(int_str).\(decimal_str)"
        }
    }
}
