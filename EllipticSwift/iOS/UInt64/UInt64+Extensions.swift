//
//  UInt64+Extensions.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 07/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

let maskLowerBits = (UInt64(1) << 32) - 1
let maskHigherBits = maskLowerBits << 32

@inline(__always) func splitUInt64(_ a: UInt64) -> (UInt64, UInt64) {
    let top = a >> 32
    let bottom = a & maskLowerBits
    return (top, bottom)
}

// expects a to have 32 bit width and together form a 64 bit limb
// expects b to actually have 32 bits
//
@inline(__always) func mixedMulAdd(_ a: (UInt64, UInt64), _ b: UInt64, _ c: UInt64) -> (UInt64, UInt64) {
    let l0 = a.1 * b
    let l1 = a.0 * b
    var bottom = UInt64(0)
    var of = false
    var ofAfterMixedAdd = false
    var top = (l1 >> 32)
    (bottom, ofAfterMixedAdd) = l0.addingReportingOverflow(c)
    if ofAfterMixedAdd {
        top = top &+ 1
    }
    (bottom, of) = bottom.addingReportingOverflow(l1 << 32)
    if of {
        top = top &+ 1
    }
    return (top, bottom)
}

extension UInt64 {
    var halfShift: UInt64 {
        return UInt64(UInt64.bitWidth / 2)
        
    }
    var high: UInt64 {
        return self >> 32
    }
    
    var low: UInt64 {
        return self & maskLowerBits
    }
    
    var upshifted: UInt64 {
        return self << 32
    }
    
    var split: (high: UInt64, low: UInt64) {
        return (self.high, self.low)
    }
    
    init(_ value: (high: UInt64, low: UInt64)) {
        self = value.high.upshifted + value.low
    }
}

@inline(__always) func quotient(dividing u: (high: UInt64, low: UInt64), by vn: UInt64) -> UInt64 {
    let (vn1, vn0) = vn.split
    // Get approximate quotient.
    let (q, r) = u.high.quotientAndRemainder(dividingBy: vn1)
    let p = q * vn0
    // q is often already correct, but sometimes the approximation overshoots by at most 2.
    // The code that follows checks for this while being careful to only perform single-digit operations.
    if q.high == 0 && p <= r.upshifted + u.low { return q }
    let r2 = r + vn1
    if r2.high != 0 { return q - 1 }
    if (q - 1).high == 0 && p - vn0 <= r2.upshifted + u.low { return q - 1 }
    //assert((r + 2 * vn1).high != 0 || p - 2 * vn0 <= (r + 2 * vn1).upshifted + u.low)
    return q - 2
}

@inline(__always) func quotientAndRemainder(dividing u: (high: UInt64, low: UInt64), by v: UInt64) -> (quotient: UInt64, remainder: UInt64) {
    let q = quotient(dividing: u, by: v)
    let r = UInt64(u) &- q &* v
    assert(r < v)
    return (q, r)
}

@inline(__always) func fastDividingFullWidth(_ dividend: (high: UInt64, low: UInt64), _ divisor: UInt64) -> (quotient: UInt64, remainder: UInt64) {
    precondition(dividend.high < divisor)
    
    // Normalize the dividend and the divisor (self) such that the divisor has no leading zeroes.
    let z = UInt64(divisor.leadingZeroBitCount)
    let w = UInt64(divisor.bitWidth) - z
    let vn = divisor << z
    
    let un32 = (z == 0 ? dividend.high : (dividend.high &<< z) | (dividend.low &>> w)) // No bits are lost
    let un10 = dividend.low &<< z
    let (un1, un0) = un10.split
    
    // Divide `(un32,un10)` by `vn`, splitting the full 4/2 division into two 3/2 ones.
    let (q1, un21) = quotientAndRemainder(dividing: (un32, un1), by: vn)
    let (q0, rn) = quotientAndRemainder(dividing: (un21, un0), by: vn)
    
    // Undo normalization of the remainder and combine the two halves of the quotient.
    let mod = rn >> z
    let div = UInt64((q1, q0))
    return (div, mod)
}

@inline(__always) func approximateQuotient(dividing x: (UInt64, UInt64, UInt64), by y: (UInt64, UInt64)) -> UInt64 {
    // Start with q = (x.0, x.1) / y.0, (or Word.max on overflow)
    var q: UInt64
    var r: UInt64
    if x.0 == y.0 {
        q = UInt64.max
        let (s, o) = x.0.addingReportingOverflow(x.1)
        if o { return q }
        r = s
    } else {
        (q, r) = fastDividingFullWidth((x.0, x.1), y.0)
    }
    // Now refine q by considering x.2 and y.1.
    // Note that since y is normalized, q * y - x is between 0 and 2.
    let (ph, pl) = q.multipliedFullWidth(by: y.1)
    if ph < r || (ph == r && pl <= x.2) { return q }

    let (r1, ro) = r.addingReportingOverflow(y.0)
    if ro { return q - 1 }

    let (pl1, so) = pl.subtractingReportingOverflow(y.1)
    let ph1 = (so ? ph - 1 : ph)

    if ph1 < r1 || (ph1 == r1 && pl1 <= x.2) { return q - 1 }
    return q - 2
}

@inline(__always) func approximateQuotientNotNormalized(dividing x: (UInt64, UInt64, UInt64), by y: (UInt64, UInt64)) -> (UInt64, Bool) {
    // 3 by 2 division algorithm requires y.high > 2^(n-1) (no leading zeroes)
    var q: UInt64
    var r: UInt64
    
//    if x.0 > y.0 {
//        (q, r) = x.0.quotientAndRemainder(dividingBy: y.0)
//    } else
    if x.0 == y.0 {
        q = UInt64.max
        let (s, o) = x.0.addingReportingOverflow(x.1)
        if o { return (q, false) }
        r = s
    } else {
        (q, r) = fastDividingFullWidth((x.0, x.1), y.0)
    }
    // Now refine q by considering x.2 and y.1.
    // Note that since y is normalized, q * y - x is between 0 and 2.
    let (ph, pl) = q.multipliedFullWidth(by: y.1)
    if ph < r || (ph == r && pl <= x.2) { return (q, false)}
    
    let (r1, ro) = r.addingReportingOverflow(y.0)
    if ro { return (q - 1, false) }
    
    let (pl1, so) = pl.subtractingReportingOverflow(y.1)
    let ph1 = (so ? ph - 1 : ph)
    
    if ph1 < r1 || (ph1 == r1 && pl1 <= x.2) { return (q - 1, false) }
    return (q - 2, false)
}
