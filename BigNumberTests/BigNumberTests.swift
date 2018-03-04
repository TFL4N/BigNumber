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
    
    func testIntInitFromRational() {
        let dbl_1: Double = 2.0
        let dbl_2: Double = 2.4
        let dbl_3: Double = 2.5
        
        let i1 = BigInt(dbl_1)
        XCTAssertEqual("2", i1.toString(), "BigInt(Double) failed")
        
        let i2 = BigInt(dbl_2)
        XCTAssertEqual("2", i2.toString(), "BigInt(Double) failed")
        
        let i3 = BigInt(dbl_3)
        XCTAssertEqual("2", i3.toString(), "BigInt(Double) failed")
        
        // init(Rational)
        let rat_1: Rational = 2.0
        let rat_2: Rational = 2.4
        let rat_3: Rational = 2.5
        
        let i4 = BigInt(rat_1)
        XCTAssertEqual("2", i4.toString(), "BigInt(Rational) failed")
        
        let i5 = BigInt(rat_2)
        XCTAssertEqual("2", i5.toString(), "BigInt(Rational) failed")
        
        let i6 = BigInt(rat_3)
        XCTAssertEqual("2", i6.toString(), "BigInt(Rational) failed")
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
        let bint1 = BigInt(12345)
        let bint10 = BigInt(12345)
        let bint2 = BigInt(9876)
        
        let dbl1: Double = 12345
        let int1: Int = 12345
        let uint1: UInt = 12345
        
        // ==(lhs: BigInt, rhs: BigInt)
        XCTAssertTrue(bint1 == bint10, "==(lhs: BigInt, rhs: BigInt) failed")
        XCTAssertFalse(bint1 == bint2, "==(lhs: BigInt, rhs: BigInt) failed")
        
        // ==(lhs: BigInt, rhs: Double)
        XCTAssertTrue(bint1 == dbl1, "==(lhs: BigInt, rhs: Double) failed")
        XCTAssertFalse(bint2 == dbl1, "==(lhs: BigInt, rhs: Double) failed")
        
        // ==(lhs: Double, rhs: BigInt)
        XCTAssertTrue(dbl1 == bint1, "==(lhs: Double, rhs: BigInt) failed")
        XCTAssertFalse(dbl1 == bint2, "==(lhs: Double, rhs: BigInt) failed")
        
        // ==(lhs: BigInt, rhs: Int)
        XCTAssertTrue(bint1 == int1, "==(lhs: BigInt, rhs: Int) failed")
        XCTAssertFalse(bint2 == int1, "==(lhs: BigInt, rhs: Int) failed")
        
        // ==(lhs: Int, rhs: BigInt)
        XCTAssertTrue(int1 == bint1, "==(lhs: Int, rhs: BigInt) failed")
        XCTAssertFalse(int1 == bint2, "==(lhs: Int, rhs: BigInt) failed")
        
        // ==(lhs: BigInt, rhs: UInt)
        XCTAssertTrue(bint1 == uint1, "==(lhs: BigInt, rhs: UInt) failed")
        XCTAssertFalse(bint2 == uint1, "==(lhs: BigInt, rhs: UInt) failed")
        
        // ==(lhs: UInt, rhs: BigInt)
        XCTAssertTrue(uint1 == bint1, "==(lhs: UInt, rhs: BigInt) failed")
        XCTAssertFalse(uint1 == bint2, "==(lhs: UInt, rhs: BigInt) failed")
    }
    
    func testIntComparableIsLessThan() {
        let bint1 = BigInt(9876)
        let bint10 = BigInt(9876)
        let bint2 = BigInt(12345)
        
        let dbl1: Double = 9876
        let dbl2: Double = 12345
        
        let int1: Int = 9876
        let int2: Int = 12345
        
        let uint1: UInt = 9876
        let uint2: UInt = 12345
        
        // <(lhs: BigInt, rhs: BigInt)
        XCTAssertTrue(bint1 < bint2, "<(lhs: BigInt, rhs: BigInt) failed")
        XCTAssertFalse(bint1 < bint10, "<(lhs: BigInt, rhs: BigInt) failed")
        XCTAssertFalse(bint2 < bint1, "<(lhs: BigInt, rhs: BigInt) failed")
        
        // <(lhs: BigInt, rhs: Double)
        XCTAssertTrue(bint1 < dbl2, "<(lhs: BigInt, rhs: Double) failed")
        XCTAssertFalse(bint1 < dbl1, "<(lhs: BigInt, rhs: Double) failed")
        XCTAssertFalse(bint2 < dbl1, "<(lhs: BigInt, rhs: Double) failed")
        
        // <(lhs: Double, rhs: BigInt)
        XCTAssertTrue(dbl1 < bint2, "<(lhs: Double, rhs: BigInt) failed")
        XCTAssertFalse(dbl1 < bint1, "<(lhs: Double, rhs: BigInt) failed")
        XCTAssertFalse(dbl2 < bint1, "<(lhs: Double, rhs: BigInt) failed")
        
        // <(lhs: BigInt, rhs: Int)
        XCTAssertTrue(bint1 < int2, "<(lhs: BigInt, rhs: Int) failed")
        XCTAssertFalse(bint1 < int1, "<(lhs: BigInt, rhs: Int) failed")
        XCTAssertFalse(bint2 < int1, "<(lhs: BigInt, rhs: Int) failed")
        
        // <(lhs: Int, rhs: BigInt)
        XCTAssertTrue(int1 < bint2, "<(lhs: Int, rhs: BigInt) failed")
        XCTAssertFalse(int1 < bint1, "<(lhs: Int, rhs: BigInt) failed")
        XCTAssertFalse(int2 < bint1, "<(lhs: Int, rhs: BigInt) failed")
        
        // <(lhs: BigInt, rhs: UInt)
        XCTAssertTrue(bint1 < uint2, "<(lhs: BigInt, rhs: UInt) failed")
        XCTAssertFalse(bint1 < uint1, "<(lhs: BigInt, rhs: UInt) failed")
        XCTAssertFalse(bint2 < uint1, "<(lhs: BigInt, rhs: UInt) failed")
        
        // <(lhs: UInt, rhs: BigInt)
        XCTAssertTrue(uint1 < bint2, "<(lhs: UInt, rhs: BigInt) failed")
        XCTAssertFalse(uint1 < bint1, "<(lhs: UInt, rhs: BigInt) failed")
        XCTAssertFalse(uint2 < bint1, "<(lhs: UInt, rhs: BigInt) failed")
    }
    
    func testIntComparableIsLessThanOrEqual() {
        let bint1 = BigInt(9876)
        let bint10 = BigInt(9876)
        let bint2 = BigInt(12345)
        
        let dbl1: Double = 9876
        let dbl2: Double = 12345
        
        let int1: Int = 9876
        let int2: Int = 12345
        
        let uint1: UInt = 9876
        let uint2: UInt = 12345
        
        // <=(lhs: BigInt, rhs: BigInt)
        XCTAssertTrue(bint1 <= bint2, "<=(lhs: BigInt, rhs: BigInt) failed")
        XCTAssertTrue(bint1 <= bint10, "<=(lhs: BigInt, rhs: BigInt) failed")
        XCTAssertFalse(bint2 <= bint1, "<=(lhs: BigInt, rhs: BigInt) failed")
        
        // <=(lhs: BigInt, rhs: Double)
        XCTAssertTrue(bint1 <= dbl2, "<=(lhs: BigInt, rhs: Double) failed")
        XCTAssertTrue(bint1 <= dbl1, "<=(lhs: BigInt, rhs: Double) failed")
        XCTAssertFalse(bint2 <= dbl1, "<=(lhs: BigInt, rhs: Double) failed")
        
        // <=(lhs: Double, rhs: BigInt)
        XCTAssertTrue(dbl1 <= bint2, "<=(lhs: Double, rhs: BigInt) failed")
        XCTAssertTrue(dbl1 <= bint1, "<=(lhs: Double, rhs: BigInt) failed")
        XCTAssertFalse(dbl2 <= bint1, "<=(lhs: Double, rhs: BigInt) failed")
        
        // <=(lhs: BigInt, rhs: Int)
        XCTAssertTrue(bint1 <= int2, "<=(lhs: BigInt, rhs: Int) failed")
        XCTAssertTrue(bint1 <= int1, "<=(lhs: BigInt, rhs: Int) failed")
        XCTAssertFalse(bint2 <= int1, "<=(lhs: BigInt, rhs: Int) failed")
        
        // <=(lhs: Int, rhs: BigInt)
        XCTAssertTrue(int1 <= bint2, "<=(lhs: Int, rhs: BigInt) failed")
        XCTAssertTrue(int1 <= bint1, "<=(lhs: Int, rhs: BigInt) failed")
        XCTAssertFalse(int2 <= bint1, "<=(lhs: Int, rhs: BigInt) failed")
        
        // <=(lhs: BigInt, rhs: UInt)
        XCTAssertTrue(bint1 <= uint2, "<=(lhs: BigInt, rhs: UInt) failed")
        XCTAssertTrue(bint1 <= uint1, "<=(lhs: BigInt, rhs: UInt) failed")
        XCTAssertFalse(bint2 <= uint1, "<=(lhs: BigInt, rhs: UInt) failed")
        
        // <=(lhs: UInt, rhs: BigInt)
        XCTAssertTrue(uint1 <= bint2, "<=(lhs: UInt, rhs: BigInt) failed")
        XCTAssertTrue(uint1 <= bint1, "<=(lhs: UInt, rhs: BigInt) failed")
        XCTAssertFalse(uint2 <= bint1, "<=(lhs: UInt, rhs: BigInt) failed")
    }
    
    func testIntComparableIsGreaterThan() {
        let bint1 = BigInt(9876)
        let bint10 = BigInt(9876)
        let bint2 = BigInt(12345)
        
        let dbl1: Double = 9876
        let dbl2: Double = 12345
        
        let int1: Int = 9876
        let int2: Int = 12345
        
        let uint1: UInt = 9876
        let uint2: UInt = 12345
        
        // >(lhs: BigInt, rhs: BigInt)
        XCTAssertFalse(bint1 > bint2, ">(lhs: BigInt, rhs: BigInt) failed")
        XCTAssertFalse(bint1 > bint10, ">(lhs: BigInt, rhs: BigInt) failed")
        XCTAssertTrue(bint2 > bint1, ">(lhs: BigInt, rhs: BigInt) failed")
        
        // >(lhs: BigInt, rhs: Double)
        XCTAssertFalse(bint1 > dbl2, ">(lhs: BigInt, rhs: Double) failed")
        XCTAssertFalse(bint1 > dbl1, ">(lhs: BigInt, rhs: Double) failed")
        XCTAssertTrue(bint2 > dbl1, ">(lhs: BigInt, rhs: Double) failed")
        
        // >(lhs: Double, rhs: BigInt)
        XCTAssertFalse(dbl1 > bint2, ">(lhs: Double, rhs: BigInt) failed")
        XCTAssertFalse(dbl1 > bint1, ">(lhs: Double, rhs: BigInt) failed")
        XCTAssertTrue(dbl2 > bint1, ">(lhs: Double, rhs: BigInt) failed")
        
        // >(lhs: BigInt, rhs: Int)
        XCTAssertFalse(bint1 > int2, ">(lhs: BigInt, rhs: Int) failed")
        XCTAssertFalse(bint1 > int1, ">(lhs: BigInt, rhs: Int) failed")
        XCTAssertTrue(bint2 > int1, ">(lhs: BigInt, rhs: Int) failed")
        
        // >(lhs: Int, rhs: BigInt)
        XCTAssertFalse(int1 > bint2, ">(lhs: Int, rhs: BigInt) failed")
        XCTAssertFalse(int1 > bint1, ">(lhs: Int, rhs: BigInt) failed")
        XCTAssertTrue(int2 > bint1, ">(lhs: Int, rhs: BigInt) failed")
        
        // >(lhs: BigInt, rhs: UInt)
        XCTAssertFalse(bint1 > uint2, ">(lhs: BigInt, rhs: UInt) failed")
        XCTAssertFalse(bint1 > uint1, ">(lhs: BigInt, rhs: UInt) failed")
        XCTAssertTrue(bint2 > uint1, ">(lhs: BigInt, rhs: UInt) failed")
        
        // >(lhs: UInt, rhs: BigInt)
        XCTAssertFalse(uint1 > bint2, ">(lhs: UInt, rhs: BigInt) failed")
        XCTAssertFalse(uint1 > bint1, ">(lhs: UInt, rhs: BigInt) failed")
        XCTAssertTrue(uint2 > bint1, ">(lhs: UInt, rhs: BigInt) failed")
    }
    
    func testIntComparableIsGreaterThanOrEqual() {
        let bint1 = BigInt(9876)
        let bint10 = BigInt(9876)
        let bint2 = BigInt(12345)
        
        let dbl1: Double = 9876
        let dbl2: Double = 12345
        
        let int1: Int = 9876
        let int2: Int = 12345
        
        let uint1: UInt = 9876
        let uint2: UInt = 12345
        
        // >=(lhs: BigInt, rhs: BigInt)
        XCTAssertFalse(bint1 >= bint2, ">=(lhs: BigInt, rhs: BigInt) failed")
        XCTAssertTrue(bint1 >= bint10, ">=(lhs: BigInt, rhs: BigInt) failed")
        XCTAssertTrue(bint2 >= bint1, ">=(lhs: BigInt, rhs: BigInt) failed")
        
        // >=(lhs: BigInt, rhs: Double)
        XCTAssertFalse(bint1 >= dbl2, ">=(lhs: BigInt, rhs: Double) failed")
        XCTAssertTrue(bint1 >= dbl1, ">=(lhs: BigInt, rhs: Double) failed")
        XCTAssertTrue(bint2 >= dbl1, ">=(lhs: BigInt, rhs: Double) failed")
        
        // >=(lhs: Double, rhs: BigInt)
        XCTAssertFalse(dbl1 >= bint2, ">=(lhs: Double, rhs: BigInt) failed")
        XCTAssertTrue(dbl1 >= bint1, ">=(lhs: Double, rhs: BigInt) failed")
        XCTAssertTrue(dbl2 >= bint1, ">=(lhs: Double, rhs: BigInt) failed")
        
        // >=(lhs: BigInt, rhs: Int)
        XCTAssertFalse(bint1 >= int2, ">=(lhs: BigInt, rhs: Int) failed")
        XCTAssertTrue(bint1 >= int1, ">=(lhs: BigInt, rhs: Int) failed")
        XCTAssertTrue(bint2 >= int1, ">=(lhs: BigInt, rhs: Int) failed")
        
        // >=(lhs: Int, rhs: BigInt)
        XCTAssertFalse(int1 >= bint2, ">=(lhs: Int, rhs: BigInt) failed")
        XCTAssertTrue(int1 >= bint1, ">=(lhs: Int, rhs: BigInt) failed")
        XCTAssertTrue(int2 >= bint1, ">=(lhs: Int, rhs: BigInt) failed")
        
        // >=(lhs: BigInt, rhs: UInt)
        XCTAssertFalse(bint1 >= uint2, ">=(lhs: BigInt, rhs: UInt) failed")
        XCTAssertTrue(bint1 >= uint1, ">=(lhs: BigInt, rhs: UInt) failed")
        XCTAssertTrue(bint2 >= uint1, ">=(lhs: BigInt, rhs: UInt) failed")
        
        // >=(lhs: UInt, rhs: BigInt)
        XCTAssertFalse(uint1 >= bint2, ">=(lhs: UInt, rhs: BigInt) failed")
        XCTAssertTrue(uint1 >= bint1, ">=(lhs: UInt, rhs: BigInt) failed")
        XCTAssertTrue(uint2 >= bint1, ">=(lhs: UInt, rhs: BigInt) failed")
    }

    func testIntAddition() {
        let bint1 = BigInt(12345)
        let bint2 = BigInt(98765)
        
        let uint1: UInt = 12345
        let uint2: UInt = 98765
        let result: UInt = uint1 + uint2
        
        // +(lhs: BigInt, rhs: BigInt)
        var temp: BigInt = bint1 + bint2
        XCTAssertEqual("\(result)", temp.toString(), "+(lhs: BigInt, rhs: BigInt) failed")
        
        // +(lhs: BigInt, rhs: UInt)
        temp = bint1 + uint2
        XCTAssertEqual("\(result)", temp.toString(), "+(lhs: BigInt, rhs: UInt) failed")
        
        // +(lhs: UInt, rhs: BigInt)
        temp = uint1 + bint2
        XCTAssertEqual("\(result)", temp.toString(), "+(lhs: UInt, rhs: BigInt) failed")
        
        // +=(lhs: inout BigInt, rhs: BigInt)
        temp = BigInt(bint1)
        temp += bint2
        XCTAssertEqual("\(result)", temp.toString(), "+=(lhs: inout BigInt, rhs: BigInt) failed")
        
        // +=(lhs: inout BigInt, rhs: UInt)
        temp = BigInt(bint1)
        temp += uint2
        XCTAssertEqual("\(result)", temp.toString(), "+=(lhs: inout BigInt, rhs: UInt) failed")
    }
    
    func testIntSubtraction() {
        let bint1 = BigInt(12345)
        let bint2 = BigInt(98765)
        
        let uint1: UInt = 12345
        let uint2: UInt = 98765
        let result: UInt = uint2 - uint1
        
        // -(lhs: BigInt, rhs: BigInt)
        var temp: BigInt = bint2 - bint1
        XCTAssertEqual("\(result)", temp.toString(), "-(lhs: BigInt, rhs: BigInt) failed")
        
        // -(lhs: BigInt, rhs: UInt)
        temp = bint2 - uint1
        XCTAssertEqual("\(result)", temp.toString(), "-(lhs: BigInt, rhs: UInt) failed")
        
        // -(lhs: UInt, rhs: BigInt)
        temp = uint2 - bint1
        XCTAssertEqual("\(result)", temp.toString(), "-(lhs: UInt, rhs: BigInt) failed")
        
        // -=(lhs: inout BigInt, rhs: BigInt)
        temp = BigInt(bint2)
        temp -= bint1
        XCTAssertEqual("\(result)", temp.toString(), "-=(lhs: inout BigInt, rhs: BigInt) failed")
        
        // -=(lhs: inout BigInt, rhs: UInt)
        temp = BigInt(bint2)
        temp -= uint1
        XCTAssertEqual("\(result)", temp.toString(), "-=(lhs: inout BigInt, rhs: UInt) failed")
    }
    
    func testIntMultiplication() {
        let result = "1219253925"
        
        let bint1: BigInt = 12345
        let bint2: BigInt = 98765
        
        let int1 = 12345
        let int2 = 98765
        
        let uint1 = 12345
        let uint2 = 98765
        
        // *(lhs: BigInt, rhs: BigInt)
        var temp = bint1 * bint2
        XCTAssertEqual(result, temp.toString(), "*(lhs: BigInt, rhs: BigInt) failed")
        
        // *(lhs: BigInt, rhs: Int)
        temp = bint1 * int2
        XCTAssertEqual(result, temp.toString(), "*(lhs: BigInt, rhs: Int) failed")
        
        // *(lhs: Int, rhs: BigInt)
        temp = int1 * bint2
        XCTAssertEqual(result, temp.toString(), "*(lhs: Int, rhs: BigInt) failed")
        
        // *(lhs: BigInt, rhs: UInt)
        temp = bint1 * uint2
        XCTAssertEqual(result, temp.toString(), "*(lhs: BigInt, rhs: UInt) failed")
        
        // *(lhs: UInt, rhs: BigInt)
        temp = uint1 * bint2
        XCTAssertEqual(result, temp.toString(), "*(lhs: UInt, rhs: BigInt) failed")
        
        // *=(lhs: inout BigInt, rhs: BigInt)
        temp = BigInt(bint1)
        temp *= bint2
        XCTAssertEqual(result, temp.toString(), "*=(lhs: inout BigInt, rhs: BigInt) failed")
        
        // *=(lhs: inout BigInt, rhs: Int)
        temp = BigInt(bint1)
        temp *= int2
        XCTAssertEqual(result, temp.toString(), "*=(lhs: inout BigInt, rhs: Int) failed")
        
        // *=(lhs: inout BigInt, rhs: UInt)
        temp = BigInt(bint1)
        temp *= uint2
        XCTAssertEqual(result, temp.toString(), "*=(lhs: inout BigInt, rhs: UInt) failed")
    }
    
    func testIntBitwise() {
        let bint1: BigInt = 9
        let uint1: UInt = 3
        
        var temp = bint1 >> uint1
        XCTAssertEqual("\(9>>3)", temp.toString(), ">>(lhs: BigInt, rhs: UInt) failed")
        
        temp = bint1 << uint1
        XCTAssertEqual("\(9<<3)", temp.toString(), "<<(lhs: BigInt, rhs: UInt) failed")
    }
}
