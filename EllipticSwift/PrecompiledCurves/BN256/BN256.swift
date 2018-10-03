//
//  BN256.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

// bn256
internal let bn256PrimeBUI = BigUInt("21888242871839275222246405745257275088696311157297823662689037894645226208583", radix: 10)!
public let bn256Prime = U256(bn256PrimeBUI.serialize())!
public let bn256PrimeField = MontPrimeField<U256>(bn256PrimeBUI)
internal let bn256CurveOrderBUI = BigUInt("21888242871839275222246405745257275088548364400416034343698204186575808495617", radix: 10)!
public let bn256CurveOrder = U256(bn256CurveOrderBUI.serialize())!
public let bn256Curve: WeierstrassCurve<MontPrimeField<U256>> = {
    let curve = WeierstrassCurve(field: bn256PrimeField, order: bn256CurveOrder, A: U256(0), B: U256(3))
    let generatorX = BigUInt("1", radix: 10)!
    let generatorY = BigUInt("2", radix: 10)!
    let success = curve.testGenerator(AffineCoordinates(generatorX, generatorY))
    precondition(success, "Failed to init bn256 curve!")
    return curve
}()

public let BN256Prime = U256(bn256PrimeBUI.serialize())!
public let BN256FF = NaivePrimeFiniteField<U256>.init(BN256Prime)
internal let BN256FFzero = FiniteFieldElement.zeroElement(BN256FF)
internal let BN256FFone = FiniteFieldElement.identityElement(BN256FF)
internal let BN256FFthree = FiniteFieldElement.init(U256(UInt64(3)), field: BN256FF)
public let BN256F2ExtensionPolynomial = (BN256FFone, BN256FFzero, BN256FFone)
public let BN256F2 = QuadraticExtensionField(BN256F2ExtensionPolynomial, field: BN256FF)
internal let BN256F2zero = FiniteFieldElement.zeroElement(BN256F2)
internal let BN256F2one = FiniteFieldElement.identityElement(BN256F2)
internal let BN256F2ksi = FiniteFieldElement((BN256FFthree, BN256FFone), field: BN256F2).negate()
// cubic extension is over t^3 - (i+3) where (i+3) is an element of F2 and a zero polynomial term coefficient
public let BN256F6OverF2ExtensionPolynomial = (BN256F2ksi, BN256F2zero, BN256F2zero, BN256F2one)
public let BN256F6 = CubicExtensionField(BN256F6OverF2ExtensionPolynomial, field: BN256F2)

public let BN256CurveOrder = U256(bn256CurveOrderBUI.serialize())!
public let BN256G1Curve: ExtendableWeierstrassCurve<NaivePrimeFiniteField<U256>> = {
    let zero = U256(0) as FiniteFieldElement<NaivePrimeFiniteField<U256>>.RawType
    let three = U256(3) as FiniteFieldElement<NaivePrimeFiniteField<U256>>.RawType
    let curve = ExtendableWeierstrassCurve(field: BN256FF, order: BN256CurveOrder, A: zero, B: three)
    return curve
}()

