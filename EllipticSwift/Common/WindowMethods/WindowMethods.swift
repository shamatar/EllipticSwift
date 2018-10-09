//
//  KSlidingWindow.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

// returns [Int] - lookup coefficients in precompute, stores as SIGNED
public func computeWNAF<T: FiniteFieldCompatible>(scalar: T, windowSize: Int = DefaultWindowSize) -> [Int] {
    var result = [Int]()
    result.reserveCapacity(100)
    var coeffsIndex: Int = 0 // points to array of NAF coefficients.
    func guardedMods(_ a: UInt32, _ half: Int, _ full: Int) -> Int {
        precondition(full <= UInt32.max)
        if a > half {
            return full - Int(a)
        } else {
            return Int(a)
        }
    }
    var dCoeffs = [Int]()
    var i = 0
    var scalarCopy = scalar
    let maxBit = windowSize - 1
    let half = 1 << (windowSize-1)
    let full = 1 << windowSize
    while scalarCopy > 0 {
        if !scalarCopy.isEven {
            let data = scalarCopy.bytes.bytes
            let coeff = bits(data, maxBit, 0) // should be window size long
            let mods = guardedMods(coeff, half, full)
            dCoeffs.append(mods)
            if mods > 0 {
                scalarCopy = scalarCopy - T(UInt64(mods))
            } else {
                scalarCopy = scalarCopy + T(UInt64(-mods))
            }
//            scalarCopy = scalarCopy >> UInt32(windowSize)
            scalarCopy = scalarCopy >> UInt32(1)
        } else {
            dCoeffs.append(0)
            scalarCopy = scalarCopy >> UInt32(1)
        }
        i = i + 1
    }
    return dCoeffs
}

// returns [Int] - lookup coefficients in precompute, [UInt64] - powers to rise the result
// lookup == -1 -> Just rise in a power
public func computeSlidingWindow<T: BitsAndBytes> (scalar: T, windowSize: Int = DefaultWindowSize) -> ([Int], [UInt64]){
    // compute left to right
    let numElements = (scalar.bitWidth - 1) / windowSize + 1
    var lookupCoeffs = [Int]()
    lookupCoeffs.reserveCapacity(numElements)
    var powers = [UInt64]()
    powers.reserveCapacity(numElements)
    let data = scalar.bytes.bytes
    var i = scalar.bitWidth - 1
    while i > 0 {
        if !scalar.bit(i) {
            lookupCoeffs.append(-1)
            powers.append(2)
            i = i - 1
        } else {
            var l = i - windowSize + 1
            var nextI = l - 1
            if l <= 0 {
                l = 0
                nextI = 0
            }
            var bitSlice = bits(data, i, l)
            let sliceBitWidth = i - l + 1
            let elementNumber = Int(bitSlice) - 1
            if bitSlice == 0 {
                i = nextI
                continue
            }
            while bitSlice & 1 == 0 {
                bitSlice = bitSlice >> 1
                l = l + 1
            }
            var power = UInt64(1) << windowSize
            if windowSize > sliceBitWidth {
                power = UInt64(1) << sliceBitWidth
            }
            lookupCoeffs.append(elementNumber)
            powers.append(power)
            i = nextI
        }
    }
    return (lookupCoeffs, powers)
}

internal func bits(_ beData: [UInt8], _ from: Int, _ to: Int) -> UInt32 {
    // TODO: should improve to one pass
    let numBytes = beData.count
    precondition(to < beData.count * 8, "accessing out of range bits")
    precondition(from > to, "should access nonzero range with LE notation")
    precondition(to - from < UInt32.bitWidth, "not meant to access more than " + String(UInt32.bitWidth) + " bits")
    var (upperByteNumber, upperBitInByte) = from.quotientAndRemainder(dividingBy: 8)
    var (lowerByteNumber, lowerBitInByte) = to.quotientAndRemainder(dividingBy: 8)
    upperByteNumber = numBytes - upperByteNumber - 1
    lowerByteNumber = numBytes - lowerByteNumber - 1
    if upperByteNumber == lowerByteNumber {
        precondition(upperBitInByte <= 7)
        var bitmask: UInt8 = UInt8((UInt16(1) << (upperBitInByte - lowerBitInByte + 1)) - UInt16(1))
        bitmask = bitmask << lowerBitInByte
        let byte = beData[lowerByteNumber]
        let maskedValue = byte & bitmask
        let result = UInt32(maskedValue >> lowerBitInByte)
        return result
    } else {
        let bitsFromUpperByte = upperBitInByte + 1
        let upperByteBitmask: UInt8 = UInt8((UInt16(1) << bitsFromUpperByte) - UInt16(1))
        let upperByte = beData[upperByteNumber]
        let upperBits = (upperByte & upperByteBitmask)

        let bitsFromLowerByte = 8 - lowerBitInByte
        var lowerByteBitmask: UInt8 = UInt8((UInt16(1) << bitsFromLowerByte) - UInt16(1))
        lowerByteBitmask = lowerByteBitmask << lowerBitInByte
        let lowerByte = beData[lowerByteNumber]
        let lowerBits = (lowerByte & lowerByteBitmask) >> lowerBitInByte
        
        var fullBits = UInt32(lowerBits)
        var shiftMultiplier = 0
        for i in (upperByteNumber+1) ..< lowerByteNumber {
            fullBits |= UInt32(beData[i]) << (shiftMultiplier*8 + lowerBitInByte)
            shiftMultiplier = shiftMultiplier + 1
        }
        fullBits |= UInt32(upperBits) << (shiftMultiplier*8 + bitsFromLowerByte)
        return fullBits
    }
    
}
