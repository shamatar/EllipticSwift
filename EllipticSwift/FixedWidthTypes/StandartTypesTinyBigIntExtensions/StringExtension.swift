//
//  StringExtension.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 01.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

extension String {
    
    public init(_ storage: TinyUInt128, radix: Int = 10, uppercase: Bool = false) {
        self = storage.valueToString(radix: radix, uppercase: uppercase)
    }
    
    public init(_ storage: TinyUInt256, radix: Int = 10, uppercase: Bool = false) {
        self = storage.valueToString(radix: radix, uppercase: uppercase)
    }
    
    public init(_ storage: TinyUInt512, radix: Int = 10, uppercase: Bool = false) {
        self = storage.valueToString(radix: radix, uppercase: uppercase)
    }
}
