//
//  BigInt.swift
//  BigNumber
//
//  Created by Spizzace on 8/19/17.
//  Copyright © 2017 SpaiceMaine. All rights reserved.
//

import GMP

//
// MARK: Exponentiation
//
precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ** : PowerPrecedence
infix operator **= : PowerPrecedence

//
// BigInt
//
internal final class BigIntImpl {
    //
    // ivars
    //
    public var integer: mpz_t
    
    // User is responsible for releasing the pointer
    public var integer_ptr: UnsafeMutablePointer<mpz_t> {
        let pointer = UnsafeMutablePointer<mpz_t>.allocate(capacity: 1)
        pointer.initialize(to: self.integer)
        
        return pointer
    }
    
    //
    // Initalizers
    //
    public required init() {
        self.integer = mpz_t()
        __gmpz_init(&self.integer)
    }
    
    //
    // deinit
    //
    deinit {
        __gmpz_clear(&self.integer)
    }
    
    //
    // Copying
    //
    internal func copy() -> BigIntImpl {
        let new_copy = BigIntImpl()
        __gmpz_set(&new_copy.integer, &self.integer)
        
        return new_copy
    }
    
    //
    // Memory
    //
    internal func reallocateToSize() {
        let bit_count = __gmpz_sizeinbase(&self.integer, 2)
        __gmpz_realloc2(&self.integer, mp_bitcnt_t(bit_count))
    }
}


public struct BigInt: SignedInteger, ExpressibleByIntegerLiteral, LosslessStringConvertible {    
    //
    // constants
    //
    public typealias IntegerLiteralType = Int
    public typealias Words = [UInt]
    
    public static var isSigned: Bool = true
    
    //
    // ivars
    //
    internal var integer_impl: BigIntImpl
    public var integer_ptr: UnsafeMutablePointer<mpz_t> {
        return self.integer_impl.integer_ptr
    }
    
    // Binary Integer
    public var words: [UInt] {
        let buffer = UnsafeBufferPointer(start: self.integer_impl.integer._mp_d,
                                         count: Int(self.integer_impl.integer._mp_size));
        return Array(buffer)
    }
    
    public var bitWidth: Int {
        return __gmpz_sizeinbase(&self.integer_impl.integer, 2)
    }
    
    public var trailingZeroBitCount: Int {
        return Int(__gmpz_scan1(&self.integer_impl.integer, 0))
    }
    
    //
    // Initalizers
    //
    public init() {
       self.integer_impl = BigIntImpl()
        __gmpz_set_si(&self.integer_impl.integer, 0)
    }
    
    public init(_ n: UnsafeMutablePointer<mpz_t>) {
        self.integer_impl = BigIntImpl()
        __gmpz_set(&self.integer_impl.integer, n)
    }
    
    public init(integerLiteral value: BigInt.IntegerLiteralType) {
        self.integer_impl = BigIntImpl()
        __gmpz_set_si(&self.integer_impl.integer, value)
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        self.init(Int(source))
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.init(Int(source))
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        if let s = UInt(exactly: source) {
            self.init(s)
            return
        }
        
        return nil
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(UInt(source))
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.init(source)
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.init(UInt(truncatingIfNeeded: source))
    }
    
    public init(_ integer: UInt) {
        self.init()
        __gmpz_set_ui(&self.integer_impl.integer, integer)
    }
    
    public init(_ integer: Int) {
        self.init()
        __gmpz_set_si(&self.integer_impl.integer, integer)
    }
    
    public init(_ double: Double) {
        self.init()
        __gmpz_set_d(&self.integer_impl.integer, double)
    }
    
    public init(_ rational: Rational) {
        self.init()
        __gmpz_set_q(&self.integer_impl.integer, &rational.rational_impl.rational)
    }
    
    public init?(_ string: String) {
        self.init(string: string, base: 10)
    }
    
