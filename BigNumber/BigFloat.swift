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
    public var float: mpfr_t
    
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
    
    public static var pi: BigFloat {
        let result = BigFloat()
        
        mpfr_const_pi(&result.float, BigFloat.defaultRounding)
        
        return result
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
        return self.toPrettyString(18)
    }
    
    //
    // Assignment
    //
    public final func set(_ value: BigFloat, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        mpfr_set(&self.float, &value.float, rounding)
    }
    
    public final func set(_ value: BigInt, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        mpfr_set_z(&self.float, &value.integer, rounding)
    }
    
    public final func set(_ value: Rational, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        mpfr_set_q(&self.float, &value.rational, rounding)
    }
    
    public final func set(_ value: Double, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        mpfr_set_d(&self.float, value, rounding)
    }
    
    public final func set(_ value: Int, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        mpfr_set_si(&self.float, value, rounding)
    }
    
    public final func set(_ value: UInt, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        mpfr_set_ui(&self.float, value, rounding)
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
    
    public func toPrettyString(_ numberOfDigits: Int = 0) -> String {
        var (str, exp) = self.toString(base: 10, numberOfDigits: numberOfDigits)!
        
        guard !str.isEmpty else {
            return "0"
        }
        
        var sign = ""
        if str.first! == "-" {
            sign = "-"
            str.removeFirst()
        }
        
        if exp == 0 {
            return sign + "0." + str
        } else if exp < 0 {
            return sign + "0." + String(repeating: "0", count: -exp) + str
        } else if exp > 0 {
            if str.count > exp {
                str.insert(".", at: str.index(str.startIndex, offsetBy: exp))
                return sign + str
            } else if str.count < exp {
                return sign + str + String(repeating: "0", count: exp - str.count)
            }
        }
        
        return sign + str
    }
    
    public func toBigInt() -> BigInt {
        let result = BigInt()
        
        mpfr_get_z(&result.integer, &self.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public func toRational() -> Rational {
        let result = Rational()
        
        mpfr_get_q(&result.rational, &self.float)
        
        return result
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
    
    public static func +(lhs: BigFloat, rhs: BigInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_z(&result.float, &lhs.float, &rhs.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_z(&result.float, &rhs.float, &lhs.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigFloat, rhs: Rational) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_q(&result.float, &lhs.float, &rhs.rational, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: Rational, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_q(&result.float, &rhs.float, &lhs.rational, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigFloat, rhs: Int) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_si(&result.float, &lhs.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: Int, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_si(&result.float, &rhs.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigFloat, rhs: UInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_ui(&result.float, &lhs.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: UInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_ui(&result.float, &rhs.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigFloat, rhs: Double) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_d(&result.float, &lhs.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: Double, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_d(&result.float, &rhs.float, lhs, BigFloat.defaultRounding)
        
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
    
    public static func *(lhs: BigFloat, rhs: Int) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_si(&result.float, &lhs.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: Int, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_si(&result.float, &rhs.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigFloat, rhs: UInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_ui(&result.float, &lhs.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: UInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_ui(&result.float, &rhs.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigFloat, rhs: Double) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_d(&result.float, &lhs.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: Double, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_d(&result.float, &rhs.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigFloat, rhs: BigInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_z(&result.float, &lhs.float, &rhs.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_z(&result.float, &rhs.float, &lhs.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigFloat, rhs: Rational) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_q(&result.float, &lhs.float, &rhs.rational, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: Rational, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_q(&result.float, &rhs.float, &lhs.rational, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *=(lhs: inout BigFloat, rhs: BigFloat) {
        mpfr_mul(&lhs.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: Int) {
        mpfr_mul_si(&lhs.float, &lhs.float, rhs, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: UInt) {
        mpfr_mul_ui(&lhs.float, &lhs.float, rhs, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: Double) {
        mpfr_mul_d(&lhs.float, &lhs.float, rhs, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: BigInt) {
        mpfr_mul_z(&lhs.float, &lhs.float, &rhs.integer, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: Rational) {
        mpfr_mul_q(&lhs.float, &lhs.float, &rhs.rational, BigFloat.defaultRounding)
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
    
    //
    // Exponentation
    //
    public static func **(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_pow(&result.float, &lhs.float, &rhs.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func **(lhs: BigFloat, rhs: BigInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_pow_z(&result.float, &lhs.float, &rhs.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func **(lhs: BigFloat, rhs: Int) -> BigFloat {
        let result = BigFloat()
        
        mpfr_pow_si(&result.float, &lhs.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func **(lhs: BigFloat, rhs: UInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_pow_ui(&result.float, &lhs.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
}
