//
//  TinyUInt512Comparable.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming Comparable for using it's methods
 */
extension TinyUInt512: Comparable {
    
    public static func <(lhs: TinyUInt512, rhs: TinyUInt512) -> Bool {
        if lhs.storage.firstHalf < rhs.storage.firstHalf {
            return true
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf < rhs.storage.secondHalf {
            return true
        }
        return false
    }
    
    public static func >(lhs: TinyUInt512, rhs: TinyUInt512) -> Bool {
        if lhs.storage.firstHalf > rhs.storage.firstHalf {
            return true
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf > rhs.storage.secondHalf {
            return true
        }
        return false
    }
    
    public static func <=(lhs: TinyUInt512, rhs: TinyUInt512) -> Bool {
        if lhs.storage.firstHalf > rhs.storage.firstHalf {
            return false
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf > rhs.storage.secondHalf {
            return false
        }
        return true
    }
    
    public static func >=(lhs: TinyUInt512, rhs: TinyUInt512) -> Bool {
        if lhs.storage.firstHalf < rhs.storage.firstHalf {
            return false
        } else if lhs.storage.firstHalf == rhs.storage.firstHalf && lhs.storage.secondHalf < rhs.storage.secondHalf {
            return false
        }
        return true
    }
}
