//
//  Rational.swift
//  BigNumber
//
//  Created by Spizzace on 8/27/17.
//  Copyright © 2017 SpaiceMaine. All rights reserved.
//

import GMP

internal final class RationalImpl {
    //
    // ivars
    //
    public var rational: mpq_t
    
    private var rational_ptr_store: UnsafeMutablePointer<mpq_t>? = nil
    public var rational_ptr: UnsafeMutablePointer<mpq_t> {
        if self.rational_ptr_store == nil {
            self.rational_ptr_store = UnsafeMutablePointer<mpq_t>.allocate(capacity: 1)
            self.rational_ptr_store!.initialize(to: self.rational)
        }
        
        return self.rational_ptr_store!
    }
    
    //
    // Initalizers
    //
    public required init() {
        self.rational = mpq_t()
        __gmpq_init(&self.rational)
    }
    
    //
    // deinit
    //
    deinit {
        __gmpq_clear(&self.rational)
    }
    
    //
    // Copying
    //
    internal func copy() -> RationalImpl {
        let new_copy = RationalImpl()
        __gmpq_set(&new_copy.rational, &self.rational)
//        __gmpq_canonicalize(&self.rational)
        
        return new_copy
    }
}

public struct Rational: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByArrayLiteral, LosslessStringConvertible {
    //
    // constants
    //
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    public typealias ArrayLiteralElement = UInt
    
    //
    // ivars
    //
    internal var rational_impl: RationalImpl
    public var rational_ptr: UnsafeMutablePointer<mpq_t> {
        return self.rational_impl.rational_ptr
    }
    
    public var numerator: BigInt {
        get {
            let result = BigInt()
            
            __gmpq_get_num(&result.integer, &self.rational_impl.rational)
            
            return result
        }
        
        set {
            __gmpz_set(&self.rational_impl.rational._mp_num, &newValue.integer)
            __gmpq_canonicalize(&self.rational_impl.rational)
        }
    }
    
    public var denominator: BigInt {
        get {
            let result = BigInt()
            
            __gmpq_get_den(&result.integer, &self.rational_impl.rational)
            
            return result
        }
        
        set {
            __gmpz_set(&self.rational_impl.rational._mp_den, &newValue.integer)
            __gmpq_canonicalize(&self.rational_impl.rational)
        }
    }
    
    //
    // Initalizers
    //
    public init() {
        self.rational_impl = RationalImpl()
    }
    
