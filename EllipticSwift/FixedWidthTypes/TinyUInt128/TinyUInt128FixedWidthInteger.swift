//
//  TinyUIntFixedWidthInteger.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 27.07.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

import Darwin

/*
 * - Extension for conforming FixedWidthInteger, that contains Instanse methods of adding, subtracting, multiplying, dividing
 */
extension TinyUInt128: FixedWidthInteger {
    
    public var nonzeroBitCount: Int {
        return storage.secondHalf.nonzeroBitCount + storage.firstHalf.nonzeroBitCount
    }
    
    public var leadingZeroBitCount: Int {
        if storage.firstHalf == 0 {
            return 64 + storage.secondHalf.leadingZeroBitCount
        } else {
            return storage.firstHalf.leadingZeroBitCount
        }
    }
    
    public var bigEndian: TinyUInt128 {
        return self.byteSwapped
    }
    
    public var littleEndian: TinyUInt128 {
        return self
    }
    
    public var byteSwapped: TinyUInt128 {
        return TinyUInt128(firstHalf: self.storage.secondHalf.byteSwapped,
                           secondHalf: self.storage.firstHalf.byteSwapped)
    }
    
    // MARK: - Initializers
    public init(_truncatingBits bits: UInt) {
        self.init(firstHalf: 0, secondHalf: UInt64(bits))
    }
    
    public init(bigEndian storage: TinyUInt128) {
        self = storage.bigEndian
    }

    public init(littleEndian storage: TinyUInt128) {
        self = storage.littleEndian
    }
    
    // MARK: - Plus
    public func addingReportingOverflow(_ rhs: TinyUInt128) -> (partialValue: TinyUInt128, overflow: Bool) {
        
        var resultOverflow = false
        let (secondHalf, secondOverflow) = self.storage.secondHalf.addingReportingOverflow(rhs.storage.secondHalf)
        var (firstHalf, firstOverflow) = self.storage.firstHalf.addingReportingOverflow(rhs.storage.firstHalf)
        
        if secondOverflow {
            (firstHalf, resultOverflow) = firstHalf.addingReportingOverflow(1) // adding 1 to first if second overflowed
        }
        
        return (partialValue: TinyUInt128(firstHalf: firstHalf, secondHalf: secondHalf),
                overflow: firstOverflow || resultOverflow)
        
    }
    
    // MARK: - Minus
    public func subtractingReportingOverflow(_ rhs: TinyUInt128) -> (partialValue: TinyUInt128, overflow: Bool) {
        
        var resultOverflow = false
        let (secondHalf, secondOverflow) = self.storage.secondHalf.subtractingReportingOverflow(rhs.storage.secondHalf)
        var (firstHalf, firstOverflow) = self.storage.firstHalf.subtractingReportingOverflow(rhs.storage.firstHalf)
        
        if secondOverflow {
            (firstHalf, resultOverflow) = firstHalf.subtractingReportingOverflow(1) // minus 1 from first if second overflowed
        }
        
        return (partialValue: TinyUInt128(firstHalf: firstHalf, secondHalf: secondHalf),
                overflow: firstOverflow || resultOverflow)
    }
    
    // MARK: - Multiply
    public func multipliedReportingOverflow(by rhs: TinyUInt128) -> (partialValue: TinyUInt128, overflow: Bool) {
        
        let result = self.multipliedFullWidth(by: rhs)
        let overflowResult = result.high > 0
        
        return (partialValue: result.low,
                overflow: overflowResult)
    }
    
