//
//  QuadraticSolver.swift
//  BigNumberTests
//
//  Created by Spizzace on 10/2/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import XCTest
@testable import BigNumber

class QuadraticSolver: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func areQuadraticCongruenceSolutionEqual(_ lhs: QuadraticCongruenceSolution?, _ rhs: QuadraticCongruenceSolution?) -> Bool {
        if (lhs == nil && rhs != nil) || (lhs != nil && rhs == nil) {
            return false
        }
        if lhs == nil && rhs == nil {
            return true
        }
        
        let lhs = lhs!
        let rhs = rhs!
        
        let lhs_set = Set(lhs.solutions.map{$0.toInt()!})
        let rhs_set = Set(rhs.solutions.map{$0.toInt()!})
        
        return lhs_set == rhs_set
            && lhs.modulus == rhs.modulus
            && lhs.originalModulus == rhs.originalModulus
    }
    
    func getQuadraticCongruenceSolutionCompareString(_ lhs: QuadraticCongruenceSolution?, _ rhs: QuadraticCongruenceSolution?) -> String {
        return "\(lhs?.description ?? "nil") is not equal to \(rhs?.description ?? "nil")."
    }

    func testSquareQuadraticCongruencesWithOddPrimeModulus() {
        typealias CaseType = (n:BigInt,prime:BigInt,solution:Set<Int>?)
        
        /// prime modulus of form 4k + 3 or p = 3 (mod 4)
        let cases_1: [CaseType] = [
            (1,7, [1,6]),
            (9,43, [3,40]),
            (7,3, [1,2])
        ]
        
        /// has solutions
        let cases_2: [CaseType] = [
            (5,41, [13,28]),
            (8,41, [7,34]),
        ]
        
        /// no solutions
        let cases_3: [CaseType] = [
            (7,43, nil)
        ]

        let all = [
            (cases_1, "<p ≡ 3 (mod 4)>"),
            (cases_2, "<has solution>"),
            (cases_3, "<has no solution>"),
        ]
        
        for a in all {
            for c in a.0 {
                let sol = solveQuadraticCongruence(a: c.n, oddPrimeModulus: c.prime)
                let set = sol == nil ? nil : Set(sol!.map {$0.toInt()!})
                
                XCTAssertEqual(set, c.solution, "solveQuadraticCongruence(n: \(c.n), oddPrimeModulus: \(c.prime)) \(a.1) failed")
            }
        }
    }
    
    func testChineseRemainderTheorem() {
        typealias CaseType = (solution:Congruence?,congruences:[Congruence])
        
        
        let coprime_cases: [CaseType] = [
            (Congruence(1243, modulus: 2772),
             [
                Congruence(3, modulus: 4),
                Congruence(4, modulus: 7),
                Congruence(1, modulus: 9),
                Congruence(0, modulus: 11)
                ]),
        ]
        
        let noncoprime_cases: [CaseType] = [
        
        ]
        
        let all = [
            (coprime_cases, "Coprime moduli"),
            (noncoprime_cases, "Non coprime moduli"),
        ]
        
        for (type, type_str) in all {
            for c in type {
                let sol = chineseRemainderTheorem(congruences: c.congruences)
                //                let sol = chineseRemainderTheorem(withCoprimeCongruences: c.congruences)
                
                XCTAssertEqual(sol, c.solution, "chineseRemainderTheorem() <\(type_str)> fail -- \(c.congruences)")
            }
        }
        
        for c in coprime_cases {
            let sol = chineseRemainderTheorem(withCoprimeCongruences: c.congruences)
            
            XCTAssertEqual(sol, c.solution, "chineseRemainderTheorem(withCoprimeModuli:) fail -- \(c.congruences)")
        }
    }
    
    func testSquareQuadraticCongruencesWithEvenPrimePowerModulus() {
        typealias CaseType = (a:BigInt,n:UInt,solution:Set<Int>?)
        
        let cases: [CaseType] = [
            (3,3, nil),
            (9,1, [1]),
            (9,2, [1,3]),
            (9,3, [1,3,5,7]),
            (9,4, [3,5,11,13]),
            (17,4, [1,7,9,15]),
            (9,12, [3,2045,2051,4093])
        ]
        
        for c in cases {
            let sol = solveQuadraticCongruence(a: c.a, evenPrimePowerModulus: c.n)
            let set = sol == nil ? nil : Set(sol!.map {$0.toInt()!})
            XCTAssertEqual(set, c.solution, "solveQuadraticCongruence(a: \(c.a), evenPrimePowerModulus: \(c.n)) fail")
        }
    }

    func testSquareQuadraticCongruencesWithOddPrimePowerModulus() {
        typealias CaseType = (a:BigInt,prime:BigInt,n:UInt,solution:Set<Int>?)
        
        let cases: [CaseType] = [
            (7,3,3, [13,14]),
            (13,17,2, [59,230]),
            (21,5,5, [461,2664]),
            (21,5,7, [19211,58914]),
            (25,7,7, [5,823538]),
            (25,7,3, [5,338])
        ]
        
        for c in cases {
            let sol = solveQuadraticCongruence(a: c.a, oddPrimePowerModulus: c.prime, exponent: c.n)
            let set = sol == nil ? nil : Set(sol!.map {$0.toInt()!})
            XCTAssertEqual(set, c.solution, "solveQuadraticCongruence(a: \(c.a), oddPrimeModulus: \(c.prime), exponent: \(c.n)) fail")
        }
    }
    
    func testSquareQuadraticCongruencesWithPrimePowerModulus() {
        typealias CaseType = (a:BigInt,prime:BigInt,n:UInt,solution:QuadraticCongruenceSolution?)
        
        //// a and p^n are not coprime, but a is not a multiple of p^n
        let non_coprime_cases: [CaseType] = [
            (11*49, 7, 5, QuadraticCongruenceSolution(solutions: [917,1484], modulus: 2401, originalModulus: 7**5) ),
            (11*49, 7, 4, QuadraticCongruenceSolution(solutions: [112,231], modulus: 343, originalModulus: 7**4)),
            (11*49, 7, 3, QuadraticCongruenceSolution(solutions: [14,35], modulus: 49, originalModulus: 7**3) )
        ]
        
        
        //// a is a multiple of p^n
        let multiple_cases: [CaseType] = [
            (25*2, 5, 2, QuadraticCongruenceSolution(solutions: [0], modulus: 5, originalModulus: 5**2)),
            (25*5, 5, 2, QuadraticCongruenceSolution(solutions: [0], modulus: 5, originalModulus: 5**2)),
            (169*5, 13, 2, QuadraticCongruenceSolution(solutions: [0], modulus: 13, originalModulus: 13**2)),
            (32*5, 2, 5, QuadraticCongruenceSolution(solutions: [0], modulus: 8, originalModulus: 2**5)),
        ]
        
        /// coprime, just uses specialized functions
        let coprime_cases: [CaseType] = [
            
        ]
        
        let all = [
            (non_coprime_cases, "<a && modulus are not coprime nor multiples>"),
            (multiple_cases, "<a is a multiple of modulus>"),
            (coprime_cases, "<a && modulus are coprime>")
        ]
        
        for (type,type_str) in all {
            for c in type {
                let sol = solveQuadraticCongruence(a: c.a, primePowerModulus: c.prime, exponent: c.n)
                
                XCTAssertTrue(areQuadraticCongruenceSolutionEqual(sol,c.solution),
                              "\(getQuadraticCongruenceSolutionCompareString(sol, c.solution)).  solveQuadraticCongruence(a: \(c.a), primePowerModulus: \(c.prime), exponent: \(c.n)) fail -- \(type_str)")
            }
        }
    }
    
    func testSquareQuadraticCongruence() {
        
    }
}
