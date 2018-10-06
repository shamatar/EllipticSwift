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
extension TinyUInt512: FixedWidthInteger {
    
    public var nonzeroBitCount: Int {
        return storage.secondHalf.nonzeroBitCount + storage.firstHalf.nonzeroBitCount
    }
    
    public var leadingZeroBitCount: Int {
        
        if storage.firstHalf == 0 {
            return TinyUInt256.bitWidth + storage.secondHalf.leadingZeroBitCount
        } else {
            return storage.firstHalf.leadingZeroBitCount
        }
        
    }
    
    public var bigEndian: TinyUInt512 {
        return self.byteSwapped
    }
    
    public var littleEndian: TinyUInt512 {
        return self
    }
    
    public var byteSwapped: TinyUInt512 {
        
        return TinyUInt512(firstHalf: self.storage.secondHalf.byteSwapped,
                           secondHalf: self.storage.firstHalf.byteSwapped)
        
    }
    
    // MARK: - Initializers
    public init(_truncatingBits bits: UInt) {
        self.init(firstHalf: 0, secondHalf: TinyUInt256(bits))
    }
    
    public init(bigEndian storage: TinyUInt512) {
        self = storage.bigEndian
    }

    public init(littleEndian storage: TinyUInt512) {
        self = storage.littleEndian
    }
    
    // MARK: - Plus
    public func addingReportingOverflow(_ rhs: TinyUInt512) -> (partialValue: TinyUInt512, overflow: Bool) {
        
        var resultOverflow = false
        let (secondHalf, secondOverflow) = self.storage.secondHalf.addingReportingOverflow(rhs.storage.secondHalf)
        var (firstHalf, firstOverflow) = self.storage.firstHalf.addingReportingOverflow(rhs.storage.firstHalf)
        
        if secondOverflow {
            (firstHalf, resultOverflow) = firstHalf.addingReportingOverflow(1) // adding 1 to first if second overflowed
        }
        
        return (partialValue: TinyUInt512(firstHalf: firstHalf, secondHalf: secondHalf),
                overflow: firstOverflow || resultOverflow)
        
    }
    
    // MARK: - Minus
    public func subtractingReportingOverflow(_ rhs: TinyUInt512) -> (partialValue: TinyUInt512, overflow: Bool) {
        
        var resultOverflow = false
        let (secondHalf, secondOverflow) = self.storage.secondHalf.subtractingReportingOverflow(rhs.storage.secondHalf)
        var (firstHalf, firstOverflow) = self.storage.firstHalf.subtractingReportingOverflow(rhs.storage.firstHalf)
        
        if secondOverflow {
            (firstHalf, resultOverflow) = firstHalf.subtractingReportingOverflow(1) // minus 1 from first if second overflowed
        }
        
        return (partialValue: TinyUInt512(firstHalf: firstHalf, secondHalf: secondHalf),
                overflow: firstOverflow || resultOverflow)
    }
    
    // MARK: - Multiply
    public func multipliedReportingOverflow(by rhs: TinyUInt512) -> (partialValue: TinyUInt512, overflow: Bool) {
        
        let result = self.multipliedFullWidth(by: rhs)
        let overflowResult = result.high > 0
        
        return (partialValue: result.low,
                overflow: overflowResult)
    }
    
