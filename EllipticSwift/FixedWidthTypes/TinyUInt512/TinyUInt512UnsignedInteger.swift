//
//  TinyUInt512.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

public struct TinyUInt512: UnsignedInteger {
    
    
    // We contain UInt512 in two TinyUInt256
    internal var storage: (firstHalf: TinyUInt256, secondHalf: TinyUInt256)
    
    public var significantBits: TinyUInt512 {
        return TinyUInt512(TinyUInt512.bitWidth - leadingZeroBitCount)
    }
    
    // BinaryFloatingPoint type passing
    internal var signBitIndex: Int {
        return 511 - leadingZeroBitCount
    }
    
    // MARK: Initializers
    public init(firstHalf: TinyUInt256, secondHalf: TinyUInt256) {
        storage.firstHalf = firstHalf
        storage.secondHalf = secondHalf
    }
    
    public init() {
        self.init(firstHalf: 0, secondHalf: 0)
    }
    
    public init(_ value: Int) {
        self.init(firstHalf: 0, secondHalf: TinyUInt256(value))
    }
    
    public init(_ source: TinyUInt512) {
        self.init(firstHalf: source.storage.firstHalf,
                  secondHalf: source.storage.secondHalf)
    }
    
    public init(_ source: String) throws {
        guard let result = TinyUInt512.valueFromString(source) else {
            throw TinyUInt512Errors.wrongString
        }
        self = result
    }
}




