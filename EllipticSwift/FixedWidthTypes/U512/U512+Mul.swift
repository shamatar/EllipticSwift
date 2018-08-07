//
//  U512+Mul.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 01.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U512 {
    public func fullMul(_ a: U512) -> U1024 {
        var result = U1024()
        var aCopy = a
        var selfCopy = self
        vU512FullMultiply(&selfCopy, &aCopy, &result)
        return result
    }
    
    public func halfMul(_ a: U512) -> U512 {
        var result = U512()
        var aCopy = a
        var selfCopy = self
        vU512HalfMultiply(&selfCopy, &aCopy, &result)
        return result
    }
    
    public mutating func inplaceHalfMul(_ a: U512) {
        var aCopy = a
        var selfCopy = self
        vU512HalfMultiply(&selfCopy, &aCopy, &self)
    }
}
