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
    
    private var integer_ptr_store: UnsafeMutablePointer<mpz_t>? = nil
    public var integer_ptr: UnsafeMutablePointer<mpz_t> {
        if self.integer_ptr_store == nil {
            self.integer_ptr_store = UnsafeMutablePointer<mpz_t>.allocate(capacity: 1)
            self.integer_ptr_store!.initialize(to: self.integer)
        }
        
        return self.integer_ptr_store!
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
        if let pointer = self.integer_ptr_store {
            pointer.deinitialize(count: 1)
            pointer.deallocate()
        }
        
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
    }
    
    public init(_ n: UnsafeMutablePointer<mpz_t>) {
        self.integer_impl = BigIntImpl()
        __gmpz_init_set(&self.integer_impl.integer, n)
    }
    
    public init(integerLiteral value: BigInt.IntegerLiteralType) {
        self.integer_impl = BigIntImpl()
        __gmpz_init_set_si(&self.integer_impl.integer, value)
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        self.init(Int(source))
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.init(Int(source))
    }
    
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
    
    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(Int(source))
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.init(source)
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        if let s = source as? Int {
            self.init(s)
            return
        } else if let s = source as? UInt {
            self.init(s)
            return
        } else {
            self.init()
        }
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
        return self.toString(base: 10) ?? ""
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
    public var hashValue: Int {
        let size = __gmpz_size(&self.integer_impl.integer)
        let limb_pointer = __gmpz_limbs_read(&self.integer_impl.integer)!
        
        var hash = 0
        
        for i in 0..<size {
            hash  = hash.addingReportingOverflow(limb_pointer.advanced(by: i).pointee.hashValue).partialValue
            
            // http://hg.openjdk.java.net/jdk8/jdk8/jdk/file/tip/src/share/classes/java/math/BigInteger.java
//            hash = 31.unsafeMultiplied(by: hash).unsafeAdding(Int(limb_pointer.advanced(by: i).pointee))
        }
        
        return hash //Int(__gmpz_getlimbn(&self.integer_impl.integer, 0))
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
    public func mod(_ modulus: BigInt) -> BigInt {
        return self % modulus
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
    
    public static func %(lhs: BigInt, rhs: BigInt) -> (q: BigInt, r: BigInt) {
        let quotient = BigInt()
        let remainder = BigInt()
        
        __gmpz_fdiv_qr(&quotient.integer_impl.integer, &remainder.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
        
        return (quotient, remainder)
    }
    
    public static func %=(lhs: inout BigInt, rhs: BigInt) {
        lhs.ensureUnique()
        
        __gmpz_mod(&lhs.integer_impl.integer, &lhs.integer_impl.integer, &rhs.integer_impl.integer)
    }
    
    //
    // MARK: Primality
    //
    public enum Primality: Int32, ExpressibleByIntegerLiteral {
        case definitePrime = 2
        case probablePrime = 1
        case notPrime = 0
        
        public typealias IntegerLiteralType = Int32
        
        public init(integerLiteral value: Primality.IntegerLiteralType) {
            if 0...2 ~= value {
                self.init(rawValue: value)!
            } else {
                self.init(rawValue: 0)!
            }
        }
    }
    public func isPrime() -> Primality {
        return self.isPrime(reps: 15)
    }
    
    public func isPrime(reps: Int32) -> Primality {
        return Primality(integerLiteral: __gmpz_probab_prime_p(&self.integer_impl.integer, reps))
    }
    
    public func nextPrime() -> BigInt {
        let result = BigInt()
        
        __gmpz_nextprime(&result.integer_impl.integer, &self.integer_impl.integer)
        
        return result
    }
    
    public mutating func moveToNextPrime() {
        self.ensureUnique()
        
        __gmpz_nextprime(&self.integer_impl.integer, &self.integer_impl.integer)
    }
    
    //
    // MARK: Factorization
    //
    
    ///// consider using
    ////// Function: mp_bitcnt_t mpz_remove (mpz_t rop, const mpz_t op, const mpz_t f)
    
    /**
     Loops through all the prime factors of Self. Set the Bool in `handler` to stop the enumeration.
     
     - parameter handler: (Stop, Factor, Working_Register)
    */
    public func enumeratePrimeFactors(testLimit: UInt? = nil, withHandler handler: ((inout Bool, BigInt, BigInt)->())) {
        var working = self
        working.ensureUnique()
        var stop = false
        let limit = testLimit ?? 0
        
        // check self.isPrime
        if self.isPrime() != .notPrime {
            handler(&stop, working, 1)
            return
        }
        
        // find prime factors
        var test = mpz_t()
        __gmpz_init_set_si(&test, 1)
        
        var q = mpz_t()
        var r = mpz_t()
        defer {
            __gmpz_clear(&q)
            __gmpz_clear(&r)
            __gmpz_clear(&test)
        }
        
        while working > 1 && (limit == 0 || __gmpz_cmp_ui(&test, limit) <= 0) {
            // check if prime
            if working.isPrime() != .notPrime {
                handler(&stop, working, 1)
                return
            }
            
            // find next factor
            __gmpz_nextprime(&test, &test)
            repeat {
                __gmpz_fdiv_qr(&q, &r, &working.integer_impl.integer, &test)
                if __gmpz_cmp_ui(&r, 0) == 0 {
                    __gmpz_swap(&working.integer_impl.integer, &q)
                    handler(&stop, BigInt(&test), working)
                    if stop {
                        return
                    }
                } else {
                    break
                }
            } while __gmpz_cmp(&test, &working.integer_impl.integer) < 0
        }
    }
    
    public func primeFactorization(withPrimeSieve sieve: [BigInt]) -> [BigInt] {
        // check self.isPrime
        guard self.isPrime() == .notPrime else {
            return [self]
        }
        
        var working = self
        working.ensureUnique()
        var output = [BigInt]()
        var index = 0
        
        // find prime factors
        var q = mpz_t()
        var r = mpz_t()
        defer {
            __gmpz_clear(&q)
            __gmpz_clear(&r)
        }
        
        main_loop: while working > 1 && index < sieve.count {
            // find next factor
            let test = sieve[index]
            
            repeat {
                __gmpz_fdiv_qr(&q, &r, &working.integer_impl.integer, &test.integer_impl.integer)

                if __gmpz_cmp_ui(&r, 0) == 0 {
                    __gmpz_swap(&working.integer_impl.integer, &q)
                    output.append(test)
                } else {
                    break
                }
            } while __gmpz_cmp(&test.integer_impl.integer, &working.integer_impl.integer) < 0
            
            // check if prime
            if working.isPrime() != .notPrime {
                output.append(working)
                break main_loop
            }
            
            /// loop
            index += 1
        }
        
        return output
    }
    
    /**
     Prime factors Self and returns the unique factors
     
     - Returns: An array of unique BigInt factors
    */
    public func primeFactorsUnique() -> [BigInt] {
        var working = self
        working.ensureUnique()
        
        // check self.isPrime
        if self.isPrime() != .notPrime {
            return [working]
        }
        
        // find prime factors
        var output = [BigInt]()
        var test: BigInt = 1
        var q = mpz_t()
        var r = mpz_t()
        defer {
            __gmpz_clear(&q)
            __gmpz_clear(&r)
        }
        
        while working > 1 {
            // check if prime
            if working.isPrime() != .notPrime {
                output.append(working)
                return output
            }
            
            // find next factor
            test = test.nextPrime()
            __gmpz_fdiv_qr(&q, &r, &working.integer_impl.integer, &test.integer_impl.integer)
            if __gmpz_cmp_ui(&r, 0) == 0 {
                output.append(test)
                
                // divide out all factors of test
                repeat {
                    __gmpz_fdiv_qr(&working.integer_impl.integer, &r, &q, &test.integer_impl.integer)
                    __gmpz_swap(&working.integer_impl.integer, &q)
                } while __gmpz_cmp_ui(&r, 0) == 0
            }
        } // while working > 1
        
        return output
    }
    
    public func primeFactorsAndExponents() -> [(BigInt,UInt)] {
        var output: [(BigInt,UInt)] = []
        var last_factor: BigInt = 0
        var count: UInt = 0
        self.enumeratePrimeFactors() { (_, factor, _) in
            if last_factor == factor {
                count += 1
            } else {
                if last_factor != 0 {
                    output.append((last_factor,count))
                }
                
                last_factor = factor
                count = 1
            }
        }
        
        output.append((last_factor,count))
        
        return output
    }
    
    public func primeFactorsAndExponents_Ints() -> [UInt : UInt] {
        var output: [UInt: UInt] = [:]
        self.enumeratePrimeFactors() { (_, factor, _) in
            let int = factor.toUInt()!
            if output[int] != nil {
                output[int]! += 1
            } else {
                output[int] = 1
            }
        }
        
        return output
    }
    
    // returns (factor, even_times)
    public func primeFactorsAndExponents_Bool() -> [UInt : Bool] {
        var output: [UInt: Bool] = [:]
        self.enumeratePrimeFactors() { (_, factor, _) in
            let int = factor.toUInt()!
            let val = output[int]
            if val != nil {
                output[int]! = val! == false
            } else {
                output[int] = false
            }
        }
        
        return output
    }
    
    public func primeFactorization(testLimit: UInt? = nil) -> [BigInt] {
        var output: [BigInt] = []
        self.enumeratePrimeFactors(testLimit: testLimit) { (_, factor, _) in
            output.append(factor)
        }
        
        return output
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


