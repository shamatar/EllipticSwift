//
//  TinyUInt512Equatable.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming Equatable
 */
extension TinyUInt512: Equatable {
    
    public static func ==(lhs: TinyUInt512, rhs: TinyUInt512) -> Bool {
        if lhs.storage.secondHalf == rhs.storage.secondHalf && lhs.storage.firstHalf == rhs.storage.firstHalf {
            return true
        }
        return false
    }
}
 
