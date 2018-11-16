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

internal final class BigFloatImpl {
    //
    // ivars
    //
    public var float: mpfr_t
    
    private var float_ptr_store: UnsafeMutablePointer<mpfr_t>? = nil
    public var float_ptr: UnsafeMutablePointer<mpfr_t> {
        if self.float_ptr_store == nil {
            self.float_ptr_store = UnsafeMutablePointer<mpfr_t>.allocate(capacity: 1)
            self.float_ptr_store!.initialize(to: self.float)
        }
        
        return self.float_ptr_store!
    }
    
    //
    // Initalizers
    //
    public required init(precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.float = mpfr_t()
        mpfr_init2(&self.float, precision)
    }
    
    //
    // deinit
    //
    deinit {
        if let pointer = self.float_ptr_store {
            pointer.deinitialize(count: 1)
            pointer.deallocate()
        }
        
        mpfr_clear(&self.float)
    }
    
    //
    // Copying
    //
    internal func copy() -> BigFloatImpl {
        let new_copy = BigFloatImpl(precision: self.float._mpfr_prec)
        mpfr_set(&new_copy.float, &self.float, BigFloat.defaultRounding)
        
        return new_copy
    }
}

public struct BigFloat: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
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
    internal var float_impl: BigFloatImpl
    public var float_ptr: UnsafeMutablePointer<mpfr_t> {
        return self.float_impl.float_ptr
    }
    
    //
    // Accessors
    //
    public var isInfinite: Bool {
        return mpfr_inf_p(&self.float_impl.float) != 0
    }
    
    //
    // Initalizers
    //
    public init(precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.float_impl = BigFloatImpl()
        mpfr_init2(&self.float_impl.float, precision)
    }
    
    public init(integerLiteral value: Rational.IntegerLiteralType) {
        self.init()
        mpfr_set_si(&self.float_impl.float, value, BigFloat.defaultRounding)
    }
    
    public init(floatLiteral value: Rational.FloatLiteralType) {
        self.init()
        mpfr_set_d(&self.float_impl.float, value, BigFloat.defaultRounding)
    }
    
    public init(_ infinity: Infinity, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_inf(&self.float_impl.float, infinity.rawValue)
    }
    
    public init(_ value: BigFloat, precision: mpfr_prec_t) {
        self.init(precision: precision)
        mpfr_set(&self.float_impl.float, &value.float_impl.float, BigFloat.defaultRounding)
    }
    
    public init(_ value: BigInt, precision: mpfr_prec_t = BigFloat.defaultPrecision ) {
        self.init(precision: precision)
        mpfr_set_z(&self.float_impl.float, &value.integer_impl.integer, BigFloat.defaultRounding)
    }
    
    public init(_ value: Rational, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_q(&self.float_impl.float, &value.rational_impl.rational, BigFloat.defaultRounding)
    }
    
    public init(_ numerator: Int, _ denominator: Int, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        let value = Rational(numerator,denominator)
        mpfr_set_q(&self.float_impl.float, &value.rational_impl.rational, BigFloat.defaultRounding)
    }
    
    public init(_ value: Double, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_d(&self.float_impl.float, value, BigFloat.defaultRounding)
    }
    
    public init(_ value: Int, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_si(&self.float_impl.float, value, BigFloat.defaultRounding)
    }
    
    public init(_ value: UInt, precision: mpfr_prec_t = BigFloat.defaultPrecision) {
        self.init(precision: precision)
        mpfr_set_ui(&self.float_impl.float, value, BigFloat.defaultRounding)
    }
    
    public static var pi: BigFloat {
        let result = BigFloat()
        
        mpfr_const_pi(&result.float_impl.float, BigFloat.defaultRounding)
        
        return result
    }
    
    //
    // Memory Management
    //
    private mutating func ensureUnique() {
        if !isKnownUniquelyReferenced(&self.float_impl) {
            self.float_impl = self.float_impl.copy()
        }
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
    public mutating func set(_ value: BigFloat, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        self.ensureUnique()
        
        mpfr_set(&self.float_impl.float, &value.float_impl.float, rounding)
    }
    
    public mutating func set(_ value: BigInt, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        self.ensureUnique()
        
        mpfr_set_z(&self.float_impl.float, &value.integer_impl.integer, rounding)
    }
    
    public mutating func set(_ value: Rational, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        self.ensureUnique()
        
        mpfr_set_q(&self.float_impl.float, &value.rational_impl.rational, rounding)
    }
    
    public mutating func set(_ value: Double, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        self.ensureUnique()
        
        mpfr_set_d(&self.float_impl.float, value, rounding)
    }
    
    public mutating func set(_ value: Int, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        self.ensureUnique()
        
        mpfr_set_si(&self.float_impl.float, value, rounding)
    }
    
    public mutating func set(_ value: UInt, rounding: mpfr_rnd_t = BigFloat.defaultRounding) {
        self.ensureUnique()
        
        mpfr_set_ui(&self.float_impl.float, value, rounding)
    }
}


