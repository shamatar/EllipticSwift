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

public final class NativeU512 {
    
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
    
    public init(_ value: (top: NativeU256, bottom: NativeU256)) {
        self.storage.copyMemory(from: value.bottom.storage, byteCount: U256ByteLength)
        self.storage.advanced(by: U256ByteLength).copyMemory(from: value.top.storage, byteCount: U256ByteLength)
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
    
    internal init(_ storage: UnsafeMutablePointer<UInt64>, shiftedBy: Int) {
        self.storage.copyMemory(from: UnsafeMutableRawPointer(storage).advanced(by: shiftedBy * 8), byteCount: U512ByteLength - shiftedBy * 8)
    }
    
    internal init(_ storage: UnsafeMutableRawPointer, shiftedBy: Int) {
        self.storage.copyMemory(from: storage.advanced(by: shiftedBy * 8), byteCount: U512ByteLength - shiftedBy * 8)
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
        for i in max ..< U512WordWidth {
            typedStorage[i] = 0
        }
    }
    
    deinit {
        self.storage.deallocate()
    }
}

extension NativeU512 {
    
    public func addMod(_ a: NativeU512) -> NativeU512 {
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
    
    public func subMod(_ a: NativeU512) -> NativeU512 {
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
    
    public func inplaceAddMod(_ a: NativeU512) {
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
        self.storage.copyMemory(from: addResult.storage, byteCount: U512ByteLength)
    }
    
    public func inplaceSubMod(_ a: NativeU512) {
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
        self.storage.copyMemory(from: addResult.storage, byteCount: U512ByteLength)
    }
    
    public func fullMul(_ a: NativeU512) -> NativeU512 {
        let mulResult = NativeU512()
        let tempStorage = mulResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U512WordWidth {
            var carry = UInt64(0) // carry is like a "double word carry"
            let (b_top, b_bottom) = splitUInt64(otherStorage[i])
            
            for j in 0 ..< U512WordWidth {
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
    
    public func halfMul(_ a: NativeU512) -> NativeU512 {
        let mulResult = NativeU512()
        let tempStorage = mulResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U512WordWidth {
            var carry = UInt64(0) // carry is like a "double word carry"
            let (b_top, b_bottom) = splitUInt64(otherStorage[i])
            
            for j in 0 ..< U512WordWidth - i {
                if typedStorage[j] != 0 || carry != 0 {
                    let a = splitUInt64(typedStorage[j])
                    let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, tempStorage[i+j])
                    let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                    
                    tempStorage[i+j]  = (c_bottom & maskLowerBits) &+ (c_top << 32);

                    var res = (c_top >> 32) + (of_top << 32);
                    var o1 = false
                    var o2 = false
                    (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                    if i + j + 1 < U512WordWidth {
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
    
    public func inplaceHalfMul(_ a: NativeU512) {
        let mulResult = NativeU512()
        let tempStorage = mulResult.storage.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U512WordWidth {
            var carry = UInt64(0) // carry is like a "double word carry"
            let (b_top, b_bottom) = splitUInt64(otherStorage[i])
            
            for j in 0 ..< U512WordWidth - i {
                if typedStorage[j] != 0 || carry != 0 {
                    let a = splitUInt64(typedStorage[j])
                    let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, tempStorage[i+j])
                    let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                    tempStorage[i+j]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                    var res = (c_top >> 32) + (of_top << 32);
                    var o1 = false
                    var o2 = false
                    (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                    if i + j + 1 < U512WordWidth {
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
        self.storage.copyMemory(from: mulResult.storage, byteCount: U512ByteLength)
    }
    
    @inline(__always) func inplaceMultiply(byWord: UInt64, shiftedBy: Int = 0) -> UInt64 {
        if byWord == 0 {
            let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
            for i in 0 ..< U512WordWidth {
                typedStorage[i] = 0
            }
            return 0
        } else if byWord == 1 {
            if shiftedBy == 0 {
                return 0
            }
        }
        let mulResult = UnsafeMutableRawPointer.allocate(byteCount: U512ByteLength + 8, alignment: 64)
        defer {
            mulResult.deallocate()
        }
        mulResult.initializeMemory(as: UInt64.self, repeating: 0, count: U512WordWidth + 1)
        let tempStorage = mulResult.assumingMemoryBound(to: UInt64.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        var carry = UInt64(0) // carry is like a "double word carry"
        let (b_top, b_bottom) = splitUInt64(byWord)
        for j in 0 ..< (U512WordWidth - shiftedBy) {
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
            tempStorage[U512WordWidth] = tempStorage[U512WordWidth] + 1
        }
        self.storage.copyMemory(from: mulResult, byteCount: U512ByteLength)
        let retval = tempStorage[U512WordWidth]
        return retval
    }
    
    @inline(__always) internal func inplaceDivide(byWord y: UInt64) -> UInt64 {
        precondition(y > 0)
        if y == 1 { return 0 }
        
        var remainder: UInt64 = 0
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U512WordWidth).reversed() {
            let u = typedStorage[i]
            (typedStorage[i], remainder) = fastDividingFullWidth((remainder, u), y)
        }
        return remainder
    }
    
    @inline(__always) internal func quotientAndRemainder(dividingByWord y: UInt64) -> (quotient: NativeU512, remainder: UInt64) {
        let div = NativeU512(self)
        let mod = div.inplaceDivide(byWord: y)
        return (div, mod)
    }
    
    public func divide(by b: NativeU512) -> (NativeU512, NativeU512) {
        precondition(!b.isZero)
        
        var x = NativeU512(self)
        
        // First, let's take care of the easy cases.
        if x < b {
            return (NativeU512(), x)
        }
        let dc = b.wordCount
        if dc == 1 {
            let (q, r) = self.quotientAndRemainder(dividingByWord: b[0])
            return (q, NativeU512(r))
        }
        
        var y = NativeU512(b)
        let leadingZeroes = UInt32(y[dc - 1].leadingZeroBitCount)
        let quotient = NativeU512()
        let xWordCount = x.wordCount
        var xTopBits = x[U512WordWidth - 1] >> (64 - leadingZeroes)
        x <<= leadingZeroes
        y <<= leadingZeroes
        let d1 = y[dc - 1]
        let d0 = y[dc - 2]
        let product = NativeU512()
        for j in (dc ... xWordCount).reversed() {
            let m = j - dc
            // pad with 0 highest word
            var r2 = x[j]
            if j == U512WordWidth {
                r2 = xTopBits
            }
            let r1 = x[j - 1]
            let r0 = x[j - 2]
            // we have properly reduced the highest word
            let q = approximateQuotient(dividing: (r2, r1, r0), by: (d1, d0))
            product.storage.copyMemory(from: y.storage, byteCount: U512ByteLength)
            let of = product.inplaceMultiply(byWord: q, shiftedBy: m)
            if j == xWordCount {
                if xTopBits > of {
                    // product is definatelly less than x
                    xTopBits = xTopBits - of
                    x.inplaceSubMod(NativeU512(product.storage))
                    quotient[m] = q
                } else if xTopBits == of {
                    // extended word bits are equal
                    xTopBits = 0
                    if product <= x {
                        x.inplaceSubMod(NativeU512(product.storage))
                        quotient[m] = q
                    } else {
                        x.inplaceAddMod(NativeU512(y.storage))
                        x.inplaceSubMod(NativeU512(product.storage))
                        quotient[m] = q - 1
                    }
                } else {
                    // we need to virtually borrow due to q being overshoot
                    x.inplaceAddMod(NativeU512(y.storage))
                    x.inplaceSubMod(NativeU512(product.storage))
                    quotient[m] = q - 1
                }
            } else if product <= x {
                x.inplaceSubMod(NativeU512(product.storage))
                quotient[m] = q
            } else {
                x.inplaceAddMod(NativeU512(y.storage))
                x.inplaceSubMod(NativeU512(product.storage))
                quotient[m] = q - 1
            }
        }
        x >>= leadingZeroes
        return (quotient, x)
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
    
    public var isZero: Bool {
        let typedStorage = storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U512WordWidth {
            if typedStorage[i] != 0 {
                return false
            }
        }
        return true
    }
}

extension NativeU512 {
    public func split() -> (NativeU256, NativeU256) {
        let top = NativeU256(self.storage.advanced(by: 4))
        let bottom = NativeU256(self.storage)
        return (top, bottom)
    }
}

extension NativeU512: Comparable {
    public static func < (lhs: NativeU512, rhs: NativeU512) -> Bool {
        let typedStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        let otherTypedStorage = rhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U512WordWidth).reversed() {
            if typedStorage[i] < otherTypedStorage[i] {
                return true
            } else if typedStorage[i] > otherTypedStorage[i] {
                return false
            }
        }
        return false
    }
    
    public static func == (lhs: NativeU512, rhs: NativeU512) -> Bool {
        let typedStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        let otherTypedStorage = rhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< U512WordWidth {
            if typedStorage[i] != otherTypedStorage[i] {
                return false
            }
        }
        return true
    }
}

extension NativeU512 {
    public var leadingZeroBitCount: Int {
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        if typedStorage[7] != 0 {
            return typedStorage[7].leadingZeroBitCount
        } else if typedStorage[6] != 0 {
            return typedStorage[6].leadingZeroBitCount + 64
        } else if typedStorage[5] != 0 {
            return typedStorage[5].leadingZeroBitCount + 128
        } else if typedStorage[4] != 0 {
            return typedStorage[4].leadingZeroBitCount + 192
        } else if typedStorage[3] != 0 {
            return typedStorage[3].leadingZeroBitCount + 256
        } else if typedStorage[2] != 0 {
            return typedStorage[2].leadingZeroBitCount + 320
        } else if typedStorage[1] != 0 {
            return typedStorage[1].leadingZeroBitCount + 384
        } else {
            return typedStorage[0].leadingZeroBitCount + 448
        }
    }
    
    public var wordCount: Int {
        let typedStorage = self.storage.assumingMemoryBound(to: UInt64.self)
        if typedStorage[7] != 0 {
            return 8
        } else if typedStorage[6] != 0 {
            return 7
        } else if typedStorage[5] != 0 {
            return 6
        } else if typedStorage[4] != 0 {
            return 5
        } else if typedStorage[3] != 0 {
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

extension NativeU512 {
    subscript (_ i: Int) -> UInt64 {
        get {
            if i >= U512WordWidth {
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

extension NativeU512 {
    func extract(_ range: CountableRange<Int>) -> NativeU512 {
        let new = NativeU512()
        var bytesToCopy = 8 * range.distance(from: range.lowerBound, to: range.upperBound)
        if bytesToCopy > U512ByteLength {
            bytesToCopy = U512ByteLength
        }
        new.storage.copyMemory(from: self.storage.advanced(by: 8 * range.lowerBound), byteCount: bytesToCopy)
        return new
    }
}

extension NativeU512 {
    public func modInv(_ modulus: NativeU512) -> NativeU512 {
        var a = self
        let zero = NativeU512(UInt64(0))
        let one = NativeU512(UInt64(1))
        var new = one
        var old = zero
        var q = modulus
        var r = zero
        var h = zero
        var positive = false
        while !a.isZero {
            (q, r) = q.divide(by: a)
            h = q.halfMul(new).addMod(old)
            old = new
            new = h
            q = a
            a = r
            positive = !positive
        }
        if positive {
            return old
        } else {
            return modulus.subMod(old)
        }
    }
}

extension NativeU512: BitShiftable {
    public static func << (lhs: NativeU512, rhs: UInt32) -> NativeU512 {
        precondition(rhs <= 64)
        let new = NativeU512()
        let typedStorage = new.storage.assumingMemoryBound(to: UInt64.self)
        let originalStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (1 ..< U512WordWidth).reversed() {
            typedStorage[i] = (originalStorage[i] << rhs) | (originalStorage[i-1] >> (64 - rhs))
        }
        typedStorage[0] = originalStorage[0] << rhs
        return new
    }
    
    public static func <<= (lhs: inout NativeU512, rhs: UInt32) {
        precondition(rhs <= 64)
        let new = NativeU512()
        let typedStorage = new.storage.assumingMemoryBound(to: UInt64.self)
        let originalStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (1 ..< U512WordWidth).reversed() {
            typedStorage[i] = (originalStorage[i] << rhs) | (originalStorage[i-1] >> (64 - rhs))
        }
        typedStorage[0] = originalStorage[0] << rhs
        lhs.storage.copyMemory(from: new.storage, byteCount: U512ByteLength)
    }
    
    public static func >> (lhs: NativeU512, rhs: UInt32) -> NativeU512 {
        precondition(rhs <= 64)
        let new = NativeU512()
        let typedStorage = new.storage.assumingMemoryBound(to: UInt64.self)
        let originalStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U512WordWidth-1).reversed() {
            typedStorage[i] = (originalStorage[i] >> rhs) | (originalStorage[i+1] << (64 - rhs))
        }
        typedStorage[U512WordWidth-1] = originalStorage[U512WordWidth-1] >> rhs
        return new
    }
    
    public static func >>= (lhs: inout NativeU512, rhs: UInt32) {
        precondition(rhs <= 64)
        let new = NativeU512()
        let typedStorage = new.storage.assumingMemoryBound(to: UInt64.self)
        let originalStorage = lhs.storage.assumingMemoryBound(to: UInt64.self)
        for i in (0 ..< U512WordWidth-1).reversed() {
            typedStorage[i] = (originalStorage[i] >> rhs) | (originalStorage[i+1] << (64 - rhs))
        }
        typedStorage[U512WordWidth-1] = originalStorage[U512WordWidth-1] >> rhs
        lhs.storage.copyMemory(from: new.storage, byteCount: U512ByteLength)
    }
}
