//
//  TinyUInt128.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 17.07.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

public struct TinyUInt128: UnsignedInteger {
    
    // We contain UInt128 in two UInt64
    internal var storage: (firstHalf: UInt64, secondHalf: UInt64)
    
    public var significantBits: TinyUInt128 {
        return TinyUInt128(TinyUInt128.bitWidth - leadingZeroBitCount)
    }
    
    // BinaryFloatingPoint type passing
    internal var signBitIndex: Int {
        return 127 - leadingZeroBitCount
    }
    
    // MARK: Initializers
    public init(firstHalf: UInt64, secondHalf: UInt64) {
        storage.firstHalf = firstHalf
        storage.secondHalf = secondHalf
    }
    
    public init() {
        self.init(firstHalf: 0, secondHalf: 0)
    }
    
    public init(_ value: Int) {
        self.init(firstHalf: 0, secondHalf: UInt64(value))
    }
    
    public init(_ source: TinyUInt128) {
        self.init(firstHalf: source.storage.firstHalf,
                  secondHalf: source.storage.secondHalf)
    }
    
    public init(_ source: String) throws {
        guard let result = TinyUInt128.valueFromString(source) else {
            throw TinyUInt128Errors.wrongString
        }
        self = result
    }
}




