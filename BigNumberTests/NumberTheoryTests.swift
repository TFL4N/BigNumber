//
//  NumberTheoryTests.swift
//  BigNumberTests
//
//  Created by Spizzace on 9/26/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import XCTest
@testable import BigNumber

class NumberTheoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPartitions() {
//        var cache = [Int:Int]()
//        partitions(317, cache: &cache)
    }
    
    func testCreatePrimeSieve() {
        typealias CaseType = (limit: Int, solution: [Int])
        
    }
    
    func testEnumerateNumbersByPrimeFactors() {
        var count = 0
        enumerateNumbersByPrimeFactors(limit: 20) { (n, factors) in
            print(factors)
            count += 1
        }
        print(count)
        
        
        let limit: UInt = fastExponentation(10, 12)//100
        var total: BigInt = 1
        
        var primes: [Int] = [2]
        enumerateNumbersByPrimeFactors(primes: [2,3,5], limit: limit) { (n, factors) in
            if BigInt(n+1).isPrime() != .notPrime {
                primes.append(n+1)
            }
        }
        
        primes.sort()
        print(primes)
        
        let blah: Set<Int> = [2,3,5]
        enumerateNumbersByPrimeFactors(primes: primes, limit: limit) { (n, factors) in
            if factors.contains(where: { (pair) -> Bool in
                if !blah.contains(pair.key) {
                    return pair.value > 1
                }
                
                return false
            }) {
                return
            }
            
            total += n
        }
        
        print(total)
        
    }

    func testQuadraticRoots() {
        /*
         /// int root rounded
         let bar: [(BigInt,BigInt,BigInt)] = [
         (1,-1,-1),
         (1,-2,-1),
         (1,-3,-1), // one negative, one positive
         (1,-5,1),  // both positive
         (1,5,1),  // both negative
         ]
         for b in bar {
         print(b)
         print(quadraticRoots(ax2: b.0, bx: b.1, c: b.2))
         print(quadraticRoots(ax2: BigFloat(b.0), bx: BigFloat(b.1), c: BigFloat(b.2)))
         print()
         }
 */
        
        
        struct Solution: Equatable, CustomStringConvertible {
            let ans_1: BigFloat
            let ans_2: BigFloat
            
            init?(_ tuple: (BigFloat,BigFloat)?) {
                guard let tuple = tuple else {
                    return nil
                }
                
                self.ans_1 = tuple.0
                self.ans_2 = tuple.1
            }
            
            init(_ multiple: BigFloat, _ constant: BigFloat, _ surd: BigFloat, _ denominator: BigFloat) {
                let root = sqrt(surd)
                
                let foo = multiple/denominator
                
                self.init((foo * (constant + root), foo * (constant - root)))!
            }
            
            public static func ==(lhs: Solution, rhs: Solution) -> Bool {
                return (lhs.ans_1 == rhs.ans_1 && lhs.ans_2 == rhs.ans_2)
                    || (lhs.ans_1 == rhs.ans_2 && lhs.ans_2 == rhs.ans_1)
            }
            
            var description: String {
                return "(\(self.ans_1), \(self.ans_2))"
            }
        }
        
        
        
        typealias CaseType = (a: BigFloat, b: BigFloat, c: BigFloat, solution: Solution?)
        
        let cases: [CaseType] = [
            (5,-6,-9, Solution(3, 1, 6, 5))
        ]
        
        for c in cases {
            let ans = quadraticRoots(ax2: c.a, bx: c.b, c: c.c)
            
            XCTAssertEqual(Solution(ans), c.solution, "quadraticRoots(ax2: \(c.a), bx: \(c.b), c: \(c.c)) failed")
        }
    }
}
