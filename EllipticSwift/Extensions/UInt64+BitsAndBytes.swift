//
//  UInt64+BitsAndBytes.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 25.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension UInt64: BitsAndBytes {
    public var bytes: Data {
        let arr = [UInt8]([
            UInt8((self >> 56) & 0xff),
            UInt8((self >> 48) & 0xff),
            UInt8((self >> 40) & 0xff),
            UInt8((self >> 32) & 0xff),
            UInt8((self >> 24) & 0xff),
            UInt8((self >> 16) & 0xff),
            UInt8((self >> 8) & 0xff),
            UInt8(self & 0xff)])
        return Data(arr)
    }
    
    public func bit(_ i: Int) -> Bool {
        return self & (1 << 1) != 0
    }
    
    public var fullBitWidth: UInt32 {
        return 8
    }
    
    public var isZero: Bool {
        return self == 0
    }
    
    public static var zero: UInt64 {
        return UInt64(0)
    }
}
