//
//  TinyUInt128ExpressibleByStringLiteral.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 30.07.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming ExpressibleByStringLiteral for add possibility to init UInt128 from string
 */
extension TinyUInt128: ExpressibleByStringLiteral {
    
    internal static func valueFromString(_ storage: String) -> TinyUInt128? {
        
        let result = (TinyUInt128._determineRadixFromString(storage) == 10) ?
            storage :
            String(storage.dropFirst(2))
        
        return TinyUInt128(result, radix: TinyUInt128._determineRadixFromString(storage))
    }
    
    internal static func _determineRadixFromString(_ string: String) -> Int {
        
        switch string.prefix(2) {
        case "0b":
            return 2
        case "0o":
            return 8
        case "0x":
            return 16
        default:
            return 10
        }
    }
    
    // MARK: Initializer
    public init(stringLiteral storage: StringLiteralType) {
        self.init()
        
        if let result = TinyUInt128.valueFromString(storage) {
            self = result
        }
    }
    
}
