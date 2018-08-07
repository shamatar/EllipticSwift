//
//  U256+Numeric.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256: Numeric {
    public typealias IntegerLiteralType = UInt64
    
    public init(integerLiteral: U256.IntegerLiteralType) {
        let top = integerLiteral >> 32
        let bot = integerLiteral & 0xffffffff
        let u256 = U256(v: (vUInt32(x: UInt32(bot), y: UInt32(top), z: 0, w: 0), vZERO))
        self = u256
    }
    
    
    public typealias Magnitude = U256
    public var magnitude: U256 {
        return self
    }
    
    public init?<T>(exactly: T) {
        return nil
    }
    public static var bitWidth: Int = U256bitLength
    public static var max: U256 = U256MAX
    public static var min: U256 = U256MIN
    
    
    public static func * (lhs: U256, rhs: U256) -> U256 {
        let (_, bottom) = lhs.fullMultiply(rhs)
        return bottom
    }
    
    public static func *= (lhs: inout U256, rhs: U256) {
        lhs.inplaceHalfMul(rhs)
    }
    
    public static func + (lhs: U256, rhs: U256) -> U256 {
        return lhs.addMod(rhs)
    }
    
    public static func += (lhs: inout U256, rhs: U256) {
        lhs.inplaceAddMod(rhs)
    }
    
    public static func - (lhs: U256, rhs: U256) -> U256 {
        return lhs.subMod(rhs)
    }
    
    public static func -= (lhs: inout U256, rhs: U256) {
        lhs.inplaceSubMod(rhs)
    }
}
