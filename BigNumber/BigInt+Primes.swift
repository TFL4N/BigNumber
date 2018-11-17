//
//  BigInt+Primes.swift
//  BigNumber
//
//  Created by Spizzace on 11/17/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation
import GMP

public extension BigInt {
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
}
