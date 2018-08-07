//
//  U256+Mont.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 30.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256: MontArithmeticsCompatible {
    
    static var montR = U512(v: (vZERO, vZERO, vUInt32(1), vZERO))
    
    public static func getMontParams(_ a: U256) -> (U256, U256, U256) {
        let ONE = U256.one
        let montR = U256.max.mod(a) + ONE
        // Montgommery R params is 2^256
        var primeU512 = U512(v: (a.v.0, a.v.1, vZERO, vZERO))
        var montInvRfullWidth = U256.montR.modInv(primeU512)
        var RmulRinvFullWidth = U512(v: (vZERO, vZERO, montInvRfullWidth.v.0, montInvRfullWidth.v.1)) // virtual multiply by hand
        var subtracted = U512()
        var u512One = U512.one
        vU512Sub(&RmulRinvFullWidth, &u512One, &subtracted)
        var montKfullWidth = U512()
        var remainder = U512()
        vU512Divide(&subtracted, &primeU512, &montKfullWidth, &remainder)
        let (_, montInvR) = montInvRfullWidth.split()
        let (_, montK) = montKfullWidth.split()
        return (montR, montInvR, montK)
    }
    
    public func toMontForm(_ modulus: U256) -> U256 {
        var multipliedByR = U512(v: (vZERO, vZERO, self.v.0, self.v.1)) // trivial bitshift
        var paddedModulus = U512(v: (modulus.v.0, modulus.v.1, vZERO, vZERO))
        var remainder = U512()
        vU512Mod(&multipliedByR, &paddedModulus, &remainder)
        let (_, b) = remainder.split()
        return b
    }
    
    public func montMul(_ b: U256, modulus: U256, montR: U256, montInvR: U256, montK: U256) -> U256 {
        
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
        var v = U512()
        var t = U512()
        vU256FullMultiply(&s, &modulusCopy, &v) // v = s*modulus
        var x512 = U512(v: (x.v.0, x.v.1, vZERO, vZERO)) // pad x to 512 bits
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
