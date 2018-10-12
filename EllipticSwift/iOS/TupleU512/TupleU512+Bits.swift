//
//  TupleU512+Bits.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 12/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU512: Zeroable {
    public var isZero: Bool {
        return self.storage.0 == 0 &&
            self.storage.1 == 0 &&
            self.storage.2 == 0 &&
            self.storage.3 == 0 &&
            self.storage.4 == 0 &&
            self.storage.5 == 0 &&
            self.storage.6 == 0 &&
            self.storage.7 == 0
    }
}

extension TupleU512: BytesInitializable {
    public init?(_ bytes: Data) {
        if bytes.count > 64 {
            return nil
        }
        var new = TupleU512()
        let d = Data(repeating: 0, count: 64 - bytes.count) + bytes
        d.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> Void in
            let ptr = UnsafeRawPointer(ptr).assumingMemoryBound(to: UInt64.self)
            for i in 0 ..< U512WordWidth {
                let t = ptr[i]
                let swapped = t.byteSwapped
                new[U512WordWidth - 1 - i] = swapped
            }
        }
        self = new
    }
}

extension TupleU512: BitsAndBytes {
    public func bit(_ i: Int) -> Bool {
        if i < 0 {
            return false
        } else if i < 64 {
            return self[0] & (UInt64(1) << i) > 0
        } else if i < 128 {
            return self[1] & (UInt64(1) << (i - 64)) > 0
        } else if i < 192 {
            return self[2] & (UInt64(1) << (i - 128)) > 0
        } else if i < 256 {
            return self[3] & (UInt64(1) << (i - 192)) > 0
        } else if i < 320 {
            return self[4] & (UInt64(1) << (i - 256)) > 0
        } else if i < 384 {
            return self[5] & (UInt64(1) << (i - 320)) > 0
        } else if i < 44 {
            return self[6] & (UInt64(1) << (i - 384)) > 0
        } else if i < 512 {
            return self[7] & (UInt64(1) << (i - 448)) > 0
        }
        return false
    }
    
    public var fullBitWidth: UInt32 {
        return 512
    }
    
    public var bitWidth: Int {
        return 512 - self.leadingZeroBitCount
    }
    
    public var leadingZeroBitCount: Int {
        if self[7] != 0 {
            return self[7].leadingZeroBitCount
        } else if self[6] != 0 {
            return self[6].leadingZeroBitCount + 64
        } else if self[5] != 0 {
            return self[5].leadingZeroBitCount + 128
        } else if self[4] != 0 {
            return self[4].leadingZeroBitCount + 192
        } else if self[3] != 0 {
            return self[3].leadingZeroBitCount + 256
        } else if self[2] != 0 {
            return self[2].leadingZeroBitCount + 320
        } else if self[1] != 0 {
            return self[1].leadingZeroBitCount + 384
        } else {
            return self[0].leadingZeroBitCount + 448
        }
    }
    
    public var bytes: Data {
        var res = Data()
        for i in (0 ..< U512WordWidth).reversed() {
            res += self[i].bytes
        }
        return res
    }
}

extension TupleU512: BitShiftable {
    public static func << (lhs: TupleU512, rhs: UInt32) -> TupleU512 {
        precondition(rhs <= 64)
        var new = TupleU512()
        for i in (1 ..< U512WordWidth).reversed() {
            new[i] = (lhs[i] << rhs) | (lhs[i-1] >> (64 - rhs))
        }
        new[0] = lhs[0] << rhs
        return new
    }
    
    public static func <<= (lhs: inout TupleU512, rhs: UInt32) {
        precondition(rhs <= 64)
        var new = TupleU512()
        for i in (1 ..< U512WordWidth).reversed() {
            new[i] = (lhs[i] << rhs) | (lhs[i-1] >> (64 - rhs))
        }
        new[0] = lhs[0] << rhs
        lhs.storage = new.storage
    }
    
    public static func >> (lhs: TupleU512, rhs: UInt32) -> TupleU512 {
        precondition(rhs <= 64)
        var new = TupleU512()
        for i in (0 ..< U512WordWidth-1).reversed() {
            new[i] = (lhs[i] >> rhs) | (lhs[i+1] << (64 - rhs))
        }
        new[U512WordWidth-1] = lhs[U512WordWidth-1] >> rhs
        return new
    }
    
    public static func >>= (lhs: inout TupleU512, rhs: UInt32) {
        precondition(rhs <= 64)
        var new = TupleU512()
        for i in (0 ..< U512WordWidth-1).reversed() {
            new[i] = (lhs[i] >> rhs) | (lhs[i+1] << (64 - rhs))
        }
        new[U512WordWidth-1] = lhs[U512WordWidth-1] >> rhs
        lhs.storage = new.storage
    }
}
