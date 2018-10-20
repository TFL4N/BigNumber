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

    func testQuadraticRoots() {
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
