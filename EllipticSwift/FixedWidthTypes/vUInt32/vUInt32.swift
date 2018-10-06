//
//  vUInt32.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 14.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

public var vZERO: vUInt32 = vUInt32(0)

extension vUInt32 {
    public var isZero: Bool {
        return self.x == 0 && self.y == 0 && self.z == 0 && self.w == 0
    }
    
    public init(_ value: UInt32) {
        self = vUInt32(x: value, y: 0, z: 0, w: 0)
    }
    
    public var bigEndianBytes: Data {
        return self.w.bigEndianBytes + self.z.bigEndianBytes + self.y.bigEndianBytes + self.x.bigEndianBytes
    }
    
    public var clippedValue: UInt64 {
        var res = UInt64(self.x)
        res += UInt64(self.y) << 32
        return res
    }
}

extension vUInt32: Zeroable {
    public static var zero: vUInt32 {
        return vUInt32()
    }
}

extension vUInt32: EvenOrOdd {
    public var isEven: Bool {
        return self.x & UInt32(1) == UInt32(0)
    }
}

extension vUInt32: Comparable {
    public static func < (lhs: vUInt32, rhs: vUInt32) -> Bool {
        if lhs.w > rhs.w {
            return false
        } else if lhs.w < rhs.w {
            return true
        }
        if lhs.z > rhs.z {
            return false
        } else if lhs.z < rhs.z {
            return true
        }
        if lhs.y > rhs.y {
            return false
        } else if lhs.y < rhs.y {
            return true
        }
        if lhs.x > rhs.x {
            return false
        } else if lhs.x < rhs.x {
            return true
        }
        return false
    }
}

extension vUInt32: BitAccessible {
    public func bit(_ i: Int) -> Bool {
        if i < 0 {
            return false
        } else if i < 32 {
            return self.x & (UInt32(1) << i) != 0
        } else if i < 64 {
            return self.y & (UInt32(1) << (i-32)) != 0
        } else if i < 96 {
            return self.z & (UInt32(1) << (i-64)) != 0
        } else if i < 128 {
            return self.w & (UInt32(1) << (i-96)) != 0
        }
        return false
    }
}

extension vUInt32 {
    public var leadingZeroBitCount: Int {
        if self.w.leadingZeroBitCount != 32 {
            return self.w.leadingZeroBitCount
        } else if self.z.leadingZeroBitCount != 32 {
            return 32 + self.z.leadingZeroBitCount
        } else if self.y.leadingZeroBitCount != 32 {
            return 64 + self.y.leadingZeroBitCount
        } else if self.x.leadingZeroBitCount != 32 {
            return 96 + self.x.leadingZeroBitCount
        }
        return 128
    }
}
