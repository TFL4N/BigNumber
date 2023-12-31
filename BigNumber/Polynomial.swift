//
//  Polynomial.swift
//  BigNumber
//
//  Created by Spizzace on 3/16/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

//
// MARK: Polynomial
//
public struct Polynomial<Coefficient:SignedNumeric>: SignedNumeric, ExpressibleByDictionaryLiteral, ExpressibleByArrayLiteral, CustomStringConvertible {
    // TODO: Find a way to make Magnitude of Polynomial type.  Might have to create a struct heirarchy such that there's some concrete subclass
    public typealias Magnitude = Int
    public typealias IntegerLiteralType = Coefficient.IntegerLiteralType
    public typealias Key = UInt
    public typealias Value = Coefficient
    public typealias ArrayLiteralElement = Coefficient
    public typealias ElementsType = [Key:Value]
    
    // constants
    //////////////
    private var default_value: Coefficient {
        return Coefficient(exactly: 0)!
    }
    
    // ivars
    ///////////
    public private(set) var coefficients: [UInt:Coefficient]
    
    public var order: UInt {
        return self.coefficients.keys.max() ?? 0
    }
    
    public var description: String {
        var output = "["
        
        for k in self.coefficients.keys.sorted() {
            output += "\(k) : "
            output += "\(self.coefficients[k]!), "
        }
        
        output.removeLast(2)
        
        output += "]"
        
        return output
    }
    
    // Initializers
    //////////////////
    public init() {
        self.coefficients = [0:Coefficient(exactly: 0)!]
    }
    
    public init(_ coefficient: Coefficient, _ exponent: UInt) {
        self.coefficients = [exponent: coefficient]
    }
    
    public init(_ values: ElementsType) {
        self.coefficients = values
    }
    
    public init(_ values: [Polynomial.ArrayLiteralElement]) {
        var output = ElementsType()
        
        var index: UInt = 0
        for el in values {
            output[index] = el
            index += 1
        }
        
        self.coefficients = output
    }
    
    public init(integerLiteral value: Polynomial.IntegerLiteralType) {
        self.coefficients = [0:Coefficient.init(integerLiteral: value)]
    }
    
    public init(arrayLiteral elements: Polynomial.ArrayLiteralElement...) {
        self.init(elements)
    }
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        var output = ElementsType()
        for (k,v) in elements {
            output[k] = v
        }
        
