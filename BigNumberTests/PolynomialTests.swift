//
//  PolynomialTests.swift
//  BigNumberTests
//
//  Created by Spizzace on 10/19/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import XCTest
@testable import BigNumber

class PolynomialTests: XCTestCase {

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
    
    func testPolynomialIntegral() {
        let foo: Polynomial<Rational> = [1,1]
        let poly: Polynomial<Polynomial<Rational>> = [foo,foo,foo,foo,foo]
        
        print(poly.integral())
        print(poly.integral())
        print(poly.integral())
        print(poly.integral())
    }

    func testPolynomials() {
        print("\n\n\n")
        
        typealias Constant = Polynomial<Rational>
        
//        var p0:Constant = [1]
//        var p1:Constant = [1]
//        var p2:Constant = [1]
//        var p3:Constant = [1]
        
        func getBezierPolynomial<T:Numeric>(p0: T, p1: T, p2: T, p3: T) -> Polynomial<T> {
            let foo = Polynomial<T>([0:1,1:-1])
            
            var B: Polynomial<T> = 0
            B += fastExponentation(foo, 3) * (p0 * 3)
            B += Polynomial<T>(arrayLiteral: 0,1) * fastExponentation(foo, 2) * (3 * p1)
            B += Polynomial<T>(arrayLiteral: 0,0,1) * foo * (3 * p2)
            B += Polynomial<T>(arrayLiteral: 0,0,0,1) * p3
            
            return B
        }
        
        let x: Polynomial<Constant> =
            getBezierPolynomial(p0: [1], p1: [1], p2: [0,1], p3: [0])
        let y: Polynomial<Constant> =
            getBezierPolynomial(p0: [0], p1: [0,1], p2: [1], p3: [1])
        
//        let y: Polynomial<Constant> =
//            getBezierPolynomial(p0: [1], p1: [1], p2: [0,1], p3: [0])
//        let x: Polynomial<Constant> =
//            getBezierPolynomial(p0: [0], p1: [0,1], p2: [1], p3: [1])
        
        let area_polynomial = y * x.derivative()
    
        print(x)
        print(x.derivative())
        print(y)
        print("!",area_polynomial)
        print(area_polynomial.integral())
        
        let area = area_polynomial.integral(min: [0], max: [1])
        print("!",area)
        print()

        let a = BigFloat(area.coefficients[2]!)
        let b = BigFloat(area.coefficients[1]!)
        let c = BigFloat(area.coefficients[0]!) - (BigFloat.pi / 4)

        let roots = quadraticRoots(ax2: a, bx: b, c: c)!
        print(roots)

//        let v = roots.0
        let v = roots.1

        //////////////////
//        let foo:[Rational] = [Rational(-9,10), Rational(-6,5), Rational(3/20)]
//        var bar = foo.map{BigFloat($0)}
//        bar[0] -= BigFloat.pi/4
//        let temp = Polynomial<BigFloat>(bar)
//
//        print(v)
//        print(temp.getValue(v))
//        print(BigFloat.pi/4)
//        print("!", quadraticRoots(ax2: BigFloat(3,20), bx: BigFloat(-6,5), c: BigFloat(-9,10))!)
//        print("!", quadraticRoots(ax2: BigFloat(3,20), bx: BigFloat(-6,5), c: BigFloat(-9,10) - (BigFloat.pi/4))!)
//        print(4.0 + sqrt(22.0))
//        print(4.0 - sqrt(22.0))
        ////////////////////
        
//        let new_x: Polynomial<BigFloat> =
//            getBezierPolynomial(p0: 1, p1: 1, p2: BigFloat(v), p3: 0)
//        let new_y: Polynomial<BigFloat> =
//            getBezierPolynomial(p0: 0, p1: BigFloat(v), p2: 1, p3: 1)
        
        let new_y: Polynomial<BigFloat> =
            getBezierPolynomial(p0: 1, p1: 1, p2: v, p3: 0)
        let new_x: Polynomial<BigFloat> =
            getBezierPolynomial(p0: 0, p1: v, p2: 1, p3: 1)

        let new_x_dt = new_x.derivative()
        let new_y_dt = new_y.derivative()

        let d = new_y_dt*new_y_dt + new_x_dt*new_x_dt

        let length = approximateIntegral(min: 0.0, max: 1.0, n: 1_000_000) { (x) -> BigFloat in
            return sqrt(d.getValue(x))
        }

        print(length)
        print(BigFloat.pi/2)
        
        print("\n\n\n")
    }
}
