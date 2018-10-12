//
//  FixedWidthTuples.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public struct TupleU256 {
    var storage: (UInt64, UInt64, UInt64, UInt64)
    
    public init() {
        self.storage = (0,0,0,0)
    }
    
    public init(_ a: TupleU256) {
        self.storage = (a.storage.0,a.storage.1,a.storage.2,a.storage.3)
    }
    
    public init(_ a: UInt64) {
        self.storage = (a,0,0,0)
    }
    
    public init(_ a: (UInt64, UInt64, UInt64, UInt64)) {
        self.storage = a
    }
}

extension TupleU256 {
    subscript (_ i: Int) -> UInt64 {
        get {
            if i >= U256WordWidth {
                return 0
            }
            var copy = self.storage
            let res: UInt64 = withUnsafeBytes(of: &copy) { (rawPtr: UnsafeRawBufferPointer) -> UInt64 in
//            let res: UInt64 = withUnsafeBytes(of: &self.storage) { (rawPtr: UnsafeRawBufferPointer) -> UInt64 in
                let bufPtr = UnsafeBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: UInt64.self),
                    count: 4)
                return bufPtr[i]
            }
            return res
        }
        set(newValue) {
            if i >= U256WordWidth {
                return
            }
            withUnsafeMutableBytes(of: &self.storage) { (rawPtr: UnsafeMutableRawBufferPointer) -> Void in
                let bufPtr = UnsafeMutableBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: UInt64.self),
                    count: 4)
                bufPtr[i] = newValue
            }
        }
    }
}