        self.init(output)
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let n = Coefficient.init(exactly: source) else {
            return nil
        }
        self.init([0:n])
    }

    //
    ///////////
    /**
     */
    public mutating func normalize() {
        self.coefficients = self.coefficients.filter({ (pair) -> Bool in
            return pair.value != 0
        })
    }
    
    // Subscript
    //////////////
    public subscript(index: Key) -> Coefficient? {
        get {
            return self.coefficients[index]
        }
        
        set {
            self.coefficients[index] = newValue
        }
    }
    
    //
    // MARK : Arthimetic
    //
    public var magnitude: Polynomial.Magnitude {
        return Int(self.coefficients.keys.max() ?? 0)
    }
    
    // Negate
    ///////////
    public mutating func negate() {
        self.coefficients.forEach {
            self.coefficients[$0.key]!.negate()
        }
    }
    
    public prefix static func -(operand: Polynomial) -> Polynomial {
        return operand * -1
    }
    
    // Addition
    /////////////
    public static func +(lhs: Polynomial, rhs: Polynomial) -> Polynomial {
        var output = lhs.coefficients
        for (k, v) in rhs.coefficients {
            output[k, default: lhs.default_value] += v
        }
        
        return Polynomial(output)
    }
    
    public static func +(lhs: Polynomial, rhs: Coefficient) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        output.coefficients[0, default: lhs.default_value] += rhs
        return output
    }
    
    public static func +(lhs: Coefficient, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        output.coefficients[0, default: rhs.default_value] += lhs
        return output
    }
    

    public static func +=(lhs: inout Polynomial, rhs: Polynomial) {
        for (k,v) in rhs.coefficients {
            lhs.coefficients[k, default: lhs.default_value] += v
        }
    }
        
    public static func +=(lhs: inout Polynomial, rhs: Coefficient) {
        lhs.coefficients[0, default: lhs.default_value] += rhs
    }
    
    // Subtraction
    ////////////////
    public static func -(lhs: Polynomial, rhs: Polynomial) -> Polynomial {
        var output = lhs.coefficients
        for (k, v) in rhs.coefficients {
            output[k, default: lhs.default_value] -= v
        }
        
        return Polynomial(output)
    }
    
    public static func -(lhs: Polynomial, rhs: Coefficient) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        output.coefficients[0, default: lhs.default_value] -= rhs
        return output
    }
    
    public static func -(lhs: Coefficient, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        output.coefficients[0, default: rhs.default_value] -= lhs
        return output
    }
    
    public static func -=(lhs: inout Polynomial, rhs: Polynomial) {
        for (k,v) in rhs.coefficients {
            lhs.coefficients[k, default: lhs.default_value] -= v
        }
    }
    
    public static func -=(lhs: inout Polynomial, rhs: Coefficient) {
        lhs.coefficients[0, default: lhs.default_value] -= rhs
    }

    // Multiplication
    ///////////////////
    public static func *(lhs: Polynomial, rhs: Polynomial) -> Polynomial {
        var output = ElementsType()
        
        for (kl, vl) in lhs.coefficients {
            for (kr, vr) in rhs.coefficients {
                output[kl+kr, default: lhs.default_value] += vl * vr
            }
        }
        
        return Polynomial(output)
    }
    
    public static func *(lhs: Polynomial, rhs: Coefficient) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! *= rhs
        }
        
        return output
    }
    
    public static func *(lhs: Coefficient, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! *= lhs
        }
        
        return output
    }
    
    public static func *=(lhs: inout Polynomial, rhs: Polynomial) {
        var output = ElementsType()
        
        for (kl, vl) in lhs.coefficients {
            for (kr, vr) in rhs.coefficients {
                output[kl+kr, default: lhs.default_value] += vl * vr
            }
        }
        
        lhs.coefficients = output
    }
    
    
    //
    // MARK: Comparable
    //
//    public static func <(lhs: Polynomial, rhs: Polynomial) -> Bool {
//        return lhs.coefficients.count < rhs.coefficients.count
//    }
//
//    public static func <=(lhs: Polynomial, rhs: Polynomial) -> Bool {
//        return lhs.coefficients.count <= rhs.coefficients.count
//    }
//
//    public static func >(lhs: Polynomial, rhs: Polynomial) -> Bool {
//        return lhs.coefficients.count < rhs.coefficients.count
//    }
//
//    public static func >=(lhs: Polynomial, rhs: Polynomial) -> Bool {
//        return lhs.coefficients.count >= rhs.coefficients.count
//    }
    
    public static func ==(lhs: Polynomial, rhs: Polynomial) -> Bool {
        return lhs.coefficients == rhs.coefficients
    }
    
    public static func !=(lhs: Polynomial, rhs: Polynomial) -> Bool {
        return lhs.coefficients != rhs.coefficients
    }
}

