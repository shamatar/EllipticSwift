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
    
    internal func halfMul(_ a: ReductionPolynomial, _ b: ReductionPolynomial) -> ReductionPolynomial {
        let intermediate = (
            a.0 * b.0,
            a.0 * b.1 + a.1 * b.0,
            a.0 * b.2 + a.1 * b.1 * a.2 * b.0
        )
        return intermediate
    }
    
    internal func getDegree(_ a: ReductionPolynomial) -> Int {
        if !a.2.isZero {
            return 2
        } else if !a.1.isZero {
            return 1
        }
        return 0
    }
    
    internal func getDegree(_ a: ExtensionFieldElement) -> Int {
        if !a.1.isZero {
            return 1
        }
        return 0
    }
    
    internal func getLeadingCoefficient(_ a: ReductionPolynomial) -> FE {
        if !a.2.isZero {
            return a.2
        } else if !a.1.isZero {
            return a.1
        }
        return a.0
    }
    
    internal func getLeadingCoefficient(_ a: ExtensionFieldElement) -> FE {
        if !a.1.isZero {
            return a.1
        }
        return a.0
    }

    public func inv(_ a: ExtensionFieldElement) -> ExtensionFieldElement {
        let zeroFE = FieldElement.zeroElement(self.field)
        let identityFE = FieldElement.identityElement(self.field)
        let zero = (zeroFE, zeroFE, zeroFE)
        var old = zero
        var new = (identityFE, zeroFE, zeroFE)
        
        var toInvert = (a.0, a.1, zeroFE) // pad
        var q = self.reducingPolynomial
        
        var r = zero
        var h = zero
//        var positive = false
        while !toInvert.0.isZero || !toInvert.1.isZero || !toInvert.2.isZero {
//            quotient := r div newr
//            (r, newr) := (newr, r - quotient * newr)
//            (t, newt) := (newt, t - quotient * newt)
            
            (q, r) = self.div(q, toInvert)
//            print("Quot")
//            self.printElement(q)
//            print("Rem")
//            self.printElement(r)
            
            
            h = self.halfMul(q, new)
            h = (old.0 - h.0, old.1 - h.1, old.2 - h.2)
            old = new
            new = h
            
            q = toInvert
            toInvert = r
            

            let qDegree = self.getDegree(q)
            let newDegree = self.getDegree(new)
            let resultingDegree = qDegree + newDegree
            precondition(resultingDegree <= 2)

            
//            positive = !positive
        }
        precondition(self.getDegree(q) == 0)
        let inv = q.0.inv()
        return (old.0 * inv, old.1 * inv)
    }
    
    internal func printElement(_ a: ReductionPolynomial) {
        print("C2 = " + String(a.2.value))
        print("C1 = " + String(a.1.value))
        print("C0 = " + String(a.0.value))
    }
    
    internal func div(_ a: ReductionPolynomial, _ b: ReductionPolynomial) -> (ReductionPolynomial, ReductionPolynomial) {
        // a is of degree 2 at max
        let zeroFE = FieldElement.zeroElement(self.field)
//        let identityFE = FieldElement.identityElement(self.field)
//        let zero = (zeroFE, zeroFE, zeroFE)
        var quotient = (zeroFE, zeroFE, zeroFE)
        var remainder = a
        let divisorDeg = self.getDegree(b)
        let divisorLC = self.getLeadingCoefficient(b)
        var remainderDegree = self.getDegree(remainder)
//        let zero = FE.zeroElement(self.field)
        while remainderDegree >= divisorDeg {
            let monomialExponent = remainderDegree - divisorDeg
            if monomialExponent == 0 {
                let remainderLeadingCoeff = self.getLeadingCoefficient(remainder)
                let divs = remainderLeadingCoeff * divisorLC.inv()
                quotient = (quotient.0 + divs, quotient.1, quotient.2)
                let m = (
                    divs * b.0,
                    divs * b.1,
                    divs * b.2
                )
                remainder = (remainder.0 - m.0, remainder.1 - m.1, remainder.2 - m.2)
            } else if monomialExponent == 1 {
                let remainderLeadingCoeff = self.getLeadingCoefficient(remainder)
                let divs = remainderLeadingCoeff * divisorLC.inv()
                let monomialDivisor = (zeroFE, divs)
                quotient = (quotient.0, quotient.1 + monomialDivisor.1, quotient.2)
                // m = divisor * monomial remainder
                let m = (
                    monomialDivisor.0 * b.0,
                    monomialDivisor.0 * b.1 + monomialDivisor.1 * b.0,
                    monomialDivisor.0 * b.2 + monomialDivisor.1 * b.1
                )
                remainder = (remainder.0 - m.0, remainder.1 - m.1, remainder.2 - m.2)
            } else {
                let remainderLeadingCoeff = self.getLeadingCoefficient(remainder)
                let divs = remainderLeadingCoeff * divisorLC.inv()
                let monomialDivisor = (zeroFE, zeroFE, divs)
                quotient = (quotient.0, quotient.1 + monomialDivisor.1, quotient.2)
                // m = divisor * monomial remainder
                let m = (
                    monomialDivisor.0 * b.0,
                    monomialDivisor.0 * b.1 + monomialDivisor.1 * b.0,
                    monomialDivisor.0 * b.2 + monomialDivisor.1 * b.1 + monomialDivisor.2 * b.0
                )
                remainder = (remainder.0 - m.0, remainder.1 - m.1, remainder.2 - m.2)
            }
            let newRemainderDegree = self.getDegree(remainder)
            if newRemainderDegree == 0 && remainder.0.isZero {
                break
            }
            precondition(newRemainderDegree < remainderDegree)
            remainderDegree = newRemainderDegree
        }
        return (quotient, remainder)
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
    
    public func fromScalar(_ a: ScalarValue) -> ExtensionFieldElement {
        let zero = FieldElement.zeroElement(self.field)
        return (
            FieldElement.fromValue(a, field: self.field),
            zero
        )
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
        let zero = FieldElement.zeroElement(self.field)
        let identity = FieldElement.identityElement(self.field)
        return (identity, zero)
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

extension QuadraticExtensionFieldElement: CustomStringConvertible {
    public var description: String {
        var descr = ""
        descr += "Coefficient 1 = \(String(self.raw.1.value))\n"
        descr += "Coefficient 0 = \(String(self.raw.0.value))\n"
        return descr
    }
}
