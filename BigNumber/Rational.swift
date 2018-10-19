//
//  Rational.swift
//  BigNumber
//
//  Created by Spizzace on 8/27/17.
//  Copyright © 2017 SpaiceMaine. All rights reserved.
//

import GMP

public final class Rational: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByArrayLiteral, LosslessStringConvertible {
    //
    // constants
    //
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    public typealias ArrayLiteralElement = UInt
    
    //
    // ivars
    //
    public var rational: mpq_t
    
    public var numerator: BigInt {
        get {
            let result = BigInt()
            
            __gmpq_get_num(&result.integer, &self.rational)
            
            return result
        }
    
        set {
            __gmpz_set(&self.rational._mp_num, &newValue.integer)
            __gmpq_canonicalize(&self.rational)
        }
    }
    
    public var denominator: BigInt {
        get {
            let result = BigInt()
            
            __gmpq_get_den(&result.integer, &self.rational)
            
            return result
        }
        
        set {
            __gmpz_set(&self.rational._mp_den, &newValue.integer)
            __gmpq_canonicalize(&self.rational)
        }
    }
    
    //
    // Initalizers
    //
    public required init() {
        self.rational = mpq_t()
        __gmpq_init(&self.rational)
    }
    
    public required convenience init(integerLiteral value: Rational.IntegerLiteralType) {
        self.init()
        __gmpq_set_si(&self.rational, value, 1)
        __gmpq_canonicalize(&self.rational)
    }
    
    public required convenience init(floatLiteral value: Rational.FloatLiteralType) {
        self.init()
        __gmpq_set_d(&self.rational, value)
        __gmpq_canonicalize(&self.rational)
    }
    
    public required convenience init(arrayLiteral elements: Rational.ArrayLiteralElement...) {
        self.init()
        __gmpq_set_ui(&self.rational, elements[0], elements[1])
        __gmpq_canonicalize(&self.rational)
    }
    
    public convenience init(_ value: Rational) {
        self.init()
        __gmpq_set(&self.rational, &value.rational)
        __gmpq_canonicalize(&self.rational)
    }
    
    public convenience init(_ value: BigInt) {
        self.init()
        __gmpq_set_z(&self.rational, &value.integer)
        __gmpq_canonicalize(&self.rational)
    }
    
    public convenience init(_ value: Int) {
        self.init()
        __gmpq_set_si(&self.rational, value, 1)
        __gmpq_canonicalize(&self.rational)
    }
    
    public convenience init(_ value: UInt) {
        self.init()
        __gmpq_set_ui(&self.rational, value, 1)
        __gmpq_canonicalize(&self.rational)
    }
    
    public convenience init(_ numerator: BigInt, _ denominator: BigInt) {
        self.init()
        __gmpq_set_num(&self.rational, &numerator.integer)
        __gmpq_set_den(&self.rational, &denominator.integer)
        __gmpq_canonicalize(&self.rational)
    }
    
    public convenience init(_ numerator: UInt, _ denominator: UInt) {
        self.init()
        __gmpq_set_ui(&self.rational, numerator, denominator)
        __gmpq_canonicalize(&self.rational)
    }
    
    public convenience init(_ numerator: Int, _ denominator: UInt) {
        self.init()
        __gmpq_set_si(&self.rational, numerator, denominator)
        __gmpq_canonicalize(&self.rational)
    }
    
    public convenience init(_ numerator: Int, _ denominator: Int) {
        self.init()
        self.set(numerator, denominator)
    }
    
    public required convenience init?(_ description: String) {
        self.init(string: description, base: 10)
    }
    
    public convenience init?(string: String, base: Int32) {
        self.init()
        
        let result = string.withCString { __gmpq_set_str(&self.rational, $0, base)}
        
        if result != 0 {
            return nil
        } else {
            __gmpq_canonicalize(&self.rational)
        }
    }
    
    //
    // deinit
    //
    deinit {
        __gmpq_clear(&self.rational)
    }
    
    //
    // CustomStringConvertible
    //
    public var description: String {
        return self.toString(base: 10) ?? ""
    }
    
