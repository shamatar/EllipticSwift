//
//  U256+Div.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256 {
    public func div(_ a: U256) -> (U256, U256) {
        var result = U256()
        var remainder = U256()
        var aCopy = a
        var selfCopy = self
        vU256Divide(&selfCopy, &aCopy, &result, &remainder)
        return (result, remainder)
    }
}
