//
//  NumericExtended.swift
//  BigNumber
//
//  Created by Spizzace on 3/16/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

public protocol NumericExtended: Numeric, Comparable {
    static func /(lhs: Self, rhs: Self) -> Self
    static func /=(lhs: inout Self, rhs: Self)
}

public protocol SignedNumericExtended: NumericExtended, SignedNumeric {}

extension Rational: NumericExtended {}
extension BigInt: NumericExtended {}
extension Int: NumericExtended {}
extension UInt: NumericExtended {}

//
//
//
public protocol IntegerArithmetic {
    static func +(lhs: Self, rhs: Int) -> Self
    static func +=(lhs: inout Self, rhs: Int)
    
    static func -(lhs: Self, rhs: Int) -> Self
    static func -=(lhs: inout Self, rhs: Int)
    
    static func *(lhs: Self, rhs: Int) -> Self
    static func *=(lhs: inout Self, rhs: Int)
    
    static func /(lhs: Self, rhs: Int) -> Self
    static func /=(lhs: inout Self, rhs: Int)
}

extension Rational: IntegerArithmetic {}
extension BigInt: IntegerArithmetic {}
extension BigFloat: IntegerArithmetic {}

//
//
//
public protocol UnsignedIntegerArithmetic {
    static func +(lhs: Self, rhs: UInt) -> Self
    static func +=(lhs: inout Self, rhs: UInt)
    
    static func -(lhs: Self, rhs: UInt) -> Self
    static func -=(lhs: inout Self, rhs: UInt)
    
    static func *(lhs: Self, rhs: UInt) -> Self
    static func *=(lhs: inout Self, rhs: UInt)
    
    static func /(lhs: Self, rhs: UInt) -> Self
    static func /=(lhs: inout Self, rhs: UInt)
}

extension Rational: UnsignedIntegerArithmetic {}
extension BigInt: UnsignedIntegerArithmetic {}
extension BigFloat: UnsignedIntegerArithmetic {}
extension Polynomial: UnsignedIntegerArithmetic where Coefficient : UnsignedIntegerArithmetic {}
extension Double: UnsignedIntegerArithmetic {
    public static func + (lhs: Double, rhs: UInt) -> Double {
        return lhs + Double(rhs)
    }
    
    public static func += (lhs: inout Double, rhs: UInt) {
        lhs += Double(rhs)
    }
    
    public static func - (lhs: Double, rhs: UInt) -> Double {
        return lhs + Double(rhs)
    }
    
    public static func -= (lhs: inout Double, rhs: UInt) {
        lhs += Double(rhs)
    }
    
    public static func * (lhs: Double, rhs: UInt) -> Double {
        return lhs * Double(rhs)
    }
    
    public static func *= (lhs: inout Double, rhs: UInt) {
        lhs *= Double(rhs)
    }
    
    public static func / (lhs: Double, rhs: UInt) -> Double {
        return lhs / Double(rhs)
    }
    
    public static func /= (lhs: inout Double, rhs: UInt) {
        lhs /= Double(rhs)
    }
}

//
//
//
public protocol ExponentialArthmetic {
    static func **(lhs: Self, rhs: UInt) -> Self
}

extension Rational: ExponentialArthmetic {}
extension BigInt: ExponentialArthmetic {}
