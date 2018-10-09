//
//  U256+Mont.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 30.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU256: MontArithmeticsCompatible {
    
    static var montR = vU512(v: (vZERO, vZERO, vUInt32(1), vZERO))
    
    public static func getMontParams(_ a: vU256) -> (vU256, vU256, vU256) {
        let ONE = vU256.one
        let montR = vU256.max.mod(a) + ONE
        // Montgommery R params is 2^256
        var primeU512 = vU512(v: (a.v.0, a.v.1, vZERO, vZERO))
        var montInvRfullWidth = vU256.montR.modInv(primeU512)
        var RmulRinvFullWidth = vU512(v: (vZERO, vZERO, montInvRfullWidth.v.0, montInvRfullWidth.v.1)) // virtual multiply by hand
        var subtracted = vU512()
        var u512One = vU512.one
        vU512Sub(&RmulRinvFullWidth, &u512One, &subtracted)
        var montKfullWidth = vU512()
        var remainder = vU512()
        vU512Divide(&subtracted, &primeU512, &montKfullWidth, &remainder)
        let (_, montInvR) = montInvRfullWidth.split()
        let (_, montK) = montKfullWidth.split()
        return (montR, montInvR, montK)
    }
    
    public func toMontForm(_ modulus: vU256) -> vU256 {
        var multipliedByR = vU512(v: (vZERO, vZERO, self.v.0, self.v.1)) // trivial bitshift
        var paddedModulus = vU512(v: (modulus.v.0, modulus.v.1, vZERO, vZERO))
        var remainder = vU512()
        vU512Mod(&multipliedByR, &paddedModulus, &remainder)
        let (_, b) = remainder.split()
        return b
    }
    
    public func montMul(_ b: vU256, modulus: vU256, montR: vU256, montInvR: vU256, montK: vU256) -> vU256 {
        
        //        x=a¯b¯.
        //
        //        s=(xk mod r).
        //
        //        t=x+sn.
        //
        //        u=t/r.
        //
        //        c¯=if (u<n) then (u) else (u−n).
        //
        //        c=(c¯r−1 mod n).
        
        // here we use a multiplication in a "true" form with R = 2^256 !
        var modulusCopy = modulus
//        var x = self.halfMul(b)
        var x = self.modMultiply(b, modulus)
        var s = x.halfMul(montK)
        var v = vU512()
        var t = vU512()
        vU256FullMultiply(&s, &modulusCopy, &v) // v = s*modulus
        var x512 = vU512(v: (x.v.0, x.v.1, vZERO, vZERO)) // pad x to 512 bits
        vU512Add(&v, &x512, &t) // t = x + s*modulus
        
        let (u, bottom) = t.split()
        if (!bottom.isZero) {
            return U256.zero
        }
//        precondition(!u.isZero)
        if u < modulus {
            return u
        } else {
            return u.subMod(modulus)
        }
    }
}
