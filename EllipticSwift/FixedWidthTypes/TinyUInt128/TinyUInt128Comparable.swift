//
//  TinyUInt128Comparable.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 28.07.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming Comparable for using it's methods
 */
extension TinyUInt128: Comparable {
    
    public static func <(lhs: TinyUInt128, rhs: TinyUInt128) -> Bool {
        if lhs.storage.firstHalf < rhs.storage.firstHalf {
            return true
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf < rhs.storage.secondHalf {
            return true
        } else {
            return false
        }
    }
    
    public static func >(lhs: TinyUInt128, rhs: TinyUInt128) -> Bool {
        if lhs.storage.firstHalf > rhs.storage.firstHalf {
            return true
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf > rhs.storage.secondHalf {
            return true
        } else {
            return false
        }
    }
    
    public static func <=(lhs: TinyUInt128, rhs: TinyUInt128) -> Bool {
        if lhs.storage.firstHalf > rhs.storage.firstHalf {
            return false
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf > rhs.storage.secondHalf {
            return false
        } else {
            return true
        }
    }
    
    public static func >=(lhs: TinyUInt128, rhs: TinyUInt128) -> Bool {
        if lhs.storage.firstHalf < rhs.storage.firstHalf {
            return false
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf < rhs.storage.secondHalf {
            return false
        }
        return true
    }
}
