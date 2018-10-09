//
//  U256+Add.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU256 {
    public func addMod(_ a: vU256) -> vU256 {
        var result = vU256()
        var aCopy = a
        var selfCopy = self
        vU256Add(&selfCopy, &aCopy, &result)
        return result
    }
    
    public mutating func inplaceAddMod(_ a: vU256) {
        var aCopy = a
        var selfCopy = self
        vU256Add(&selfCopy, &aCopy, &self)
    }
}
