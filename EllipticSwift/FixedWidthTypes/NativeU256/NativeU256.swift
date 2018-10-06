//
//  NativeU256.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 06/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

// this implementation is purely little endian

import Foundation
import BigInt

public class NativeU256 {
   
    // store as limbs with lower bits in [0]
    internal var storage = UnsafeMutableRawPointer.allocate(byteCount: 32, alignment: 64)
    
    public init(_ value: UInt64) {
        let typedStorage = storage.initializeMemory(as: UInt64.self, repeating: 0, count: 4)
        typedStorage[0] = value
    }
    
    public init() {
        storage.initializeMemory(as: UInt64.self, repeating: 0, count: 4)
    }
    
    public init(_ value: NativeU256) {
        self.storage.copyMemory(from: value.storage, byteCount: 32)
    }
    
    internal init(_ storage: UnsafeMutableRawPointer) {
        self.storage.copyMemory(from: storage, byteCount: 32)
    }
    
    internal init(_ storage: UnsafeMutablePointer<UInt32>) {
        self.storage.copyMemory(from: UnsafeMutableRawPointer(storage), byteCount: 32)
    }
    
    internal init(_ storage: UnsafeMutablePointer<UInt64>) {
        self.storage.copyMemory(from: UnsafeMutableRawPointer(storage), byteCount: 32)
    }
    
    // this is highly buggy on 32-bit arch, only for testing here
    public init(_ a: BigUInt) {
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        var max = a.words.count
        if max > 4 {
            max = 4
        }
        for i in 0 ..< max {
            typedStorage[i] = UInt64(a.words[i])
        }
    }
    
    deinit {
        self.storage.deallocate()
    }
}

extension NativeU256 {
    public func addMod(_ a: NativeU256) -> NativeU256 {
        let tempStorage = UnsafeMutableRawPointer.allocate(byteCount: 40, alignment: 64).assumingMemoryBound(to: UInt32.self)
        defer {
            tempStorage.deallocate()
        }
        
        let typedStorage = self.storage.assumingMemoryBound(to: UInt32.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt32.self)
        var carry = UInt64(0)
        let maskLowerBits = UInt64(0xffffffff)
        let maskHigherBits = maskLowerBits << 32
        for i in 0 ..< 8 {
            let result = UInt64(typedStorage[i]) + UInt64(otherStorage[i]) + carry
            carry = (result & maskHigherBits) >> 32
            tempStorage[i] = UInt32(result & maskLowerBits)
        }
        let result = NativeU256(tempStorage)
        return result
    }
    
    public func addMod64(_ a: NativeU256) -> NativeU256 {
        let tempStorage = UnsafeMutableRawPointer.allocate(byteCount: 40, alignment: 64).assumingMemoryBound(to: UInt64.self)
        defer {
            tempStorage.deallocate()
        }
        
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        var OF = false
        for i in 0 ..< 4 {
            var (result, newOF) = typedStorage[i].addingReportingOverflow(otherStorage[i])
            if OF {
                result = result + 1
            }
            tempStorage[i] = result
            OF = newOF
        }
        let result = NativeU256(tempStorage)
        return result
    }
}

extension NativeU256: CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.words.debugDescription
    }
    
    public var words: [UInt64] {
        var res = [UInt64](repeating: 0, count: 4)
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< 4 {
            res[i] = typedStorage[i]
        }
        return res
    }
    
    public var bytes: Data {
        var res = Data()
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< 4).reversed() {
            res += typedStorage[i].bytes
        }
        return res
    }
}
