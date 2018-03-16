//
//  NumericExtended.swift
//  BigNumber
//
//  Created by Spizzace on 3/16/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

public protocol NumericExtended: Numeric {
    static func /(lhs: Self, rhs: Self) -> Self
    static func /=(lhs: inout Self, rhs: Self)
}

public protocol SignedNumericExtended: NumericExtended, SignedNumeric {}

//public extension Rational: NumericExtended {}
//public extension BigInt: NumericExtended {}
//public extension Int: NumericExtended {}
//public extension UInt: NumericExtended {}

