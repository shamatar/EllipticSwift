//
//  EllipticSwiftTests_Performance.swift
//  EllipticSwiftTests_Performance
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import EllipticSwift
import BigInt

class EllipticSwiftTests_Performance: XCTestCase {

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
        let a = U256(ar.serialize())!
        let b = U256(br.serialize())!
        measure {
            let _ = a.addMod(b)
        }
    }
    
    func testAdditionPerformance3() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = TupleU256(ar.serialize())!
        let b = TupleU256(br.serialize())!
        measure {
            let _ = a.addMod(b)
        }
    }
    
    func testMultiplicationPerformance0(){
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        measure {
            let _ = ar * br
        }
    }
    
    func testMultiplicationPerformance1() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = NativeU256(ar)
        let b = NativeU256(br)
        measure {
            let _ = a.fullMul(b)
        }
    }
    
    func testMultiplicationPerformance2() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = U256(ar.serialize())!
        let b = U256(br.serialize())!
        measure {
            let _ = a.fullMul(b)
        }
    }
    
    func testDivisionPerformance0(){
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        measure {
            let _ = ar.quotientAndRemainder(dividingBy: br)
        }
    }
    
    func testDivisionPerformance1() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = NativeU256(ar)
        let b = NativeU256(br)
        measure {
            let _ = a.div(b)
        }
    }
    
    func testDivisionPerformance2() {
        let ar = BigUInt.randomInteger(withMaximumWidth: 256)
        let br = BigUInt.randomInteger(withMaximumWidth: 256)
        let a = U256(ar.serialize())!
        let b = U256(br.serialize())!
        measure {
            let _ = a.div(b)
        }
    }

}
