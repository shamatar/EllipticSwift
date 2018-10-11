//
//  EllipticSwiftTests.swift
//  EllipticSwiftTests
//
//  Created by Alex Vlasov on 20.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt

@testable import EllipticSwift
class EllipticSwiftTests: XCTestCase {
    
    func testBIimport() {
        let a = BigUInt(3)
        let b = BigUInt(97)
        let c = a.inverse(b)
        XCTAssert(c != nil)
    }
    
    func testFullMul() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = TinyUInt256(ar.serialize())!
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let b = TinyUInt256(br.serialize())!
        let res = a.multipliedFullWidth(by: b)
        let data = res.high.bytes + res.low.bytes
        let serialized = (ar * br).serialize()
        XCTAssert(serialized == Data(data[64 - serialized.count ..< 64]))
    }
    
    func testMulPerformance() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        measure {
            let _ = ar * br
        }
    }
    
    func testMulPerformanceTinyUInt() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = TinyUInt256(ar.serialize())!
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let b = TinyUInt256(br.serialize())!
        measure {
            let _ = a.multipliedFullWidth(by: b)
        }
    }
    
    func testModMul() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let modulus = TinyUInt256(secp256k1PrimeBUI.serialize())!
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = TinyUInt256(ar.serialize())!
        let b = TinyUInt256(br.serialize())!
        let res = a.modMultiply(b, modulus)
        let naive = (ar * br) % secp256k1PrimeBUI
        XCTAssert(String(naive) == String(res))
    }
    
    func testDivision128() {
        let ar = BigUInt.randomInteger(withExactWidth: 128)
        let br = BigUInt.randomInteger(lessThan: ar)
        let a = TinyUInt128(ar.serialize())!
        let b = TinyUInt128(br.serialize())!
        let (q, r) = a.quotientAndRemainder(dividingBy: b)
        let (qr, rr) = ar.quotientAndRemainder(dividingBy: br)
        print(String(q))
        print(String(qr))
        XCTAssert(String(q) == String(qr))
        XCTAssert(String(r) == String(rr))
    }
    
    func testDivision() {
        let ar = BigUInt.randomInteger(withExactWidth: 256)
        let br = BigUInt.randomInteger(lessThan: ar)
        let a = TinyUInt256(ar.serialize())!
        let b = TinyUInt256(br.serialize())!
        let (q, r) = a.quotientAndRemainder(dividingBy: b)
        let (qr, rr) = ar.quotientAndRemainder(dividingBy: br)
        XCTAssert(String(q) == String(qr))
        XCTAssert(String(r) == String(rr))
    }
    
    func testDivisionPerf() {
        let ar = BigUInt.randomInteger(withExactWidth: 256)
        let br = BigUInt.randomInteger(lessThan: ar)
        measure {
            let _ = ar.quotientAndRemainder(dividingBy: br)
        }
    }
    
    func testDivisionPerf128() {
        let ar = BigUInt.randomInteger(withExactWidth: 128)
        let br = BigUInt.randomInteger(lessThan: ar)
        measure {
            let _ = ar.quotientAndRemainder(dividingBy: br)
        }
    }
    
    func testDivisionPerfTinyUInt128() {
        let ar = BigUInt.randomInteger(withExactWidth: 128)
        let br = BigUInt.randomInteger(lessThan: ar)
        let a = TinyUInt128(ar.serialize())!
        let b = TinyUInt128(br.serialize())!
        measure {
            let _ = a.quotientAndRemainder(dividingBy: b)
        }
    }
    
    func testDivisionPerfTinyUInt256() {
        let ar = BigUInt.randomInteger(withExactWidth: 256)
        let br = BigUInt.randomInteger(lessThan: ar)
        let a = TinyUInt256(ar.serialize())!
        let b = TinyUInt256(br.serialize())!
        measure {
            let _ = a.quotientAndRemainder(dividingBy: b)
        }
    }
    
    func testModMulPerf() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        measure {
            let _ = (ar * br) % secp256k1PrimeBUI
        }
    }
    
    func testModMulPerfTinuUInt256() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let modulus = TinyUInt256(secp256k1PrimeBUI.serialize())!
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = TinyUInt256(ar.serialize())!
        let b = TinyUInt256(br.serialize())!
        measure {
            let _ = a.modMultiply(b, modulus)
        }
    }
    
    func testModMulPerfNativeU256() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let modulus = NativeU256(secp256k1PrimeBUI.serialize())!
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = NativeU256(ar.serialize())!
        let b = NativeU256(br.serialize())!
        measure {
            let _ = a.modMultiply(b, modulus)
        }
    }
    
    func testModMulPerfTinuUInt256InMont() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let secp256k1PrimeField = MontPrimeField<TinyUInt256>.init(secp256k1PrimeBUI)
        let a = TinyUInt256(ar.serialize())!
        let b = TinyUInt256(br.serialize())!
        let A = FieldElement.fromValue(a, field: secp256k1PrimeField)
        let B = FieldElement.fromValue(b, field: secp256k1PrimeField)
        measure {
            let _ = A * B
        }
    }
    
    func testProfileModExp() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = TinyUInt256(ar.serialize())!
        let b = TinyUInt256(br.serialize())!
        let secp256k1PrimeField = NaivePrimeField<TinyUInt256>.init(secp256k1PrimeBUI)
        let _ = secp256k1PrimeField.pow(a, b)
    }
    
    func testExpPerformance() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        measure {
            let _ = ar.power(br, modulus: secp256k1PrimeBUI)
        }
    }
    
    func testExpPerformanceTinyUInt() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = TinyUInt256(ar.serialize())!
        let b = TinyUInt256(br.serialize())!
        let secp256k1PrimeField = NaivePrimeField<TinyUInt256>.init(secp256k1PrimeBUI)
        measure {
            let _ = secp256k1PrimeField.pow(a, b)
        }
    }
    
    func testExpPerformanceTinyUIntMontForm() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = TinyUInt256(ar.serialize())!
        let b = TinyUInt256(br.serialize())!
        let secp256k1PrimeField = MontPrimeField<TinyUInt256>.init(secp256k1PrimeBUI)
        measure {
            let _ = secp256k1PrimeField.pow(a, b)
        }
    }
    
    func testPointDoublingAndMultiplication() {
        let c = EllipticSwift.secp256k1Curve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let dbl = c.double(p!.toProjective()).toAffine().coordinates
        let mul = c.mul(2, p!).toAffine().coordinates
        XCTAssert(!dbl.isInfinity)
        XCTAssert(!mul.isInfinity)
        XCTAssert(dbl.X == mul.X)
        XCTAssert(dbl.Y == mul.Y)
    }
    
    func testPointConversionCycle() {
        let c = EllipticSwift.secp256k1Curve
        let x = BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!
        let y = BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!
        let p = c.toPoint(x, y)
        XCTAssert(p != nil)
        let proj = p!.toProjective()
        let backToAffine = proj.toAffine().coordinates
        XCTAssert(backToAffine.X == x)
        XCTAssert(backToAffine.Y == y)
    }
    
    func testPointAddition() {
        let c = EllipticSwift.secp256k1Curve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let q = c.toPoint(BigUInt("a1904a2f1366086462462b759857ee4ec785343d9e9c64f980527a9b62651e31", radix: 16)!, BigUInt("3e0e62a6dd89b0775092c1552751c35cf0769b4b2647ce6491e88dbff1c692ce", radix: 16)!)
        XCTAssert(q != nil)
        let sum = c.add(p!.toProjective(), q!.toProjective())
        let sumAffine = sum.toAffine().coordinates
        XCTAssert(!sumAffine.isInfinity)
        XCTAssert(sumAffine.X == BigUInt("cb48b4b3237451109ddd2fb9146556f4c1acb4082a9c667adf4fcb9b0bb6ff83", radix: 16)!)
        XCTAssert(sumAffine.Y == BigUInt("b47df17dfc7607880c54f2c2bfea0f0118c79319573dc66fcb0d952115beb554", radix: 16)!)
    }
    
    func testPointDouble() {
        let c = EllipticSwift.secp256k1Curve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let dbl = c.add(p!.toProjective(), p!.toProjective())
        let affine = dbl.toAffine().coordinates
        XCTAssert(!affine.isInfinity)
        XCTAssert(affine.X == BigUInt("aad76204cd11092a84f04694138db345b1d7223a0bba5483cd089968a34448cb", radix: 16)!)
        XCTAssert(affine.Y == BigUInt("7cfb0467e5df4e174c1ee43c5dcca494cd3e198cf9512f7088bea0a8a76f7d78", radix: 16)!)
    }
    
    func testPointMul() {
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = EllipticSwift.secp256k1Curve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let res = c.mul(U256(scalar.serialize())!, p!)
        let resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
    }
    
    func testLargeFieldInv() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
            let trivialRes = ar.inverse(secp256k1PrimeBUI)!
            let res = a.inv()
            XCTAssert(res.value == trivialRes, "Failed on attempt = " + String(i))
        }
    }

    func testLargeFieldMul() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
            let b = FieldElement.fromBytes(br.serialize(), field: secp256k1PrimeField)
            let fullTrivialMul = ar * br
            let pTrivial = fullTrivialMul % secp256k1PrimeBUI
            let p = a * b
            XCTAssert(p.value == pTrivial, "Failed on attempt = " + String(i))
        }
    }

    func testLargeFieldAddition() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
            let b = FieldElement.fromBytes(br.serialize(), field: secp256k1PrimeField)
            let fullTrivialMul = ar + br
            let pTrivial = fullTrivialMul % secp256k1PrimeBUI
            let p = a + b
            XCTAssert(p.value == pTrivial, "Failed on attempt = " + String(i))
        }
    }

    func testLargeFieldPow() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let base = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let power = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let pTrivial = base.power(power, modulus: secp256k1PrimeBUI)
            let a = FieldElement.fromBytes(base.serialize(), field: secp256k1PrimeField)
            let p = a.pow(U256(power.serialize())!)
            XCTAssert(p.value == pTrivial, "Failed on attempt = " + String(i))
        }
    }
    
    func testLargeFieldInvNativeU256() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<NativeU256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
            let trivialRes = ar.inverse(secp256k1PrimeBUI)!
            let res = a.inv()
            XCTAssert(res.value == trivialRes, "Failed on attempt = " + String(i))
        }
    }
    
    func testLargeFieldMulNativeU256() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<NativeU256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
            let b = FieldElement.fromBytes(br.serialize(), field: secp256k1PrimeField)
            let fullTrivialMul = ar * br
            let pTrivial = fullTrivialMul % secp256k1PrimeBUI
            let p = a * b
            XCTAssert(p.value == pTrivial, "Failed on attempt = " + String(i))
        }
    }
    
    func testLargeFieldAdditionNativeU256() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<NativeU256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
            let b = FieldElement.fromBytes(br.serialize(), field: secp256k1PrimeField)
            let fullTrivialMul = ar + br
            let pTrivial = fullTrivialMul % secp256k1PrimeBUI
            let p = a + b
            XCTAssert(p.value == pTrivial, "Failed on attempt = " + String(i))
        }
    }
    
    func testLargeFieldPowNativeU256() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<NativeU256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let base = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let power = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let pTrivial = base.power(power, modulus: secp256k1PrimeBUI)
            let a = FieldElement.fromBytes(base.serialize(), field: secp256k1PrimeField)
            let p = a.pow(U256(power.serialize())!)
            XCTAssert(p.value == pTrivial, "Failed on attempt = " + String(i))
        }
    }
    
    func testFieldInversion() {
        let modulus = BigUInt(97)
        let inverse = BigUInt(3).inverse(modulus)!
        let field = NaivePrimeField<U256>(modulus)
        let fe1 = FieldElement.fromValue(UInt64(3), field: field)
        let inv = fe1.inv()
        XCTAssert(inverse == inv.value)
        let mul = fe1 * inv
        XCTAssert(mul.value == 1)
    }
    
    func testMontFieldConversion() {
        let modulus = BigUInt(97)
        let field = MontPrimeField<U256>(modulus)
        let forward = FieldElement.fromValue(UInt64(3), field: field)
        let back = forward.value
        XCTAssert(back == 3)
        let rawValue = U256(3)
        let reduced = rawValue.toMontForm(U256(modulus.serialize())!)
        XCTAssert(forward.rawValue == reduced)
    }
    
    func testMontParamsCalculation() {
        let modulus = BigUInt(97)
        let field = MontPrimeField<U256>(modulus)
        let R = BigUInt(1) << 256
        let montR = R % modulus
        XCTAssert(montR == BigUInt(field.montR.bytes))
        let montInvR = montR.inverse(modulus)!
        XCTAssert(montInvR == BigUInt(field.montInvR.bytes))
        let montK = (R * montInvR - BigUInt(1)) / modulus
        XCTAssert(montK == BigUInt(field.montK.bytes))
        XCTAssert(BigUInt(field.montR.modMultiply(field.montInvR, field.prime).bytes) == 1)
    }
    
    //    func testMontReduction() {
    //        let modulus = BigUInt(97)
    //        let field = MontPrimeField<U256>(modulus)
    //        let R = BigUInt(1) << 256
    //        let montR = R % modulus
    //        XCTAssert(montR == BigUInt(field.montR.bytes))
    //        let montInvR = montR.inverse(modulus)!
    //        XCTAssert(montInvR == BigUInt(field.montInvR.bytes))
    //        let montK = (R * montInvR - BigUInt(1)) / modulus
    //        XCTAssert(montK == BigUInt(field.montK.bytes))
    //
    //        let a = BigUInt.randomInteger(lessThan: modulus)
    //        let aReduced = (a * R) % modulus
    //        let fe = FieldElement.fromValue(a, field: field)
    //        XCTAssert(aReduced == BigUInt(fe.rawValue.bytes))
    //    }
    
    func testMontMultiplication() {
        let modulus = BigUInt(97)
        let field = MontPrimeField<U256>(modulus)
        let a = FieldElement.fromValue(UInt64(43), field: field)
        let b = FieldElement.fromValue(UInt64(56), field: field)
        let mul = a * b
        let value = mul.value
        XCTAssert(value == 80)
    }
    
    func testModularSquareRoot() {
        let bn256Prime = BigUInt("21888242871839275222246405745257275088696311157297823662689037894645226208583", radix: 10)!
        let bn256PrimeField = NaivePrimeField<U256>(bn256Prime)
        let primeField = bn256PrimeField
        let x = BigUInt("16013846061302606236678105035458059333313648338706491832021059651102665958964", radix: 10)!
        let xReduced = FieldElement.fromValue(x, field: primeField)
        let sqrtReduced = xReduced.sqrt()
        let y = sqrtReduced.value
        //        XCTAssert(sqrtReduced * sqrtReduced == xReduced)
        //        XCTAssert((y * y) % primeField.modulus == x)
        XCTAssert(y == BigUInt("19775247992460679389771436516608933805782779220511590267128505960436574705663", radix: 10)!)
    }
    
    func testNaiveModularMultiplicationPerformance() {
        let bn256Prime = BigUInt("21888242871839275222246405745257275088696311157297823662689037894645226208583", radix: 10)!
        let modulus = U256(bn256Prime.serialize())!
        let number1 = BigUInt.randomInteger(lessThan: bn256Prime)
        let number2 = BigUInt.randomInteger(lessThan: bn256Prime)
        let bn1 = U256(number1.serialize())!
        let bn2 = U256(number2.serialize())!
        measure {
            let _ = bn1.modMultiply(bn2, modulus)
        }
    }
    
    func testBitWidth() {
        let br = BigUInt(11749)
        let b = U256(br.serialize())!
        let leadingZeroes = UInt32(11794).leadingZeroBitCount
        let actualWidth = 32 - leadingZeroes
        let bitWidth = b.bitWidth
        let largeLeadingZeroes = b.leadingZeroBitCount
        XCTAssert(largeLeadingZeroes + bitWidth == 256)
        XCTAssert(actualWidth == bitWidth)
        XCTAssert(leadingZeroes + 224 == largeLeadingZeroes)
    }
    
    func testComputeSlidingWindow() {
        let exponent = 12686028502
        let br = BigUInt(exponent)
        let b = U256(br.serialize())!
        let windowSize = 5
        let (lookups, powers) = computeSlidingWindow(scalar: b, windowSize: windowSize)
        let numPrecomputedElements = (1 << windowSize) - 1 // 2**k - 1
        var precomputations = [Int](repeating: 0, count: numPrecomputedElements)
        precomputations[0] = 1
        precomputations[1] = 2
        for i in 2 ..< numPrecomputedElements {
            precomputations[i] = precomputations[i-2] + precomputations[1]
        }
        XCTAssert(lookups[0] != -1)
        // base implementation of sliding windows exponentiation
        var resultOrder = 0
        for i in 0 ..< lookups.count {
            if lookups[i] == -1 {
                resultOrder = resultOrder * 2
            } else {
                let power = powers[i]
                let intermediatePower = resultOrder * Int(power)
                resultOrder = intermediatePower + precomputations[lookups[i]]
            }
        }
        XCTAssert(resultOrder == exponent)
    }
    
    func testDifferentSquaring() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
        let br = BigUInt(2)
        let b = U256(br.serialize())!
        let mul = a * a
        let trivial = a.field.doubleAndAddExponentiation(a.rawValue, b)
        let sliding = a.field.kSlidingWindowExponentiation(a.rawValue, b, windowSize: 5)
        XCTAssert(mul.rawValue == trivial)
        XCTAssert(trivial == sliding)
    }
    
    func testDifferentCubing() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
        let br = BigUInt(3)
        let b = U256(br.serialize())!
        var mul = a.field.mul(a.rawValue, a.rawValue)
        mul = a.field.mul(a.rawValue, mul)
        let trivial = a.field.doubleAndAddExponentiation(a.rawValue, b)
        let sliding = a.field.kSlidingWindowExponentiation(a.rawValue, b, windowSize: 5)
        XCTAssert(mul == trivial)
        XCTAssert(trivial == sliding)
    }
    
    func testDifferentExponentiations() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1Prime)
        for _ in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
            let br = BigUInt.randomInteger(withExactWidth: 256)
            let b = U256(br.serialize())!
            let trivial = a.field.doubleAndAddExponentiation(a.rawValue, b)
            let sliding = a.field.kSlidingWindowExponentiation(a.rawValue, b, windowSize: 5)
            let naive = ar.power(br, modulus: secp256k1PrimeBUI)
            XCTAssert(trivial == U256(naive.serialize())!)
            XCTAssert(trivial == sliding)
        }
    }
    
    func testDoubleAndAddExponentiationPerformance() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.doubleAndAddExponentiation(a.rawValue, b)
        }
    }
    
    func testSlidingWindowExponentiationPerformance() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NaivePrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.kSlidingWindowExponentiation(a.rawValue, b, windowSize: 5)
        }
    }
    
    func testDoubleAndAddExponentiationPerformanceInMontForm() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = MontPrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.doubleAndAddExponentiation(a.rawValue, b)
        }
    }
    
    func testSlidingWindowExponentiationPerformanceInMontForm() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = MontPrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.kSlidingWindowExponentiation(a.rawValue, b, windowSize: 5)
        }
    }
    
    func testWideSlidingWindowExponentiationPerformanceInMontForm() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = MontPrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.kSlidingWindowExponentiation(a.rawValue, b, windowSize: 16)
        }
    }
    
    func testNaviteModInverse() {
        let modulus = U256(97)
        let number = U256(3)
        let inverse = number.modInv(modulus)
        XCTAssert(inverse.v.0.clippedValue == 65)
    }
    
    func testGenericFEInversion() {
        let modulus = U256(97)
        let field = MontPrimeField<U256>(modulus)
        let fe = FieldElement.fromValue(UInt64(3), field: field)
        let inverse = fe.inv()
        let value = inverse.value
        XCTAssert(value == 65)
    }
    
    func testGenericFEMul() {
        let modulus = U256(97)
        let field = MontPrimeField<U256>(modulus)
        let fe = FieldElement.fromValue(UInt64(3), field: field)
        let mul = fe * fe
        let value = mul.value
        XCTAssert(value == 9)
    }
    
    func testGenericFEMulWithOverflow() {
        let modulus = U256(97)
        let field = MontPrimeField<U256>(modulus)
        let fe = FieldElement.fromValue(UInt64(40), field: field)
        let mul = fe * fe
        let value = mul.value
        XCTAssert(value == 48)
    }
    
    func testGenericDoubleAndAddExponentiationPerformanceInMontForm() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = MontPrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = FieldElement.fromBytes(ar.serialize(), field: secp256k1PrimeField)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.pow(b)
        }
    }
    
    func testGenericCurveCreation() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        //        let secp256k1PrimeField = MontPrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1PrimeField = NaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        precondition(success, "Failed to init secp256k1 curve!")
    }
    
    func testPointMulInGenerics() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        //        let secp256k1PrimeField = MontPrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1PrimeField = NaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let res = c.mul(U256(scalar.serialize())! , p!)
        let resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
    }
    
    func testPointMulInGenericsNativeU256() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        //        let secp256k1PrimeField = MontPrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1PrimeField = NaivePrimeField<NativeU256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = NativeU256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: NativeU256(UInt64(0)), B: NativeU256(UInt64(7)))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let ss = NativeU256(scalar.serialize())!
        let res = c.mul(ss, p!)
        let resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
    }
    
    func testPointMulInGenericsInMontForm() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let secp256k1PrimeField = MontPrimeField<U256>.init(secp256k1PrimeBUI)
        //        let secp256k1PrimeField = NaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        var res = c.wNAFmul(U256(scalar.serialize())! , p!)
        var resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
        res = c.doubleAndAddMul(U256(scalar.serialize())! , p!)
        resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
    }
    
    func testPointMulPerformanceDoubleAndAdd() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let secp256k1PrimeField = MontPrimeField<U256>.init(secp256k1PrimeBUI)
        //        let secp256k1PrimeField = NaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        measure {
            let _ = c.doubleAndAddMul(U256(scalar.serialize())! , p!)
        }
    }
    
    func testPointMulPerformanceWNAF() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let secp256k1PrimeField = MontPrimeField<U256>.init(secp256k1PrimeBUI)
        //        let secp256k1PrimeField = NaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        measure {
            let _ = c.wNAFmul(U256(scalar.serialize())! , p!)
        }
    }
    
    func testPointMulPerformanceWNAFNativeU256() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        //        let secp256k1PrimeField = MontPrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1PrimeField = NaivePrimeField<NativeU256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = NativeU256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: NativeU256(UInt64(0)), B: NativeU256(UInt64(7)))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        measure {
            let _ = c.wNAFmul(NativeU256(scalar.serialize())! , p!)
        }
    }
    
    func testPointMulPerformanceDoubleAndAddNativeU256() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        //        let secp256k1PrimeField = MontPrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1PrimeField = NaivePrimeField<NativeU256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = NativeU256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: NativeU256(UInt64(0)), B: NativeU256(UInt64(7)))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        measure {
            let _ = c.doubleAndAddMul(NativeU256(scalar.serialize())! , p!)
        }
    }
    
    func testUsage() {
        let curve = secp256k1Curve
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = curve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        // this is basically a private key - large random scalar
        let randomScalar = BigUInt.randomInteger(withMaximumWidth: 256)
        guard let privateKey = U256(randomScalar.serialize()) else { return XCTFail()}
        
        // make point. Point is made from affine coordinates in normal (not Montgomery) representation
        guard let G = curve.toPoint(generatorX, generatorY) else {return XCTFail()}
        
        // calculate a public key
        let publicKey = privateKey * G
        XCTAssert(!publicKey.isInfinity)
        
        // also try to multiply by group order
        let groupOrder = curve.order
        let expectInfinity = groupOrder * G
        XCTAssert(expectInfinity.isInfinity)
    }
    
    func testDifferentNativeTypes() {
        let curve = secp256k1Curve
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = curve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let curveNativeU256: WeierstrassCurve<NaivePrimeField<NativeU256>> = {
            let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
            let secp256k1PrimeField = NaivePrimeField<NativeU256>(secp256k1PrimeBUI)
            let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
            let secp256k1CurveOrder = NativeU256(secp256k1CurveOrderBUI.serialize())!
            let curve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: NativeU256(UInt64(0)), B: NativeU256(UInt64(7)))
            return curve
        }()
        
        let successNative = curveNativeU256.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(successNative, "Failed to init secp256k1 curve!")
        
        
        for _ in 0 ..< 100 {
            // this is basically a private key - large random scalar
            let randomScalar = BigUInt.randomInteger(withMaximumWidth: 256)
            guard let privateKey = U256(randomScalar.serialize()) else { return XCTFail()}
            guard let privateKeyNative = NativeU256(randomScalar.serialize()) else { return XCTFail()}
            // make point. Point is made from affine coordinates in normal (not Montgomery) representation
            guard let G = curve.toPoint(generatorX, generatorY) else {return XCTFail()}
            guard let GNative = curveNativeU256.toPoint(generatorX, generatorY) else {return XCTFail()}
            
            // calculate a public key
            let publicKey = privateKey * G
            let publicKeyNative = privateKeyNative * GNative
            XCTAssert(!publicKey.isInfinity)
            XCTAssert(!publicKeyNative.isInfinity)
            
            XCTAssert(publicKey.toAffine().coordinates.X == publicKeyNative.toAffine().coordinates.X)
            XCTAssert(publicKey.toAffine().coordinates.Y == publicKeyNative.toAffine().coordinates.Y)
            
            // also try to multiply by group order
            let groupOrder = curve.order
            let expectInfinity = groupOrder * G
            XCTAssert(expectInfinity.isInfinity)
            
            let groupOrderNative = curveNativeU256.order
            let expectInfinityNative = groupOrderNative * GNative
            XCTAssert(expectInfinityNative.isInfinity)
        }
    }
    
    func testDifferentNativeMultiplicationTypes() {
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        
        let curveNativeU256: WeierstrassCurve<NaivePrimeField<NativeU256>> = {
            let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
            let secp256k1PrimeField = NaivePrimeField<NativeU256>(secp256k1PrimeBUI)
            let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
            let secp256k1CurveOrder = NativeU256(secp256k1CurveOrderBUI.serialize())!
            let curve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: NativeU256(UInt64(0)), B: NativeU256(UInt64(7)))
            return curve
        }()
        
        let successNative = curveNativeU256.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(successNative, "Failed to init secp256k1 curve!")
        
        
        for _ in 0 ..< 100 {
            // this is basically a private key - large random scalar
            let randomScalar = BigUInt.randomInteger(withMaximumWidth: 256)
            guard let privateKeyNative = NativeU256(randomScalar.serialize()) else { return XCTFail()}
            guard let GNative = curveNativeU256.toPoint(generatorX, generatorY) else {return XCTFail()}
            
            // calculate a public key
            let publicKey = curveNativeU256.doubleAndAddMul(privateKeyNative, GNative)
            let publicKeyNative = curveNativeU256.wNAFmul(privateKeyNative, GNative)
            XCTAssert(!publicKey.isInfinity)
            XCTAssert(!publicKeyNative.isInfinity)
            
            XCTAssertEqual(publicKey.toAffine().coordinates.X, publicKeyNative.toAffine().coordinates.X)
            XCTAssertEqual(publicKey.toAffine().coordinates.Y, publicKeyNative.toAffine().coordinates.Y)
            
        }
    }
}
