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
}
