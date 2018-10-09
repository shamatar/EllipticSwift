//
//  vU512+Add.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 01.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU512 {
    public func addMod(_ a: vU512) -> vU512 {
        var result = vU512()
        var aCopy = a
        var selfCopy = self
        vU512Add(&selfCopy, &aCopy, &result)
        return result
    }
    
    public mutating func inplaceAddMod(_ a: vU512) {
        var aCopy = a
        var selfCopy = self
        vU512Add(&selfCopy, &aCopy, &self)
    }
}
