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

let U256ByteLength = 32
let U256WordWidth = 4

public final class NativeU256 {
   
    // store as limbs with lower bits in [0]
    internal var storage = UnsafeMutableRawPointer.allocate(byteCount: U256ByteLength, alignment: 64)
    
    public init(_ value: UInt64) {
        let typedStorage = storage.initializeMemory(as: UInt64.self, repeating: 0, count: U256WordWidth)
        typedStorage[0] = value
    }
    
    public init() {
        storage.initializeMemory(as: UInt64.self, repeating: 0, count: U256WordWidth)
    }
    
    public init(_ value: NativeU256) {
        self.storage.copyMemory(from: value.storage, byteCount: U256ByteLength)
    }
    
    internal init(_ storage: UnsafeMutableRawPointer) {
        self.storage.copyMemory(from: storage, byteCount: U256ByteLength)
    }
    
    internal init(_ storage: UnsafeMutablePointer<UInt32>) {
        self.storage.copyMemory(from: UnsafeMutableRawPointer(storage), byteCount: U256ByteLength)
    }
    
    internal init(_ storage: UnsafeMutablePointer<UInt64>) {
        self.storage.copyMemory(from: UnsafeMutableRawPointer(storage), byteCount: U256ByteLength)
    }
    
    internal init(_ storage: UnsafeMutablePointer<UInt64>, shiftedBy: Int) {
        self.storage.copyMemory(from: UnsafeMutableRawPointer(storage).advanced(by: shiftedBy * 8), byteCount: U256ByteLength - shiftedBy * 8)
    }
    
    internal init(_ storage: UnsafeMutableRawPointer, shiftedBy: Int) {
        self.storage.copyMemory(from: storage.advanced(by: shiftedBy * 8), byteCount: U256ByteLength - shiftedBy * 8)
    }
    
    // this is highly buggy on 32-bit arch, only for testing here
    public init(_ a: BigUInt) {
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        var max = a.words.count
        if max > U256WordWidth {
            max = U256WordWidth
        }
        for i in 0 ..< max {
            typedStorage[i] = UInt64(a.words[i])
        }
    }
    
    deinit {
//        self.storage.deallocate()
    }
    
}

extension NativeU256 {

//    public func addMod(_ a: NativeU256) -> NativeU256 {
//        let addResult = NativeU256()
//        let tempStorage = addResult.storage.assumingMemoryBound(to: UInt32.self)
//        let typedStorage = self.storage.assumingMemoryBound(to: UInt32.self)
//        let otherStorage = a.storage.assumingMemoryBound(to: UInt32.self)
//        var carry = UInt64(0)
//        for i in 0 ..< U256WordWidth*2 {
//            let result = UInt64(typedStorage[i]) &+ UInt64(otherStorage[i]) &+ carry
//            carry = result >> 32
//            tempStorage[i] = UInt32(result & maskLowerBits)
//        }
//        return addResult
//    }
    
    public func addMod(_ a: NativeU256) -> NativeU256 {
        let addResult = NativeU256()
        let tempStorage = addResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        var OF = false
        for i in 0 ..< U256WordWidth {
            var (result, newOF) = typedStorage[i].addingReportingOverflow(otherStorage[i])
            if OF {
                result = result &+ 1
            }
            tempStorage[i] = result
            OF = newOF
        }
        return addResult
    }
    
    public func subMod(_ a: NativeU256) -> NativeU256 {
        let addResult = NativeU256()
        let tempStorage = addResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        var OF = false
        for i in 0 ..< U256WordWidth {
            var (result, newOF) = typedStorage[i].subtractingReportingOverflow(otherStorage[i])
            if OF {
                result = result &- 1
            }
            tempStorage[i] = result
            OF = newOF
        }
        return addResult
    }
    
    public func inplaceAddMod(_ a: NativeU256) {
        let addResult = NativeU256()
        let tempStorage = addResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        var OF = false
        for i in 0 ..< U256WordWidth {
            var (result, newOF) = typedStorage[i].addingReportingOverflow(otherStorage[i])
            if OF {
                result = result &+ 1
            }
            tempStorage[i] = result
            OF = newOF
        }
        self.storage.copyMemory(from: addResult.storage, byteCount: U256ByteLength)
    }
    
    public func inplaceSubMod(_ a: NativeU256) {
        let addResult = NativeU256()
        let tempStorage = addResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        var OF = false
        for i in 0 ..< U256WordWidth {
            var (result, newOF) = typedStorage[i].subtractingReportingOverflow(otherStorage[i])
            if OF {
                result = result &- 1
            }
            tempStorage[i] = result
            OF = newOF
        }
        self.storage.copyMemory(from: addResult.storage, byteCount: U256ByteLength)
    }
    
