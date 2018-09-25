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
        let field = EllipticSwift.bn256PrimeField
        let zero = FieldElement.zeroElement(field)
        let one = FieldElement.fromValue(UInt64(1), field: field)
        let two = FieldElement.fromValue(UInt64(2), field: field)
        
        let quadraticExtField = QuadraticExtensionField((one, zero, one), field: field)
        
        let a = QuadraticExtensionFieldElement.init((one, one), extensionField: quadraticExtField)
        let b = QuadraticExtensionFieldElement.init((two, two), extensionField: quadraticExtField)
        
        let mul = a * b
        print(mul)
    }
    
    func testQuadraticExtensionInternalDivision() {
        let field = EllipticSwift.bn256PrimeField
        let zero = FieldElement.zeroElement(field)
        let one = FieldElement.fromValue(UInt64(1), field: field)
        let two = FieldElement.fromValue(UInt64(2), field: field)
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
        let field = NaivePrimeField<U256>(BigUInt(7))
        let zero = FieldElement.zeroElement(field)
        let one = FieldElement.fromValue(UInt64(1), field: field)
        let two = FieldElement.fromValue(UInt64(2), field: field)
        let quadraticExtField = QuadraticExtensionField((one, zero, one), field: field)
        let a = (two, two)
        let inv = quadraticExtField.inv(a)
        print(inv.1.value)
        print(inv.0.value)
        let mulBack = quadraticExtField.mul(inv, a)
        print(mulBack.1.value)
        print(mulBack.0.value)
    }
    
    func testQuadraticExtensionInversion2() {
        let field = NaivePrimeField<U256>(BigUInt(7))
        let zero = FieldElement.zeroElement(field)
        let one = FieldElement.fromValue(UInt64(1), field: field)
        let quadraticExtField = QuadraticExtensionField((one, zero, one), field: field)
        for _ in 0 ..< 10 {
            let a = FieldElement.fromValue(BigUInt.randomInteger(lessThan: 7), field: field)
            let b = FieldElement.fromValue(BigUInt.randomInteger(lessThan: 7), field: field)
            if a.isZero && b.isZero {
                continue
            }
            let A = (a, b) // a + i*b
            print("A = ")
            print(A.1.value)
            print(A.0.value)
            let modulus = (a * a + b * b).inv()
            let res = quadraticExtField.inv(A)
            print("Field inverse")
            print(res.1.value)
            print(res.0.value)
            let manualInverse = (a * modulus, b.negate() * modulus) // (a - i*b)/(a^2 + b^2)
            print("Manual inverse")
            print(manualInverse.1.value)
            print(manualInverse.0.value)
            let mulBack = quadraticExtField.mul(manualInverse, A)
            let ident = quadraticExtField.mul(res, A)
            print("Identity for manual inverse")
            print(mulBack.1.value)
            print(mulBack.0.value)
            print("Identity for field inverse")
            print(ident.1.value)
            print(ident.0.value)
        }

    }
    
    func testQuadraticFieldMultiplication() {
        let field = EllipticSwift.bn256PrimeField
        let zero = FieldElement.zeroElement(field)
        let one = FieldElement.fromValue(UInt64(1), field: field)
        let quadraticExtField = QuadraticExtensionField((one, zero, one), field: field) // x^2 + 1
        for _ in 0 ..< 10 {
            let a = FieldElement.fromValue(BigUInt.randomInteger(withMaximumWidth: 250), field: field)
            let b = FieldElement.fromValue(BigUInt.randomInteger(withMaximumWidth: 250), field: field)
            let c = FieldElement.fromValue(BigUInt.randomInteger(withMaximumWidth: 250), field: field)
            let d = FieldElement.fromValue(BigUInt.randomInteger(withMaximumWidth: 250), field: field)
            let A = (a, b)
            let B = (c, d)
            let res = quadraticExtField.mul(A, B)
            XCTAssert(res.0 == a * c - b * d) // real part
            XCTAssert(res.1 == a * d + b * c) // imaginary
        }
    }
}
