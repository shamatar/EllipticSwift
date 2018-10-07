//
//  TinyUInt128+FF.swift
//  EllipticSwift_iOS
//
//  Created by Alex Vlasov on 05/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TinyUInt128: BytesInitializable {
    public init?(_ bytes: Data) {
        if bytes.count > 16 {
            return nil
        }
        var bottom = UInt64(0)
        var end = 8
        if bytes.count <= 8 {
            end = bytes.count
            for i in stride(from: 0, to: end, by: 1).reversed() {
                bottom |= UInt64(bytes[i]) << (8 * (end - 1 - i))
            }
            self = TinyUInt128(firstHalf: 0, secondHalf: bottom)
            return
        } else {
            end = bytes.count
            for i in stride(from: end - 8, to: end, by: 1).reversed() {
                bottom |= UInt64(bytes[i]) << (8 * (end - 1 - i))
            }
            var top = UInt64(0)
            end = 8
            if bytes.count < 16 {
                end = bytes.count - 8
            }
            for i in stride(from: 0, to: end, by: 1).reversed() {
                top |= UInt64(bytes[i]) << (8 * (end - 1 - i))
            }
            self = TinyUInt128(firstHalf: top, secondHalf: bottom)
        }
    }
}

extension TinyUInt128: BitsAndBytes {
    public var bytes: Data {
        return self.storage.firstHalf.bytes + self.storage.secondHalf.bytes
    }
    
    public func bit(_ i: Int) -> Bool {
        if i < 0 {
            return false
        } else if i < 64 {
            return self.storage.secondHalf & (UInt64(1) << i) > 0
        } else if i < 128 {
            return self.storage.firstHalf & (UInt64(1) << i) > 0
        }
        return false
    }
    
    public var fullBitWidth: UInt32 {
        return 128
    }
    
    public var bitWidth: Int {
        return 128 - self.leadingZeroBitCount
    }
    
    public var isZero: Bool {
        return self.storage.firstHalf.isZero && self.storage.secondHalf.isZero
    }
}

extension TinyUInt128: EvenOrOdd {
    public var isEven: Bool {
        return self.storage.secondHalf & UInt64(1) == 0
    }
}