    public init(integerLiteral value: Rational.IntegerLiteralType) {
        self.init()
        __gmpq_set_si(&self.rational_impl.rational, value, 1)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public init(floatLiteral value: Rational.FloatLiteralType) {
        self.init()
        __gmpq_set_d(&self.rational_impl.rational, value)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public init(arrayLiteral elements: Rational.ArrayLiteralElement...) {
        self.init()
        __gmpq_set_ui(&self.rational_impl.rational, elements[0], elements[1])
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public init(_ value: BigInt) {
        self.init()
        __gmpq_set_z(&self.rational_impl.rational, &value.integer)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public  init(_ value: Int) {
        self.init()
        __gmpq_set_si(&self.rational_impl.rational, value, 1)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public init(_ value: UInt) {
        self.init()
        __gmpq_set_ui(&self.rational_impl.rational, value, 1)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public init(_ numerator: BigInt, _ denominator: BigInt) {
        self.init()
        __gmpq_set_num(&self.rational_impl.rational, &numerator.integer)
        __gmpq_set_den(&self.rational_impl.rational, &denominator.integer)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public init(_ numerator: UInt, _ denominator: UInt) {
        self.init()
        __gmpq_set_ui(&self.rational_impl.rational, numerator, denominator)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public init(_ numerator: Int, _ denominator: UInt) {
        self.init()
        __gmpq_set_si(&self.rational_impl.rational, numerator, denominator)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public init(_ numerator: Int, _ denominator: Int) {
        self.init()
        self.set(numerator, denominator)
    }
    
    public init?(_ description: String) {
        self.init(string: description, base: 10)
    }
    
    public init?(string: String, base: Int32) {
        self.init()
        
        let result = string.withCString { __gmpq_set_str(&self.rational_impl.rational, $0, base)}
        
        if result != 0 {
            return nil
        } else {
            __gmpq_canonicalize(&self.rational_impl.rational)
        }
    }
    
    //
    // Memory Management
    //
    private mutating func ensureUnique() {
        if !isKnownUniquelyReferenced(&self.rational_impl) {
            self.rational_impl = self.rational_impl.copy()
        }
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
    public mutating func set(_ value: Rational) {
        self.ensureUnique()
        
        __gmpq_set(&self.rational_impl.rational, &value.rational_impl.rational)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public mutating func set(_ value: BigInt) {
        self.ensureUnique()
        
        __gmpq_set_z(&self.rational_impl.rational, &value.integer)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public mutating func set(_ value: Int) {
        self.ensureUnique()
        
        __gmpq_set_si(&self.rational_impl.rational, value, 1)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public mutating func set(_ value: UInt) {
        self.ensureUnique()
        
        __gmpq_set_ui(&self.rational_impl.rational, value, 1)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public mutating func set(_ numerator: BigInt, _ denominator: BigInt) {
        self.ensureUnique()
        
        __gmpq_set_num(&self.rational_impl.rational, &numerator.integer)
        __gmpq_set_den(&self.rational_impl.rational, &denominator.integer)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public mutating func set(_ numerator: UInt, _ denominator: UInt) {
        self.ensureUnique()
        
        __gmpq_set_ui(&self.rational_impl.rational, numerator, denominator)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public mutating func set(_ numerator: Int, _ denominator: UInt) {
        self.ensureUnique()
        
        __gmpq_set_si(&self.rational_impl.rational, numerator, denominator)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    public mutating func set(_ numerator: Int, _ denominator: Int) {
        self.ensureUnique()
        
        var num = abs(numerator)
        let dem = UInt(abs(denominator))
        
        let is_num_neg = numerator < 0
        let is_den_neg = denominator < 0
        
        if is_num_neg != is_den_neg {
            num.negate()
        }
        
        __gmpq_set_si(&self.rational_impl.rational, num, dem)
        __gmpq_canonicalize(&self.rational_impl.rational)
    }
    
    //
    // Misc Arithmetic
    //
    public mutating func invert() {
        self.ensureUnique()
        
        __gmpq_inv(&self.rational_impl.rational, &self.rational_impl.rational)
    }
    
    public func inverse() -> Rational {
        let result = Rational()
        
        __gmpq_inv(&result.rational_impl.rational, &self.rational_impl.rational)
        
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
        let result = operand
        
        __gmpq_neg(&result.rational_impl.rational, &result.rational_impl.rational)
        
        return result
    }
    
    public mutating func negate() {
        self.ensureUnique()
        
        __gmpq_neg(&self.rational_impl.rational, &self.rational_impl.rational)
    }
    
    // Numeric
    public typealias Magnitude = Rational
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
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
        let result = self
        
        __gmpq_abs(&result.rational_impl.rational, &result.rational_impl.rational)
        
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
        if let r = __gmpq_get_str(nil, base, &self.rational_impl.rational) {
            return String(cString: r)
        } else {
            return nil
        }
    }
    
    public func toString() -> String {
        return self.toString(base: 10)!
    }
    
    public func toDouble() -> Double {
        return __gmpq_get_d(&self.rational_impl.rational)
    }
    
    public func isIntegral() -> Bool {
        return __gmpz_cmp_si(&self.rational_impl.rational._mp_den, 1) == 0
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
        return __gmpq_equal(&lhs.rational_impl.rational, &rhs.rational_impl.rational) != 0
    }
    
    public static func ==(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational_impl.rational, &rhs.integer) == 0
    }
    
    public static func ==(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational_impl.rational, rhs, 1) == 0
    }
    
    public static func ==(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational_impl.rational, rhs, 1) == 0
    }
    
    //
    // isNotEqual
    //
    public static func !=(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_equal(&lhs.rational_impl.rational, &rhs.rational_impl.rational) == 0
    }
    
    public static func !=(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational_impl.rational, &rhs.integer) != 0
    }
    
    public static func !=(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational_impl.rational, rhs, 1) == 0
    }
    
    public static func !=(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational_impl.rational, rhs, 1) == 0
    }
    
    //
    // isLessThan
    //
    public static func <(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational_impl.rational, &rhs.rational_impl.rational) < 0
    }
    
    public static func <(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational_impl.rational, &rhs.integer) < 0
    }
    
    public static func <(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational_impl.rational, rhs, 1) <= 0
    }
    
    public static func <(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational_impl.rational, rhs, 1) <= 0
    }
    
    //
    // isLessThanOrEqual
    //
    public static func <=(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational_impl.rational, &rhs.rational_impl.rational) <= 0
    }
    
    public static func <=(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational_impl.rational, &rhs.integer) <= 0
    }
    
    public static func <=(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational_impl.rational, rhs, 1) <= 0
    }
    
    public static func <=(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational_impl.rational, rhs, 1) <= 0
    }
    
    //
    // isGreaterThan
    //
    public static func >(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational_impl.rational, &rhs.rational_impl.rational) > 0
    }
    
    public static func >(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational_impl.rational, &rhs.integer) > 0
    }
    
