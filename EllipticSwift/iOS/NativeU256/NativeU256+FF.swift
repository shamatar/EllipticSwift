//
//  NativeU256+FF.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 07/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation


//public protocol FiniteFieldCompatible: Comparable, Numeric, ModReducable, BytesInitializable, BitsAndBytes, BitShiftable, EvenOrOdd, UInt64Initializable, FastZeroInitializable {
//}

extension NativeU256: FiniteFieldCompatible {
    public typealias Magnitude = NativeU256
    
    public convenience init?<T>(exactly source: T) where T : BinaryInteger {
        return nil
    }
    
    public typealias IntegerLiteralType = UInt64
}


extension NativeU256: Numeric {
    public static func += (lhs: inout NativeU256, rhs: NativeU256) {
        lhs.inplaceAddMod(rhs)
    }
    
    public static func -= (lhs: inout NativeU256, rhs: NativeU256) {
        lhs.inplaceSubMod(rhs)
    }
    
    public static func + (lhs: NativeU256, rhs: NativeU256) -> NativeU256 {
        return lhs.addMod(rhs)
    }
    
    public static func - (lhs: NativeU256, rhs: NativeU256) -> NativeU256 {
        return lhs.subMod(rhs)
    }
    
    public var magnitude: NativeU256 {
        return self
    }
    
    public static func * (lhs: NativeU256, rhs: NativeU256) -> NativeU256 {
        return lhs.halfMul(rhs)
    }
    
    public static func *= (lhs: inout NativeU256, rhs: NativeU256) {
        lhs.inplaceHalfMul(rhs)
    }
    
    public convenience init(integerLiteral value: NativeU256.IntegerLiteralType) {
        self.init(value)
    }
}


extension NativeU256: ModReducable {
    public func modMultiply(_ a: NativeU256, _ modulus: NativeU256) -> NativeU256 {
        let fullMul = self.fullMul(a)
        let extendedModulus = NativeU512((NativeU256(), modulus))
        let (_, reduced) = fullMul.divide(by: extendedModulus)
        let (_, b) = reduced.split()
        return b
    }
    
    public func mod(_ modulus: NativeU256) -> NativeU256 {
        let (_, rem) = self.div(modulus)
        return rem
    }
    
    public func modInv(_ modulus: NativeU256) -> NativeU256 {
        var a = NativeU256(self)
        let zero = NativeU256(UInt64(0))
        let one = NativeU256(UInt64(1))
        var new = NativeU256(one)
        var old = NativeU256(zero)
        var q = NativeU256(modulus)
        var r = NativeU256(zero)
        var h = NativeU256(zero)
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
    
    public func div(_ a: NativeU256) -> (NativeU256, NativeU256) {
        return self.divide(by: a)
    }
    
    public func fullMultiply(_ a: NativeU256) -> (NativeU256, NativeU256) {
        let (t, b) = self.fullMul(a).split()
        return (t, b)
    }
}

extension NativeU256: BytesInitializable {
    public convenience init?(_ bytes: Data) {
        self.init()
        if bytes.count > 32 {
            return nil
        }
        let d = Data(repeating: 0, count: 32 - bytes.count) + bytes
        d.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> Void in
            let ptr = UnsafeRawPointer(ptr).assumingMemoryBound(to: UInt64.self)
            let typedPointer = self.storage.assumingMemoryBound(to: UInt64.self)
            for i in 0 ..< U256WordWidth {
                let t = ptr[i]
                let swapped = t.byteSwapped
                typedPointer[U256WordWidth - 1 - i] = swapped
            }
        }
    }
}

extension NativeU256: BitsAndBytes {
    public func bit(_ i: Int) -> Bool {
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        if i < 0 {
            return false
        } else if i < 64 {
            return typedStorage[0] & (UInt64(1) << i) > 0
        } else if i < 128 {
            return typedStorage[1] & (UInt64(1) << (i - 64)) > 0
        } else if i < 192 {
            return typedStorage[2] & (UInt64(1) << (i - 128)) > 0
        } else if i < 256 {
            return typedStorage[3] & (UInt64(1) << (i - 192)) > 0
        }
        return false
    }
    
    public var fullBitWidth: UInt32 {
        return 256
    }
    
    public var bitWidth: Int {
        return 256 - self.leadingZeroBitCount
    }
}

extension NativeU256: BitShiftable {
    public static func << (lhs: NativeU256, rhs: UInt32) -> NativeU256 {
        precondition(rhs <= 64)
        let new = NativeU256()
        let typedStorage = new.storage.assumingMemoryBound(to: UInt64.self)
        let originalStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (1 ..< U256WordWidth).reversed() {
            typedStorage[i] = (originalStorage[i] << rhs) | (originalStorage[i-1] >> (64 - rhs))
        }
        typedStorage[0] = originalStorage[0] << rhs
        return new
    }
    
