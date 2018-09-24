//
//  U256+BitOps.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256: BitShiftable {
    public func leftShifted(_ a: UInt32) -> U256 {
        var result = U256()
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafeMutablePointer(to: &result, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                vLL256Shift(selfPtr, a, resultPtr)
            })
        }
        return result
    }
    
    public mutating func inplaceLeftShifted(_ a: UInt32) {
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafeMutablePointer(to: &self, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                vLL256Shift(selfPtr, a, resultPtr)
            })
        }
    }
    
    public func rightShifted(_ a: UInt32) -> U256 {
        var result = U256()
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafeMutablePointer(to: &result, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                vLR256Shift(selfPtr, a, resultPtr)
            })
        }
        return result
    }
    
    public mutating func inplaceRightShifted(_ a: UInt32) {
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafeMutablePointer(to: &self, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                vLR256Shift(selfPtr, a, resultPtr)
            })
        }
    }
    
    public static func >> (lhs: U256, rhs: UInt32) -> U256 {
        return lhs.rightShifted(rhs)
    }
    
    public static func << (lhs: U256, rhs: UInt32) -> U256 {
        return lhs.leftShifted(rhs)
    }
    
}
