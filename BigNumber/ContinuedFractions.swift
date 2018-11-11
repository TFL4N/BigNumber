//
//  ContinuedFractions.swift
//  BigNumber
//
//  Created by Spizzace on 11/11/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

public typealias ContinuedFractionExpansion = (UInt, [UInt])

/**
 The square root of very positive squarefree integer can be expressed as continued fraction with a repeating period.
 [ProofWiki](https://proofwiki.org/wiki/Continued_Fraction_Expansion_of_Irrational_Square_Root/Example/13/Convergents)
 
 This function will accept square numbers, and simply return a tuple with the square root and an empty array, as expected.
 
 - Parameter n: A positive integer
 - Returns: A tuple with the whole root, and an array of the repeating period
 */
public func continuedFractionExpansionOfQuadraticSurd(_ n: UInt) -> ContinuedFractionExpansion {
    // check if perfect square
    let root = sqrt(Double(n))
    let sq_floor_n = floor(root)
    if root == sq_floor_n {
        return (UInt(root), [])
    }
    
    ///
    func findNextTerm(P: UInt, Q: UInt, a: UInt) -> (P: UInt, Q: UInt, a: UInt) {
        let Pr = a * Q - P
        let Qr = (n - Pr*Pr) / Q
        let ar = UInt(floor((sq_floor_n + Double(Pr)) / Double(Qr)))
        
        return (Pr, Qr, ar)
    }
    
    ////
    let a0 = UInt(sq_floor_n)
    var expansion = [a0]
    let first = findNextTerm(P: 0, Q: 1, a: a0 )
    var tuple = first
    repeat {
        expansion.append(tuple.a)
        tuple = findNextTerm(P: tuple.P, Q: tuple.Q, a: tuple.a)
    } while tuple != first
    
    return (expansion.removeFirst(), expansion)
}

/**
 This function computes the continued fraction expansion of a quadratic irrational of the form:
 ```
 (a + sqrt(b)) / c
 ```
 
 TODO: Make this capable of handling all fraction.  Currently it only handles irrationals.  If fraction simplies to a rational or just a quadratic surd, handle these cases separately
 
 References:
 
 [Alpertron](https://www.alpertron.com.ar/CONTFRAC.HTM)
 
 - Parameters:
 - a: Integer part of the numerator
 - b: Quadratic surd
 - c: Denominator
 
 - Returns: A tuple containing the integer part, leading non-repeating fractional parts, and repeating fractional parts
 */
public func continueFractionExpansion(a: BigInt, b: BigInt, c: BigInt) -> (BigInt,[BigInt],[BigInt]) {
    /*
     PQa algorithm for (P+G)/Q where G = sqrt(discriminant):
     If D - U^2 is not multiple of V then
     U = U*V
     V = V*V
     G = G*V
     U1 <- 1, U2 <- 0
     V1 <- 0, V2 <- 1
     
     Perform loop:
     a = floor((U + G)/V)
     U3 <- U2, U2 <- U1, U1 <- a*U2 + U3
     V3 <- V2, V2 <- V1, V1 <- a*V2 + V3
     U <- a*V - U
     V <- (D - U^2)/V
     */
    
    
    var a: BigInt = a
    var b: BigInt = b
    var c: BigInt = c
    
    if !(b - a*a).isMultiple(of: c) {
        a *= c
        b *= c*c
        c *= c
    }
    
    var a1: BigInt = 1
    var a2: BigInt = 0
    var a3: BigInt = 0
    var c1: BigInt = 0
    var c2: BigInt = 1
    var c3: BigInt = 1
    
    var repeat_index = 0
    var output = [BigInt]()
    var previous = [(a:BigInt,c:BigInt)]()
    main_loop: while true {
        let x = (a + sqrt(b)) / c
        
        a3 = a2
        a2 = a1
        a1 = x*a2 + a3
        
        c3 = c2
        c2 = c1
        c1 = x*c2 + c3
        
        a = x*c - a
        c = (b - a*a) / c
        
        /// check if repeats
        let pair = (a,c)
        loop: for (i,e) in previous.enumerated() {
            if i == 0 {
                continue
            }
            
            if e == pair {
                repeat_index = i
                break loop
            }
        }
        
        if repeat_index > 0 {
            break main_loop
        }
        
        /// add new coefficient
        output.append(x)
        previous.append(pair)
    }
    
    return (output[0], Array(output[1..<repeat_index]), Array(output[repeat_index...]))
}

/**
 This function calculations the Nth convergent of a Continued Fraction Expansion.
 
 - Parameters:
 - n: Zero indexed Nth convergent to be found
 - continuedFraction: The ContinuedFractionExpansion describing the convergence
 - Returns: A Rational of the Nth convergent
 */
public func getConvergent(n: UInt, continuedFraction expansion: ContinuedFractionExpansion ) -> Rational {
    if n == 0 || expansion.1.isEmpty {
        return Rational(expansion.0)
    }
    
    let period = expansion.1.count
    var depth = Int(n) - 1
    var num = Rational(expansion.1[depth % period])
    while depth > 0 {
        depth -= 1
        
        num = Rational(expansion.1[depth % period]) + num.inverse()
    }
    
    return expansion.0 + num.inverse()
}

/**
 This function enumerates the convergents of a continued fraction starting from the 0th convergent to the Nth.  It keep returning the N+1 convergent until false is set to the first parameter of the handler closure
 
 - Precondition: The continued fraction's expansion period must be nonzero
 - Parameter handler: A closure of the form, (Stop, Convergent, Depth)
 */
public func enumerateConvergents(continuedFraction: ContinuedFractionExpansion, handler: ((inout Bool,Rational,Int)->Void)) {
    let expanse = continuedFraction.1
    let period = expanse.count
    var stop = false
    
    var depth: Int = 0
    var p: UInt = continuedFraction.0
    var p_1: UInt = p
    var p_2: UInt = 0
    
    var q: UInt = 1
    var q_1: UInt = q
    var q_2: UInt = 0
    
    
    // 0
    handler(&stop,Rational(p,q),depth)
    if stop {
        return
    }
    
    // 1
    depth = 1
    q = expanse[1%period]
    p = p*q + 1
    
    handler(&stop,Rational(p,q),depth)
    
    while !stop {
        depth += 1
        
        p_2 = p_1
        q_2 = q_1
        
        p_1 = p
        q_1 = q
        
        let a_k = expanse[(depth-1)%period]
        p = a_k*p_1 + p_2
        q = a_k*q_1 + q_2
        
        //        print("--------")
        //        print("k: ", depth)
        //        print("a_k: ", a_k)
        //        print("p: ", p, " : ", p_1, " : ", p_2)
        //        print("q: ", q, " : ", q_1, " : ", q_2)
        //        print(Rational(p,q))
        //        print("--------")
        
        handler(&stop,Rational(p,q),depth)
    }
}
