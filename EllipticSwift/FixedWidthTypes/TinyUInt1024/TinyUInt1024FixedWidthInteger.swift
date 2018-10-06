//
//  TinyUIntFixedWidthInteger.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

import Darwin

/*
 * - Extension for conforming FixedWidthInteger, that contains Instanse methods of adding, subtracting, multiplying, dividing
 */
extension TinyUInt1024: FixedWidthInteger {
    
    public var nonzeroBitCount: Int {
        return storage.secondHalf.nonzeroBitCount + storage.firstHalf.nonzeroBitCount
    }
    
    public var leadingZeroBitCount: Int {
        
        if storage.firstHalf == 0 {
            return TinyUInt512.bitWidth + storage.secondHalf.leadingZeroBitCount
        } else {
            return storage.firstHalf.leadingZeroBitCount
        }
        
    }
    
    public var bigEndian: TinyUInt1024 {
        return self.byteSwapped
    }
    
    public var littleEndian: TinyUInt1024 {
        return self
    }
    
    public var byteSwapped: TinyUInt1024 {
        
        return TinyUInt1024(firstHalf: self.storage.secondHalf.byteSwapped,
                            secondHalf: self.storage.firstHalf.byteSwapped)
        
    }
    
    // MARK: - Initializers
    public init(_truncatingBits bits: UInt) {
        self.init(firstHalf: 0, secondHalf: TinyUInt512(bits))
    }
    
    public init(bigEndian storage: TinyUInt1024) {
        self = storage.bigEndian
    }
    
    public init(littleEndian storage: TinyUInt1024) {
        self = storage.littleEndian
    }
    
    // MARK: - Plus
    public func addingReportingOverflow(_ rhs: TinyUInt1024) -> (partialValue: TinyUInt1024, overflow: Bool) {
        
        var resultOverflow = false
        let (secondHalf, secondOverflow) = self.storage.secondHalf.addingReportingOverflow(rhs.storage.secondHalf)
        var (firstHalf, firstOverflow) = self.storage.firstHalf.addingReportingOverflow(rhs.storage.firstHalf)
        
        if secondOverflow {
            (firstHalf, resultOverflow) = firstHalf.addingReportingOverflow(1) // adding 1 to first if second overflowed
        }
        
        return (partialValue: TinyUInt1024(firstHalf: firstHalf, secondHalf: secondHalf),
                overflow: firstOverflow || resultOverflow)
        
    }
    
    // MARK: - Minus
    public func subtractingReportingOverflow(_ rhs: TinyUInt1024) -> (partialValue: TinyUInt1024, overflow: Bool) {
        
        var resultOverflow = false
        let (secondHalf, secondOverflow) = self.storage.secondHalf.subtractingReportingOverflow(rhs.storage.secondHalf)
        var (firstHalf, firstOverflow) = self.storage.firstHalf.subtractingReportingOverflow(rhs.storage.firstHalf)
        
        if secondOverflow {
            (firstHalf, resultOverflow) = firstHalf.subtractingReportingOverflow(1) // minus 1 from first if second overflowed
        }
        
        return (partialValue: TinyUInt1024(firstHalf: firstHalf, secondHalf: secondHalf),
                overflow: firstOverflow || resultOverflow)
    }
    
    // MARK: - Multiply
    public func multipliedReportingOverflow(by rhs: TinyUInt1024) -> (partialValue: TinyUInt1024, overflow: Bool) {
        
        let result = self.multipliedFullWidth(by: rhs)
        let overflowResult = result.high > 0
        
        return (partialValue: result.low,
                overflow: overflowResult)
    }
    