    public init?(string:String, base: Int32) {
        self.init()
        
        let result = string.withCString { __gmpz_set_str(&self.integer_impl.integer, $0, base) }
        
        if result != 0 {
            return nil
        }
    }
    
    //
    // Memory Management
    //
    internal mutating func ensureUnique() {
        if !isKnownUniquelyReferenced(&self.integer_impl) {
            self.integer_impl = self.integer_impl.copy()
        }
    }
    
    //
    // CustomStringConvertible
    //
    public var description: String {
        return self.toString()
    }
    
    //
    // Assignments
    //
    public mutating func set(_ integer: BigInt) {
        self.ensureUnique()
        
        __gmpz_set(&self.integer_impl.integer, &integer.integer_impl.integer)
    }
    
    public mutating func set(_ integer: UInt) {
        self.ensureUnique()
        
        __gmpz_set_ui(&self.integer_impl.integer, integer)
    }
    
    public mutating func set(_ integer: Int) {
        self.ensureUnique()
        
        __gmpz_set_si(&self.integer_impl.integer, integer)
    }
    
    public mutating func set(_ double: Double) {
        self.ensureUnique()
        
        __gmpz_set_d(&self.integer_impl.integer, double)
    }
    
    public mutating func set(_ rational: Rational) {
        self.ensureUnique()
        
        __gmpz_set_q(&self.integer_impl.integer, &rational.rational_impl.rational)
    }
    
    //
    // Misc
    //
    public func reallocateToSize() {
        self.integer_impl.reallocateToSize()
    }
    
    public func signum() -> Int {
        let x = __gmpz_cmp_ui(&self.integer_impl.integer, 0)
        if x < 0 {
            return -1
        } else if x > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    public func isOdd() -> Bool {
        return self.integer_impl.integer._mp_d.pointee % 2 == 1
    }
    
    public func isEven() -> Bool {
        return self.integer_impl.integer._mp_d.pointee % 2 == 0
    }
}

//
// MARK: SignInteger
//
extension BigInt: SignedNumeric {
    // Sign Numeric
    prefix public static func -(operand: BigInt) -> BigInt {
        var result = operand
        result.ensureUnique()
        
        __gmpz_neg(&result.integer_impl.integer, &result.integer_impl.integer)
        
        return result
    }
    
    public mutating func negate() {
        self.ensureUnique()
        
        __gmpz_neg(&self.integer_impl.integer, &self.integer_impl.integer)
    }
    
    // Numeric
    public typealias Magnitude = BigInt
    
    public var magnitude: BigInt {
        var result = self
        result.ensureUnique()
        
        __gmpz_abs(&result.integer_impl.integer, &result.integer_impl.integer)
        
        return result
    }
    
    prefix public static func +(x: BigInt) -> BigInt {
        return x
    }
}

// Hashable
extension BigInt: Hashable {    
    public func hash(into hasher: inout Hasher) {
        let size = __gmpz_size(&self.integer_impl.integer)
        let limb_pointer = __gmpz_limbs_read(&self.integer_impl.integer)!
        
        for i in 0..<size {
            hasher.combine(limb_pointer.advanced(by: i).pointee)
        }
    }
}

//
// MARK: Stridable
//
extension BigInt: Strideable {
    public typealias Stride = BigInt
    
    public func distance(to other: BigInt) -> BigInt {
        return self - other
    }
    
    public func advanced(by n: BigInt) -> BigInt {
        return self + n
    }
}


//
// MARK: Convertibles
//
extension BigInt {
    public func toString(base: Int32) -> String? {
        if let r = __gmpz_get_str(nil, base, &self.integer_impl.integer) {
            return String(cString: r)
        } else {
            return nil
        }
    }
    
    public func toString() -> String {
        return self.toString(base: 10)!
    }
    
