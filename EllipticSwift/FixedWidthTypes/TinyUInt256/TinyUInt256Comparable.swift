//
//  TinyUInt256Comparable.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming Comparable for using it's methods
 */
extension TinyUInt256: Comparable {
    
    public static func <(lhs: TinyUInt256, rhs: TinyUInt256) -> Bool {
        if lhs.storage.firstHalf < rhs.storage.firstHalf {
            return true
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf < rhs.storage.secondHalf {
            return true
        }
        return false
    }
    
    public static func >(lhs: TinyUInt256, rhs: TinyUInt256) -> Bool {
        if lhs.storage.firstHalf > rhs.storage.firstHalf {
            return true
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf > rhs.storage.secondHalf {
            return true
        }
        return false
    }
    
    public static func <=(lhs: TinyUInt256, rhs: TinyUInt256) -> Bool {
        if lhs.storage.firstHalf > rhs.storage.firstHalf {
            return false
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf > rhs.storage.secondHalf {
            return false
        }
        return true
    }
    
    public static func >=(lhs: TinyUInt256, rhs: TinyUInt256) -> Bool {
        if lhs.storage.firstHalf < rhs.storage.firstHalf {
            return false
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf < rhs.storage.secondHalf {
            return false
        }
        return true
    }
}
