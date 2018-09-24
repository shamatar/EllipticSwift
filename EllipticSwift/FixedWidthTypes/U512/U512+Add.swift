//
//  U512+Add.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 01.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U512 {
    public func addMod(_ a: U512) -> U512 {
        var result = U512()
        var aCopy = a
        var selfCopy = self
        vU512Add(&selfCopy, &aCopy, &result)
        return result
    }
    
    public mutating func inplaceAddMod(_ a: U512) {
        var aCopy = a
        var selfCopy = self
        vU512Add(&selfCopy, &aCopy, &self)
    }
}
