//
//  CubicExtensionField.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 26/09/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

public final class CubicExtensionField<F>: ExtensionFieldProtocol where F: FiniteFieldProtocol {
    
    public typealias Field = F
    public typealias PolynomialCoefficientType = FiniteFieldElement<F>
    public typealias FE = PolynomialCoefficientType
    public typealias ReductionPolynomial = (FE, FE, FE, FE)
//    public typealias ScalarType = U256
    public typealias RawType = (FE, FE, FE)
    public typealias ElementType = (FE, FE, FE)
    
    public var field: F
    public var degree: Int = 3
    public var reducingPolynomial: ReductionPolynomial
    
    public init (_ polynomial: ReductionPolynomial, field: Field) {
        self.field = field
        self.reducingPolynomial = polynomial
    }
    
    public func add(_ a: ElementType, _ b: ElementType) -> ElementType {
        return (
            a.0 + b.0,
            a.1 + b.1,
            a.2 + b.2
        )
    }
    public func sub(_ a: ElementType, _ b: ElementType) -> ElementType {
        return (
            a.0 - b.0,
            a.1 - b.1,
            a.2 - b.2
        )
    }
    public func neg(_ a: ElementType) -> ElementType {
        return (
            a.0.negate(),
            a.1.negate(),
            a.2.negate()
        )
    }
    public func mul(_ a: ElementType, _ b: ElementType) -> ElementType {
        let intermediate = (
            a.0 * b.0,
            a.0 * b.1 + a.1 * b.0,
            a.0 * b.2 + a.1 * b.1 + a.2 * b.0,
            a.1 * b.2 + a.2 * b.1,
            a.2 * b.2
        )
        let a3Inv = self.reducingPolynomial.3.inv()
        let leadingCoeff = intermediate.4 * a3Inv
        let subtracted = (intermediate.0, // virtual multiplication by one power
                          intermediate.1 - leadingCoeff * self.reducingPolynomial.0,
                          intermediate.2 - leadingCoeff * self.reducingPolynomial.1,
                          intermediate.3 - leadingCoeff * self.reducingPolynomial.2)
        let leadingCoeff2 = subtracted.3 * a3Inv
        let subtracted2 = (subtracted.0 - leadingCoeff2 * self.reducingPolynomial.0,
                          subtracted.1 - leadingCoeff2 * self.reducingPolynomial.1,
                          subtracted.2 - leadingCoeff2 * self.reducingPolynomial.2)
        
        return subtracted2
    }
    
    internal func halfMul(_ a: ReductionPolynomial, _ b: ReductionPolynomial) -> ReductionPolynomial {
        let intermediate = (
            a.0 * b.0,
            a.0 * b.1 + a.1 * b.0,
            a.0 * b.2 + a.1 * b.1 + a.2 * b.0,
            a.1 * b.2 + a.2 * b.1
        )
        return intermediate
    }
    
    internal func getDegree(_ a: ReductionPolynomial) -> Int {
        if !a.3.isZero {
            return 3
        } else if !a.2.isZero {
            return 2
        } else if !a.1.isZero {
            return 1
        }
        return 0
    }
    
    internal func getDegree(_ a: ElementType) -> Int {
        if !a.2.isZero {
            return 2
        } else if !a.1.isZero {
            return 1
        }
        return 0
    }
    
    internal func getLeadingCoefficient(_ a: ReductionPolynomial) -> FE {
        if !a.3.isZero {
            return a.3
        } else if !a.2.isZero {
            return a.2
        } else if !a.1.isZero {
            return a.1
        }
        return a.0
    }
    
    internal func getLeadingCoefficient(_ a: ElementType) -> FE {
        if !a.2.isZero {
            return a.2
        } else if !a.1.isZero {
            return a.1
        }
        return a.0
    }
    