    public static func >(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational_impl.rational, rhs, 1) > 0
    }
    
    public static func >(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational_impl.rational, rhs, 1) > 0
    }
    
    //
    // isGreaterThanOrEqual
    //
    public static func >=(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational_impl.rational, &rhs.rational_impl.rational) >= 0
    }
    
    public static func >=(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational_impl.rational, &rhs.integer) >= 0
    }
    
    public static func >=(lhs: Rational, rhs: Int) -> Bool {
        return __gmpq_cmp_si(&lhs.rational_impl.rational, rhs, 1) >= 0
    }
    
    public static func >=(lhs: Rational, rhs: UInt) -> Bool {
        return __gmpq_cmp_ui(&lhs.rational_impl.rational, rhs, 1) >= 0
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
        
        __gmpq_add(&result.rational_impl.rational, &lhs.rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func +(lhs: Int, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_add(&result.rational_impl.rational, &Rational(lhs).rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func +(lhs: Rational, rhs: Int) -> Rational {
        let result = Rational()
        
        __gmpq_add(&result.rational_impl.rational, &lhs.rational_impl.rational, &Rational(rhs).rational_impl.rational)
        
        return result
    }
    
    public static func +(lhs: UInt, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_add(&result.rational_impl.rational, &Rational(lhs).rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func +(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational()
        
        __gmpq_add(&result.rational_impl.rational, &lhs.rational_impl.rational, &Rational(rhs).rational_impl.rational)
        
        return result
    }
    
    public static func +=(lhs: inout Rational, rhs: Rational) {
        lhs.ensureUnique()
        
        __gmpq_add(&lhs.rational_impl.rational, &lhs.rational_impl.rational, &rhs.rational_impl.rational)
    }
    
    public static func +=(lhs: inout Rational, rhs: Int) {
        lhs.ensureUnique()
        
        __gmpq_add(&lhs.rational_impl.rational, &lhs.rational_impl.rational, &Rational(rhs).rational_impl.rational)
    }
    
    public static func +=(lhs: inout Rational, rhs: UInt) {
        lhs.ensureUnique()
        
        __gmpq_add(&lhs.rational_impl.rational, &lhs.rational_impl.rational, &Rational(rhs).rational_impl.rational)
    }
    
    //
    // Subtraction
    //
    public static func -(lhs: Rational, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational_impl.rational, &lhs.rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func -(lhs: Int, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational_impl.rational, &Rational(lhs).rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func -(lhs: Rational, rhs: Int) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational_impl.rational, &lhs.rational_impl.rational, &Rational(rhs).rational_impl.rational)
        
        return result
    }
    
    public static func -(lhs: UInt, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational_impl.rational, &Rational(lhs).rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func -(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational_impl.rational, &lhs.rational_impl.rational, &Rational(rhs).rational_impl.rational)
        
        return result
    }
    
    public static func -=(lhs: inout Rational, rhs: Rational) {
        lhs.ensureUnique()
        
        __gmpq_sub(&lhs.rational_impl.rational, &lhs.rational_impl.rational, &rhs.rational_impl.rational)
    }
    
    public static func -=(lhs: inout Rational, rhs: Int) {
        lhs.ensureUnique()
        
        __gmpq_sub(&lhs.rational_impl.rational, &lhs.rational_impl.rational, &Rational(rhs).rational_impl.rational)
    }
    
    public static func -=(lhs: inout Rational, rhs: UInt) {
        lhs.ensureUnique()
        
        __gmpq_sub(&lhs.rational_impl.rational, &lhs.rational_impl.rational, &Rational(rhs).rational_impl.rational)
    }
    
    //
    // Multipication
    //
    public static func *(lhs: Rational, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_mul(&result.rational_impl.rational, &lhs.rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func *(lhs: Rational, rhs: BigInt) -> Rational {
        let result = lhs
        
        __gmpz_mul(&result.rational_impl.rational._mp_num, &result.rational_impl.rational._mp_num, &rhs.integer)
        __gmpq_canonicalize(&result.rational_impl.rational)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: Rational) -> Rational {
        let result = rhs
        
        __gmpz_mul(&result.rational_impl.rational._mp_num, &lhs.integer, &result.rational_impl.rational._mp_num)
        __gmpq_canonicalize(&result.rational_impl.rational)
        
        return result
    }
    
    public static func *(lhs: Rational, rhs: Int) -> Rational {
        let result = Rational(rhs)
        
        __gmpq_mul(&result.rational_impl.rational, &lhs.rational_impl.rational, &result.rational_impl.rational)
        
        return result
    }
    
    public static func *(lhs: Int, rhs: Rational) -> Rational {
        let result = Rational(lhs)
        
        __gmpq_mul(&result.rational_impl.rational, &result.rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func *(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational(rhs)
        
        __gmpq_mul(&result.rational_impl.rational, &lhs.rational_impl.rational, &result.rational_impl.rational)
        
        return result
    }
    
    public static func *(lhs: UInt, rhs: Rational) -> Rational {
        let result = Rational(lhs)
        
        __gmpq_mul(&result.rational_impl.rational, &result.rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func *=(lhs: inout Rational, rhs: Rational) {
        lhs.ensureUnique()
        
        __gmpq_mul(&lhs.rational_impl.rational, &lhs.rational_impl.rational, &rhs.rational_impl.rational)
    }
    
    public static func *=(lhs: inout Rational, rhs: Int) {
        lhs.ensureUnique()
        
        __gmpz_mul_si(&lhs.rational_impl.rational._mp_num, &lhs.rational_impl.rational._mp_num, rhs)
        __gmpq_canonicalize(&lhs.rational_impl.rational)
    }
    
    public static func *=(lhs: inout Rational, rhs: UInt) {
        lhs.ensureUnique()
        
        __gmpz_mul_ui(&lhs.rational_impl.rational._mp_num, &lhs.rational_impl.rational._mp_num, rhs)
        __gmpq_canonicalize(&lhs.rational_impl.rational)
    }
    
    //
    // Division
    //
    public static func /(lhs: Rational, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_div(&result.rational_impl.rational, &lhs.rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func /(lhs: Rational, rhs: Int) -> Rational {
        let result = Rational(rhs)
        
        __gmpq_div(&result.rational_impl.rational, &lhs.rational_impl.rational, &result.rational_impl.rational)
        
        return result
    }
    
    public static func /(lhs: Int, rhs: Rational) -> Rational {
        let result = Rational(lhs)
        
        __gmpq_div(&result.rational_impl.rational, &result.rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func /(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational(rhs)
        
        __gmpq_div(&result.rational_impl.rational, &lhs.rational_impl.rational, &result.rational_impl.rational)
        
        return result
    }
    
    public static func /(lhs: UInt, rhs: Rational) -> Rational {
        let result = Rational(lhs)
        
        __gmpq_div(&result.rational_impl.rational, &result.rational_impl.rational, &rhs.rational_impl.rational)
        
        return result
    }
    
    public static func /=(lhs: inout Rational, rhs: Rational) {
        lhs.ensureUnique()
        
        __gmpq_div(&lhs.rational_impl.rational, &lhs.rational_impl.rational, &rhs.rational_impl.rational)
    }
    
    public static func /=(lhs: inout Rational, rhs: Int) {
        lhs.ensureUnique()
        
        __gmpz_mul_si(&lhs.rational_impl.rational._mp_den, &lhs.rational_impl.rational._mp_den, rhs)
        __gmpq_canonicalize(&lhs.rational_impl.rational)
    }
    
    public static func /=(lhs: inout Rational, rhs: UInt) {
        lhs.ensureUnique()
        
        __gmpz_mul_ui(&lhs.rational_impl.rational._mp_den, &lhs.rational_impl.rational._mp_den, rhs)
        __gmpq_canonicalize(&lhs.rational_impl.rational)
    }
    
    //
    // Exponentation
    //
    public static func **(lhs: Rational, rhs: UInt) -> Rational {
        let result = Rational()
        
        __gmpz_pow_ui(&result.rational_impl.rational._mp_num, &lhs.rational_impl.rational._mp_num, rhs)
        __gmpz_pow_ui(&result.rational_impl.rational._mp_den, &lhs.rational_impl.rational._mp_den, rhs)
        __gmpq_canonicalize(&result.rational_impl.rational)
        
        return result
    }
}