    public func fullMul(_ a: NativeU256) -> NativeU512 {
        let mulResult = NativeU512()
        let tempStorage = mulResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U256WordWidth {
            var carry = UInt64(0) // carry is like a "double word carry"
            let (b_top, b_bottom) = splitUInt64(otherStorage[i])
            
            for j in 0 ..< U256WordWidth {
                if typedStorage[j] != 0 || carry != 0 {
                    let a = splitUInt64(typedStorage[j])
                    // do a FMA like operation adding the existing storage
                    // in tempStorage[i+j] we expect existing data
                    // first param is what we multiply split as top and bottom half-words
                    // second param is half-word multiplier
                    let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, tempStorage[i+j])
                    // structure is         of_bottom|c_bottom_0|c_bottom_1
                    //               of_top| c_top_0 | c_top_1
                    //                  res[i+j+1]   |      res[i+j]
                    
                    let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)

                    // we have already added top 32 bits of c_bottom in a line above
                    tempStorage[i+j]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                    // assemble higher U64
                    var res = (c_top >> 32) + (of_top << 32);
                    var o1 = false
                    var o2 = false
                    (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                    (tempStorage[i + j + 1], o2) = res.addingReportingOverflow(tempStorage[i + j + 1])
                    if o1 || o2 {
                        carry = 1
                    } else {
                        carry = 0
                    }
                }
            }
        }
        return mulResult
    }
    
    public func halfMul(_ a: NativeU256) -> NativeU256 {
        let mulResult = NativeU256()
        let tempStorage = mulResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U256WordWidth {
            var carry = UInt64(0) // carry is like a "double word carry"
            let (b_top, b_bottom) = splitUInt64(otherStorage[i])
            
            for j in 0 ..< U256WordWidth - i {
                if typedStorage[j] != 0 || carry != 0 {
                    let a = splitUInt64(typedStorage[j])
                    // do a FMA like operation adding the existing storage
                    // in tempStorage[i+j] we expect existing data
                    // first param is what we multiply split as top and bottom half-words
                    // second param is half-word multiplier
                    let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, tempStorage[i+j])
                    // structure is         of_bottom|c_bottom_0|c_bottom_1
                    //               of_top| c_top_0 | c_top_1
                    //                  res[i+j+1]   |      res[i+j]
                    
                    let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                    
                    // we have already added top 32 bits of c_bottom in a line above
                    tempStorage[i+j]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                    // assemble higher U64
                    var res = (c_top >> 32) + (of_top << 32);
                    var o1 = false
                    var o2 = false
                    (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                    if i + j + 1 < U256WordWidth {
                        (tempStorage[i + j + 1], o2) = res.addingReportingOverflow(tempStorage[i + j + 1])
                    }
                    if o1 || o2 {
                        carry = 1
                    } else {
                        carry = 0
                    }
                }
            }
        }
        return mulResult
    }
    
    public func inplaceHalfMul(_ a: NativeU256) {
        let mulResult = NativeU256()
        let tempStorage = mulResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U256WordWidth {
            var carry = UInt64(0) // carry is like a "double word carry"
            let (b_top, b_bottom) = splitUInt64(otherStorage[i])
            
            for j in 0 ..< U256WordWidth - i {
                if typedStorage[j] != 0 || carry != 0 {
                    let a = splitUInt64(typedStorage[j])
                    // do a FMA like operation adding the existing storage
                    // in tempStorage[i+j] we expect existing data
                    // first param is what we multiply split as top and bottom half-words
                    // second param is half-word multiplier
                    let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, tempStorage[i+j])
                    // structure is         of_bottom|c_bottom_0|c_bottom_1
                    //               of_top| c_top_0 | c_top_1
                    //                  res[i+j+1]   |      res[i+j]
                    
                    let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                    
                    // we have already added top 32 bits of c_bottom in a line above
                    tempStorage[i+j]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                    // assemble higher U64
                    var res = (c_top >> 32) + (of_top << 32);
                    var o1 = false
                    var o2 = false
                    (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                    if i + j + 1 < U256WordWidth {
                        (tempStorage[i + j + 1], o2) = res.addingReportingOverflow(tempStorage[i + j + 1])
                    }
                    if o1 || o2 {
                        carry = 1
                    } else {
                        carry = 0
                    }
                }
            }
        }
        self.storage.copyMemory(from: mulResult.storage, byteCount: U256ByteLength)
    }
    
    func inplaceMultiply(byWord: UInt64) {
        let mulResult = NativeU256()
        let tempStorage = mulResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        var carry = UInt64(0) // carry is like a "double word carry"
        let (b_top, b_bottom) = splitUInt64(byWord)
        for j in 0 ..< U256WordWidth {
            if typedStorage[j] != 0 || carry != 0 {
                let a = splitUInt64(typedStorage[j])
                let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, tempStorage[j])
                let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                tempStorage[j]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                var res = (c_top >> 32) + (of_top << 32);
                var o1 = false
                var o2 = false
                (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                if j + 1 < U256WordWidth {
                    (tempStorage[j + 1], o2) = res.addingReportingOverflow(tempStorage[j + 1])
                }
                if o1 || o2 {
                    carry = 1
                } else {
                    carry = 0
                }
            }
        }
        self.storage.copyMemory(from: mulResult.storage, byteCount: U256ByteLength)
    }
    
    @inline(__always) internal func divide(byWord y: UInt64) -> UInt64 {
        precondition(y > 0)
        if y == 1 { return 0 }
        
        var remainder: UInt64 = 0
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U256WordWidth).reversed() {
            let u = typedStorage[i]
            (typedStorage[i], remainder) = fastDividingFullWidth((remainder, u), y)
        }
        return remainder
    }
    
    @inline(__always) internal func quotientAndRemainder(dividingByWord y: UInt64) -> (quotient: NativeU256, remainder: UInt64) {
        let div = self
        let mod = div.divide(byWord: y)
        return (div, mod)
    }
    
    public func divide(by b: NativeU256) -> (NativeU256, NativeU256) {
        precondition(!b.isZero)
        
        let x = NativeU256(self)
        
        // First, let's take care of the easy cases.
        if x < b {
            return (NativeU256(), x)
        }
        
        let y = NativeU256(b)
        let quotient = NativeU256()
        let dc = y.wordCount
        let xWordCount = x.wordCount
        if dc >= 2 && xWordCount >= 3 {
            let d1 = y[dc - 1]
            let d0 = y[dc - 2]
            let product = NativeU256()
            for j in (dc ... xWordCount).reversed() {

                let r2 = x[j]
                let r1 = x[j - 1]
                let r0 = x[j - 2]
                let q = approximateQuotient(dividing: (r2, r1, r0), by: (d1, d0))
                product.storage.copyMemory(from: y.storage, byteCount: U256ByteLength)
                product.inplaceMultiply(byWord: q)
                let partial = x.extract(j - dc ..< j + 1)
                if product <= partial {
                    x.inplaceSubMod(NativeU256(product.storage, shiftedBy: j - dc))
                    quotient[j - dc] = q
                }
                else {
                    precondition(false)
                    x.inplaceAddMod(NativeU256(y.storage, shiftedBy: j - dc))
                    x.inplaceSubMod(NativeU256(product.storage, shiftedBy: j - dc))
                    quotient[j - dc] = q - 1
                }
            }
        } else {
            precondition(false)
        }
        return (quotient, x)
    }
}

