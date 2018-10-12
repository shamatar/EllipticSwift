//
//  TupleU256+Mod.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 12/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU256: ModReducable {
    public func modMultiply(_ a: TupleU256, _ modulus: TupleU256) -> TupleU256 {
        let fullMul = self.fullMul(a)
        let extendedModulus = TupleU512((TupleU256(), modulus))
        let (_, reduced) = fullMul.divide(by: extendedModulus)
        let (_, b) = reduced.split()
        return b
    }
    
    public func mod(_ modulus: TupleU256) -> TupleU256 {
        let (_, rem) = self.div(modulus)
        return rem
    }
    
    public func modInv(_ modulus: TupleU256) -> TupleU256 {
        var a = TupleU256(self)
        let zero = TupleU256(UInt64(0))
        let one = TupleU256(UInt64(1))
        var new = TupleU256(one)
        var old = TupleU256(zero)
        var q = TupleU256(modulus)
        var r = TupleU256(zero)
        var h = TupleU256(zero)
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
    
    public func fullMultiply(_ a: TupleU256) -> (TupleU256, TupleU256) {
        let (t, b) = self.fullMul(a).split()
        return (t, b)
    }
}