    public func multipliedFullWidth(by other: TinyUInt512) -> (high: TinyUInt512, low: TinyUInt512.Magnitude) {
        
        let second128 = TinyUInt256(TinyUInt128.max) //mask second 128 bits of TinyUInt256
        
        // Get arrays of 4x 128bit TinyUInt256
        
        var result = [[TinyUInt256]](repeating: [TinyUInt256](repeating: 0, count: 4), count: 4)
        
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
        let lhsArray = [self.storage.firstHalf >> 128,
                        self.storage.firstHalf & second128,
                        self.storage.secondHalf >> 128,
                        self.storage.secondHalf & second128]
        
        // R0,R1,R2,R3
        let rhsArray = [other.storage.firstHalf >> 128,
                        other.storage.firstHalf & second128,
                        other.storage.secondHalf >> 128,
                        other.storage.secondHalf & second128]
        
        // Multiplication of every part: L0R0, L1R0, L2R0, ... , L3R3
        for rhsSegment in 0 ..< rhsArray.count {
            for lhsSegment in 0 ..< lhsArray.count {
                let currentValue = lhsArray[lhsSegment] * rhsArray[rhsSegment]
                result[lhsSegment][rhsSegment] = currentValue
            }
        }
        
        // addition like on scheme
        let bit7 = result[3][3] & second128
        let bit6 = TinyUInt512.variadicAdditionWithOverflowCount(
            result[2][3] & second128,
            result[3][2] & second128,
            result[3][3] >> 128) // overflow from bit7
        let bit5 = TinyUInt512.variadicAdditionWithOverflowCount(
            result[1][3] & second128,
            result[2][2] & second128,
            result[3][1] & second128,
            result[2][3] >> 128, // overflow from bit6
            result[3][2] >> 128, // overflow from bit6
            bit6.overflowCount)
        let bit4 = TinyUInt512.variadicAdditionWithOverflowCount(
            result[0][3] & second128,
            result[1][2] & second128,
            result[2][1] & second128,
            result[3][0] & second128,
            result[1][3] >> 128, // overflow from bit5
            result[2][2] >> 128, // overflow from bit5
            result[3][1] >> 128, // overflow from bit5
            bit5.overflowCount)
        let bit3 = TinyUInt512.variadicAdditionWithOverflowCount(
            result[0][2] & second128,
            result[1][1] & second128,
            result[2][0] & second128,
            result[0][3] >> 128, // overflow from bit4
            result[1][2] >> 128, // overflow from bit4
            result[2][1] >> 128, // overflow from bit4
            result[3][0] >> 128, // overflow from bit4
            bit4.overflowCount)
        let bit2 = TinyUInt512.variadicAdditionWithOverflowCount(
            result[0][1] & second128,
            result[1][0] & second128,
            result[0][2] >> 128, // overflow from bit3
            result[1][1] >> 128, // overflow from bit3
            result[2][0] >> 128, // overflow from bit3
            bit3.overflowCount)
        let bit1 = TinyUInt512.variadicAdditionWithOverflowCount(
            result[0][0],
            result[0][1] >> 128, // overflow from bit2
            result[1][0] >> 128, // overflow from bit2
            bit2.overflowCount)
        
        // 256 bit
        let secondSecondBits = TinyUInt512.variadicAdditionWithOverflowCount(
            bit7,
            bit6.truncatedValue << 128)
        let firstSecondBits = TinyUInt512.variadicAdditionWithOverflowCount(
            bit6.truncatedValue >> 128,
            bit5.truncatedValue,
            bit4.truncatedValue << 128,
            secondSecondBits.overflowCount)
        let secondFirstBits = TinyUInt512.variadicAdditionWithOverflowCount(
            bit4.truncatedValue >> 128,
            bit3.truncatedValue,
            bit2.truncatedValue << 128,
            firstSecondBits.overflowCount)
        let firstFirstBits = TinyUInt512.variadicAdditionWithOverflowCount(
            bit2.truncatedValue >> 128,
            bit1.truncatedValue,
            secondFirstBits.overflowCount)
        
        return (high: TinyUInt512(firstHalf: firstFirstBits.truncatedValue, secondHalf: secondFirstBits.truncatedValue),
                low: TinyUInt512(firstHalf: firstSecondBits.truncatedValue, secondHalf: secondSecondBits.truncatedValue))
    }

