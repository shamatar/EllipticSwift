//
//  TinyUInt256BinaryInteger.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

extension TinyUInt256 {
    public static var bitWidth: Int {
        return 256
    }
}

/*
 * - Extension for conforming BinaryInteger and use / /= % %= for it
 */
extension TinyUInt256: BinaryInteger {
    
    public var words: [UInt] {
        get {
            if self == TinyUInt256.min {
                return [0]
            }
            
            var arrayOfWords: [UInt] = []
            
            for word in 0...self.bitWidth/UInt.bitWidth {
                let shift = TinyUInt128(UInt.bitWidth)*TinyUInt128(word)
                let mask = TinyUInt128(UInt.max)
                var wordWithShift = self
                
                if shift > 0 {
                    wordWithShift &>>= TinyUInt256(firstHalf: 0, secondHalf: shift)
                }
                
                let wordWithMask = wordWithShift & TinyUInt256(firstHalf: 0, secondHalf: mask)
                
                arrayOfWords.append(UInt(wordWithMask.storage.secondHalf))
            }
            
            return arrayOfWords
        } 
    }
    
    public static var isSigned: Bool {
        return false
    }
    
    public var trailingZeroBitCount: Int {
        
        var shift = self
        
        for bit in 0...256 {
            if shift & TinyUInt256(1) == 1 {
                return bit
            }
            shift >>= 1
        }
        
        return 256
    }
    
    // MARK: Methods
    public static func /(lhs: TinyUInt256, rhs: TinyUInt256) -> TinyUInt256 {
        let result = lhs.dividedReportingOverflow(by: rhs)
        
        return result.partialValue
    }
    
    public static func /=(lhs: inout TinyUInt256, rhs: TinyUInt256) {
        lhs = lhs / rhs
    }
    
    public static func %(lhs: TinyUInt256, rhs: TinyUInt256) -> TinyUInt256 {
        let result = lhs.remainderReportingOverflow(dividingBy: rhs)
        
        return result.partialValue
    }
    
    public static func %=(lhs: inout TinyUInt256, rhs: TinyUInt256) {
        lhs = lhs % rhs
    }
    
    // AND
    public static func &=(lhs: inout TinyUInt256, rhs: TinyUInt256) {
        let firstHalf = lhs.storage.firstHalf & rhs.storage.firstHalf
        let secondHalf = lhs.storage.secondHalf & rhs.storage.secondHalf
        
        lhs = TinyUInt256(firstHalf: firstHalf, secondHalf: secondHalf)
    }
    
    // OR
    public static func |=(lhs: inout TinyUInt256, rhs: TinyUInt256) {
        let firstHalf = lhs.storage.firstHalf | rhs.storage.firstHalf
        let secondHalf = lhs.storage.secondHalf | rhs.storage.secondHalf
        
        lhs = TinyUInt256(firstHalf: firstHalf, secondHalf: secondHalf)
    }
    
    // XOR
    public static func ^=(lhs: inout TinyUInt256, rhs: TinyUInt256) {
        let firstHalf = lhs.storage.firstHalf ^ rhs.storage.firstHalf
        let secondHalf = lhs.storage.secondHalf ^ rhs.storage.secondHalf
        
        lhs = TinyUInt256(firstHalf: firstHalf, secondHalf: secondHalf)
    }
    
    
    // Masked right shift operation. 256 -> 0, 257 -> 1
    public static func &>>=(lhs: inout TinyUInt256, rhs: TinyUInt256) {
        
        let shift = rhs.storage.secondHalf & 255
        
        switch shift {
        case 0:
            return
        case 1...127:
            let firstHalf = lhs.storage.firstHalf >> shift
            let secondHalf = (lhs.storage.secondHalf >> shift) + (lhs.storage.firstHalf << (128 - shift))
            lhs = TinyUInt256(firstHalf: firstHalf, secondHalf: secondHalf)
        case 128:
            // Move first bits to second
            lhs = TinyUInt256(firstHalf: 0, secondHalf: lhs.storage.firstHalf)
        default:
            let secondHalf = lhs.storage.firstHalf >> (shift - 128)
            lhs = TinyUInt256(firstHalf: 0, secondHalf: secondHalf)
        }
    }
    
    /// Masked left shift operation. 256 -> 0, 257 -> 1
    public static func &<<=(lhs: inout TinyUInt256, rhs: TinyUInt256) {
        
        let shift = rhs.storage.secondHalf & 255
        
        switch shift {
        case 0:
            return // Do nothing shift
        case 1...127:
            let firstHalf = (lhs.storage.firstHalf << shift) + (lhs.storage.secondHalf >> (128 - shift))
            let secondHalf = lhs.storage.secondHalf << shift
            lhs = TinyUInt256(firstHalf: firstHalf, secondHalf: secondHalf)
        case 128:
            // Move second bits to first
            lhs = TinyUInt256(firstHalf: lhs.storage.secondHalf, secondHalf: 0)
        default:
            let firstHalf = lhs.storage.secondHalf << (shift - 128)
            lhs = TinyUInt256(firstHalf: firstHalf, secondHalf: 0)
        }
    }
}