    public func multipliedFullWidth(by other: TinyUInt1024) -> (high: TinyUInt1024, low: TinyUInt1024.Magnitude) {
        
        let second256 = TinyUInt512(TinyUInt256.max) //mask second 256 bits of TinyUInt512
        
        // Get arrays of 4x 256bit TinyUInt512
        
        var result = [[TinyUInt512]](repeating: [TinyUInt512](repeating: 0, count: 4), count: 4)
        
        //          R0,R1,R2,R3
        //        * L0,L1,L2,L3
        //        ------------------------------------
        //        +                L3R0,L3R1,L3R2,L3R3
        //        +           L2R0,L2R1,L2R2,L2R3
        //        +      L1R0,L1R1,L1R2,L1R3
        //        + L0R0,L0R1,L0R2,L0R3
        //        ====================================
        //          BIT1,BIT2,BIT3,BIT4,BIT5,BIT6,BIT7
        //          (BIT1 [BIT2) BIT3 {BIT4] BIT5 (BIT6} BIT7)
        //        result: {(BIT1,BIT2) (BIT2,BIT3,BIT4)} {(BIT4,BIT5,BIT6) (BIT6,BIT7)}
        
        // L0,L1,L2,L3
        let lhsArray = [self.storage.firstHalf >> 256,
                        self.storage.firstHalf & second256,
                        self.storage.secondHalf >> 256,
                        self.storage.secondHalf & second256]
        
        // R0,R1,R2,R3
        let rhsArray = [other.storage.firstHalf >> 256,
                        other.storage.firstHalf & second256,
                        other.storage.secondHalf >> 256,
                        other.storage.secondHalf & second256]
        
        // Multiplication of every part: L0R0, L1R0, L2R0, ... , L3R3
        for rhsSegment in 0 ..< rhsArray.count {
            for lhsSegment in 0 ..< lhsArray.count {
                let currentValue = lhsArray[lhsSegment] * rhsArray[rhsSegment]
                result[lhsSegment][rhsSegment] = currentValue
            }
        }
        
        // addition like on scheme
        let bit7 = result[3][3] & second256
        let bit6 = TinyUInt1024.variadicAdditionWithOverflowCount(
            result[2][3] & second256,
            result[3][2] & second256,
            result[3][3] >> 256) // overflow from bit7
        let bit5 = TinyUInt1024.variadicAdditionWithOverflowCount(
            result[1][3] & second256,
            result[2][2] & second256,
            result[3][1] & second256,
            result[2][3] >> 256, // overflow from bit6
            result[3][2] >> 256, // overflow from bit6
            bit6.overflowCount)
        let bit4 = TinyUInt1024.variadicAdditionWithOverflowCount(
            result[0][3] & second256,
            result[1][2] & second256,
            result[2][1] & second256,
            result[3][0] & second256,
            result[1][3] >> 256, // overflow from bit5
            result[2][2] >> 256, // overflow from bit5
            result[3][1] >> 256, // overflow from bit5
            bit5.overflowCount)
        let bit3 = TinyUInt1024.variadicAdditionWithOverflowCount(
            result[0][2] & second256,
            result[1][1] & second256,
            result[2][0] & second256,
            result[0][3] >> 256, // overflow from bit4
            result[1][2] >> 256, // overflow from bit4
            result[2][1] >> 256, // overflow from bit4
            result[3][0] >> 256, // overflow from bit4
            bit4.overflowCount)
        let bit2 = TinyUInt1024.variadicAdditionWithOverflowCount(
            result[0][1] & second256,
            result[1][0] & second256,
            result[0][2] >> 256, // overflow from bit3
            result[1][1] >> 256, // overflow from bit3
            result[2][0] >> 256, // overflow from bit3
            bit3.overflowCount)
        let bit1 = TinyUInt1024.variadicAdditionWithOverflowCount(
            result[0][0],
            result[0][1] >> 256, // overflow from bit2
            result[1][0] >> 256, // overflow from bit2
            bit2.overflowCount)
        
        // 512 bit
        let secondSecondBits = TinyUInt1024.variadicAdditionWithOverflowCount(
            bit7,
            bit6.truncatedValue << 256)
        let firstSecondBits = TinyUInt1024.variadicAdditionWithOverflowCount(
            bit6.truncatedValue >> 256,
            bit5.truncatedValue,
            bit4.truncatedValue << 256,
            secondSecondBits.overflowCount)
        let secondFirstBits = TinyUInt1024.variadicAdditionWithOverflowCount(
            bit4.truncatedValue >> 256,
            bit3.truncatedValue,
            bit2.truncatedValue << 256,
            firstSecondBits.overflowCount)
        let firstFirstBits = TinyUInt1024.variadicAdditionWithOverflowCount(
            bit2.truncatedValue >> 256,
            bit1.truncatedValue,
            secondFirstBits.overflowCount)
        
        return (high: TinyUInt1024(firstHalf: firstFirstBits.truncatedValue, secondHalf: secondFirstBits.truncatedValue),
                low: TinyUInt1024(firstHalf: firstSecondBits.truncatedValue, secondHalf: secondSecondBits.truncatedValue))
    }
    
