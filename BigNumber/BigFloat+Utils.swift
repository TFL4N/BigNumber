//
//  BigFloat+Utils.swift
//  BigNumber
//
//  Created by Spizzace on 3/23/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation
import MPFR

public func sqrt(_ n: BigFloat) -> BigFloat {
    let result = BigFloat()
    
    mpfr_sqrt(&result.float, &n.float, BigFloat.defaultRounding)
    
    return result
}
