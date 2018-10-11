//
//  TupleU256+Bits.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU256: Zeroable {
    public var isZero: Bool {
        return self.storage.0 == 0 &&
            self.storage.1 == 0 &&
            self.storage.2 == 0 &&
            self.storage.3 == 0
    }
}

extension TupleU256: BytesInitializable {
    public init?(_ bytes: Data) {
        if bytes.count > 32 {
            return nil
        }
        var new = TupleU256()
        let d = Data(repeating: 0, count: 32 - bytes.count) + bytes
        d.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> Void in
            let ptr = UnsafeRawPointer(ptr).assumingMemoryBound(to: UInt64.self)
            for i in 0 ..< U256WordWidth {
                let t = ptr[i]
                let swapped = t.byteSwapped
                new[U256WordWidth - 1 - i] = swapped
            }
        }
        self = new
    }
}

extension TupleU256: BitsAndBytes {
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
        }
        return false
    }
    
    public var fullBitWidth: UInt32 {
        return 256
    }
    
    public var bitWidth: Int {
        return 256 - self.leadingZeroBitCount
    }
    
    public var leadingZeroBitCount: Int {
        if self[3] != 0 {
            return self[3].leadingZeroBitCount
        } else if self[2] != 0 {
            return self[2].leadingZeroBitCount + 64
        } else if self[1] != 0 {
            return self[1].leadingZeroBitCount + 128
        } else {
            return self[0].leadingZeroBitCount + 192
        }
    }
    
    public var bytes: Data {
        var res = Data()
        for i in (0 ..< U256WordWidth).reversed() {
            res += self[i].bytes
        }
        return res
    }
}

extension TupleU256: BitShiftable {
    public static func << (lhs: TupleU256, rhs: UInt32) -> TupleU256 {
        precondition(rhs <= 64)
        var new = TupleU256()
        for i in (1 ..< U256WordWidth).reversed() {
            new[i] = (lhs[i] << rhs) | (lhs[i-1] >> (64 - rhs))
        }
        new[0] = lhs[0] << rhs
        return new
    }
    
    public static func <<= (lhs: inout TupleU256, rhs: UInt32) {
        precondition(rhs <= 64)
        var new = TupleU256()
        for i in (1 ..< U256WordWidth).reversed() {
            new[i] = (lhs[i] << rhs) | (lhs[i-1] >> (64 - rhs))
        }
        new[0] = lhs[0] << rhs
        lhs.storage = new.storage
    }
    
    public static func >> (lhs: TupleU256, rhs: UInt32) -> TupleU256 {
        precondition(rhs <= 64)
        var new = TupleU256()
        for i in (0 ..< U256WordWidth-1).reversed() {
            new[i] = (lhs[i] >> rhs) | (lhs[i+1] << (64 - rhs))
        }
        new[U256WordWidth-1] = lhs[U256WordWidth-1] >> rhs
        return new
    }
    
    public static func >>= (lhs: inout TupleU256, rhs: UInt32) {
        precondition(rhs <= 64)
        var new = TupleU256()
        for i in (0 ..< U256WordWidth-1).reversed() {
            new[i] = (lhs[i] >> rhs) | (lhs[i+1] << (64 - rhs))
        }
        new[U256WordWidth-1] = lhs[U256WordWidth-1] >> rhs
        lhs.storage = new.storage
    }
}
