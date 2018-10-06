//
//  TinyUInt512+FF.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 06/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TinyUInt512 {
    func addMod(_ a: TinyUInt512) -> TinyUInt512 {
        let (res, _) = self.addingReportingOverflow(a)
        return res
    }
    func subMod(_ a: TinyUInt512) -> TinyUInt512 {
        let (res, _) = self.subtractingReportingOverflow(a)
        return res
    }
    func halfMul(_ a: TinyUInt512) -> TinyUInt512 {
        let (res, _) = self.multipliedReportingOverflow(by: a)
        return res
    }
}

extension TinyUInt512: ModReducable {
    public func modMultiply(_ a: TinyUInt512, _ modulus: TinyUInt512) -> TinyUInt512 {
        let fullMul =  self.fullMultiply(a)
        // second half is lower bits in BE
        let extended = TinyUInt1024(firstHalf: fullMul.0, secondHalf: fullMul.1)
        let extendedModulus = TinyUInt1024(firstHalf: TinyUInt512(0), secondHalf: modulus)
        let (_, reduced) = extended.quotientAndRemainder(dividingBy: extendedModulus)
        return reduced.storage.secondHalf
    }
    
    public func mod(_ modulus: TinyUInt512) -> TinyUInt512 {
        let (_, rem) = self.quotientAndRemainder(dividingBy: modulus)
        return rem
    }
    
    public func modInv(_ modulus: TinyUInt512) -> TinyUInt512 {
        var a = self
        let zero = TinyUInt512(0)
        let one = TinyUInt512(1)
        var new = one
        var old = zero
        var q = modulus
        var r = zero
        var h = zero
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
    
    public func div(_ a: TinyUInt512) -> (TinyUInt512, TinyUInt512) {
        return self.quotientAndRemainder(dividingBy: a)
    }
    
    public func fullMultiply(_ a: TinyUInt512) -> (TinyUInt512, TinyUInt512) {
        let res = self.multipliedFullWidth(by: a)
        return (res.high, res.low)
    }
    
    public var isZero: Bool {
        return self.storage.firstHalf.isZero && self.storage.secondHalf.isZero
    }
}
