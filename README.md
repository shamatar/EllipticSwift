# EllipticSwift

## Installation

Add the following line to your Podfile

```
  pod 'EllipticSwift', '~> 2.0'
```

## Example

```
		let curve = secp256k1Curve
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = curve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        // this is basically a private key - large random scalar
        let randomScalar = BigUInt.randomInteger(lessThan: 256)
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
```

## Limitations

- Point multiplication is not yet constant type
- Protocols are quite suboptimal, global cleanups will happen
- No support of pairings yet
- U512 type is not polyfilled
- No Montgomery support on iOS (should work, but untested)
- Only Weierstrass curves for now