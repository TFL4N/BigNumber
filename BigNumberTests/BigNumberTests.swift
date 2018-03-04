//
//  BigNumberTests.swift
//  BigNumberTests
//
//  Created by Spizzace on 8/19/17.
//  Copyright © 2017 SpaiceMaine. All rights reserved.
//

import XCTest
@testable import BigNumber

class BigNumberTests: XCTestCase {
    
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
    
    func testIntInitFromInt() {
        let i1 = BigInt()
        XCTAssertEqual(i1.toString(), "0", "BigInt() failed")
        
        let i2: BigInt = 1233456789
        XCTAssertEqual(i2.toString(), "1233456789", "IntLiteral -> BigInt failed")
        
        let int3 = Int(12345678)
        let i3 = BigInt(int3)
        XCTAssertEqual(i3.toString(), "\(int3)", "BigInt(Int) failed")
        
        let int4 = UInt(123456)
        let i4 = BigInt(int4)
        XCTAssertEqual(i4.toString(), "\(int4)", "BigInt(UInt) failed")
    }
    
    func testIntInitFromString() {
        //
        // Possible Improvements
        //
        // 1) Better fail cases
        // 2) Separate out fail cases
        // 3) Init cases for bases >16
    
        let int1 = "56789"
        let i1 = BigInt(int1)
        XCTAssertNotNil(i1, "BigInt(String) != nil failed")
        XCTAssertEqual(i1!.toString(), int1, "BigInt(String) failed")
        
        let int2 = "123$%esfdb@45"
        let i2 = BigInt(int2)
        XCTAssertNil(i2, "BigInt(BadStr) == nil failed")
        
        let int3 = "12345"
        let i3 = BigInt(string: int3, base: 10)
        XCTAssertNotNil(i3, "BigInt(string:,base:10) != nil failed")
        XCTAssertEqual(i3!.toString(), int3, "BigInt(string:,base:10) failed")
        
        let int4 = "1010101"
        let i4 = BigInt(string: int4, base: 2)
        XCTAssertNotNil(i4, "BigInt(string:,base:2) != nil failed")
        XCTAssertEqual(i4!.toString(), "85", "BigInt(string:,base:2) failed")
        
        let int5 = "12334FF"
        let i5 = BigInt(string: int5, base: 16)
        XCTAssertNotNil(i5, "BigInt(string:,base:16) != nil failed")
        XCTAssertEqual(i5!.toString(), "19084543", "BigInt(string:,base:16) failed")
    }
    
    func testIntComparableIsEqual() {
        
    }
    
    func testIntComparableIsLessThan() {
        
    }
    
    func testIntComparableIsLessThanOrEqual() {
        
    }
    
    func testIntComparableIsGreaterThan() {
        
    }
    
    func testIntComparableIsGreaterThanOrEqual() {
        
    }

    func testIntAddition() {
        
    }
    
    func testIntSubtraction() {
        
    }
    
    func testIntMultiplication() {
        
    }
}
