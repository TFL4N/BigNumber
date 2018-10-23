//
//  BezierCurve.swift
//  BigNumber
//
//  Created by Spizzace on 10/22/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

public class BezierCurve<T: SignedNumeric & UnsignedIntegerArithmetic>: CustomStringConvertible {
    public typealias PolyType = Polynomial<T>
    public typealias GeneratorType = (T)->Point<T>
    
    let p0:PolyType
    let p1:PolyType
    let p2:PolyType
    let p3:PolyType
    
    public var description: String {
        return "{p0: \(self.p0), p1: \(self.p1), p2: \(self.p2), p3: \(self.p3)}"
    }
    
    public convenience init() {
        self.init(p0: [1,-3,3,-1], p1: [0,3,-6,3], p2: [0,0,3,-3], p3: [0,0,0,1])
    }
    
    private init(p0: PolyType, p1: PolyType, p2: PolyType, p3: PolyType) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
    }
    
    public func derivative() -> BezierCurve {
        return BezierCurve(p0: self.p0.derivative(),
                           p1: self.p1.derivative(),
                           p2: self.p2.derivative(),
                           p3: self.p3.derivative())
    }
    
    public func integral() -> BezierCurve {
        return BezierCurve(p0: self.p0.integral(),
                           p1: self.p1.integral(),
                           p2: self.p2.integral(),
                           p3: self.p3.integral())
    }
    
    public static func getControlPoints<S:Numeric>(t: S, p0: Point<S>, p1: Point<S>, p2: Point<S>, p3: Point<S>) -> (q: (Point<S>,Point<S>,Point<S>), r: (Point<S>,Point<S>), b: Point<S>) {
        let q0 = BezierCurve.linearInterpolation(t: t, p0: p0, p1: p1)
        let q1 = BezierCurve.linearInterpolation(t: t, p0: p1, p1: p2)
        let q2 = BezierCurve.linearInterpolation(t: t, p0: p2, p1: p3)
        
        let r0 = BezierCurve.linearInterpolation(t: t, p0: q0, p1: q1)
        let r1 = BezierCurve.linearInterpolation(t: t, p0: q1, p1: q2)
        
        let b = BezierCurve.linearInterpolation(t: t, p0: r0, p1: r1)
        
        return ((q0,q1,q2),(r0,r1),b)
    }
    
    private static func linearInterpolation<S : Numeric>(t: S, p0: Point<S>, p1: Point<S>) -> Point<S> {
        return Point<S>(x: (1-t)*p0.x + t*p1.x,
                     y: (1-t)*p0.y + t*p1.y)
    }
    
    public static func getQPointFunctions<S : Numeric>(p0: Point<S>, p1: Point<S>, p2: Point<S>, p3: Point<S>) -> (q0: (S)->Point<S>, q1: (S)->Point<S>, q2: (S)->Point<S>) {
        let q0 = { (t: S)->Point<S> in
            return BezierCurve.linearInterpolation(t: t, p0: p0, p1: p1)
        }
        let q1 = { (t: S)->Point<S> in
            return BezierCurve.linearInterpolation(t: t, p0: p1, p1: p2)
        }
        let q2 = { (t: S)->Point<S> in
            return BezierCurve.linearInterpolation(t: t, p0: p2, p1: p3)
        }
        
        return (q0,q1,q2)
    }
    
    public static func getRPointFunctions<S : Numeric>(p0: Point<S>, p1: Point<S>, p2: Point<S>, p3: Point<S>) -> (r0: (S)->Point<S>, r1: (S)->Point<S>) {
        let q_functions = BezierCurve.getQPointFunctions(p0: p0, p1: p1, p2: p2, p3: p3)
        
        let r0 = { (t: S)->Point<S> in
            let q0 = q_functions.q0(t)
            let q1 = q_functions.q1(t)
            
            return BezierCurve.linearInterpolation(t: t, p0: q0, p1: q1)
        }
        
        let r1 = { (t: S)->Point<S> in
            let q1 = q_functions.q1(t)
            let q2 = q_functions.q2(t)
            
            return BezierCurve.linearInterpolation(t: t, p0: q1, p1: q2)
        }
        
        return (r0,r1)
    }
    
    public static func getBPointFunction<S : Numeric>(p0: Point<S>, p1: Point<S>, p2: Point<S>, p3: Point<S>) -> (S)->Point<S> {
        let r_functions = BezierCurve.getRPointFunctions(p0: p0, p1: p1, p2: p2, p3: p3)
        
        return { (t: S)->Point<S> in
            let r0 = r_functions.r0(t)
            let r1 = r_functions.r1(t)
            
            return BezierCurve.linearInterpolation(t: t, p0: r0, p1: r1)
        }
    }
    
    public static func *(lhs: BezierCurve, rhs: BezierCurve) -> BezierCurve {
        return BezierCurve(p0: lhs.p0 * rhs.p0,
                           p1: lhs.p1 * rhs.p1,
                           p2: lhs.p2 * rhs.p2,
                           p3: lhs.p3 * rhs.p3)
    }
}
