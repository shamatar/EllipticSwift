//
//  TinyUInt128Equatable.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 28.07.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming Equatable
 */
extension TinyUInt128: Equatable {
    
    public static func ==(lhs: TinyUInt128, rhs: TinyUInt128) -> Bool {
        if lhs.storage.secondHalf == rhs.storage.secondHalf && lhs.storage.firstHalf == rhs.storage.firstHalf {
            return true
        }
        return false
    }
}
 
