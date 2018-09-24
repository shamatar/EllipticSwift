//
//  DoubleAndAddMultiplication.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

internal func doubleAndAddExponentiation<T, U>(_ a: T, _ b: U) -> T where T: Arithmetics, T: UInt64Initializable, U: BitsAndBytes {
    var base = a
    var result = T.init(UInt64(1))
    let bitwidth = b.bitWidth
    for i in 0 ..< bitwidth {
        if b.bit(i) {
            result = result * base
        }
        if i == b.bitWidth - 1 {
            break
        }
        base = base * base
    }
    return result
}

//fileprivate typealias multiplicationFunction
//
//internal func doubleAndAddExponentiation<T, U>(_ a: T, _ b: U) -> T where T: Arithmetics, T: UInt64Initializable, U: BitsAndBytes {
//    var base = a
//    var result = T.init(UInt64(1))
//    let bitwidth = b.bitWidth
//    for i in 0 ..< bitwidth {
//        if b.bit(i) {
//            result = result * base
//        }
//        if i == b.bitWidth - 1 {
//            break
//        }
//        base = base * base
//    }
//    return result
//}