    //
    // Assignments
    //
    public final func set(_ value: Rational) {
        __gmpq_set(&self.rational, &value.rational)
        __gmpq_canonicalize(&self.rational)
    }
    
    public final func set(_ value: BigInt) {
        __gmpq_set_z(&self.rational, &value.integer)
        __gmpq_canonicalize(&self.rational)
    }
    
    public final func set(_ value: Int) {
        __gmpq_set_si(&self.rational, value, 1)
        __gmpq_canonicalize(&self.rational)
    }
    
    public final func set(_ value: UInt) {
        __gmpq_set_ui(&self.rational, value, 1)
        __gmpq_canonicalize(&self.rational)
    }
    
    public final func set(_ numerator: BigInt, _ denominator: BigInt) {
        __gmpq_set_num(&self.rational, &numerator.integer)
        __gmpq_set_den(&self.rational, &denominator.integer)
        __gmpq_canonicalize(&self.rational)
    }
    
    public final func set(_ numerator: UInt, _ denominator: UInt) {
        __gmpq_set_ui(&self.rational, numerator, denominator)
        __gmpq_canonicalize(&self.rational)
    }
    
    public final func set(_ numerator: Int, _ denominator: UInt) {
        __gmpq_set_si(&self.rational, numerator, denominator)
        __gmpq_canonicalize(&self.rational)
    }
    
    public final func set(_ numerator: Int, _ denominator: Int) {
        var num = abs(numerator)
        let dem = UInt(abs(denominator))
        
        let is_num_neg = numerator < 0
        let is_den_neg = denominator < 0
        
        if is_num_neg != is_den_neg {
            num.negate()
        }
        
        __gmpq_set_si(&self.rational, num, dem)
        __gmpq_canonicalize(&self.rational)
    }
    
    //
    // Misc Arithmetic
    //
    public func invert() {
        __gmpq_inv(&self.rational, &self.rational)
    }
    
    public func inverse() -> Rational {
        let result = Rational()
        
        __gmpq_inv(&result.rational, &self.rational)
        
        return result
    }
}

//
// Hashable
//
extension Rational: Hashable {
    public var hashValue: Int {
        return self.numerator.hashValue ^ self.denominator.hashValue
    }
}

//
// SignedNumeric
//
extension Rational: SignedNumeric {
    // Sign Numeric
    prefix public static func -(operand: Rational) -> Rational {
        let result = Rational(operand)
        
        __gmpq_neg(&result.rational, &result.rational)
        
        return result
    }
    
    public func negate() {
        __gmpq_neg(&self.rational, &self.rational)
    }
    
    // Numeric
    public typealias Magnitude = Rational
    
    public convenience init?<T>(exactly source: T) where T : BinaryInteger {
        if let s = source as? BigInt {
            self.init(s)
            return
        } else if let s = source as? Int {
            self.init(s)
            return
        } else if let s = source as? UInt {
            self.init(s)
            return
        }
        
        return nil
    }
    
    public var magnitude: Rational {
        let result = Rational(self)
        
        __gmpq_abs(&result.rational, &result.rational)
        
        return result
    }
    
    prefix public static func +(x: Rational) -> Rational {
        return x
    }
}


//
// Convertibles
//
extension Rational {
    public func toString(base: Int32) -> String? {
        if let r = __gmpq_get_str(nil, base, &self.rational) {
            return String(cString: r)
        } else {
            return nil
        }
    }
    
    public func toString() -> String {
        return self.toString(base: 10)!
    }
    
    public func toDouble() -> Double {
        return __gmpq_get_d(&self.rational)
    }
    
    public func isIntegral() -> Bool {
        return __gmpz_cmp_si(&self.rational._mp_den, 1) == 0
    }
}

//
// Comparable/ Equatable
//
extension Rational: Comparable, Equatable {
    //
    // isEqual
    //
    public static func ==(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_equal(&lhs.rational, &rhs.rational) != 0
    }
    
