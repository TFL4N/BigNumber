//
//  BinomialNumber.swift
//  BigNumber
//
//  Created by Spizzace on 11/7/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

/**
 This function returns the factors of a binomial number of the form:
 ```
 x^n - 1
 ```
 */
public func getBinomialNumberFactors(_ n: UInt, additionOrSubtraction: Bool = false) -> [Polynomial<BigInt>] {
    var factors: [Polynomial<BigInt>] = [[n: 1,
                                          0: additionOrSubtraction ? 1 : -1]]
    var output: [Polynomial<BigInt>] = []
    
    while !factors.isEmpty {
        var f = factors.remove(at: 0)
        f.normalize()
        
        if canBeSimplified(f) {
            factors.insert(contentsOf: simplify(f), at: 0)
        } else {
            output.append(f)
        }
    }
    
    return output
}

private func canBeSimplified(_ poly: Polynomial<BigInt>) -> Bool {
    guard poly.coefficients.count == 2,
        let constant = poly[0] else {
            return false
    }
    
    let exponent = poly.coefficients.first { (pair) -> Bool in
        return pair.key != UInt(0)
        }!.key
    
    if constant > 0 {
        // positive
        let log = log2(Double(exponent))
        return floor(log) != log /// is power of 2
    } else {
        // negative
        return exponent > 1
    }
}

private func createPolynomialFactor(n: UInt, multiple: UInt = 1, positive: Bool) -> Polynomial<BigInt> {
    var exponents = [UInt:BigInt]()
    
    for exp in 0...n {
        if positive {
            exponents[exp*multiple] = (exp % 2 == 0) ? 1 : -1
        } else {
            exponents[exp*multiple] = 1
        }
    }
    
    return Polynomial<BigInt>(exponents)
}

private func simplify(_ poly: Polynomial<BigInt>) -> [Polynomial<BigInt>] {
    let constant = poly[0]!
    let exponent = poly.coefficients.first { (pair) -> Bool in
        return pair.key != UInt(0)
        }!.key
    
    let is_positive = constant > 0
    
    if is_positive {
        // positive
        let divs = divisors(Int(exponent), sorted: true, includeSelf: false).filter{$0%2 != 0}
        // odd divs only
        if divs.count > 1 {
            let n = UInt(divs[1])
            let m = exponent / n
            
            return [[m: 1, 0: 1], createPolynomialFactor(n: n-1, multiple: m, positive: true)]
        } else {
            return [[1: 1, 0: 1], createPolynomialFactor(n: exponent-1, positive: true)]
        }
    } else {
        // negative
        if  exponent % 2 == UInt(0) {
            // even
            let new_exp = exponent / 2
            return [[new_exp: 1, 0: -1], [new_exp: 1, 0: 1]]
        } else {
            // odd
            let divs = divisors(Int(exponent), sorted: true, includeSelf: false)
            if divs.count > 1 {
                let m = UInt(divs.last!)
                let n = UInt(divs[1])
                
                return [[m: 1, 0: -1], createPolynomialFactor(n: n-1, multiple: m, positive: false)]
            } else {
                // prime
                return [[1: 1, 0: -1], createPolynomialFactor(n: exponent-1, positive: false)]
            }
        }
    }
}
