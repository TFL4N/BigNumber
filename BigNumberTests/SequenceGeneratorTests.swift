//
//  SequenceGeneratorTests.swift
//  BigNumberTests
//
//  Created by Spizzace on 11/19/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import XCTest
@testable import BigNumber

class SequenceGeneratorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

    func testPrimeNumberSequence() {
//        let sequence = PrimeFactorsSequence<UInt,UInt>()
//        sequence.loadItems(min: 0, max: 10)
//
//        print(sequence.data)
        
        let str = "2 2:1"
        let pair = StringSequencePair<UInt,[UInt:UInt]>(encodedString: str)
        
        print(pair)
        print([UInt:UInt](encodedString: "2:1"))
    }
}