    public func multipliedFullWidth(by other: TinyUInt128) -> (high: TinyUInt128, low: TinyUInt128.Magnitude) {
        
        let second32 = UInt64(UInt32.max) //mask second 32 bits of UInt64
        
        // Get arrays of 4x 32bit UInt64
        
        var result = [[UInt64]](repeating: [UInt64](repeating: 0, count: 4), count: 4)
        
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
        let lhsArray = [self.storage.firstHalf >> 32,
                        self.storage.firstHalf & second32,
                        self.storage.secondHalf >> 32,
                        self.storage.secondHalf & second32]
        
        // R0,R1,R2,R3
        let rhsArray = [other.storage.firstHalf >> 32,
                        other.storage.firstHalf & second32,
                        other.storage.secondHalf >> 32,
                        other.storage.secondHalf & second32]
        
        // Multiplication of every part: L0R0, L1R0, L2R0, ... , L3R3
        for rhsSegment in 0 ..< rhsArray.count {
            for lhsSegment in 0 ..< lhsArray.count {
                let currentValue = lhsArray[lhsSegment] * rhsArray[rhsSegment]
                result[lhsSegment][rhsSegment] = currentValue
            }
        }
        
        // addition like on scheme
        let bit7 = result[3][3] & second32
        let bit6 = TinyUInt128.variadicAdditionWithOverflowCount(
            result[2][3] & second32,
            result[3][2] & second32,
            result[3][3] >> 32) // overflow from bit7
        let bit5 = TinyUInt128.variadicAdditionWithOverflowCount(
            result[1][3] & second32,
            result[2][2] & second32,
            result[3][1] & second32,
            result[2][3] >> 32, // overflow from bit6
            result[3][2] >> 32, // overflow from bit6
            bit6.overflowCount)
        let bit4 = TinyUInt128.variadicAdditionWithOverflowCount(
            result[0][3] & second32,
            result[1][2] & second32,
            result[2][1] & second32,
            result[3][0] & second32,
            result[1][3] >> 32, // overflow from bit5
            result[2][2] >> 32, // overflow from bit5
            result[3][1] >> 32, // overflow from bit5
            bit5.overflowCount)
        let bit3 = TinyUInt128.variadicAdditionWithOverflowCount(
            result[0][2] & second32,
            result[1][1] & second32,
            result[2][0] & second32,
            result[0][3] >> 32, // overflow from bit4
            result[1][2] >> 32, // overflow from bit4
            result[2][1] >> 32, // overflow from bit4
            result[3][0] >> 32, // overflow from bit4
            bit4.overflowCount)
        let bit2 = TinyUInt128.variadicAdditionWithOverflowCount(
            result[0][1] & second32,
            result[1][0] & second32,
            result[0][2] >> 32, // overflow from bit3
            result[1][1] >> 32, // overflow from bit3
            result[2][0] >> 32, // overflow from bit3
            bit3.overflowCount)
        let bit1 = TinyUInt128.variadicAdditionWithOverflowCount(
            result[0][0],
            result[0][1] >> 32, // overflow from bit2
            result[1][0] >> 32, // overflow from bit2
            bit2.overflowCount)
        
        // 64 bit
        let secondSecondBits = TinyUInt128.variadicAdditionWithOverflowCount(
            bit7,
            bit6.truncatedValue << 32)
        let firstSecondBits = TinyUInt128.variadicAdditionWithOverflowCount(
            bit6.truncatedValue >> 32,
            bit5.truncatedValue,
            bit4.truncatedValue << 32,
            secondSecondBits.overflowCount)
        let secondFirstBits = TinyUInt128.variadicAdditionWithOverflowCount(
            bit4.truncatedValue >> 32,
            bit3.truncatedValue,
            bit2.truncatedValue << 32,
            firstSecondBits.overflowCount)
        let firstFirstBits = TinyUInt128.variadicAdditionWithOverflowCount(
            bit2.truncatedValue >> 32,
            bit1.truncatedValue,
            secondFirstBits.overflowCount)
        
        return (high: TinyUInt128(firstHalf: firstFirstBits.truncatedValue, secondHalf: secondFirstBits.truncatedValue),
                low: TinyUInt128(firstHalf: firstSecondBits.truncatedValue, secondHalf: secondSecondBits.truncatedValue))
    }

