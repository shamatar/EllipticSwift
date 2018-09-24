//
//  U256+Mod.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256: ModReducable {
    public func mod(_ modulus: U256) -> U256 {
        var result = U256()
        var modCopy = modulus
        var selfCopy = self
        vU256Mod(&selfCopy, &modCopy, &result)
        return result
    }
    
    public mutating func inplaceMod(_ modulus: U256) {
        var modCopy = modulus
        var selfCopy = self
        vU256Mod(&selfCopy, &modCopy, &self)
    }
    
    public func modInv(_ modulus: U256) -> U256 {
        var a = self
        var new = U256.one
        var old = U256.zero
        var q = modulus
        var r = U256.zero
        var h = U256.zero
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
    
    public func modMultiply(_ a: U256, _ modulus: U256) -> U256 {
        var result = U512()
        var aCopy = a
        var selfCopy = self
        vU256FullMultiply(&selfCopy, &aCopy, &result)
        var extendedModulus = U512(v: (modulus.v.0, modulus.v.1, vUInt32(0), vUInt32(0)))
        var extendedRes = U512()
        vU512Mod(&result, &extendedModulus, &extendedRes)
        let (_, bottom) = extendedRes.split()
        return bottom
    }
    
    public func fullMultiply(_ a: U256) -> (U256, U256) {
//        var result = U512()
//        var aCopy = a
//        var selfCopy = self
//        vU256FullMultiply(&selfCopy, &aCopy, &result)
        let result: U512 = self.fullMul(a)
        return result.split()
    }
    
//    public func modAdd(_ a: U256, _ modulus: U256) -> U256 {
//        var result = U256()
//        var aCopy = a
//        var selfCopy = self
//        vU256FullMultiply(&selfCopy, &aCopy, &result)
//        var extendedModulus = U512(v: (modulus.v.0, modulus.v.1, vUInt32(0), vUInt32(0)))
//        var extendedRes = U512()
//        vU512Mod(&result, &extendedModulus, &extendedRes)
//        let (_, bottom) = extendedRes.split()
//        return bottom
//    }
    
}
