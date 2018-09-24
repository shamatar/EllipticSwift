//
//  U256+Sub.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256 {
    public func subMod(_ a: U256) -> U256 {
        var result = U256()
        var aCopy = a
        var selfCopy = self
        vU256Sub(&selfCopy, &aCopy, &result)
        return result
    }
    
    public mutating func inplaceSubMod(_ a: U256) {
        var aCopy = a
        var selfCopy = self
        vU256Sub(&selfCopy, &aCopy, &self)
    }
}
