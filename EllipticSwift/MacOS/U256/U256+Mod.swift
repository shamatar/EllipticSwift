//
//  U256+Mod.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU256: ModReducable {
    public func mod(_ modulus: vU256) -> vU256 {
        var result = vU256()
        var modCopy = modulus
        var selfCopy = self
        vU256Mod(&selfCopy, &modCopy, &result)
        return result
    }
    
    public mutating func inplaceMod(_ modulus: vU256) {
        var modCopy = modulus
        var selfCopy = self
        vU256Mod(&selfCopy, &modCopy, &self)
    }
    
    public func modInv(_ modulus: vU256) -> vU256 {
        var a = self
        var new = vU256.one
        var old = vU256.zero
        var q = modulus
        var r = vU256.zero
        var h = vU256.zero
        var positive = false
        while !a.isZero {
            (q, r) = q.div(a)
            h = q.halfMul(new).addMod(old)
            old = new
            new = h
            q = a
            a = r
            positive = !positive
        }
        if positive {
            return old
        } else {
            return modulus.subMod(old)
        }
    }
    
    public func modMultiply(_ a: vU256, _ modulus: vU256) -> vU256 {
        var result = vU512()
        var aCopy = a
        var selfCopy = self
        vU256FullMultiply(&selfCopy, &aCopy, &result)
        var extendedModulus = vU512(v: (modulus.v.0, modulus.v.1, vUInt32(0), vUInt32(0)))
        var extendedRes = vU512()
        vU512Mod(&result, &extendedModulus, &extendedRes)
        let (_, bottom) = extendedRes.split()
        return bottom
    }
    
    public func fullMultiply(_ a: vU256) -> (vU256, vU256) {
        let result: vU512 = self.fullMul(a)
        return result.split()
    }
    
}