    public func inv(_ a: ElementType) -> ElementType {
        let zeroFE = FE.zeroElement(self.field)
        let identityFE = FE.identityElement(self.field)
        let zero = (zeroFE, zeroFE, zeroFE, zeroFE)
        var old = zero
        var new = (identityFE, zeroFE, zeroFE, zeroFE)
        
        var toInvert = (a.0, a.1, a.2, zeroFE) // pad
        var q = self.reducingPolynomial
        
        var r = zero
        var h = zero
        while !toInvert.0.isZero || !toInvert.1.isZero || !toInvert.2.isZero || !toInvert.3.isZero {
            (q, r) = self.div(q, toInvert)
            h = self.halfMul(q, new)
            h = (old.0 - h.0, old.1 - h.1, old.2 - h.2, old.3 - h.3)
            old = new
            new = h
            
            q = toInvert
            toInvert = r
            
            let qDegree = self.getDegree(q)
            let newDegree = self.getDegree(new)
            let resultingDegree = qDegree + newDegree
            precondition(resultingDegree <= 3)
        }
        precondition(self.getDegree(q) == 0)
        let inv: FE = q.0.inv()
        return (old.0 * inv, old.1 * inv, old.2 * inv)
    }
    
    
    internal func div(_ a: ReductionPolynomial, _ b: ReductionPolynomial) -> (ReductionPolynomial, ReductionPolynomial) {
        // a is of degree 2 at max
        let zeroFE = FE.zeroElement(self.field)
//        let identityFE = FE.identityElement(self.field)
        var quotient = (zeroFE, zeroFE, zeroFE, zeroFE)
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
                quotient = (quotient.0 + divs, quotient.1, quotient.2, quotient.3)
                let m = (
                    divs * b.0,
                    divs * b.1,
                    divs * b.2,
                    divs * b.3
                )
                remainder = (remainder.0 - m.0, remainder.1 - m.1, remainder.2 - m.2, remainder.3 - m.3)
            } else if monomialExponent == 1 {
                let remainderLeadingCoeff = self.getLeadingCoefficient(remainder)
                let divs = remainderLeadingCoeff * divisorLC.inv()
                let monomialDivisor = (zeroFE, divs)
                quotient = (quotient.0, quotient.1 + monomialDivisor.1, quotient.2, quotient.3)
                // m = divisor * monomial remainder
                let m = (
                    monomialDivisor.0 * b.0,
                    monomialDivisor.0 * b.1 + monomialDivisor.1 * b.0,
                    monomialDivisor.0 * b.2 + monomialDivisor.1 * b.1,
                    monomialDivisor.0 * b.3 + monomialDivisor.1 * b.2
                )
                remainder = (remainder.0 - m.0, remainder.1 - m.1, remainder.2 - m.2, remainder.3 - m.3)
            } else if monomialExponent == 2 {
                let remainderLeadingCoeff = self.getLeadingCoefficient(remainder)
                let divs = remainderLeadingCoeff * divisorLC.inv()
                let monomialDivisor = (zeroFE, zeroFE, divs)
                quotient = (quotient.0, quotient.1, quotient.2 + monomialDivisor.2, quotient.3)
                // m = divisor * monomial remainder
                let m = (
                    monomialDivisor.0 * b.0,
                    monomialDivisor.0 * b.1 + monomialDivisor.1 * b.0,
                    monomialDivisor.0 * b.2 + monomialDivisor.1 * b.1 + monomialDivisor.2 * b.0,
                    monomialDivisor.0 * b.3 + monomialDivisor.1 * b.2 + monomialDivisor.2 * b.1
                )
                remainder = (remainder.0 - m.0, remainder.1 - m.1, remainder.2 - m.2, remainder.3 - m.3)
            } else {
                let remainderLeadingCoeff = self.getLeadingCoefficient(remainder)
                let divs = remainderLeadingCoeff * divisorLC.inv()
                let monomialDivisor = (zeroFE, zeroFE, zeroFE, divs)
                quotient = (quotient.0, quotient.1, quotient.2, quotient.3 + monomialDivisor.3)
                // m = divisor * monomial remainder
                let m = (
                    monomialDivisor.0 * b.0,
                    monomialDivisor.0 * b.1 + monomialDivisor.1 * b.0,
                    monomialDivisor.0 * b.2 + monomialDivisor.1 * b.1 + monomialDivisor.2 * b.0,
                    monomialDivisor.0 * b.3 + monomialDivisor.1 * b.2 + monomialDivisor.2 * b.1 + monomialDivisor.3 * b.0
                    )
                remainder = (remainder.0 - m.0, remainder.1 - m.1, remainder.2 - m.2, remainder.3 - m.3)
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
    
    public func pow(_ a: ElementType, _ b: BitsAndBytes) -> ElementType {
        let res = self.doubleAndAddExponentiation(a, b)
        return res
    }
    
    internal func doubleAndAddExponentiation(_ a: ElementType, _ b: BitsAndBytes) -> ElementType {
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
    
    public func fromValue(_ a: RawType) -> ElementType {
        return (
            a.0,
            a.1,
            a.2
        )
    }
    public func toValue(_ a: ElementType) -> RawType {
        return (a.0, a.1, a.2)
    }
    
    public var identityElement: ElementType {
        let zero = FE.zeroElement(self.field)
        let identity = FE.identityElement(self.field)
        return (identity, zero, zero)
    }
    
    public var zeroElement: ElementType {
        let zero = FE.zeroElement(self.field)
        return (zero, zero, zero)
    }
    
    public func isEqualTo(_ other: CubicExtensionField<F>) -> Bool {
        if !self.field.isEqualTo(other.field) {
            return false
        }
        if self.reducingPolynomial.0 != other.reducingPolynomial.0 ||
            self.reducingPolynomial.1 != other.reducingPolynomial.1 ||
            self.reducingPolynomial.2 != other.reducingPolynomial.2 ||
            self.reducingPolynomial.3 != other.reducingPolynomial.3 {
            return false
        }
        return true
    }
    
    public func areEqual(_ a: (FiniteFieldElement<F>, FiniteFieldElement<F>, FiniteFieldElement<F>), _ b: (FiniteFieldElement<F>, FiniteFieldElement<F>, FiniteFieldElement<F>)) -> Bool {
        if a.0 != b.0 {
            return false
        }
        if a.1 != b.1 {
            return false
        }
        if a.2 != b.2 {
            return false
        }
        return true
    }
    
    public func isZero(_ a: (FiniteFieldElement<F>, FiniteFieldElement<F>, FiniteFieldElement<F>)) -> Bool {
        return a.0.isZero && a.1.isZero && a.2.isZero
    }
    
    public func sqrt(_ a: (FiniteFieldElement<F>, FiniteFieldElement<F>, FiniteFieldElement<F>)) -> (FiniteFieldElement<F>, FiniteFieldElement<F>, FiniteFieldElement<F>) {
        precondition(false)
        let zero = self.zeroElement
        return zero
    }
    
}
