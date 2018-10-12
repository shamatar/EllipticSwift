//
//  TupleU512+Mul.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 12/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU512 {
    
    public func fullMul(_ a: TupleU512) -> TupleU512 {
        var opResult = TupleU512()
        var aCopy = a
        for i in 0 ..< U512WordWidth {
            var carry = UInt64(0) // carry is like a "double word carry"
            let (b_top, b_bottom) = splitUInt64(aCopy[i])
            
            for j in 0 ..< U512WordWidth {
                if self[j] != 0 || carry != 0 {
                    let a = splitUInt64(self[j])
                    let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, opResult[i+j])
                    
                    let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                    
                    opResult[i+j]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                    
                    var res = (c_top >> 32) + (of_top << 32);
                    var o1 = false
                    var o2 = false
                    (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                    (opResult[i + j + 1], o2) = res.addingReportingOverflow(opResult[i + j + 1])
                    if o1 || o2 {
                        carry = 1
                    } else {
                        carry = 0
                    }
                }
            }
        }
        return opResult
    }
    
    public func halfMul(_ a: TupleU512) -> TupleU512 {
        var opResult = TupleU512()
        var aCopy = a
        for i in 0 ..< U512WordWidth {
            var carry = UInt64(0) // carry is like a "double word carry"
            let (b_top, b_bottom) = splitUInt64(aCopy[i])
            
            for j in 0 ..< U512WordWidth - i {
                if self[j] != 0 || carry != 0 {
                    let a = splitUInt64(self[j])
                    let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, opResult[i+j])
                    let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                    opResult[i+j]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                    // assemble higher U64
                    var res = (c_top >> 32) + (of_top << 32);
                    var o1 = false
                    var o2 = false
                    (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                    if i + j + 1 < U512WordWidth {
                        (opResult[i + j + 1], o2) = res.addingReportingOverflow(opResult[i + j + 1])
                    }
                    if o1 || o2 {
                        carry = 1
                    } else {
                        carry = 0
                    }
                }
            }
        }
        return opResult
    }
    
    public mutating func inplaceHalfMul(_ a: TupleU512) {
        var tempStorage = TupleU512()
        var aCopy = a
        for i in 0 ..< U512WordWidth {
            var carry = UInt64(0) // carry is like a "double word carry"
            let (b_top, b_bottom) = splitUInt64(aCopy[i])
            
            for j in 0 ..< U512WordWidth - i {
                if self[j] != 0 || carry != 0 {
                    let a = splitUInt64(self[j])
                    let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, tempStorage[i+j])
                    let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                    tempStorage[i+j]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                    // assemble higher U64
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
        self.storage = tempStorage.storage
    }
    
    @inline(__always) mutating func inplaceMultiply(byWord: UInt64, shiftedBy: Int = 0) -> UInt64 {
        if byWord == 0 {
            for i in 0 ..< U512WordWidth {
                self[i] = 0
            }
            return 0
        } else if byWord == 1 {
            if shiftedBy == 0 {
                return 0
            }
        }
        var mulResult = TupleU576()
        var carry = UInt64(0) // carry is like a "double word carry"
        let (b_top, b_bottom) = splitUInt64(byWord)
        for j in 0 ..< (U512WordWidth - shiftedBy) {
            if self[j] != 0 || carry != 0 {
                let a = splitUInt64(self[j])
                let m = j + shiftedBy
                let (of_bottom, c_bottom) = mixedMulAdd(a, b_bottom, mulResult[m])
                let (of_top, c_top) = mixedMulAdd(a, b_top, c_bottom >> 32)
                mulResult[m]  = (c_bottom & maskLowerBits) &+ (c_top << 32);
                var res = (c_top >> 32) + (of_top << 32);
                var o1 = false
                var o2 = false
                (res, o1) = res.addingReportingOverflow(of_bottom &+ carry)
                (mulResult[m + 1], o2) = res.addingReportingOverflow(mulResult[m + 1])
                if o1 || o2 {
                    carry = 1
                } else {
                    carry = 0
                }
            }
        }
        if carry != 0 {
            precondition(false)
            mulResult[U512WordWidth] = mulResult[U512WordWidth] + 1
        }
        self.storage = (mulResult.storage.0, mulResult.storage.1, mulResult.storage.2, mulResult.storage.3, mulResult.storage.4, mulResult.storage.5, mulResult.storage.6, mulResult.storage.7)
        let retval = mulResult[U512WordWidth]
        return retval
    }
    
}
