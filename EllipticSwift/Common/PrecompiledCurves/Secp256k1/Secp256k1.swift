//
//  Secp256k1.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

// secp256k1
internal let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
public let secp256k1Prime = U256(secp256k1PrimeBUI.serialize())!
let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1PrimeBUI)
internal let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
public let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
public let secp256k1Curve: WeierstrassCurve<NaivePrimeField<U256>> = {
    let curve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(UInt64(0)), B: U256(UInt64(7)))
    let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
    let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
    let success = curve.testGenerator(AffineCoordinates(generatorX, generatorY))
    precondition(success, "Failed to init secp256k1 curve!")
    return curve
}()
