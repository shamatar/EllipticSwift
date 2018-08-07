//
//  U512+Mod.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 01.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U512 {
    public func modInv(_ modulus: U512) -> U512 {
        var a = self
        var new = U512.one
        var old = U512.zero
        var q = modulus
        var r = U512.zero
        var h = U512.zero
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
}
