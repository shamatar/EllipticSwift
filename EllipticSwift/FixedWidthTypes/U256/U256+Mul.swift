//
//  U256+Mul.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256 {
    public func fullMul(_ a: U256) -> U512 {
        var result = U512()
        var aCopy = a
        var selfCopy = self
        vU256FullMultiply(&selfCopy, &aCopy, &result)
        return result
    }
        
    public func halfMul(_ a: U256) -> U256 {
        var result = U256()
        var aCopy = a
        var selfCopy = self
        vU256HalfMultiply(&selfCopy, &aCopy, &result)
        return result
    }
    
    public mutating func inplaceHalfMul(_ a: U256) {
        var aCopy = a
        var selfCopy = self
        vU256HalfMultiply(&selfCopy, &aCopy, &self)
    }
}
