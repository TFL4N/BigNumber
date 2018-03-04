//
//  BigInt.swift
//  BigNumber
//
//  Created by Spizzace on 8/19/17.
//  Copyright © 2017 SpaiceMaine. All rights reserved.
//

import GMP

public class BigInt: ExpressibleByIntegerLiteral, LosslessStringConvertible {
    //
    // constants
    //
    public typealias IntegerLiteralType = Int

    //
    // ivars
    //
    internal var integer: mpz_t
    
    //
    // Initalizers
    //
    public required init() {
        self.integer = mpz_t()
        __gmpz_init(&self.integer)
    }
    
    public required init(integerLiteral value: BigInt.IntegerLiteralType) {
        self.integer = mpz_t()
        __gmpz_init_set_si(&self.integer, value)
    }
    
    public convenience init(_ integer: BigInt) {
        self.init()
        __gmpz_set(&self.integer, &integer.integer)
    }
    
    public convenience init(_ integer: UInt) {
        self.init()
        __gmpz_set_ui(&self.integer, integer)
    }
    
    public convenience init(_ integer: Int) {
        self.init()
        __gmpz_set_si(&self.integer, integer)
    }
    
    public convenience init(_ double: Double) {
        self.init()
        __gmpz_set_d(&self.integer, double)
    }
    
    public convenience init(_ rational: Rational) {
        self.init()
        __gmpz_set_q(&self.integer, &rational.rational)
    }
    
    public required convenience init?(_ string: String) {
        self.init(string: string, base: 10)
    }
    
    public convenience init?(string:String, base: Int32) {
        self.init()
        
        let result = string.withCString { __gmpz_set_str(&self.integer, $0, base) }
        
        if result != 0 {
            return nil
        }
    }
    
    //
    // deinit
    //
    deinit {
        __gmpz_clear(&self.integer)
    }
    
    //
    // CustomStringConvertible
    //
    public var description: String {
        return self.toString(base: 10) ?? ""
    }
}

//
// Convertibles
//
extension BigInt {
    public func toString(base: Int32) -> String? {
        if let r = __gmpz_get_str(nil, base, &self.integer) {
            return String(cString: r)
        } else {
            return nil
        }
    }
    
    public func toString() -> String? {
        return self.toString(base: 10)
    }
    
    public func toInt() -> Int? {
        if __gmpz_fits_slong_p(&self.integer) != 0 {
            return __gmpz_get_si(&self.integer)
        } else {
            return nil
        }
    }
    
    public func toUInt() -> UInt? {
        if __gmpz_fits_ulong_p(&self.integer) != 0 {
            return __gmpz_get_ui(&self.integer)
        } else {
            return nil
        }
    }
}

//
// Comparable/ Equatable
//
extension BigInt: Comparable, Equatable {
    //
    // isEqual
    //
    public static func ==(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) == 0
    }
    
    public static func ==(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) == 0
    }
    
    public static func ==(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) == 0
    }
    
    public static func ==(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) == 0
    }
    
    public static func ==(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) == 0
    }
    
    public static func ==(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) == 0
    }
    
    public static func ==(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) == 0
    }
    
    //
    // isLessThan
    //
    public static func <(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) < 0
    }
    
    public static func <(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) < 0
    }
    
    public static func <(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) > 0
    }
    
    public static func <(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) < 0
    }
    
    public static func <(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) > 0
    }
    
    public static func <(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) < 0
    }
    
    public static func <(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) > 0
    }
    
    //
    // isLessThanOrEqual
    //
    public static func <=(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) <= 0
    }
    
    public static func <=(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) <= 0
    }
    
    public static func <=(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) >= 0
    }
    
    public static func <=(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) <= 0
    }
    
    public static func <=(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) >= 0
    }
    
    public static func <=(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) <= 0
    }
    
    public static func <=(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) >= 0
    }
    
    //
    // isGreaterThanOrEqual
    //
    public static func >=(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) >= 0
    }
    
    public static func >=(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) >= 0
    }
    
    public static func >=(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) <= 0
    }
    
    public static func >=(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) >= 0
    }
    
    public static func >=(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) <= 0
    }
    
    public static func >=(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) >= 0
    }
    
    public static func >=(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) <= 0
    }
    
    //
    // isGreaterThan
    //
    public static func >(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) > 0
    }
    
    public static func >(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) > 0
    }
    
    public static func >(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) < 0
    }
    
    public static func >(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) > 0
    }
    
    public static func >(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) < 0
    }
    
    public static func >(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) > 0
    }
    
    public static func >(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) < 0
    }
}

