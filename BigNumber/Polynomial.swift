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
public struct Polynomial: SignedNumeric, ExpressibleByArrayLiteral {
    // TODO: Implement normalizing function, a bookkeeping function that removes higher order zero coeffiecents or just [UInt]
    // TODO: Find a way to make Magnitude of Polynomial type.  Might have to create a struct heirarchy such that there's some concrete subclass
    
    public typealias Magnitude = Int
    public typealias IntegerLiteralType = Int
    public typealias ArrayLiteralElement = Rational
    
    // ivars
    ///////////
    public private(set) var coefficients: [Rational]
    
    public var order: Int {
        // TODO: Should return the last non-zero C
        return self.coefficients.count - 1
    }
    
    // Initializers
    //////////////////
    public init() {
        self.coefficients = [0]
    }
    
    public init(_ values: Rational...) {
        self.coefficients = values
    }
    
    public init(_ values: [Rational]) {
        self.coefficients = values
    }
    
    public init(integerLiteral value: Polynomial.IntegerLiteralType) {
        self.coefficients = [Rational(value)]
    }
    
    public init(arrayLiteral elements: Polynomial.ArrayLiteralElement...) {
        self.coefficients = elements
    }
    
    public init?<S>(exactly source: S) where S : BinaryInteger {
        return nil
    }
    
    //
    /////////////
    public func getValue(_ x: BigInt) -> Rational {
        var output: Rational = 0
        
        for (i, el) in self.enumerated() {
            output += el * (x ** UInt(i))
        }
        
        return output
    }
    
    // Internals
    ///////////////
    private func normalize() {
        // remove excess higher order zeros
    }
    
    // Subscript
    //////////////
    public subscript(index: Array<Rational>.Index) -> Rational {
        get {
            return self.coefficients[index]
        }
        
        set {
            self.coefficients[index] = newValue
        }
    }
    
    // Sequence
    //////////////
    public func enumerated() -> EnumeratedSequence<[Rational]> {
        return self.coefficients.enumerated()
    }
    
    //
    // MARK : Arthimetic
    //
    public var magnitude: Polynomial.Magnitude {
        return self.order
    }
    
    // Negate
    ///////////
    public mutating func negate() {
        self *= Rational(-1)
    }
    
    public prefix static func -(operand: Polynomial) -> Polynomial {
        return operand * -1
    }
    
    // Addition
    /////////////
    public static func +(lhs: Polynomial, rhs: Polynomial) -> Polynomial {
        var output: [Rational] = Array(repeatElement(0, count: max(lhs.coefficients.count, rhs.coefficients.count)))
        
        for (i, el) in lhs.enumerated() {
            output[i] += el
        }
        for (i, el) in rhs.enumerated() {
            output[i] += el
        }
        
        return Polynomial(output)
    }
    