    public func toPrettyString() -> String {
        var str = self.toString(base: 10)!
        
        var count = str.count
        if self < 0 {
            count -= 1
        }
        var (q,r) = count.quotientAndRemainder(dividingBy: 3)
        
        if q == 0 {
            return str
        }
        
        if r == 0 {
            q -= 1
        }
        
        for x in (1...q).reversed() {
            let index = str.index(str.endIndex, offsetBy: -x*3)
            str.insert("_", at: index)
        }
        
        return  str
    }
    
    public func toInt() -> Int? {
        if __gmpz_fits_slong_p(&self.integer_impl.integer) != 0 {
            return __gmpz_get_si(&self.integer_impl.integer)
        } else {
            return nil
        }
    }
    
    public func toUInt() -> UInt? {
        if __gmpz_fits_ulong_p(&self.integer_impl.integer) != 0 {
            return __gmpz_get_ui(&self.integer_impl.integer)
        } else {
            return nil
        }
    }
    
    public func toDouble() -> Double? {
        if __gmpz_fits_ulong_p(&self.integer_impl.integer) != 0 {
            return __gmpz_get_d(&self.integer_impl.integer)
        } else {
            return nil
        }
    }
}

//
// MARK: Comparable/ Equatable
//
extension BigInt: Comparable, Equatable {
    //
    // isEqual
    //
    public static func ==(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer_impl.integer, &rhs.integer_impl.integer) == 0
    }
    
    public static func ==(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer_impl.integer, rhs) == 0
    }
    
    public static func ==(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer_impl.integer, lhs) == 0
    }
    
    public static func ==(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer_impl.integer, rhs) == 0
    }
    
    public static func ==(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer_impl.integer, lhs) == 0
    }
    
    public static func ==(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer_impl.integer, rhs) == 0
    }
    
    public static func ==(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer_impl.integer, lhs) == 0
    }
    
    //
    // isNotEqual
    //
    public static func !=(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer_impl.integer, &rhs.integer_impl.integer) != 0
    }
    
    public static func !=(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer_impl.integer, rhs) != 0
    }
    
    public static func !=(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer_impl.integer, lhs) != 0
    }
    
    public static func !=(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer_impl.integer, rhs) != 0
    }
    
    public static func !=(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer_impl.integer, lhs) != 0
    }
    
    public static func !=(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer_impl.integer, rhs) != 0
    }
    
    public static func !=(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer_impl.integer, lhs) != 0
    }
    
    //
    // isLessThan
    //
    public static func <(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer_impl.integer, &rhs.integer_impl.integer) < 0
    }
    
    public static func <(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer_impl.integer, rhs) < 0
    }
    
    public static func <(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer_impl.integer, lhs) > 0
    }
    
    public static func <(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer_impl.integer, rhs) < 0
    }
    
    public static func <(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer_impl.integer, lhs) > 0
    }
    
    public static func <(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer_impl.integer, rhs) < 0
    }
    
    public static func <(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer_impl.integer, lhs) > 0
    }
    
    //
    // isLessThanOrEqual
    //
    public static func <=(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer_impl.integer, &rhs.integer_impl.integer) <= 0
    }
    
    public static func <=(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer_impl.integer, rhs) <= 0
    }
    
    public static func <=(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer_impl.integer, lhs) >= 0
    }
    
    public static func <=(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer_impl.integer, rhs) <= 0
    }
    
    public static func <=(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer_impl.integer, lhs) >= 0
    }
    
    public static func <=(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer_impl.integer, rhs) <= 0
    }
    
    public static func <=(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer_impl.integer, lhs) >= 0
    }
    
    //
    // isGreaterThanOrEqual
    //
    public static func >=(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer_impl.integer, &rhs.integer_impl.integer) >= 0
    }
    
    public static func >=(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer_impl.integer, rhs) >= 0
    }
    
    public static func >=(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer_impl.integer, lhs) <= 0
    }
    
    public static func >=(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer_impl.integer, rhs) >= 0
    }
    
    public static func >=(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer_impl.integer, lhs) <= 0
    }
    
    public static func >=(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer_impl.integer, rhs) >= 0
    }
    
    public static func >=(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer_impl.integer, lhs) <= 0
    }
    
    //
    // isGreaterThan
    //
    public static func >(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer_impl.integer, &rhs.integer_impl.integer) > 0
    }
    
    public static func >(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer_impl.integer, rhs) > 0
    }
    
    public static func >(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer_impl.integer, lhs) < 0
    }
    
    public static func >(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer_impl.integer, rhs) > 0
    }
    
    public static func >(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer_impl.integer, lhs) < 0
    }
    
    public static func >(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer_impl.integer, rhs) > 0
    }
    
    public static func >(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer_impl.integer, lhs) < 0
    }
}

