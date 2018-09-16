//
//  Geometry.swift
//  Utilities
//
//  Created by Spizzace on 3/24/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

public struct Point: CustomStringConvertible  {
    public var x: Rational
    public var y: Rational
    
    public var description: String {
        return "(x:\(self.x), y:\(self.y))"
    }
    
    public init(x: Rational, y: Rational) {
        self.x = x
        self.y = y
    }
}

public struct Line: CustomStringConvertible {
    //
    // ivars
    //
    public let point_1: Point
    public let point_2: Point
    public let slope: Rational?
    
    //
    // Initializers
    //
    public init(_ p1: Point, _ p2: Point) {
        self.point_1 = p1
        self.point_2 = p2
        
        // calculate slope
        if self.point_1.x == self.point_2.x {
            self.slope = nil
        } else if self.point_1.y == self.point_2.y {
            self.slope =  0
        } else {
            self.slope = (self.point_1.y - self.point_2.y) / (self.point_1.x - self.point_2.x)
        }
    }
        
    public init(x1: Rational, y1: Rational, x2: Rational, y2: Rational) {
        self.init(Point(x: x1, y: y1), Point(x: x2, y: y2))
    }
    
    //
    // Accessors
    //
    public var description: String {
        return "{\(self.point_1), \(self.point_2)}"
    }
    
    public func getY(x: Rational) -> Rational? {
        if let m = self.slope {
            return m * (x - self.point_1.x) + self.point_1.y
        } else {
            return nil
        }
    }
    
    public func getX(y: Rational) -> Rational? {
        if self.slope != nil && self.slope! != 0 {
            return (y - self.point_1.y) / self.slope! + self.point_1.x
        } else {
            return nil
        }
    }
    
    public func getYIntercept() -> Rational? {
        return self.getY(x: 0)
    }
    
    public func getXIntercept() -> Rational? {
        return self.getX(y: 0)
    }
    
    /**
     This function determines if a particular point is within the interval defined the line segement Self, i.e. (point_1, point_2)
     - Parameters:
        - point: The point being compared
        - includeEndpoints: Optional, should the comparison include the endpoints of the segment
     - Returns: A truth value
    */
    public func doesSegmentContain(point: Point, includeEndpoints: Bool = true) -> Bool {
        let y_max = max(self.point_1.y, self.point_2.y)
        let y_min = min(self.point_1.y, self.point_2.y)
        let x_max = max(self.point_1.x, self.point_2.x)
        let x_min = min(self.point_1.x, self.point_2.x)
        
        if includeEndpoints {
            return y_max >= point.y && point.y >= y_min
                && x_max >= point.x && point.x >= x_min
        } else {
            if self.point_1.y == self.point_2.y
                && self.point_1.y == point.y {
                return x_max > point.x && point.x > x_min
            } else if self.point_1.x == self.point_2.x
                && self.point_1.x == point.x {
                return y_max > point.y && point.y > y_min
            } else {
                return y_max > point.y && point.y > y_min
                    && x_max > point.x && point.x > x_min
            }
        }
    }
}

public struct Triangle {
    public var line_1: Line
    public var line_2: Line
    public var line_3: Line
    
    public var lines: [Line] {
        return [line_1, line_2, line_3]
    }
    
    // right triangles
    public static func area(leg leg_1: BigFloat, leg leg_2: BigFloat) -> BigFloat {
        return 0.5 * leg_1 * leg_2
    }
    
    // all triangles
    public static func area(side side_1: BigFloat, side side_2: BigFloat, side side_3: BigFloat) -> BigFloat {
        // Heron's Formula
        let s = 0.5 * (side_1 + side_2 + side_3)
        let surd = s * (s - side_1) * (s - side_2) * (s - side_3)
        
        return sqrt(surd)
    }
    
    public static func area(side side_1: BigFloat, angle: BigFloat, side side_2: BigFloat) -> BigFloat {
        return 0.5 * side_1 * side_2 * sin(angle)
    }
}

public struct Circle {
    public var radius: BigFloat
    
    public init(radius: BigFloat) {
        self.radius = radius
    }
    
    public func area() -> BigFloat {
        return self.radius * self.radius * BigFloat.pi
    }
    
    public func sectorArea(angle: BigFloat) -> BigFloat {
        return 0.5 * self.radius * self.radius * angle
    }
    
    public func segmentArea(angle: BigFloat) -> BigFloat {
        return 0.5 * self.radius * self.radius * (angle - sin(angle))
    }
}

public func intersection(line_1: Line, line_2: Line) -> Point? {
    let m_1 = line_1.slope
    let m_2 = line_2.slope
    
    if m_1 == m_2 {
        return nil
    }
    
    if m_1 == nil {
        let x = line_1.point_1.x
        let y = line_2.getY(x: x)!
        
        return Point(x: x, y: y)
    } else if m_2 == nil {
        let x = line_2.point_1.x
        let y = line_1.getY(x: x)!
        
        return Point(x: x, y: y)
    } else if m_1 == 0 {
        let y = line_1.point_1.y
        let x = line_2.getX(y: y)!
        
        return Point(x: x, y: y)
    } else if m_2 == 0 {
        let y = line_2.point_1.y
        let x = line_1.getX(y: y)!
        
        return Point(x: x, y: y)
    } else {
//        let y1_intercept = line_1.getYIntercept()!
//        let y2_intercept = line_2.getYIntercept()!
//
//        let x = (y2_intercept - y1_intercept) / (m_1! - m_2!)
//        let y = m_1! * x + y1_intercept
//
//        return Point(x: x, y: y)
        
        let x1 = line_1.point_1.x
        let y1 = line_1.point_1.y
        let x2 = line_1.point_2.x
        let y2 = line_1.point_2.y
        
        let x3 = line_2.point_1.x
        let y3 = line_2.point_1.y
        let x4 = line_2.point_2.x
        let y4 = line_2.point_2.y
        
        let temp1 = (x2*y1 - x1*y2)
        let temp2 = (x4*y3 - x3*y4)
        let denom = (x2 - x1) * (y4 - y3) - (x4 - x3) * (y2 - y1)
        
        let x = (temp1*(x4 - x3) - temp2*(x2 - x1)) / denom
        let y = (temp1*(y4 - y3) - temp2*(y2 - y1)) / denom
        
        return Point(x: x, y: y)
    }
}