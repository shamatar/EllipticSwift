//
//  TupleU512+Div.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 12/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU512 {
    @inline(__always) internal mutating func inplaceDivide(byWord y: UInt64) -> UInt64 {
        precondition(y > 0)
        if y == 1 { return 0 }
        
        var remainder: UInt64 = 0
        for i in (0 ..< U512WordWidth).reversed() {
            let u = self[i]
            (self[i], remainder) = fastDividingFullWidth((remainder, u), y)
        }
        return remainder
    }
    
    @inline(__always) internal mutating func quotientAndRemainder(dividingByWord y: UInt64) -> (quotient: TupleU512, remainder: UInt64) {
        var div = TupleU512(self)
        let mod = div.inplaceDivide(byWord: y)
        return (div, mod)
    }
    
    public func div(_ a: TupleU512) -> (TupleU512, TupleU512) {
        return self.divide(by: a)
    }
    
    public func divide(by b: TupleU512) -> (TupleU512, TupleU512) {
        precondition(!b.isZero)
        
        var x = TupleU512(self)
        
        // First, let's take care of the easy cases.
        if x < b {
            return (TupleU512(), x)
        }
        
        let dc = b.wordCount
        if dc == 1 {
            let (q, r) = x.quotientAndRemainder(dividingByWord: b[0])
            return (q, TupleU512(r))
        }
        
        var y = TupleU512(b)
        let leadingZeroes = UInt32(y[dc - 1].leadingZeroBitCount)
        var quotient = TupleU512()
        let xWordCount = x.wordCount
        var xTopBits = x[U512WordWidth - 1] >> (64 - leadingZeroes)
        x <<= leadingZeroes
        y <<= leadingZeroes
        let d1 = y[dc - 1]
        let d0 = y[dc - 2]
        var product = TupleU512()
        for j in (dc ... xWordCount).reversed() {
            let m = j - dc
            // pad with 0 highest word
            var r2 = x[j]
            if j == U512WordWidth {
                r2 = xTopBits
            }
            let r1 = x[j - 1]
            let r0 = x[j - 2]
            // we have properly reduced the highest word
            let q = approximateQuotient(dividing: (r2, r1, r0), by: (d1, d0))
            product = TupleU512(y)
            let of = product.inplaceMultiply(byWord: q, shiftedBy: m)
            if j == xWordCount {
                if xTopBits > of {
                    // product is definatelly less than x
                    xTopBits = xTopBits - of
                    x.inplaceSubMod(product)
                    quotient[m] = q
                } else if xTopBits == of {
                    // extended word bits are equal
                    xTopBits = 0
                    if product <= x {
                        x.inplaceSubMod(product)
                        quotient[m] = q
                    } else {
                        x.inplaceAddMod(y)
                        x.inplaceSubMod(product)
                        quotient[m] = q - 1
                    }
                } else {
                    // we need to virtually borrow due to q being overshoot
                    x.inplaceAddMod(y)
                    x.inplaceSubMod(product)
                    quotient[m] = q - 1
                }
            } else if product <= x {
                x.inplaceSubMod(product)
                quotient[m] = q
            } else {
                x.inplaceAddMod(y)
                x.inplaceSubMod(product)
                quotient[m] = q - 1
            }
        }
        x >>= leadingZeroes
        return (quotient, x)
    }
}
