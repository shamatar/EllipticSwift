//
//  U128+BitAccessible.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 19.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU128: BitAccessible {
    public func bit(_ i: Int) -> Bool {
        if i < 0 {
            return false
        } else if i < 32 {
            return self.v.x & (UInt32(1) << i) > 0
        } else if i < 64 {
            return self.v.y & (UInt32(1) << (i-32)) > 0
        } else if i < 96 {
            return self.v.z & (UInt32(1) << (i-64)) > 0
        } else if i < 128 {
            return self.v.w & (UInt32(1) << (i-96)) > 0
        }
        return false
    }
}
