//
//  TinyUInt512BinaryInteger.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

extension TinyUInt512 {
    public static var bitWidth: Int {
        return 512
    }
}

/*
 * - Extension for conforming BinaryInteger and use / /= % %= for it
 */
extension TinyUInt512: BinaryInteger {
    
    public var words: [UInt] {
        get {
            if self == TinyUInt512.min {
                return [0]
            }
            
            var arrayOfWords: [UInt] = []
            
            for word in 0...self.bitWidth/UInt.bitWidth {
                let shift = TinyUInt256(UInt.bitWidth)*TinyUInt256(word)
                let mask = TinyUInt256(UInt.max)
                var wordWithShift = self
                
                if shift > 0 {
                    wordWithShift &>>= TinyUInt512(firstHalf: 0, secondHalf: shift)
                }
                
                let wordWithMask = wordWithShift & TinyUInt512(firstHalf: 0, secondHalf: mask)
                
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
        
        for bit in 0...512 {
            if shift & TinyUInt512(1) == 1 {
                return bit
            }
            shift >>= 1
        }
        
        return 512
    }
    
    // MARK: Methods
    public static func /(lhs: TinyUInt512, rhs: TinyUInt512) -> TinyUInt512 {
        let result = lhs.dividedReportingOverflow(by: rhs)
        
        return result.partialValue
    }
    
    public static func /=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        lhs = lhs / rhs
    }
    
    public static func %(lhs: TinyUInt512, rhs: TinyUInt512) -> TinyUInt512 {
        let result = lhs.remainderReportingOverflow(dividingBy: rhs)
        
        return result.partialValue
    }
    
    public static func %=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        lhs = lhs % rhs
    }
    
    // AND
    public static func &=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        let firstHalf = lhs.storage.firstHalf & rhs.storage.firstHalf
        let secondHalf = lhs.storage.secondHalf & rhs.storage.secondHalf
        
        lhs = TinyUInt512(firstHalf: firstHalf, secondHalf: secondHalf)
    }
    
    // OR
    public static func |=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        let firstHalf = lhs.storage.firstHalf | rhs.storage.firstHalf
        let secondHalf = lhs.storage.secondHalf | rhs.storage.secondHalf
        
        lhs = TinyUInt512(firstHalf: firstHalf, secondHalf: secondHalf)
    }
    
    // XOR
    public static func ^=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        let firstHalf = lhs.storage.firstHalf ^ rhs.storage.firstHalf
        let secondHalf = lhs.storage.secondHalf ^ rhs.storage.secondHalf
        
        lhs = TinyUInt512(firstHalf: firstHalf, secondHalf: secondHalf)
    }
    
    
    // Masked right shift operation. 512 -> 0, 257 -> 1
    public static func &>>=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        
        let shift = rhs.storage.secondHalf & 511
        
        switch shift {
        case 0:
            return
        case 1...255:
            let firstHalf = lhs.storage.firstHalf >> shift
            let secondHalf = (lhs.storage.secondHalf >> shift) + (lhs.storage.firstHalf << (256 - shift))
            lhs = TinyUInt512(firstHalf: firstHalf, secondHalf: secondHalf)
        case 256:
            // Move first bits to second
            lhs = TinyUInt512(firstHalf: 0, secondHalf: lhs.storage.firstHalf)
        default:
            let secondHalf = lhs.storage.firstHalf >> (shift - 256)
            lhs = TinyUInt512(firstHalf: 0, secondHalf: secondHalf)
        }
    }
    
    /// Masked left shift operation. 512 -> 0, 257 -> 1
    public static func &<<=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        
        let shift = rhs.storage.secondHalf & 255
        
        switch shift {
        case 0:
            return // Do nothing shift
        case 1...255:
            let firstHalf = (lhs.storage.firstHalf << shift) + (lhs.storage.secondHalf >> (256 - shift))
            let secondHalf = lhs.storage.secondHalf << shift
            lhs = TinyUInt512(firstHalf: firstHalf, secondHalf: secondHalf)
        case 256:
            // Move second bits to first
            lhs = TinyUInt512(firstHalf: lhs.storage.secondHalf, secondHalf: 0)
        default:
            let firstHalf = lhs.storage.secondHalf << (shift - 256)
            lhs = TinyUInt512(firstHalf: firstHalf, secondHalf: 0)
        }
    }
}
