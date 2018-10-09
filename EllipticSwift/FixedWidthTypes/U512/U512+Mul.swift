//
//  U512+Mul.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 01.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU512 {
    public func fullMul(_ a: vU512) -> vU1024 {
        var result = vU1024()
        var aCopy = a
        var selfCopy = self
        vU512FullMultiply(&selfCopy, &aCopy, &result)
        return result
    }
    
    public func halfMul(_ a: vU512) -> vU512 {
        var result = vU512()
        var aCopy = a
        var selfCopy = self
        vU512HalfMultiply(&selfCopy, &aCopy, &result)
        return result
    }
    
    public mutating func inplaceHalfMul(_ a: vU512) {
        var aCopy = a
        var selfCopy = self
        vU512HalfMultiply(&selfCopy, &aCopy, &self)
    }
}
