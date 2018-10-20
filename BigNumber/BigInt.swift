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
public final class BigInt: ExpressibleByIntegerLiteral, LosslessStringConvertible {
    //
    // constants
    //
    public typealias IntegerLiteralType = Int

    //
    // ivars
    //
    public var integer: mpz_t
    
    //
    // Initalizers
    //
    public required init() {
        self.integer = mpz_t()
        __gmpz_init(&self.integer)
    }
    
    public required init(_ n: UnsafeMutablePointer<mpz_t>) {
        self.integer = mpz_t()
        __gmpz_init_set(&self.integer, n)
    }
    
    public required init(integerLiteral value: BigInt.IntegerLiteralType) {
        self.integer = mpz_t()
        __gmpz_init_set_si(&self.integer, value)
    }

    public convenience init(_ integer: BigInt) {
        self.init()
        __gmpz_set(&self.integer, &integer.integer)
    }
    
    public convenience init(_ integer: UInt) {
        self.init()
        __gmpz_set_ui(&self.integer, integer)
    }
    
    public convenience init(_ integer: Int) {
        self.init()
        __gmpz_set_si(&self.integer, integer)
    }
    
    public convenience init(_ double: Double) {
        self.init()
        __gmpz_set_d(&self.integer, double)
    }
    
    public convenience init(_ rational: Rational) {
        self.init()
        __gmpz_set_q(&self.integer, &rational.rational_impl.rational)
    }
    
    public required convenience init?(_ string: String) {
        self.init(string: string, base: 10)
    }
    
    public convenience init?(string:String, base: Int32) {
        self.init()
        
        let result = string.withCString { __gmpz_set_str(&self.integer, $0, base) }
        
        if result != 0 {
            return nil
        }
    }
    
    //
    // deinit
    //
    deinit {
        __gmpz_clear(&self.integer)
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
    public final func set(_ integer: BigInt) {
        __gmpz_set(&self.integer, &integer.integer)
    }
    
    public final func set(_ integer: UInt) {
        __gmpz_set_ui(&self.integer, integer)
    }
    
    public final func set(_ integer: Int) {
        __gmpz_set_si(&self.integer, integer)
    }
    
    public final func set(_ double: Double) {
        __gmpz_set_d(&self.integer, double)
    }
    
    public final func set(_ rational: Rational) {
        __gmpz_set_q(&self.integer, &rational.rational_impl.rational)
    }
    
    //
    // Misc
    //
    public final func signum() -> Int {
        let x = __gmpz_cmp_ui(&self.integer, 0)
        if x < 0 {
            return -1
        } else if x > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    public final func isOdd() -> Bool {
        return self.integer._mp_d.pointee % 2 == 1
    }
    
    public final func isEven() -> Bool {
        return self.integer._mp_d.pointee % 2 == 0
    }
}

//
// MARK: SignNumeric
//
extension BigInt: SignedNumeric {
    // Sign Numeric
    prefix public static func -(operand: BigInt) -> BigInt {
        let result = BigInt(operand)
        
        __gmpz_neg(&result.integer, &result.integer)
        
        return result
    }
    
    public func negate() {
        __gmpz_neg(&self.integer, &self.integer)
    }
    
    // Numeric
    public typealias Magnitude = BigInt
    
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
    
    public var magnitude: BigInt {
        let result = BigInt(self)
        
        __gmpz_abs(&result.integer, &result.integer)
        
        return result
    }
    
    prefix public static func +(x: BigInt) -> BigInt {
        return x
    }
}

// Hashable
extension BigInt: Hashable {
    public var hashValue: Int {
        let size = __gmpz_size(&self.integer)
        let limb_pointer = __gmpz_limbs_read(&self.integer)!
        
        var hash = 0
        
        for i in 0..<size {
            hash  = hash.addingReportingOverflow(limb_pointer.advanced(by: i).pointee.hashValue).partialValue
            
            // http://hg.openjdk.java.net/jdk8/jdk8/jdk/file/tip/src/share/classes/java/math/BigInteger.java
//            hash = 31.unsafeMultiplied(by: hash).unsafeAdding(Int(limb_pointer.advanced(by: i).pointee))
        }
        
        return hash //Int(__gmpz_getlimbn(&self.integer, 0))
    }
}

//
// MARK: Convertibles
//
extension BigInt {
    public func toString(base: Int32) -> String? {
        if let r = __gmpz_get_str(nil, base, &self.integer) {
            return String(cString: r)
        } else {
            return nil
        }
    }
    
    public func toString() -> String {
        return self.toString(base: 10)!
    }
    
    public func toInt() -> Int? {
        if __gmpz_fits_slong_p(&self.integer) != 0 {
            return __gmpz_get_si(&self.integer)
        } else {
            return nil
        }
    }
    
    public func toUInt() -> UInt? {
        if __gmpz_fits_ulong_p(&self.integer) != 0 {
            return __gmpz_get_ui(&self.integer)
        } else {
            return nil
        }
    }
    
    public func toDouble() -> Double? {
        if __gmpz_fits_ulong_p(&self.integer) != 0 {
            return __gmpz_get_d(&self.integer)
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
        return __gmpz_cmp(&lhs.integer, &rhs.integer) == 0
    }
    
    public static func ==(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) == 0
    }
    
    public static func ==(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) == 0
    }
    
    public static func ==(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) == 0
    }
    
