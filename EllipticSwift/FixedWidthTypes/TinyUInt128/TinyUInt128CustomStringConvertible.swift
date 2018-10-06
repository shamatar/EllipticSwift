//
//  TinyUInt128CustomStringConvertible.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 29.07.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

import Darwin

/*
 * - Extension for conforming CustomStringConvertible for using it's method valueToString
 */
extension TinyUInt128: CustomStringConvertible {
    
    public var description: String {
        return self.valueToString()
    }
    
    internal func valueToString(radix: Int = 10, uppercase: Bool = true) -> String {
        
        var result = String()
        
        // For string interpolation
        var divModResult = (quotient: self, remainder: TinyUInt128(0))
        
        let possibleValues = uppercase ? "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" : "0123456789abcdefghijklmnopqrstuvwxyz"
        
        // turning into string
        repeat {
            divModResult = divModResult.quotient.quotientAndRemainder(dividingBy: TinyUInt128(radix))
            let index = possibleValues.index(possibleValues.startIndex, offsetBy: Int(divModResult.remainder))
            result.insert(possibleValues[index], at: result.startIndex)
        } while divModResult.quotient > 0
        
        return result
    }
}
