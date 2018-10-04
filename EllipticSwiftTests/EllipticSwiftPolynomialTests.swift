//
//  EllipticSwiftPolynomialTests.swift
//  EllipticSwiftTests
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt

@testable import EllipticSwift
class EllipticSwiftPolynomialTests: XCTestCase {

    func testTrivialPoly() {
        let field = EllipticSwift.bn256PrimeField
        let emptyPoly = FieldPolynomial(field: field)
        XCTAssert(emptyPoly.isZero)
    }
    
    func testEvaluationAtZero() {
        let field = EllipticSwift.bn256PrimeField
        let zero = FieldElement.zeroElement(field)
        let one = FieldElement.fromValue(UInt64(1), field: field)
        let arrayOfCoefficients = [FieldElement](repeating: one, count: 9)
        let poly = FieldPolynomial(arrayOfCoefficients)
        let eval = poly.evaluate(zero)
        XCTAssert(eval.isZero)
    }
    
    func testEvaluationAtOne() {
        let field = EllipticSwift.bn256PrimeField
        let one = FieldElement.fromValue(UInt64(1), field: field)
        let arrayOfCoefficients = [FieldElement](repeating: one, count: 9)
        let NINE = FieldElement.fromValue(UInt64(9), field: field)
        let poly = FieldPolynomial(arrayOfCoefficients)
        let eval = poly.evaluate(one)
        XCTAssert(eval == NINE)
    }
    
    func testDescription() {
        let field = EllipticSwift.bn256PrimeField
        let one = FieldElement.fromValue(UInt64(1), field: field)
        let arrayOfCoefficients = [FieldElement](repeating: one, count: 9)
        let poly = FieldPolynomial(arrayOfCoefficients)
        print(poly.description)
    }
    
    func testMultiplicationAndDivision() {
        let field = EllipticSwift.bn256PrimeField
        let one = FieldElement.fromValue(UInt64(1), field: field)
        let two = FieldElement.fromValue(UInt64(2), field: field)
        let arrayOfCoefficients = [FieldElement](repeating: one, count: 2)
        let poly = FieldPolynomial(arrayOfCoefficients)
        let res = [one, two, one]
        let resPoly = FieldPolynomial(res)
        XCTAssert(poly.mul(poly).equals(resPoly))
        let (q, r) = resPoly.div(poly)
        XCTAssert(poly.equals(q))
        XCTAssert(r.isZero)
    }
    
    func testQuadraticExtension1() {
        let modulus = EllipticSwift.bn256Prime
        let field = NaivePrimeFiniteField(modulus)
        let zero = FiniteFieldElement.zeroElement(field)
        let oneScalar = U256(UInt64(1))
        let twoScalar = U256(UInt64(2))
        let one = FiniteFieldElement(oneScalar, field: field)
        let two = FiniteFieldElement(twoScalar, field: field)
        
        let quadraticExtField = QuadraticExtensionField((one, zero, one), field: field)
        let aEl = (one, one)
        let bEl = (two, two)
        
        let a = FiniteFieldElement.init(aEl, field: quadraticExtField)
        let b = FiniteFieldElement.init(bEl, field: quadraticExtField)

        let mul = a * b
        XCTAssert(mul.rawValue.1.value.debugDescription == "4")
        XCTAssert(mul.rawValue.0.value.debugDescription == "0")
    }
    
    func testQuadraticExtensionInternalDivision() {
        let modulus = EllipticSwift.bn256Prime
        let field = NaivePrimeFiniteField(modulus)
        let zero = FiniteFieldElement.zeroElement(field)
        let oneScalar = U256(UInt64(1))
        let twoScalar = U256(UInt64(2))
        let one = FiniteFieldElement(oneScalar, field: field)
        let two = FiniteFieldElement(twoScalar, field: field)
        let quadraticExtField = QuadraticExtensionField((one, zero, one), field: field)
        let t = (two, two, two)
        let (q, r) = quadraticExtField.div(t, quadraticExtField.reducingPolynomial)
        XCTAssert(q.2.value == 0)
        XCTAssert(q.1.value == 0)
        XCTAssert(q.0.value == 2)

        XCTAssert(r.2.value == 0)
        XCTAssert(r.1.value == 2)
        XCTAssert(r.0.value == 0)
    }

    func testQuadraticExtensionInversion() {
        let modulus = EllipticSwift.bn256Prime
        let field = NaivePrimeFiniteField(modulus)
        let zero = FiniteFieldElement.zeroElement(field)
        let oneScalar = U256(UInt64(1))
        let twoScalar = U256(UInt64(2))
        let one = FiniteFieldElement(oneScalar, field: field)
        let two = FiniteFieldElement(twoScalar, field: field)
        let quadraticExtField = QuadraticExtensionField((one, zero, one), field: field)
        let a = (two, two)
        let inv = quadraticExtField.inv(a)
        let mulBack = quadraticExtField.mul(inv, a)
        XCTAssert(mulBack.1.isZero)
        XCTAssert(mulBack.0.value == 1)
    }

