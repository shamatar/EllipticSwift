//
//  TinyUInt256Equatable.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming Equatable
 */
extension TinyUInt256: Equatable {
    
    public static func ==(lhs: TinyUInt256, rhs: TinyUInt256) -> Bool {
        if lhs.storage.secondHalf == rhs.storage.secondHalf && lhs.storage.firstHalf == rhs.storage.firstHalf {
            return true
        }
        return false
    }
}
 