    // sum with counting overflows
    private static func variadicAdditionWithOverflowCount(_ adds: UInt64...) -> (truncatedValue: UInt64, overflowCount: UInt64) {
        
        var sum: UInt64 = 0
        var overflowCount: UInt64 = 0
        
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
    public func dividedReportingOverflow(by rhs: TinyUInt128) -> (partialValue: TinyUInt128, overflow: Bool) {
        
        if rhs == 0 {
            return (self, true)
        } else {
            let quotient = self.quotientAndRemainder(dividingBy: rhs).quotient
            return (quotient, false)
        }
        
    }
    
    public func dividingFullWidth(_ dividend: (high: TinyUInt128, low: TinyUInt128)) -> (quotient: TinyUInt128, remainder: TinyUInt128) {
        return self.quotientAndRemainderFullWidth(dividingBy: dividend)
    }
    
    public func remainderReportingOverflow(dividingBy rhs: TinyUInt128) -> (partialValue: TinyUInt128, overflow: Bool) {
        
        if rhs == 0 {
            return (self, true)
        } else {
            let remainder = self.quotientAndRemainder(dividingBy: rhs).remainder
            return (remainder, false)
        }
        
    }
    
    public func quotientAndRemainder(dividingBy rhs: TinyUInt128) -> (quotient: TinyUInt128, remainder: TinyUInt128) {
        return rhs.quotientAndRemainderFullWidth(dividingBy: (high: 0, low: self))
    }
    
    internal func quotientAndRemainderFullWidth(dividingBy dividend: (high: TinyUInt128, low: TinyUInt128)) -> (quotient: TinyUInt128, remainder: TinyUInt128) {
        
        let divisor = self
        var numeratorLength: Int
        
        if dividend.high > 0 {
            numeratorLength = 256 - dividend.high.leadingZeroBitCount
        } else if dividend.low == 0 {
            return (0, 0)
        } else {
            numeratorLength = 128 - dividend.low.leadingZeroBitCount
        }
        
        // https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_.28unsigned.29_with_remainder
        // divide N by D, placing the quotient in Q and the remainder in R
        
        if self == 0 {
            precondition(false) // if D = 0 then error(DivisionByZeroException) end
        }
        
        var quotient = TinyUInt128.min // Q := 0
        var remainder = TinyUInt128.min // R := 0
        
        for numeratorShift in (0 ..< numeratorLength).reversed() { // for i := n − 1 .. 0 do
            remainder <<= 1 // R := R << 1
            if TinyUInt128.getBitFromPosition(at: numeratorShift, for: dividend) {
                remainder.setBit(i: 0)
            }
            
            if remainder >= divisor { // if R ≥ D then
                remainder -= divisor // R := R − D
                quotient.setBit(i: numeratorShift)
            }
        }
        
        return (quotient, remainder)
    }
    
    // Get the bit at position
    @inline(__always) internal static func bitFromPosition(at bitPosition: Int, for input: (high: TinyUInt128, low: TinyUInt128)) -> TinyUInt128 {
        switch bitPosition {
        case 0...127:
            return input.low.getBit(at: bitPosition) ? TinyUInt128(1) : TinyUInt128(0)
        case 128...255:
            return input.high.getBit(at: bitPosition - 128) ? TinyUInt128(1) : TinyUInt128(0)
        default:
            return TinyUInt128(0)
        }
    }
    
    // Get the bit at position
    @inline(__always) internal static func getBitFromPosition(at bitPosition: Int, for input: (high: TinyUInt128, low: TinyUInt128)) -> Bool {
        switch bitPosition {
        case 0...127:
            return input.low.getBit(at: bitPosition)
        case 128...255:
            return input.high.getBit(at: bitPosition - 128)
        default:
            return false
        }
    }
    
    // Get the bit at position
    @inline(__always) internal func getBit(at i: Int) -> Bool {
        if i < 0 {
            return false
        } else if i < 64 {
            return self.storage.secondHalf & (UInt64(1) << i) > 0
        } else if i < 128 {
            return self.storage.firstHalf & (UInt64(1) << (i - 64)) > 0
        }
        return false
    }
    
    // Get the bit at position
    @inline(__always) internal func getBitAsInt(at i: Int) -> Int {
        if i < 0 {
            return 0
        } else if i < 64 {
            return self.storage.secondHalf & (UInt64(1) << i) > 0 ? 1 : 0
        } else if i < 128 {
            return self.storage.firstHalf & (UInt64(1) << (i - 64)) > 0 ? 1 : 0
        }
        return 0
    }
    
    @inline(__always) internal mutating func setBit(i: Int) {
        if i < 0 {
            return
        } else if i < 64 {
            self.storage.secondHalf |= (UInt64(1) << i)
        } else if i < 128 {
            self.storage.firstHalf |= (UInt64(1) << (i - 64))
        }
    }
    
    @inline(__always) internal mutating func setBit(i: Int, bitValue: Int) {
        if i < 0 {
            return
        } else if i < 64 {
            self.storage.secondHalf |= (UInt64(bitValue) << i)
        } else if i < 128 {
            self.storage.firstHalf |= (UInt64(bitValue) << (i - 64))
        }
    }
}