    // sum with counting overflows
    private static func variadicAdditionWithOverflowCount(_ adds: TinyUInt512...) -> (truncatedValue: TinyUInt512, overflowCount: TinyUInt512) {
        
        var sum: TinyUInt512 = 0
        var overflowCount: TinyUInt512 = 0
        
        for add in adds {
            let intersum = sum.addingReportingOverflow(add)
            if intersum.overflow {
                overflowCount += 1
            }
            sum = intersum.partialValue
        }
        
        return (truncatedValue: sum, overflowCount: overflowCount)
    }
    
    // MARK: - Divide
    public func dividedReportingOverflow(by rhs: TinyUInt1024) -> (partialValue: TinyUInt1024, overflow: Bool) {
        if rhs == 0 {
            return (self, true)
        } else {
            let quotient = self.quotientAndRemainder(dividingBy: rhs).quotient
            return (quotient, false)
        }
    }
    
    public func dividingFullWidth(_ dividend: (high: TinyUInt1024, low: TinyUInt1024)) -> (quotient: TinyUInt1024, remainder: TinyUInt1024) {
        return self.quotientAndRemainderFullWidth(dividingBy: dividend)
    }
    
    public func remainderReportingOverflow(dividingBy rhs: TinyUInt1024) -> (partialValue: TinyUInt1024, overflow: Bool) {
        
        if rhs == 0 {
            return (self, true)
        } else {
            let remainder = self.quotientAndRemainder(dividingBy: rhs).remainder
            return (remainder, false)
        }
    }
    
    public func quotientAndRemainder(dividingBy rhs: TinyUInt1024) -> (quotient: TinyUInt1024, remainder: TinyUInt1024) {
        return rhs.quotientAndRemainderFullWidth(dividingBy: (high: 0, low: self))
    }
    
    internal func quotientAndRemainderFullWidth(dividingBy dividend: (high: TinyUInt1024, low: TinyUInt1024)) -> (quotient: TinyUInt1024, remainder: TinyUInt1024) {
        
        let divisor = self
        var numeratorLength: TinyUInt1024
        
        if dividend.high > 0 {
            numeratorLength = dividend.high.significantBits + 1024 - 1
        } else if dividend.low == 0 {
            return (0, 0)
        } else {
            numeratorLength = dividend.low.significantBits - 1
        }
        
        // https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_.28unsigned.29_with_remainder
        // divide N by D, placing the quotient in Q and the remainder in R
        
        if self == 0 {
            exit(0) // if D = 0 then error(DivisionByZeroException) end
        }
        
        var quotient = TinyUInt1024.min // Q := 0
        var remainder = TinyUInt1024.min // R := 0
        
        for numeratorShift in (0...numeratorLength).reversed() { // for i := n − 1 .. 0 do
            remainder <<= 1 // R := R << 1
            remainder |= TinyUInt1024.bitFromPosition(at: numeratorShift, for: dividend) // R(0) := N(i)
            
            if remainder >= divisor { // if R ≥ D then
                remainder -= divisor // R := R − D
                quotient |= 1 << numeratorShift // Q(i) := 1
            }
        }
        
        return (quotient, remainder)
    }
    
    // Get the bit at position
    internal static func bitFromPosition(at bitPosition: TinyUInt1024, for input: (high: TinyUInt1024, low: TinyUInt1024)) -> TinyUInt1024 {
        switch bitPosition {
        case 0:
            return input.low & 1
        case 1...1023:
            return input.low >> bitPosition & 1
        case 1024:
            return input.high & 1
        default:
            return input.high >> (bitPosition - 1024) & 1
        }
    }
}
