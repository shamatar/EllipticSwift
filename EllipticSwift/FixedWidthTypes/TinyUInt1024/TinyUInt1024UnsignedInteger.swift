//
//  TinyUInt512.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

public struct TinyUInt1024: UnsignedInteger {
    
    
    // We contain UInt1024 in two TinyUInt512
    internal var storage: (firstHalf: TinyUInt512, secondHalf: TinyUInt512)
    
    public var significantBits: TinyUInt1024 {
        return TinyUInt1024(TinyUInt1024.bitWidth - leadingZeroBitCount)
    }
    
    // BinaryFloatingPoint type passing
    internal var signBitIndex: Int {
        return 1023 - leadingZeroBitCount
    }
    
    // MARK: Initializers
    public init(firstHalf: TinyUInt512, secondHalf: TinyUInt512) {
        storage.firstHalf = firstHalf
        storage.secondHalf = secondHalf
    }
    
    public init() {
        self.init(firstHalf: 0, secondHalf: 0)
    }
    
    public init(_ value: Int) {
        self.init(firstHalf: 0, secondHalf: TinyUInt512(value))
    }
    
    public init(_ source: TinyUInt1024) {
        self.init(firstHalf: source.storage.firstHalf,
                  secondHalf: source.storage.secondHalf)
    }
    
    public init(_ source: String) throws {
        guard let result = TinyUInt1024.valueFromString(source) else {
            throw TinyUInt1024Errors.wrongString
        }
        self = result
    }
}