    public static func ==(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational, &rhs.integer) == 0
    }
    
    public static func ==(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational, rhs, 1) == 0
    }
    
    public static func ==(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational, rhs, 1) == 0
    }
    
    //
    // isNotEqual
    //
    public static func !=(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_equal(&lhs.rational, &rhs.rational) == 0
    }
    
    public static func !=(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational, &rhs.integer) != 0
    }
    
    public static func !=(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational, rhs, 1) == 0
    }
    
    public static func !=(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational, rhs, 1) == 0
    }
    
    //
    // isLessThan
    //
    public static func <(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational, &rhs.rational) < 0
    }
    
    public static func <(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational, &rhs.integer) < 0
    }
    
    public static func <(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational, rhs, 1) <= 0
    }
    
    public static func <(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational, rhs, 1) <= 0
    }
    
    //
    // isLessThanOrEqual
    //
    public static func <=(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational, &rhs.rational) <= 0
    }
    
    public static func <=(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational, &rhs.integer) <= 0
    }
    
    public static func <=(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational, rhs, 1) <= 0
    }
    
    public static func <=(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational, rhs, 1) <= 0
    }
    
    //
    // isGreaterThan
    // 
    public static func >(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational, &rhs.rational) > 0
    }
    
    public static func >(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational, &rhs.integer) > 0
    }
    
    public static func >(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational, rhs, 1) > 0
    }
    
    public static func >(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational, rhs, 1) > 0
    }
    
    //
    // isGreaterThanOrEqual
    //
    public static func >=(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational, &rhs.rational) >= 0
    }
    
    public static func >=(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational, &rhs.integer) >= 0
    }
    
    public static func >=(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational, rhs, 1) >= 0
    }
    
    public static func >=(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational, rhs, 1) >= 0
    }
}

//
// Numeric
//
extension Rational {
    //
    // Addition
    //
    public static func +(lhs: Rational, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_add(&result.rational, &lhs.rational, &rhs.rational)
        
        return result
    }
    
    public static func +(lhs: Int, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_add(&result.rational, &Rational(lhs).rational, &rhs.rational)
        
        return result
    }
    
    public static func +(lhs: Rational, rhs: Int) -> Rational {
        let result = Rational()
        
        __gmpq_add(&result.rational, &lhs.rational, &Rational(rhs).rational)
        
        return result
    }
    
    public static func +(lhs: UInt, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_add(&result.rational, &Rational(lhs).rational, &rhs.rational)
        
        return result
    }
    
    public static func +(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational()
        
        __gmpq_add(&result.rational, &lhs.rational, &Rational(rhs).rational)
        
        return result
    }
    
    public static func +=(lhs: inout Rational, rhs: Rational) {
        __gmpq_add(&lhs.rational, &lhs.rational, &rhs.rational)
    }
    
    public static func +=(lhs: inout Rational, rhs: Int) {
        __gmpq_add(&lhs.rational, &lhs.rational, &Rational(rhs).rational)
    }
    
    public static func +=(lhs: inout Rational, rhs: UInt) {
        __gmpq_add(&lhs.rational, &lhs.rational, &Rational(rhs).rational)
    }
    
    //
    // Subtraction
    //
    public static func -(lhs: Rational, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational, &lhs.rational, &rhs.rational)
        