    public static func <<= (lhs: inout NativeU256, rhs: UInt32) {
        precondition(rhs <= 64)
        let new = NativeU256()
        let typedStorage = new.storage.assumingMemoryBound(to: UInt64.self)
        let originalStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (1 ..< U256WordWidth).reversed() {
            typedStorage[i] = (originalStorage[i] << rhs) | (originalStorage[i-1] >> (64 - rhs))
        }
        typedStorage[0] = originalStorage[0] << rhs
        lhs.storage.copyMemory(from: new.storage, byteCount: U256ByteLength)
    }
    
    public static func >> (lhs: NativeU256, rhs: UInt32) -> NativeU256 {
        precondition(rhs <= 64)
        let new = NativeU256()
        let typedStorage = new.storage.assumingMemoryBound(to: UInt64.self)
        let originalStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U256WordWidth-1).reversed() {
            typedStorage[i] = (originalStorage[i] >> rhs) | (originalStorage[i+1] << (64 - rhs))
        }
        typedStorage[U256WordWidth-1] = originalStorage[U256WordWidth-1] >> rhs
        return new
    }
    
    public static func >>= (lhs: inout NativeU256, rhs: UInt32) {
        precondition(rhs <= 64)
        let new = NativeU256()
        let typedStorage = new.storage.assumingMemoryBound(to: UInt64.self)
        let originalStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U256WordWidth-1).reversed() {
            typedStorage[i] = (originalStorage[i] >> rhs) | (originalStorage[i+1] << (64 - rhs))
        }
        typedStorage[U256WordWidth-1] = originalStorage[U256WordWidth-1] >> rhs
        lhs.storage.copyMemory(from: new.storage, byteCount: U256ByteLength)
    }
}

extension NativeU256: EvenOrOdd {
    public var isEven: Bool {
        return self.storage.assumingMemoryBound(to: UInt64.self)[0] & UInt64(1) == 0
    }
}

extension NativeU256: UInt64Initializable {
    
}

extension NativeU256: FastZeroInitializable {
    public static var zero: NativeU256 {
        let res = NativeU256()
        return res
    }
}

extension NativeU256 {
    public static var max: NativeU256 {
        let new = NativeU256()
        let typedStorage = new.storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U256WordWidth {
            typedStorage[i] = UInt64.max
        }
        return new
    }
    
    public static var min: NativeU256 {
        let new = NativeU256()

        return new
    }
}

extension NativeU256: MontArithmeticsCompatible {
    
    static var montR = NativeU512((NativeU256(UInt64(1)), NativeU256()))
    
    public static func getMontParams(_ a: NativeU256) -> (NativeU256, NativeU256, NativeU256) {
        let ONE = NativeU256(UInt64(1))
        let montR = NativeU256.max.mod(a) + ONE
        // Montgommery R params is 2^256
        let primeU512 = NativeU512((NativeU256.min, a))
        let montInvRfullWidth = NativeU256.montR.modInv(primeU512)
        let (_, rInvBottom) = montInvRfullWidth.split()
        let RmulRinvFullWidth = NativeU512((rInvBottom, NativeU256.min)) // virtual multiply by hand
        let subtracted = RmulRinvFullWidth.subMod(NativeU512(UInt64(1)))
        
        let (montKfullWidth, _) = subtracted.divide(by: primeU512)
        let (_, montInvR) = montInvRfullWidth.split()
        let (_, montK) = montKfullWidth.split()
        return (montR, montInvR, montK)
    }
    
    public func toMontForm(_ modulus: NativeU256) -> NativeU256 {
        let multipliedByR = NativeU512((self, NativeU256.min)) // trivial bitshift
        let paddedModulus = NativeU512((NativeU256.min, modulus))
        let (_, remainder) = multipliedByR.divide(by: paddedModulus)
        let (_, b) = remainder.split()
        return b
    }
    
    public func montMul(_ b: NativeU256, modulus: NativeU256, montR: NativeU256, montInvR: NativeU256, montK: NativeU256) -> NativeU256 {
        let x = self.modMultiply(b, modulus)
        let s = x.halfMul(montK)
        let v = modulus.fullMultiply(s)
        let x512 = NativeU512((NativeU256(), x))
        let v512 = NativeU512(v)
        let t = v512.addMod(x512)
        
        let (u, bottom) = t.split()
        if (!bottom.isZero) {
            return NativeU256()
        }
        //        precondition(!u.isZero)
        if u < modulus {
            return u
        } else {
            return u.subMod(modulus)
        }
    }
}
