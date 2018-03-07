//
//  RationalTests.swift
//  BigNumberTests
//
//  Created by Spizzace on 3/5/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import XCTest
import BigNumber

class RationalTests: XCTestCase {

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
    
    func testRationalToString() {
        var str = Rational(1,7).toFloatString(decimalPlaces: 10)
        XCTAssertEqual("0.1428571428", str, "(1/7)[10].toFloatString failed")
        
        str = Rational(1,999).toFloatString(decimalPlaces: 9)
        XCTAssertEqual("0.001001001", str, "(1/999)[9].toFloatString failed")
        
        str = Rational(1,689).toFloatString(decimalPlaces: 22)
        XCTAssertEqual("0.0014513788098693759071", str, "(1/689)[22].toFloatString failed")
        
        str = Rational(1,748).toFloatString(decimalPlaces: 22)
        XCTAssertEqual("0.0013368983957219251336", str, "(1/748)[22].toFloatString failed")
        
        
        
        
    }

}
