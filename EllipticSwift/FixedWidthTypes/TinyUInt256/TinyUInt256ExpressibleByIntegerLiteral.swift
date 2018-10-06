//
//  TinyUInt256ExpressibleByIntegerLitera.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming ExpressibleByIntegerLiteral (for Numeric conforming)
 */
extension TinyUInt256: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral storage: IntegerLiteralType) {
        self.init(firstHalf: 0, secondHalf: TinyUInt128(storage))
    }
    
}
