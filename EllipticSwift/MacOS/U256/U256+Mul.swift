//
//  U256+Mul.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU256 {
    public func fullMul(_ a: vU256) -> vU512 {
        var result = vU512()
        var aCopy = a
        var selfCopy = self
        vU256FullMultiply(&selfCopy, &aCopy, &result)
        return result
    }
        
    public func halfMul(_ a: vU256) -> vU256 {
        var result = vU256()
        var aCopy = a
        var selfCopy = self
        vU256HalfMultiply(&selfCopy, &aCopy, &result)
        return result
    }
    
    public mutating func inplaceHalfMul(_ a: vU256) {
        var aCopy = a
        var selfCopy = self
        vU256HalfMultiply(&selfCopy, &aCopy, &self)
    }
}
