//
//  BigFloat.swift
//  BigNumber
//
//  Created by Spizzace on 3/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation
import GMP

public final class BigFloat: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    //
    // constants
    //
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    public static var defaultPrecision: mp_bitcnt_t = 350
    
    //
    // ivars
    //
    internal var float: mpf_t
    
    //
    // Initalizers
    //
    public required init(precision: mp_bitcnt_t = BigFloat.defaultPrecision) {
        self.float = mpf_t()
        __gmpf_init2(&self.float, precision)
    }
    
    public required convenience init(integerLiteral value: Rational.IntegerLiteralType) {
        self.init()
        __gmpf_set_si(&self.float, value)
    }
    
    public required convenience init(floatLiteral value: Rational.FloatLiteralType) {
        self.init()
        __gmpf_set_d(&self.float, value)
    }
    
    public convenience init(_ value: BigFloat, precision: mp_bitcnt_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        __gmpf_set(&self.float, &value.float)
    }
    
    public convenience init(_ value: BigInt, precision: mp_bitcnt_t = BigFloat.defaultPrecision ) {
        self.init(precision: precision)
        __gmpf_set_z(&self.float, &value.integer)
    }
    
    public convenience init(_ value: Rational, precision: mp_bitcnt_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        __gmpf_set_q(&self.float, &value.rational)
    }
    
    public convenience init(_ value: Double, precision: mp_bitcnt_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        __gmpf_set_d(&self.float, value)
    }
    
    public convenience init(_ value: Int, precision: mp_bitcnt_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        __gmpf_set_si(&self.float, value)
    }
    
    public convenience init(_ value: UInt, precision: mp_bitcnt_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        __gmpf_set_ui(&self.float, value)
    }
    
    //
    // deinit
    //
    deinit {
        __gmpf_clear(&self.float)
    }
    
    //
    // CustomStringConvertible
    //
    public var description: String {
        return self.toString()
    }
}


//
// SignedNumeric
//
extension BigFloat: SignedNumeric {
    // Sign Numeric
    prefix public static func -(operand: BigFloat) -> BigFloat {
        let result = BigFloat(operand)
        
        __gmpf_neg(&result.float, &result.float)
        
        return result
    }
    
    public func negate() {
        __gmpf_neg(&self.float, &self.float)
    }
    
    // Numeric
    public typealias Magnitude = BigFloat
    
    public convenience init?<T>(exactly source: T) where T : BinaryInteger {
        if let s = source as? BigFloat {
            self.init(s)
            return
        }
//        else if let s = source as? Int {
//            self.init(s)
//            return
//        } else if let s = source as? UInt {
//            self.init(s)
//            return
//        }
        
        return nil
    }
    
    public var magnitude: BigFloat {
        let result = BigFloat(self)
        
        __gmpf_abs(&result.float, &result.float)
        
        return result
    }
    
    prefix public static func +(x: BigFloat) -> BigFloat {
        return x
    }
}

//
// Convertibles
//
extension BigFloat {
    public func toString(base: Int32, numberOfDigits: Int = 0) -> (String, Int)? {
        var exponent = 0
        if let r = __gmpf_get_str(nil, &exponent, base, numberOfDigits, &self.float) {
            return (String(cString: r),exponent)
        } else {
            return nil
        }
    }
    
    public func toString() -> String {
        var (str, exp) = self.toString(base: 10)!
        
        if str.isEmpty {
            return "0"
        } else if exp == 0 {
            return "0." + str
        } else if exp < 0 {
            return "0." + String(repeating: "0", count: -exp) + str
        } else if exp > 0 {
            if str.count > exp {
                str.insert(".", at: str.index(str.startIndex, offsetBy: exp))
                return str
            } else if str.count < exp {
                return str + String(repeating: "0", count: exp - str.count) 
            }
        }
        
        return str
    }
    
    public func toDouble() -> Double {
        return __gmpf_get_d(&self.float)
    }
    
    public func toInt() -> Int? {
        if __gmpf_get_d(&self.float) != 0 {
            return __gmpf_get_si(&self.float)
        }
        
        return nil
    }
    
    public func toUInt() -> UInt? {
        if __gmpf_get_d(&self.float) != 0 {
            return __gmpf_get_ui(&self.float)
        }
        
        return nil
    }
    
    public func isIntegral() -> Bool {
        return __gmpf_integer_p(&self.float) != 0
    }
}

//
// Comparable/ Equatable
//
extension BigFloat: Comparable, Equatable {
    //
    // isEqual
    //
    public static func ==(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return __gmpf_cmp(&lhs.float, &rhs.float) != 0
    }
    
    //
    // isNotEqual
    //
    public static func !=(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return __gmpf_cmp(&lhs.float, &rhs.float) == 0
    }
    
    //
    // isLessThan
    //
    public static func <(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return __gmpf_cmp(&lhs.float, &rhs.float) < 0
    }
    
    //
    // isLessThanOrEqual
    //
    public static func <=(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return __gmpf_cmp(&lhs.float, &rhs.float) <= 0
    }
    
    //
    // isGreaterThan
    //
    public static func >(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return __gmpf_cmp(&lhs.float, &rhs.float) > 0
    }
    
    //
    // isGreaterThanOrEqual
    //
    public static func >=(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return __gmpf_cmp(&lhs.float, &rhs.float) >= 0
    }
}

//
// Numeric
//
extension BigFloat {
    //
    // Addition
    //
    public static func +(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        __gmpf_add(&result.float, &lhs.float, &rhs.float)
        
        return result
    }
    
    public static func +=(lhs: inout BigFloat, rhs: BigFloat) {
        __gmpf_add(&lhs.float, &lhs.float, &rhs.float)
    }
    
    //
    // Subtraction
    //
    public static func -(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        __gmpf_sub(&result.float, &lhs.float, &rhs.float)
        
        return result
    }
    
    public static func -=(lhs: inout BigFloat, rhs: BigFloat) {
        __gmpf_sub(&lhs.float, &lhs.float, &rhs.float)
    }
    
    //
    // Multipication
    //
    public static func *(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        __gmpf_mul(&result.float, &lhs.float, &rhs.float)
        
        return result
    }
    
    public static func *=(lhs: inout BigFloat, rhs: BigFloat) {
        __gmpf_mul(&lhs.float, &lhs.float, &rhs.float)
    }

    //
    // Division
    //
    public static func /(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        __gmpf_div(&result.float, &lhs.float, &rhs.float)
        
        return result
    }
    
    public static func /=(lhs: inout BigFloat, rhs: BigFloat) {
        __gmpf_div(&lhs.float, &lhs.float, &rhs.float)
    }
}
