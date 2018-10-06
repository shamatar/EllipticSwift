//
//  TinyUInt128ExpressibleByIntegerLitera.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 01.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming ExpressibleByIntegerLiteral (for Numeric conforming)
 */
extension TinyUInt128: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral storage: IntegerLiteralType) {
        self.init(firstHalf: 0, secondHalf: UInt64(storage))
    }
    
}
