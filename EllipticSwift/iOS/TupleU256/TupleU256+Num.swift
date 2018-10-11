//
//  TupleU256+Num.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU256: Comparable {
    public static func < (lhs: TupleU256, rhs: TupleU256) -> Bool {
        for i in (0 ..< U256WordWidth).reversed() {
            if lhs[i] < rhs[i] {
                return true
            } else if lhs[i] > rhs[i] {
                return false
            }
        }
        return false
    }
    
    public static func == (lhs: TupleU256, rhs: TupleU256) -> Bool {
        for i in 0 ..< U256WordWidth {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
}

//extension TupleU256: FiniteFieldCompatible {
extension TupleU256 {
    public typealias Magnitude = TupleU256
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        return nil
    }
    
    public typealias IntegerLiteralType = UInt64
}


extension TupleU256: Numeric {
    public static func += (lhs: inout TupleU256, rhs: TupleU256) {
        lhs.inplaceAddMod(rhs)
    }
    
    public static func -= (lhs: inout TupleU256, rhs: TupleU256) {
        lhs.inplaceSubMod(rhs)
    }
    
    public static func + (lhs: TupleU256, rhs: TupleU256) -> TupleU256 {
        return lhs.addMod(rhs)
    }
    
    public static func - (lhs: TupleU256, rhs: TupleU256) -> TupleU256 {
        return lhs.subMod(rhs)
    }
    
    public var magnitude: TupleU256 {
        return self
    }
    
    public static func * (lhs: TupleU256, rhs: TupleU256) -> TupleU256 {
        return lhs.halfMul(rhs)
    }
    
    public static func *= (lhs: inout TupleU256, rhs: TupleU256) {
        lhs.inplaceHalfMul(rhs)
    }
    
    public init(integerLiteral value: TupleU256.IntegerLiteralType) {
        self.init(value)
    }
}
