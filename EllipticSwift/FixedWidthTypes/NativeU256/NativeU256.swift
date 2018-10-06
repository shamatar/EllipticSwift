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

private let U256ByteLength = 32
private let U256WordWidth = 4

public class NativeU256 {
   
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

    public func addMod(_ a: NativeU256) -> NativeU256 {
        let addResult = NativeU256()
        let tempStorage = addResult.storage.assumingMemoryBound(to: UInt32.self)
        let typedStorage = self.storage.assumingMemoryBound(to: UInt32.self)
        let otherStorage = a.storage.assumingMemoryBound(to: UInt32.self)
        var carry = UInt64(0)
        for i in 0 ..< U256WordWidth*2 {
            let result = UInt64(typedStorage[i]) &+ UInt64(otherStorage[i]) &+ carry
            carry = result >> 32
            tempStorage[i] = UInt32(result & maskLowerBits)
        }
        return addResult
    }
    
    public func addMod64(_ a: NativeU256) -> NativeU256 {
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
    
    func inplaceAddMod(_ a: NativeU256) {
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
        self.storage = addResult.storage
    }
    
    public func subMod64(_ a: NativeU256) -> NativeU256 {
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
        self.storage = addResult.storage
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
        self.storage = mulResult.storage
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
        self.storage = mulResult.storage
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
        // This is a Swift adaptation of "divmnu" from Hacker's Delight, which is in
        // turn a C adaptation of Knuth's Algorithm D (TAOCP vol 2, 4.3.1).
        
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


private let maskLowerBits = UInt64(0xffffffff)
private let maskHigherBits = maskLowerBits << 32

@inline(__always) func splitUInt64(_ a: UInt64) -> (UInt64, UInt64) {
    let top = a >> 32
    let bottom = a & maskLowerBits
    return (top, bottom)
}

// expects a to have 32 bit width and together form a 64 bit limb
// expects b to actually have 32 bits
//
@inline(__always) func mixedMulAdd(_ a: (UInt64, UInt64), _ b: UInt64, _ c: UInt64) -> (UInt64, UInt64) {
    let l0 = a.1 * b
    let l1 = a.0 * b
    var bottom = UInt64(0)
    var of = false
    var ofAfterMixedAdd = false
    var top = (l1 >> 32)
    (bottom, ofAfterMixedAdd) = l0.addingReportingOverflow(c)
    if ofAfterMixedAdd {
        top = top &+ 1
    }
    (bottom, of) = bottom.addingReportingOverflow(l1 << 32)
    if of {
        top = top &+ 1
    }
    return (top, bottom)
}

extension UInt64 {
    var halfShift: UInt64 {
        return UInt64(UInt64.bitWidth / 2)
        
    }
    var high: UInt64 {
        return self >> 32
    }
    
    var low: UInt64 {
        return self & maskLowerBits
    }
    
    var upshifted: UInt64 {
        return self << 32
    }
    
    var split: (high: UInt64, low: UInt64) {
        return (self.high, self.low)
    }
    
    init(_ value: (high: UInt64, low: UInt64)) {
        self = value.high.upshifted + value.low
    }
}

@inline(__always) func quotient(dividing u: (high: UInt64, low: UInt64), by vn: UInt64) -> UInt64 {
    let (vn1, vn0) = vn.split
    // Get approximate quotient.
    let (q, r) = u.high.quotientAndRemainder(dividingBy: vn1)
    let p = q * vn0
    // q is often already correct, but sometimes the approximation overshoots by at most 2.
    // The code that follows checks for this while being careful to only perform single-digit operations.
    if q.high == 0 && p <= r.upshifted + u.low { return q }
    let r2 = r + vn1
    if r2.high != 0 { return q - 1 }
    if (q - 1).high == 0 && p - vn0 <= r2.upshifted + u.low { return q - 1 }
    //assert((r + 2 * vn1).high != 0 || p - 2 * vn0 <= (r + 2 * vn1).upshifted + u.low)
    return q - 2
}

@inline(__always) func quotientAndRemainder(dividing u: (high: UInt64, low: UInt64), by v: UInt64) -> (quotient: UInt64, remainder: UInt64) {
    let q = quotient(dividing: u, by: v)
    let r = UInt64(u) &- q &* v
    assert(r < v)
    return (q, r)
}

@inline(__always) func fastDividingFullWidth(_ dividend: (high: UInt64, low: UInt64), _ divisor: UInt64) -> (quotient: UInt64, remainder: UInt64) {
    precondition(dividend.high < divisor)
    
    // Normalize the dividend and the divisor (self) such that the divisor has no leading zeroes.
    let z = UInt64(divisor.leadingZeroBitCount)
    let w = UInt64(divisor.bitWidth) - z
    let vn = divisor << z
    
    let un32 = (z == 0 ? dividend.high : (dividend.high &<< z) | (dividend.low &>> w)) // No bits are lost
    let un10 = dividend.low &<< z
    let (un1, un0) = un10.split
    
    // Divide `(un32,un10)` by `vn`, splitting the full 4/2 division into two 3/2 ones.
    let (q1, un21) = quotientAndRemainder(dividing: (un32, un1), by: vn)
    let (q0, rn) = quotientAndRemainder(dividing: (un21, un0), by: vn)
    
    // Undo normalization of the remainder and combine the two halves of the quotient.
    let mod = rn >> z
    let div = UInt64((q1, q0))
    return (div, mod)
}

@inline(__always) func approximateQuotient(dividing x: (UInt64, UInt64, UInt64), by y: (UInt64, UInt64)) -> UInt64 {
    // Start with q = (x.0, x.1) / y.0, (or Word.max on overflow)
    var q: UInt64
    var r: UInt64
    if x.0 == y.0 {
        q = UInt64.max
        let (s, o) = x.0.addingReportingOverflow(x.1)
        if o { return q }
        r = s
    }
    else {
        (q, r) = fastDividingFullWidth((x.0, x.1), y.0)
    }
    // Now refine q by considering x.2 and y.1.
    // Note that since y is normalized, q * y - x is between 0 and 2.
    let (ph, pl) = q.multipliedFullWidth(by: y.1)
    if ph < r || (ph == r && pl <= x.2) { return q }
    
    let (r1, ro) = r.addingReportingOverflow(y.0)
    if ro { return q - 1 }
    
    let (pl1, so) = pl.subtractingReportingOverflow(y.1)
    let ph1 = (so ? ph - 1 : ph)
    
    if ph1 < r1 || (ph1 == r1 && pl1 <= x.2) { return q - 1 }
    return q - 2
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