    func testQuadraticExtensionInversion2() {
        let modulus = EllipticSwift.bn256Prime
        let field = NaivePrimeFiniteField(modulus)
        let zero = FiniteFieldElement.zeroElement(field)
        let oneScalar = U256(UInt64(1))
        let one = FiniteFieldElement(oneScalar, field: field)
        let quadraticExtField = QuadraticExtensionField((one, zero, one), field: field)
        for _ in 0 ..< 10 {
            let aScalar = U256(BigUInt.randomInteger(lessThan: 7).serialize())!
            let bScalar = U256(BigUInt.randomInteger(lessThan: 7).serialize())!
            let a = FiniteFieldElement(aScalar, field: field)
            let b = FiniteFieldElement(bScalar, field: field)
            if a.isZero && b.isZero {
                continue
            }
            let A = (a, b) // a + i*b
            let modulus = (a * a + b * b).inv()
            let res = quadraticExtField.inv(A)
            let manualInverse = (a * modulus, b.negate() * modulus) // (a - i*b)/(a^2 + b^2)
            let mulBack = quadraticExtField.mul(manualInverse, A)
            let ident = quadraticExtField.mul(res, A)
            XCTAssert(ident == mulBack)
            XCTAssert(ident == quadraticExtField.identityElement)
        }

    }

    func testQuadraticFieldMultiplication() {
        let modulus = EllipticSwift.bn256Prime
        let field = NaivePrimeFiniteField(modulus)
        let zero = FiniteFieldElement.zeroElement(field)
        let oneScalar = U256(UInt64(1))
        let one = FiniteFieldElement(oneScalar, field: field)
        let quadraticExtField = QuadraticExtensionField((one, zero, one), field: field) // x^2 + 1
        for _ in 0 ..< 10 {
            let a = FiniteFieldElement(U256(BigUInt.randomInteger(withMaximumWidth: 250).serialize())!, field: field)
            let b = FiniteFieldElement(U256(BigUInt.randomInteger(withMaximumWidth: 250).serialize())!, field: field)
            let c = FiniteFieldElement(U256(BigUInt.randomInteger(withMaximumWidth: 250).serialize())!, field: field)
            let d = FiniteFieldElement(U256(BigUInt.randomInteger(withMaximumWidth: 250).serialize())!, field: field)
            let A = (a, b)
            let B = (c, d)
            let res = quadraticExtField.mul(A, B)
            XCTAssert(res.0 == a * c - b * d) // real part
            XCTAssert(res.1 == a * d + b * c) // imaginary
        }
    }
    
    func testCubicExtensionMultiplication() {
        let field = NaivePrimeFiniteField(U256(UInt64(7)))
        let zero = FiniteFieldElement.zeroElement(field)
        let oneScalar = U256(UInt64(1))
        let twoScalar = U256(UInt64(2))
        let one = FiniteFieldElement(oneScalar, field: field)
        let two = FiniteFieldElement(twoScalar, field: field)
        let cubicExtensionField = CubicExtensionField((two, zero, zero, one), field: field)
        let A = FiniteFieldElement((one, one, one), field: cubicExtensionField)
        let B = FiniteFieldElement((two, two, two), field: cubicExtensionField)
        let C = A * B
        print(C.rawValue.2.value)
        print(C.rawValue.1.value)
        print(C.rawValue.0.value)
    }
    
    func testCubicExtensionInversion() {
        let field = NaivePrimeFiniteField(U256(UInt64(7)))
        let zero = FiniteFieldElement.zeroElement(field)
        let oneScalar = U256(UInt64(1))
        let twoScalar = U256(UInt64(2))
        let one = FiniteFieldElement(oneScalar, field: field)
        let two = FiniteFieldElement(twoScalar, field: field)
        let cubicExtensionField = CubicExtensionField((two, zero, zero, one), field: field)
        let extensionIdentityElement = FiniteFieldElement.identityElement(cubicExtensionField)
        for _ in 0 ..< 10 {
            let aScalar = U256(BigUInt.randomInteger(lessThan: 7).serialize())!
            let bScalar = U256(BigUInt.randomInteger(lessThan: 7).serialize())!
            let cScalar = U256(BigUInt.randomInteger(lessThan: 7).serialize())!
//            let dScalar = U256(BigUInt.randomInteger(lessThan: 5).serialize())!
            let a = FiniteFieldElement(aScalar, field: field)
            let b = FiniteFieldElement(bScalar, field: field)
            let c = FiniteFieldElement(cScalar, field: field)
            if a.isZero && b.isZero && c.isZero {
                continue
            }
            let FFElement = FiniteFieldElement((a, b, c), field: cubicExtensionField)
            let res = FFElement.inv()
            let ident = FFElement * res
            XCTAssert(ident == extensionIdentityElement)
        }
        
    }

}
