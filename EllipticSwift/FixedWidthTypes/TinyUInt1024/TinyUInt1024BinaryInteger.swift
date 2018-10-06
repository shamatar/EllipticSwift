//
//  TinyUInt1024BinaryInteger.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

extension TinyUInt1024 {
    public static var bitWidth: Int {
        return 1024
    }
}

/*
 * - Extension for conforming BinaryInteger and use / /= % %= for it
 */
extension TinyUInt1024: BinaryInteger {
    
    public var words: [UInt] {
        get {
            if self == TinyUInt1024.min {
                return [0]
            }
            
            var arrayOfWords: [UInt] = []
            
            for word in 0...self.bitWidth/UInt.bitWidth {
                let shift = TinyUInt512(UInt.bitWidth)*TinyUInt512(word)
                let mask = TinyUInt512(UInt.max)
                var wordWithShift = self
                
                if shift > 0 {
                    wordWithShift &>>= TinyUInt1024(firstHalf: 0, secondHalf: shift)
                }
                
                let wordWithMask = wordWithShift & TinyUInt1024(firstHalf: 0, secondHalf: mask)
                
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
        
        for bit in 0...1024 {
            if shift & TinyUInt1024(1) == 1 {
                return bit
            }
            shift >>= 1
        }
        
        return 1024
    }
    
    // MARK: Methods
    public static func /(lhs: TinyUInt1024, rhs: TinyUInt1024) -> TinyUInt1024 {
        let result = lhs.dividedReportingOverflow(by: rhs)
        
        return result.partialValue
    }
    
    public static func /=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        lhs = lhs / rhs
    }
    
    public static func %(lhs: TinyUInt1024, rhs: TinyUInt1024) -> TinyUInt1024 {
        let result = lhs.remainderReportingOverflow(dividingBy: rhs)
        
        return result.partialValue
    }
    
    public static func %=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        lhs = lhs % rhs
    }
    
    // AND
    public static func &=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        let firstHalf = lhs.storage.firstHalf & rhs.storage.firstHalf
        let secondHalf = lhs.storage.secondHalf & rhs.storage.secondHalf
        
        lhs = TinyUInt1024(firstHalf: firstHalf, secondHalf: secondHalf)
    }
    
    // OR
    public static func |=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        let firstHalf = lhs.storage.firstHalf | rhs.storage.firstHalf
        let secondHalf = lhs.storage.secondHalf | rhs.storage.secondHalf
        
        lhs = TinyUInt1024(firstHalf: firstHalf, secondHalf: secondHalf)
    }
    
    // XOR
    public static func ^=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        let firstHalf = lhs.storage.firstHalf ^ rhs.storage.firstHalf
        let secondHalf = lhs.storage.secondHalf ^ rhs.storage.secondHalf
        
        lhs = TinyUInt1024(firstHalf: firstHalf, secondHalf: secondHalf)
    }
    
    
    // Masked right shift operation. 1024 -> 0, 257 -> 1
    public static func &>>=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        
        let shift = rhs.storage.secondHalf & 1023
        
        switch shift {
        case 0:
            return
        case 1...511:
            let firstHalf = lhs.storage.firstHalf >> shift
            let secondHalf = (lhs.storage.secondHalf >> shift) + (lhs.storage.firstHalf << (512 - shift))
            lhs = TinyUInt1024(firstHalf: firstHalf, secondHalf: secondHalf)
        case 512:
            // Move first bits to second
            lhs = TinyUInt1024(firstHalf: 0, secondHalf: lhs.storage.firstHalf)
        default:
            let secondHalf = lhs.storage.firstHalf >> (shift - 512)
            lhs = TinyUInt1024(firstHalf: 0, secondHalf: secondHalf)
        }
    }
    
    /// Masked left shift operation. 1024 -> 0, 257 -> 1
    public static func &<<=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        
        let shift = rhs.storage.secondHalf & 511
        
        switch shift {
        case 0:
            return // Do nothing shift
        case 1...511:
            let firstHalf = (lhs.storage.firstHalf << shift) + (lhs.storage.secondHalf >> (512 - shift))
            let secondHalf = lhs.storage.secondHalf << shift
            lhs = TinyUInt1024(firstHalf: firstHalf, secondHalf: secondHalf)
        case 512:
            // Move second bits to first
            lhs = TinyUInt1024(firstHalf: lhs.storage.secondHalf, secondHalf: 0)
        default:
            let firstHalf = lhs.storage.secondHalf << (shift - 512)
            lhs = TinyUInt1024(firstHalf: firstHalf, secondHalf: 0)
        }
    }
}





















