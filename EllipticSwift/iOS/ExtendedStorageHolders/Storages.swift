//
//  Storages.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

fileprivate let words320 = 5
fileprivate let words576 = 5

struct TupleU320 {
    var storage: (UInt64, UInt64, UInt64, UInt64, UInt64)
    
    public init() {
        self.storage = (0,0,0,0,0)
    }
    
    subscript (_ i: Int) -> UInt64 {
        get {
            if i >= words320 {
                return 0
            }
            var copy = self.storage
            let res: UInt64 = withUnsafeBytes(of: &copy) { (rawPtr: UnsafeRawBufferPointer) -> UInt64 in
                //            let res: UInt64 = withUnsafeBytes(of: &self.storage) { (rawPtr: UnsafeRawBufferPointer) -> UInt64 in
                let bufPtr = UnsafeBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: UInt64.self),
                    count: words320)
                return bufPtr[i]
            }
            return res
        }
        set(newValue) {
            if i >= words320 {
                return
            }
            withUnsafeMutableBytes(of: &self.storage) { (rawPtr: UnsafeMutableRawBufferPointer) -> Void in
                let bufPtr = UnsafeMutableBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: UInt64.self),
                    count: words320)
                bufPtr[i] = newValue
            }
        }
    }
}

struct TupleU576 {
    var storage: (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64)
    
    public init() {
        self.storage = (0,0,0,0,0,0,0,0,0)
    }
    
    subscript (_ i: Int) -> UInt64 {
        get {
            if i >= words576 {
                return 0
            }
            var copy = self.storage
            let res: UInt64 = withUnsafeBytes(of: &copy) { (rawPtr: UnsafeRawBufferPointer) -> UInt64 in
                //            let res: UInt64 = withUnsafeBytes(of: &self.storage) { (rawPtr: UnsafeRawBufferPointer) -> UInt64 in
                let bufPtr = UnsafeBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: UInt64.self),
                    count: words576)
                return bufPtr[i]
            }
            return res
        }
        set(newValue) {
            if i >= words576 {
                return
            }
            withUnsafeMutableBytes(of: &self.storage) { (rawPtr: UnsafeMutableRawBufferPointer) -> Void in
                let bufPtr = UnsafeMutableBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: UInt64.self),
                    count: words576)
                bufPtr[i] = newValue
            }
        }
    }
}