//
// SignedNumeric
//
extension BigFloat: SignedNumeric {
    // Sign Numeric
    prefix public static func -(operand: BigFloat) -> BigFloat {
        var result = operand
        result.ensureUnique()
        
        mpfr_neg(&result.float_impl.float, &result.float_impl.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public mutating func negate() {
        self.ensureUnique()
        
        mpfr_neg(&self.float_impl.float, &self.float_impl.float, BigFloat.defaultRounding)
    }
    
    // Numeric
    public typealias Magnitude = BigFloat
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        if let s = source as? Int {
            self.init(s)
            return
        } else if let s = source as? UInt {
            self.init(s)
            return
        }
        
        return nil
    }
    
    public var magnitude: BigFloat {
        var result = self
        result.ensureUnique()
        
        mpfr_abs(&result.float_impl.float, &result.float_impl.float, BigFloat.defaultRounding)
        
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
        if let r = mpfr_get_str(nil, &exponent, base, numberOfDigits, &self.float_impl.float, BigFloat.defaultRounding) {
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
        
        mpfr_get_z(&result.integer_impl.integer, &self.float_impl.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public func toRational() -> Rational {
        let result = Rational()
        
        mpfr_get_q(&result.rational_impl.rational, &self.float_impl.float)
        
        return result
    }
    
    public func toDouble() -> Double {
        return mpfr_get_d(&self.float_impl.float, BigFloat.defaultRounding)
    }
    
    public func toInt() -> Int? {
        if  mpfr_cmp_si(&self.float_impl.float, Int.max) <= 0
        &&  mpfr_cmp_si(&self.float_impl.float, Int.min) >= 0 {
            return mpfr_get_si(&self.float_impl.float, BigFloat.defaultRounding)
        }
        
        return nil
    }
    
    public func toUInt() -> UInt? {
        if mpfr_cmp_ui(&self.float_impl.float, UInt.max) <= 0
        &&  mpfr_cmp_ui(&self.float_impl.float, UInt.min) >= 0{
            return mpfr_get_ui(&self.float_impl.float, BigFloat.defaultRounding)
        }
        
        return nil
    }
    
    public func getIntegralPart() -> BigInt {
        let result = BigFloat()
        
        mpfr_trunc(&result.float_impl.float, &self.float_impl.float)
        
        return result.toBigInt()
    }
    
    public func isIntegral() -> Bool {
        return mpfr_integer_p(&self.float_impl.float) != 0
    }
    
    public func isIntegral(tolerance: BigFloat) -> Bool {
        var int_val = mpfr_t()
        defer {
            mpfr_clear(&int_val)
        }
        
        mpfr_init2(&int_val, BigFloat.defaultPrecision)
        mpfr_roundeven(&int_val, &self.float_impl.float)
        mpfr_sub(&int_val, &int_val, &self.float_impl.float, BigFloat.defaultRounding)
        
        return mpfr_cmpabs(&int_val, &tolerance.float_impl.float) <= 0
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
        return mpfr_cmp(&lhs.float_impl.float, &rhs.float_impl.float) == 0
    }
    
    //
    // isNotEqual
    //
    public static func !=(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float_impl.float, &rhs.float_impl.float) != 0
    }
    
    //
    // isLessThan
    //
    public static func <(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float_impl.float, &rhs.float_impl.float) < 0
    }
    
    //
    // isLessThanOrEqual
    //
    public static func <=(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float_impl.float, &rhs.float_impl.float) <= 0
    }
    
    //
    // isGreaterThan
    //
    public static func >(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float_impl.float, &rhs.float_impl.float) > 0
    }
    
