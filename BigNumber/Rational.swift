//
//  Rational.swift
//  BigNumber
//
//  Created by Spizzace on 8/27/17.
//  Copyright © 2017 SpaiceMaine. All rights reserved.
//

import GMP

public final class Rational: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, LosslessStringConvertible {
    //
    // constants
    //
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    
    //
    // ivars
    //
    internal var rational: mpq_t
    
    public var numerator: BigInt {
        get {
            let result = BigInt()
            
            __gmpq_get_num(&result.integer, &self.rational)
            
            return result
        }
    
        set {
            __gmpq_set_num(&self.rational, &newValue.integer)
        }
    }
    
    public var denominator: BigInt {
        get {
            let result = BigInt()
            
            __gmpq_get_den(&result.integer, &self.rational)
            
            return result
        }
        
        set {
            __gmpq_set_den(&self.rational, &newValue.integer)
        }
    }
    
    //
    // Initalizers
    //
    public required init() {
        self.rational = mpq_t()
        __gmpq_init(&self.rational)
    }
    
    public required init(integerLiteral value: Rational.IntegerLiteralType) {
        self.rational = mpq_t()
        __gmpq_init(&self.rational)
        __gmpq_set_si(&self.rational, value, 1)
        __gmpq_canonicalize(&self.rational)
    }
    
    public required init(floatLiteral value: Rational.FloatLiteralType) {
        self.rational = mpq_t()
        __gmpq_init(&self.rational)
        __gmpq_set_d(&self.rational, value)
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
    
    public func toDouble() -> Double? {
        return __gmpq_get_d(&self.rational)
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
    
    //
    // isLessThan
    public static func <(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational, &rhs.rational) < 0
    }
    
    public static func <(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational, &rhs.integer) < 0
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
    
    //
    // isGreaterThan
    // 
    public static func >(lhs: Rational, rhs: Rational) -> Bool {
        return __gmpq_cmp(&lhs.rational, &rhs.rational) > 0
    }
    
    public static func >(lhs: Rational, rhs: BigInt) -> Bool {
        return __gmpq_cmp_z(&lhs.rational, &rhs.integer) > 0
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
    
    public static func +=(lhs: inout Rational, rhs: Rational) {
        let result = Rational()
        
        __gmpq_add(&result.rational, &lhs.rational, &rhs.rational)
        
        __gmpq_set(&lhs.rational, &result.rational)
    }
    
    //
    // Subtraction
    //
    public static func -(lhs: Rational, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_sub(&result.rational, &lhs.rational, &rhs.rational)
        
        return result
    }
    
    public static func -=(lhs: inout Rational, rhs: Rational) {
        let result = Rational()
        
        __gmpq_sub(&result.rational, &lhs.rational, &rhs.rational)
        
        __gmpq_set(&lhs.rational, &result.rational)
    }
    
    //
    // Multipication
    //
    public static func *(lhs: Rational, rhs: Rational) -> Rational {
        let result = Rational()
        
        __gmpq_mul(&result.rational, &lhs.rational, &rhs.rational)
        
        return result
    }
    
    public static func *=(lhs: inout Rational, rhs: Rational) {
        let result = Rational()
        
        __gmpq_mul(&result.rational, &lhs.rational, &rhs.rational)
        
        __gmpq_set(&lhs.rational, &result.rational)
    }
}
