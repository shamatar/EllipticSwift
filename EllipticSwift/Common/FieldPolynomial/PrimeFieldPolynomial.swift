//
//  PrimeFieldPolynomial.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

public struct PrimeFieldPolynomial<F>: FieldPolynomialProtocol where F: PrimeFieldProtocol {
    public typealias Field = F
    public typealias FE = PrimeFieldElement<F>
    
    public var field: Field
    public var coefficients: [FE]
    public var degree: Int {
        return self.coefficients.count - 1
    }
    public var isZero: Bool {
        return self.coefficients.count == 0
    }
    
    public init(field: Field) {
        self.field = field
        self.coefficients = [FE]()
    }
    
    public init(_ coefficients: [BytesRepresentable], field: Field) {
        self.field = field
        let zero = FE.zeroElement(field)
        var coeffs = [FE](repeating: zero, count: coefficients.count)
        for (i, c) in coefficients.enumerated() {
            let converted = PrimeFieldElement.fromValue(c, field: field)
            coeffs[i] = converted
        }
        self.coefficients = coeffs
    }
    
    public init(_ coefficients: [Field.UnderlyingRawType], field: Field) {
        self.field = field
        let zero = FE.zeroElement(field)
        var coeffs = [FE](repeating: zero, count: coefficients.count)
        for (i, c) in coefficients.enumerated() {
            let converted = PrimeFieldElement.fromValue(c, field: field)
            coeffs[i] = converted
        }
        self.coefficients = coeffs
    }
    
    public init(_ coefficients: [FE]) {
        precondition(coefficients.count > 0)
        self.coefficients = coefficients
        self.field = coefficients.first!.field
    }
    
    public func add(_ p: PrimeFieldPolynomial<F>) -> PrimeFieldPolynomial<F> {
        let longest = self.degree >= p.degree ? self.coefficients : p.coefficients
        let shortest = self.degree < p.degree ? self.coefficients : p.coefficients
        let zero = FE.zeroElement(self.field)
        var coeffs = [FE](repeating: zero, count: longest.count)
        for i in 0 ..< longest.count {
            if i < shortest.count {
                let newVal = longest[i] + shortest[i]
                coeffs[i] = newVal
            } else {
                coeffs[i] = longest[i]
            }
        }
        return PrimeFieldPolynomial<F>(coeffs)
    }
    
    public func neg() -> PrimeFieldPolynomial<F> {
        let zero = FE.zeroElement(self.field)
        var coeffs = [FE](repeating: zero, count: self.coefficients.count)
        for (i, c) in self.coefficients.enumerated() {
            coeffs[i] = c.negate()
        }
        return PrimeFieldPolynomial<F>(coeffs)
    }
    
    public func sub(_ p: PrimeFieldPolynomial<F>) -> PrimeFieldPolynomial<F> {
        let interm = self.add(p.neg())
        var topCoeff = -1
        for i in stride(from: 0, to: interm.coefficients.count - 1, by: 1).reversed() {
            if interm.coefficients[i].isZero {
                continue
            } else {
                topCoeff = i
                break
            }
        }
        if topCoeff == -1 {
            return PrimeFieldPolynomial(field: self.field)
        }
        let coeffs = [FE](interm.coefficients[0 ... topCoeff])
        return PrimeFieldPolynomial<F>(coeffs)
        
    }
    public func mul(_ p: PrimeFieldPolynomial<F>) -> PrimeFieldPolynomial<F> {
        let zero = FE.zeroElement(self.field)
        var coeffs = [FE](repeating: zero, count: self.coefficients.count + p.coefficients.count - 1)
        for (i, a) in self.coefficients.enumerated() {
            for (j, b) in p.coefficients.enumerated() {
                coeffs[i + j] = coeffs[i + j] + a * b
            }
        }
        return PrimeFieldPolynomial<F>(coeffs)
    }
    
    public func div(_ p: PrimeFieldPolynomial<F>) -> (PrimeFieldPolynomial<F>, PrimeFieldPolynomial<F>) {
        var quotient = PrimeFieldPolynomial<F>(field: self.field)
        var remainder = self
        let divisorDeg = p.degree
        let divisorLC = p.coefficients.last!
        let zero = FE.zeroElement(self.field)
        while remainder.degree >= divisorDeg {
            let monomialExponent = remainder.degree - divisorDeg
            let monomialZeros = [PrimeFieldElement](repeating: zero, count: monomialExponent)
            let divs = remainder.coefficients.last! * divisorLC.inv()
            let monomialDivisor = PrimeFieldPolynomial<F>(monomialZeros + [divs])
            quotient = quotient.add(monomialDivisor)
            remainder = remainder.sub(monomialDivisor.mul(p))
        }
        return (quotient, remainder)
    }
    
    public func equals(_ other: PrimeFieldPolynomial<F>) -> Bool {
        if self.degree != other.degree {
            return false
        }
        for i in 0 ..< self.degree {
            if self.coefficients[i] != other.coefficients[i] {
                return false
            }
        }
        return true
    }
    
    public func evaluate(_ x: FE) -> FE {
        var p = FE.identityElement(self.field)
        var accumulator = self.coefficients[0] * p
        for i in 1 ..< self.coefficients.count {
            p = p * x
            let c = self.coefficients[i]
            if c.isZero {
                continue
            }
            accumulator = accumulator + p * c
        }
        return accumulator
    }
}

extension PrimeFieldPolynomial: CustomStringConvertible {
    public var description: String {
        var descr = ""
        descr += "Degree = \(self.degree)\n"
        for i in 0 ..< self.coefficients.count {
            descr += "Coefficient \(i) = \(String(self.coefficients[i].value))\n"
        }
        return descr
    }
}
