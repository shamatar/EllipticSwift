//
//  U512+Sub.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 01.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U512 {
    public func subMod(_ a: U512) -> U512 {
        var result = U512()
        var aCopy = a
        var selfCopy = self
        vU512Sub(&selfCopy, &aCopy, &result)
        return result
    }
    
    public mutating func inplaceSubMod(_ a: U512) {
        var aCopy = a
        var selfCopy = self
        vU512Sub(&selfCopy, &aCopy, &self)
    }
}