    public static func ==(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) == 0
    }
    
    public static func ==(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) == 0
    }
    
    public static func ==(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) == 0
    }
    
    //
    // isNotEqual
    //
    public static func !=(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) != 0
    }
    
    public static func !=(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) != 0
    }
    
    public static func !=(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) != 0
    }
    
    public static func !=(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) != 0
    }
    
    public static func !=(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) != 0
    }
    
    public static func !=(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) != 0
    }
    
    public static func !=(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) != 0
    }
    
    //
    // isLessThan
    //
    public static func <(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) < 0
    }
    
    public static func <(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) < 0
    }
    
    public static func <(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) > 0
    }
    
    public static func <(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) < 0
    }
    
    public static func <(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) > 0
    }
    
    public static func <(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) < 0
    }
    
    public static func <(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) > 0
    }
    
    //
    // isLessThanOrEqual
    //
    public static func <=(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) <= 0
    }
    
    public static func <=(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) <= 0
    }
    
    public static func <=(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) >= 0
    }
    
    public static func <=(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) <= 0
    }
    
    public static func <=(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) >= 0
    }
    
    public static func <=(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) <= 0
    }
    
    public static func <=(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) >= 0
    }
    
    //
    // isGreaterThanOrEqual
    //
    public static func >=(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) >= 0
    }
    
    public static func >=(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) >= 0
    }
    
    public static func >=(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) <= 0
    }
    
    public static func >=(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) >= 0
    }
    
    public static func >=(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) <= 0
    }
    
    public static func >=(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) >= 0
    }
    
    public static func >=(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) <= 0
    }
    
    //
    // isGreaterThan
    //
    public static func >(lhs: BigInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp(&lhs.integer, &rhs.integer) > 0
    }
    
    public static func >(lhs: BigInt, rhs: Double) -> Bool {
        return __gmpz_cmp_d(&lhs.integer, rhs) > 0
    }
    
    public static func >(lhs: Double, rhs: BigInt) -> Bool {
        return __gmpz_cmp_d(&rhs.integer, lhs) < 0
    }
    
    public static func >(lhs: BigInt, rhs: Int) -> Bool {
        return __gmpz_cmp_si(&lhs.integer, rhs) > 0
    }
    
    public static func >(lhs: Int, rhs: BigInt) -> Bool {
        return __gmpz_cmp_si(&rhs.integer, lhs) < 0
    }
    
    public static func >(lhs: BigInt, rhs: UInt) -> Bool {
        return __gmpz_cmp_ui(&lhs.integer, rhs) > 0
    }
    
    public static func >(lhs: UInt, rhs: BigInt) -> Bool {
        return __gmpz_cmp_ui(&rhs.integer, lhs) < 0
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
        
        __gmpz_add(&result.integer, &lhs.integer, &rhs.integer)
        
        return result
    }
    
    public static func +(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_sub_ui(&result.integer, &lhs.integer, uint)
        } else {
            __gmpz_add_ui(&result.integer, &lhs.integer, uint)
        }
        
        return result
    }
    
    public static func +(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(lhs))
        
        if lhs.signum() == -1 {
            // negative value
            __gmpz_sub_ui(&result.integer, &rhs.integer, uint)
        } else {
            __gmpz_add_ui(&result.integer, &rhs.integer, uint)
        }
        
        return result
    }
    
    public static func +(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_add_ui(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func +(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_add_ui(&result.integer, &rhs.integer, lhs)
        
        return result
    }
    
    public static func +=(lhs: inout BigInt, rhs: BigInt) {
        __gmpz_add(&lhs.integer, &lhs.integer, &rhs.integer)
    }
    
    public static func +=(lhs: inout BigInt, rhs: UInt) {
        __gmpz_add_ui(&lhs.integer, &lhs.integer, rhs)
    }
    
    public static func +=(lhs: inout BigInt, rhs: Int) {
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_sub_ui(&lhs.integer, &lhs.integer, uint)
        } else {
            __gmpz_add_ui(&lhs.integer, &lhs.integer, uint)
        }
    }
    
    //
    // Subtraction
    //
    public static func -(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_sub(&result.integer, &lhs.integer, &rhs.integer)
        
        return result
    }
    
    public static func -(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_add_ui(&result.integer, &lhs.integer, uint)
        } else {
            __gmpz_sub_ui(&result.integer, &lhs.integer, uint)
        }
        
        return result
    }
    
    public static func -(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt()
        let uint = UInt(abs(lhs))
        
        if lhs.signum() == -1 {
            // negative value
            __gmpz_add_ui(&result.integer, &rhs.integer, uint)
            __gmpz_neg(&result.integer, &result.integer)
        } else {
            __gmpz_ui_sub(&result.integer, uint,  &rhs.integer)
        }
        
        return result
    }
    
    public static func -(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_sub_ui(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func -(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_ui_sub(&result.integer, lhs,  &rhs.integer)
        
        return result
    }
    
    public static func -=(lhs: inout BigInt, rhs: BigInt) {
        __gmpz_sub(&lhs.integer, &lhs.integer, &rhs.integer)
    }
    
    public static func -=(lhs: inout BigInt, rhs: UInt) {
        __gmpz_sub_ui(&lhs.integer, &lhs.integer, rhs)
    }
    
    public static func -=(lhs: inout BigInt, rhs: Int) {
        let uint = UInt(abs(rhs))
        
        if rhs.signum() == -1 {
            // negative value
            __gmpz_add_ui(&lhs.integer, &lhs.integer, uint)
        } else {
            __gmpz_sub_ui(&lhs.integer, &lhs.integer, uint)
        }
    }
    
    //
    // Multipication
    //
    public static func *(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul(&result.integer, &lhs.integer, &rhs.integer)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_si(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func *(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_si(&result.integer, &rhs.integer, lhs)
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_ui(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func *(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_ui(&result.integer, &rhs.integer, lhs)
        
        return result
    }
    
    public static func *=(lhs: inout BigInt, rhs: BigInt) {
        let result = BigInt()
        
        __gmpz_mul(&result.integer, &lhs.integer, &rhs.integer)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    public static func *=(lhs: inout BigInt, rhs: Int) {
        let result = BigInt()
        
        __gmpz_mul_si(&result.integer, &lhs.integer, rhs)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    public static func *=(lhs: inout BigInt, rhs: UInt) {
        let result = BigInt()
        
        __gmpz_mul_ui(&result.integer, &lhs.integer, rhs)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    //
    // Divison
    //
    public static func /(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
       __gmpz_fdiv_q(&result.integer, &lhs.integer, &rhs.integer)
        
        return result
    }
    
    public static func /(lhs: BigInt, rhs: Int) -> BigInt {
        let result = BigInt(rhs)
        
        __gmpz_fdiv_q(&result.integer, &lhs.integer, &result.integer)
        
        return result
    }
    
    public static func /(lhs: Int, rhs: BigInt) -> BigInt {
        let result = BigInt(lhs)
        
        __gmpz_fdiv_q(&result.integer, &result.integer, &rhs.integer)
        
        return result
    }
    
    public static func /(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt(rhs)
        
        __gmpz_fdiv_q(&result.integer, &lhs.integer, &result.integer)
        
        return result
    }
    
    public static func /(lhs: UInt, rhs: BigInt) -> BigInt {
        let result = BigInt(lhs)
        
        __gmpz_fdiv_q(&result.integer, &result.integer, &rhs.integer)
        
        return result
    }
    
    public static func /=(lhs: inout BigInt, rhs: BigInt) {
        let result = BigInt()
        
        __gmpz_fdiv_q(&result.integer, &lhs.integer, &rhs.integer)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    public static func /=(lhs: inout BigInt, rhs: Int) {
        let result = BigInt(rhs)
        
        __gmpz_fdiv_q(&result.integer, &lhs.integer, &result.integer)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    public static func /=(lhs: inout BigInt, rhs: UInt) {
        let result = BigInt(rhs)
        
        __gmpz_fdiv_q(&result.integer, &lhs.integer, &result.integer)
        
        __gmpz_set(&lhs.integer, &result.integer)
    }
    
    //
    // Modulus
    //
    public static func %(lhs: BigInt, rhs: BigInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mod(&result.integer, &lhs.integer, &rhs.integer)
        
        return result
    }
    
    public static func %(lhs: BigInt, rhs: UInt) -> BigInt {
        return BigInt(__gmpz_fdiv_ui(&lhs.integer, rhs))
    }
    
    public static func %(lhs: BigInt, rhs: Int) -> BigInt {
        return BigInt(__gmpz_fdiv_ui(&lhs.integer, UInt(abs(rhs))))
    }
    
    public static func %(lhs: BigInt, rhs: BigInt) -> (q: BigInt, r: BigInt) {
        let quotient = BigInt()
        let remainder = BigInt()
        
        __gmpz_fdiv_qr(&quotient.integer, &remainder.integer, &lhs.integer, &rhs.integer)
        
        return (quotient, remainder)
    }
    
    public static func %=(lhs: inout BigInt, rhs: BigInt) {
        __gmpz_mod(&lhs.integer, &lhs.integer, &rhs.integer)
    }
    
    //
    // Bitwise
    //
    public static func <<(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_mul_2exp(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func <<=(lhs: inout BigInt, rhs: UInt) {
        __gmpz_mul_2exp(&lhs.integer, &lhs.integer, rhs)
    }
    
    public static func >>(lhs: BigInt, rhs: UInt) -> BigInt {
        let result = BigInt()
        
        __gmpz_tdiv_q_2exp(&result.integer, &lhs.integer, rhs)
        
        return result
    }
    
    public static func >>=(lhs: inout BigInt, rhs: UInt) {
        __gmpz_tdiv_q_2exp(&lhs.integer, &lhs.integer, rhs)
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
        return Primality(integerLiteral: __gmpz_probab_prime_p(&self.integer, reps))
    }
    
    public func nextPrime() -> BigInt {
        let result = BigInt()
        
        __gmpz_nextprime(&result.integer, &self.integer)
        
        return result
    }
    
    public func moveToNextPrime() {
        __gmpz_nextprime(&self.integer, &self.integer)
    }
    
    //
    // MARK: Factorization
    //
    
    /**
     Loops through all the prime factors of Self. Set the Bool in `handler` to stop the enumeration.
     
     - parameter handler: (Stop, Factor, Working_Register)
    */
    public func enumeratePrimeFactors(withHandler handler: ((inout Bool, BigInt, BigInt)->())) {
        var working = BigInt(self)
        var stop = false
        
        // check self.isPrime
        if self.isPrime() != .notPrime {
            handler(&stop, working, 1)
            return
        }
        
        // find prime factors
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
                handler(&stop, working, 1)
                working = 1
                continue
            }
            
            // find next factor
            test = test.nextPrime()
            repeat {
                __gmpz_fdiv_qr(&q, &r, &working.integer, &test.integer)
                if __gmpz_cmp_ui(&r, 0) == 0 {
                    __gmpz_swap(&working.integer, &q)
                    handler(&stop, test, working)
                    if stop {
                        return
                    }
                } else {
                    break
                }
            } while test < working
        }
    }
    
    /**
     Prime factors Self and returns the unique factors
     
     - Returns: An array of unique BigInt factors
    */
    public func primeFactorsUnique() -> [BigInt] {
        let working = BigInt(self)
        
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
            __gmpz_fdiv_qr(&q, &r, &working.integer, &test.integer)
            if __gmpz_cmp_ui(&r, 0) == 0 {
                output.append(BigInt(test))
                
                // divide out all factors of test
                repeat {
                    __gmpz_fdiv_qr(&working.integer, &r, &q, &test.integer)
                    __gmpz_swap(&working.integer, &q)
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
    
    public func primeFactorization() -> [BigInt] {
        var output: [BigInt] = []
        self.enumeratePrimeFactors() { (_, factor, _) in
            output.append(factor)
        }
        
        return output
    }
    
    //
    // MARK: Expontenials
    //
    public static func **(radix: BigInt, power: UInt) -> BigInt {
        let output = BigInt()
        
        __gmpz_pow_ui(&output.integer, &radix.integer, power)
        
        return output
    }
    
    
    public static func **=(radix: inout BigInt, power: UInt) {
        __gmpz_pow_ui(&radix.integer, &radix.integer, power)
    }
    
    public func raisedTo(_ power: UInt) {
        __gmpz_pow_ui(&self.integer, &self.integer, power)
    }
    
    public func isPerfectPower() -> Bool {
        return __gmpz_perfect_power_p(&self.integer) != 0
    }
    
    public func isPerfectSquare() -> Bool {
        return __gmpz_perfect_square_p(&self.integer) != 0
    }
    
    public func squareRoot() -> BigInt {
        let result = BigInt()
        
        __gmpz_sqrt(&result.integer, &self.integer)
        
        return result
    }
    
    public func squareRootAndRemainder() -> (BigInt,BigInt) {
        let root = BigInt()
        let rem = BigInt()
        
        __gmpz_sqrtrem(&root.integer, &rem.integer, &self.integer)
        
        return (root,rem)
    }
}


