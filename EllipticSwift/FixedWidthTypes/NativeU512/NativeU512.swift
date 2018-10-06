//
//  NativeU512.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 06/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

// this implementation is purely little endian

import Foundation
import BigInt

private let U512ByteLength = 64
private let U512WordWidth = 8

public class NativeU512 {
    
    // store as limbs with lower bits in [0]
    internal var storage = UnsafeMutableRawPointer.allocate(byteCount: U512ByteLength, alignment: 64)
    
    public init(_ value: UInt64) {
        let typedStorage = storage.initializeMemory(as: UInt64.self, repeating: 0, count: U512WordWidth)
        typedStorage[0] = value
    }
    
    public init() {
        storage.initializeMemory(as: UInt64.self, repeating: 0, count: U512WordWidth)
    }
    
    public init(_ value: NativeU512) {
        self.storage.copyMemory(from: value.storage, byteCount: U512ByteLength)
    }
    
    internal init(_ storage: UnsafeMutableRawPointer) {
        self.storage.copyMemory(from: storage, byteCount: U512ByteLength)
    }
    
    internal init(_ storage: UnsafeMutablePointer<UInt32>) {
        self.storage.copyMemory(from: UnsafeMutableRawPointer(storage), byteCount: U512ByteLength)
    }
    
    internal init(_ storage: UnsafeMutablePointer<UInt64>) {
        self.storage.copyMemory(from: UnsafeMutableRawPointer(storage), byteCount: U512ByteLength)
    }
    
    // this is highly buggy on 32-bit arch, only for testing here
    public init(_ a: BigUInt) {
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        var max = a.words.count
        if max > U512WordWidth {
            max = U512WordWidth
        }
        for i in 0 ..< max {
            typedStorage[i] = UInt64(a.words[i])
        }
    }
    
    deinit {
        self.storage.deallocate()
    }
}

extension NativeU512 {
    
    public func addMod(_ a: NativeU512) -> NativeU512 {
        let addResult = NativeU512()
        let tempStorage = addResult.storage.assumingMemoryBound(to: UInt32.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt32.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt32.self)
        var carry = UInt64(0)
        let maskLowerBits = UInt64(0xffffffff)
        let maskHigherBits = maskLowerBits << 32
        for i in 0 ..< U512WordWidth*2 {
            let result = UInt64(typedStorage[i]) &+ UInt64(otherStorage[i]) &+ carry
            carry = (result & maskHigherBits) >> 32
            tempStorage[i] = UInt32(result & maskLowerBits)
        }
        return addResult
    }
    
    public func addMod64(_ a: NativeU512) -> NativeU512 {
        let addResult = NativeU512()
        let tempStorage = addResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        var OF = false
        for i in 0 ..< U512WordWidth {
            var (result, newOF) = typedStorage[i].addingReportingOverflow(otherStorage[i])
            if OF {
                result = result &+ 1
            }
            tempStorage[i] = result
            OF = newOF
        }
        return addResult
    }
    
    public func subMod64(_ a: NativeU512) -> NativeU512 {
        let addResult = NativeU512()
        let tempStorage = addResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        var OF = false
        for i in 0 ..< U512WordWidth {
            var (result, newOF) = typedStorage[i].subtractingReportingOverflow(otherStorage[i])
            if OF {
                result = result &- 1
            }
            tempStorage[i] = result
            OF = newOF
        }
        return addResult
    }
}

extension NativeU512: CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.words.debugDescription
    }
    
    public var words: [UInt64] {
        var res = [UInt64](repeating: 0, count: U512WordWidth)
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U512WordWidth {
            res[i] = typedStorage[i]
        }
        return res
    }
    
    public var bytes: Data {
        var res = Data()
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U512WordWidth).reversed() {
            res += typedStorage[i].bytes
        }
        return res
    }
}

extension NativeU512 {
    public func split() -> (NativeU256, NativeU256) {
        let top = NativeU256(self.storage.advanced(by: 4))
        let bottom = NativeU256(self.storage)
        return (top, bottom)
    }
}