//
// Numeric
//
extension BigInt {
    //
    // Addition
    //
    public static func +(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_add(&result.integer, &lhs.integer, &rhs.integer)
        
        return result
    }
    
    public static func +(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_sub_ui(&result.integer, &lhs.integer, uint)
        } else {
            __gmpz_add_ui(&result.integer, &lhs.integer, uint)
        }
        
        return result
    }
    
    public static func +(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(lhs))
        
        if lhs.signum() == -1 {
            // negative value
            __gmpz_sub_ui(&result.integer, &rhs.integer, uint)
        } else {
            __gmpz_add_ui(&result.integer, &rhs.integer, uint)
        }
        
        return result
    }
    
    public static func +(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_add_ui(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func +(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_add_ui(&result.integer, &rhs.integer, lhs)
        
        return result
    }
    
    public static func +=(lhs: inout BigInt, rhs: BigInt) {
        let result = BigInt()
        
        __gmpz_add(&result.integer, &lhs.integer, &rhs.integer)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    public static func +=(lhs: inout BigInt, rhs: UInt) {
        let result = BigInt()
        
        __gmpz_add_ui(&result.integer, &lhs.integer, rhs)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    //
    // Subtraction
    //
    public static func -(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_sub(&result.integer, &lhs.integer, &rhs.integer)
        
        return result
    }
    
    public static func -(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_add_ui(&result.integer, &lhs.integer, uint)
        } else {
            __gmpz_sub_ui(&result.integer, &lhs.integer, uint)
        }
        
        return result
    }
    
    public static func -(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(lhs))
        
        if lhs.signum() == -1 {
            // negative value
            __gmpz_add_ui(&result.integer, &rhs.integer, uint)
            __gmpz_neg(&result.integer, &result.integer)
        } else {
            __gmpz_ui_sub(&result.integer, uint,  &rhs.integer)
        }
        
        return result
    }
    
    public static func -(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_sub_ui(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func -(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_ui_sub(&result.integer, lhs,  &rhs.integer)
        
        return result
    }
    
    public static func -=(lhs: inout BigInt, rhs: BigInt) {
        let result = BigInt()
        
        __gmpz_sub(&result.integer, &lhs.integer, &rhs.integer)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    public static func -=(lhs: inout BigInt, rhs: UInt) {
        let result = BigInt()
        
        __gmpz_sub_ui(&result.integer, &lhs.integer, rhs)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    //
    // Multipication
    //
    public static func *(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul(&result.integer, &lhs.integer, &rhs.integer)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_si(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func *(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_si(&result.integer, &rhs.integer, lhs)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_ui(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func *(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_ui(&result.integer, &rhs.integer, lhs)
        
        return result
    }
    
    public static func *=(lhs: inout BigInt, rhs: BigInt) {
        let result = BigInt()
        
        __gmpz_mul(&result.integer, &lhs.integer, &rhs.integer)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    public static func *=(lhs: inout BigInt, rhs: Int) {
        let result = BigInt()
        
        __gmpz_mul_si(&result.integer, &lhs.integer, rhs)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    public static func *=(lhs: inout BigInt, rhs: UInt) {
        let result = BigInt()
        
        __gmpz_mul_ui(&result.integer, &lhs.integer, rhs)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    //
    // Bitwise
    //
    public static func <<(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_2exp(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func >>(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_tdiv_q_2exp(&result.integer, &lhs.integer, rhs)
        
        return result
    }
}

//
// Exponentiation
//
precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ** : PowerPrecedence
extension BigInt {
    static public func **(radix: BigInt, power: UInt) -> BigInt {
        var result = mpz_t()
        __gmpz_init_set_ui(&result, 0)
        
        __gmpz_pow_ui(&result, &radix.integer, power)
        
        let output = BigInt()
        __gmpz_set(&output.integer, &result)
        return output
    }
}

