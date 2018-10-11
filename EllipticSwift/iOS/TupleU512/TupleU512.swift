//
//  TupleU512.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public struct TupleU512 {
    var storage: (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64)
    
    public init() {
        self.storage = (0,0,0,0,0,0,0,0)
    }
    
    public init(_ a: TupleU512) {
        self.storage = (a.storage.0,a.storage.1,a.storage.2,a.storage.3,
                        a.storage.4,a.storage.5,a.storage.6,a.storage.7)
    }
    
    public init(_ a: UInt64) {
        self.storage = (a,0,0,0,0,0,0,0)
    }
    
    public init(_ value: (top: TupleU256, bottom: TupleU256)) {
        self.storage = (value.bottom.storage.0, value.bottom.storage.1, value.bottom.storage.2, value.bottom.storage.3,
                        value.top.storage.0, value.top.storage.1, value.top.storage.2, value.top.storage.3)
    }
}

extension TupleU512 {
    subscript (_ i: Int) -> UInt64 {
        get {
            if i >= U512WordWidth {
                return 0
            }
            var copy = self.storage
            let res: UInt64 = withUnsafeBytes(of: &copy) { (rawPtr: UnsafeRawBufferPointer) -> UInt64 in
                //            let res: UInt64 = withUnsafeBytes(of: &self.storage) { (rawPtr: UnsafeRawBufferPointer) -> UInt64 in
                let bufPtr = UnsafeBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: UInt64.self),
                    count: 8)
                return bufPtr[i]
            }
            return res
        }
        set(newValue) {
            if i >= U512WordWidth {
                return
            }
            withUnsafeMutableBytes(of: &self.storage) { (rawPtr: UnsafeMutableRawBufferPointer) -> Void in
                let bufPtr = UnsafeMutableBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: UInt64.self),
                    count: 8)
                bufPtr[i] = newValue
            }
        }
    }
}
