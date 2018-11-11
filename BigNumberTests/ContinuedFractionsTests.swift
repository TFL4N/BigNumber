//
//  ContinuedFractionsTests.swift
//  BigNumberTests
//
//  Created by Spizzace on 11/11/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import XCTest
@testable import BigNumber

class ContinuedFractionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testCreateContinuedFraction() {
        typealias CaseType = (a: BigInt, b: BigInt, c: BigInt, solution: ContinuedFraction)
        
        let cases: [CaseType] = [
            (1, 5, 2, ContinuedFraction(integral: 1, nonrepeating: [], repeating: [1])),
            (1, 5, 3, ContinuedFraction(integral: 1, nonrepeating: [], repeating: [12, 1, 2, 2, 2, 1])),
            (1, 51, 2, ContinuedFraction(integral: 4, nonrepeating: [], repeating: [14, 7])),
            (1, 51, 3, ContinuedFraction(integral: 2, nonrepeating: [], repeating: [1, 2, 2, 42, 2, 2, 1, 4, 21, 4])),
            ]
        
        for c in cases {
            let sol = createContinuedFraction(a: c.a, b: c.b, c: c.c)
            
            XCTAssertEqual(sol, c.solution, "ContinuedFraction(a: \(c.a), b: \(c.b), c: \(c.c)) failed")
        }
    }
    
    func testEnumerateConvergents() {
//        let fraction = createContinuedFraction(a: 1, b: 5, c: 3)
//
//        enumerateConvergents(continuedFraction: fraction) { (stop, r, depth) in
//            print(depth, r)
//
//            stop = depth > 8
//        }
//        return
        
        
        typealias CaseType = (fraction: ContinuedFraction, convergents: [UInt:Rational])
        
        let cases: [CaseType] = [
            // (1,5,2)
            (ContinuedFraction(integral: 1, nonrepeating: [], repeating: [1]),
             [0:1,1:2]),
            
            // (1,5,3)
            (ContinuedFraction(integral: 1, nonrepeating: [], repeating: [12, 1, 2, 2, 2, 1]),
             [0:1,
              1:[13,12],
              2:[14,13],
              3:[41,38],
              4:[96,89],
              5:[233,216],
              6:[329,305],
             ]),
            
            // (1,51,2)
            (ContinuedFraction(integral: 4, nonrepeating: [], repeating: [14, 7]),
             [0:4,
              1:[57,14],
              2:[403,99],
             ]),
            
            // (1,51,3)
            (ContinuedFraction(integral: 2, nonrepeating: [], repeating: [1, 2, 2, 42, 2, 2, 1, 4, 21, 4]),
             [0:2,
              1:3,
              2:[8,3],
              3:[19,7],
              4:[806,297],
              5:[1631,601],
              6:[4068,1499],
              7:[5699,2100],
              8:[26864,9899],
              9:[569843,209979],
              10:[2306236,849815],
              ]),
            ]
        
        for c in cases {
            let max_x = c.convergents.keys.max()!
            for (k, x) in c.convergents {
                enumerateConvergents(continuedFraction: c.fraction) { (stop, r, depth) in
                    if depth == k {
                        XCTAssertEqual(r, x, "enumerateConvergences(\(k), \(c.fraction)) failed")
                    }
                    
                    stop = depth >= max_x
                }
                
            }
        }
    }
}
