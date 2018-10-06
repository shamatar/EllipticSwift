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
    
    func testU256Subtraction() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(lessThan: ar)
        let a = NativeU256(ar)
        let b = NativeU256(br)
        let c = b.subMod64(a)
        let mod = BigUInt(1) << 256
        let cr = br + mod - ar
        print(cr.serialize().bytes)
        print(c.bytes.bytes)
    }
    
    func testU256Multiplication() {
        for _ in 0 ..< 10 {
            let ar = BigUInt.randomInteger(withMaximumWidth: 256)
            let br = BigUInt.randomInteger(withMaximumWidth: 256)
            let a = NativeU256(ar)
            let b = NativeU256(br)
            let c = a.fullMul(b)
            let cr = ar * br
            for i in 0 ..< 8 {
                XCTAssert(c.words[i] == cr.words[i])
            }
        }
    }
    
    func testU256Multiplication2() {
        let ar = BigUInt(UInt64.max)
        let br = BigUInt(UInt64.max)
        let a = NativeU256(UInt64.max)
        let b = NativeU256(UInt64.max)
        let c = a.fullMul(b)
        let cr = ar * br
        print(c.words)
        print(cr.words)
        XCTAssert(c.words[0] == cr.words[0])
        XCTAssert(c.words[1] == cr.words[1])
    }
    
    func testU256Multiplication3() {
        let a = NativeU256(UInt64(16))
        let b = NativeU256(UInt64(16))
        let c = a.fullMul(b)
        XCTAssert(c.words[0] == 256)
    }
    
    func testU256MultiplicationPerf() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = NativeU256(ar)
        let b = NativeU256(br)
        measure {
            let _ = a.fullMul(b)
        }
    }
    
    func testMultiplicationPerf() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        measure {
            let _ = ar * br
        }
    }
    
    func testU256Division() {
        for _ in 0 ..< 10 {
            let ar = BigUInt.randomInteger(withMaximumWidth: 256)
            let br = BigUInt.randomInteger(lessThan: ar)
            let a = NativeU256(ar)
            let b = NativeU256(br)
            let (q, r) = a.divide(by: b)
            let (qq, rr) = ar.quotientAndRemainder(dividingBy: br)
            for i in 0 ..< 4 {
                XCTAssert(q.words[i] == qq.words[i])
                XCTAssert(r.words[i] == rr.words[i])
            }
        }
    }
    
    func testU256Division2() {
        for _ in 0 ..< 10 {
            let ar = BigUInt.randomInteger(withMaximumWidth: 256)
            let br = BigUInt.randomInteger(withMaximumWidth: 256)
            let a = NativeU256(ar)
            let b = NativeU256(br)
            let (q, r) = a.divide(by: b)
            let (qq, rr) = ar.quotientAndRemainder(dividingBy: br)
            for i in 0 ..< 4 {
                XCTAssert(q.words[i] == qq.words[i])
                XCTAssert(r.words[i] == rr.words[i])
            }
        }
    }
    
    func testU256DivisionByWord() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt(1234)
        let a = NativeU256(ar)
        let r = a.divide(byWord: 1234)
        let (qq, rr) = ar.quotientAndRemainder(dividingBy: br)
        for i in 0 ..< 4 {
            XCTAssert(a.words[i] == qq.words[i])
        }
        XCTAssert(r == rr.words[0])
    }
    
    func testDivisionPerf() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(lessThan: ar)
        measure {
            let _ = ar.quotientAndRemainder(dividingBy: br)
        }
    }
    
    func testDivisionPerfU256() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(lessThan: ar)
        let a = NativeU256(ar)
        let b = NativeU256(br)
        measure {
            let _ = a.divide(by: b)
        }
    }
}
