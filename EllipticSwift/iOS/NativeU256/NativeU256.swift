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
        for i in max ..< U256WordWidth {
             typedStorage[i] = 0
        }
    }
    
    deinit {
        self.storage.deallocate()
    }
    
}

extension NativeU256 {
    
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
    
    @inline(__always) func inplaceMultiply(byWord: UInt64, shiftedBy: Int = 0) -> UInt64 {
        if byWord == 0 {
            let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
            for i in 0 ..< U256WordWidth {
                typedStorage[i] = 0
            }
            return 0
        } else if byWord == 1 {
            if shiftedBy == 0 {
                return 0
            }
        }
        let mulResult = UnsafeMutableRawPointer.allocate(byteCount: U256ByteLength + 8, alignment: 64)
        defer {
            mulResult.deallocate()
        }
        mulResult.initializeMemory(as: UInt64.self, repeating: 0, count: 5)
        let tempStorage = mulResult.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        var carry = UInt64(0) // carry is like a "double word carry"
        let (b_top, b_bottom) = splitUInt64(byWord)
        for j in 0 ..< (U256WordWidth - shiftedBy) {
            if typedStorage[j] != 0 || carry != 0 {
                let a = splitUInt64(typedStorage[j])
                let m = j + shiftedBy
                let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, tempStorage[m])
                let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                tempStorage[m]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                var res = (c_top >> 32) + (of_top << 32);
                var o1 = false
                var o2 = false
                (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                (tempStorage[m + 1], o2) = res.addingReportingOverflow(tempStorage[m + 1])
                if o1 || o2 {
                    carry = 1
                } else {
                    carry = 0
                }
            }
        }
        if carry != 0 {
            precondition(false)
            tempStorage[U256WordWidth] = tempStorage[U256WordWidth] + 1
        }
        self.storage.copyMemory(from: mulResult, byteCount: U256ByteLength)
        let retval = tempStorage[U256WordWidth]
        return retval
    }
    
    @inline(__always) internal func inplaceDivide(byWord y: UInt64) -> UInt64 {
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
        let div = NativeU256(self)
        let mod = div.inplaceDivide(byWord: y)
        return (div, mod)
    }
    
    public func divide(by b: NativeU256) -> (NativeU256, NativeU256) {
        precondition(!b.isZero)
        
        var x = NativeU256(self)
        
        // First, let's take care of the easy cases.
        if x < b {
            return (NativeU256(), x)
        }
        let dc = b.wordCount
        if dc == 1 {
            let (q, r) = self.quotientAndRemainder(dividingByWord: b[0])
            return (q, NativeU256(r))
        }

        var y = NativeU256(b)
        let leadingZeroes = UInt32(y[dc - 1].leadingZeroBitCount)
        let quotient = NativeU256()
        let xWordCount = x.wordCount
        var xTopBits = x[U256WordWidth - 1] >> (64 - leadingZeroes)
        x <<= leadingZeroes
        y <<= leadingZeroes
        let d1 = y[dc - 1]
        let d0 = y[dc - 2]
        let product = NativeU256()
        for j in (dc ... xWordCount).reversed() {
            let m = j - dc
            // pad with 0 highest word
            var r2 = x[j]
            if j == U256WordWidth {
                r2 = xTopBits
            }
            let r1 = x[j - 1]
            let r0 = x[j - 2]
            // we have properly reduced the highest word
            let q = approximateQuotient(dividing: (r2, r1, r0), by: (d1, d0))
            product.storage.copyMemory(from: y.storage, byteCount: U256ByteLength)
            let of = product.inplaceMultiply(byWord: q, shiftedBy: m)
            if j == xWordCount {
                if xTopBits > of {
                    // product is definatelly less than x
                    xTopBits = xTopBits - of
                    x.inplaceSubMod(NativeU256(product.storage))
                    quotient[m] = q
                } else if xTopBits == of {
                    // extended word bits are equal
                    xTopBits = 0
                    if product <= x {
                        x.inplaceSubMod(NativeU256(product.storage))
                        quotient[m] = q
                    } else {
                        x.inplaceAddMod(NativeU256(y.storage))
                        x.inplaceSubMod(NativeU256(product.storage))
                        quotient[m] = q - 1
                    }
                } else {
                    // we need to virtually borrow due to q being overshoot
                    x.inplaceAddMod(NativeU256(y.storage))
                    x.inplaceSubMod(NativeU256(product.storage))
                    quotient[m] = q - 1
                }
            } else if product <= x {
                x.inplaceSubMod(NativeU256(product.storage))
                quotient[m] = q
            } else {
                x.inplaceAddMod(NativeU256(y.storage))
                x.inplaceSubMod(NativeU256(product.storage))
                quotient[m] = q - 1
            }
        }
        x >>= leadingZeroes
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
            if i >= U256WordWidth {
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

extension NativeU256 {
    func toBigUInt() -> BigUInt {

        var words = [BigUInt.Word]()
        for i in 0 ..< U256WordWidth {
            words.append(BigUInt.Word(self[i]))
        }
        let b = BigUInt.init(words: words)
        return b
    }
}
