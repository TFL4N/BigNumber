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
        var cache = [Int:Int]()
        partitions(317, cache: &cache)
    }

}
