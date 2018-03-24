//
//  BigFloat.swift
//  BigNumber
//
//  Created by Spizzace on 3/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation
import GMP
import MPFR

public enum Infinity: Int32 {
    case positive = 1, negative = -1
}

public final class BigFloat: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    //
    // constants
    //
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    public static var defaultPrecision: mpfr_prec_t = 350
    public static var defaultRounding: mpfr_rnd_t = MPFR_RNDF
    
    //
    // ivars
    //
    internal var float: mpfr_t
    
    //
    // Accessors
    //
    public var isInfinite: Bool {
        return mpfr_inf_p(&self.float) != 0
    }
    
    //
    // Initalizers
    //
    public required init(precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.float = mpfr_t()
        mpfr_init2(&self.float, precision)
    }
    
    public required convenience init(integerLiteral value: Rational.IntegerLiteralType) {
        self.init()
        mpfr_set_si(&self.float, value, BigFloat.defaultRounding)
    }
    
    public required convenience init(floatLiteral value: Rational.FloatLiteralType) {
        self.init()
        mpfr_set_d(&self.float, value, BigFloat.defaultRounding)
    }
    
    public convenience init(_ infinity: Infinity, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_inf(&self.float, infinity.rawValue)
    }
    
    public convenience init(_ value: BigFloat, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set(&self.float, &value.float, BigFloat.defaultRounding)
    }
    
    public convenience init(_ value: BigInt, precision: mpfr_prec_t = BigFloat.defaultPrecision ) {
        self.init(precision: precision)
        mpfr_set_z(&self.float, &value.integer, BigFloat.defaultRounding)
    }
    
    public convenience init(_ value: Rational, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_q(&self.float, &value.rational, BigFloat.defaultRounding)
    }
    
    public convenience init(_ value: Double, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_d(&self.float, value, BigFloat.defaultRounding)
    }
    
    public convenience init(_ value: Int, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_si(&self.float, value, BigFloat.defaultRounding)
    }
    
    public convenience init(_ value: UInt, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_ui(&self.float, value, BigFloat.defaultRounding)
    }
    
    //
    // deinit
    //
    deinit {
        mpfr_clear(&self.float)
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
        
        mpfr_neg(&result.float, &result.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public func negate() {
        mpfr_neg(&self.float, &self.float, BigFloat.defaultRounding)
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
        
        mpfr_abs(&result.float, &result.float, BigFloat.defaultRounding)
        
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
        if let r = mpfr_get_str(nil, &exponent, base, numberOfDigits, &self.float, BigFloat.defaultRounding) {
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
        return mpfr_get_d(&self.float, BigFloat.defaultRounding)
    }
    
    public func toInt() -> Int? {
        if  mpfr_cmp_si(&self.float, Int.max) <= 0
        &&  mpfr_cmp_si(&self.float, Int.min) >= 0 {
            return mpfr_get_si(&self.float, BigFloat.defaultRounding)
        }
        
        return nil
    }
    
    public func toUInt() -> UInt? {
        if mpfr_cmp_ui(&self.float, UInt.max) <= 0
        &&  mpfr_cmp_ui(&self.float, UInt.min) >= 0{
            return mpfr_get_ui(&self.float, BigFloat.defaultRounding)
        }
        
        return nil
    }
    
    public func isIntegral() -> Bool {
        return mpfr_integer_p(&self.float) != 0
    }
    
    public func isIntegral(tolerance: BigFloat) -> Bool {
        var int_val = mpfr_t()
        defer {
            mpfr_clear(&int_val)
        }
        
        mpfr_init2(&int_val, BigFloat.defaultPrecision)
        mpfr_roundeven(&int_val, &self.float)
        mpfr_sub(&int_val, &int_val, &self.float, BigFloat.defaultRounding)
        
        return mpfr_cmpabs(&int_val, &tolerance.float) <= 0
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
        return mpfr_cmp(&lhs.float, &rhs.float) == 0
    }
    
    //
    // isNotEqual
    //
    public static func !=(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float, &rhs.float) != 0
    }
    
    //
    // isLessThan
    //
    public static func <(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float, &rhs.float) < 0
    }
    
    //
    // isLessThanOrEqual
    //
    public static func <=(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float, &rhs.float) <= 0
    }
    
    //
    // isGreaterThan
    //
    public static func >(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float, &rhs.float) > 0
    }
    
    //
    // isGreaterThanOrEqual
    //
    public static func >=(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float, &rhs.float) >= 0
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
        
        mpfr_add(&result.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +=(lhs: inout BigFloat, rhs: BigFloat) {
        mpfr_add(&lhs.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
    }
    
    //
    // Subtraction
    //
    public static func -(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_sub(&result.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func -=(lhs: inout BigFloat, rhs: BigFloat) {
        mpfr_sub(&lhs.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
    }
    
    //
    // Multipication
    //
    public static func *(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul(&result.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *=(lhs: inout BigFloat, rhs: BigFloat) {
        mpfr_mul(&lhs.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
    }

    //
    // Division
    //
    public static func /(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_div(&result.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func /=(lhs: inout BigFloat, rhs: BigFloat) {
        mpfr_div(&lhs.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
    }
}
