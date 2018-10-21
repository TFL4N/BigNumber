//
//  BigFloatTests.swift
//  BigNumberTests
//
//  Created by Spizzace on 10/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import XCTest
@testable import BigNumber

class BigFloatTests: XCTestCase {

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

    func testBigFloat() {
        let foo = BigFloat(10)
        
        for i: UInt in 1...10 {
            let bar = foo / i
            print(bar)
            print(foo)
            print()
        }
    }
    
    func testBigFloatCopyOnWrite() {
        let a = BigFloat(10)
        var b = a
        
        b += 1
        
        XCTAssertNotEqual(a, b, "BigFloat CopyOnWrite fail")
        
        
        let c = BigFloat(10)
        let d = -c
        
        XCTAssertNotEqual(c, d, "BigFloat CopyOnWrite fail")
    }
    
    func testBigFloatNegate() {
        typealias CaseType = (BigFloat,solution: BigFloat)
        
        let cases: [CaseType] = [
            (0.12345, -0.12345),
            (-0.12345, 0.12345),
        ]
        
        for var c in cases {
            let sol = -c.0
            c.0.negate()
            
            XCTAssertEqual(c.0, c.solution, "BigFloat(\(c.0)).negate() fail")
            XCTAssertEqual(sol, c.solution, "BigFloat.-(\(c.0)) fail")
        }
    }
    
    func testBigFloatSubtraction() {
        typealias CaseType_FF = (BigFloat,BigFloat,solution: BigFloat)
        
        let cases: [CaseType_FF] = [
            (0.7, -0.12345, solution: 0.7+0.12345),
            (50.0, 0.12345, solution: 50.0-0.12345),
            ]
        
        let all = [
            (cases, "Two BigFloats")
        ]
        
        for type in all {
            for c in type.0 {
                let sol = c.0 - c.1
                
                XCTAssertEqual(sol, c.solution, "BigFloat.-(\(c.0),\(c.1)) failed <\(type.1)>")
            }
        }
    }
}
