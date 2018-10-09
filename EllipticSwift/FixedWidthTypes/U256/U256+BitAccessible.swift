//
//  U256+BitAccessible.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 19.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU256: BitAccessible {
    public func bit(_ i: Int) -> Bool {
        if i < 0 {
            return false
        } else if i < 128 {
            return self.v.0.bit(i)
        } else if i < 256 {
            return self.v.1.bit(i-128)
        }
        return false
    }
}

extension vU256: FixedWidth {
    public var leadingZeroBitCount: Int {
        if self.v.1.leadingZeroBitCount != 128 {
            return self.v.1.leadingZeroBitCount
        } else if self.v.0.leadingZeroBitCount != 128 {
            return 128 + self.v.0.leadingZeroBitCount
        }
        return 256
    }
    
    public var bitWidth: Int {
        if self.v.1.leadingZeroBitCount != 128 {
            return 256 - self.v.1.leadingZeroBitCount
        } else if self.v.0.leadingZeroBitCount != 128 {
            return 128 - self.v.0.leadingZeroBitCount
        }
        return 256
    }
    
    public var fullBitWidth: UInt32 {
        return 256
    }
}
