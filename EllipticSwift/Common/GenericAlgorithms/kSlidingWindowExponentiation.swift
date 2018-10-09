//
//  kSlidingWindowExponentiation.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 25.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

internal func kSlidingWindowExponentiationGeneric<T, U>(a: T, power: U, identity: T, multiplicationFunction: (T, T) -> T, windowSize: Int = DefaultWindowSize) -> T where U: BitsAndBytes {
    let numPrecomputedElements = (1 << windowSize) - 1 // 2**k - 1
    var precomputations = [T](repeating: identity, count: numPrecomputedElements)
    precomputations[0] = a
    precomputations[1] = multiplicationFunction(a, a)
    for i in 2 ..< numPrecomputedElements {
        precomputations[i] = multiplicationFunction(precomputations[i-2], precomputations[1])
    }
    var result = identity
    let (lookups, powers) = computeSlidingWindow(scalar: power, windowSize: windowSize)
    for i in 0 ..< lookups.count {
        let lookupCoeff = lookups[i]
        if lookupCoeff == -1 {
            result = multiplicationFunction(result, result)
        } else {
            let chosenPower = powers[i]
            let intermediatePower = DoubleAndAddExponentiationGeneric(a: result, power: chosenPower, identity: identity, multiplicationFunction: multiplicationFunction) // use trivial form to don't go recursion
            result = multiplicationFunction(intermediatePower, precomputations[lookupCoeff])
        }
    }
    return result
}