    //
    // isGreaterThanOrEqual
    //
    public static func >=(lhs: BigFloat, rhs: BigFloat) -> Bool {
        return mpfr_cmp(&lhs.float_impl.float, &rhs.float_impl.float) >= 0
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
        
        mpfr_add(&result.float_impl.float, &lhs.float_impl.float, &rhs.float_impl.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigFloat, rhs: BigInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_z(&result.float_impl.float, &lhs.float_impl.float, &rhs.integer_impl.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_z(&result.float_impl.float, &rhs.float_impl.float, &lhs.integer_impl.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigFloat, rhs: Rational) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_q(&result.float_impl.float, &lhs.float_impl.float, &rhs.rational_impl.rational, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: Rational, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_q(&result.float_impl.float, &rhs.float_impl.float, &lhs.rational_impl.rational, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigFloat, rhs: Int) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_si(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: Int, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_si(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigFloat, rhs: UInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_ui(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: UInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_ui(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: BigFloat, rhs: Double) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_d(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +(lhs: Double, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_add_d(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func +=(lhs: inout BigFloat, rhs: BigFloat) {
        lhs.ensureUnique()
        
        mpfr_add(&lhs.float_impl.float, &lhs.float_impl.float, &rhs.float_impl.float, BigFloat.defaultRounding)
    }
    
    public static func +=(lhs: inout BigFloat, rhs: Int) {
        lhs.ensureUnique()
        
        mpfr_add_si(&lhs.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
    }
    
    public static func +=(lhs: inout BigFloat, rhs: UInt) {
        lhs.ensureUnique()
        
        mpfr_add_ui(&lhs.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
    }
    
    //
    // Subtraction
    //
    public static func -(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_sub(&result.float_impl.float, &lhs.float_impl.float, &rhs.float_impl.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func -(lhs: BigFloat, rhs: Int) -> BigFloat {
        let result = BigFloat()
        
        mpfr_sub_si(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func -(lhs: Int, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_sub_si(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func -(lhs: BigFloat, rhs: UInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_sub_ui(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func -(lhs: UInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_sub_ui(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func -=(lhs: inout BigFloat, rhs: BigFloat) {
        lhs.ensureUnique()
        
        mpfr_sub(&lhs.float_impl.float, &lhs.float_impl.float, &rhs.float_impl.float, BigFloat.defaultRounding)
    }
    
    public static func -=(lhs: inout BigFloat, rhs: Int) {
        lhs.ensureUnique()
        
        mpfr_sub_si(&lhs.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
    }
    
    public static func -=(lhs: inout BigFloat, rhs: UInt) {
        lhs.ensureUnique()
        
        mpfr_sub_ui(&lhs.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
    }
    
    //
    // Multipication
    //
    public static func *(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul(&result.float_impl.float, &lhs.float_impl.float, &rhs.float_impl.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigFloat, rhs: Int) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_si(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: Int, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_si(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigFloat, rhs: UInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_ui(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: UInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_ui(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigFloat, rhs: Double) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_d(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: Double, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_d(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigFloat, rhs: BigInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_z(&result.float_impl.float, &lhs.float_impl.float, &rhs.integer_impl.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_z(&result.float_impl.float, &rhs.float_impl.float, &lhs.integer_impl.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: BigFloat, rhs: Rational) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_q(&result.float_impl.float, &lhs.float_impl.float, &rhs.rational_impl.rational, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *(lhs: Rational, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_mul_q(&result.float_impl.float, &rhs.float_impl.float, &lhs.rational_impl.rational, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func *=(lhs: inout BigFloat, rhs: BigFloat) {
        lhs.ensureUnique()
        
        mpfr_mul(&lhs.float_impl.float, &lhs.float_impl.float, &rhs.float_impl.float, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: Int) {
        lhs.ensureUnique()
        
        mpfr_mul_si(&lhs.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: UInt) {
        lhs.ensureUnique()
        
        mpfr_mul_ui(&lhs.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: Double) {
        lhs.ensureUnique()
        
        mpfr_mul_d(&lhs.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: BigInt) {
        lhs.ensureUnique()
        
        mpfr_mul_z(&lhs.float_impl.float, &lhs.float_impl.float, &rhs.integer_impl.integer, BigFloat.defaultRounding)
    }
    
    public static func *=(lhs: inout BigFloat, rhs: Rational) {
        lhs.ensureUnique()
        
        mpfr_mul_q(&lhs.float_impl.float, &lhs.float_impl.float, &rhs.rational_impl.rational, BigFloat.defaultRounding)
    }

    //
    // Division
    //
    public static func /(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_div(&result.float_impl.float, &lhs.float_impl.float, &rhs.float_impl.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func /(lhs: BigFloat, rhs: Int) -> BigFloat {
        let result = BigFloat()
        
        mpfr_div_si(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func /(lhs: Int, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_div_si(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func /(lhs: BigFloat, rhs: UInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_div_ui(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func /(lhs: UInt, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_div_ui(&result.float_impl.float, &rhs.float_impl.float, lhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func /=(lhs: inout BigFloat, rhs: BigFloat) {
        lhs.ensureUnique()
        
        mpfr_div(&lhs.float_impl.float, &lhs.float_impl.float, &rhs.float_impl.float, BigFloat.defaultRounding)
    }
    
    public static func /=(lhs: inout BigFloat, rhs: Int) {
        lhs.ensureUnique()
        
        mpfr_div_si(&lhs.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
    }
    
    public static func /=(lhs: inout BigFloat, rhs: UInt) {
        lhs.ensureUnique()
        
        mpfr_div_ui(&lhs.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
    }
    
    //
    // Exponentation
    //
    public static func **(lhs: BigFloat, rhs: BigFloat) -> BigFloat {
        let result = BigFloat()
        
        mpfr_pow(&result.float_impl.float, &lhs.float_impl.float, &rhs.float_impl.float, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func **(lhs: BigFloat, rhs: BigInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_pow_z(&result.float_impl.float, &lhs.float_impl.float, &rhs.integer_impl.integer, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func **(lhs: BigFloat, rhs: Int) -> BigFloat {
        let result = BigFloat()
        
        mpfr_pow_si(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
    
    public static func **(lhs: BigFloat, rhs: UInt) -> BigFloat {
        let result = BigFloat()
        
        mpfr_pow_ui(&result.float_impl.float, &lhs.float_impl.float, rhs, BigFloat.defaultRounding)
        
        return result
    }
}