    public static func +(lhs: Polynomial, rhs: Rational) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        output[0] += rhs
        return output
    }
    
    public static func +(lhs: Rational, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        output[0] += lhs
        return output
    }
    
    public static func +=(lhs: inout Polynomial, rhs: Polynomial) {
        let lhs_last_idx = lhs.coefficients.count - 1
        for (i, el) in rhs.enumerated() {
            if i > lhs_last_idx {
                lhs.coefficients.append(el)
            } else {
                lhs[i] += el
            }
        }
    }
    
    public static func +=(lhs: inout Polynomial, rhs: Rational) {
        lhs[0] += rhs
    }
    
    // Multiplication
    ///////////////////
    public static func *(lhs: Polynomial, rhs: Polynomial) -> Polynomial {
        var output: [Rational] = []
        for _ in 0...(lhs.coefficients.count + rhs.coefficients.count - 2) {
            output.append(Rational(0))
        }
        
        for (i, l) in lhs.enumerated() {
            for (j, r) in rhs.enumerated() {
                output[i+j] += l * r
            }
        }
        
        return Polynomial(output)
    }
    
    public static func *(lhs: Polynomial, rhs: Rational) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        for i in 0..<output.coefficients.count {
            output[i] *= rhs
        }
        return output
    }
    
    public static func *(lhs: Rational, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        for i in 0..<output.coefficients.count {
            output[i] *= lhs
        }
        return output
    }
    
    public static func *(lhs: Polynomial, rhs: Int) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        for i in 0..<output.coefficients.count {
            output[i] *= rhs
        }
        return output
    }
    
    public static func *(lhs: Int, rhs: Polynomial) -> Polynomial {
        var output = Polynomial(rhs.coefficients)
        for i in 0..<output.coefficients.count {
            output[i] *= lhs
        }
        return output
    }
    
    public static func *=(lhs: inout Polynomial, rhs: Polynomial) {
        let max_idx = lhs.coefficients.count + rhs.coefficients.count - 1
        var new_coefficients: [Rational] = []
        for _ in 1...max_idx {
            new_coefficients.append(Rational(0))
        }
        
        for (i, l) in lhs.enumerated() {
            for (j, r) in rhs.enumerated() {
                new_coefficients[i+j] += l * r
            }
        }
        
        lhs.coefficients = new_coefficients
    }
    
    public static func *=(lhs: inout Polynomial, rhs: [Int]) {
        let max_idx = lhs.coefficients.count + rhs.count - 1
        var new_coefficients: [Rational] = []
        for _ in 1...max_idx {
            new_coefficients.append(Rational(0))
        }
        
        for (i, l) in lhs.enumerated() {
            for (j, r) in rhs.enumerated() {
                new_coefficients[i+j] += l * r
            }
        }
        
        lhs.coefficients = new_coefficients
    }
    
    public static func *=(lhs: inout Polynomial, rhs: [UInt]) {
        let max_idx = lhs.coefficients.count + rhs.count - 1
        var new_coefficients: [Rational] = []
        for _ in 1...max_idx {
            new_coefficients.append(Rational(0))
        }
        
        for (i, l) in lhs.enumerated() {
            for (j, r) in rhs.enumerated() {
                new_coefficients[i+j] += l * r
            }
        }
        
        lhs.coefficients = new_coefficients
    }
    
    public static func *=(lhs: inout Polynomial, rhs: Rational) {
        for i in 0..<lhs.coefficients.count {
            lhs[i] *= rhs
        }
    }
    
    
    // Subtraction
    ////////////////
    public static func -(lhs: Polynomial, rhs: Polynomial) -> Polynomial {
        var output: [Rational] = Array(repeatElement(0, count: max(lhs.coefficients.count, rhs.coefficients.count)))
        
        for (i, el) in lhs.enumerated() {
            output[i] += el
        }
        for (i, el) in rhs.enumerated() {
            output[i] -= el
        }
        
        return Polynomial(output)
    }
    
    public static func -(lhs: Polynomial, rhs: Rational) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        output[0] -= rhs
        return output
    }
    
    public static func -=(lhs: inout Polynomial, rhs: Polynomial) {
        let lhs_last_idx = lhs.coefficients.count - 1
        for (i, el) in rhs.enumerated() {
            if i > lhs_last_idx {
                lhs.coefficients.append(-el)
            } else {
                lhs[i] -= el
            }
        }
    }
    
    public static func -=(lhs: inout Polynomial, rhs: Rational) {
        lhs[0] -= rhs
    }
    
    public static func -=(lhs: inout Polynomial, rhs: Int) {
        lhs[0] -= rhs
    }
    
    public static func -=(lhs: inout Polynomial, rhs: UInt) {
        lhs[0] -= rhs
    }
    
    // Divison
    ///////////////////
    public static func /(lhs: Polynomial, rhs: Rational) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        for i in 0..<lhs.coefficients.count {
            output[i] /= rhs
        }
        return output
    }
    
    public static func /(lhs: Polynomial, rhs: Int) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        for i in 0..<lhs.coefficients.count {
            output[i] /= rhs
        }
        return output
    }
    
    public static func /(lhs: Polynomial, rhs: UInt) -> Polynomial {
        var output = Polynomial(lhs.coefficients)
        for i in 0..<lhs.coefficients.count {
            output[i] /= rhs
        }
        return output
    }
    
    public static func /=(lhs: inout Polynomial, rhs: Rational) {
        for i in 0..<lhs.coefficients.count {
            lhs[i] /= rhs
        }
    }
    
    public static func /=(lhs: inout Polynomial, rhs: Int) {
        for i in 0..<lhs.coefficients.count {
            lhs[i] /= rhs
        }
    }
    
    public static func /=(lhs: inout Polynomial, rhs: UInt) {
        for i in 0..<lhs.coefficients.count {
            lhs[i] /= rhs
        }
    }
    
    //
    // MARK: Comparable
    //
    public static func <(lhs: Polynomial, rhs: Polynomial) -> Bool {
        return lhs.coefficients.count < rhs.coefficients.count
    }
    
    public static func <=(lhs: Polynomial, rhs: Polynomial) -> Bool {
        return lhs.coefficients.count <= rhs.coefficients.count
    }
    
    public static func >(lhs: Polynomial, rhs: Polynomial) -> Bool {
        return lhs.coefficients.count < rhs.coefficients.count
    }
    
    public static func >=(lhs: Polynomial, rhs: Polynomial) -> Bool {
        return lhs.coefficients.count >= rhs.coefficients.count
    }
    
    public static func ==(lhs: Polynomial, rhs: Polynomial) -> Bool {
        return lhs.coefficients == rhs.coefficients
    }
    
    public static func !=(lhs: Polynomial, rhs: Polynomial) -> Bool {
        return lhs.coefficients != rhs.coefficients
    }
}