    // sum with counting overflows
    private static func variadicAdditionWithOverflowCount(_ adds: TinyUInt256...) -> (truncatedValue: TinyUInt256, overflowCount: TinyUInt256) {
        
        var sum: TinyUInt256 = 0
        var overflowCount: TinyUInt256 = 0
        
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
    public func dividedReportingOverflow(by rhs: TinyUInt512) -> (partialValue: TinyUInt512, overflow: Bool) {
        if rhs == 0 {
            return (self, true)
        } else {
            let quotient = self.quotientAndRemainder(dividingBy: rhs).quotient
            return (quotient, false)
        }
    }
    
    public func dividingFullWidth(_ dividend: (high: TinyUInt512, low: TinyUInt512)) -> (quotient: TinyUInt512, remainder: TinyUInt512) {
        return self.quotientAndRemainderFullWidth(dividingBy: dividend)
    }
    
    public func remainderReportingOverflow(dividingBy rhs: TinyUInt512) -> (partialValue: TinyUInt512, overflow: Bool) {
        
        if rhs == 0 {
            return (self, true)
        } else {
            let remainder = self.quotientAndRemainder(dividingBy: rhs).remainder
            return (remainder, false)
        }
    }
    
    public func quotientAndRemainder(dividingBy rhs: TinyUInt512) -> (quotient: TinyUInt512, remainder: TinyUInt512) {
        return rhs.quotientAndRemainderFullWidth(dividingBy: (high: 0, low: self))
    }
    
    internal func quotientAndRemainderFullWidth(dividingBy dividend: (high: TinyUInt512, low: TinyUInt512)) -> (quotient: TinyUInt512, remainder: TinyUInt512) {
        
        let divisor = self
        var numeratorLength: Int
        
        if dividend.high > 0 {
            numeratorLength = TinyUInt512.bitWidth - self.leadingZeroBitCount + 128 - 1
        } else if dividend.low == 0 {
            return (0, 0)
        } else {
            numeratorLength = TinyUInt512.bitWidth - self.leadingZeroBitCount - 1
        }
        
        // https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_.28unsigned.29_with_remainder
        // divide N by D, placing the quotient in Q and the remainder in R
        
        if self == 0 {
            exit(0) // if D = 0 then error(DivisionByZeroException) end
        }
        
        var quotient = TinyUInt512.min // Q := 0
        var remainder = TinyUInt512.min // R := 0
        
        for numeratorShift in (0...numeratorLength).reversed() { // for i := n − 1 .. 0 do
            remainder <<= 1 // R := R << 1
            remainder |= TinyUInt512.bitFromPosition(at: numeratorShift, for: dividend) // R(0) := N(i)
            
            if remainder >= divisor { // if R ≥ D then
                remainder -= divisor // R := R − D
                quotient.setBit(i: numeratorShift)
//                quotient |= 1 << numeratorShift // Q(i) := 1
            }
        }
        
        return (quotient, remainder)
    }
    
    // Get the bit at position
    @inline(__always) internal static func bitFromPosition(at bitPosition: TinyUInt512, for input: (high: TinyUInt512, low: TinyUInt512)) -> TinyUInt512 {
        switch bitPosition {
        case 0:
            return input.low & 1
        case 1...511:
            return input.low >> bitPosition & 1
        case 512:
            return input.high & 1
        default:
            return input.high >> (bitPosition - 512) & 1
        }
    }
    
    // Get the bit at position
    @inline(__always) internal static func bitFromPosition(at bitPosition: Int, for input: (high: TinyUInt512, low: TinyUInt512)) -> TinyUInt512 {
        switch bitPosition {
        case 0...511:
            return input.low.getBit(at: bitPosition) ? TinyUInt512(1) : TinyUInt512(0)
        case 512...1023:
            return input.high.getBit(at: bitPosition - 512) ? TinyUInt512(1) : TinyUInt512(0)
        default:
            return TinyUInt512(0)
        }
    }
    
    // Get the bit at position
    @inline(__always) internal func getBit(at i: Int) -> Bool {
        if i < 0 {
            return false
        } else if i < 255 {
            return self.storage.secondHalf.getBit(at: i)
        } else if i < 511 {
            return self.storage.secondHalf.getBit(at: i - 256)
        }
        return false
    }
    
    @inline(__always) internal mutating func setBit(i: Int) {
        if i < 0 {
            return
        } else if i < 255 {
            self.storage.secondHalf.setBit(i: i)
        } else if i < 511 {
            self.storage.secondHalf.setBit(i: i - 256)
        }
    }
}
