//
//  PrimeExtensionField.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public final class QuadraticExtensionField<F>: ExtensionFieldProtocol where F: FieldProtocol, F: FieldWithDivisionProtocol {
    public typealias Field = F
    public typealias FE = FieldElement<F>
    public typealias ReductionPolynomial = (FE, FE, FE)
    public typealias ExtensionFieldElement = (FE, FE)
    public typealias ScalarValue = FE.Field.UnderlyingRawType
    public typealias RawType = (FE.Field.UnderlyingRawType, FE.Field.UnderlyingRawType)
    
    public var field: F
    public var degree: Int = 2
    public var reducingPolynomial: ReductionPolynomial
    
    public init (_ polynomial: ReductionPolynomial, field: Field) {
        self.field = field
        self.reducingPolynomial = polynomial
    }
    
    public func add(_ a: ExtensionFieldElement, _ b: ExtensionFieldElement) -> ExtensionFieldElement {
        return (
            a.0 + b.0,
            a.1 + b.1
        )
    }
    public func sub(_ a: ExtensionFieldElement, _ b: ExtensionFieldElement) -> ExtensionFieldElement {
        return (
            a.0 - b.0,
            a.1 - b.1
        )
    }
    public func neg(_ a: ExtensionFieldElement) -> ExtensionFieldElement {
        return (
            a.0.negate(),
            a.1.negate()
        )
    }
    public func mul(_ a: ExtensionFieldElement, _ b: ExtensionFieldElement) -> ExtensionFieldElement {
        let intermediate = (
            a.0 * b.0,
            a.0 * b.1 + a.1 * b.0,
            a.1 * b.1
        )
        let leadingCoeff = intermediate.2 * self.reducingPolynomial.2.inv()
        let subtracted = (intermediate.0 - leadingCoeff * self.reducingPolynomial.0,
                          intermediate.1 - leadingCoeff * self.reducingPolynomial.1,
                          intermediate.2 - leadingCoeff * self.reducingPolynomial.2)
        return (subtracted.0, subtracted.1)
    }

    public func inv(_ a: ExtensionFieldElement) -> ExtensionFieldElement {
        return self.identityElement
    }
    
    public func pow(_ a: ExtensionFieldElement, _ b: ScalarValue) -> ExtensionFieldElement {
        let res = self.doubleAndAddExponentiation(a, b)
        return res
    }
    
    internal func doubleAndAddExponentiation(_ a: ExtensionFieldElement, _ b: ScalarValue) -> ExtensionFieldElement {
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
    
    public func fromValue(_ a: RawType) -> ExtensionFieldElement {
        return (
            FieldElement.fromValue(a.0, field: self.field),
            FieldElement.fromValue(a.1, field: self.field)
        )
    }
    public func toValue(_ a: ExtensionFieldElement) -> RawType {
        return (a.0.nativeValue, a.1.nativeValue)
    }
    
    public var identityElement: ExtensionFieldElement {
        let identity = FieldElement.identityElement(self.field)
        return (identity, identity)
    }
    
    public var zeroElement: ExtensionFieldElement {
        let zero = FieldElement.zeroElement(self.field)
        return (zero, zero)
    }
    
}

public struct QuadraticExtensionFieldElement<Q>: Arithmetics where Q: ExtensionFieldProtocol, Q.ExtensionFieldElement == (Q.FE, Q.FE)  {
    
    public typealias ExtensionField = Q
    public typealias FE = Q.FE
    public typealias ElementsType = (FE, FE)
    public typealias RawType = (FE.Field.UnderlyingRawType, FE.Field.UnderlyingRawType)
    public typealias SelfType = QuadraticExtensionFieldElement<Q>
    
    public var extensionField: Q
    public var raw: ElementsType
    
    public var isZero: Bool {
        return self.raw.0.isZero && self.raw.1.isZero
    }
    
    public init(_ raw: ElementsType, extensionField: ExtensionField) {
        self.extensionField = extensionField
        self.raw = raw
    }
    
    public init(_ raw: RawType, extensionField: ExtensionField) {
        self.extensionField = extensionField
        self.raw = (FE.fromValue(raw.0, field: extensionField.field), FE.fromValue(raw.1, field: extensionField.field))
    }
    
    public static func + (lhs: SelfType, rhs: SelfType) -> SelfType {
        let extField = lhs.extensionField
        let raw = extField.add(lhs.raw, rhs.raw)
        return SelfType(raw, extensionField: extField)
    }
    
    public static func - (lhs: QuadraticExtensionFieldElement<Q>, rhs: QuadraticExtensionFieldElement<Q>) -> QuadraticExtensionFieldElement<Q> {
        let extField = lhs.extensionField
        let raw = extField.sub(lhs.raw, rhs.raw)
        return SelfType(raw, extensionField: extField)
    }
    
    public static func == (lhs: SelfType, rhs: SelfType) -> Bool {
        return lhs.raw.0 == rhs.raw.1 && lhs.raw.1 == rhs.raw.1
    }
    
    public static func * (lhs: SelfType, rhs: SelfType) -> SelfType {
        let extField = lhs.extensionField
        let raw = extField.mul(lhs.raw, rhs.raw)
        return SelfType(raw, extensionField: extField)
    }
    
    public func pow(_ a: Q.ScalarValue) -> SelfType {
        let extField = self.extensionField
        let raw = extField.pow(self.raw, a)
        return SelfType(raw, extensionField: extField)
    }
    
    public func inv() -> SelfType {
        let extField = self.extensionField
        let raw = extField.inv(self.raw)
        return SelfType(raw, extensionField: extField)
    }
    
    public static func / (lhs: SelfType, rhs: SelfType) -> (SelfType, SelfType) {
        let extField = lhs.extensionField
        let inverse = extField.inv(rhs.raw)
        let raw = extField.mul(lhs.raw, inverse)
        return (SelfType(raw, extensionField: extField), SelfType.zero(extField))
    }
    
    public static func zero(_ extensionField: ExtensionField) -> SelfType{
        let raw = extensionField.zeroElement
        return SelfType(raw, extensionField: extensionField)
    }
}
