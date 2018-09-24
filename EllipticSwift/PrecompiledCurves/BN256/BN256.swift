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

