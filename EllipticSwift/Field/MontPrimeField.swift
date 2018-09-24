//
//  GeneralizedMontField.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 02.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class MontPrimeField<T>: PrimeFieldProtocol where T: FiniteFieldCompatible, T: MontArithmeticsCompatible  {
    
    public typealias UnderlyingRawType = T
    
    public func reduce(_ a: BytesRepresentable) -> T {
        let t = T(a.bytes)
        precondition(t != nil)
        let reduced = t!.toMontForm(self.prime)
        return reduced
    }
    
    public func reduce(_ a: T) -> T {
        let reduced = a.toMontForm(self.prime)
        return reduced
    }
    
    public func isEqualTo(_ other: MontPrimeField<T>) -> Bool {
        return self.prime == other.prime
    }
    
    public var modulus: BigUInt {
        return BigUInt(self.prime.bytes)
    }
    
    public func toValue(_ a: UnderlyingRawType) -> BigUInt {
        let normalValue = a.modMultiply(self.montInvR, self.prime)
        //        (a.rawValue*self.montInvR) % self.prime
        let bytes = normalValue.bytes
        return BigUInt(bytes)
    }
    
    public func toValue(_ a: UnderlyingRawType) -> UnderlyingRawType {
        let normalValue = a.modMultiply(self.montInvR, self.prime)
        return normalValue
    }
    
    public required init(_ p: BytesRepresentable) {
        let nativeType: T? = T(p.bytes)
        precondition(nativeType != nil)
        self.prime = nativeType!
        let (montR, montInvR, montK) = T.getMontParams(self.prime)
        self.montR = montR
        self.montInvR = montInvR
        self.montK = montK
    }
    
    public required init(_ p: BigUInt) {
        let nativeType: T? = T(p.serialize())
        precondition(nativeType != nil)
        self.prime = nativeType!
        let (montR, montInvR, montK) = T.getMontParams(self.prime)
        self.montR = montR
        self.montInvR = montInvR
        self.montK = montK
    }
    public required init(_ p: T) {
        self.prime = p
        let (montR, montInvR, montK) = T.getMontParams(self.prime)
        self.montR = montR
        self.montInvR = montInvR
        self.montK = montK
    }
    
    public var prime: UnderlyingRawType
    public var montR: UnderlyingRawType
    public var montInvR: UnderlyingRawType
    public var montK: UnderlyingRawType
    
    public func add(_ a: T, _ b: T) -> T {
        let space = self.prime - a // q - a
        if (b >= space) {
            return b - space
        } else {
            return b + a
        }
    }

    internal func toElement(_ a: T) -> PrimeFieldElement<MontPrimeField<T>> {
        return PrimeFieldElement<MontPrimeField<T>>(a, self)
    }

    public func sub(_ a: T, _ b: T) -> T {
        if a >= b {
            return a - b
        } else {
            return self.prime - (b - a)
        }
    }

    public func neg(_ a: T) -> T {
        return self.prime - a
    }

    internal func doubleAndAddExponentiation(_ a: T, _ b: T) -> T {
        var base = a
        var result = self.identityElement
        let bitwidth = b.bitWidth
        for i in 0 ..< bitwidth {
            if b.bit(i) {
                result = self.mul(result, base)
            }
            if i == b.bitWidth - 1 {
                break
            }
            base = mul(base, base)
        }
        return result
    }

    internal func kSlidingWindowExponentiation(_ a: T, _ b: T, windowSize: Int = DefaultWindowSize) -> T {
        let numPrecomputedElements = (1 << windowSize) - 1 // 2**k - 1
        var precomputations = [T](repeating: self.identityElement, count: numPrecomputedElements)
        precomputations[0] = a
        precomputations[1] = self.mul(a, a)
        for i in 2 ..< numPrecomputedElements {
            precomputations[i] = self.mul(precomputations[i-2], precomputations[1])
        }
        var result = self.identityElement
        let (lookups, powers) = computeSlidingWindow(scalar: b, windowSize: windowSize)
        for i in 0 ..< lookups.count {
            let lookupCoeff = lookups[i]
            if lookupCoeff == -1 {
                result = self.mul(result, result)
            } else {
                let power = powers[i]
                let intermediatePower = self.doubleAndAddExponentiation(result, T(power)) // use trivial form to don't go recursion
                result = self.mul(intermediatePower, precomputations[lookupCoeff])
            }
        }
        return result
    }

    public func mul(_ a: T, _ b: T) -> T {
        // multiplication in Mont. reduced field
        return self.montMul(a, b)
    }

    func montMul(_ a: T, _ b: T) -> T {
        let res = a.montMul(b, modulus: self.prime, montR: self.montR, montInvR: self.montInvR, montK: self.montK)
        return res
    }

    public func div(_ a: T, _ b: T) -> T {
        return self.mul(a, self.inv(b))
    }

    public func inv(_ a: T) -> T {
        // TODO: inversion in Mont. field natively
        let TWO = T(UInt64(2))
        let power = self.prime - TWO
        return self.pow(a, power)
        //        return self.toElement(a.rawValue.modInv(self.prime))
    }

    public func pow(_ a: T, _ b: T) -> T {
        if b.isZero {
            return self.identityElement
        }
        if b == 1 {
            return a
        }
        return self.doubleAndAddExponentiation(a, b)
    }

    public func pow(_ a: T, _ b: BytesRepresentable) -> T {
        let t = T(b.bytes)
        precondition(t != nil)
        return self.pow(a, t!)
    }

    public func sqrt(_ a: T) -> T {
        if a.isZero {
            return a
        }
        let ONE = T(UInt64(1))
        let TWO = T(UInt64(2))
        let THREE = T(UInt64(3))
        let FOUR = T(UInt64(4))
        //        let EIGHT = T(Data(repeating: 8, count: 1))!
        let mod4 = self.prime.mod(FOUR)
        precondition(mod4.mod(TWO) == ONE)

        // Fast case
        if (mod4 == THREE) {
            let (power, _) = (self.prime + ONE).div(FOUR)
            return self.pow(a, power)
        }
        precondition(false, "NYI")
        return self.zeroElement
    }

    public func fromValue(_ a: BytesRepresentable) -> UnderlyingRawType {
        let t = T(a.bytes)
        precondition(t != nil)
        let reduced = t!.toMontForm(self.prime)
        return reduced
//        let fe = UnderlyingFieldElementType(reduced, self)
//        return fe
    }
    
    public func fromValue(_ a: BigUInt) -> UnderlyingRawType {
        let t = T(a.serialize())
        precondition(t != nil)
        let reduced = t!.toMontForm(self.prime)
        return reduced
//        let fe = UnderlyingFieldElementType(reduced, self)
//        return fe
    }
    
    public func fromValue(_ a: T) -> UnderlyingRawType {
        let reduced = a.toMontForm(self.prime)
        return reduced
//        let fe = UnderlyingFieldElementType(reduced, self)
//        return fe
    }
    
    public func fromValue(_ a: UInt64) -> UnderlyingRawType {
        let t = T(a)
        let reduced = t.toMontForm(self.prime)
        return reduced
//        let fe = UnderlyingFieldElementType(reduced, self)
//        return fe
    }
    
    public func fromBytes(_ a: Data) -> UnderlyingRawType {
        let t = T(a)
        precondition(t != nil)
        let reduced = t!.toMontForm(self.prime)
        return reduced
//        let fe = UnderlyingFieldElementType(reduced, self)
//        return fe
    }

    public var identityElement: UnderlyingRawType {
        let element = self.fromValue(UInt64(1))
        return element
    }

    public var zeroElement: UnderlyingRawType {
        let element = self.fromValue(UInt64(0))
        return element
    }
}

