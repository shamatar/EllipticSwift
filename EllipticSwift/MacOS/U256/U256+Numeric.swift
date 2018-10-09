//
//  U256+Numeric.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU256: Numeric {
    public typealias IntegerLiteralType = UInt64
    
    public init(integerLiteral: vU256.IntegerLiteralType) {
        let top = integerLiteral >> 32
        let bot = integerLiteral & 0xffffffff
        let u256 = vU256(v: (vUInt32(x: UInt32(bot), y: UInt32(top), z: 0, w: 0), vZERO))
        self = u256
    }
    
    
    public typealias Magnitude = vU256
    public var magnitude: vU256 {
        return self
    }
    
    public init?<T>(exactly: T) {
        return nil
    }
    public static var bitWidth: Int = U256BitLength
    public static var max: vU256 = vU256MAX
    public static var min: vU256 = vU256MIN
    
    
    public static func * (lhs: vU256, rhs: vU256) -> vU256 {
        let (_, bottom) = lhs.fullMultiply(rhs)
        return bottom
    }
    
    public static func *= (lhs: inout vU256, rhs: vU256) {
        lhs.inplaceHalfMul(rhs)
    }
    
    public static func + (lhs: vU256, rhs: vU256) -> vU256 {
        return lhs.addMod(rhs)
    }
    
    public static func += (lhs: inout vU256, rhs: vU256) {
        lhs.inplaceAddMod(rhs)
    }
    
    public static func - (lhs: vU256, rhs: vU256) -> vU256 {
        return lhs.subMod(rhs)
    }
    
    public static func -= (lhs: inout vU256, rhs: vU256) {
        lhs.inplaceSubMod(rhs)
    }
}