public extension Polynomial where Coefficient : IntegerArithmetic {
    // Addition
    ///////////////
    public static func +(lhs: Polynomial, rhs: Int) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        output.coefficients[0, default: lhs.default_value] += rhs
        return output
    }
    
    public static func +(lhs: Int, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        output.coefficients[0, default: rhs.default_value] += lhs
        return output
    }
    
    public static func +=(lhs: inout Polynomial, rhs: Int) {
        lhs.coefficients[0, default: lhs.default_value] += rhs
    }
    
    // Subtraction
    //////////////////
    public static func -(lhs: Polynomial, rhs: Int) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        output.coefficients[0, default: lhs.default_value] -= rhs
        return output
    }
    
    public static func -(lhs: Int, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        output.coefficients[0, default: rhs.default_value] -= lhs
        return output
    }
    
    public static func -=(lhs: inout Polynomial, rhs: Int) {
        lhs.coefficients[0, default: lhs.default_value] -= rhs
    }
    
    // Multiplication
    ///////////////////
    public static func *(lhs: Polynomial, rhs: Int) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! *= rhs
        }
        
        return output
    }
    
    public static func *(lhs: Int, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! *= lhs
        }
        
        return output
    }
    
    public static func *=(lhs: inout Polynomial, rhs: Int) {
        lhs.coefficients[0, default: lhs.default_value] *= rhs
    }
    
    // Divison
    ///////////////////
    public static func /(lhs: Polynomial, rhs: Int) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! /= rhs
        }
        
        return output
    }
    
    public static func /(lhs: Int, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! /= lhs
        }
        
        return output
    }
    
    public static func /=(lhs: inout Polynomial, rhs: Int) {
        lhs.coefficients[0, default: lhs.default_value] /= rhs
    }
}

public extension Polynomial where Coefficient : UnsignedIntegerArithmetic {
    // Addition
    ///////////////
    public static func +(lhs: Polynomial, rhs: UInt) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        output.coefficients[0, default: lhs.default_value] += rhs
        return output
    }
    
    public static func +(lhs: UInt, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        output.coefficients[0, default: rhs.default_value] += lhs
        return output
    }
    
    public static func +=(lhs: inout Polynomial, rhs: UInt) {
        lhs.coefficients[0, default: lhs.default_value] += rhs
    }
    
    // Subtraction
    //////////////////
    public static func -(lhs: Polynomial, rhs: UInt) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        output.coefficients[0, default: lhs.default_value] -= rhs
        return output
    }
    
    public static func -(lhs: UInt, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        output.coefficients[0, default: rhs.default_value] -= lhs
        return output
    }
    
    public static func -=(lhs: inout Polynomial, rhs: UInt) {
        lhs.coefficients[0, default: lhs.default_value] -= rhs
    }
    
    // Multiplication
    ///////////////////
    public static func *(lhs: Polynomial, rhs: UInt) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! *= rhs
        }
        
        return output
    }
    
    public static func *(lhs: UInt, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! *= lhs
        }
        
        return output
    }
    
    public static func *=(lhs: inout Polynomial, rhs: UInt) {
        lhs.coefficients[0, default: lhs.default_value] *= rhs
    }
    
    // Divison
    ///////////////////
    public static func /(lhs: Polynomial, rhs: UInt) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! /= rhs
        }
        
        return output
    }
    
    public static func /(lhs: UInt, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        
        output.coefficients.forEach {
            output.coefficients[$0.key]! /= lhs
        }
        
        return output
    }
    
    public static func /=(lhs: inout Polynomial, rhs: UInt) {
        lhs.coefficients[0, default: lhs.default_value] /= rhs
    }
}

public extension Polynomial where Coefficient : UnsignedIntegerArithmetic {
    public func getValue(_ x: Coefficient) -> Coefficient {
        var output: Coefficient = 0
        
        for (k, v) in self.coefficients {
            output += v * fastExponentation(x,k)
        }
        
        return output
    }
    
    public func derivative() -> Polynomial {
        var output = Polynomial()
        
        for (k,v) in self.coefficients {
            if k == 0 {
                continue
            }
            
            output.coefficients[k-1, default: output.default_value] = v * k
        }
        
        return output
    }
    
    public func integral() -> Polynomial {
        var output = Polynomial()
        
        for (k,v) in self.coefficients {            
            let new_k = k+1
            output.coefficients[new_k] = v / new_k
        }
        
        return output
    }
    
    public func integral(min: Coefficient, max: Coefficient) -> Coefficient {
        let integral_result = self.integral()
        
        return integral_result.getValue(max) - integral_result.getValue(min)
    }
}
