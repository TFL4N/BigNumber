//
//  GMP+Utils.swift
//  BigNumber
//
//  Created by Spizzace on 10/4/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation
import GMP

public typealias MPZ_Pointer = UnsafeMutablePointer<mpz_t>

extension UnsafeMutablePointer: CustomStringConvertible where Pointee == mpz_t {
    public var description: String {
        return self.pointee.description
    }
}

extension mpz_t: CustomStringConvertible {
    public var description: String {
        let ptr = UnsafeMutablePointer<mpz_t>.allocate(capacity: 1)
        ptr.initialize(to: self)
        
        defer {
            ptr.deinitialize(count: 1)
            ptr.deallocate()
        }
        
        return String(cString: __gmpz_get_str(nil, 10, ptr))
    }
}
