//
//  NaivePrimeFiniteField.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 26/09/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public final class NaivePrimeFiniteField<T>: FiniteFieldProtocol where T: FiniteFieldCompatible {

    public typealias RawType = T
    public typealias SelfType = NaivePrimeFiniteField<T>
    public typealias ElementType = T
    
    public var modulus: RawType
    
    @_specialize(exported: true, where T == U256)
    public required init(_ p: RawType) {
        self.modulus = p
    }
    
    @_specialize(exported: true, where T == U256)
    public func isEqualTo(_ other: NaivePrimeFiniteField<T>) -> Bool {
        return self.modulus == other.modulus
    }
    
    @_specialize(exported: true, where T == U256)
    public func add(_ a: ElementType, _ b: ElementType) -> ElementType {
        let space = self.modulus - a // q - a
        if (b >= space) {
            return b - space
        } else {
            return b + a
        }
    }
    
    @_specialize(exported: true, where T == U256)
    public func sub(_ a: ElementType, _ b: ElementType) -> ElementType {
        if a >= b {
            return a - b
        } else {
            return self.modulus - (b - a)
        }
    }
    
    @_specialize(exported: true, where T == U256)
    public func neg(_ a: ElementType) -> ElementType {
        return self.modulus - a
    }
    
    @_specialize(exported: false, where T == U256)
    internal func doubleAndAddExponentiation(_ a: ElementType, _ b: ElementType) -> ElementType {
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
    public func mul(_ a: ElementType, _ b: ElementType) -> ElementType {
        return a.modMultiply(b, self.modulus)
    }
    
    @_specialize(exported: true, where T == U256)
    public func inv(_ a: ElementType) -> ElementType {
        let inverse = a.modInv(self.modulus)
        return inverse
//        let TWO = T(UInt64(2))
//        let power = self.modulus - TWO
//        return self.pow(a, power)
    }
    
    @_specialize(exported: true, where T == U256)
    public func pow(_ a: ElementType, _ b: ElementType) -> ElementType {
        if b.isZero {
            return self.identityElement
        }
        if b == 1 {
            return a
        }
        return self.doubleAndAddExponentiation(a, b)
    }
    
    @_specialize(exported: true, where T == U256)
    public func pow(_ a: ElementType, _ b: BitsAndBytes) -> ElementType {
        let t = ElementType(b.bytes)
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
        let mod4 = self.modulus.mod(FOUR)
        precondition(mod4.mod(TWO) == ONE)
        
        // Fast case
        if (mod4 == THREE) {
            let (power, _) = (self.modulus + ONE).div(FOUR)
            return self.pow(a, power)
        }
        precondition(false, "NYI")
        return self.zeroElement
    }
    
    @_specialize(exported: true, where T == U256)
    public func fromValue(_ a: BytesRepresentable) -> ElementType {
        let t = T(a.bytes)
        precondition(t != nil)
        let reduced = t!
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func fromValue(_ a: BigUInt) -> ElementType {
        let t = T(a.serialize())
        precondition(t != nil)
        let reduced = t!
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func fromValue(_ a: T) -> ElementType {
        let reduced = a
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func fromValue(_ a: UInt64) -> ElementType {
        let t = T(a)
        let reduced = t
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func fromBytes(_ a: Data) -> ElementType {
        let t = T(a)
        precondition(t != nil)
        let reduced = t!
        return reduced
    }
    
    @_specialize(exported: true, where T == U256)
    public func areEqual(_ a: T, _ b: T) -> Bool {
        return a == b
    }
    
    @_specialize(exported: true, where T == U256)
    public func toValue(_ a: T) -> T {
        return a
    }
    
    @_specialize(exported: true, where T == U256)
    public func isZero(_ a: T) -> Bool {
        return a.isZero
    }
    
    public var identityElement: ElementType {
        let element = self.fromValue(UInt64(1))
        return element
    }
    
    public var zeroElement: ElementType {
        let element = self.fromValue(UInt64(0))
        return element
    }
}

public struct FiniteFieldElement<F>:Arithmetics where F: FiniteFieldProtocol {
    public var bytes: Data {
        // TODO
        return Data()
    }
    
    public typealias Field = F
    public typealias RawType = F.RawType
    public typealias SelfType = FiniteFieldElement<F>
    
    public var field: F
    public var rawValue: F.ElementType
    
    public var value: F.RawType {
        get {
            return self.field.toValue(self.rawValue)
        }
    }
    
    public init (_ a: RawType, field: F) {
        let reduced = field.fromValue(a)
        self.field = field
        self.rawValue = reduced
    }
    
    internal init (_ raw: F.ElementType, _ field: F) {
        self.rawValue = raw
        self.field = field
    }
    
    public static func + (lhs: SelfType, rhs: SelfType) -> SelfType {
        let newRaw = lhs.field.add(lhs.rawValue, rhs.rawValue)
        return SelfType(newRaw, lhs.field)
    }
    
    public static func - (lhs: SelfType, rhs: SelfType) -> SelfType {
        let newRaw = lhs.field.sub(lhs.rawValue, rhs.rawValue)
        return SelfType(newRaw, lhs.field)
    }
    
    public prefix static func - (rhs: SelfType) -> SelfType {
        let newRaw = rhs.field.neg(rhs.rawValue)
        return SelfType(newRaw, rhs.field)
    }
    
    public static func == (lhs: SelfType, rhs: SelfType) -> Bool {
        return lhs.field.areEqual(lhs.rawValue, rhs.rawValue)
    }
    
    public static func * (lhs: SelfType, rhs: SelfType) -> SelfType {
        let newRaw = lhs.field.mul(lhs.rawValue, rhs.rawValue)
        return SelfType(newRaw, lhs.field)
    }
    
    public var isZero: Bool {
        return self.field.isZero(self.rawValue)
    }
    
    public func inv() -> SelfType {
        let newRaw =  self.field.inv(self.rawValue)
        return SelfType(newRaw, self.field)
    }
    
    public var zero: SelfType {
        let zero = self.field.zeroElement
        return SelfType(zero, self.field)
    }
    
    public var one: SelfType {
        let one = self.field.identityElement
        return SelfType(one, self.field)
    }
    
    public static func identityElement(_ field: F) -> FiniteFieldElement<F> {
        let reduced = field.identityElement
        return SelfType(reduced, field)
    }
    
    public static func zeroElement(_ field: F) -> FiniteFieldElement<F> {
        let reduced = field.zeroElement
        return SelfType(reduced, field)
    }
    
    public static func fromValue(_ a: F.RawType, field: F) -> FiniteFieldElement<F> {
        return SelfType(a, field: field)
    }
    
    public func negate() -> FiniteFieldElement<F> {
        let newRaw = self.field.neg(self.rawValue)
        return SelfType(newRaw, field)
    }
}
