//
//  U256+Div.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU256 {
    public func div(_ a: vU256) -> (vU256, vU256) {
        var result = vU256()
        var remainder = vU256()
        var aCopy = a
        var selfCopy = self
        vU256Divide(&selfCopy, &aCopy, &result, &remainder)
        return (result, remainder)
    }
}
