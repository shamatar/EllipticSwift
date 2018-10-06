//
//  EllipticSwiftNativeUIntsTests.swift
//  EllipticSwiftTests
//
//  Created by Alex Vlasov on 06/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt

@testable import EllipticSwift

class EllipticSwiftNativeUIntsTests: XCTestCase {

    func testU256Addition() {
        let a = NativeU256(UInt64.max)
        let b = NativeU256(UInt64.max)
        let c = a.addMod(b)
        XCTAssert(c.words[0] == UInt64.max - 1)
        XCTAssert(c.words[1] == 1)
    }
    
    func testU256Addition2() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = NativeU256(ar)
        let b = NativeU256(br)
        let c = a.addMod(b)
        let mod = BigUInt(1) << 256
        let cr = (ar + br) % mod
        print(cr.serialize().bytes)
        print(c.bytes.bytes)
    }
    
    func testU256Addition3() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = NativeU256(ar)
        let b = NativeU256(br)
        let _ = a.addMod(b)
    }

    func testAdditionPerformance0(){
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        measure {
            let _ = ar + br
        }
    }
    
    func testAdditionPerformance1() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = NativeU256(ar)
        let b = NativeU256(br)
        measure {
            let _ = a.addMod(b)
        }
    }
    
    func testAdditionPerformance2() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = NativeU256(ar)
        let b = NativeU256(br)
        measure {
            let _ = a.addMod64(b)
        }
    }
}
