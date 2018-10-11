//
//  NaivePrimeField.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 02.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class NaivePrimeField<T>: PrimeFieldProtocol where T: FiniteFieldCompatible {
    public typealias UnderlyingRawType = T
    
    @_specialize(exported: true, where T == U256)
    public func reduce(_ a: BytesRepresentable) -> T {
        let t = T(a.bytes)
        precondition(t != nil)
        let reduced = t!.mod(self.prime)
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func reduce(_ a: T) -> T {
        let reduced = a.mod(self.prime)
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func isEqualTo(_ other: NaivePrimeField<T>) -> Bool {
        return self.prime == other.prime
    }
    
    public var modulus: BigUInt {
        return BigUInt(self.prime.bytes)
    }
    
    public func toValue(_ a: UnderlyingRawType) -> BigUInt {
        let bytes = a.bytes
        return BigUInt(bytes)
    }
    
    @_specialize(exported: true, where T == U256)
    public func toValue(_ a: UnderlyingRawType) -> UnderlyingRawType {
        return a
    }
    
    @_specialize(exported: true, where T == U256)
    public required init(_ p: BytesRepresentable) {
        let nativeType: T? = T(p.bytes)
        precondition(nativeType != nil)
        self.prime = nativeType!
    }
    
    public required init(_ p: BigUInt) {
        let nativeType: T? = T(p.serialize())
        precondition(nativeType != nil)
        self.prime = nativeType!
    }
    
    @_specialize(exported: true, where T == U256)
    public required init(_ p: T) {
        self.prime = p
    }
    
    public var prime: UnderlyingRawType
    
    @_specialize(exported: true, where T == U256)
    public func add(_ a: T, _ b: T) -> T {
        let space = self.prime - a // q - a
        if (b >= space) {
            return b - space
        } else {
            return b + a
        }
    }
    
    @_specialize(exported: true, where T == U256)
    internal func toElement(_ a: T) -> FieldElement<NaivePrimeField<T>> {
        return FieldElement<NaivePrimeField<T>>(a, self)
    }
    
    @_specialize(exported: true, where T == U256)
    public func sub(_ a: T, _ b: T) -> T {
        if a >= b {
            return a - b
        } else {
            return self.prime - (b - a)
        }
    }
    
    @_specialize(exported: true, where T == U256)
    public func neg(_ a: T) -> T {
        return self.prime - a
    }
    
    @_specialize(exported: false, where T == U256)
    internal func doubleAndAddExponentiation(_ a: T, _ b: T) -> T {
        return DoubleAndAddExponentiationGeneric(a: a, power: b, identity: self.identityElement, multiplicationFunction: self.mul)
//        var base = a
//        var result = self.identityElement
//        let bitwidth = b.bitWidth
//        for i in 0 ..< bitwidth {
//            if b.bit(i) {
//                result = self.mul(result, base)
//            }
//            if i == bitwidth - 1 {
//                break
//            }
//            base = mul(base, base)
//        }
//        return result
    }
    
    @_specialize(exported: false, where T == U256)
    internal func kSlidingWindowExponentiation(_ a: T, _ b: T, windowSize: Int = DefaultWindowSize) -> T {
        return kSlidingWindowExponentiationGeneric(a: a, power: b, identity: self.identityElement, multiplicationFunction: self.mul, windowSize: windowSize)
//        let numPrecomputedElements = (1 << windowSize) - 1 // 2**k - 1
//        var precomputations = [T](repeating: self.identityElement, count: numPrecomputedElements)
//        precomputations[0] = a
//        precomputations[1] = self.mul(a, a)
//        for i in 2 ..< numPrecomputedElements {
//            precomputations[i] = self.mul(precomputations[i-2], precomputations[1])
//        }
//        var result = self.identityElement
//        let (lookups, powers) = computeSlidingWindow(scalar: b, windowSize: windowSize)
//        for i in 0 ..< lookups.count {
//            let lookupCoeff = lookups[i]
//            if lookupCoeff == -1 {
//                result = self.mul(result, result)
//            } else {
//                let power = powers[i]
//                let intermediatePower = self.doubleAndAddExponentiation(result, T(power)) // use trivial form to don't go recursion
//                result = self.mul(intermediatePower, precomputations[lookupCoeff])
//            }
//        }
//        return result
    }
    
    @_specialize(exported: true, where T == U256)
    public func mul(_ a: T, _ b: T) -> T {
        return a.modMultiply(b, self.prime)
    }
    
    @_specialize(exported: true, where T == U256)
    public func div(_ a: T, _ b: T) -> T {
        return self.mul(a, self.inv(b))
    }
    
    @_specialize(exported: true, where T == U256)
    public func inv(_ a: T) -> T {
        return a.modInv(self.prime)
        // faster than POW
//        let TWO = T(UInt64(2))
//        let power = self.prime - TWO
//        return self.pow(a, power)
    }
    
    @_specialize(exported: true, where T == U256)
    public func pow(_ a: T, _ b: T) -> T {
        if b.isZero {
            return self.identityElement
        }
        if b == 1 {
            return a
        }
        return self.doubleAndAddExponentiation(a, b)
    }
    
    @_specialize(exported: true, where T == U256)
    public func pow(_ a: T, _ b: BytesRepresentable) -> T {
        let t = T(b.bytes)
        precondition(t != nil)
        return self.pow(a, t!)
    }
    
    @_specialize(exported: true, where T == U256)
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
    
    @_specialize(exported: true, where T == U256)
    public func fromValue(_ a: BytesRepresentable) -> UnderlyingRawType {
        let t = T(a.bytes)
        precondition(t != nil)
        let reduced = self.reduce(t!)
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func fromValue(_ a: BigUInt) -> UnderlyingRawType {
        let t = T(a.serialize())
        precondition(t != nil)
        let reduced = self.reduce(t!)
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func fromValue(_ a: T) -> UnderlyingRawType {
        let reduced = self.reduce(a)
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func fromValue(_ a: UInt64) -> UnderlyingRawType {
        let t = T(a)
        let reduced = self.reduce(t)
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func fromBytes(_ a: Data) -> UnderlyingRawType {
        let t = T(a)
        precondition(t != nil)
        let reduced = self.reduce(t!)
        return reduced
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