//
// MARK: Bitwise Operations
//
extension BigInt {
    public static prefix func ~(x: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_com(&result.integer_impl.integer,
                   &x.integer_impl.integer)
        
        return result
    }
    
    public static func &(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_and(&result.integer_impl.integer,
                   &lhs.integer_impl.integer,
                   &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func &=(lhs: inout BigInt, rhs: BigInt) {
        lhs.ensureUnique()
        
        __gmpz_and(&lhs.integer_impl.integer,
                   &lhs.integer_impl.integer,
                   &rhs.integer_impl.integer)
    }
    
    public static func |(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_ior(&result.integer_impl.integer,
                   &lhs.integer_impl.integer,
                   &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func |=(lhs: inout BigInt, rhs: BigInt) {
        lhs.ensureUnique()
        
        __gmpz_ior(&lhs.integer_impl.integer,
                   &lhs.integer_impl.integer,
                   &rhs.integer_impl.integer)
    }
    
    public static func ^(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_xor(&result.integer_impl.integer,
                   &lhs.integer_impl.integer,
                   &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func ^=(lhs: inout BigInt, rhs: BigInt) {
        lhs.ensureUnique()
        
        __gmpz_xor(&lhs.integer_impl.integer,
                   &lhs.integer_impl.integer,
                   &rhs.integer_impl.integer)
    }
    
    public static func <<(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_2exp(&result.integer_impl.integer, &lhs.integer_impl.integer, rhs)
        
        return result
    }
    
    public static func <<= <RHS>(lhs: inout BigInt, rhs: RHS) where RHS : BinaryInteger {
        lhs.ensureUnique()
        
        __gmpz_mul_2exp(&lhs.integer_impl.integer, &lhs.integer_impl.integer, UInt(rhs))
    }
    
    public static func >>(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_tdiv_q_2exp(&result.integer_impl.integer, &lhs.integer_impl.integer, rhs)
        
        return result
    }
    
    public static func >>= <RHS>(lhs: inout BigInt, rhs: RHS) where RHS : BinaryInteger {
        lhs.ensureUnique()
        
        __gmpz_tdiv_q_2exp(&lhs.integer_impl.integer, &lhs.integer_impl.integer, UInt(rhs))
    }
}

//
// MARK: Arithmetic
//
extension BigInt {
    //
    // Addition
    //
    public static func +(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_add(&result.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func +(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_sub_ui(&result.integer_impl.integer, &lhs.integer_impl.integer, uint)
        } else {
            __gmpz_add_ui(&result.integer_impl.integer, &lhs.integer_impl.integer, uint)
        }
        
        return result
    }
    
    public static func +(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(lhs))
        
        if lhs.signum() == -1 {
            // negative value
            __gmpz_sub_ui(&result.integer_impl.integer, &rhs.integer_impl.integer, uint)
        } else {
            __gmpz_add_ui(&result.integer_impl.integer, &rhs.integer_impl.integer, uint)
        }
        
        return result
    }
    
    public static func +(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_add_ui(&result.integer_impl.integer, &lhs.integer_impl.integer, rhs)
        
        return result
    }
    
    public static func +(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_add_ui(&result.integer_impl.integer, &rhs.integer_impl.integer, lhs)
        
        return result
    }
    
    public static func +=(lhs: inout BigInt, rhs: BigInt) {
        lhs.ensureUnique()
        
        __gmpz_add(&lhs.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
    }
    
    public static func +=(lhs: inout BigInt, rhs: UInt) {
        lhs.ensureUnique()
        
        __gmpz_add_ui(&lhs.integer_impl.integer, &lhs.integer_impl.integer, rhs)
    }
    
    public static func +=(lhs: inout BigInt, rhs: Int) {
        lhs.ensureUnique()
        
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_sub_ui(&lhs.integer_impl.integer, &lhs.integer_impl.integer, uint)
        } else {
            __gmpz_add_ui(&lhs.integer_impl.integer, &lhs.integer_impl.integer, uint)
        }
    }
    
    //
    // Subtraction
    //
    public static func -(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_sub(&result.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func -(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_add_ui(&result.integer_impl.integer, &lhs.integer_impl.integer, uint)
        } else {
            __gmpz_sub_ui(&result.integer_impl.integer, &lhs.integer_impl.integer, uint)
        }
        
        return result
    }
    
    public static func -(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(lhs))
        
        if lhs.signum() == -1 {
            // negative value
            __gmpz_add_ui(&result.integer_impl.integer, &rhs.integer_impl.integer, uint)
            __gmpz_neg(&result.integer_impl.integer, &result.integer_impl.integer)
        } else {
            __gmpz_ui_sub(&result.integer_impl.integer, uint,  &rhs.integer_impl.integer)
        }
        
        return result
    }
    
    public static func -(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_sub_ui(&result.integer_impl.integer, &lhs.integer_impl.integer, rhs)
        
        return result
    }
    
    public static func -(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_ui_sub(&result.integer_impl.integer, lhs,  &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func -=(lhs: inout BigInt, rhs: BigInt) {
        lhs.ensureUnique()
        
        __gmpz_sub(&lhs.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
    }
    
    public static func -=(lhs: inout BigInt, rhs: UInt) {
        lhs.ensureUnique()
        
        __gmpz_sub_ui(&lhs.integer_impl.integer, &lhs.integer_impl.integer, rhs)
    }
    
    public static func -=(lhs: inout BigInt, rhs: Int) {
        lhs.ensureUnique()
        
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_add_ui(&lhs.integer_impl.integer, &lhs.integer_impl.integer, uint)
        } else {
            __gmpz_sub_ui(&lhs.integer_impl.integer, &lhs.integer_impl.integer, uint)
        }
    }
    
    //
    // Multipication
    //
    public static func *(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul(&result.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_si(&result.integer_impl.integer, &lhs.integer_impl.integer, rhs)
        
        return result
    }
    
    public static func *(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_si(&result.integer_impl.integer, &rhs.integer_impl.integer, lhs)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_ui(&result.integer_impl.integer, &lhs.integer_impl.integer, rhs)
        
        return result
    }
    
    public static func *(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_ui(&result.integer_impl.integer, &rhs.integer_impl.integer, lhs)
        
        return result
    }
    
    public static func *=(lhs: inout BigInt, rhs: BigInt) {
        lhs.ensureUnique()
        
        __gmpz_mul(&lhs.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
    }
    
    public static func *=(lhs: inout BigInt, rhs: Int) {
        lhs.ensureUnique()
        
        __gmpz_mul_si(&lhs.integer_impl.integer, &lhs.integer_impl.integer, rhs)
    }
    
    public static func *=(lhs: inout BigInt, rhs: UInt) {
        lhs.ensureUnique()
        
        __gmpz_mul_ui(&lhs.integer_impl.integer, &lhs.integer_impl.integer, rhs)
    }
    
    //
    // Divison
    //
    public static func /(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
       __gmpz_fdiv_q(&result.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func /(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt(rhs)
        
        __gmpz_fdiv_q(&result.integer_impl.integer, &lhs.integer_impl.integer, &result.integer_impl.integer)
        
        return result
    }
    
    public static func /(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt(lhs)
        
        __gmpz_fdiv_q(&result.integer_impl.integer, &result.integer_impl.integer, &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func /(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt(rhs)
        
        __gmpz_fdiv_q(&result.integer_impl.integer, &lhs.integer_impl.integer, &result.integer_impl.integer)
        
        return result
    }
    
    public static func /(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt(lhs)
        
        __gmpz_fdiv_q(&result.integer_impl.integer, &result.integer_impl.integer, &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func /=(lhs: inout BigInt, rhs: BigInt) {
        lhs.ensureUnique()
        
        __gmpz_fdiv_q(&lhs.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
    }
    
    public static func /=(lhs: inout BigInt, rhs: Int) {
        lhs.ensureUnique()
        
        __gmpz_fdiv_q_ui(&lhs.integer_impl.integer, &lhs.integer_impl.integer, UInt(rhs))
        
        if rhs < 0 {
            __gmpz_neg(&lhs.integer_impl.integer, &lhs.integer_impl.integer)
        }
    }
    
    public static func /=(lhs: inout BigInt, rhs: UInt) {
        lhs.ensureUnique()
        
        __gmpz_fdiv_q_ui(&lhs.integer_impl.integer, &lhs.integer_impl.integer, rhs)
    }
    
    //
    // Modulus
    //
    public func quotientAndRemainder(dividingBy rhs: BigInt) -> (quotient: BigInt, remainder: BigInt) {
        let quotient = BigInt()
        let remainder = BigInt()
        
        __gmpz_fdiv_qr(&quotient.integer_impl.integer, &remainder.integer_impl.integer, &self.integer_impl.integer, &rhs.integer_impl.integer)
        
        return (quotient, remainder)
    }
    
    public static func %(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mod(&result.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
        
        return result
    }
    
    public static func %(lhs: BigInt, rhs: UInt) -> BigInt {
        return BigInt(__gmpz_fdiv_ui(&lhs.integer_impl.integer, rhs))
    }
    
    public static func %(lhs: BigInt, rhs: Int) -> BigInt {
        return BigInt(__gmpz_fdiv_ui(&lhs.integer_impl.integer, UInt(abs(rhs))))
    }
    
    public static func %=(lhs: inout BigInt, rhs: BigInt) {
        lhs.ensureUnique()
        
        __gmpz_mod(&lhs.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
    }
    
    //
    // MARK: Expontenials
    //
    public static func **(radix: BigInt, power: UInt) -> BigInt {
        let output = BigInt()
        
        __gmpz_pow_ui(&output.integer_impl.integer, &radix.integer_impl.integer, power)
        
        return output
    }
    
    
    public static func **=(radix: inout BigInt, power: UInt) {
        radix.ensureUnique()
        
        __gmpz_pow_ui(&radix.integer_impl.integer, &radix.integer_impl.integer, power)
    }
    
    public mutating func raisedTo(_ power: UInt) {
        self.ensureUnique()
        
        __gmpz_pow_ui(&self.integer_impl.integer, &self.integer_impl.integer, power)
    }
    
    public func isPerfectPower() -> Bool {
        return __gmpz_perfect_power_p(&self.integer_impl.integer) != 0
    }
    
    public func isPerfectSquare() -> Bool {
        return __gmpz_perfect_square_p(&self.integer_impl.integer) != 0
    }
    
    public func squareRoot() -> BigInt {
        let result = BigInt()
        
        __gmpz_sqrt(&result.integer_impl.integer, &self.integer_impl.integer)
        
        return result
    }
    
    public func squareRootAndRemainder() -> (BigInt,BigInt) {
        let root = BigInt()
        let rem = BigInt()
        
        __gmpz_sqrtrem(&root.integer_impl.integer, &rem.integer_impl.integer, &self.integer_impl.integer)
        
        return (root,rem)
    }
}


