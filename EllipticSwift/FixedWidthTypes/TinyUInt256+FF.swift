//
//  TinyUInt256+FF.swift
//  EllipticSwift_iOS
//
//  Created by Alex Vlasov on 05/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation


//public protocol FiniteFieldCompatible: Comparable, Numeric, ModReducable, BytesInitializable, BitsAndBytes, BitShiftable, EvenOrOdd, UInt64Initializable, FastZeroInitializable {
//}

extension TinyUInt256: FiniteFieldCompatible {
    
}

extension TinyUInt256 {
    func addMod(_ a: TinyUInt256) -> TinyUInt256 {
        let (res, _) = self.addingReportingOverflow(a)
        return res
    }
    func subMod(_ a: TinyUInt256) -> TinyUInt256 {
        let (res, _) = self.subtractingReportingOverflow(a)
        return res
    }
    func halfMul(_ a: TinyUInt256) -> TinyUInt256 {
        let (res, _) = self.multipliedReportingOverflow(by: a)
        return res
    }
}

extension TinyUInt256: ModReducable {
    public func modMultiply(_ a: TinyUInt256, _ modulus: TinyUInt256) -> TinyUInt256 {
        let fullMul =  self.fullMultiply(a)
        // second half is lower bits in BE
        let extended = TinyUInt512(firstHalf: fullMul.0, secondHalf: fullMul.1)
        let extendedModulus = TinyUInt512(firstHalf: TinyUInt256(0), secondHalf: modulus)
        let (_, reduced) = extended.quotientAndRemainder(dividingBy: extendedModulus)
        return reduced.storage.secondHalf
    }
    
    public func mod(_ modulus: TinyUInt256) -> TinyUInt256 {
        let (_, rem) = self.quotientAndRemainder(dividingBy: modulus)
        return rem
    }
    
    public func modInv(_ modulus: TinyUInt256) -> TinyUInt256 {
        var a = self
        let zero = TinyUInt256(0)
        let one = TinyUInt256(1)
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
    
    public func div(_ a: TinyUInt256) -> (TinyUInt256, TinyUInt256) {
        return self.quotientAndRemainder(dividingBy: a)
    }
    
    public func fullMultiply(_ a: TinyUInt256) -> (TinyUInt256, TinyUInt256) {
        let res = self.multipliedFullWidth(by: a)
        return (res.high, res.low)
    }
}

extension TinyUInt256: BytesInitializable {
    public init?(_ bytes: Data) {
        if bytes.count > 32 {
            return nil
        }
        if bytes.count <= 16 {
            let bottom = TinyUInt128(bytes)!
            self = TinyUInt256.init(firstHalf: TinyUInt128(0), secondHalf: bottom)
            return
        }
        let topLength = bytes.count - 16
        let bottom = TinyUInt128(Data(bytes[topLength ..< bytes.count]))!
        let top = TinyUInt128(Data(bytes[0 ..< topLength]))!
        self = TinyUInt256.init(firstHalf: top, secondHalf: bottom)
    }
}

extension TinyUInt256: BitsAndBytes {
    public var bytes: Data {
        return self.storage.firstHalf.bytes + self.storage.secondHalf.bytes
    }
    
    public func bit(_ i: Int) -> Bool {
        if i < 0 {
            return false
        } else if i < 128 {
            return self.storage.secondHalf.bit(i)
        } else if i < 256 {
            return self.storage.firstHalf.bit(i - 128)
        }
        return false
    }
    
    public var fullBitWidth: UInt32 {
        return 256
    }
    
    public var isZero: Bool {
        return self.storage.firstHalf.isZero && self.storage.secondHalf.isZero
    }
    
    public var bitWidth: Int {
        return 256 - self.leadingZeroBitCount
    }
}

extension TinyUInt256: BitShiftable {
    
}

extension TinyUInt256: EvenOrOdd {
    public var isEven: Bool {
        return self.storage.secondHalf.isEven
    }
}

extension TinyUInt256: UInt64Initializable {
    
}

extension TinyUInt256: FastZeroInitializable {
    public static var zero: TinyUInt256 {
        let res = TinyUInt256(0)
        return res
    }
}

extension TinyUInt256: MontArithmeticsCompatible {
    
    static var montR = TinyUInt512(firstHalf: TinyUInt256(1), secondHalf: TinyUInt256.min)
    
    public static func getMontParams(_ a: TinyUInt256) -> (TinyUInt256, TinyUInt256, TinyUInt256) {
        let ONE = TinyUInt256(1)
        let montR = TinyUInt256.max.mod(a) + ONE
        // Montgommery R params is 2^256
        let primeU512 = TinyUInt512(firstHalf: TinyUInt256.min, secondHalf: a)
        let montInvRfullWidth = TinyUInt256.montR.modInv(primeU512)
        let RmulRinvFullWidth = TinyUInt512(firstHalf: montInvRfullWidth.storage.secondHalf, secondHalf: TinyUInt256.min) // virtual multiply by hand
        let subtracted = RmulRinvFullWidth - TinyUInt512(1)

        let (montKfullWidth, _) = subtracted.quotientAndRemainder(dividingBy: primeU512)
        let (_, montInvR) = montInvRfullWidth.storage
        let (_, montK) = montKfullWidth.storage
        return (montR, montInvR, montK)
    }
    
    public func toMontForm(_ modulus: TinyUInt256) -> TinyUInt256 {
        let multipliedByR = TinyUInt512(firstHalf: self, secondHalf: TinyUInt256.min) // trivial bitshift
        let paddedModulus = TinyUInt512(firstHalf: TinyUInt256.min, secondHalf: modulus)
        let (_, remainder) = multipliedByR.quotientAndRemainder(dividingBy: paddedModulus)
        let (_, b) = remainder.storage
        return b
    }
    
    public func montMul(_ b: TinyUInt256, modulus: TinyUInt256, montR: TinyUInt256, montInvR: TinyUInt256, montK: TinyUInt256) -> TinyUInt256 {
        let x = self.modMultiply(b, modulus)
        let s = x.halfMul(montK)
        let v = modulus.fullMultiply(s)
        let x512 = TinyUInt512(firstHalf: TinyUInt256(0), secondHalf: x)
        let v512 = TinyUInt512(firstHalf: v.0, secondHalf: v.1)
        let t = v512.addMod(x512)

        let (u, bottom) = t.storage
        if (!bottom.isZero) {
            return TinyUInt256(0)
        }
        //        precondition(!u.isZero)
        if u < modulus {
            return u
        } else {
            return u.subMod(modulus)
        }
    }
}