        return result
    }
    
    public static func -(lhs: Int, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational, &Rational(lhs).rational, &rhs.rational)
        
        return result
    }
    
    public static func -(lhs: Rational, rhs: Int) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational, &lhs.rational, &Rational(rhs).rational)
        
        return result
    }
    
    public static func -(lhs: UInt, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational, &Rational(lhs).rational, &rhs.rational)
        
        return result
    }
    
    public static func -(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational, &lhs.rational, &Rational(rhs).rational)
        
        return result
    }
    
    public static func -=(lhs: inout Rational, rhs: Rational) {
        __gmpq_sub(&lhs.rational, &lhs.rational, &rhs.rational)
    }
    
    public static func -=(lhs: inout Rational, rhs: Int) {
        __gmpq_sub(&lhs.rational, &lhs.rational, &Rational(rhs).rational)
    }
    
    public static func -=(lhs: inout Rational, rhs: UInt) {
        __gmpq_sub(&lhs.rational, &lhs.rational, &Rational(rhs).rational)
    }
    
    //
    // Multipication
    //
    public static func *(lhs: Rational, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_mul(&result.rational, &lhs.rational, &rhs.rational)
        
        return result
    }
    
    public static func *(lhs: Rational, rhs: BigInt) -> Rational {
        let result = Rational(lhs)
        
        __gmpz_mul(&result.rational._mp_num, &result.rational._mp_num, &rhs.integer)
        __gmpq_canonicalize(&result.rational)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: Rational) -> Rational {
        let result = Rational(rhs)
        
        __gmpz_mul(&result.rational._mp_num, &lhs.integer, &result.rational._mp_num)
        __gmpq_canonicalize(&result.rational)
        
        return result
    }
    
    public static func *(lhs: Rational, rhs: Int) -> Rational {
        let result = Rational(rhs)
        
        __gmpq_mul(&result.rational, &lhs.rational, &result.rational)
        
        return result
    }
    
    public static func *(lhs: Int, rhs: Rational) -> Rational {
        let result = Rational(lhs)
        
        __gmpq_mul(&result.rational, &result.rational, &rhs.rational)
        
        return result
    }
    
    public static func *(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational(rhs)
        
        __gmpq_mul(&result.rational, &lhs.rational, &result.rational)
        
        return result
    }
    
    public static func *(lhs: UInt, rhs: Rational) -> Rational {
        let result = Rational(lhs)
        
        __gmpq_mul(&result.rational, &result.rational, &rhs.rational)
        
        return result
    }
    
    public static func *=(lhs: inout Rational, rhs: Rational) {
        __gmpq_mul(&lhs.rational, &lhs.rational, &rhs.rational)
    }
    
    public static func *=(lhs: inout Rational, rhs: Int) {
        __gmpz_mul_si(&lhs.rational._mp_num, &lhs.rational._mp_num, rhs)
        __gmpq_canonicalize(&lhs.rational)
    }
    
    public static func *=(lhs: inout Rational, rhs: UInt) {
        __gmpz_mul_ui(&lhs.rational._mp_num, &lhs.rational._mp_num, rhs)
        __gmpq_canonicalize(&lhs.rational)
    }
    
    //
    // Division
    //
    public static func /(lhs: Rational, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_div(&result.rational, &lhs.rational, &rhs.rational)
        
        return result
    }
    
    public static func /(lhs: Rational, rhs: Int) -> Rational {
        let result = Rational(rhs)
        
        __gmpq_div(&result.rational, &lhs.rational, &result.rational)
        
        return result
    }
    
    public static func /(lhs: Int, rhs: Rational) -> Rational {
        let result = Rational(lhs)
        
        __gmpq_div(&result.rational, &result.rational, &rhs.rational)
        
        return result
    }
    
    public static func /(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational(rhs)
        
        __gmpq_div(&result.rational, &lhs.rational, &result.rational)
        
        return result
    }
    
    public static func /(lhs: UInt, rhs: Rational) -> Rational {
        let result = Rational(lhs)
        
        __gmpq_div(&result.rational, &result.rational, &rhs.rational)
        
        return result
    }
    
    public static func /=(lhs: inout Rational, rhs: Rational) {
        __gmpq_div(&lhs.rational, &lhs.rational, &rhs.rational)
    }
    
    public static func /=(lhs: inout Rational, rhs: Int) {
        __gmpz_mul_si(&lhs.rational._mp_den, &lhs.rational._mp_den, rhs)
        __gmpq_canonicalize(&lhs.rational)
    }
    
    public static func /=(lhs: inout Rational, rhs: UInt) {
        __gmpz_mul_ui(&lhs.rational._mp_den, &lhs.rational._mp_den, rhs)
        __gmpq_canonicalize(&lhs.rational)
    }
    
    //
    // Exponentation
    //
    public static func **(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational()
        
        __gmpz_pow_ui(&result.rational._mp_num, &lhs.rational._mp_num, rhs)
        __gmpz_pow_ui(&result.rational._mp_den, &lhs.rational._mp_den, rhs)
        __gmpq_canonicalize(&result.rational)
        
        return result
    }
}