extension NativeU256: CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.words.debugDescription
    }
    
    public var words: [UInt64] {
        var res = [UInt64](repeating: 0, count: U256WordWidth)
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U256WordWidth {
            res[i] = typedStorage[i]
        }
        return res
    }
    
    public var bytes: Data {
        var res = Data()
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U256WordWidth).reversed() {
            res += typedStorage[i].bytes
        }
        return res
    }
    
    public var isZero: Bool {
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U256WordWidth {
            if typedStorage[i] != 0 {
                return false
            }
        }
        return true
    }
}

extension NativeU256: Comparable {
    public static func < (lhs: NativeU256, rhs: NativeU256) -> Bool {
        let typedStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        let otherTypedStorage = rhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U256WordWidth).reversed() {
            if typedStorage[i] < otherTypedStorage[i] {
                return true
            } else if typedStorage[i] > otherTypedStorage[i] {
                return false
            }
        }
        return false
    }
    
    public static func == (lhs: NativeU256, rhs: NativeU256) -> Bool {
        let typedStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        let otherTypedStorage = rhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U256WordWidth {
            if typedStorage[i] != otherTypedStorage[i] {
                return false
            }
        }
        return true
    }
}

extension NativeU256 {
    public var leadingZeroBitCount: Int {
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        if typedStorage[3] != 0 {
            return typedStorage[3].leadingZeroBitCount
        } else if typedStorage[2] != 0 {
            return typedStorage[2].leadingZeroBitCount + 64
        } else if typedStorage[1] != 0 {
            return typedStorage[0].leadingZeroBitCount + 128
        } else {
            return typedStorage[0].leadingZeroBitCount + 192
        }
    }
    
    public var wordCount: Int {
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        if typedStorage[3] != 0 {
            return 4
        } else if typedStorage[2] != 0 {
            return 3
        } else if typedStorage[1] != 0 {
            return 2
        } else if typedStorage[0] != 0 {
            return 1
        }
        return 0
    }
}

extension NativeU256 {
    subscript (_ i: Int) -> UInt64 {
        get {
            if i > 3 {
                return 0
            }
            let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
            return typedStorage[i]
        }
        set(newValue) {
            let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
            typedStorage[i] = newValue
        }
    }
}

extension NativeU256 {
    func extract(_ range: CountableRange<Int>) -> NativeU256 {
        let new = NativeU256()
        var bytesToCopy = 8 * range.distance(from: range.lowerBound, to: range.upperBound)
        if bytesToCopy > U256ByteLength {
            bytesToCopy = U256ByteLength
        }
        new.storage.copyMemory(from: self.storage.advanced(by: 8 * range.lowerBound), byteCount: bytesToCopy)
        return new
    }
}
