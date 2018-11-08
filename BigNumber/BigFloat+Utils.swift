//
//  BigFloat+Utils.swift
//  BigNumber
//
//  Created by Spizzace on 3/23/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation
import MPFR

public func floor(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_floor(&result.float_impl.float, &n.float_impl.float)
    
    return result
}

public func ceil(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_ceil(&result.float_impl.float, &n.float_impl.float)
    
    return result
}

public func sqrt(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_sqrt(&result.float_impl.float, &n.float_impl.float, BigFloat.defaultRounding)
    
    return result
}

public func sin(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_sin(&result.float_impl.float, &n.float_impl.float, BigFloat.defaultRounding)
    
    return result
}

public func cos(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_cos(&result.float_impl.float, &n.float_impl.float, BigFloat.defaultRounding)
    
    return result
}

public func tan(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_tan(&result.float_impl.float, &n.float_impl.float, BigFloat.defaultRounding)
    
    return result
}

public func asin(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_asin(&result.float_impl.float, &n.float_impl.float, BigFloat.defaultRounding)
    
    return result
}

public func acos(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_acos(&result.float_impl.float, &n.float_impl.float, BigFloat.defaultRounding)
    
    return result
}

public func atan(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_atan(&result.float_impl.float, &n.float_impl.float, BigFloat.defaultRounding)
    
    return result
}
