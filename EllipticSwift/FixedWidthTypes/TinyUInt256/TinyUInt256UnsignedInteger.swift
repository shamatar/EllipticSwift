//
//  TinyUInt256.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

public struct TinyUInt256: UnsignedInteger {
    
    
    // We contain UInt256 in two TinyUInt128
    internal var storage: (firstHalf: TinyUInt128, secondHalf: TinyUInt128)
    
    public var significantBits: TinyUInt256 {
//        var bits: TinyUInt256 = 0
//        var shift: TinyUInt128 = 0
//        if self.storage.firstHalf == 0 && self.storage.secondHalf == 0 {
//            return bits
//        }
//
//        shift = self.storage.firstHalf > 0 ?
//            self.storage.firstHalf :
//            self.storage.secondHalf
//
//        bits = self.storage.firstHalf > 0 ? 64 : 0
//
//        repeat {
//            bits += 1
//            shift >>= 1
//        } while shift > 0
//
//        return bits
        return TinyUInt256(TinyUInt256.bitWidth - leadingZeroBitCount)
    }
    
    // BinaryFloatingPoint type passing
    internal var signBitIndex: Int {
        return 255 - leadingZeroBitCount
    }
    
    // MARK: Initializers
    public init(firstHalf: TinyUInt128, secondHalf: TinyUInt128) {
        storage.firstHalf = firstHalf
        storage.secondHalf = secondHalf
    }
    
    public init() {
        self.init(firstHalf: 0, secondHalf: 0)
    }
    
    public init(_ value: Int) {
        self.init(firstHalf: 0, secondHalf: TinyUInt128(value))
    }
    
    public init(_ source: TinyUInt256) {
        self.init(firstHalf: source.storage.firstHalf,
                  secondHalf: source.storage.secondHalf)
    }
    
    public init(_ source: String) throws {
        guard let result = TinyUInt256.valueFromString(source) else {
            throw TinyUInt256Errors.wrongString
        }
        self = result
    }
}




